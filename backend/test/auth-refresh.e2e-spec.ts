import { Test, TestingModule } from '@nestjs/testing';
import { INestApplication } from '@nestjs/common';
import request from 'supertest';
import { AppModule } from '../src/app.module';
import { PrismaService } from '../src/modules/prisma/prisma.service';

describe('Auth - Refresh Token Flow (e2e)', () => {
  let app: INestApplication;
  let prisma: PrismaService;

  beforeAll(async () => {
    const moduleFixture: TestingModule = await Test.createTestingModule({
      imports: [AppModule],
    }).compile();

    app = moduleFixture.createNestApplication();
    prisma = app.get<PrismaService>(PrismaService);
    await app.init();
  });

  afterAll(async () => {
    // Очистка тестовых данных (в правильном порядке из-за FK constraints)
    await prisma.user.deleteMany({
      where: {
        email: {
          contains: 'test-refresh'
        }
      }
    });
    await app.close();
  });

  describe('Register and Login with Refresh Tokens', () => {
    const testUser = {
      email: 'test-refresh@example.com',
      username: 'test-refresh-user',
      password: 'password123',
    };

    let accessToken: string;
    let refreshToken: string;

    it('should register a new user and return tokens', () => {
      const registerMutation = `
        mutation {
          register(input: {
            email: "${testUser.email}"
            username: "${testUser.username}"
            password: "${testUser.password}"
          }) {
            accessToken
            refreshToken
            user {
              id
              email
              username
            }
          }
        }
      `;

      return request(app.getHttpServer())
        .post('/graphql')
        .send({ query: registerMutation })
        .expect(200)
        .expect((res) => {
          if (res.body.errors) {
            console.error('GraphQL Errors:', JSON.stringify(res.body.errors, null, 2));
          }
          expect(res.body.data).toBeDefined();
          expect(res.body.data.register).toBeDefined();
          expect(res.body.data.register.accessToken).toBeDefined();
          expect(res.body.data.register.refreshToken).toBeDefined();
          expect(res.body.data.register.user.email).toBe(testUser.email);
          
          // Сохраняем токены для следующих тестов
          accessToken = res.body.data.register.accessToken;
          refreshToken = res.body.data.register.refreshToken;
        });
    });

    it('should access protected route with access token', () => {
      const meQuery = `
        query {
          me {
            id
            email
            username
          }
        }
      `;

      return request(app.getHttpServer())
        .post('/graphql')
        .set('Authorization', `Bearer ${accessToken}`)
        .send({ query: meQuery })
        .expect(200)
        .expect((res) => {
          expect(res.body.data.me).toBeDefined();
          expect(res.body.data.me.email).toBe(testUser.email);
        });
    });

    it('should refresh access token with valid refresh token', () => {
      const refreshMutation = `
        mutation {
          refreshToken(input: {
            refreshToken: "${refreshToken}"
          }) {
            accessToken
            refreshToken
            user {
              id
              email
            }
          }
        }
      `;

      return request(app.getHttpServer())
        .post('/graphql')
        .send({ query: refreshMutation })
        .expect(200)
        .expect((res) => {
          expect(res.body.data.refreshToken).toBeDefined();
          expect(res.body.data.refreshToken.accessToken).toBeDefined();
          expect(res.body.data.refreshToken.refreshToken).toBeDefined();
          
          // Новый refresh token должен отличаться от старого (rotation)
          expect(res.body.data.refreshToken.refreshToken).not.toBe(refreshToken);
          
          // Обновляем токены
          accessToken = res.body.data.refreshToken.accessToken;
          refreshToken = res.body.data.refreshToken.refreshToken;
        });
    });

    it('should fail to use old refresh token after rotation', () => {
      // Сначала получаем новую пару токенов
      const refreshMutation1 = `
        mutation {
          refreshToken(input: {
            refreshToken: "${refreshToken}"
          }) {
            accessToken
            refreshToken
          }
        }
      `;

      return request(app.getHttpServer())
        .post('/graphql')
        .send({ query: refreshMutation1 })
        .expect(200)
        .then((res) => {
          const oldRefreshToken = refreshToken;
          refreshToken = res.body.data.refreshToken.refreshToken;

          // Пытаемся использовать старый токен
          const refreshMutation2 = `
            mutation {
              refreshToken(input: {
                refreshToken: "${oldRefreshToken}"
              }) {
                accessToken
              }
            }
          `;

          return request(app.getHttpServer())
            .post('/graphql')
            .send({ query: refreshMutation2 })
            .expect(200)
            .expect((res) => {
              expect(res.body.errors).toBeDefined();
              expect(res.body.errors[0].message).toContain('Invalid or expired refresh token');
            });
        });
    });

    it('should logout (revoke refresh token)', () => {
      const logoutMutation = `
        mutation {
          logout(refreshToken: "${refreshToken}")
        }
      `;

      return request(app.getHttpServer())
        .post('/graphql')
        .send({ query: logoutMutation })
        .expect(200)
        .expect((res) => {
          expect(res.body.data.logout).toBe(true);
        });
    });

    it('should fail to refresh with revoked token', () => {
      const refreshMutation = `
        mutation {
          refreshToken(input: {
            refreshToken: "${refreshToken}"
          }) {
            accessToken
          }
        }
      `;

      return request(app.getHttpServer())
        .post('/graphql')
        .send({ query: refreshMutation })
        .expect(200)
        .expect((res) => {
          expect(res.body.errors).toBeDefined();
          expect(res.body.errors[0].message).toContain('Invalid or expired refresh token');
        });
    });

    it('should login again and get new tokens', () => {
      const loginMutation = `
        mutation {
          login(input: {
            email: "${testUser.email}"
            password: "${testUser.password}"
          }) {
            accessToken
            refreshToken
            user {
              email
            }
          }
        }
      `;

      return request(app.getHttpServer())
        .post('/graphql')
        .send({ query: loginMutation })
        .expect(200)
        .expect((res) => {
          expect(res.body.data.login).toBeDefined();
          expect(res.body.data.login.accessToken).toBeDefined();
          expect(res.body.data.login.refreshToken).toBeDefined();
          
          accessToken = res.body.data.login.accessToken;
          refreshToken = res.body.data.login.refreshToken;
        });
    });

    it('should logout from all devices', () => {
      const logoutAllMutation = `
        mutation {
          logoutAll
        }
      `;

      return request(app.getHttpServer())
        .post('/graphql')
        .set('Authorization', `Bearer ${accessToken}`)
        .send({ query: logoutAllMutation })
        .expect(200)
        .expect((res) => {
          expect(res.body.data.logoutAll).toBeGreaterThan(0);
        });
    });

    it('should fail to refresh after logoutAll', () => {
      const refreshMutation = `
        mutation {
          refreshToken(input: {
            refreshToken: "${refreshToken}"
          }) {
            accessToken
          }
        }
      `;

      return request(app.getHttpServer())
        .post('/graphql')
        .send({ query: refreshMutation })
        .expect(200)
        .expect((res) => {
          expect(res.body.errors).toBeDefined();
          expect(res.body.errors[0].message).toContain('Invalid or expired refresh token');
        });
    });
  });

  describe('Edge Cases', () => {
    it('should fail with invalid refresh token format', () => {
      const refreshMutation = `
        mutation {
          refreshToken(input: {
            refreshToken: "invalid-token-format"
          }) {
            accessToken
          }
        }
      `;

      return request(app.getHttpServer())
        .post('/graphql')
        .send({ query: refreshMutation })
        .expect(200)
        .expect((res) => {
          expect(res.body.errors).toBeDefined();
          expect(res.body.errors[0].message).toContain('Invalid or expired refresh token');
        });
    });

    it('should fail with empty refresh token', () => {
      const refreshMutation = `
        mutation {
          refreshToken(input: {
            refreshToken: ""
          }) {
            accessToken
          }
        }
      `;

      return request(app.getHttpServer())
        .post('/graphql')
        .send({ query: refreshMutation })
        .expect(200)
        .expect((res) => {
          // GraphQL возвращает 200 с ошибкой валидации в body
          expect(res.body.errors).toBeDefined();
        });
    });
  });
});
