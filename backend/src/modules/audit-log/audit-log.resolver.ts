import { Resolver, Query, Args, ResolveField, Parent } from '@nestjs/graphql';
import { UseGuards } from '@nestjs/common';
import { AuditLogService } from './audit-log.service';
import { AuditLogType, AuditLogListType, AuditLogUserType } from './types/audit-log.type';
import { GetAuditLogsInput } from './dto/audit-log.input';
import { JwtAuthGuard } from '../auth/auth.guard';
import { CurrentUser } from '../auth/decorators/current-user.decorator';
import type { User } from '@prisma/client';

/**
 * AuditLog Resolver
 * Provides queries for audit log access (PRD 3.6.4)
 */
@Resolver(() => AuditLogType)
export class AuditLogResolver {
  constructor(private auditLogService: AuditLogService) {}

  /**
   * Resolve performedBy as alias for user
   */
  @ResolveField(() => AuditLogUserType, { nullable: true })
  performedBy(@Parent() auditLog: any) {
    return auditLog.user;
  }

  /**
   * Получить логи с фильтрацией и пагинацией
   * TODO: Add admin-only guard (currently all authenticated users can access)
   */
  @Query(() => AuditLogListType, {
    description: 'Get audit logs with filtering and pagination (admin only)',
  })
  @UseGuards(JwtAuthGuard)
  async getAuditLogs(
    @CurrentUser() user: User,
    @Args('input', { nullable: true }) input?: GetAuditLogsInput,
  ) {
    const filters = input
      ? {
          entityType: input.entityType,
          action: input.action,
          userId: input.userId,
          startDate: input.startDate ? new Date(input.startDate) : undefined,
          endDate: input.endDate ? new Date(input.endDate) : undefined,
          limit: input.limit,
          offset: input.offset,
        }
      : undefined;

    return this.auditLogService.getAllLogs(filters);
  }

  /**
   * Получить логи для конкретной задачи
   */
  @Query(() => [AuditLogType], {
    description: 'Get audit logs for a specific task',
  })
  @UseGuards(JwtAuthGuard)
  async getTaskAuditLog(
    @CurrentUser() user: User,
    @Args('taskId') taskId: string,
  ) {
    return this.auditLogService.getLogsByTask(taskId);
  }

  /**
   * Получить логи для конкретной группы
   */
  @Query(() => [AuditLogType], {
    description: 'Get audit logs for a specific group',
  })
  @UseGuards(JwtAuthGuard)
  async getGroupAuditLog(
    @CurrentUser() user: User,
    @Args('groupId') groupId: string,
  ) {
    return this.auditLogService.getLogsByGroup(groupId);
  }

  /**
   * Получить мои логи (действия текущего пользователя)
   */
  @Query(() => [AuditLogType], {
    description: 'Get audit logs for current user actions',
  })
  @UseGuards(JwtAuthGuard)
  async getMyAuditLogs(
    @CurrentUser() user: User,
    @Args('limit', { type: () => Number, nullable: true, defaultValue: 100 })
    limit?: number,
  ) {
    return this.auditLogService.getLogsByUser(user.id, limit);
  }
}
