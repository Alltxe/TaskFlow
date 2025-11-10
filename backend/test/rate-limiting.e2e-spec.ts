/**
 * Rate Limiting E2E Tests
 * 
 * Tests user-based and IP-based rate limiting functionality
 * 
 * NOTE: These tests require NODE_ENV=production to enable rate limiting
 * Run with: NODE_ENV=production npm run test:e2e -- rate-limiting.e2e-spec.ts
 */

import { Test, TestingModule } from '@nestjs/testing';
import { INestApplication, ValidationPipe } from '@nestjs/common';
import request from 'supertest';
import { AppModule } from './../src/app.module';
import { PrismaService } from '../src/modules/prisma/prisma.service';
import { AllExceptionsFilter } from '../src/common/filters/all-exceptions.filter';

describe('Rate Limiting (e2e)', () => {
  let app: INestApplication;
  let prisma: PrismaService;
  let user1Token: string;
  let user2Token: string;

  beforeAll(async () => {
    const moduleFixture: TestingModule = await Test.createTestingModule({
      imports: [AppModule],
    }).compile();

    app = moduleFixture.createNestApplication();
    prisma = app.get<PrismaService>(PrismaService);

    // Apply same configuration as main.ts
    app.useGlobalPipes(
      new ValidationPipe({
        whitelist: true,
        forbidNonWhitelisted: true,
        transform: true,
      }),
    );
    app.useGlobalFilters(new AllExceptionsFilter());

    await app.init();

    // Clean database
    await prisma.cleanDatabase();

    // Register two users for testing
    const user1Response = await request(app.getHttpServer())
      .post('/graphql')
      .send({
        query: `
          mutation {
            register(input: {
              username: "user1_ratelimit"
              email: "user1_ratelimit@example.com"
              password: "Password123!"
            }) {
              accessToken
            }
          }
        `,
      });

    const user2Response = await request(app.getHttpServer())
      .post('/graphql')
      .send({
        query: `
          mutation {
            register(input: {
              username: "user2_ratelimit"
              email: "user2_ratelimit@example.com"
              password: "Password123!"
            }) {
              accessToken
            }
          }
        `,
      });

    user1Token = user1Response.body.data.register.accessToken;
    user2Token = user2Response.body.data.register.accessToken;
  });

  afterAll(async () => {
    await prisma.cleanDatabase();
    await app.close();
  });

  describe('User-Based Rate Limiting', () => {
    it('should rate limit per user ID (not shared between users)', async () => {
      // Skip test if not in production mode (rate limiting disabled)
      if (process.env.NODE_ENV !== 'production') {
        console.log('⏭️  Skipping rate limit test (not in production mode)');
        return;
      }

      // User 1 makes 100 requests (should succeed)
      const user1Query = `
        query {
          me {
            id
            username
          }
        }
      `;

      let user1Success = 0;
      for (let i = 0; i < 100; i++) {
        const response = await request(app.getHttpServer())
          .post('/graphql')
          .set('Authorization', `Bearer ${user1Token}`)
          .send({ query: user1Query });

        if (response.status === 200) {
          user1Success++;
        }
      }

      expect(user1Success).toBe(100); // All 100 should succeed

      // User 1's 101st request should be rate limited
      const user1Blocked = await request(app.getHttpServer())
        .post('/graphql')
        .set('Authorization', `Bearer ${user1Token}`)
        .send({ query: user1Query });

      expect(user1Blocked.status).toBe(200);
      expect(user1Blocked.body.errors).toBeDefined();
      expect(user1Blocked.body.errors[0].extensions.code).toBe('TOO_MANY_REQUESTS');

      // User 2 should still have full limit (separate bucket)
      const user2Response = await request(app.getHttpServer())
        .post('/graphql')
        .set('Authorization', `Bearer ${user2Token}`)
        .send({ query: user1Query });

      expect(user2Response.status).toBe(200);
      expect(user2Response.body.data.me).toBeDefined();
      expect(user2Response.body.data.me.username).toBe('user2_ratelimit');
    }, 120000); // Increase timeout for 100+ requests
  });

  describe('IP-Based Rate Limiting (Unauthenticated)', () => {
    it('should rate limit unauthenticated requests by IP', async () => {
      // Skip test if not in production mode
      if (process.env.NODE_ENV !== 'production') {
        console.log('⏭️  Skipping rate limit test (not in production mode)');
        return;
      }

      // Make 5 login attempts (auth limit is 5/min)
      const loginMutation = `
        mutation {
          login(input: {
            email: "user1_ratelimit@example.com"
            password: "Password123!"
          }) {
            accessToken
          }
        }
      `;

      let loginSuccess = 0;
      for (let i = 0; i < 5; i++) {
        const response = await request(app.getHttpServer())
          .post('/graphql')
          .send({ query: loginMutation });

        if (response.status === 200 && !response.body.errors) {
          loginSuccess++;
        }
      }

      expect(loginSuccess).toBe(5); // All 5 should succeed

      // 6th login attempt should be rate limited
      const blockedLogin = await request(app.getHttpServer())
        .post('/graphql')
        .send({ query: loginMutation });

      expect(blockedLogin.status).toBe(200);
      expect(blockedLogin.body.errors).toBeDefined();
      expect(blockedLogin.body.errors[0].extensions.code).toBe('TOO_MANY_REQUESTS');
    }, 60000);
  });

  describe('Rate Limiting Documentation', () => {
    it('should return clear error message when rate limited', async () => {
      // Skip test if not in production mode
      if (process.env.NODE_ENV !== 'production') {
        console.log('⏭️  Skipping rate limit test (not in production mode)');
        return;
      }

      // Exhaust user 2's rate limit
      const query = `
        query {
          me {
            id
          }
        }
      `;

      for (let i = 0; i < 100; i++) {
        await request(app.getHttpServer())
          .post('/graphql')
          .set('Authorization', `Bearer ${user2Token}`)
          .send({ query });
      }

      // Next request should be blocked with clear message
      const blocked = await request(app.getHttpServer())
        .post('/graphql')
        .set('Authorization', `Bearer ${user2Token}`)
        .send({ query });

      expect(blocked.body.errors).toBeDefined();
      expect(blocked.body.errors[0].message).toBe('ThrottlerException: Too Many Requests');
      expect(blocked.body.errors[0].extensions.code).toBe('TOO_MANY_REQUESTS');
      expect(blocked.body.errors[0].extensions.originalError.statusCode).toBe(429);
    }, 120000);
  });
});
