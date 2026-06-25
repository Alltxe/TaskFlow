import {
  Injectable,
  NotFoundException,
  ForbiddenException,
  BadRequestException,
  Inject,
  Logger,
} from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import {
  CreateTaskInput,
  UpdateTaskInput,
  CompleteTaskInput,
  ApproveTaskInput,
  ClaimTaskInput,
  AddTaskAttachmentInput,
} from './dto/task.input';
import { RotationService } from './rotation.service';
import { RecurringTaskService } from './recurring-task.service';
import { StorageService } from '../storage/storage.service';
import { AuditLogService, AuditAction } from '../audit-log/audit-log.service';
import { NotificationMessages } from '../../common/i18n/notification-messages';
import { NotificationService } from '../notification/notification.service';
import { NotificationType as NotificationTypeEnum } from '@prisma/client';
import { CACHE_MANAGER } from '@nestjs/cache-manager';
import { Cache } from 'cache-manager';

@Injectable()
export class TaskService {
  private readonly logger = new Logger(TaskService.name);

  constructor(
    private prisma: PrismaService,
    private rotationService: RotationService,
    private recurringTaskService: RecurringTaskService,
    private auditLogService: AuditLogService,
    private notificationService: NotificationService,
    private storageService: StorageService,
    @Inject(CACHE_MANAGER) private cacheManager: Cache,
  ) {}

  /**
   * Создать задачу (только админы группы)
   */
  async createTask(userId: string, input: CreateTaskInput) {
    console.log('[TaskService.createTask] Input:', JSON.stringify(input, null, 2));
    console.log('[TaskService.createTask] UserId:', userId);

    const {
      title,
      description,
      deadline,
      priority,
      points,
      requiresApproval,
      isRecurring,
      recurrenceRule,
      rotationType,
      weight,
      groupId,
      assigneeId,
    } = input;

    const deadlineDate = new Date(deadline);
    if (Number.isNaN(deadlineDate.getTime())) {
      throw new BadRequestException('Некорректный формат deadline');
    }

    if (isRecurring && (!recurrenceRule || recurrenceRule.trim().length === 0)) {
      throw new BadRequestException(
        'Для шаблона повторяющейся задачи требуется recurrenceRule',
      );
    }

    if (isRecurring && recurrenceRule) {
      try {
        this.recurringTaskService.validateRecurrenceRule(
          recurrenceRule,
          deadlineDate,
        );
      } catch (error) {
        throw new BadRequestException(
          `Некорректный recurrenceRule: ${error.message}`,
        );
      }
    }

    // Проверяем, что пользователь - админ группы
    const member = await this.prisma.groupMember.findFirst({
      where: {
        groupId,
        userId,
        role: 'ADMIN',
      },
    });

    if (!member) {
      throw new ForbiddenException(
        'Только администраторы могут создавать задачи',
      );
    }

    // Если указан assignee, проверяем что он член группы
    if (assigneeId) {
      const assigneeMember = await this.prisma.groupMember.findFirst({
        where: {
          groupId,
          userId: assigneeId,
        },
      });

      if (!assigneeMember) {
        throw new BadRequestException(
          'Указанный пользователь не является членом группы',
        );
      }
    }

    // Если assignee не указан, назначаем по алгоритму ротации
    // ИСКЛЮЧЕНИЕ: если rotationType = DISABLED, оставляем задачу в Up-for-Grabs
    let finalAssigneeId: string | null | undefined = assigneeId;
    if (!finalAssigneeId && !isRecurring) {
      const group = await this.prisma.group.findUnique({
        where: { id: groupId },
        select: { rotationType: true },
      });
      const effectiveRotationType = rotationType || group?.rotationType || 'ROUND_ROBIN';
      if (effectiveRotationType !== 'DISABLED') {
        finalAssigneeId = await this.rotationService.selectAssignee(
          groupId,
          effectiveRotationType,
          weight || 1,
        );
      }
    }

    const task = await this.prisma.task.create({
      data: {
        title,
        description,
        deadline: deadlineDate,
        priority,
        points,
        requiresApproval: requiresApproval ?? true,
        isRecurring: isRecurring ?? false,
        recurrenceRule,
        rotationType: rotationType as any,
        weight: weight || 1,
        groupId,
        createdById: userId,
        assigneeId: finalAssigneeId,
        status: 'PENDING',
      },
      include: {
        assignee: true,
        createdBy: true,
      },
    });

    // Phase 8: Notify assignee on assignment (PRD 3.6.3)
    if (task.assigneeId && !task.isRecurring) {
      await this.notificationService.notify({
        userId: task.assigneeId,
        title: NotificationMessages.taskAssignedTitle(),
        message: NotificationMessages.taskAssigned(task.title),
        type: NotificationTypeEnum.TASK_ASSIGNED,
        relatedEntityType: 'Task',
        relatedEntityId: task.id,
        sentById: userId,
      });
    }

    await this.auditLogService.createLog({
      action: AuditAction.TASK_CREATED,
      entityType: 'Task',
      entityId: task.id,
      userId,
      newValues: {
        title: task.title,
        groupId: task.groupId,
        isRecurring: task.isRecurring,
      },
    });

    if (task.isRecurring) {
      try {
        await this.recurringTaskService.forceGenerateNextTask(task.id);
      } catch (error) {
        this.logger.warn(
          `Recurring template ${task.id} created, but first child generation failed: ${error.message}`,
        );
      }
    }

    return task;
  }

