import { Injectable } from '@nestjs/common';
import { PrismaClient, Prisma } from '@prisma/client';
import { PrismaService } from '../prisma/prisma.service';
import { UserStatistics } from './types/user-statistics.type';

/**
 * User service handles user profile management and statistics calculation
 * Implements PRD 3.1.2 (User Profile Management) and 3.1.3 (User Statistics)
 */
@Injectable()
export class UserService {
  constructor(private prisma: PrismaService) {}

  /**
   * Calculate comprehensive user statistics
   * Implements PRD 3.1.3 - User Statistics Calculation
   * 
   * @param userId - User ID to calculate statistics for
   * @param groupId - Optional group ID for group-specific statistics
   * @returns UserStatistics object with all metrics
   */
  async calculateUserStatistics(
    userId: string,
    groupId?: string,
  ): Promise<UserStatistics> {
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

    return {
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
    const stats = await this.calculateUserStatistics(userId, groupId);
    return stats.currentPointBalance;
  }
}
