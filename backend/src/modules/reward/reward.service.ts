import { Injectable, ForbiddenException, NotFoundException, BadRequestException } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { CreateRewardInput, UpdateRewardInput, RequestRewardInput, ApproveRewardRequestInput } from './dto/reward.input';
import { AuditLogService } from '../audit-log/audit-log.service';
import { NotificationService } from '../notification/notification.service';
import { NotificationType as NotificationTypeEnum } from '@prisma/client';

@Injectable()
export class RewardService {
  constructor(
    private prisma: PrismaService,
    private auditLogService: AuditLogService,
    private notifications: NotificationService,
  ) {}

  // Permission helper
  private async assertGroupAdmin(groupId: string, userId: string) {
    const member = await this.prisma.groupMember.findFirst({
      where: { groupId, userId },
    });
    if (!member) throw new ForbiddenException('Вы не участник группы');
    if (member.role !== 'ADMIN') throw new ForbiddenException('Только администратор группы может выполнять это действие');
  }

  async createReward(userId: string, input: CreateRewardInput) {
    await this.assertGroupAdmin(input.groupId, userId);
    return this.prisma.reward.create({
      data: {
        groupId: input.groupId,
        name: input.name,
        cost: input.cost,
        description: input.description,
        imageUrl: input.imageUrl,
        isActive: input.isActive ?? true,
        createdById: userId,
      },
    });
  }

  async updateReward(userId: string, input: UpdateRewardInput) {
    await this.assertGroupAdmin(input.groupId, userId);
    const reward = await this.prisma.reward.findUnique({ where: { id: input.rewardId } });
    if (!reward || reward.groupId !== input.groupId) throw new NotFoundException('Награда не найдена');
    return this.prisma.reward.update({
      where: { id: input.rewardId },
      data: {
        ...(input.name !== undefined && { name: input.name }),
        ...(input.description !== undefined && { description: input.description }),
        ...(input.cost !== undefined && { cost: input.cost }),
        ...(input.imageUrl !== undefined && { imageUrl: input.imageUrl }),
        ...(input.isActive !== undefined && { isActive: input.isActive }),
      },
    });
  }

  async deleteReward(userId: string, rewardId: string, groupId: string) {
    await this.assertGroupAdmin(groupId, userId);
    const reward = await this.prisma.reward.findUnique({ where: { id: rewardId } });
    if (!reward || reward.groupId !== groupId) throw new NotFoundException('Награда не найдена');
    await this.prisma.reward.delete({ where: { id: rewardId } });
    return true;
  }

  async listGroupRewards(userId: string, groupId: string) {
    // Ensure membership
    const member = await this.prisma.groupMember.findFirst({ where: { groupId, userId } });
    if (!member) throw new ForbiddenException('Вы не участник группы');
    return this.prisma.reward.findMany({ where: { groupId, isActive: true }, orderBy: { createdAt: 'asc' } });
  }

  // Balance calculation (PRD 3.5.1-3.5.4)
  async getPointBalance(userId: string, groupId?: string) {
  const earned = await (this.prisma as any).pointTransaction.aggregate({
      _sum: { amount: true },
      where: { userId, type: 'EARNED', ...(groupId && { groupId }) },
    });
  const spent = await (this.prisma as any).pointTransaction.aggregate({
      _sum: { amount: true },
      where: { userId, type: 'SPENT', ...(groupId && { groupId }) },
    });
    const reserved = await (this.prisma as any).pointTransaction.aggregate({
      _sum: { amount: true },
      where: { userId, type: 'RESERVED', ...(groupId && { groupId }), rewardTransaction: { status: 'RESERVED' } },
    });
  const refunded = await (this.prisma as any).pointTransaction.aggregate({
      _sum: { amount: true },
      where: { userId, type: 'REFUNDED', ...(groupId && { groupId }) },
    });

    const totalEarned = earned._sum.amount || 0;
    const totalSpentApproved = spent._sum.amount || 0;
    const totalReservedPending = reserved._sum.amount || 0;
    const totalRefunded = refunded._sum.amount || 0;

    const currentBalance = totalEarned + totalRefunded - totalSpentApproved - totalReservedPending;
    const availableBalance = totalEarned + totalRefunded - totalSpentApproved - totalReservedPending; // same because reserved excluded

    return {
      totalEarned,
      totalSpentApproved,
      totalReservedPending,
      currentBalance,
      availableBalance,
    };
  }

