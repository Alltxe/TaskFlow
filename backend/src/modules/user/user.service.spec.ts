import { Test, TestingModule } from '@nestjs/testing';
import { CACHE_MANAGER } from '@nestjs/cache-manager';
import { UserService } from './user.service';
import { PrismaService } from '../prisma/prisma.service';

describe('UserService', () => {
  let service: UserService;
  let prismaService: PrismaService;

  const mockUserId = 'user-123';
  const mockGroupId = 'group-456';

  const mockCompletedTasks = [
    {
      id: 'completion-1',
      userId: mockUserId,
      taskId: 'task-1',
      pointsAwarded: 100,
      wasOnTime: true,
      wasUpForGrabs: false,
      completedAt: new Date('2025-10-20'),
      approvedAt: new Date('2025-10-21'),
      approvedById: 'admin-1',
      task: {
        id: 'task-1',
        groupId: mockGroupId,
        title: 'Test Task 1',
      },
    },
    {
      id: 'completion-2',
      userId: mockUserId,
      taskId: 'task-2',
      pointsAwarded: 150,
      wasOnTime: false,
      wasUpForGrabs: true,
      completedAt: new Date('2025-10-22'),
      approvedAt: new Date('2025-10-23'),
      approvedById: 'admin-1',
      task: {
        id: 'task-2',
        groupId: mockGroupId,
        title: 'Test Task 2',
      },
    },
    {
      id: 'completion-3',
      userId: mockUserId,
      taskId: 'task-3',
      pointsAwarded: 75,
      wasOnTime: true,
      wasUpForGrabs: false,
      completedAt: new Date('2025-10-25'),
      approvedAt: new Date('2025-10-26'),
      approvedById: 'admin-1',
      task: {
        id: 'task-3',
        groupId: mockGroupId,
        title: 'Test Task 3',
      },
    },
  ];

  const mockAssignedTasks = [
    {
      id: 'task-1',
      assigneeId: mockUserId,
      groupId: mockGroupId,
      status: 'COMPLETED',
    },
    {
      id: 'task-2',
      assigneeId: mockUserId,
      groupId: mockGroupId,
      status: 'COMPLETED',
    },
    {
      id: 'task-3',
      assigneeId: mockUserId,
      groupId: mockGroupId,
      status: 'COMPLETED',
    },
    {
      id: 'task-4',
      assigneeId: mockUserId,
      groupId: mockGroupId,
      status: 'IN_PROGRESS',
    },
  ];

  const mockRewardTransactions = [
    {
      id: 'reward-1',
      userId: mockUserId,
      pointsSpent: 50,
      status: 'APPROVED',
      reward: {
        groupId: mockGroupId,
      },
    },
    {
      id: 'reward-2',
      userId: mockUserId,
      pointsSpent: 100,
      status: 'APPROVED',
      reward: {
        groupId: mockGroupId,
      },
    },
  ];

  const mockLeaderboardData = [
    {
      userId: 'user-999',
      _sum: { pointsAwarded: 500 },
    },
    {
      userId: 'user-888',
      _sum: { pointsAwarded: 325 },
    },
    {
      userId: mockUserId,
      _sum: { pointsAwarded: 325 }, // Same as user-888, should be position 2 or 3
    },
    {
      userId: 'user-777',
      _sum: { pointsAwarded: 200 },
    },
  ];

  const mockPrismaService = {
    taskCompletionHistory: {
      findMany: jest.fn(),
      groupBy: jest.fn(),
    },
    task: {
      findMany: jest.fn(),
    },
    rewardTransaction: {
      findMany: jest.fn(),
    },
  };

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [
        UserService,
        {
          provide: PrismaService,
          useValue: mockPrismaService,
        },
        {
          provide: CACHE_MANAGER,
          useValue: {
            get: jest.fn(),
            set: jest.fn(),
            del: jest.fn(),
            reset: jest.fn(),
          },
        },
      ],
    }).compile();

    service = module.get<UserService>(UserService);
    prismaService = module.get<PrismaService>(PrismaService);

    // Reset all mocks before each test
    jest.clearAllMocks();
  });

  it('should be defined', () => {
    expect(service).toBeDefined();
  });

  describe('calculateUserStatistics', () => {
    it('should calculate comprehensive user statistics with all data', async () => {
      mockPrismaService.taskCompletionHistory.findMany.mockResolvedValue(
        mockCompletedTasks,
      );
      mockPrismaService.task.findMany.mockResolvedValue(mockAssignedTasks);
      mockPrismaService.rewardTransaction.findMany.mockResolvedValue(
        mockRewardTransactions,
      );
      mockPrismaService.taskCompletionHistory.groupBy.mockResolvedValue(
        mockLeaderboardData,
      );

      const result = await service.calculateUserStatistics(mockUserId, mockGroupId);

      expect(result).toEqual({
        userId: mockUserId,
        groupId: mockGroupId,
        currentPointBalance: 175, // 325 earned - 150 spent
        totalPointsEarned: 325, // 100 + 150 + 75
        totalPointsSpent: 150, // 50 + 100
        tasksCompleted: 3,
        tasksAssigned: 4,
        completionRate: 75, // 3/4 * 100
        tasksCompletedOnTime: 2, // task-1 and task-3
        onTimePercentage: 66.67, // 2/3 * 100, rounded to 2 decimals
        leaderboardPosition: 3, // Third in the list (0-indexed position 2)
      });

      expect(mockPrismaService.taskCompletionHistory.findMany).toHaveBeenCalledWith({
        where: {
          userId: mockUserId,
          task: {
            groupId: mockGroupId,
          },
        },
        include: {
          task: true,
        },
      });

      expect(mockPrismaService.task.findMany).toHaveBeenCalledWith({
        where: {
          assigneeId: mockUserId,
          groupId: mockGroupId,
          status: {
            in: ['COMPLETED', 'IN_PROGRESS', 'AWAITING_APPROVAL', 'OVERDUE'],
          },
        },
      });

      expect(mockPrismaService.rewardTransaction.findMany).toHaveBeenCalledWith({
        where: {
          userId: mockUserId,
          status: 'APPROVED',
          reward: {
            groupId: mockGroupId,
          },
        },
        include: {
          reward: true,
        },
      });
    });

    it('should handle user with no completed tasks', async () => {
      mockPrismaService.taskCompletionHistory.findMany.mockResolvedValue([]);
      mockPrismaService.task.findMany.mockResolvedValue([]);
      mockPrismaService.rewardTransaction.findMany.mockResolvedValue([]);
      mockPrismaService.taskCompletionHistory.groupBy.mockResolvedValue([]);

      const result = await service.calculateUserStatistics(mockUserId);

      expect(result).toEqual({
        userId: mockUserId,
        groupId: null,
        currentPointBalance: 0,
        totalPointsEarned: 0,
        totalPointsSpent: 0,
        tasksCompleted: 0,
        tasksAssigned: 0,
        completionRate: 0,
        tasksCompletedOnTime: 0,
        onTimePercentage: 0,
        leaderboardPosition: null,
      });
    });

    it('should calculate statistics without groupId (overall stats)', async () => {
      mockPrismaService.taskCompletionHistory.findMany.mockResolvedValue(
        mockCompletedTasks,
      );
      mockPrismaService.task.findMany.mockResolvedValue(mockAssignedTasks);
      mockPrismaService.rewardTransaction.findMany.mockResolvedValue([]);
      mockPrismaService.taskCompletionHistory.groupBy.mockResolvedValue(
        mockLeaderboardData,
      );

      const result = await service.calculateUserStatistics(mockUserId);

      expect(result.groupId).toBeNull();
      expect(result.currentPointBalance).toBe(325); // No rewards spent
      expect(mockPrismaService.taskCompletionHistory.findMany).toHaveBeenCalledWith({
        where: {
          userId: mockUserId,
        },
        include: {
          task: true,
        },
      });
    });

    it('should handle user with tasks but no on-time completions', async () => {
      const lateCompletions = mockCompletedTasks.map((task) => ({
        ...task,
        wasOnTime: false,
      }));

      mockPrismaService.taskCompletionHistory.findMany.mockResolvedValue(
        lateCompletions,
      );
      mockPrismaService.task.findMany.mockResolvedValue(mockAssignedTasks);
      mockPrismaService.rewardTransaction.findMany.mockResolvedValue([]);
      mockPrismaService.taskCompletionHistory.groupBy.mockResolvedValue(
        mockLeaderboardData,
      );

      const result = await service.calculateUserStatistics(mockUserId);

      expect(result.tasksCompletedOnTime).toBe(0);
      expect(result.onTimePercentage).toBe(0);
    });

    it('should handle 100% completion rate', async () => {
      const allCompleted = mockAssignedTasks.map((task) => ({
        ...task,
        status: 'COMPLETED',
      }));

      mockPrismaService.taskCompletionHistory.findMany.mockResolvedValue(
        [...mockCompletedTasks, { ...mockCompletedTasks[0], id: 'completion-4' }],
      );
      mockPrismaService.task.findMany.mockResolvedValue(allCompleted);
      mockPrismaService.rewardTransaction.findMany.mockResolvedValue([]);
      mockPrismaService.taskCompletionHistory.groupBy.mockResolvedValue(
        mockLeaderboardData,
      );

      const result = await service.calculateUserStatistics(mockUserId);

      expect(result.completionRate).toBe(100);
    });
  });

  describe('getCurrentPointBalance', () => {
    it('should return current point balance', async () => {
      mockPrismaService.taskCompletionHistory.findMany.mockResolvedValue(
        mockCompletedTasks,
      );
      mockPrismaService.task.findMany.mockResolvedValue(mockAssignedTasks);
      mockPrismaService.rewardTransaction.findMany.mockResolvedValue(
        mockRewardTransactions,
      );
      mockPrismaService.taskCompletionHistory.groupBy.mockResolvedValue(
        mockLeaderboardData,
      );

      const balance = await service.getCurrentPointBalance(mockUserId, mockGroupId);

      expect(balance).toBe(175); // 325 earned - 150 spent
    });

    it('should return 0 for user with no activity', async () => {
      mockPrismaService.taskCompletionHistory.findMany.mockResolvedValue([]);
      mockPrismaService.task.findMany.mockResolvedValue([]);
      mockPrismaService.rewardTransaction.findMany.mockResolvedValue([]);
      mockPrismaService.taskCompletionHistory.groupBy.mockResolvedValue([]);

      const balance = await service.getCurrentPointBalance(mockUserId);

      expect(balance).toBe(0);
    });
  });

  describe('leaderboard position calculation', () => {
    it('should return correct position when user is in the middle', async () => {
      mockPrismaService.taskCompletionHistory.findMany.mockResolvedValue(
        mockCompletedTasks,
      );
      mockPrismaService.task.findMany.mockResolvedValue(mockAssignedTasks);
      mockPrismaService.rewardTransaction.findMany.mockResolvedValue([]);
      mockPrismaService.taskCompletionHistory.groupBy.mockResolvedValue(
        mockLeaderboardData,
      );

      const result = await service.calculateUserStatistics(mockUserId);

      expect(result.leaderboardPosition).toBe(3); // 1-based position (0-indexed 2)
    });

    it('should return position 1 for top user', async () => {
      const topUserData = [
        { userId: mockUserId, _sum: { pointsAwarded: 1000 } },
        { userId: 'user-999', _sum: { pointsAwarded: 500 } },
      ];

      mockPrismaService.taskCompletionHistory.findMany.mockResolvedValue(
        mockCompletedTasks,
      );
      mockPrismaService.task.findMany.mockResolvedValue(mockAssignedTasks);
      mockPrismaService.rewardTransaction.findMany.mockResolvedValue([]);
      mockPrismaService.taskCompletionHistory.groupBy.mockResolvedValue(
        topUserData,
      );

      const result = await service.calculateUserStatistics(mockUserId);

      expect(result.leaderboardPosition).toBe(1);
    });

    it('should return null when user has no completions', async () => {
      const otherUsersData = [
        { userId: 'user-999', _sum: { pointsAwarded: 500 } },
        { userId: 'user-888', _sum: { pointsAwarded: 300 } },
      ];

      mockPrismaService.taskCompletionHistory.findMany.mockResolvedValue([]);
      mockPrismaService.task.findMany.mockResolvedValue([]);
      mockPrismaService.rewardTransaction.findMany.mockResolvedValue([]);
      mockPrismaService.taskCompletionHistory.groupBy.mockResolvedValue(
        otherUsersData,
      );

      const result = await service.calculateUserStatistics(mockUserId);

      expect(result.leaderboardPosition).toBeNull();
    });
  });
});
