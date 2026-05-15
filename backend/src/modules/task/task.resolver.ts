import { Resolver, Query, Mutation, Args, Int } from '@nestjs/graphql';
import { UseGuards } from '@nestjs/common';
import { TaskService } from './task.service';
import { RecurringTaskService } from './recurring-task.service';
import { TaskType } from './types/task.type';
import { RotationScheduleEntry } from './types/rotation-schedule.type';
import { RotationHistoryResult } from './types/rotation-history.type';
import { RotationPatternType } from './types/rotation-pattern.type';
import {
  CreateTaskInput,
  UpdateTaskInput,
  CompleteTaskInput,
  ApproveTaskInput,
  ClaimTaskInput,
  AddTaskAttachmentInput,
} from './dto/task.input';
import { TaskAttachmentType } from './types/task-attachment.type';
import { JwtAuthGuard } from '../auth/auth.guard';
import { CurrentUser } from '../auth/decorators/current-user.decorator';
import type { User } from '@prisma/client';

@Resolver()
export class TaskResolver {
  constructor(
    private taskService: TaskService,
    private recurringTaskService: RecurringTaskService,
  ) {}

  /**
   * Создать задачу (только админы группы)
   */
  @Mutation(() => TaskType)
  @UseGuards(JwtAuthGuard)
  async createTask(
    @CurrentUser() user: User,
    @Args('input') input: CreateTaskInput,
  ) {
    console.log('[TaskResolver.createTask] Received input:', JSON.stringify(input, null, 2));
    console.log('[TaskResolver.createTask] User:', user.id, user.username);
    return this.taskService.createTask(user.id, input);
  }

  /**
   * Получить задачу по ID
   */
  @Query(() => TaskType)
  @UseGuards(JwtAuthGuard)
  async getTask(@Args('taskId') taskId: string, @CurrentUser() user: User) {
    return this.taskService.getTask(taskId, user.id);
  }

  /**
   * Получить задачи группы
   */
  @Query(() => [TaskType])
  @UseGuards(JwtAuthGuard)
  async getGroupTasks(
    @Args('groupId') groupId: string,
    @Args('status', { nullable: true }) status: string,
    @CurrentUser() user: User,
  ) {
    return this.taskService.getGroupTasks(groupId, user.id, status);
  }

  /**
   * Получить шаблоны повторяющихся задач группы
   */
  @Query(() => [TaskType])
  @UseGuards(JwtAuthGuard)
  async getRecurringTemplates(
    @Args('groupId') groupId: string,
    @CurrentUser() user: User,
  ) {
    return this.taskService.getRecurringTemplates(groupId, user.id);
  }

  /**
   * Получить задачи пользователя
   */
  @Query(() => [TaskType])
  @UseGuards(JwtAuthGuard)
  async getUserTasks(
    @Args('status', { nullable: true }) status: string,
    @CurrentUser() user: User,
  ) {
    return this.taskService.getUserTasks(user.id, status);
  }

  /**
   * Обновить задачу
   */
  @Mutation(() => TaskType)
  @UseGuards(JwtAuthGuard)
  async updateTask(
    @Args('taskId') taskId: string,
    @Args('input') input: UpdateTaskInput,
    @CurrentUser() user: User,
  ) {
    return this.taskService.updateTask(taskId, user.id, input);
  }

  /**
   * Удалить задачу (только админы)
   */
  @Mutation(() => Boolean)
  @UseGuards(JwtAuthGuard)
  async deleteTask(@Args('taskId') taskId: string, @CurrentUser() user: User) {
    return this.taskService.deleteTask(taskId, user.id);
  }

  /**
   * Отметить задачу как выполненную
   */
  @Mutation(() => TaskType)
  @UseGuards(JwtAuthGuard)
  async completeTask(
    @Args('input') input: CompleteTaskInput,
    @CurrentUser() user: User,
  ) {
    return this.taskService.completeTask(user.id, input);
  }

