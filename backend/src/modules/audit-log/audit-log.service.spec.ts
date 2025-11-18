import { Test, TestingModule } from '@nestjs/testing';
import { AuditLogService, AuditAction } from './audit-log.service';
import { PrismaService } from '../prisma/prisma.service';

describe('AuditLogService', () => {
  let service: AuditLogService;
  let prisma: PrismaService;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [
        AuditLogService,
        {
          provide: PrismaService,
          useValue: {
            auditLog: {
              create: jest.fn(),
              findMany: jest.fn(),
              count: jest.fn(),
            },
          },
        },
      ],
    }).compile();

    service = module.get<AuditLogService>(AuditLogService);
    prisma = module.get<PrismaService>(PrismaService);
  });

  it('should be defined', () => {
    expect(service).toBeDefined();
  });

  describe('createLog', () => {
    it('should create audit log entry', async () => {
      const logData = {
        action: AuditAction.TASK_APPROVED,
        entityType: 'Task',
        entityId: 'task123',
        userId: 'user123',
        newValues: { approved: true },
      };

      const mockLog = { id: 'log1', ...logData, performedAt: new Date() };
      jest.spyOn(prisma.auditLog, 'create').mockResolvedValue(mockLog as any);

      const result = await service.createLog(logData);

      expect(result).toEqual(mockLog);
      expect(prisma.auditLog.create).toHaveBeenCalledWith({
        data: expect.objectContaining({
          action: logData.action,
          entityType: logData.entityType,
          entityId: logData.entityId,
          userId: logData.userId,
        }),
      });
    });

    it('should handle errors gracefully', async () => {
      const logData = {
        action: AuditAction.TASK_APPROVED,
        entityType: 'Task',
        userId: 'user123',
      };

      jest.spyOn(prisma.auditLog, 'create').mockRejectedValue(new Error('Database error'));

      const result = await service.createLog(logData);

      expect(result).toBeNull();
    });
  });

  describe('logRoleChange', () => {
    it('should log member role change', async () => {
      const mockLog = {
        id: 'log1',
        action: AuditAction.MEMBER_ROLE_CHANGED,
        entityType: 'GroupMember',
        performedAt: new Date(),
      };

      jest.spyOn(prisma.auditLog, 'create').mockResolvedValue(mockLog as any);

      const result = await service.logRoleChange('group1', 'user1', 'MEMBER', 'ADMIN', 'admin1');

      expect(result).toEqual(mockLog);
      expect(prisma.auditLog.create).toHaveBeenCalledWith({
        data: expect.objectContaining({
          action: AuditAction.MEMBER_ROLE_CHANGED,
          entityType: 'GroupMember',
          entityId: 'group1-user1',
          oldValues: { role: 'MEMBER' },
          newValues: { role: 'ADMIN' },
          userId: 'admin1',
        }),
      });
    });
  });

  describe('logTaskApproval', () => {
    it('should log task approval', async () => {
      const mockLog = {
        id: 'log1',
        action: AuditAction.TASK_APPROVED,
        entityType: 'Task',
        performedAt: new Date(),
      };

      jest.spyOn(prisma.auditLog, 'create').mockResolvedValue(mockLog as any);

      await service.logTaskApproval('task1', true, undefined, 'admin1');

      expect(prisma.auditLog.create).toHaveBeenCalledWith({
        data: expect.objectContaining({
          action: AuditAction.TASK_APPROVED,
          entityType: 'Task',
          entityId: 'task1',
          newValues: { approved: true },
          userId: 'admin1',
        }),
      });
    });

    it('should log task rejection with reason', async () => {
      const mockLog = {
        id: 'log1',
        action: AuditAction.TASK_REJECTED,
        entityType: 'Task',
        performedAt: new Date(),
      };

      jest.spyOn(prisma.auditLog, 'create').mockResolvedValue(mockLog as any);

      await service.logTaskApproval('task1', false, 'Некачественная работа', 'admin1');

      expect(prisma.auditLog.create).toHaveBeenCalledWith({
        data: expect.objectContaining({
          action: AuditAction.TASK_REJECTED,
          entityType: 'Task',
          entityId: 'task1',
          newValues: { approved: false, rejectionReason: 'Некачественная работа' },
          userId: 'admin1',
        }),
      });
    });
  });

  describe('logPointTransaction', () => {
    it('should log earned points', async () => {
      const mockLog = {
        id: 'log1',
        action: AuditAction.POINTS_EARNED,
        performedAt: new Date(),
      };

      jest.spyOn(prisma.auditLog, 'create').mockResolvedValue(mockLog as any);

      await service.logPointTransaction('EARNED', 100, 'user1', 'group1', 'task1', 'Task approved');

      expect(prisma.auditLog.create).toHaveBeenCalledWith({
        data: expect.objectContaining({
          action: AuditAction.POINTS_EARNED,
          entityType: 'PointTransaction',
          entityId: 'task1',
          newValues: {
            type: 'EARNED',
            amount: 100,
            groupId: 'group1',
            description: 'Task approved',
          },
          userId: 'user1',
        }),
      });
    });
  });

  describe('getAllLogs', () => {
    it('should return logs with pagination', async () => {
      const mockLogs = [
        { id: 'log1', action: 'TASK_APPROVED', performedAt: new Date() },
        { id: 'log2', action: 'POINTS_EARNED', performedAt: new Date() },
      ];

      jest.spyOn(prisma.auditLog, 'findMany').mockResolvedValue(mockLogs as any);
      jest.spyOn(prisma.auditLog, 'count').mockResolvedValue(2);

      const result = await service.getAllLogs({ limit: 50, offset: 0 });

      expect(result).toEqual({
        logs: mockLogs,
        total: 2,
        limit: 50,
        offset: 0,
      });
    });

    it('should filter logs by entity type', async () => {
      const mockLogs = [{ id: 'log1', action: 'TASK_APPROVED', entityType: 'Task' }];

      jest.spyOn(prisma.auditLog, 'findMany').mockResolvedValue(mockLogs as any);
      jest.spyOn(prisma.auditLog, 'count').mockResolvedValue(1);

      await service.getAllLogs({ entityType: 'Task' });

      expect(prisma.auditLog.findMany).toHaveBeenCalledWith(
        expect.objectContaining({
          where: expect.objectContaining({
            entityType: 'Task',
          }),
        }),
      );
    });
  });

  describe('getLogsByEntity', () => {
    it('should return logs for specific entity', async () => {
      const mockLogs = [
        { id: 'log1', entityType: 'Task', entityId: 'task1', performedAt: new Date() },
      ];

      jest.spyOn(prisma.auditLog, 'findMany').mockResolvedValue(mockLogs as any);

      const result = await service.getLogsByEntity('Task', 'task1');

      expect(result).toEqual(mockLogs);
      expect(prisma.auditLog.findMany).toHaveBeenCalledWith({
        where: {
          entityType: 'Task',
          entityId: 'task1',
        },
        include: {
          user: {
            select: {
              id: true,
              username: true,
              email: true,
            },
          },
        },
        orderBy: {
          performedAt: 'desc',
        },
      });
    });
  });
});
