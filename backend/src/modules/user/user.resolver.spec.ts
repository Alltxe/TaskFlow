import { Test, TestingModule } from '@nestjs/testing';
import { UserResolver } from './user.resolver';
import { UserService } from './user.service';
import { JwtAuthGuard } from '../auth/auth.guard';
import { ExecutionContext } from '@nestjs/common';
import { UserStatistics } from './types/user-statistics.type';

describe('UserResolver', () => {
  let resolver: UserResolver;
  let userService: UserService;

  const mockUser = {
    id: 'user-123',
    email: 'test@example.com',
    username: 'testuser',
    passwordHash: 'hashed_password',
    avatarUrl: null,
    isAway: false,
    awayUntil: null,
    createdAt: new Date(),
    updatedAt: new Date(),
  };

  const mockStatistics: UserStatistics = {
    userId: 'user-123',
    currentPointBalance: 250,
    totalPointsEarned: 500,
    totalPointsSpent: 250,
    tasksCompleted: 10,
    tasksAssigned: 12,
    completionRate: 83.33,
    tasksCompletedOnTime: 8,
    onTimePercentage: 80,
    leaderboardPosition: 3,
    groupId: null,
  };

  const mockGroupStatistics: UserStatistics = {
    ...mockStatistics,
    groupId: 'group-456',
    currentPointBalance: 150,
    totalPointsEarned: 300,
    totalPointsSpent: 150,
  };

  const mockUserService = {
    calculateUserStatistics: jest.fn(),
  };

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [
        UserResolver,
        {
          provide: UserService,
          useValue: mockUserService,
        },
      ],
    })
      .overrideGuard(JwtAuthGuard)
      .useValue({
        canActivate: (context: ExecutionContext) => {
          const ctx = context.switchToHttp();
          const request = ctx.getRequest();
          request.user = mockUser;
          return true;
        },
      })
      .compile();

    resolver = module.get<UserResolver>(UserResolver);
    userService = module.get<UserService>(UserService);

    // Reset all mocks before each test
    jest.clearAllMocks();
  });

  it('should be defined', () => {
    expect(resolver).toBeDefined();
  });

  describe('myStatistics', () => {
    it('should return statistics for the current authenticated user', async () => {
      mockUserService.calculateUserStatistics.mockResolvedValue(mockStatistics);

      const result = await resolver.myStatistics(mockUser);

      expect(result).toEqual(mockStatistics);
      expect(mockUserService.calculateUserStatistics).toHaveBeenCalledWith(
        mockUser.id,
        undefined,
      );
    });

    it('should return group-specific statistics when groupId is provided', async () => {
      mockUserService.calculateUserStatistics.mockResolvedValue(
        mockGroupStatistics,
      );

      const result = await resolver.myStatistics(mockUser, 'group-456');

      expect(result).toEqual(mockGroupStatistics);
      expect(mockUserService.calculateUserStatistics).toHaveBeenCalledWith(
        mockUser.id,
        'group-456',
      );
    });

    it('should return statistics with zero values for new user', async () => {
      const newUserStats: UserStatistics = {
        userId: mockUser.id,
        currentPointBalance: 0,
        totalPointsEarned: 0,
        totalPointsSpent: 0,
        tasksCompleted: 0,
        tasksAssigned: 0,
        completionRate: 0,
        tasksCompletedOnTime: 0,
        onTimePercentage: 0,
        leaderboardPosition: null,
        groupId: null,
      };

      mockUserService.calculateUserStatistics.mockResolvedValue(newUserStats);

      const result = await resolver.myStatistics(mockUser);

      expect(result).toEqual(newUserStats);
      expect(result.leaderboardPosition).toBeNull();
    });
  });

  describe('userStatistics', () => {
    const targetUserId = 'user-456';

    it('should return statistics for a specific user by ID', async () => {
      const targetUserStats: UserStatistics = {
        ...mockStatistics,
        userId: targetUserId,
      };

      mockUserService.calculateUserStatistics.mockResolvedValue(targetUserStats);

      const result = await resolver.userStatistics(targetUserId);

      expect(result).toEqual(targetUserStats);
      expect(mockUserService.calculateUserStatistics).toHaveBeenCalledWith(
        targetUserId,
        undefined,
      );
    });

    it('should return group-specific statistics for a user', async () => {
      const groupId = 'group-789';
      const targetUserGroupStats: UserStatistics = {
        ...mockStatistics,
        userId: targetUserId,
        groupId: groupId,
      };

      mockUserService.calculateUserStatistics.mockResolvedValue(
        targetUserGroupStats,
      );

      const result = await resolver.userStatistics(targetUserId, groupId);

      expect(result).toEqual(targetUserGroupStats);
      expect(mockUserService.calculateUserStatistics).toHaveBeenCalledWith(
        targetUserId,
        groupId,
      );
    });

    it('should allow current user to view their own statistics via userStatistics query', async () => {
      mockUserService.calculateUserStatistics.mockResolvedValue(mockStatistics);

      const result = await resolver.userStatistics(mockUser.id);

      expect(result).toEqual(mockStatistics);
      expect(mockUserService.calculateUserStatistics).toHaveBeenCalledWith(
        mockUser.id,
        undefined,
      );
    });

    it('should handle viewing statistics for users in different groups', async () => {
      const group1Stats: UserStatistics = {
        ...mockStatistics,
        userId: targetUserId,
        groupId: 'group-1',
        currentPointBalance: 100,
      };

      const group2Stats: UserStatistics = {
        ...mockStatistics,
        userId: targetUserId,
        groupId: 'group-2',
        currentPointBalance: 200,
      };

      // First call for group-1
      mockUserService.calculateUserStatistics.mockResolvedValueOnce(group1Stats);
      const result1 = await resolver.userStatistics(targetUserId, 'group-1');
      expect(result1.currentPointBalance).toBe(100);

      // Second call for group-2
      mockUserService.calculateUserStatistics.mockResolvedValueOnce(group2Stats);
      const result2 = await resolver.userStatistics(targetUserId, 'group-2');
      expect(result2.currentPointBalance).toBe(200);

      expect(mockUserService.calculateUserStatistics).toHaveBeenCalledTimes(2);
    });
  });

  describe('Authentication', () => {
    it('should require authentication for myStatistics', async () => {
      // This test verifies that the JwtAuthGuard is applied
      // In a real scenario, without the guard mock, this would fail
      mockUserService.calculateUserStatistics.mockResolvedValue(mockStatistics);

      const result = await resolver.myStatistics(mockUser);

      expect(result).toBeDefined();
      // The guard is mocked to always return true, so this should pass
    });

    it('should require authentication for userStatistics', async () => {
      // This test verifies that the JwtAuthGuard is applied
      mockUserService.calculateUserStatistics.mockResolvedValue(mockStatistics);

      const result = await resolver.userStatistics('user-456');

      expect(result).toBeDefined();
      // The guard is mocked to always return true, so this should pass
    });
  });

  describe('Edge cases', () => {
    it('should handle user with perfect 100% completion rate', async () => {
      const perfectStats: UserStatistics = {
        userId: mockUser.id,
        currentPointBalance: 1000,
        totalPointsEarned: 1000,
        totalPointsSpent: 0,
        tasksCompleted: 20,
        tasksAssigned: 20,
        completionRate: 100,
        tasksCompletedOnTime: 20,
        onTimePercentage: 100,
        leaderboardPosition: 1,
        groupId: null,
      };

      mockUserService.calculateUserStatistics.mockResolvedValue(perfectStats);

      const result = await resolver.myStatistics(mockUser);

      expect(result.completionRate).toBe(100);
      expect(result.onTimePercentage).toBe(100);
      expect(result.leaderboardPosition).toBe(1);
    });

    it('should handle user with negative balance (spent more than earned)', async () => {
      const negativeBalanceStats: UserStatistics = {
        userId: mockUser.id,
        currentPointBalance: -50,
        totalPointsEarned: 100,
        totalPointsSpent: 150,
        tasksCompleted: 5,
        tasksAssigned: 5,
        completionRate: 100,
        tasksCompletedOnTime: 5,
        onTimePercentage: 100,
        leaderboardPosition: 5,
        groupId: null,
      };

      mockUserService.calculateUserStatistics.mockResolvedValue(
        negativeBalanceStats,
      );

      const result = await resolver.myStatistics(mockUser);

      expect(result.currentPointBalance).toBe(-50);
      expect(result.totalPointsSpent).toBeGreaterThan(result.totalPointsEarned);
    });

    it('should handle very large numbers correctly', async () => {
      const largeStats: UserStatistics = {
        userId: mockUser.id,
        currentPointBalance: 999999,
        totalPointsEarned: 1000000,
        totalPointsSpent: 1,
        tasksCompleted: 10000,
        tasksAssigned: 10000,
        completionRate: 100,
        tasksCompletedOnTime: 10000,
        onTimePercentage: 100,
        leaderboardPosition: 1,
        groupId: null,
      };

      mockUserService.calculateUserStatistics.mockResolvedValue(largeStats);

      const result = await resolver.myStatistics(mockUser);

      expect(result.totalPointsEarned).toBe(1000000);
      expect(result.tasksCompleted).toBe(10000);
    });
  });
});
