import { Resolver, Query, Mutation, Args } from '@nestjs/graphql';
import { UseGuards } from '@nestjs/common';
import { User } from '@prisma/client';
import { UserService } from './user.service';
import { UserStatistics } from './types/user-statistics.type';
import { UserType } from '../auth/types/user.type';
import { UpdateUserInput } from './dto/update-user.input';
import { SetAwayStatusInput } from './dto/set-away-status.input';
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

  /**
   * Update current user's profile
   * Implements BACKEND_API_REQUIREMENTS.md - updateUser mutation (Critical - Phase 8.1)
   * PRD 3.1.2 - User Profile Management
   * 
   * @param user - Current authenticated user from JWT
   * @param input - Update data (username, avatarUrl)
   * @returns Updated user object
   */
  @Mutation(() => UserType, {
    description: 'Update current user profile (username, avatarUrl)',
  })
  @UseGuards(JwtAuthGuard)
  async updateUser(
    @CurrentUser() user: User,
    @Args('input') input: UpdateUserInput,
  ): Promise<User> {
    return this.userService.updateUser(user.id, input);
  }

  /**
   * Set current user's "Away" status
   * Implements BACKEND_API_REQUIREMENTS.md - setUserAwayStatus mutation (Critical - Phase 5.3)
   * PRD 3.1.2 - User Profile Management
   * PRD 3.4.1 - Affects task rotation (away users are skipped)
   * 
   * @param user - Current authenticated user from JWT
   * @param input - Away status data
   * @returns Updated user object
   */
  @Mutation(() => UserType, {
    description: 'Set "Away" status for current user (affects task rotation)',
  })
  @UseGuards(JwtAuthGuard)
  async setUserAwayStatus(
    @CurrentUser() user: User,
    @Args('input') input: SetAwayStatusInput,
  ): Promise<User> {
    return this.userService.setAwayStatus(user.id, input);
  }
}
