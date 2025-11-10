import { Injectable, Inject } from '@nestjs/common';
import { PrismaClient, Prisma } from '@prisma/client';
import { PrismaService } from '../prisma/prisma.service';
import { UserStatistics } from './types/user-statistics.type';
import { CACHE_MANAGER } from '@nestjs/cache-manager';
import { Cache } from 'cache-manager';

/**
 * User service handles user profile management and statistics calculation
 * Implements PRD 3.1.2 (User Profile Management) and 3.1.3 (User Statistics)
 */
@Injectable()
export class UserService {
  constructor(
    private prisma: PrismaService,
    @Inject(CACHE_MANAGER) private cacheManager: Cache,
  ) {}

  /**
   * Calculate comprehensive user statistics
   * Implements PRD 3.1.3 - User Statistics Calculation
   * Cached for 5 minutes to improve performance (PRD 4.1)
   * 
   * @param userId - User ID to calculate statistics for
   * @param groupId - Optional group ID for group-specific statistics
   * @returns UserStatistics object with all metrics
   */
  async calculateUserStatistics(
    userId: string,
    groupId?: string,
  ): Promise<UserStatistics> {
    // Check cache first
    const cacheKey = `user:stats:${userId}${groupId ? `:group:${groupId}` : ''}`;
    const cachedStats = await this.cacheManager.get<UserStatistics>(cacheKey);
    
    if (cachedStats) {
      return cachedStats;
    }

    // Get all completed tasks for the user
    const completedTasks = await this.prisma.taskCompletionHistory.findMany({
      where: {
        userId,
        ...(groupId && {
          task: {
            groupId,
          },
        }),
      },
      include: {
        task: true,
      },
    });

    // Get all assigned tasks (for completion rate calculation)
    const assignedTasks = await this.prisma.task.findMany({
      where: {
        assigneeId: userId,
        ...(groupId && { groupId }),
        status: {
          in: ['COMPLETED', 'IN_PROGRESS', 'AWAITING_APPROVAL', 'OVERDUE'],
        },
      },
    });

    // Calculate total points earned
    const totalPointsEarned = completedTasks.reduce(
      (sum, completion) => sum + completion.pointsAwarded,
      0,
    );

    // Get total points spent on rewards
    const rewardTransactions = await this.prisma.rewardTransaction.findMany({
      where: {
        userId,
        status: 'APPROVED',
        ...(groupId && {
          reward: {
            groupId,
          },
        }),
      },
      include: {
        reward: true,
      },
    });

    const totalPointsSpent = rewardTransactions.reduce(
      (sum, transaction) => sum + transaction.pointsSpent,
      0,
    );

    // Calculate current point balance
    const currentPointBalance = totalPointsEarned - totalPointsSpent;

    // Calculate completion metrics
    const tasksCompleted = completedTasks.length;
    const tasksAssigned = assignedTasks.length;
    const completionRate =
      tasksAssigned > 0 ? (tasksCompleted / tasksAssigned) * 100 : 0;

    // Calculate on-time completion metrics
    const tasksCompletedOnTime = completedTasks.filter(
      (completion) => completion.wasOnTime,
    ).length;
    const onTimePercentage =
      tasksCompleted > 0 ? (tasksCompletedOnTime / tasksCompleted) * 100 : 0;

    // Calculate leaderboard position
    const leaderboardPosition = await this.calculateLeaderboardPosition(
      userId,
      groupId,
    );

    const statistics: UserStatistics = {
      userId,
      currentPointBalance,
      totalPointsEarned,
      totalPointsSpent,
      tasksCompleted,
      tasksAssigned,
      completionRate: Math.round(completionRate * 100) / 100, // Round to 2 decimal places
      tasksCompletedOnTime,
      onTimePercentage: Math.round(onTimePercentage * 100) / 100,
      leaderboardPosition,
      groupId: groupId || null,
    };

    // Cache the result for 5 minutes (300 seconds)
    await this.cacheManager.set(cacheKey, statistics, 300000);

    return statistics;
  }

  /**
   * Calculate user's position in the leaderboard
   * Based on total points earned
   * 
   * @param userId - User ID to calculate position for
   * @param groupId - Optional group ID for group-specific leaderboard
   * @returns Position (1-based) or null if user has no completions
   */
  private async calculateLeaderboardPosition(
    userId: string,
    groupId?: string,
  ): Promise<number | null> {
    // Get all users with their total points
    const userPoints = await this.prisma.taskCompletionHistory.groupBy({
      by: ['userId'],
      where: {
        ...(groupId && {
          task: {
            groupId,
          },
        }),
      },
      _sum: {
        pointsAwarded: true,
      },
      orderBy: {
        _sum: {
          pointsAwarded: 'desc',
        },
      },
    });

    // Find the user's position
    const position = userPoints.findIndex(
      (entry) => entry.userId === userId,
    );

    // Return 1-based position or null if not found
    return position !== -1 ? position + 1 : null;
  }

  /**
   * Get current point balance for a user
   * 
   * @param userId - User ID
   * @param groupId - Optional group ID for group-specific balance
   * @returns Current point balance
   */
  async getCurrentPointBalance(
    userId: string,
    groupId?: string,
  ): Promise<number> {
    // Use point transaction ledger if present (Phase 6)
    if (!(this.prisma as any).pointTransaction) {
      const stats = await this.calculateUserStatistics(userId, groupId);
      return stats.currentPointBalance;
    }
    const earnedAgg = await (this.prisma as any).pointTransaction.aggregate({
      _sum: { amount: true },
      where: { userId, type: 'EARNED', ...(groupId && { groupId }) },
    });
    // If ledger empty fall back to legacy calculation
    const earned = earnedAgg._sum.amount || 0;
    if (earned === 0) {
      const stats = await this.calculateUserStatistics(userId, groupId);
      return stats.currentPointBalance;
    }
    const spentAgg = await (this.prisma as any).pointTransaction.aggregate({
      _sum: { amount: true },
      where: { userId, type: 'SPENT', ...(groupId && { groupId }) },
    });
    const reservedAgg = await (this.prisma as any).pointTransaction.aggregate({
      _sum: { amount: true },
      where: { userId, type: 'RESERVED', ...(groupId && { groupId }) },
    });
    const refundedAgg = await (this.prisma as any).pointTransaction.aggregate({
      _sum: { amount: true },
      where: { userId, type: 'REFUNDED', ...(groupId && { groupId }) },
    });

    const spent = spentAgg._sum.amount || 0;
    const reserved = reservedAgg._sum.amount || 0;
    const refunded = refundedAgg._sum.amount || 0;
    return earned + refunded - spent - reserved;
  }
}
