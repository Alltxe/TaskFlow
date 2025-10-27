import { Resolver, Query, Args } from '@nestjs/graphql';
import { UseGuards } from '@nestjs/common';
import { User } from '@prisma/client';
import { UserService } from './user.service';
import { UserStatistics } from './types/user-statistics.type';
import { JwtAuthGuard } from '../auth/auth.guard';
import { CurrentUser } from '../auth/decorators/current-user.decorator';

/**
 * User resolver handles user-related GraphQL queries and mutations
 * Implements PRD 3.1.2 (User Profile) and 3.1.3 (User Statistics)
 */
@Resolver()
export class UserResolver {
  constructor(private userService: UserService) {}

  /**
   * Get current authenticated user's statistics
   * Implements PRD 3.1.3 - User Statistics Calculation
   * 
   * @param user - Current authenticated user from JWT
   * @param groupId - Optional group ID for group-specific statistics
   * @returns UserStatistics object
   */
  @Query(() => UserStatistics, {
    description: 'Get statistics for the current authenticated user',
  })
  @UseGuards(JwtAuthGuard)
  async myStatistics(
    @CurrentUser() user: User,
    @Args('groupId', { nullable: true, description: 'Optional group ID for group-specific statistics' })
    groupId?: string,
  ): Promise<UserStatistics> {
    return this.userService.calculateUserStatistics(user.id, groupId);
  }

  /**
   * Get statistics for a specific user by ID
   * Implements PRD 3.1.3 - User Statistics Calculation
   * 
   * @param userId - User ID to get statistics for
   * @param groupId - Optional group ID for group-specific statistics
   * @returns UserStatistics object
   */
  @Query(() => UserStatistics, {
    description: 'Get statistics for a specific user by ID',
  })
  @UseGuards(JwtAuthGuard)
  async userStatistics(
    @Args('userId', { description: 'User ID to get statistics for' })
    userId: string,
    @Args('groupId', { nullable: true, description: 'Optional group ID for group-specific statistics' })
    groupId?: string,
  ): Promise<UserStatistics> {
    return this.userService.calculateUserStatistics(userId, groupId);
  }
}
