import { Injectable, Logger } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';

export enum AuditAction {
  // User actions
  USER_STATUS_CHANGED = 'USER_STATUS_CHANGED',
  USER_PROFILE_UPDATED = 'USER_PROFILE_UPDATED',

  // Group actions
  GROUP_CREATED = 'GROUP_CREATED',
  GROUP_UPDATED = 'GROUP_UPDATED',
  GROUP_DELETED = 'GROUP_DELETED',
  MEMBER_ADDED = 'MEMBER_ADDED',
  MEMBER_REMOVED = 'MEMBER_REMOVED',
  MEMBER_ROLE_CHANGED = 'MEMBER_ROLE_CHANGED',

  // Task actions
  TASK_CREATED = 'TASK_CREATED',
  TASK_UPDATED = 'TASK_UPDATED',
  TASK_DELETED = 'TASK_DELETED',
  TASK_ASSIGNED = 'TASK_ASSIGNED',
  TASK_COMPLETED = 'TASK_COMPLETED',
  TASK_APPROVED = 'TASK_APPROVED',
  TASK_REJECTED = 'TASK_REJECTED',
  TASK_OVERDUE = 'TASK_OVERDUE',

  // Reward actions
  REWARD_CREATED = 'REWARD_CREATED',
  REWARD_UPDATED = 'REWARD_UPDATED',
  REWARD_DELETED = 'REWARD_DELETED',
  REWARD_REQUESTED = 'REWARD_REQUESTED',
  REWARD_REQUEST_APPROVED = 'REWARD_REQUEST_APPROVED',
  REWARD_REQUEST_REJECTED = 'REWARD_REQUEST_REJECTED',

  // Point transactions (PRD 3.6.4)
  POINTS_EARNED = 'POINTS_EARNED',
  POINTS_RESERVED = 'POINTS_RESERVED',
  POINTS_SPENT = 'POINTS_SPENT',
  POINTS_REFUNDED = 'POINTS_REFUNDED',
}

export interface AuditLogData {
  action: AuditAction | string;
  entityType: string;
  entityId?: string;
  oldValues?: any;
  newValues?: any;
  userId?: string;
  ipAddress?: string;
}

/**
 * Audit Logging Service (PRD 3.6.4)
 * Maintains complete audit logs for all critical actions:
 * - Role changes
 * - Task approvals/rejections
 * - Point transactions
 * - User status changes
 */
@Injectable()
export class AuditLogService {
  private readonly logger = new Logger(AuditLogService.name);

  constructor(private prisma: PrismaService) {}

  /**
   * Создать запись в аудит-логе
   */
  async createLog(data: AuditLogData) {
    try {
      const log = await this.prisma.auditLog.create({
        data: {
          action: data.action,
          entityType: data.entityType,
          entityId: data.entityId,
          oldValues: data.oldValues ? JSON.parse(JSON.stringify(data.oldValues)) : null,
          newValues: data.newValues ? JSON.parse(JSON.stringify(data.newValues)) : null,
          userId: data.userId,
          ipAddress: data.ipAddress,
        },
      });

      this.logger.log(
        `Audit log created: ${data.action} on ${data.entityType}${data.entityId ? ` (${data.entityId})` : ''} by user ${data.userId || 'SYSTEM'}`,
      );

      return log;
    } catch (error) {
      this.logger.error(`Failed to create audit log: ${error.message}`, error.stack);
      // Не бросаем ошибку, чтобы не ломать основной процесс
      return null;
    }
  }

  /**
   * Получить логи по типу сущности и ID
   */
  async getLogsByEntity(entityType: string, entityId: string) {
    return this.prisma.auditLog.findMany({
      where: {
        entityType,
        entityId,
      },
      include: {
        user: {
          select: {
            id: true,
            username: true,
            email: true,
          },
        },
      },
      orderBy: {
        performedAt: 'desc',
      },
    });
  }

