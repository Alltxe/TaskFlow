import { Resolver, Query, Mutation, Args } from '@nestjs/graphql';
import { UseGuards } from '@nestjs/common';
import { TaskService } from './task.service';
import { TaskType } from './types/task.type';
import {
  CreateTaskInput,
  UpdateTaskInput,
  CompleteTaskInput,
  ApproveTaskInput,
  ClaimTaskInput,
} from './dto/task.input';
import { JwtAuthGuard } from '../auth/auth.guard';
import { CurrentUser } from '../auth/decorators/current-user.decorator';
import type { User } from '@prisma/client';

@Resolver()
export class TaskResolver {
  constructor(private taskService: TaskService) {}

  /**
   * Создать задачу (только админы группы)
   */
  @Mutation(() => TaskType)
  @UseGuards(JwtAuthGuard)
  async createTask(
    @CurrentUser() user: User,
    @Args('input') input: CreateTaskInput,
  ) {
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
}
