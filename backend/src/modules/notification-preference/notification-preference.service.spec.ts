import { Test, TestingModule } from '@nestjs/testing';
import { NotFoundException } from '@nestjs/common';
import { NotificationPreferenceService } from './notification-preference.service';
import { PrismaService } from '../prisma/prisma.service';
import { Prisma } from '@prisma/client';

describe('NotificationPreferenceService', () => {
  let service: NotificationPreferenceService;
  let prismaService: PrismaService;

  const mockPrismaService = {
    notificationPreference: {
      findUnique: jest.fn(),
      upsert: jest.fn(),
    },
    deviceToken: {
      upsert: jest.fn(),
      findUnique: jest.fn(),
      delete: jest.fn(),
      findMany: jest.fn(),
    },
  };

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [
        NotificationPreferenceService,
        {
          provide: PrismaService,
          useValue: mockPrismaService,
        },
      ],
    }).compile();

    service = module.get<NotificationPreferenceService>(NotificationPreferenceService);
    prismaService = module.get<PrismaService>(PrismaService);

    jest.clearAllMocks();
  });

  it('should be defined', () => {
    expect(service).toBeDefined();
  });

  describe('getPreference', () => {
    it('should return user preference if exists', async () => {
      const mockPreference = {
        id: 'pref1',
        userId: 'user1',
        enablePush: true,
        quietHoursStart: '22:00',
        quietHoursEnd: '08:00',
        mutedTypes: ['TASK_ASSIGNED'],
        batchingEnabled: false,
        createdAt: new Date(),
        updatedAt: new Date(),
      };

      mockPrismaService.notificationPreference.findUnique.mockResolvedValue(mockPreference);

      const result = await service.getPreference('user1');

      expect(result).toEqual(mockPreference);
      expect(mockPrismaService.notificationPreference.findUnique).toHaveBeenCalledWith({
        where: { userId: 'user1' },
      });
    });

    it('should return null if preference does not exist', async () => {
      mockPrismaService.notificationPreference.findUnique.mockResolvedValue(null);

      const result = await service.getPreference('user1');

      expect(result).toBeNull();
    });
  });

  describe('upsertPreference', () => {
    it('should create new preference with default values', async () => {
      const mockPreference = {
        id: 'pref1',
        userId: 'user1',
        enablePush: true,
        quietHoursStart: null,
        quietHoursEnd: null,
        mutedTypes: Prisma.DbNull,
        batchingEnabled: false,
        createdAt: new Date(),
        updatedAt: new Date(),
      };

      mockPrismaService.notificationPreference.upsert.mockResolvedValue(mockPreference);

      const result = await service.upsertPreference('user1', {});

      expect(result).toEqual(mockPreference);
      expect(mockPrismaService.notificationPreference.upsert).toHaveBeenCalledWith({
        where: { userId: 'user1' },
        update: {},
        create: {
          userId: 'user1',
          enablePush: true,
          quietHoursStart: null,
          quietHoursEnd: null,
          mutedTypes: Prisma.DbNull,
          batchingEnabled: false,
        },
      });
    });

    it('should update preference with provided values', async () => {
      const updateData = {
        enablePush: false,
        quietHoursStart: '22:00',
        quietHoursEnd: '08:00',
        mutedTypes: ['TASK_ASSIGNED', 'REWARD_APPROVED'],
      };

      const mockPreference = {
        id: 'pref1',
        userId: 'user1',
        ...updateData,
        batchingEnabled: false,
        createdAt: new Date(),
        updatedAt: new Date(),
      };

      mockPrismaService.notificationPreference.upsert.mockResolvedValue(mockPreference);

      const result = await service.upsertPreference('user1', updateData);

      expect(result).toEqual(mockPreference);
      expect(mockPrismaService.notificationPreference.upsert).toHaveBeenCalledWith({
        where: { userId: 'user1' },
        update: {
          enablePush: false,
          quietHoursStart: '22:00',
          quietHoursEnd: '08:00',
          mutedTypes: ['TASK_ASSIGNED', 'REWARD_APPROVED'],
        },
        create: expect.objectContaining({
          userId: 'user1',
          enablePush: false,
          quietHoursStart: '22:00',
          quietHoursEnd: '08:00',
        }),
      });
    });

    it('should handle partial updates', async () => {
      const updateData = {
        batchingEnabled: true,
      };

      const mockPreference = {
        id: 'pref1',
        userId: 'user1',
        enablePush: true,
        quietHoursStart: null,
        quietHoursEnd: null,
        mutedTypes: null,
        batchingEnabled: true,
        createdAt: new Date(),
        updatedAt: new Date(),
      };

      mockPrismaService.notificationPreference.upsert.mockResolvedValue(mockPreference);

      const result = await service.upsertPreference('user1', updateData);

      expect(result).toEqual(mockPreference);
      expect(mockPrismaService.notificationPreference.upsert).toHaveBeenCalledWith({
        where: { userId: 'user1' },
        update: {
          batchingEnabled: true,
        },
        create: expect.objectContaining({
          userId: 'user1',
          batchingEnabled: true,
        }),
      });
    });
  });

  describe('registerDeviceToken', () => {
    it('should register new device token', async () => {
      const mockToken = {
        id: 'token1',
        token: 'device-token-123',
        userId: 'user1',
        provider: 'firebase',
        platform: 'android',
        createdAt: new Date(),
        updatedAt: new Date(),
      };

      mockPrismaService.deviceToken.upsert.mockResolvedValue(mockToken);

      const result = await service.registerDeviceToken('user1', 'device-token-123', 'firebase', 'android');

      expect(result).toEqual(mockToken);
      expect(mockPrismaService.deviceToken.upsert).toHaveBeenCalledWith({
        where: { token: 'device-token-123' },
        update: { userId: 'user1', provider: 'firebase', platform: 'android' },
        create: { token: 'device-token-123', userId: 'user1', provider: 'firebase', platform: 'android' },
      });
    });

    it('should update existing token with new user', async () => {
      const mockToken = {
        id: 'token1',
        token: 'device-token-123',
        userId: 'user2',
        provider: 'firebase',
        platform: 'ios',
        createdAt: new Date(),
        updatedAt: new Date(),
      };

      mockPrismaService.deviceToken.upsert.mockResolvedValue(mockToken);

      const result = await service.registerDeviceToken('user2', 'device-token-123', 'firebase', 'ios');

      expect(result).toEqual(mockToken);
    });
  });

  describe('removeDeviceToken', () => {
    it('should remove device token for correct user', async () => {
      const mockToken = {
        id: 'token1',
        token: 'device-token-123',
        userId: 'user1',
        provider: 'firebase',
        platform: 'android',
        createdAt: new Date(),
        updatedAt: new Date(),
      };

      mockPrismaService.deviceToken.findUnique.mockResolvedValue(mockToken);
      mockPrismaService.deviceToken.delete.mockResolvedValue(mockToken);

      const result = await service.removeDeviceToken('user1', 'device-token-123');

      expect(result).toBe(true);
      expect(mockPrismaService.deviceToken.findUnique).toHaveBeenCalledWith({
        where: { token: 'device-token-123' },
      });
      expect(mockPrismaService.deviceToken.delete).toHaveBeenCalledWith({
        where: { token: 'device-token-123' },
      });
    });

    it('should throw NotFoundException if token does not exist', async () => {
      mockPrismaService.deviceToken.findUnique.mockResolvedValue(null);

      await expect(service.removeDeviceToken('user1', 'device-token-123')).rejects.toThrow(NotFoundException);
    });

    it('should throw NotFoundException if token belongs to different user', async () => {
      const mockToken = {
        id: 'token1',
        token: 'device-token-123',
        userId: 'user2',
        provider: 'firebase',
        platform: 'android',
        createdAt: new Date(),
        updatedAt: new Date(),
      };

      mockPrismaService.deviceToken.findUnique.mockResolvedValue(mockToken);

      await expect(service.removeDeviceToken('user1', 'device-token-123')).rejects.toThrow(NotFoundException);
    });
  });

  describe('listDeviceTokens', () => {
    it('should return all device tokens for user', async () => {
      const mockTokens = [
        {
          id: 'token1',
          token: 'device-token-1',
          userId: 'user1',
          provider: 'firebase',
          platform: 'android',
          createdAt: new Date(),
          updatedAt: new Date(),
        },
        {
          id: 'token2',
          token: 'device-token-2',
          userId: 'user1',
          provider: 'onesignal',
          platform: 'ios',
          createdAt: new Date(),
          updatedAt: new Date(),
        },
      ];

      mockPrismaService.deviceToken.findMany.mockResolvedValue(mockTokens);

      const result = await service.listDeviceTokens('user1');

      expect(result).toEqual(mockTokens);
      expect(mockPrismaService.deviceToken.findMany).toHaveBeenCalledWith({
        where: { userId: 'user1' },
      });
    });

    it('should return empty array if no tokens', async () => {
      mockPrismaService.deviceToken.findMany.mockResolvedValue([]);

      const result = await service.listDeviceTokens('user1');

      expect(result).toEqual([]);
    });
  });
});
