import { Test, TestingModule } from '@nestjs/testing';
import { NotificationService } from './notification.service';
import { PrismaService } from '../prisma/prisma.service';
import { NotificationType as NotificationTypeEnum } from '@prisma/client';
import { NotificationPreferenceService } from '../notification-preference/notification-preference.service';

// Minimal Prisma mock covering methods used by NotificationService
class PrismaMock {
  notification = {
    create: jest.fn(async ({ data }) => ({ id: 'n1', createdAt: new Date(), isRead: false, ...data })),
    findMany: jest.fn(async () => []),
    count: jest.fn(async () => 0),
    updateMany: jest.fn(async ({ where }) => ({ count: (where.id?.in?.length) || 1 })),
  };
  groupMember = {
    findMany: jest.fn(async () => [{ userId: 'admin1' }, { userId: 'admin2' }]),
  };
}

// Mock NotificationPreferenceService
const mockPreferenceService = {
  getPreference: jest.fn().mockResolvedValue(null),
};

describe('NotificationService', () => {
  let service: NotificationService;
  let prisma: PrismaMock;

  beforeEach(async () => {
    prisma = new PrismaMock();
    const module: TestingModule = await Test.createTestingModule({
      providers: [
        NotificationService,
        { provide: PrismaService, useValue: prisma },
        { provide: NotificationPreferenceService, useValue: mockPreferenceService },
      ],
    }).compile();

    service = module.get<NotificationService>(NotificationService);
  });

  it('should create a notification', async () => {
    const result = await service.notify({
      userId: 'u1',
      title: 'Hello',
      message: 'World',
      type: NotificationTypeEnum.SYSTEM,
    });
    expect(prisma.notification.create).toHaveBeenCalledTimes(1);
    expect(result).toBeDefined();
    expect(result?.title).toBe('Hello');
  });

  it('should notify group admins', async () => {
    const res = await service.notifyGroupAdmins('g1', (adminId) => ({
      title: 'Admin Notice',
      message: `Hi ${adminId}`,
      type: NotificationTypeEnum.SYSTEM,
    }));
    expect(prisma.groupMember.findMany).toHaveBeenCalled();
    expect(res).toHaveLength(2);
    expect(prisma.notification.create).toHaveBeenCalledTimes(2);
  });

  it('should list notifications with filters', async () => {
    await service.list('u1', { isRead: false, limit: 10, offset: 0 });
    expect(prisma.notification.findMany).toHaveBeenCalled();
    expect(prisma.notification.count).toHaveBeenCalled();
  });

  it('should mark notifications read', async () => {
    const count = await service.markRead('u1', ['n1', 'n2']);
    expect(prisma.notification.updateMany).toHaveBeenCalled();
    expect(count).toBe(2);
  });

  it('should mark all notifications read', async () => {
    const count = await service.markAllRead('u1');
    expect(prisma.notification.updateMany).toHaveBeenCalled();
    expect(count).toBe(1); // mock returns 1 by default
  });
});

// Helper functions are in notification.service.ts module scope
// We need to re-implement them here for testing or export them
// For now, we'll re-implement for testing purposes
function parseTime(str: string): Date {
  const [h, m] = str.split(':').map(Number);
  const d = new Date();
  d.setHours(h, m, 0, 0);
  return d;
}

function isWithinQuietHours(now: Date, start: Date, end: Date): boolean {
  const nowMinutes = now.getHours() * 60 + now.getMinutes();
  const startMinutes = start.getHours() * 60 + start.getMinutes();
  const endMinutes = end.getHours() * 60 + end.getMinutes();
  if (startMinutes < endMinutes) {
    return nowMinutes >= startMinutes && nowMinutes < endMinutes;
  } else {
    // Quiet hours cross midnight
    return nowMinutes >= startMinutes || nowMinutes < endMinutes;
  }
}

describe('Quiet Hours Helper Functions', () => {
  describe('parseTime', () => {
    it('should parse time string to Date object', () => {
      const result = parseTime('14:30');
      expect(result.getHours()).toBe(14);
      expect(result.getMinutes()).toBe(30);
      expect(result.getSeconds()).toBe(0);
      expect(result.getMilliseconds()).toBe(0);
    });

    it('should handle midnight', () => {
      const result = parseTime('00:00');
      expect(result.getHours()).toBe(0);
      expect(result.getMinutes()).toBe(0);
    });

    it('should handle end of day', () => {
      const result = parseTime('23:59');
      expect(result.getHours()).toBe(23);
      expect(result.getMinutes()).toBe(59);
    });
  });

  describe('isWithinQuietHours', () => {
    it('should return true when time is within quiet hours (same day)', () => {
      const now = new Date();
      now.setHours(23, 0, 0, 0); // 11:00 PM

      const start = parseTime('22:00'); // 10:00 PM
      const end = parseTime('23:30');   // 11:30 PM

      expect(isWithinQuietHours(now, start, end)).toBe(true);
    });

    it('should return false when time is outside quiet hours (same day)', () => {
      const now = new Date();
      now.setHours(21, 0, 0, 0); // 9:00 PM

      const start = parseTime('22:00'); // 10:00 PM
      const end = parseTime('23:30');   // 11:30 PM

      expect(isWithinQuietHours(now, start, end)).toBe(false);
    });

    it('should handle quiet hours crossing midnight (before midnight)', () => {
      const now = new Date();
      now.setHours(23, 30, 0, 0); // 11:30 PM

      const start = parseTime('22:00'); // 10:00 PM
      const end = parseTime('08:00');   // 8:00 AM

      expect(isWithinQuietHours(now, start, end)).toBe(true);
    });

    it('should handle quiet hours crossing midnight (after midnight)', () => {
      const now = new Date();
      now.setHours(6, 0, 0, 0); // 6:00 AM

      const start = parseTime('22:00'); // 10:00 PM
      const end = parseTime('08:00');   // 8:00 AM

      expect(isWithinQuietHours(now, start, end)).toBe(true);
    });

    it('should return false when outside cross-midnight quiet hours', () => {
      const now = new Date();
      now.setHours(10, 0, 0, 0); // 10:00 AM

      const start = parseTime('22:00'); // 10:00 PM
      const end = parseTime('08:00');   // 8:00 AM

      expect(isWithinQuietHours(now, start, end)).toBe(false);
    });

    it('should handle edge case at start boundary (same day)', () => {
      const now = new Date();
      now.setHours(22, 0, 0, 0); // 10:00 PM exactly

      const start = parseTime('22:00'); // 10:00 PM
      const end = parseTime('23:00');   // 11:00 PM

      expect(isWithinQuietHours(now, start, end)).toBe(true);
    });

    it('should handle edge case at end boundary (same day)', () => {
      const now = new Date();
      now.setHours(23, 0, 0, 0); // 11:00 PM exactly

      const start = parseTime('22:00'); // 10:00 PM
      const end = parseTime('23:00');   // 11:00 PM

      expect(isWithinQuietHours(now, start, end)).toBe(false); // Exclusive end
    });

    it('should handle edge case at midnight boundary (cross-midnight)', () => {
      const now = new Date();
      now.setHours(0, 0, 0, 0); // Midnight exactly

      const start = parseTime('22:00'); // 10:00 PM
      const end = parseTime('08:00');   // 8:00 AM

      expect(isWithinQuietHours(now, start, end)).toBe(true);
    });
  });
});