  // Rotation logic moved to RotationService (PRD 3.4.x Phase 5)

  /**
   * Получить задачу по ID
   */
  async getTask(taskId: string, userId: string) {
    const task = await this.prisma.task.findUnique({
      where: { id: taskId },
      include: {
        assignee: true,
        createdBy: true,
        attachments: {
          orderBy: { uploadedAt: 'desc' },
        },
        group: {
          include: {
            members: true,
          },
        },
      },
    });

    if (!task) {
      throw new NotFoundException('Задача не найдена');
    }

    // Проверяем, что пользователь - член группы
    const isMember = task.group.members.some((m) => m.userId === userId);
    if (!isMember) {
      throw new ForbiddenException('У вас нет доступа к этой задаче');
    }

    return task;
  }

  /**
   * Получить задачи группы
   */
  async getGroupTasks(groupId: string, userId: string, status?: string) {
    // Проверяем членство
    const member = await this.prisma.groupMember.findFirst({
      where: { groupId, userId },
    });

    if (!member) {
      throw new ForbiddenException('Вы не являетесь членом группы');
    }

    const whereClause: any = { groupId };
    whereClause.isRecurring = false;
    if (status) {
      whereClause.status = status;
    }

    const tasks = await this.prisma.task.findMany({
      where: whereClause,
      include: {
        assignee: true,
        createdBy: true,
      },
      orderBy: { deadline: 'asc' },
    });

    return tasks;
  }

  /**
   * Получить задачи пользователя
   */
  async getUserTasks(userId: string, status?: string) {
    const whereClause: any = { assigneeId: userId };
    whereClause.isRecurring = false;
    if (status) {
      whereClause.status = status;
    }

    const tasks = await this.prisma.task.findMany({
      where: whereClause,
      include: {
        assignee: true,
        createdBy: true,
        group: true,
      },
      orderBy: { deadline: 'asc' },
    });

    return tasks;
  }

  /**
   * Получить шаблоны повторяющихся задач группы
   */
  async getRecurringTemplates(groupId: string, userId: string) {
    const member = await this.prisma.groupMember.findFirst({
      where: { groupId, userId },
    });

    if (!member) {
      throw new ForbiddenException('Вы не являетесь членом группы');
    }

    const templates = await this.prisma.task.findMany({
      where: {
        groupId,
        isRecurring: true,
        parentTaskId: null,
      },
      include: {
        assignee: true,
        createdBy: true,
      },
      orderBy: { createdAt: 'desc' },
    });

    return templates;
  }