  /**
   * Получить логи пользователя
   */
  async getLogsByUser(userId: string, limit: number = 100) {
    return this.prisma.auditLog.findMany({
      where: {
        userId,
      },
      include: {
        user: {
          select: {
            id: true,
            username: true,
            email: true,
          },
        },
      },
      orderBy: {
        performedAt: 'desc',
      },
      take: limit,
    });
  }

  /**
   * Получить все логи с фильтрацией и пагинацией
   */
  async getAllLogs(filters?: {
    entityType?: string;
    action?: string;
    userId?: string;
    startDate?: Date;
    endDate?: Date;
    limit?: number;
    offset?: number;
  }) {
    const where: any = {};

    if (filters?.entityType) {
      where.entityType = filters.entityType;
    }

    if (filters?.action) {
      where.action = filters.action;
    }

    if (filters?.userId) {
      where.userId = filters.userId;
    }

    if (filters?.startDate || filters?.endDate) {
      where.performedAt = {};
      if (filters.startDate) {
        where.performedAt.gte = filters.startDate;
      }
      if (filters.endDate) {
        where.performedAt.lte = filters.endDate;
      }
    }

    const [logs, total] = await Promise.all([
      this.prisma.auditLog.findMany({
        where,
        include: {
          user: {
            select: {
              id: true,
              username: true,
              email: true,
            },
          },
        },
        orderBy: {
          performedAt: 'desc',
        },
        take: filters?.limit || 50,
        skip: filters?.offset || 0,
      }),
      this.prisma.auditLog.count({ where }),
    ]);

    return {
      logs,
      total,
      limit: filters?.limit || 50,
      offset: filters?.offset || 0,
    };
  }

  /**
   * Логирование изменения роли участника группы (PRD 3.6.4)
   */
  async logRoleChange(
    groupId: string,
    userId: string,
    oldRole: string,
    newRole: string,
    performedBy: string,
  ) {
    return this.createLog({
      action: AuditAction.MEMBER_ROLE_CHANGED,
      entityType: 'GroupMember',
      entityId: `${groupId}-${userId}`,
      oldValues: { role: oldRole },
      newValues: { role: newRole },
      userId: performedBy,
    });
  }

  /**
   * Логирование одобрения/отклонения задачи (PRD 3.6.4)
   */
  async logTaskApproval(
    taskId: string,
    approved: boolean,
    reason: string | undefined,
    userId: string,
  ) {
    return this.createLog({
      action: approved ? AuditAction.TASK_APPROVED : AuditAction.TASK_REJECTED,
      entityType: 'Task',
      entityId: taskId,
      newValues: {
        approved,
        ...(reason && { rejectionReason: reason }),
      },
      userId,
    });
  }

  /**
   * Логирование транзакции очков (PRD 3.6.4)
   */
  async logPointTransaction(
    type: 'EARNED' | 'RESERVED' | 'SPENT' | 'REFUNDED',
    amount: number,
    userId: string,
    groupId: string,
    entityId?: string,
    description?: string,
  ) {
    const actionMap = {
      EARNED: AuditAction.POINTS_EARNED,
      RESERVED: AuditAction.POINTS_RESERVED,
      SPENT: AuditAction.POINTS_SPENT,
      REFUNDED: AuditAction.POINTS_REFUNDED,
    };

    return this.createLog({
      action: actionMap[type],
      entityType: 'PointTransaction',
      entityId,
      newValues: {
        type,
        amount,
        groupId,
        description,
      },
      userId,
    });
  }

  /**
   * Логирование изменения статуса пользователя (PRD 3.6.4)
   */
  async logUserStatusChange(
    userId: string,
    oldStatus: { isAway: boolean; awayUntil?: Date | null },
    newStatus: { isAway: boolean; awayUntil?: Date | null },
    performedBy: string,
  ) {
    return this.createLog({
      action: AuditAction.USER_STATUS_CHANGED,
      entityType: 'User',
      entityId: userId,
      oldValues: oldStatus,
      newValues: newStatus,
      userId: performedBy,
    });
  }
}
