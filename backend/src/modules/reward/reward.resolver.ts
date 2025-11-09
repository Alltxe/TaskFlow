import { Resolver, Mutation, Query, Args } from '@nestjs/graphql';
import { UseGuards } from '@nestjs/common';
import { JwtAuthGuard } from '../auth/auth.guard';
import { GroupAdminGuard } from '../group/guards/group-admin.guard';
import { RewardService } from './reward.service';
import { CreateRewardInput, UpdateRewardInput, RequestRewardInput, ApproveRewardRequestInput } from './dto/reward.input';
import { RewardType, RewardTransactionType, PointBalanceType, LeaderboardEntryType } from './types/reward.type';
import { CurrentUser } from '../auth/decorators/current-user.decorator';
import { User } from '@prisma/client';

@Resolver()
export class RewardResolver {
  constructor(private rewardService: RewardService) {}

  // Admin mutations
  @Mutation(() => RewardType, { description: 'Create reward (PRD 3.5.3) - admin only' })
  @UseGuards(JwtAuthGuard, GroupAdminGuard)
  async createReward(@CurrentUser() user: User, @Args('input') input: CreateRewardInput) {
    return this.rewardService.createReward(user.id, input);
  }

  @Mutation(() => RewardType, { description: 'Update reward (PRD 3.5.3) - admin only' })
  @UseGuards(JwtAuthGuard, GroupAdminGuard)
  async updateReward(@CurrentUser() user: User, @Args('input') input: UpdateRewardInput) {
    return this.rewardService.updateReward(user.id, input);
  }

  @Mutation(() => Boolean, { description: 'Delete reward (PRD 3.5.3) - admin only' })
  @UseGuards(JwtAuthGuard, GroupAdminGuard)
  async deleteReward(
    @CurrentUser() user: User,
    @Args('rewardId') rewardId: string,
    @Args('groupId') groupId: string,
  ) {
    return this.rewardService.deleteReward(user.id, rewardId, groupId);
  }

  // Reward request flow
  @Mutation(() => RewardTransactionType, { description: 'Request reward (PRD 3.5.4)' })
  @UseGuards(JwtAuthGuard)
  async requestReward(@CurrentUser() user: User, @Args('input') input: RequestRewardInput) {
    return this.rewardService.requestReward(user.id, input);
  }

  @Mutation(() => RewardTransactionType, { description: 'Approve or reject reward request (PRD 3.5.4) - admin only' })
  @UseGuards(JwtAuthGuard)
  async approveRewardRequest(@CurrentUser() user: User, @Args('input') input: ApproveRewardRequestInput) {
    return this.rewardService.approveRewardRequest(user.id, input);
  }

  // Queries
  @Query(() => [RewardType], { description: 'List active rewards for group (PRD 3.5.3)' })
  @UseGuards(JwtAuthGuard)
  async getGroupRewards(@CurrentUser() user: User, @Args('groupId') groupId: string) {
    return this.rewardService.listGroupRewards(user.id, groupId);
  }

  @Query(() => [RewardTransactionType], { description: 'List my reward requests (PRD 3.5.4)' })
  @UseGuards(JwtAuthGuard)
  async getMyRewardRequests(@CurrentUser() user: User, @Args('groupId', { nullable: true }) groupId?: string) {
    return this.rewardService.listMyRewardRequests(user.id, groupId);
  }

  @Query(() => [RewardTransactionType], { description: 'List all group reward requests (admin only) (PRD 3.5.4)' })
  @UseGuards(JwtAuthGuard, GroupAdminGuard)
  async getGroupRewardRequests(@CurrentUser() user: User, @Args('groupId') groupId: string) {
    return this.rewardService.listGroupRewardRequests(user.id, groupId);
  }

  @Query(() => PointBalanceType, { description: 'Get point balance summary (PRD 3.5.1-3.5.4)' })
  @UseGuards(JwtAuthGuard)
  async getPointBalance(@CurrentUser() user: User, @Args('groupId', { nullable: true }) groupId?: string) {
    return this.rewardService.getPointBalance(user.id, groupId);
  }

  @Query(() => [LeaderboardEntryType], { description: 'Group leaderboard by earned points (PRD 3.5.5)' })
  @UseGuards(JwtAuthGuard)
  async getGroupLeaderboard(@Args('groupId') groupId: string) {
    return this.rewardService.getLeaderboard(groupId);
  }
}
