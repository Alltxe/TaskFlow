import {
  Injectable,
  NotFoundException,
  ForbiddenException,
  BadRequestException,
} from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import {
  CreateTaskInput,
  UpdateTaskInput,
  CompleteTaskInput,
  ApproveTaskInput,
  ClaimTaskInput,
} from './dto/task.input';
import { RotationService } from './rotation.service';
import { AuditLogService } from '../audit-log/audit-log.service';

@Injectable()
export class TaskService {
  constructor(
    private prisma: PrismaService,
    private rotationService: RotationService,
    private auditLogService: AuditLogService,
  ) {}

  /**
   * Создать задачу (только админы группы)
   */
  async createTask(userId: string, input: CreateTaskInput) {
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
    if (!finalAssigneeId) {
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
        deadline: new Date(deadline),
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
   * Обновить задачу (только админы или создатель)
   */
  async updateTask(taskId: string, userId: string, input: UpdateTaskInput) {
    const task = await this.getTask(taskId, userId);

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
      }
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
      }
    }

    // Audit log for task approval/rejection (PRD 3.6.4)
    await this.auditLogService.logTaskApproval(
      taskId,
      approved,
      rejectionReason,
      userId,
    );

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
}