  /**
   * Обновить задачу (только админы или создатель)
   */
  async updateTask(taskId: string, userId: string, input: UpdateTaskInput) {
    const task = await this.getTask(taskId, userId);
    const previousAssigneeId = task.assigneeId;

    // Проверяем права: админ или создатель
    const member = await this.prisma.groupMember.findFirst({
      where: {
        groupId: task.groupId,
        userId,
      },
    });

    const isAdmin = member?.role === 'ADMIN';
    const isCreator = task.createdById === userId;

    if (!isAdmin && !isCreator) {
      throw new ForbiddenException(
        'Только администраторы или создатель могут редактировать задачу',
      );
    }

    if (input.assigneeId !== undefined) {
      const assigneeMember = await this.prisma.groupMember.findFirst({
        where: {
          groupId: task.groupId,
          userId: input.assigneeId,
        },
      });

      if (!assigneeMember) {
        throw new BadRequestException(
          'Указанный пользователь не является членом группы',
        );
      }
    }

    const updatedTask = await this.prisma.task.update({
      where: { id: taskId },
      data: {
        ...(input.title && { title: input.title }),
        ...(input.description !== undefined && { description: input.description }),
        ...(input.deadline && { deadline: new Date(input.deadline) }),
        ...(input.priority && { priority: input.priority }),
        ...(input.points && { points: input.points }),
        ...(input.requiresApproval !== undefined && {
          requiresApproval: input.requiresApproval,
        }),
        ...(input.assigneeId !== undefined && { assigneeId: input.assigneeId }),
      },
      include: {
        assignee: true,
        createdBy: true,
      },
    });

    // Notify new assignee when task assignment changes.
    if (
      input.assigneeId !== undefined &&
      updatedTask.assigneeId &&
      updatedTask.assigneeId !== previousAssigneeId
    ) {
      await this.notificationService.notify({
        userId: updatedTask.assigneeId,
        title: NotificationMessages.taskAssignedTitle(),
        message: NotificationMessages.taskAssigned(updatedTask.title),
        type: NotificationTypeEnum.TASK_ASSIGNED,
        relatedEntityType: 'Task',
        relatedEntityId: updatedTask.id,
        sentById: userId,
      });
    }

    return updatedTask;
  }

  /**
   * Удалить задачу (только админы)
   */
  async deleteTask(taskId: string, userId: string) {
    const task = await this.getTask(taskId, userId);

    // Проверяем права администратора
    const member = await this.prisma.groupMember.findFirst({
      where: {
        groupId: task.groupId,
        userId,
        role: 'ADMIN',
      },
    });

    if (!member) {
      throw new ForbiddenException('Только администраторы могут удалять задачи');
    }

    await this.prisma.task.delete({
      where: { id: taskId },
    });

    return true;
  }

  /**
   * Отметить задачу как выполненную
   */
  async completeTask(userId: string, input: CompleteTaskInput) {
    const { taskId } = input;
    const task = await this.getTask(taskId, userId);

    // Проверяем, что пользователь - исполнитель задачи
    if (task.assigneeId !== userId) {
      throw new ForbiddenException('Только исполнитель может завершить задачу');
    }

    if (task.status === 'COMPLETED') {
      throw new BadRequestException('Задача уже выполнена');
    }

    const newStatus = task.requiresApproval ? 'AWAITING_APPROVAL' : 'COMPLETED';

    const updatedTask = await this.prisma.task.update({
      where: { id: taskId },
      data: {
        status: newStatus,
        ...(newStatus === 'COMPLETED' && { completedAt: new Date() }),
      },
      include: {
        assignee: true,
        createdBy: true,
      },
    });

    await this.auditLogService.createLog({
      action: AuditAction.TASK_COMPLETED,
      entityType: 'Task',
      entityId: taskId,
      userId,
      newValues: {
        title: task.title,
        groupId: task.groupId,
        status: newStatus,
        requiresApproval: task.requiresApproval,
      },
    });

    // Если не требуется одобрение, создаем запись в истории
    if (!task.requiresApproval) {
      const wasOnTime = new Date() <= task.deadline;
      const wasClaimed = (task as any).wasClaimedFromPool === true;
      const pointsAwarded = this.calculatePoints(
        task.points,
        wasOnTime,
        wasClaimed,
        false,
      );

      await this.prisma.taskCompletionHistory.create({
        data: {
          taskId,
          userId,
          pointsAwarded,
          completedAt: new Date(),
          wasOnTime,
        },
      });

      // Invalidate user statistics cache after task completion (PRD 4.1)
      await this.cacheManager.del(`user:stats:${userId}`);
      await this.cacheManager.del(`user:stats:${userId}:group:${task.groupId}`);

      // Create point ledger entry (Phase 6 - PRD 3.5.1)
      if ((this.prisma as any).pointTransaction) {
        await (this.prisma as any).pointTransaction.create({
        data: {
          type: 'EARNED',
          amount: pointsAwarded,
          userId,
          groupId: task.groupId,
          taskId: task.id,
          description: `Task completed${wasClaimed ? ' (Up-for-Grabs bonus)' : ''}`,
        },
        });

        await this.auditLogService.logPointTransaction(
          'EARNED',
          pointsAwarded,
          userId,
          task.groupId,
          task.id,
          `Task completed${wasClaimed ? ' (Up-for-Grabs bonus)' : ''}`,
        );

        // Notify user about points awarded (Phase 8 - distinct from TASK_APPROVED)
        await this.notificationService.notify({
          userId,
          title: NotificationMessages.pointsAwardedTitle(),
          message: NotificationMessages.pointsEarnedCompletion(
            pointsAwarded,
            task.title,
            wasClaimed,
          ),
          type: 'POINT_AWARDED' as any,
          relatedEntityType: 'Task',
          relatedEntityId: task.id,
        });
      }
    }

    // If requires approval, notify group admins that task is awaiting review
    if (task.requiresApproval && updatedTask.status === 'AWAITING_APPROVAL') {
      await this.notificationService.notifyGroupAdmins(task.groupId, (adminId) => ({
        title: NotificationMessages.taskPendingReviewTitle(),
        message: NotificationMessages.taskAwaitingApproval(task.title),
        type: NotificationTypeEnum.TASK_COMPLETED,
        relatedEntityType: 'Task',
        relatedEntityId: task.id,
        sentById: userId,
      }));
    }

    return updatedTask;
  }

