import { Resolver, Query, Mutation, Args } from '@nestjs/graphql';
import { UseGuards } from '@nestjs/common';
import { GroupService } from './group.service';
import { GroupType, GroupMemberType } from './types/group.type';
import {
  CreateGroupInput,
  UpdateGroupInput,
  JoinGroupInput,
  UpdateMemberRoleInput,
} from './dto/group.input';
import { JwtAuthGuard } from '../auth/auth.guard';
import { CurrentUser } from '../auth/decorators/current-user.decorator';
import { GroupAdminGuard } from './guards/group-admin.guard';
import type { User } from '@prisma/client';

@Resolver()
export class GroupResolver {
  constructor(private groupService: GroupService) {}

  /**
   * Создать группу
   */
  @Mutation(() => GroupType)
  @UseGuards(JwtAuthGuard)
  async createGroup(
    @CurrentUser() user: User,
    @Args('input') input: CreateGroupInput,
  ) {
    return this.groupService.createGroup(user.id, input);
  }

  /**
   * Получить группу по ID
   */
  @Query(() => GroupType)
  @UseGuards(JwtAuthGuard)
  async getGroup(
    @Args('groupId') groupId: string,
    @CurrentUser() user: User,
  ) {
    return this.groupService.getGroup(groupId, user.id);
  }

  /**
   * Получить все группы пользователя
   */
  @Query(() => [GroupType])
  @UseGuards(JwtAuthGuard)
  async getUserGroups(@CurrentUser() user: User) {
    return this.groupService.getUserGroups(user.id);
  }

  /**
   * Получить список участников группы (только для админов)
   */
  @Query(() => [GroupMemberType])
  @UseGuards(JwtAuthGuard, GroupAdminGuard)
  async getGroupMembers(
    @Args('groupId') groupId: string,
    @CurrentUser() user: User,
  ) {
    return this.groupService.getGroupMembers(groupId, user.id);
  }

  /**
   * Обновить группу
   */
  @Mutation(() => GroupType)
  @UseGuards(JwtAuthGuard)
  async updateGroup(
    @Args('groupId') groupId: string,
    @CurrentUser() user: User,
    @Args('input') input: UpdateGroupInput,
  ) {
    return this.groupService.updateGroup(groupId, user.id, input);
  }

  /**
   * Удалить группу
   */
  @Mutation(() => Boolean)
  @UseGuards(JwtAuthGuard)
  async deleteGroup(
    @Args('groupId') groupId: string,
    @CurrentUser() user: User,
  ) {
    return this.groupService.deleteGroup(groupId, user.id);
  }

  /**
   * Присоединиться к группе по токену
   */
  @Mutation(() => GroupType)
  @UseGuards(JwtAuthGuard)
  async joinGroup(
    @CurrentUser() user: User,
    @Args('input') input: JoinGroupInput,
  ) {
    return this.groupService.joinGroup(user.id, input);
  }

  /**
   * Покинуть группу
   */
  @Mutation(() => Boolean)
  @UseGuards(JwtAuthGuard)
  async leaveGroup(
    @Args('groupId') groupId: string,
    @CurrentUser() user: User,
  ) {
    return this.groupService.leaveGroup(groupId, user.id);
  }

  /**
   * Удалить участника из группы
   */
  @Mutation(() => Boolean)
  @UseGuards(JwtAuthGuard)
  async removeMember(
    @Args('groupId') groupId: string,
    @CurrentUser() user: User,
    @Args('userId') memberUserId: string,
  ) {
    return this.groupService.removeMember(groupId, user.id, memberUserId);
  }

  /**
   * Изменить роль участника
   */
  @Mutation(() => GroupMemberType)
  @UseGuards(JwtAuthGuard)
  async updateMemberRole(
    @Args('groupId') groupId: string,
    @CurrentUser() user: User,
    @Args('input') input: UpdateMemberRoleInput,
  ) {
    return this.groupService.updateMemberRole(groupId, user.id, input);
  }

  /**
   * Сгенерировать новый токен приглашения
   */
  @Mutation(() => String)
  @UseGuards(JwtAuthGuard)
  async regenerateInviteToken(
    @Args('groupId') groupId: string,
    @CurrentUser() user: User,
  ) {
    return this.groupService.regenerateInviteToken(groupId, user.id);
  }
}
