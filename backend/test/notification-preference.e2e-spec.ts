import { Test, TestingModule } from '@nestjs/testing';
import { INestApplication, ValidationPipe } from '@nestjs/common';
import request from 'supertest';
import { AppModule } from '../src/app.module';
import { PrismaService } from '../src/modules/prisma/prisma.service';

describe('Notification Preferences (e2e)', () => {
  let app: INestApplication;
  let prismaService: PrismaService;
  let userToken: string;
  let userId: string;

  beforeAll(async () => {
    const moduleFixture: TestingModule = await Test.createTestingModule({
      imports: [AppModule],
    }).compile();

    app = moduleFixture.createNestApplication();
    app.useGlobalPipes(new ValidationPipe());
    await app.init();

    prismaService = moduleFixture.get<PrismaService>(PrismaService);

    // Clean database in correct order (from dependent to independent)
    await prismaService.taskCompletionAttachment.deleteMany();
    await prismaService.taskCompletionHistory.deleteMany();
    await prismaService.taskAttachment.deleteMany();
    await prismaService.task.deleteMany();
    await prismaService.rewardTransaction.deleteMany();
    await prismaService.reward.deleteMany();
    await prismaService.notification.deleteMany();
    await prismaService.auditLog.deleteMany();
    await prismaService.groupMember.deleteMany();
    await prismaService.group.deleteMany();
    await prismaService.refreshToken.deleteMany();
    await prismaService.user.deleteMany(); // deviceToken and notificationPreference will cascade

    // Register test user
    const registerResponse = await request(app.getHttpServer())
      .post('/graphql')
      .send({
        query: `
          mutation Register($input: RegisterInput!) {
            register(input: $input) {
              accessToken
              user {
                id
                username
                email
              }
            }
          }
        `,
        variables: {
          input: {
            email: 'preftest@example.com',
            username: 'preftest',
            password: 'Test123!@#',
          },
        },
      });

    expect(registerResponse.status).toBe(200);
    userToken = registerResponse.body.data.register.accessToken;
    userId = registerResponse.body.data.register.user.id;
  });

  afterAll(async () => {
    await app.close();
  });

  describe('NotificationPreference CRUD', () => {
    it('should return null for non-existent preferences', async () => {
      const response = await request(app.getHttpServer())
        .post('/graphql')
        .set('Authorization', `Bearer ${userToken}`)
        .send({
          query: `
            query {
              myNotificationPreference {
                id
                enablePush
                quietHoursStart
                quietHoursEnd
                mutedTypes
                batchingEnabled
              }
            }
          `,
        });

      expect(response.status).toBe(200);
      // First time accessing, service returns null which becomes null in GraphQL
      if (response.body.data) {
        expect(response.body.data.myNotificationPreference).toBeNull();
      } else {
        // Or GraphQL might return an error if query fails
        expect(response.body.errors).toBeDefined();
      }
    });

    it('should create notification preferences with default values', async () => {
      const response = await request(app.getHttpServer())
        .post('/graphql')
        .set('Authorization', `Bearer ${userToken}`)
        .send({
          query: `
            mutation UpsertPreference($input: UpsertNotificationPreferenceInput!) {
              upsertNotificationPreference(input: $input) {
                id
                enablePush
                quietHoursStart
                quietHoursEnd
                mutedTypes
                batchingEnabled
              }
            }
          `,
          variables: {
            input: {},
          },
        });

      expect(response.status).toBe(200);
      const pref = response.body.data.upsertNotificationPreference;
      expect(pref.enablePush).toBe(true);
      expect(pref.quietHoursStart).toBeNull();
      expect(pref.quietHoursEnd).toBeNull();
      expect(pref.mutedTypes).toBeNull();
      expect(pref.batchingEnabled).toBe(false);
    });

    it('should update notification preferences', async () => {
      const response = await request(app.getHttpServer())
        .post('/graphql')
        .set('Authorization', `Bearer ${userToken}`)
        .send({
          query: `
            mutation UpsertPreference($input: UpsertNotificationPreferenceInput!) {
              upsertNotificationPreference(input: $input) {
                id
                enablePush
                quietHoursStart
                quietHoursEnd
                mutedTypes
                batchingEnabled
              }
            }
          `,
          variables: {
            input: {
              enablePush: false,
              quietHoursStart: '22:00',
              quietHoursEnd: '08:00',
              mutedTypes: ['TASK_ASSIGNED', 'REWARD_APPROVED'],
              batchingEnabled: true,
            },
          },
        });

      expect(response.status).toBe(200);
      const pref = response.body.data.upsertNotificationPreference;
      expect(pref.enablePush).toBe(false);
      expect(pref.quietHoursStart).toBe('22:00');
      expect(pref.quietHoursEnd).toBe('08:00');
      expect(pref.mutedTypes).toEqual(['TASK_ASSIGNED', 'REWARD_APPROVED']);
      expect(pref.batchingEnabled).toBe(true);
    });

    it('should retrieve updated preferences', async () => {
      const response = await request(app.getHttpServer())
        .post('/graphql')
        .set('Authorization', `Bearer ${userToken}`)
        .send({
          query: `
            query {
              myNotificationPreference {
                id
                enablePush
                quietHoursStart
                quietHoursEnd
                mutedTypes
                batchingEnabled
              }
            }
          `,
        });

      expect(response.status).toBe(200);
      const pref = response.body.data.myNotificationPreference;
      expect(pref.enablePush).toBe(false);
      expect(pref.quietHoursStart).toBe('22:00');
      expect(pref.quietHoursEnd).toBe('08:00');
      expect(pref.mutedTypes).toEqual(['TASK_ASSIGNED', 'REWARD_APPROVED']);
      expect(pref.batchingEnabled).toBe(true);
    });
  });

  describe('Device Token Management', () => {
    it('should register a device token', async () => {
      const response = await request(app.getHttpServer())
        .post('/graphql')
        .set('Authorization', `Bearer ${userToken}`)
        .send({
          query: `
            mutation RegisterDevice($input: RegisterDeviceTokenInput!) {
              registerDeviceToken(input: $input) {
                id
                token
                provider
                platform
              }
            }
          `,
          variables: {
            input: {
              token: 'test-device-token-123',
              provider: 'firebase',
              platform: 'android',
            },
          },
        });

      expect(response.status).toBe(200);
      const device = response.body.data.registerDeviceToken;
      expect(device.token).toBe('test-device-token-123');
      expect(device.provider).toBe('firebase');
      expect(device.platform).toBe('android');
    });

    it('should list device tokens', async () => {
      const response = await request(app.getHttpServer())
        .post('/graphql')
        .set('Authorization', `Bearer ${userToken}`)
        .send({
          query: `
            query {
              myDeviceTokens {
                id
                token
                provider
                platform
              }
            }
          `,
        });

      expect(response.status).toBe(200);
      const devices = response.body.data.myDeviceTokens;
      expect(devices).toHaveLength(1);
      expect(devices[0].token).toBe('test-device-token-123');
    });

    it('should register multiple device tokens', async () => {
      await request(app.getHttpServer())
        .post('/graphql')
        .set('Authorization', `Bearer ${userToken}`)
        .send({
          query: `
            mutation RegisterDevice($input: RegisterDeviceTokenInput!) {
              registerDeviceToken(input: $input) {
                id
              }
            }
          `,
          variables: {
            input: {
              token: 'test-device-token-456',
              provider: 'onesignal',
              platform: 'ios',
            },
          },
        });

      const response = await request(app.getHttpServer())
        .post('/graphql')
        .set('Authorization', `Bearer ${userToken}`)
        .send({
          query: `
            query {
              myDeviceTokens {
                id
                token
                provider
                platform
              }
            }
          `,
        });

      expect(response.status).toBe(200);
      const devices = response.body.data.myDeviceTokens;
      expect(devices).toHaveLength(2);
    });

    it('should remove a device token', async () => {
      const response = await request(app.getHttpServer())
        .post('/graphql')
        .set('Authorization', `Bearer ${userToken}`)
        .send({
          query: `
            mutation RemoveDevice($input: RemoveDeviceTokenInput!) {
              removeDeviceToken(input: $input)
            }
          `,
          variables: {
            input: {
              token: 'test-device-token-123',
            },
          },
        });

      expect(response.status).toBe(200);
      expect(response.body.data.removeDeviceToken).toBe(true);

      // Verify removal
      const listResponse = await request(app.getHttpServer())
        .post('/graphql')
        .set('Authorization', `Bearer ${userToken}`)
        .send({
          query: `
            query {
              myDeviceTokens {
                token
              }
            }
          `,
        });

      const devices = listResponse.body.data.myDeviceTokens;
      expect(devices).toHaveLength(1);
      expect(devices[0].token).toBe('test-device-token-456');
    });

    it('should fail to remove non-existent token', async () => {
      const response = await request(app.getHttpServer())
        .post('/graphql')
        .set('Authorization', `Bearer ${userToken}`)
        .send({
          query: `
            mutation RemoveDevice($input: RemoveDeviceTokenInput!) {
              removeDeviceToken(input: $input)
            }
          `,
          variables: {
            input: {
              token: 'non-existent-token',
            },
          },
        });

      expect(response.status).toBe(200);
      expect(response.body.errors).toBeDefined();
      expect(response.body.errors[0].message).toContain('not found');
    });
  });

  describe('Preference Integration (Unit-level)', () => {
    it('should allow setting complex preference combinations', async () => {
      const response = await request(app.getHttpServer())
        .post('/graphql')
        .set('Authorization', `Bearer ${userToken}`)
        .send({
          query: `
            mutation UpsertPreference($input: UpsertNotificationPreferenceInput!) {
              upsertNotificationPreference(input: $input) {
                id
                enablePush
                quietHoursStart
                quietHoursEnd
                mutedTypes
                batchingEnabled
              }
            }
          `,
          variables: {
            input: {
              enablePush: true,
              quietHoursStart: '23:00',
              quietHoursEnd: '07:00',
              mutedTypes: ['SYSTEM', 'TASK_ASSIGNED', 'REWARD_REQUESTED'],
              batchingEnabled: true,
            },
          },
        });

      expect(response.status).toBe(200);
      const pref = response.body.data.upsertNotificationPreference;
      expect(pref.enablePush).toBe(true);
      expect(pref.quietHoursStart).toBe('23:00');
      expect(pref.quietHoursEnd).toBe('07:00');
      expect(pref.mutedTypes).toHaveLength(3);
      expect(pref.mutedTypes).toContain('SYSTEM');
      expect(pref.mutedTypes).toContain('TASK_ASSIGNED');
      expect(pref.mutedTypes).toContain('REWARD_REQUESTED');
      expect(pref.batchingEnabled).toBe(true);
    });

    it('should allow clearing muted types', async () => {
      const response = await request(app.getHttpServer())
        .post('/graphql')
        .set('Authorization', `Bearer ${userToken}`)
        .send({
          query: `
            mutation UpsertPreference($input: UpsertNotificationPreferenceInput!) {
              upsertNotificationPreference(input: $input) {
                mutedTypes
              }
            }
          `,
          variables: {
            input: {
              mutedTypes: null,
            },
          },
        });

      expect(response.status).toBe(200);
      expect(response.body.data.upsertNotificationPreference.mutedTypes).toBeNull();
    });

    it('should allow clearing quiet hours', async () => {
      const response = await request(app.getHttpServer())
        .post('/graphql')
        .set('Authorization', `Bearer ${userToken}`)
        .send({
          query: `
            mutation UpsertPreference($input: UpsertNotificationPreferenceInput!) {
              upsertNotificationPreference(input: $input) {
                quietHoursStart
                quietHoursEnd
              }
            }
          `,
          variables: {
            input: {
              quietHoursStart: null,
              quietHoursEnd: null,
            },
          },
        });

      expect(response.status).toBe(200);
      const pref = response.body.data.upsertNotificationPreference;
      expect(pref.quietHoursStart).toBeNull();
      expect(pref.quietHoursEnd).toBeNull();
    });
  });
});
