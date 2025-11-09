// Clean replacement of file (previous content corrupted by duplicate blocks)
import { Test, TestingModule } from '@nestjs/testing';
import { FirebaseService } from './firebase.service';
import * as admin from 'firebase-admin';

jest.mock('firebase-admin', () => {
  const credential = { cert: jest.fn() };
  const initializeApp = jest.fn();
  const messaging = jest.fn();
  return { credential, initializeApp, messaging, get apps() { return []; } } as any;
});

describe('FirebaseService', () => {
  let service: FirebaseService;
  let mockSend: jest.Mock;

  beforeEach(async () => {
    jest.clearAllMocks();
    mockSend = jest.fn();
    (admin.messaging as any).mockReturnValue({ send: mockSend });
    const module: TestingModule = await Test.createTestingModule({ providers: [FirebaseService] }).compile();
    service = module.get<FirebaseService>(FirebaseService);
  });

  describe('init', () => {
    it('defined', () => expect(service).toBeDefined());
    it('initializes with creds', () => {
      process.env.FIREBASE_PROJECT_ID = 'p';
      process.env.FIREBASE_PRIVATE_KEY = 'k';
      process.env.FIREBASE_CLIENT_EMAIL = 'e@x.com';
      service.onModuleInit();
      expect((admin.credential.cert as any)).toHaveBeenCalled();
      expect((admin.initializeApp as any)).toHaveBeenCalled();
    });
    it('skips without creds', () => {
      delete process.env.FIREBASE_PROJECT_ID;
      delete process.env.FIREBASE_PRIVATE_KEY;
      delete process.env.FIREBASE_CLIENT_EMAIL;
      service.onModuleInit();
      expect((admin.initializeApp as any)).not.toHaveBeenCalled();
      expect(service.isInitialized()).toBe(false);
    });
    it('handles newline replacement', () => {
      process.env.FIREBASE_PROJECT_ID = 'p';
      process.env.FIREBASE_PRIVATE_KEY = 'a\\nb';
      process.env.FIREBASE_CLIENT_EMAIL = 'e@x.com';
      service.onModuleInit();
      expect((admin.credential.cert as any)).toHaveBeenCalledWith({ projectId: 'p', privateKey: 'a\nb', clientEmail: 'e@x.com' });
    });
  });

  describe('sendPushNotification', () => {
    beforeEach(() => { (service as any).app = { name: 'p' }; });
    it('sends', async () => {
      mockSend.mockResolvedValue('m1');
      const res = await service.sendPushNotification({ token: 't', title: 'T', body: 'B', data: { x: 'y' } });
      expect(res).toEqual({ success: true, messageId: 'm1' });
    });
    it('not initialized', async () => {
      (service as any).app = null;
      const res = await service.sendPushNotification({ token: 't', title: 'T', body: 'B' });
      expect(res.success).toBe(false);
    });
    it('invalid token', async () => {
      mockSend.mockRejectedValue({ code: 'messaging/invalid-registration-token', message: 'bad' });
      const res = await service.sendPushNotification({ token: 'bad', title: 'T', body: 'B' });
      expect(res).toEqual({ success: false, error: 'Invalid FCM token' });
    });
    it('unregistered token', async () => {
      mockSend.mockRejectedValue({ code: 'messaging/registration-token-not-registered', message: 'gone' });
      const res = await service.sendPushNotification({ token: 'gone', title: 'T', body: 'B' });
      expect(res).toEqual({ success: false, error: 'Invalid FCM token' });
    });
    it('retry then success', async () => {
      mockSend.mockRejectedValueOnce({ code: 'messaging/server-unavailable', message: 'tmp' }).mockResolvedValueOnce('m2');
      const res = await service.sendPushNotification({ token: 't', title: 'T', body: 'B' }, 2);
      expect(res).toEqual({ success: true, messageId: 'm2' });
      expect(mockSend).toHaveBeenCalledTimes(2);
    });
    it('max retries error', async () => {
      mockSend.mockRejectedValue({ code: 'messaging/server-unavailable', message: 'down' });
      const res = await service.sendPushNotification({ token: 't', title: 'T', body: 'B' }, 1);
      expect(res).toEqual({ success: false, error: 'down' });
    });
  });

  describe('batch', () => {
    beforeEach(() => { (service as any).app = { name: 'p' }; });
    it('batch success', async () => {
      mockSend.mockResolvedValueOnce('m1').mockResolvedValueOnce('m2');
      const res = await service.sendBatchPushNotifications(['t1','t2'],'T','B');
      expect(res.length).toBe(2);
      expect(res[0].success).toBe(true);
    });
    it('batch mixed', async () => {
      mockSend.mockResolvedValueOnce('m1').mockRejectedValueOnce({ code: 'messaging/invalid-registration-token', message: 'bad' });
      const res = await service.sendBatchPushNotifications(['t1','bad'],'T','B');
      expect(res[1].success).toBe(false);
    });
    it('empty tokens', async () => {
      const res = await service.sendBatchPushNotifications([],'T','B');
      expect(res).toEqual([]);
    });
  });

  describe('isInitialized', () => {
    it('true if app set', () => { (service as any).app = { name: 'p' }; expect(service.isInitialized()).toBe(true); });
    it('false if app null', () => { (service as any).app = null; expect(service.isInitialized()).toBe(false); });
  });
});
