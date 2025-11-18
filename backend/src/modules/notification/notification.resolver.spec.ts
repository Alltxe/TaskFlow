import { Test, TestingModule } from '@nestjs/testing';
import { NotificationResolver } from './notification.resolver';
import { NotificationService } from './notification.service';
import { JwtAuthGuard } from '../auth/auth.guard';

const serviceMock = {
  list: jest.fn(async () => ({ items: [], total: 0 })),
  markRead: jest.fn(async () => 1),
  markAllRead: jest.fn(async () => 1),
};

describe('NotificationResolver', () => {
  let resolver: NotificationResolver;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [NotificationResolver, { provide: NotificationService, useValue: serviceMock }],
    })
      .overrideGuard(JwtAuthGuard)
      .useValue({ canActivate: () => true })
      .compile();

    resolver = module.get<NotificationResolver>(NotificationResolver);
  });

  it('should list notifications for current user', async () => {
    const res = await resolver.myNotifications({ id: 'u1' } as any, { limit: 10 } as any);
    expect(serviceMock.list).toHaveBeenCalledWith('u1', { limit: 10 } as any);
    expect(res.total).toBe(0);
  });

  it('should mark notifications read', async () => {
    const ok = await resolver.markNotificationsRead({ id: 'u1' } as any, { ids: ['n1'] } as any);
    expect(serviceMock.markRead).toHaveBeenCalledWith('u1', ['n1']);
    expect(ok).toBe(true);
  });

  it('should mark all read', async () => {
    const ok = await resolver.markAllNotificationsRead({ id: 'u1' } as any);
    expect(serviceMock.markAllRead).toHaveBeenCalledWith('u1');
    expect(ok).toBe(true);
  });
});
