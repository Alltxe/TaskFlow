import { ObjectType, Field, Int, Float, ID } from '@nestjs/graphql';

/**
 * User statistics including point balance, completion metrics, and leaderboard position
 * Implements PRD 3.1.3 - User Statistics Calculation
 */
@ObjectType()
export class UserStatistics {
  @Field(() => ID, { description: 'User ID' })
  userId: string;

  @Field(() => Int, { description: 'Current point balance (total earned - total spent)' })
  currentPointBalance: number;

  @Field(() => Int, { description: 'Total points earned from completed tasks' })
  totalPointsEarned: number;

  @Field(() => Int, { description: 'Total points spent on rewards' })
  totalPointsSpent: number;

  @Field(() => Int, { description: 'Total number of tasks completed' })
  tasksCompleted: number;

  @Field(() => Int, { description: 'Total number of tasks assigned to user' })
  tasksAssigned: number;

  @Field(() => Float, { description: 'Task completion rate (completed / assigned) as percentage' })
  completionRate: number;

  @Field(() => Int, { description: 'Number of tasks completed on time' })
  tasksCompletedOnTime: number;

  @Field(() => Float, { description: 'On-time completion percentage' })
  onTimePercentage: number;

  @Field(() => Int, { nullable: true, description: 'Leaderboard position (1-based, null if no completions)' })
  leaderboardPosition: number | null;

  @Field(() => ID, { nullable: true, description: 'Group ID for group-specific statistics (null for overall stats)' })
  groupId: string | null;
}