  /**
   * Одобрить/отклонить задачу (только админы)
   */
  async approveTask(userId: string, input: ApproveTaskInput) {
    const { taskId, approved, rejectionReason } = input;
    const task = await this.getTask(taskId, userId);

    // Проверяем права администратора
    const member = await this.prisma.groupMember.findFirst({
      where: {
        groupId: task.groupId,
        userId,
        role: 'ADMIN',
      },
    });

    if (!member) {
      throw new ForbiddenException('Только администраторы могут одобрять задачи');
    }

    if (task.status !== 'AWAITING_APPROVAL') {
      throw new BadRequestException('Задача не ожидает одобрения');
    }

    // PRD 3.6.2: При отклонении требуется причина
    if (!approved && !rejectionReason) {
      throw new BadRequestException('При отклонении задачи необходимо указать причину');
    }

    const newStatus = approved ? 'COMPLETED' : 'PENDING';

    const updatedTask = await this.prisma.task.update({
      where: { id: taskId },
      data: {
        status: newStatus,
        approvedById: approved ? userId : null,
        rejectionReason: approved ? null : rejectionReason,
        ...(approved && { completedAt: new Date() }),
      } as any,
      include: {
        assignee: true,
        createdBy: true,
      },
    });

    // Если одобрено, создаем запись в истории и начисляем очки
    if (approved && task.assigneeId) {
      const wasOnTime = new Date() <= task.deadline;
      const wasClaimed = (task as any).wasClaimedFromPool === true;
      const pointsAwarded = this.calculatePoints(
        task.points,
        wasOnTime,
        wasClaimed,
        false,
      );

      await this.prisma.taskCompletionHistory.create({
        data: {
          taskId,
          userId: task.assigneeId,
          approvedById: userId,
          pointsAwarded,
          completedAt: new Date(),
          approvedAt: new Date(),
          wasOnTime,
        },
      });

      // Point ledger entry for approved task completion (PRD 3.5.1)
      if ((this.prisma as any).pointTransaction) {
        await (this.prisma as any).pointTransaction.create({
        data: {
          type: 'EARNED',
          amount: pointsAwarded,
          userId: task.assigneeId,
          groupId: task.groupId,
          taskId: task.id,
          description: `Task approved${wasClaimed ? ' (Up-for-Grabs bonus)' : ''}`,
        },
        });

        // Audit log for point transaction (PRD 3.6.4)
        await this.auditLogService.logPointTransaction(
          'EARNED',
          pointsAwarded,
          task.assigneeId,
          task.groupId,
          taskId,
          `Task approved${wasClaimed ? ' (Up-for-Grabs bonus)' : ''}`,
        );

        // Notify user about points awarded (Phase 8 - distinct from TASK_APPROVED)
        await this.notificationService.notify({
          userId: task.assigneeId,
          title: NotificationMessages.pointsAwardedTitle(),
          message: NotificationMessages.pointsEarnedApproval(
            pointsAwarded,
            task.title,
            wasClaimed,
          ),
          type: 'POINT_AWARDED' as any,
          relatedEntityType: 'Task',
          relatedEntityId: task.id,
        });
      }
    }

    // Audit log for task approval/rejection (PRD 3.6.4)
    await this.auditLogService.logTaskApproval(
      taskId,
      approved,
      rejectionReason,
      userId,
      task.groupId,
      task.title,
    );

    // Phase 8: Notifications to assignee on approval/rejection
    if (task.assigneeId) {
      if (approved) {
        await this.notificationService.notify({
          userId: task.assigneeId,
          title: NotificationMessages.taskApprovedTitle(),
          message: NotificationMessages.taskApproved(task.title),
          type: NotificationTypeEnum.TASK_APPROVED,
          relatedEntityType: 'Task',
          relatedEntityId: task.id,
          sentById: userId,
        });

        // Invalidate user statistics cache after task approval (PRD 4.1)
        await this.cacheManager.del(`user:stats:${task.assigneeId}`);
        await this.cacheManager.del(`user:stats:${task.assigneeId}:group:${task.groupId}`);
      } else {
        await this.notificationService.notify({
          userId: task.assigneeId,
          title: NotificationMessages.taskRejectedTitle(),
          message: NotificationMessages.taskRejected(
            task.title,
            rejectionReason ?? NotificationMessages.noReason(),
          ),
          type: NotificationTypeEnum.TASK_REJECTED,
          relatedEntityType: 'Task',
          relatedEntityId: task.id,
          sentById: userId,
        });
      }
    }

    return updatedTask;
  }