  async requestReward(userId: string, input: RequestRewardInput) {
    const reward = await this.prisma.reward.findUnique({ where: { id: input.rewardId } });
    if (!reward) throw new NotFoundException('Награда не найдена');

    // Ensure membership in group
    const member = await this.prisma.groupMember.findFirst({ where: { groupId: reward.groupId, userId } });
    if (!member) throw new ForbiddenException('Вы не участник группы');

    // Check balance
    const balance = await this.getPointBalance(userId, reward.groupId);
    if (balance.availableBalance < reward.cost) {
      throw new BadRequestException('Недостаточно очков для обмена награды');
    }

    const created = await this.prisma.$transaction(async (tx) => {
      const request = await tx.rewardTransaction.create({
        data: {
          userId,
          rewardId: reward.id,
          pointsSpent: reward.cost,
          status: 'RESERVED' as any,
        },
      });

      await (tx as any).pointTransaction.create({
        data: {
          type: 'RESERVED',
          amount: reward.cost,
          userId,
          groupId: reward.groupId,
          rewardTransactionId: request.id,
          description: `Reward reservation: ${reward.name}`,
        },
      });

      return request;
    });

    // Notify group admins about reward request (PRD 3.6.3)
    await this.notifications.notifyGroupAdmins(reward.groupId, () => ({
      title: 'Reward request',
      message: `New reward request for "${reward.name}"`,
      type: NotificationTypeEnum.REWARD_REQUESTED,
      relatedEntityType: 'RewardTransaction',
      relatedEntityId: created.id,
      sentById: userId,
    }));

    return created;
  }

  async approveRewardRequest(userId: string, input: ApproveRewardRequestInput) {
    const request = await this.prisma.rewardTransaction.findUnique({
      where: { id: input.requestId },
      include: { reward: true },
    });
    if (!request) throw new NotFoundException('Запрос награды не найден');

    // Admin check
    await this.assertGroupAdmin(request.reward.groupId, userId);

  if ((request.status as any) !== 'RESERVED') throw new BadRequestException('Запрос должен быть в статусе RESERVED');

  if (!input.approved) {
      // Reject flow
      const updated = await this.prisma.$transaction(async (tx) => {
        const updated = await tx.rewardTransaction.update({
          where: { id: request.id },
          data: ({
            status: 'REJECTED',
            rejectedAt: new Date(),
            rejectionReason: input.reason || 'Без причины',
            approvedById: userId,
          } as any),
        });

        // Refund points
        await (tx as any).pointTransaction.create({
          data: {
            type: 'REFUNDED',
            amount: request.pointsSpent,
            userId: request.userId,
            groupId: request.reward.groupId,
            rewardTransactionId: request.id,
            description: `Reward request rejected: ${request.reward.name}`,
          },
        });

        return updated;
      });

      // Audit log for refunded points (PRD 3.6.4) - outside transaction
      await this.auditLogService.logPointTransaction(
        'REFUNDED',
        request.pointsSpent,
        request.userId,
        request.reward.groupId,
        request.id,
        `Reward request rejected: ${request.reward.name}`,
      );

      // Notify requester about rejection
      await this.notifications.notify({
        userId: request.userId,
        title: 'Reward request rejected',
        message: `Your reward request for "${request.reward.name}" was rejected: ${input.reason || 'No reason provided'}`,
        type: NotificationTypeEnum.REWARD_REJECTED,
        relatedEntityType: 'RewardTransaction',
        relatedEntityId: request.id,
        sentById: userId,
      });

      return updated;
    }

    // Approval flow
    const updated = await this.prisma.$transaction(async (tx) => {
      const updated = await tx.rewardTransaction.update({
        where: { id: request.id },
        data: {
          status: 'APPROVED',
          approvedAt: new Date(),
          approvedById: userId,
        },
      });

      // Convert reservation to spent (ledger entry)
      await (tx as any).pointTransaction.create({
        data: {
          type: 'SPENT',
          amount: request.pointsSpent,
          userId: request.userId,
          groupId: request.reward.groupId,
          rewardTransactionId: request.id,
          description: `Reward approved: ${request.reward.name}`,
        },
      });

      return updated;
    });

    // Audit log for spent points (PRD 3.6.4) - outside transaction
    await this.auditLogService.logPointTransaction(
      'SPENT',
      request.pointsSpent,
      request.userId,
      request.reward.groupId,
      request.id,
      `Reward approved: ${request.reward.name}`,
    );

    // Notify requester about approval
    await this.notifications.notify({
      userId: request.userId,
      title: 'Reward request approved',
      message: `Your reward request for "${request.reward.name}" has been approved`,
      type: NotificationTypeEnum.REWARD_APPROVED,
      relatedEntityType: 'RewardTransaction',
      relatedEntityId: request.id,
      sentById: userId,
    });

    return updated;
  }

  async listMyRewardRequests(userId: string, groupId?: string) {
    return this.prisma.rewardTransaction.findMany({
      where: { userId, ...(groupId && { reward: { groupId } }) },
      orderBy: { requestedAt: 'desc' },
    });
  }

  async listGroupRewardRequests(userId: string, groupId: string) {
    await this.assertGroupAdmin(groupId, userId);
    return this.prisma.rewardTransaction.findMany({
      where: { reward: { groupId } },
      orderBy: { requestedAt: 'desc' },
    });
  }

  async getLeaderboard(groupId: string) {
    // Aggregate earned points for group via point transactions (EARNED only) minus spent
  const earned = await (this.prisma as any).pointTransaction.groupBy({
      by: ['userId'],
      where: { groupId, type: 'EARNED' },
      _sum: { amount: true },
      orderBy: { _sum: { amount: 'desc' } },
    });
    return earned.map((e, idx) => ({ userId: e.userId, points: e._sum.amount || 0, rank: idx + 1 }));
  }
}
