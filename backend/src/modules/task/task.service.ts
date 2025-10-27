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
} from './dto/task.input';

@Injectable()
export class TaskService {
  constructor(private prisma: PrismaService) {}

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
    let finalAssigneeId: string | null | undefined = assigneeId;
    if (!finalAssigneeId) {
      const group = await this.prisma.group.findUnique({
        where: { id: groupId },
        include: {
          members: true,
        },
      });

      if (group) {
        const effectiveRotationType = rotationType || group.rotationType;
        finalAssigneeId = await this.selectAssignee(
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
        rotationType,
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

  /**
   * Выбрать исполнителя по алгоритму ротации
   */
  private async selectAssignee(
    groupId: string,
    rotationType: string,
    weight: number,
  ): Promise<string | null> {
    const members = await this.prisma.groupMember.findMany({
      where: {
        groupId,
        user: {
          isAway: false,
        },
      },
      include: {
        user: true,
      },
    });

    if (members.length === 0) return null;

    switch (rotationType) {
      case 'ROUND_ROBIN':
        return this.roundRobinSelection(groupId, members);

      case 'RANDOM':
        return this.randomSelection(members);

      case 'WEIGHTED_RANDOM':
        return this.weightedRandomSelection(groupId, members, weight);

      case 'DISABLED':
        return null;

      default:
        return this.roundRobinSelection(groupId, members);
    }
  }

  /**
   * Round Robin - выбор следующего по очереди
   */
  private async roundRobinSelection(
    groupId: string,
    members: any[],
  ): Promise<string> {
    // Получаем последнюю назначенную задачу в группе
    const lastTask = await this.prisma.task.findFirst({
      where: { groupId, assigneeId: { not: null } },
      orderBy: { createdAt: 'desc' },
    });

    if (!lastTask || !lastTask.assigneeId) {
      return members[0].userId;
    }

    // Находим индекс последнего исполнителя
    const lastIndex = members.findIndex((m) => m.userId === lastTask.assigneeId);
    const nextIndex = (lastIndex + 1) % members.length;
    return members[nextIndex].userId;
  }

  /**
   * Random - случайный выбор
   */
  private randomSelection(members: any[]): string {
    const randomIndex = Math.floor(Math.random() * members.length);
    return members[randomIndex].userId;
  }

  /**
   * Weighted Random - взвешенный случайный выбор (меньше задач = больше шанс)
   */
  private async weightedRandomSelection(
    groupId: string,
    members: any[],
    taskWeight: number,
  ): Promise<string> {
    // Подсчитываем активные задачи для каждого участника
    const memberWeights = await Promise.all(
      members.map(async (member) => {
        const activeTasks = await this.prisma.task.count({
          where: {
            groupId,
            assigneeId: member.userId,
            status: {
              in: ['PENDING', 'IN_PROGRESS'],
            },
          },
        });

        // Чем меньше задач, тем больше вес
        const weight = Math.max(1, 10 - activeTasks);
        return { userId: member.userId, weight };
      }),
    );

    // Взвешенный случайный выбор
    const totalWeight = memberWeights.reduce((sum, m) => sum + m.weight, 0);
    let random = Math.random() * totalWeight;

    for (const member of memberWeights) {
      random -= member.weight;
      if (random <= 0) {
        return member.userId;
      }
    }

    return memberWeights[0].userId;
  }

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
      await this.prisma.taskCompletionHistory.create({
        data: {
          taskId,
          userId,
          pointsAwarded: task.points,
          completedAt: new Date(),
          wasOnTime: new Date() <= task.deadline,
        },
      });
    }

    return updatedTask;
  }

  /**
   * Одобрить/отклонить задачу (только админы)
   */
  async approveTask(userId: string, input: ApproveTaskInput) {
    const { taskId, approved } = input;
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

    const newStatus = approved ? 'COMPLETED' : 'PENDING';

    const updatedTask = await this.prisma.task.update({
      where: { id: taskId },
      data: {
        status: newStatus,
        approvedById: approved ? userId : null,
        ...(approved && { completedAt: new Date() }),
      },
      include: {
        assignee: true,
        createdBy: true,
      },
    });

    // Если одобрено, создаем запись в истории и начисляем очки
    if (approved && task.assigneeId) {
      await this.prisma.taskCompletionHistory.create({
        data: {
          taskId,
          userId: task.assigneeId,
          approvedById: userId,
          pointsAwarded: task.points,
          completedAt: new Date(),
          approvedAt: new Date(),
          wasOnTime: new Date() <= task.deadline,
        },
      });
    }

    return updatedTask;
  }
}
