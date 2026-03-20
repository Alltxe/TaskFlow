import { Test, TestingModule } from '@nestjs/testing';
import { INestApplication, ValidationPipe } from '@nestjs/common';
import request from 'supertest';
import { AppModule } from '../src/app.module';
import { PrismaService } from '../src/modules/prisma/prisma.service';
import { FirebaseService } from '../src/modules/firebase/firebase.service';

describe('sendTestPush mutation (e2e)', () => {
  let app: INestApplication;
  let prisma: PrismaService;
  let accessToken: string;

  beforeAll(async () => {
    const firebaseMock: Partial<FirebaseService> = {
      isInitialized: () => true,
      sendBatchPushNotifications: async (tokens: string[]) =>
        tokens.map((_, idx) => ({ success: true, messageId: `mock-${idx + 1}` })),
    };

    const moduleFixture: TestingModule = await Test.createTestingModule({ imports: [AppModule] })
      .overrideProvider(FirebaseService)
      .useValue(firebaseMock)
      .compile();

    app = moduleFixture.createNestApplication();
    app.useGlobalPipes(new ValidationPipe());
    await app.init();

    prisma = moduleFixture.get<PrismaService>(PrismaService);

    // Cleanup potentially conflicting data
    await prisma.notification.deleteMany();
    await prisma.deviceToken.deleteMany();
    await prisma.notificationPreference.deleteMany();
    await prisma.taskCompletionAttachment.deleteMany();
    await prisma.taskCompletionHistory.deleteMany();
    await prisma.taskAttachment.deleteMany();
    await prisma.task.deleteMany();
    await prisma.rewardTransaction.deleteMany();
    await prisma.reward.deleteMany();
    await prisma.groupMember.deleteMany();
    await prisma.group.deleteMany();
    await prisma.refreshToken.deleteMany();
    await prisma.user.deleteMany();

    // Register a user
    const reg = await request(app.getHttpServer())
      .post('/graphql')
      .send({ query: `mutation { register(input: { email: "push@test.com", username: "pushuser", password: "Test123!" }) { accessToken } }` });
    accessToken = reg.body.data.register.accessToken;

    // Enable push in preferences
    await request(app.getHttpServer())
      .post('/graphql')
      .set('Authorization', `Bearer ${accessToken}`)
      .send({ query: `mutation { upsertNotificationPreference(input: { enablePush: true }) { enablePush } }` });

    // Register a device token (valid FCM token format to avoid SDK validation errors)
    // Note: This is a syntactically valid token but not registered with FCM, so actual send will fail gracefully
    const validFcmTokenFormat = 'dGVzdC10b2tlbi1mb3ItZTJlLXRlc3RpbmctcHVycG9zZXMtb25seS0xMjM0NTY3ODkwYWJjZGVmZ2hpamtsbW5vcHFyc3R1dnd4eXpBQkNERUZHSElKS0xNTk9QUVJTVFVWV1hZWjAxMjM0NTY3ODk';
    await request(app.getHttpServer())
      .post('/graphql')
      .set('Authorization', `Bearer ${accessToken}`)
      .send({ query: `mutation { registerDeviceToken(input: { token: "${validFcmTokenFormat}", provider: "fcm", platform: "ios" }) { id token } }` });
  });

  afterAll(async () => {
    await prisma.notification.deleteMany();
    await prisma.deviceToken.deleteMany();
    await prisma.notificationPreference.deleteMany();
    await prisma.taskCompletionAttachment.deleteMany();
    await prisma.taskCompletionHistory.deleteMany();
    await prisma.taskAttachment.deleteMany();
    await prisma.task.deleteMany();
    await prisma.rewardTransaction.deleteMany();
    await prisma.reward.deleteMany();
    await prisma.groupMember.deleteMany();
    await prisma.group.deleteMany();
    await prisma.refreshToken.deleteMany();
    await prisma.user.deleteMany();
    await app.close();
  });

  it('returns successful results for my devices', async () => {
    const res = await request(app.getHttpServer())
      .post('/graphql')
      .set('Authorization', `Bearer ${accessToken}`)
      .send({ query: `mutation { sendTestPush(input: { title: "Hi", body: "There", data: { a: "b" } }) { success messageId error } }` });

    expect(res.body.errors).toBeUndefined();
    const results = res.body.data.sendTestPush as Array<{ success: boolean; messageId?: string }>;
    expect(Array.isArray(results)).toBe(true);
    expect(results.length).toBeGreaterThan(0);
    expect(results.every((r) => r.success)).toBe(true);
    expect(results[0].messageId).toMatch(/^mock-/);
  });
});