  /**
   * Взять задачу из Up-for-Grabs пула (PRD 3.4.2)
   * Участник может взять задачу без исполнителя
   * Получает бонусные очки (+50% = 1.5x multiplier)
   */
  async claimTask(userId: string, taskId: string) {
    const task = await this.getTask(taskId, userId);

    // Проверяем, что у задачи нет исполнителя
    if (task.assigneeId !== null) {
      throw new BadRequestException(
        'Эта задача уже назначена исполнителю. Только задачи без исполнителя можно взять из Up-for-Grabs пула',
      );
    }

    // Проверяем, что пользователь - член группы
    const member = await this.prisma.groupMember.findFirst({
      where: {
        groupId: task.groupId,
        userId,
      },
    });

    if (!member) {
      throw new ForbiddenException('Вы не являетесь членом этой группы');
    }

    // Назначаем задачу пользователю
    const updatedTask = await this.prisma.task.update({
      where: { id: taskId },
      data: ({
        assigneeId: userId,
        status: 'PENDING', // Переводим в статус PENDING (назначена)
        wasClaimedFromPool: true, // Отмечаем, что задача взята из Up-for-Grabs
      } as any),
      include: {
        assignee: true,
        createdBy: true,
        group: true,
      },
    });

    // Notify claimer about assignment confirmation
    await this.notificationService.notify({
      userId,
      title: NotificationMessages.taskClaimedTitle(),
      message: NotificationMessages.taskClaimed(updatedTask.title),
      type: NotificationTypeEnum.TASK_ASSIGNED,
      relatedEntityType: 'Task',
      relatedEntityId: updatedTask.id,
      sentById: userId,
    });

    return updatedTask;
  }

