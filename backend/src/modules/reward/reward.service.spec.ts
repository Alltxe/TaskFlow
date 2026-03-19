import { Test, TestingModule } from '@nestjs/testing';
import { RewardService } from './reward.service';
import { PrismaService } from '../prisma/prisma.service';
import { AuditLogService } from '../audit-log/audit-log.service';
import { ForbiddenException, BadRequestException } from '@nestjs/common';
import { CreateRewardInput, RequestRewardInput, ApproveRewardRequestInput } from './dto/reward.input';

// Simplified in-memory mocks similar to TaskService tests
const mockGroupId = 'group-123';
const adminUserId = 'admin-1';
const memberUserId = 'member-2';
const rewardId = 'reward-abc';
const requestId = 'request-xyz';

describe('RewardService', () => {
  let service: RewardService;
  let prisma: any;

  const mockPrisma = {
    groupMember: {
      findFirst: jest.fn(),
    },
    reward: {
      create: jest.fn(),
      update: jest.fn(),
      delete: jest.fn(),
      findUnique: jest.fn(),
      findMany: jest.fn(),
    },
    rewardTransaction: {
      create: jest.fn(),
      update: jest.fn(),
      findUnique: jest.fn(),
      findMany: jest.fn(),
    },
    pointTransaction: {
      aggregate: jest.fn(),
      create: jest.fn(),
      groupBy: jest.fn(),
    },
    user: {
      findUnique: jest.fn(),
    },
    $transaction: jest.fn().mockImplementation(async (cb) => cb(mockPrisma)),
  };

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [
        RewardService,
        { provide: PrismaService, useValue: mockPrisma },
        {
          provide: AuditLogService,
          useValue: {
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

    service = module.get(RewardService);
    prisma = module.get(PrismaService);
    jest.clearAllMocks();
  });

  describe('createReward', () => {
    it('should create reward when admin', async () => {
      prisma.groupMember.findFirst.mockResolvedValue({ role: 'ADMIN' });
      prisma.reward.create.mockResolvedValue({ id: rewardId, groupId: mockGroupId, name: 'Coffee', cost: 50, isActive: true });
      const input: CreateRewardInput = { groupId: mockGroupId, name: 'Coffee', cost: 50 } as any;
      const res = await service.createReward(adminUserId, input);
      expect(res.id).toBe(rewardId);
      expect(prisma.reward.create).toHaveBeenCalled();
    });

    it('should forbid non-admin', async () => {
      prisma.groupMember.findFirst.mockResolvedValue({ role: 'MEMBER' });
      const input: CreateRewardInput = { groupId: mockGroupId, name: 'Tea', cost: 30 } as any;
      await expect(service.createReward(memberUserId, input)).rejects.toThrow(ForbiddenException);
    });
  });

  describe('requestReward', () => {
    it('should reserve points when balance sufficient', async () => {
      prisma.reward.findUnique.mockResolvedValue({ id: rewardId, groupId: mockGroupId, name: 'Gift', cost: 40 });
      prisma.groupMember.findFirst.mockResolvedValue({ role: 'MEMBER' });
      prisma.pointTransaction.aggregate.mockResolvedValueOnce({ _sum: { amount: 100 } }); // earned
      prisma.pointTransaction.aggregate.mockResolvedValueOnce({ _sum: { amount: 0 } }); // spent
      prisma.pointTransaction.aggregate.mockResolvedValueOnce({ _sum: { amount: 0 } }); // reserved
      prisma.pointTransaction.aggregate.mockResolvedValueOnce({ _sum: { amount: 0 } }); // refunded

      prisma.rewardTransaction.create.mockResolvedValue({ id: requestId, status: 'RESERVED', pointsSpent: 40 });
      prisma.pointTransaction.create.mockResolvedValue({});

      const input: RequestRewardInput = { rewardId } as any;
      const res = await service.requestReward(memberUserId, input);
      expect(res.status).toBe('RESERVED');
      expect(prisma.rewardTransaction.create).toHaveBeenCalled();
      expect(prisma.pointTransaction.create).toHaveBeenCalledWith(expect.objectContaining({ data: expect.objectContaining({ type: 'RESERVED', amount: 40 }) }));
    });

    it('should fail if insufficient balance', async () => {
      prisma.reward.findUnique.mockResolvedValue({ id: rewardId, groupId: mockGroupId, name: 'Gift', cost: 200 });
      prisma.groupMember.findFirst.mockResolvedValue({ role: 'MEMBER' });
      prisma.pointTransaction.aggregate.mockResolvedValue({ _sum: { amount: 0 } }); // all zero for each call

      const input: RequestRewardInput = { rewardId } as any;
      await expect(service.requestReward(memberUserId, input)).rejects.toThrow(BadRequestException);
    });
  });

  describe('approveRewardRequest', () => {
    it('should approve reserved request', async () => {
      prisma.rewardTransaction.findUnique.mockResolvedValue({ id: requestId, status: 'RESERVED', pointsSpent: 40, userId: memberUserId, reward: { id: rewardId, groupId: mockGroupId, name: 'Gift' } });
      prisma.groupMember.findFirst.mockResolvedValue({ role: 'ADMIN' });
      prisma.rewardTransaction.update.mockResolvedValue({ id: requestId, status: 'APPROVED' });
      prisma.pointTransaction.create.mockResolvedValue({});

      const input: ApproveRewardRequestInput = { requestId, approved: true } as any;
      const res = await service.approveRewardRequest(adminUserId, input);
      expect(res.status).toBe('APPROVED');
      expect(prisma.rewardTransaction.update).toHaveBeenCalled();
      expect(prisma.pointTransaction.create).toHaveBeenCalledWith(expect.objectContaining({ data: expect.objectContaining({ type: 'SPENT', amount: 40 }) }));
    });

    it('should reject reserved request and refund points', async () => {
      prisma.rewardTransaction.findUnique.mockResolvedValue({ id: requestId, status: 'RESERVED', pointsSpent: 60, userId: memberUserId, reward: { id: rewardId, groupId: mockGroupId, name: 'Gift' } });
      prisma.groupMember.findFirst.mockResolvedValue({ role: 'ADMIN' });
      prisma.rewardTransaction.update.mockResolvedValue({ id: requestId, status: 'REJECTED' });
      prisma.pointTransaction.create.mockResolvedValue({});

      const input: ApproveRewardRequestInput = { requestId, approved: false, reason: 'Out of stock' } as any;
      const res = await service.approveRewardRequest(adminUserId, input);
      expect(res.status).toBe('REJECTED');
      expect(prisma.pointTransaction.create).toHaveBeenCalledWith(expect.objectContaining({ data: expect.objectContaining({ type: 'REFUNDED', amount: 60 }) }));
    });

    it('should fail approval if not admin', async () => {
      prisma.rewardTransaction.findUnique.mockResolvedValue({ id: requestId, status: 'RESERVED', pointsSpent: 40, userId: memberUserId, reward: { id: rewardId, groupId: mockGroupId, name: 'Gift' } });
      prisma.groupMember.findFirst.mockResolvedValue({ role: 'MEMBER' });
      const input: ApproveRewardRequestInput = { requestId, approved: true } as any;
      await expect(service.approveRewardRequest(memberUserId, input)).rejects.toThrow(ForbiddenException);
    });
  });

  describe('getPointBalance', () => {
    it('should calculate balance values', async () => {
      prisma.pointTransaction.aggregate
        .mockResolvedValueOnce({ _sum: { amount: 100 } }) // earned
        .mockResolvedValueOnce({ _sum: { amount: 30 } }) // spent
        .mockResolvedValueOnce({ _sum: { amount: 10 } }) // reserved
        .mockResolvedValueOnce({ _sum: { amount: 5 } }); // refunded

      const balance = await service.getPointBalance(memberUserId, mockGroupId);
      expect(balance.currentBalance).toBe(100 + 5 - 30 - 10);
      expect(balance.totalEarned).toBe(100);
      expect(balance.totalSpentApproved).toBe(30);
      expect(balance.totalReservedPending).toBe(10);
    });
  });

  describe('getLeaderboard', () => {
    it('should return ranked entries', async () => {
      prisma.pointTransaction.groupBy.mockResolvedValue([
        { userId: adminUserId, _sum: { amount: 120 } },
        { userId: memberUserId, _sum: { amount: 80 } },
      ]);

      prisma.user.findUnique.mockImplementation(({ where }: any) => {
        if (where.id === adminUserId) {
          return Promise.resolve({
            id: adminUserId,
            username: 'admin',
            email: 'admin@example.com',
            avatarUrl: null,
            isAway: false,
            awayUntil: null,
            createdAt: new Date('2025-01-01T00:00:00.000Z'),
            updatedAt: new Date('2025-01-01T00:00:00.000Z'),
          });
        }

        return Promise.resolve({
          id: memberUserId,
          username: 'member',
          email: 'member@example.com',
          avatarUrl: null,
          isAway: false,
          awayUntil: null,
          createdAt: new Date('2025-01-01T00:00:00.000Z'),
          updatedAt: new Date('2025-01-01T00:00:00.000Z'),
        });
      });

      const lb = await service.getLeaderboard(mockGroupId);
      expect(lb).toEqual([
        {
          user: {
            id: adminUserId,
            username: 'admin',
            email: 'admin@example.com',
            avatarUrl: null,
            isAway: false,
            awayUntil: null,
            createdAt: new Date('2025-01-01T00:00:00.000Z'),
            updatedAt: new Date('2025-01-01T00:00:00.000Z'),
          },
          pointsEarned: 120,
          rank: 1,
        },
        {
          user: {
            id: memberUserId,
            username: 'member',
            email: 'member@example.com',
            avatarUrl: null,
            isAway: false,
            awayUntil: null,
            createdAt: new Date('2025-01-01T00:00:00.000Z'),
            updatedAt: new Date('2025-01-01T00:00:00.000Z'),
          },
          pointsEarned: 80,
          rank: 2,
        },
      ]);
    });
  });
});