  /**
   * Одобрить/отклонить задачу (только админы)
   */
  @Mutation(() => TaskType)
  @UseGuards(JwtAuthGuard)
  async approveTask(
    @Args('input') input: ApproveTaskInput,
    @CurrentUser() user: User,
  ) {
    return this.taskService.approveTask(user.id, input);
  }

  /**
   * Взять задачу из Up-for-Grabs пула (PRD 3.4.2)
   */
  @Mutation(() => TaskType, {
    description:
      'Claim an unassigned task from the Up-for-Grabs pool. User receives bonus points (1.5x multiplier).',
  })
  @UseGuards(JwtAuthGuard)
  async claimTask(
    @Args('input') input: ClaimTaskInput,
    @CurrentUser() user: User,
  ) {
    return this.taskService.claimTask(user.id, input.taskId);
  }

  /**
   * Get rotation schedule for upcoming task assignments
   * Implements BACKEND_API_REQUIREMENTS.md - getRotationSchedule query (Critical - Phase 5.1)
   */
  @Query(() => [RotationScheduleEntry], {
    description:
      'Get planned rotation schedule for next 30 days (requires recurring task scheduler - Phase 9)',
  })
  @UseGuards(JwtAuthGuard)
  async getRotationSchedule(
    @Args('groupId') groupId: string,
    @CurrentUser() user: User,
  ): Promise<RotationScheduleEntry[]> {
    return this.taskService.getRotationSchedule(groupId, user.id);
  }

  /**
   * Get rotation history for past task assignments
   * Implements BACKEND_API_REQUIREMENTS.md - getRotationHistory query (Critical - Phase 5.1)
   */
  @Query(() => RotationHistoryResult, {
    description: 'Get history of tasks assigned through rotation system',
  })
  @UseGuards(JwtAuthGuard)
  async getRotationHistory(
    @Args('groupId') groupId: string,
    @Args('limit', { type: () => Int, nullable: true, defaultValue: 50 })
    limit: number,
    @Args('offset', { type: () => Int, nullable: true, defaultValue: 0 })
    offset: number,
    @CurrentUser() user: User,
  ): Promise<RotationHistoryResult> {
    return this.taskService.getRotationHistory(groupId, user.id, limit, offset);
  }

  /**
   * Get rotation pattern information for a group
   * Implements BACKEND_API_REQUIREMENTS.md - getRotationPattern query (Important - Phase 5.1)
   */
  @Query(() => RotationPatternType, {
    description: 'Get current rotation configuration and cycle state',
  })
  @UseGuards(JwtAuthGuard)
  async getRotationPattern(
    @Args('groupId') groupId: string,
    @CurrentUser() user: User,
  ): Promise<RotationPatternType> {
    return this.taskService.getRotationPattern(groupId, user.id);
  }

  /**
   * Добавить вложение к задаче (файл предварительно загружен через POST /upload/task-attachment)
   */
  @Mutation(() => TaskAttachmentType)
  @UseGuards(JwtAuthGuard)
  async addTaskAttachment(
    @Args('input') input: AddTaskAttachmentInput,
    @CurrentUser() user: User,
  ) {
    return this.taskService.addTaskAttachment(user.id, input);
  }

  /**
   * Удалить вложение задачи
   */
  @Mutation(() => Boolean)
  @UseGuards(JwtAuthGuard)
  async deleteTaskAttachment(
    @Args('attachmentId') attachmentId: string,
    @CurrentUser() user: User,
  ) {
    return this.taskService.deleteTaskAttachment(user.id, attachmentId);
  }

  /**
   * Force generation of next task from recurring template (PRD 3.3.3)
   * Used for testing or manual task creation
   */
  @Mutation(() => TaskType, {
    description:
      'Manually generate next task from recurring template (admin only)',
  })
  @UseGuards(JwtAuthGuard)
  async generateNextRecurringTask(
    @Args('taskId') taskId: string,
    @CurrentUser() user: User,
  ): Promise<TaskType> {
    // Проверяем права доступа через TaskService
    const template = await this.taskService.getTask(taskId, user.id);
    if (!template.isRecurring) {
      throw new Error('Task is not a recurring template');
    }

    return this.recurringTaskService.forceGenerateNextTask(taskId);
  }
}