  /**
   * Рассчитать очки с учетом мультипликаторов (PRD 3.5.1-3.5.2)
   * - On-time completion: 1.0x
   * - Late completion: 0.5x
   * - Up-for-Grabs: 1.5x
   * - Rejected/Overdue: 0.0x
   */
  calculatePoints(
    basePoints: number,
    wasOnTime: boolean,
    wasUpForGrabs: boolean = false,
    wasRejected: boolean = false,
  ): number {
    if (wasRejected) {
      return 0; // Rejected or overdue = 0 points
    }

    let multiplier = 1.0;

    if (wasUpForGrabs) {
      multiplier = 1.5; // Up-for-Grabs bonus
    } else if (!wasOnTime) {
      multiplier = 0.5; // Late completion penalty
    }

    return Math.round(basePoints * multiplier);
  }

  /**
   * Get rotation schedule for a group (next 30 days of planned assignments)
   * Implements BACKEND_API_REQUIREMENTS.md - getRotationSchedule query (Critical - Phase 5.1)
   * 
   * @param groupId - Group ID
   * @param userId - User ID (for permission check)
   * @returns Array of planned rotation assignments
   */
  async getRotationSchedule(
    groupId: string,
    userId: string,
  ): Promise<any[]> {
    // Check user is member of group
    const member = await this.prisma.groupMember.findFirst({
      where: { groupId, userId },
    });

    if (!member) {
      throw new ForbiddenException('Access denied: not a group member');
    }

    // Get all recurring tasks for the group
    const recurringTasks = await this.prisma.task.findMany({
      where: {
        groupId,
        isRecurring: true,
        rotationType: { not: null },
      },
      include: {
        assignee: {
          select: {
            id: true,
            username: true,
            avatarUrl: true,
          },
        },
      },
    });

    // TODO: Implement recurrence rule parsing (RFC 5545 RRULE)
    // For MVP, return empty array (recurring task scheduler pending Phase 9)
    // Full implementation requires:
    // 1. Parse recurrenceRule (rrule library)
    // 2. Generate next N occurrences (30 days window)
    // 3. Apply rotation algorithm for each occurrence
    // 4. Return sorted schedule entries
    
    return [];
  }

  /**
   * Get rotation history for a group (past assignments through rotation)
   * Implements BACKEND_API_REQUIREMENTS.md - getRotationHistory query (Critical - Phase 5.1)
   * 
   * @param groupId - Group ID
   * @param userId - User ID (for permission check)
   * @param limit - Max number of results
   * @param offset - Pagination offset
   * @returns Paginated rotation history
   */
  async getRotationHistory(
    groupId: string,
    userId: string,
    limit: number = 50,
    offset: number = 0,
  ): Promise<{ items: any[]; total: number }> {
    // Check user is member of group
    const member = await this.prisma.groupMember.findFirst({
      where: { groupId, userId },
    });

    if (!member) {
      throw new ForbiddenException('Access denied: not a group member');
    }

    // Get tasks assigned through rotation (not manual assignment)
    // Criteria: tasks with rotationType !== null and assignee !== createdBy
    const tasks = await this.prisma.task.findMany({
      where: {
        groupId,
        rotationType: { not: null },
        assigneeId: { not: null },
      },
      include: {
        assignee: {
          select: {
            id: true,
            username: true,
            avatarUrl: true,
          },
        },
        completions: {
          select: {
            pointsAwarded: true,
          },
          take: 1,
          orderBy: {
            completedAt: 'desc',
          },
        },
      },
      orderBy: {
        createdAt: 'desc',
      },
      take: limit,
      skip: offset,
    });

    // Count total
    const total = await this.prisma.task.count({
      where: {
        groupId,
        rotationType: { not: null },
        assigneeId: { not: null },
      },
    });

    // Map to RotationHistoryEntry format
    const items = tasks.map((task) => ({
      taskId: task.id,
      taskTitle: task.title,
      userId: task.assignee!.id,
      username: task.assignee!.username,
      avatarUrl: task.assignee!.avatarUrl,
      assignedAt: task.createdAt,
      completedAt: task.completedAt,
      status: task.status,
      rotationType: task.rotationType!,
      pointsEarned: task.completions[0]?.pointsAwarded || 0,
    }));

    return { items, total };
  }

