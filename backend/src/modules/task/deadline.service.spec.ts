import { Test, TestingModule } from '@nestjs/testing';
import { DeadlineService } from './deadline.service';
import { PrismaService } from '../prisma/prisma.service';
import { NotificationService } from '../notification/notification.service';

describe('DeadlineService', () => {
  let service: DeadlineService;
  let prisma: PrismaService;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [
        DeadlineService,
        {
          provide: PrismaService,
          useValue: {
            task: {
              findMany: jest.fn(),
              updateMany: jest.fn(),
            },
          },
        },
        {
          provide: NotificationService,
          useValue: { notify: jest.fn().mockResolvedValue({}) },
        },
      ],
    }).compile();

    service = module.get<DeadlineService>(DeadlineService);
    prisma = module.get<PrismaService>(PrismaService);
  });

  it('should be defined', () => {
    expect(service).toBeDefined();
  });

  describe('checkOverdueTasks', () => {
    it('should find and update overdue tasks', async () => {
      const now = new Date();
      const pastDeadline = new Date(now.getTime() - 24 * 60 * 60 * 1000);

      const overdueTasks = [
        { id: 'task1', deadline: pastDeadline, status: 'PENDING' },
        { id: 'task2', deadline: pastDeadline, status: 'IN_PROGRESS' },
      ];

      jest.spyOn(prisma.task, 'findMany').mockResolvedValue(overdueTasks as any);
      jest.spyOn(prisma.task, 'updateMany').mockResolvedValue({ count: 2 } as any);

      await service.checkOverdueTasks();

      expect(prisma.task.findMany).toHaveBeenCalledWith({
        where: {
          isRecurring: false,
          deadline: {
            lt: expect.any(Date),
          },
          status: {
            notIn: ['COMPLETED', 'OVERDUE', 'CANCELLED'],
          },
        },
      });

      expect(prisma.task.updateMany).toHaveBeenCalledWith({
        where: {
          id: {
            in: ['task1', 'task2'],
          },
        },
        data: {
          status: 'OVERDUE',
        },
      });
    });

    it('should not update if no overdue tasks found', async () => {
      jest.spyOn(prisma.task, 'findMany').mockResolvedValue([]);

      await service.checkOverdueTasks();

      expect(prisma.task.findMany).toHaveBeenCalled();
      expect(prisma.task.updateMany).not.toHaveBeenCalled();
    });

    it('should handle errors gracefully', async () => {
      jest.spyOn(prisma.task, 'findMany').mockRejectedValue(new Error('Database error'));

      await expect(service.checkOverdueTasks()).resolves.not.toThrow();
    });
  });

  describe('sendDeadlineReminders', () => {
    it('should find tasks with upcoming deadlines', async () => {
      const now = new Date();
      const in24h = new Date(now.getTime() + 24 * 60 * 60 * 1000);
      const in1h = new Date(now.getTime() + 60 * 60 * 1000);

      const tasks24h = [
        { id: 'task1', title: 'Test Task 1', deadline: in24h, status: 'PENDING', assignee: { username: 'user1' } },
      ];
      const tasks1h = [
        { id: 'task2', title: 'Test Task 2', deadline: in1h, status: 'IN_PROGRESS', assignee: { username: 'user2' } },
      ];

      jest.spyOn(prisma.task, 'findMany')
        .mockResolvedValueOnce(tasks24h as any)
        .mockResolvedValueOnce(tasks1h as any);

      await service.sendDeadlineReminders();

      expect(prisma.task.findMany).toHaveBeenCalledTimes(2);
      expect(prisma.task.findMany).toHaveBeenNthCalledWith(1, {
        where: {
          isRecurring: false,
          deadline: {
            gte: expect.any(Date),
            lte: expect.any(Date),
          },
          status: {
            in: ['PENDING', 'IN_PROGRESS'],
          },
        },
        include: {
          assignee: true,
          group: true,
        },
      });
      expect(prisma.task.findMany).toHaveBeenNthCalledWith(2, {
        where: {
          isRecurring: false,
          deadline: {
            gte: expect.any(Date),
            lte: expect.any(Date),
          },
          status: {
            in: ['PENDING', 'IN_PROGRESS'],
          },
        },
        include: {
          assignee: true,
          group: true,
        },
      });
    });

    it('should handle errors in reminder sending', async () => {
      jest.spyOn(prisma.task, 'findMany').mockRejectedValue(new Error('Database error'));

      await expect(service.sendDeadlineReminders()).resolves.not.toThrow();
    });
  });
});
