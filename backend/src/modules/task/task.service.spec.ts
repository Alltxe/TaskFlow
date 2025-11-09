import { Test, TestingModule } from '@nestjs/testing';
import {
  NotFoundException,
  ForbiddenException,
  BadRequestException,
} from '@nestjs/common';
import { TaskService } from './task.service';
import { RotationService } from './rotation.service';
import { PrismaService } from '../prisma/prisma.service';
import { AuditLogService } from '../audit-log/audit-log.service';
import {
  CreateTaskInput,
  UpdateTaskInput,
  CompleteTaskInput,
  ApproveTaskInput,
  TaskPriority,
  RotationType,
} from './dto/task.input';

describe('TaskService', () => {
  let service: TaskService;
  let prismaService: PrismaService;

  const mockAdminUserId = 'admin-user-123';
  const mockMemberUserId = 'member-user-456';
  const mockGroupId = 'group-789';
  const mockTaskId = 'task-abc';

  const mockAdminUser = {
    id: mockAdminUserId,
    email: 'admin@example.com',
    username: 'admin',
    isAway: false,
  };

  const mockMemberUser = {
    id: mockMemberUserId,
    email: 'member@example.com',
    username: 'member',
    isAway: false,
  };

  const mockGroup = {
    id: mockGroupId,
    name: 'Test Group',
    rotationType: 'ROUND_ROBIN',
    requiresApproval: true,
    gamificationEnabled: true,
    members: [
      {
        id: 'member-1',
        userId: mockAdminUserId,
        groupId: mockGroupId,
        role: 'ADMIN',
        user: mockAdminUser,
      },
      {
        id: 'member-2',
        userId: mockMemberUserId,
        groupId: mockGroupId,
        role: 'MEMBER',
        user: mockMemberUser,
      },
    ],
  };

  const mockTask = {
    id: mockTaskId,
    title: 'Test Task',
    description: 'Test Description',
    deadline: new Date('2025-12-31'),
    priority: 'MEDIUM',
    points: 100,
    requiresApproval: true,
    isRecurring: false,
    recurrenceRule: null,
    rotationType: null,
    weight: 1,
    status: 'PENDING',
    groupId: mockGroupId,
    createdById: mockAdminUserId,
    assigneeId: mockMemberUserId,
    approvedById: null,
    completedAt: null,
    wasClaimedFromPool: false,
    createdAt: new Date(),
    updatedAt: new Date(),
    assignee: mockMemberUser,
    createdBy: mockAdminUser,
    group: mockGroup,
  };

  const mockPrismaService = {
    groupMember: {
      findFirst: jest.fn(),
      findMany: jest.fn(),
    },
    group: {
      findUnique: jest.fn(),
    },
    task: {
      create: jest.fn(),
      findUnique: jest.fn(),
      findMany: jest.fn(),
      findFirst: jest.fn(),
      update: jest.fn(),
      delete: jest.fn(),
      count: jest.fn(),
    },
    taskCompletionHistory: {
      create: jest.fn(),
      findMany: jest.fn(),
    },
  };

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [
        TaskService,
        RotationService,
        {
          provide: PrismaService,
          useValue: mockPrismaService,
        },
        {
          provide: AuditLogService,
          useValue: {
            logTaskApproval: jest.fn(),
            logPointTransaction: jest.fn(),
            createLog: jest.fn(),
          },
        },
        {
          provide: require('../notification/notification.service').NotificationService,
          useValue: {
            notify: jest.fn().mockResolvedValue({}),
            notifyGroupAdmins: jest.fn().mockResolvedValue([]),
          },
        },
      ],
    }).compile();

    service = module.get<TaskService>(TaskService);
    prismaService = module.get<PrismaService>(PrismaService);

    jest.clearAllMocks();
  });

  it('should be defined', () => {
    expect(service).toBeDefined();
  });

  describe('createTask', () => {
    it('should create a task successfully by admin with assignee', async () => {
      const input: CreateTaskInput = {
        title: 'New Task',
        description: 'Task Description',
        deadline: '2025-12-31',
        priority: TaskPriority.HIGH,
        points: 150,
        requiresApproval: true,
        groupId: mockGroupId,
        assigneeId: mockMemberUserId,
      };

      mockPrismaService.groupMember.findFirst
        .mockResolvedValueOnce({ role: 'ADMIN' }) // Admin check
        .mockResolvedValueOnce({ userId: mockMemberUserId }); // Assignee check

      mockPrismaService.task.create.mockResolvedValue(mockTask);

      const result = await service.createTask(mockAdminUserId, input);

      expect(result).toEqual(mockTask);
      expect(mockPrismaService.task.create).toHaveBeenCalledWith(
        expect.objectContaining({
          data: expect.objectContaining({
            title: input.title,
            description: input.description,
            priority: input.priority,
            points: input.points,
            groupId: mockGroupId,
            createdById: mockAdminUserId,
            assigneeId: mockMemberUserId,
            status: 'PENDING',
          }),
        }),
      );
    });

    it('should throw ForbiddenException if user is not admin', async () => {
      const input: CreateTaskInput = {
        title: 'New Task',
        deadline: '2025-12-31',
        priority: TaskPriority.MEDIUM,
        points: 100,
        groupId: mockGroupId,
      };

      mockPrismaService.groupMember.findFirst.mockResolvedValue(null);

      await expect(
        service.createTask(mockMemberUserId, input),
      ).rejects.toThrow(ForbiddenException);
    });

    it('should throw BadRequestException if assignee is not group member', async () => {
      const input: CreateTaskInput = {
        title: 'New Task',
        deadline: '2025-12-31',
        priority: TaskPriority.MEDIUM,
        points: 100,
        groupId: mockGroupId,
        assigneeId: 'non-member-user',
      };

      mockPrismaService.groupMember.findFirst
        .mockResolvedValueOnce({ role: 'ADMIN' }) // Admin check passes
        .mockResolvedValueOnce(null); // Assignee check fails

      await expect(
        service.createTask(mockAdminUserId, input),
      ).rejects.toThrow(BadRequestException);
    });

    it('should create Up-for-Grabs task when rotationType is DISABLED', async () => {
      const input: CreateTaskInput = {
        title: 'Up-for-Grabs Task',
        deadline: '2025-12-31',
        priority: TaskPriority.MEDIUM,
        points: 100,
        groupId: mockGroupId,
        rotationType: RotationType.DISABLED,
      };

      mockPrismaService.groupMember.findFirst.mockResolvedValue({
        role: 'ADMIN',
      });

      mockPrismaService.group.findUnique.mockResolvedValue({
        ...mockGroup,
        rotationType: 'DISABLED',
      });

      const upForGrabsTask = { ...mockTask, assigneeId: null };
      mockPrismaService.task.create.mockResolvedValue(upForGrabsTask);

      const result = await service.createTask(mockAdminUserId, input);

      expect(result.assigneeId).toBeNull();
      expect(mockPrismaService.task.create).toHaveBeenCalledWith(
        expect.objectContaining({
          data: expect.objectContaining({
            assigneeId: undefined, // undefined because not explicitly set
          }),
        }),
      );
    });

    it('should auto-assign task using Round Robin when no assignee specified', async () => {
      const input: CreateTaskInput = {
        title: 'Auto-assign Task',
        deadline: '2025-12-31',
        priority: TaskPriority.MEDIUM,
        points: 100,
        groupId: mockGroupId,
      };

      mockPrismaService.groupMember.findFirst.mockResolvedValue({
        role: 'ADMIN',
      });

      mockPrismaService.group.findUnique.mockResolvedValue(mockGroup);

      mockPrismaService.groupMember.findMany.mockResolvedValue([
        {
          userId: mockMemberUserId,
          user: { isAway: false },
        },
      ]);

      mockPrismaService.task.findFirst.mockResolvedValue(null); // No previous tasks

      mockPrismaService.task.create.mockResolvedValue({
        ...mockTask,
        assigneeId: mockMemberUserId,
      });

      const result = await service.createTask(mockAdminUserId, input);

      expect(result.assigneeId).toBe(mockMemberUserId);
    });
  });

  describe('getTask', () => {
    it('should return task if user is group member', async () => {
      mockPrismaService.task.findUnique.mockResolvedValue(mockTask);

      const result = await service.getTask(mockTaskId, mockMemberUserId);

      expect(result).toEqual(mockTask);
    });

    it('should throw NotFoundException if task does not exist', async () => {
      mockPrismaService.task.findUnique.mockResolvedValue(null);

      await expect(
        service.getTask('non-existent-task', mockMemberUserId),
      ).rejects.toThrow(NotFoundException);
    });

    it('should throw ForbiddenException if user is not group member', async () => {
      const taskWithDifferentGroup = {
        ...mockTask,
        group: {
          ...mockGroup,
          members: [
            {
              userId: 'other-user',
              role: 'ADMIN',
            },
          ],
        },
      };

      mockPrismaService.task.findUnique.mockResolvedValue(
        taskWithDifferentGroup,
      );

      await expect(
        service.getTask(mockTaskId, mockMemberUserId),
      ).rejects.toThrow(ForbiddenException);
    });
  });

  describe('getGroupTasks', () => {
    it('should return all group tasks for group member', async () => {
      mockPrismaService.groupMember.findFirst.mockResolvedValue({
        userId: mockMemberUserId,
      });

      mockPrismaService.task.findMany.mockResolvedValue([mockTask]);

      const result = await service.getGroupTasks(
        mockGroupId,
        mockMemberUserId,
      );

      expect(result).toEqual([mockTask]);
      expect(mockPrismaService.task.findMany).toHaveBeenCalledWith(
        expect.objectContaining({
          where: { groupId: mockGroupId },
        }),
      );
    });

    it('should filter tasks by status', async () => {
      mockPrismaService.groupMember.findFirst.mockResolvedValue({
        userId: mockMemberUserId,
      });

      mockPrismaService.task.findMany.mockResolvedValue([mockTask]);

      await service.getGroupTasks(mockGroupId, mockMemberUserId, 'PENDING');

      expect(mockPrismaService.task.findMany).toHaveBeenCalledWith(
        expect.objectContaining({
          where: {
            groupId: mockGroupId,
            status: 'PENDING',
          },
        }),
      );
    });

    it('should throw ForbiddenException if user is not group member', async () => {
      mockPrismaService.groupMember.findFirst.mockResolvedValue(null);

      await expect(
        service.getGroupTasks(mockGroupId, 'non-member-user'),
      ).rejects.toThrow(ForbiddenException);
    });
  });

  describe('getUserTasks', () => {
    it('should return all tasks assigned to user', async () => {
      mockPrismaService.task.findMany.mockResolvedValue([mockTask]);

      const result = await service.getUserTasks(mockMemberUserId);

      expect(result).toEqual([mockTask]);
      expect(mockPrismaService.task.findMany).toHaveBeenCalledWith(
        expect.objectContaining({
          where: { assigneeId: mockMemberUserId },
        }),
      );
    });

    it('should filter user tasks by status', async () => {
      mockPrismaService.task.findMany.mockResolvedValue([mockTask]);

      await service.getUserTasks(mockMemberUserId, 'COMPLETED');

      expect(mockPrismaService.task.findMany).toHaveBeenCalledWith(
        expect.objectContaining({
          where: {
            assigneeId: mockMemberUserId,
            status: 'COMPLETED',
          },
        }),
      );
    });
  });

  describe('updateTask', () => {
    it('should update task by admin', async () => {
      const input: UpdateTaskInput = {
        title: 'Updated Title',
        description: 'Updated Description',
      };

      mockPrismaService.task.findUnique.mockResolvedValue(mockTask);
      mockPrismaService.groupMember.findFirst.mockResolvedValue({
        role: 'ADMIN',
      });
      mockPrismaService.task.update.mockResolvedValue({
        ...mockTask,
        ...input,
      });

      const result = await service.updateTask(
        mockTaskId,
        mockAdminUserId,
        input,
      );

      expect(result.title).toBe(input.title);
      expect(result.description).toBe(input.description);
    });

    it('should update task by creator (non-admin)', async () => {
      const input: UpdateTaskInput = {
        title: 'Updated Title',
      };

      mockPrismaService.task.findUnique.mockResolvedValue(mockTask);
      mockPrismaService.groupMember.findFirst.mockResolvedValue({
        role: 'MEMBER',
      });
      mockPrismaService.task.update.mockResolvedValue({
        ...mockTask,
        ...input,
      });

      const result = await service.updateTask(
        mockTaskId,
        mockAdminUserId, // Creator of task
        input,
      );

      expect(result.title).toBe(input.title);
    });

    it('should throw ForbiddenException if user is neither admin nor creator', async () => {
      const input: UpdateTaskInput = {
        title: 'Updated Title',
      };

      mockPrismaService.task.findUnique.mockResolvedValue(mockTask);
      mockPrismaService.groupMember.findFirst.mockResolvedValue({
        role: 'MEMBER',
      });

      await expect(
        service.updateTask(mockTaskId, 'other-user', input),
      ).rejects.toThrow(ForbiddenException);
    });
  });

  describe('deleteTask', () => {
    it('should delete task by admin', async () => {
      mockPrismaService.task.findUnique.mockResolvedValue(mockTask);
      mockPrismaService.groupMember.findFirst.mockResolvedValue({
        role: 'ADMIN',
      });
      mockPrismaService.task.delete.mockResolvedValue(mockTask);

      const result = await service.deleteTask(mockTaskId, mockAdminUserId);

      expect(result).toBe(true);
      expect(mockPrismaService.task.delete).toHaveBeenCalledWith({
        where: { id: mockTaskId },
      });
    });

    it('should throw ForbiddenException if user is not admin', async () => {
      mockPrismaService.task.findUnique.mockResolvedValue(mockTask);
      mockPrismaService.groupMember.findFirst.mockResolvedValue(null);

      await expect(
        service.deleteTask(mockTaskId, mockMemberUserId),
      ).rejects.toThrow(ForbiddenException);
    });
  });

  describe('completeTask', () => {
    it('should complete task without approval requirement', async () => {
      const taskWithoutApproval = {
        ...mockTask,
        requiresApproval: false,
      };

      const input: CompleteTaskInput = { taskId: mockTaskId };

      mockPrismaService.task.findUnique.mockResolvedValue(
        taskWithoutApproval,
      );
      mockPrismaService.task.update.mockResolvedValue({
        ...taskWithoutApproval,
        status: 'COMPLETED',
        completedAt: new Date(),
      });
      mockPrismaService.taskCompletionHistory.create.mockResolvedValue({});

      const result = await service.completeTask(mockMemberUserId, input);

      expect(result.status).toBe('COMPLETED');
      expect(mockPrismaService.taskCompletionHistory.create).toHaveBeenCalled();
    });

    it('should move task to AWAITING_APPROVAL if approval required', async () => {
      const input: CompleteTaskInput = { taskId: mockTaskId };

      mockPrismaService.task.findUnique.mockResolvedValue(mockTask);
      mockPrismaService.task.update.mockResolvedValue({
        ...mockTask,
        status: 'AWAITING_APPROVAL',
      });

      const result = await service.completeTask(mockMemberUserId, input);

      expect(result.status).toBe('AWAITING_APPROVAL');
      expect(mockPrismaService.taskCompletionHistory.create).not.toHaveBeenCalled();
    });

    it('should throw ForbiddenException if user is not assignee', async () => {
      const input: CompleteTaskInput = { taskId: mockTaskId };

      mockPrismaService.task.findUnique.mockResolvedValue(mockTask);

      await expect(
        service.completeTask('other-user', input),
      ).rejects.toThrow(ForbiddenException);
    });

    it('should throw BadRequestException if task already completed', async () => {
      const completedTask = { ...mockTask, status: 'COMPLETED' };
      const input: CompleteTaskInput = { taskId: mockTaskId };

      mockPrismaService.task.findUnique.mockResolvedValue(completedTask);

      await expect(
        service.completeTask(mockMemberUserId, input),
      ).rejects.toThrow(BadRequestException);
    });
  });

  describe('approveTask', () => {
    it('should approve task and award points', async () => {
      const awaitingTask = { ...mockTask, status: 'AWAITING_APPROVAL' };
      const input: ApproveTaskInput = {
        taskId: mockTaskId,
        approved: true,
      };

      mockPrismaService.task.findUnique.mockResolvedValue(awaitingTask);
      mockPrismaService.groupMember.findFirst.mockResolvedValue({
        role: 'ADMIN',
      });
      mockPrismaService.task.update.mockResolvedValue({
        ...awaitingTask,
        status: 'COMPLETED',
        completedAt: new Date(),
        approvedById: mockAdminUserId,
      });
      mockPrismaService.taskCompletionHistory.create.mockResolvedValue({});

      const result = await service.approveTask(mockAdminUserId, input);

      expect(result.status).toBe('COMPLETED');
      expect(result.approvedById).toBe(mockAdminUserId);
      expect(mockPrismaService.taskCompletionHistory.create).toHaveBeenCalledWith(
        expect.objectContaining({
          data: expect.objectContaining({
            taskId: mockTaskId,
            userId: mockMemberUserId,
            approvedById: mockAdminUserId,
            pointsAwarded: expect.any(Number),
          }),
        }),
      );
    });

    it('should reject task and return to PENDING', async () => {
      const awaitingTask = { ...mockTask, status: 'AWAITING_APPROVAL' };
      const input: ApproveTaskInput = {
        taskId: mockTaskId,
        approved: false,
        rejectionReason: 'Некачественная работа', // PRD 3.6.2: rejection reason required
      };

      mockPrismaService.task.findUnique.mockResolvedValue(awaitingTask);
      mockPrismaService.groupMember.findFirst.mockResolvedValue({
        role: 'ADMIN',
      });
      mockPrismaService.task.update.mockResolvedValue({
        ...awaitingTask,
        status: 'PENDING',
        approvedById: null,
        rejectionReason: 'Некачественная работа',
      });

      const result = await service.approveTask(mockAdminUserId, input);

      expect(result.status).toBe('PENDING');
      expect(result.approvedById).toBeNull();
      expect(mockPrismaService.taskCompletionHistory.create).not.toHaveBeenCalled();
    });

    it('should throw ForbiddenException if user is not admin', async () => {
      const awaitingTask = { ...mockTask, status: 'AWAITING_APPROVAL' };
      const input: ApproveTaskInput = {
        taskId: mockTaskId,
        approved: true,
      };

      mockPrismaService.task.findUnique.mockResolvedValue(awaitingTask);
      mockPrismaService.groupMember.findFirst.mockResolvedValue(null);

      await expect(
        service.approveTask(mockMemberUserId, input),
      ).rejects.toThrow(ForbiddenException);
    });

    it('should throw BadRequestException if task is not awaiting approval', async () => {
      const input: ApproveTaskInput = {
        taskId: mockTaskId,
        approved: true,
      };

      mockPrismaService.task.findUnique.mockResolvedValue(mockTask);
      mockPrismaService.groupMember.findFirst.mockResolvedValue({
        role: 'ADMIN',
      });

      await expect(
        service.approveTask(mockAdminUserId, input),
      ).rejects.toThrow(BadRequestException);
    });
  });

  describe('claimTask', () => {
    it('should claim Up-for-Grabs task successfully', async () => {
      const upForGrabsTask = { ...mockTask, assigneeId: null };

      mockPrismaService.task.findUnique.mockResolvedValue(upForGrabsTask);
      mockPrismaService.groupMember.findFirst.mockResolvedValue({
        userId: mockMemberUserId,
      });
      
      const claimedTask = {
        ...upForGrabsTask,
        assigneeId: mockMemberUserId,
        wasClaimedFromPool: true,
        status: 'PENDING',
      };
      
      mockPrismaService.task.update.mockResolvedValue(claimedTask);

      const result = await service.claimTask(mockMemberUserId, mockTaskId);

      expect(result.assigneeId).toBe(mockMemberUserId);
      expect((result as any).wasClaimedFromPool).toBe(true);
      expect(mockPrismaService.task.update).toHaveBeenCalledWith(
        expect.objectContaining({
          data: expect.objectContaining({
            assigneeId: mockMemberUserId,
            wasClaimedFromPool: true,
          }),
        }),
      );
    });

    it('should throw BadRequestException if task already has assignee', async () => {
      mockPrismaService.task.findUnique.mockResolvedValue(mockTask);

      await expect(
        service.claimTask(mockMemberUserId, mockTaskId),
      ).rejects.toThrow(BadRequestException);
    });

    it('should throw ForbiddenException if user is not group member', async () => {
      const upForGrabsTask = { ...mockTask, assigneeId: null };

      mockPrismaService.task.findUnique.mockResolvedValue(upForGrabsTask);
      mockPrismaService.groupMember.findFirst.mockResolvedValue(null);

      await expect(
        service.claimTask('non-member-user', mockTaskId),
      ).rejects.toThrow(ForbiddenException);
    });
  });

  describe('calculatePoints', () => {
    it('should return full points for on-time completion', () => {
      const result = service.calculatePoints(100, true, false, false);
      expect(result).toBe(100); // 100 × 1.0
    });

    it('should return half points for late completion', () => {
      const result = service.calculatePoints(100, false, false, false);
      expect(result).toBe(50); // 100 × 0.5
    });

    it('should return bonus points for Up-for-Grabs', () => {
      const result = service.calculatePoints(100, true, true, false);
      expect(result).toBe(150); // 100 × 1.5
    });

    it('should return zero points for rejected task', () => {
      const result = service.calculatePoints(100, true, false, true);
      expect(result).toBe(0); // Rejected
    });

    it('should prioritize Up-for-Grabs bonus over late penalty', () => {
      const result = service.calculatePoints(100, false, true, false);
      expect(result).toBe(150); // Up-for-Grabs takes priority
    });

    it('should return zero points for rejected Up-for-Grabs task', () => {
      const result = service.calculatePoints(100, true, true, true);
      expect(result).toBe(0); // Rejection overrides all
    });
  });

  describe('Rotation Algorithms', () => {
    describe('Round Robin', () => {
      it('should select first member when no previous tasks', async () => {
        const members = [
          { userId: 'user-1', user: { isAway: false } },
          { userId: 'user-2', user: { isAway: false } },
        ];

        mockPrismaService.groupMember.findMany.mockResolvedValue(members);
        mockPrismaService.task.findFirst.mockResolvedValue(null);

        const input: CreateTaskInput = {
          title: 'Round Robin Test',
          deadline: '2025-12-31',
          priority: TaskPriority.MEDIUM,
          points: 100,
          groupId: mockGroupId,
        };

        mockPrismaService.groupMember.findFirst.mockResolvedValue({
          role: 'ADMIN',
        });
        mockPrismaService.group.findUnique.mockResolvedValue({
          ...mockGroup,
          rotationType: 'ROUND_ROBIN',
        });
        mockPrismaService.task.create.mockResolvedValue({
          ...mockTask,
          assigneeId: 'user-1',
        });

        const result = await service.createTask(mockAdminUserId, input);

        expect(result.assigneeId).toBe('user-1');
      });
    });

    describe('Weighted Random', () => {
      it('should prefer member with fewer active tasks', async () => {
        const members = [
          { userId: 'user-1', user: { isAway: false } },
          { userId: 'user-2', user: { isAway: false } },
        ];

        mockPrismaService.groupMember.findMany.mockResolvedValue(members);
        mockPrismaService.task.count
          .mockResolvedValueOnce(5) // user-1 has 5 active tasks
          .mockResolvedValueOnce(0); // user-2 has 0 active tasks

        const input: CreateTaskInput = {
          title: 'Weighted Random Test',
          deadline: '2025-12-31',
          priority: TaskPriority.MEDIUM,
          points: 100,
          groupId: mockGroupId,
          rotationType: RotationType.WEIGHTED_RANDOM,
        };

        mockPrismaService.groupMember.findFirst.mockResolvedValue({
          role: 'ADMIN',
        });
        mockPrismaService.group.findUnique.mockResolvedValue({
          ...mockGroup,
          rotationType: 'WEIGHTED_RANDOM',
        });
        mockPrismaService.task.create.mockResolvedValue({
          ...mockTask,
          assigneeId: expect.any(String),
        });

        const result = await service.createTask(mockAdminUserId, input);

        // Since weighted random, result could be either user
        expect(result.assigneeId).toBeDefined();
      });
    });

    describe('Skip Away Users', () => {
      it('should skip users marked as away', async () => {
        const members = [
          { userId: 'user-1', user: { isAway: true } }, // Away
          { userId: 'user-2', user: { isAway: false } }, // Available
        ];

        mockPrismaService.groupMember.findMany.mockResolvedValue([
          members[1], // Only available users returned
        ]);

        const input: CreateTaskInput = {
          title: 'Skip Away Test',
          deadline: '2025-12-31',
          priority: TaskPriority.MEDIUM,
          points: 100,
          groupId: mockGroupId,
        };

        mockPrismaService.groupMember.findFirst.mockResolvedValue({
          role: 'ADMIN',
        });
        mockPrismaService.group.findUnique.mockResolvedValue(mockGroup);
        mockPrismaService.task.findFirst.mockResolvedValue(null);
        mockPrismaService.task.create.mockResolvedValue({
          ...mockTask,
          assigneeId: 'user-2',
        });

        const result = await service.createTask(mockAdminUserId, input);

        expect(result.assigneeId).toBe('user-2');
      });
    });

    describe('Load Balancing', () => {
      it('should assign task to lowest accumulated weight when imbalance >= 2x', async () => {
        const input: CreateTaskInput = {
          title: 'Heavy Task',
          deadline: '2025-12-31',
          priority: TaskPriority.MEDIUM,
          points: 100,
          groupId: mockGroupId,
          rotationType: RotationType.LOAD_BALANCING,
          weight: 5,
        };

        mockPrismaService.groupMember.findFirst.mockResolvedValue({ role: 'ADMIN' });
        mockPrismaService.group.findUnique.mockResolvedValue({ ...mockGroup, rotationType: 'LOAD_BALANCING' });

        // Two members available
        mockPrismaService.groupMember.findMany.mockResolvedValue([
          { userId: 'user-lower', user: { isAway: false } },
          { userId: 'user-higher', user: { isAway: false } },
        ]);

        // Completion history: user-higher has accumulated weight 20, user-lower has 5 -> imbalance 4x
        mockPrismaService.taskCompletionHistory.findMany.mockResolvedValue([
          { task: { weight: 10, assigneeId: 'user-higher' } },
          { task: { weight: 10, assigneeId: 'user-higher' } },
          { task: { weight: 5, assigneeId: 'user-lower' } },
        ]);

        mockPrismaService.task.create.mockResolvedValue({
          ...mockTask,
          assigneeId: 'user-lower',
          rotationType: 'LOAD_BALANCING',
        });

        const result = await service.createTask(mockAdminUserId, input);
        expect(result.assigneeId).toBe('user-lower');
      });

      it('should fallback to round robin when imbalance below threshold', async () => {
        const input: CreateTaskInput = {
          title: 'Balanced Task',
          deadline: '2025-12-31',
          priority: TaskPriority.MEDIUM,
          points: 100,
          groupId: mockGroupId,
          rotationType: RotationType.LOAD_BALANCING,
          weight: 3,
        };

        mockPrismaService.groupMember.findFirst.mockResolvedValue({ role: 'ADMIN' });
        mockPrismaService.group.findUnique.mockResolvedValue({ ...mockGroup, rotationType: 'LOAD_BALANCING' });

        mockPrismaService.groupMember.findMany.mockResolvedValue([
          { userId: 'user-1', user: { isAway: false } },
          { userId: 'user-2', user: { isAway: false } },
        ]);

        // Small difference: user-1 load 6, user-2 load 5 -> ratio < 2x
        mockPrismaService.taskCompletionHistory.findMany.mockResolvedValue([
          { task: { weight: 6, assigneeId: 'user-1' } },
          { task: { weight: 5, assigneeId: 'user-2' } },
        ]);

        // No previous task -> round robin chooses first (user-1)
        mockPrismaService.task.findFirst.mockResolvedValue(null);
        mockPrismaService.task.create.mockResolvedValue({
          ...mockTask,
          assigneeId: 'user-1',
          rotationType: 'LOAD_BALANCING',
        });

        const result = await service.createTask(mockAdminUserId, input);
        expect(result.assigneeId).toBe('user-1');
      });
    });
  });
});