  /**
   * Get rotation pattern information for a group
   * Implements BACKEND_API_REQUIREMENTS.md - getRotationPattern query (Important - Phase 5.1)
   * 
   * @param groupId - Group ID
   * @param userId - User ID (for permission check)
   * @returns Rotation pattern configuration and state
   */
  async getRotationPattern(
    groupId: string,
    userId: string,
  ): Promise<any> {
    // Check user is member of group
    const member = await this.prisma.groupMember.findFirst({
      where: { groupId, userId },
    });

    if (!member) {
      throw new ForbiddenException('Access denied: not a group member');
    }

    // Get group rotation type
    const group = await this.prisma.group.findUnique({
      where: { id: groupId },
      select: { rotationType: true },
    });

    if (!group) {
      throw new NotFoundException('Group not found');
    }

    // Get all group members
    const members = await this.prisma.groupMember.findMany({
      where: { groupId },
      include: {
        user: {
          select: {
            id: true,
            username: true,
            avatarUrl: true,
            isAway: true,
            awayUntil: true,
          },
        },
      },
      orderBy: {
        joinedAt: 'asc', // CYCLIC rotation order
      },
    });

    // Separate active and away members
    const now = new Date();
    const activeMembers = members
      .filter((m) => !m.user.isAway || (m.user.awayUntil && new Date(m.user.awayUntil) <= now))
      .map((m) => ({
        id: m.user.id,
        username: m.user.username,
        avatarUrl: m.user.avatarUrl,
        isAway: false,
        awayUntil: null,
      }));

    const awayMembers = members
      .filter((m) => m.user.isAway && (!m.user.awayUntil || new Date(m.user.awayUntil) > now))
      .map((m) => ({
        id: m.user.id,
        username: m.user.username,
        avatarUrl: m.user.avatarUrl,
        isAway: true,
        awayUntil: m.user.awayUntil,
      }));

    // Get last rotation assignment
    const lastTask = await this.prisma.task.findFirst({
      where: {
        groupId,
        rotationType: { not: null },
      },
      orderBy: {
        createdAt: 'desc',
      },
    });

    // Calculate current cycle index (for CYCLIC)
    let currentCycleIndex: number | null = null;
    if (group.rotationType === 'ROUND_ROBIN' && lastTask && lastTask.assigneeId) {
      const lastAssigneeIndex = activeMembers.findIndex(
        (m) => m.id === lastTask.assigneeId,
      );
      if (lastAssigneeIndex !== -1) {
        currentCycleIndex = (lastAssigneeIndex + 1) % activeMembers.length;
      }
    }

    return {
      rotationType: group.rotationType,
      currentCycle: activeMembers.map((m) => m.id),
      currentCycleIndex: currentCycleIndex,
      lastRotationAt: lastTask?.createdAt || null,
      nextRotationAt: null,
      activeMembers: activeMembers,
      awayMembers: awayMembers,
    };
  }

  /**
   * Добавить вложение к задаче (файл уже загружен через /upload/task-attachment)
   */
  async addTaskAttachment(userId: string, input: AddTaskAttachmentInput) {
    const task = await this.getTask(input.taskId, userId);

    return this.prisma.taskAttachment.create({
      data: {
        url: input.url,
        filename: input.filename,
        fileSize: input.fileSize,
        mimeType: input.mimeType,
        taskId: input.taskId,
        groupId: task.groupId,
        uploadedById: userId,
      },
    });
  }

  /**
   * Удалить вложение задачи (удаляет и файл в MinIO)
   */
  async deleteTaskAttachment(userId: string, attachmentId: string) {
    const attachment = await this.prisma.taskAttachment.findUnique({
      where: { id: attachmentId },
      include: {
        task: {
          include: {
            group: { include: { members: true } },
          },
        },
      },
    });

    if (!attachment) {
      throw new NotFoundException('Вложение не найдено');
    }

    const isMember = attachment.task.group.members.some(
      (m) => m.userId === userId,
    );
    if (!isMember) {
      throw new ForbiddenException('У вас нет доступа к этому вложению');
    }

    const isAdmin = attachment.task.group.members.some(
      (m) => m.userId === userId && m.role === 'ADMIN',
    );
    const isUploader = attachment.uploadedById === userId;

    if (!isAdmin && !isUploader) {
      throw new ForbiddenException(
        'Удалить вложение может только его автор или администратор',
      );
    }

    await this.storageService.deleteFileByUrl(attachment.url);
    await this.prisma.taskAttachment.delete({ where: { id: attachmentId } });

    return true;
  }
}

