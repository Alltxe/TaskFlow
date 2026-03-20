import { Test, TestingModule } from '@nestjs/testing';
import { RecurringTaskService } from './recurring-task.service';
import { PrismaService } from '../prisma/prisma.service';
import { RotationService } from './rotation.service';
import { NotificationService } from '../notification/notification.service';

describe('RecurringTaskService', () => {
  let service: RecurringTaskService;
  let prismaService: PrismaService;
  let rotationService: RotationService;
  let notificationService: NotificationService;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [
        RecurringTaskService,
        {
          provide: PrismaService,
          useValue: {
            task: {
              findMany: jest.fn(),
              findUnique: jest.fn(),
              findFirst: jest.fn(),
              create: jest.fn(),
            },
          },
        },
        {
          provide: RotationService,
          useValue: {
            selectAssignee: jest.fn(),
          },
        },
        {
          provide: NotificationService,
          useValue: {
            notify: jest.fn().mockResolvedValue({}),
          },
        },
      ],
    }).compile();

    service = module.get<RecurringTaskService>(RecurringTaskService);
    prismaService = module.get<PrismaService>(PrismaService);
    rotationService = module.get<RotationService>(RotationService);
    notificationService = module.get<NotificationService>(NotificationService);
  });

  it('should be defined', () => {
    expect(service).toBeDefined();
  });

  describe('calculateNextDeadline', () => {
    it('should calculate next deadline for DAILY recurrence', () => {
      const currentDeadline = new Date('2025-11-16T10:00:00Z');
      const nextDeadline = service.calculateNextDeadline(
        'DAILY',
        currentDeadline,
      );

      expect(nextDeadline).toBeDefined();
      expect(nextDeadline?.getDate()).toBe(17); // Next day
      expect(nextDeadline?.getMonth()).toBe(10); // November (0-indexed)
    });

    it('should calculate next deadline for WEEKLY recurrence (same day next week)', () => {
      const currentDeadline = new Date('2025-11-16T10:00:00Z'); // Sunday
      const nextDeadline = service.calculateNextDeadline(
        'WEEKLY',
        currentDeadline,
      );

      expect(nextDeadline).toBeDefined();
      expect(nextDeadline?.getDate()).toBe(23); // Next Sunday
    });

    it('should calculate next deadline for WEEKLY:1,3,5 (Mon, Wed, Fri)', () => {
      const currentDeadline = new Date('2025-11-17T10:00:00Z'); // Monday (day 1)
      const nextDeadline = service.calculateNextDeadline(
        'WEEKLY:1,3,5',
        currentDeadline,
      );

      expect(nextDeadline).toBeDefined();
      expect(nextDeadline?.getDay()).toBe(3); // Wednesday
      expect(nextDeadline?.getDate()).toBe(19);
    });

    it('should wrap to next week for WEEKLY:1,3,5 when current day is Friday', () => {
      const currentDeadline = new Date('2025-11-21T10:00:00Z'); // Friday (day 5)
      const nextDeadline = service.calculateNextDeadline(
        'WEEKLY:1,3,5',
        currentDeadline,
      );

      expect(nextDeadline).toBeDefined();
      expect(nextDeadline?.getDay()).toBe(1); // Monday
      expect(nextDeadline?.getDate()).toBe(24); // Next week
    });

    it('should calculate next deadline for MONTHLY recurrence', () => {
      const currentDeadline = new Date('2025-11-16T10:00:00Z');
      const nextDeadline = service.calculateNextDeadline(
        'MONTHLY',
        currentDeadline,
      );

      expect(nextDeadline).toBeDefined();
      expect(nextDeadline?.getMonth()).toBe(11); // December (0-indexed)
      expect(nextDeadline?.getDate()).toBe(16); // Same day
    });

    it('should calculate next deadline for MONTHLY:1,15 (1st and 15th)', () => {
      const currentDeadline = new Date('2025-11-10T10:00:00Z');
      const nextDeadline = service.calculateNextDeadline(
        'MONTHLY:1,15',
        currentDeadline,
      );

      expect(nextDeadline).toBeDefined();
      expect(nextDeadline?.getDate()).toBe(15); // Next occurrence in same month
      expect(nextDeadline?.getMonth()).toBe(10); // November
    });

    it('should wrap to next month for MONTHLY:1,15 when current day is 20th', () => {
      const currentDeadline = new Date('2025-11-20T10:00:00Z');
      const nextDeadline = service.calculateNextDeadline(
        'MONTHLY:1,15',
        currentDeadline,
      );

      expect(nextDeadline).toBeDefined();
      expect(nextDeadline?.getDate()).toBe(1); // 1st of next month
      expect(nextDeadline?.getMonth()).toBe(11); // December
    });

    it('should return null for invalid recurrence rule', () => {
      const currentDeadline = new Date('2025-11-16T10:00:00Z');
      const nextDeadline = service.calculateNextDeadline(
        'INVALID',
        currentDeadline,
      );

      expect(nextDeadline).toBeNull();
    });

    // RFC 5545 (iCalendar) format tests
    it('should calculate next deadline for RFC 5545 DAILY rule', () => {
      const currentDeadline = new Date('2025-11-16T10:00:00Z');
      const nextDeadline = service.calculateNextDeadline(
        'FREQ=DAILY',
        currentDeadline,
      );

      expect(nextDeadline).toBeDefined();
      expect(nextDeadline!.getTime()).toBeGreaterThan(currentDeadline.getTime());
      // Should be approximately 1 day later
      const hoursDiff = (nextDeadline!.getTime() - currentDeadline.getTime()) / (1000 * 60 * 60);
      expect(hoursDiff).toBeGreaterThanOrEqual(23);
      expect(hoursDiff).toBeLessThanOrEqual(25);
    });

    it('should calculate next deadline for RFC 5545 WEEKLY with BYDAY', () => {
      const currentDeadline = new Date('2025-11-17T10:00:00Z'); // Monday
      const nextDeadline = service.calculateNextDeadline(
        'FREQ=WEEKLY;BYDAY=MO,WE,FR',
        currentDeadline,
      );

      expect(nextDeadline).toBeDefined();
      expect(nextDeadline!.getTime()).toBeGreaterThan(currentDeadline.getTime());
      // Next occurrence should be Wednesday (day 3) or Friday (day 5)
      const dayOfWeek = nextDeadline!.getDay();
      expect([3, 5]).toContain(dayOfWeek);
    });

    it('should calculate next deadline for RFC 5545 with specific time', () => {
      const currentDeadline = new Date('2025-11-17T10:00:00Z');
      const nextDeadline = service.calculateNextDeadline(
        'FREQ=WEEKLY;BYDAY=MO,WE,FR;BYHOUR=18;BYMINUTE=30;BYSECOND=0',
        currentDeadline,
      );

      expect(nextDeadline).toBeDefined();
      expect(nextDeadline!.getTime()).toBeGreaterThan(currentDeadline.getTime());
      // Should have specific time set (checking UTC time)
      expect(nextDeadline?.getUTCHours()).toBe(18);
      expect(nextDeadline?.getUTCMinutes()).toBe(30);
      expect(nextDeadline?.getUTCSeconds()).toBe(0);
    });

    it('should calculate next deadline for RFC 5545 MONTHLY', () => {
      const currentDeadline = new Date('2025-11-10T10:00:00Z');
      const nextDeadline = service.calculateNextDeadline(
        'FREQ=MONTHLY;BYMONTHDAY=1,15',
        currentDeadline,
      );

      expect(nextDeadline).toBeDefined();
      expect(nextDeadline!.getTime()).toBeGreaterThan(currentDeadline.getTime());
      // Next occurrence should be on 1st or 15th of month
      const dayOfMonth = nextDeadline!.getDate();
      expect([1, 15]).toContain(dayOfMonth);
    });

    it('should calculate next deadline for RFC 5545 with seconds interval', () => {
      const currentDeadline = new Date('2025-11-16T10:00:00Z');
      const nextDeadline = service.calculateNextDeadline(
        'FREQ=SECONDLY;INTERVAL=30',
        currentDeadline,
      );

      expect(nextDeadline).toBeDefined();
      expect(nextDeadline!.getTime()).toBeGreaterThan(currentDeadline.getTime());
      // Should be approximately 30 seconds later
      const secondsDiff = (nextDeadline!.getTime() - currentDeadline.getTime()) / 1000;
      expect(secondsDiff).toBeGreaterThanOrEqual(29);
      expect(secondsDiff).toBeLessThanOrEqual(31);
    });

    it('should return null for invalid RFC 5545 rule', () => {
      const currentDeadline = new Date('2025-11-16T10:00:00Z');
      
      // calculateNextDeadline catches errors and returns null
      const result = service.calculateNextDeadline(
        'FREQ=DAILY;INVALID_SYNTAX===',
        currentDeadline,
      );
      
      expect(result).toBeNull();
    });
  });

  describe('forceGenerateNextTask', () => {
    it('should generate next task from recurring template', async () => {
      const templateId = 'template-1';
      const groupId = 'group-1';
      const userId = 'user-1';

      const mockTemplate = {
        id: templateId,
        title: 'Clean Kitchen',
        description: 'Weekly kitchen cleaning',
        deadline: new Date('2025-11-16T10:00:00Z'),
        priority: 'MEDIUM',
        points: 10,
        requiresApproval: true,
        weight: 1,
        groupId,
        createdById: userId,
        assigneeId: null,
        parentTaskId: null,
        isRecurring: true,
        recurrenceRule: 'WEEKLY',
        rotationType: 'ROUND_ROBIN',
        status: 'COMPLETED',
        group: {
          id: groupId,
          rotationType: 'ROUND_ROBIN',
          name: 'Test Group',
        },
        childTasks: [],
      };

      const mockNewTask = {
        id: 'task-new',
        title: mockTemplate.title,
        description: mockTemplate.description,
        deadline: new Date('2025-11-23T10:00:00Z'),
        priority: mockTemplate.priority,
        points: mockTemplate.points,
        requiresApproval: mockTemplate.requiresApproval,
        weight: mockTemplate.weight,
        groupId: mockTemplate.groupId,
        createdById: mockTemplate.createdById,
        assigneeId: userId,
        parentTaskId: templateId,
        isRecurring: false,
        recurrenceRule: null,
        rotationType: mockTemplate.rotationType,
        status: 'PENDING',
        wasClaimedFromPool: false,
        rejectionReason: null,
        createdAt: new Date(),
        completedAt: null,
        approvedById: null,
      };

      jest.spyOn(prismaService.task, 'findUnique').mockResolvedValue(mockTemplate as any);
      jest.spyOn(prismaService.task, 'create').mockResolvedValue(mockNewTask as any);
      jest.spyOn(rotationService, 'selectAssignee').mockResolvedValue(userId);

      const result = await service.forceGenerateNextTask(templateId);

      expect(result).toBeDefined();
      expect(result.parentTaskId).toBe(templateId);
      expect(result.isRecurring).toBe(false);
      expect(prismaService.task.create).toHaveBeenCalled();
      expect(notificationService.notify).toHaveBeenCalledWith(
        expect.objectContaining({
          userId,
          title: 'Task assigned',
          relatedEntityType: 'Task',
          relatedEntityId: mockNewTask.id,
          type: 'TASK_ASSIGNED',
        }),
      );
    });

    it('should throw error if task is not recurring', async () => {
      const taskId = 'task-1';
      const mockTask = {
        id: taskId,
        isRecurring: false,
      };

      jest.spyOn(prismaService.task, 'findUnique').mockResolvedValue(mockTask as any);

      await expect(service.forceGenerateNextTask(taskId)).rejects.toThrow(
        'Task is not a recurring template',
      );
    });

    it('should use group rotation type if task has no specific rotation', async () => {
      const templateId = 'template-1';
      const groupId = 'group-1';
      const userId = 'user-1';

      const mockTemplate = {
        id: templateId,
        title: 'Clean Kitchen',
        deadline: new Date('2025-11-16T10:00:00Z'),
        priority: 'MEDIUM',
        points: 10,
        requiresApproval: true,
        weight: 1,
        groupId,
        createdById: userId,
        assigneeId: null,
        isRecurring: true,
        recurrenceRule: 'DAILY',
        rotationType: null, // No specific rotation
        status: 'COMPLETED',
        group: {
          id: groupId,
          rotationType: 'WEIGHTED_RANDOM',
          name: 'Test Group',
        },
        childTasks: [],
      };

      jest.spyOn(prismaService.task, 'findUnique').mockResolvedValue(mockTemplate as any);
      jest.spyOn(prismaService.task, 'create').mockResolvedValue({ id: 'new-task' } as any);
      jest.spyOn(rotationService, 'selectAssignee').mockResolvedValue(userId);

      await service.forceGenerateNextTask(templateId);

      expect(rotationService.selectAssignee).toHaveBeenCalledWith(
        groupId,
        'WEIGHTED_RANDOM',
        1,
      );
    });

    it('should keep fixed assignee when rotation type is null', async () => {
      const templateId = 'template-1';
      const groupId = 'group-1';
      const userId = 'user-1';
      const fixedAssigneeId = 'user-fixed';

      const mockTemplate = {
        id: templateId,
        title: 'Clean Kitchen',
        deadline: new Date('2025-11-16T10:00:00Z'),
        priority: 'MEDIUM',
        points: 10,
        requiresApproval: true,
        weight: 1,
        groupId,
        createdById: userId,
        assigneeId: fixedAssigneeId, // Fixed executor
        isRecurring: true,
        recurrenceRule: 'DAILY',
        rotationType: null,
        status: 'COMPLETED',
        group: {
          id: groupId,
          rotationType: 'ROUND_ROBIN',
          name: 'Test Group',
        },
        childTasks: [],
      };

      jest.spyOn(prismaService.task, 'findUnique').mockResolvedValue(mockTemplate as any);
      const createSpy = jest.spyOn(prismaService.task, 'create').mockResolvedValue({
        id: 'new-task',
        assigneeId: fixedAssigneeId,
      } as any);

      await service.forceGenerateNextTask(templateId);

      expect(createSpy).toHaveBeenCalledWith(
        expect.objectContaining({
          data: expect.objectContaining({
            assigneeId: fixedAssigneeId,
          }),
        }),
      );
      expect(rotationService.selectAssignee).not.toHaveBeenCalled();
    });
  });

  describe('generateRecurringTasks', () => {
    it('should skip tasks with deadline more than 24 hours away', async () => {
      const futureDeadline = new Date();
      futureDeadline.setHours(futureDeadline.getHours() + 30); // 30 hours in future

      const mockTemplate = {
        id: 'template-1',
        isRecurring: true,
        recurrenceRule: 'DAILY',
        deadline: new Date(),
        status: 'COMPLETED',
        group: { id: 'group-1', rotationType: 'ROUND_ROBIN', name: 'Test' },
        childTasks: [{ deadline: futureDeadline }],
      };

      jest.spyOn(prismaService.task, 'findMany').mockResolvedValue([mockTemplate as any]);
      jest.spyOn(prismaService.task, 'findFirst').mockResolvedValue(null);

      await service.generateRecurringTasks();

      expect(prismaService.task.create).not.toHaveBeenCalled();
    });

    it('should create task when deadline is within 24 hours', async () => {
      const now = new Date();
      const lastDeadline = new Date(now);
      lastDeadline.setDate(lastDeadline.getDate() - 1); // Yesterday

      const nextDeadline = new Date(now);
      nextDeadline.setDate(nextDeadline.getDate() + 1); // Tomorrow (DAILY rule)

      const mockTemplate = {
        id: 'template-1',
        title: 'Test Task',
        description: 'Test',
        isRecurring: true,
        recurrenceRule: 'DAILY',
        deadline: lastDeadline,
        priority: 'MEDIUM',
        points: 10,
        requiresApproval: true,
        weight: 1,
        groupId: 'group-1',
        createdById: 'user-1',
        assigneeId: null,
        rotationType: 'ROUND_ROBIN',
        status: 'COMPLETED',
        group: { id: 'group-1', rotationType: 'ROUND_ROBIN', name: 'Test' },
        childTasks: [{ deadline: lastDeadline }], // Last child was yesterday
      };

      jest.spyOn(prismaService.task, 'findMany').mockResolvedValue([mockTemplate as any]);
      jest.spyOn(prismaService.task, 'findFirst').mockResolvedValue(null); // No existing task
      jest.spyOn(prismaService.task, 'create').mockResolvedValue({ id: 'new-task' } as any);
      jest.spyOn(rotationService, 'selectAssignee').mockResolvedValue('user-1');

      await service.generateRecurringTasks();

      expect(prismaService.task.create).toHaveBeenCalled();
      expect(prismaService.task.create).toHaveBeenCalledWith(
        expect.objectContaining({
          data: expect.objectContaining({
            parentTaskId: 'template-1',
            isRecurring: false,
          }),
        }),
      );
    });
  });

  describe('RFC 5545 Integration Test', () => {
    it('should generate task from RFC 5545 template with secondly interval', async () => {
      const templateId = 'template-rrule';
      const groupId = 'group-1';
      const userId = 'user-1';
      
      // Create a template with 10-second interval for testing
      const now = new Date();
      const mockTemplate = {
        id: templateId,
        title: 'Quick Recurring Task',
        description: 'Task that recurs every 10 seconds',
        deadline: now,
        priority: 'MEDIUM',
        points: 5,
        requiresApproval: false,
        weight: 1,
        groupId,
        createdById: userId,
        assigneeId: userId,
        isRecurring: true,
        recurrenceRule: 'FREQ=SECONDLY;INTERVAL=10', // Every 10 seconds
        rotationType: null, // Fixed executor
        status: 'COMPLETED',
        group: {
          id: groupId,
          rotationType: 'ROUND_ROBIN',
          name: 'Test Group',
        },
        childTasks: [{ deadline: now }],
      };

      jest.spyOn(prismaService.task, 'findUnique').mockResolvedValue(mockTemplate as any);
      
      const createSpy = jest.spyOn(prismaService.task, 'create').mockResolvedValue({
        id: 'generated-task',
        parentTaskId: templateId,
        isRecurring: false,
        deadline: new Date(now.getTime() + 10000), // 10 seconds later
      } as any);

      const result = await service.forceGenerateNextTask(templateId);

      expect(result).toBeDefined();
      expect(result.parentTaskId).toBe(templateId);
      expect(result.isRecurring).toBe(false);
      expect(createSpy).toHaveBeenCalled();
      
      // Verify deadline is approximately 10 seconds after template deadline
      const createCallArgs = createSpy.mock.calls[0][0];
      const createdDeadline = new Date(createCallArgs.data.deadline);
      const timeDiff = createdDeadline.getTime() - now.getTime();
      const secondsDiff = timeDiff / 1000;
      
      expect(secondsDiff).toBeGreaterThanOrEqual(9);
      expect(secondsDiff).toBeLessThanOrEqual(11);
    });

    it('should use RFC 5545 rule for task generation in CRON job context', async () => {
      const now = new Date();
      const pastDeadline = new Date(now.getTime() - 1000); // 1 second ago
      
      const mockTemplate = {
        id: 'template-cron',
        title: 'CRON Test Task',
        description: 'Test',
        isRecurring: true,
        recurrenceRule: 'FREQ=SECONDLY;INTERVAL=5', // Every 5 seconds
        deadline: pastDeadline,
        priority: 'MEDIUM',
        points: 10,
        requiresApproval: false,
        weight: 1,
        groupId: 'group-1',
        createdById: 'user-1',
        assigneeId: 'user-1',
        rotationType: null,
        status: 'COMPLETED',
        group: { id: 'group-1', rotationType: 'ROUND_ROBIN', name: 'Test' },
        childTasks: [{ deadline: pastDeadline }],
      };

      jest.spyOn(prismaService.task, 'findMany').mockResolvedValue([mockTemplate as any]);
      jest.spyOn(prismaService.task, 'findFirst').mockResolvedValue(null);
      const createSpy = jest.spyOn(prismaService.task, 'create').mockResolvedValue({ id: 'new-task' } as any);

      await service.generateRecurringTasks();

      // Should create task because next deadline (pastDeadline + 5 seconds) is within 24 hours
      expect(createSpy).toHaveBeenCalled();
      
      const createCallArgs = createSpy.mock.calls[0][0];
      const createdDeadline = new Date(createCallArgs.data.deadline);
      
      // Verify deadline is approximately 5 seconds after last deadline
      const timeDiff = createdDeadline.getTime() - pastDeadline.getTime();
      const secondsDiff = timeDiff / 1000;
      
      expect(secondsDiff).toBeGreaterThanOrEqual(4);
      expect(secondsDiff).toBeLessThanOrEqual(6);
    });
  });
});
