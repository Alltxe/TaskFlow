/**
 * E2E tests for new BACKEND_API_REQUIREMENTS.md features
 * Tests Critical and Important APIs from Phase 5-8
 */
import { Test, TestingModule } from '@nestjs/testing';
import { INestApplication } from '@nestjs/common';
import request from 'supertest';
import { AppModule } from '../src/app.module';

describe('Backend API Requirements - Critical Features (e2e)', () => {
  let app: INestApplication;
  let accessToken: string;
  let userId: string;
  let groupId: string;

  beforeAll(async () => {
    const moduleFixture: TestingModule = await Test.createTestingModule({
      imports: [AppModule],
    }).compile();

    app = moduleFixture.createNestApplication();
    await app.init();

    // Register test user with unique email (using timestamp)
    const timestamp = Date.now();
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
            email: `backend-api-test-${timestamp}@example.com`,
            username: `backend_api_test_${timestamp}`,
            password: 'TestPassword123!',
          },
        },
      });

    accessToken = registerResponse.body.data.register.accessToken;
    userId = registerResponse.body.data.register.user.id;

    // Create test group
    const createGroupResponse = await request(app.getHttpServer())
      .post('/graphql')
      .set('Authorization', `Bearer ${accessToken}`)
      .send({
        query: `
          mutation CreateGroup($input: CreateGroupInput!) {
            createGroup(input: $input) {
              id
              name
            }
          }
        `,
        variables: {
          input: {
            name: 'Backend API Test Group',
            requiresApproval: true,
            rotationType: 'ROUND_ROBIN',
            gamificationEnabled: true,
          },
        },
      });

    groupId = createGroupResponse.body.data.createGroup.id;
  });

  afterAll(async () => {
    await app.close();
  });

  describe('User Profile Management', () => {
    it('should update user profile (updateUser mutation)', async () => {
      const response = await request(app.getHttpServer())
        .post('/graphql')
        .set('Authorization', `Bearer ${accessToken}`)
        .send({
          query: `
            mutation UpdateUser($input: UpdateUserInput!) {
              updateUser(input: $input) {
                id
                username
                avatarUrl
              }
            }
          `,
          variables: {
            input: {
              username: 'updated_username',
              avatarUrl: 'https://example.com/avatar.jpg',
            },
          },
        });

      expect(response.status).toBe(200);
      expect(response.body.errors).toBeUndefined();
      expect(response.body.data.updateUser.username).toBe('updated_username');
      expect(response.body.data.updateUser.avatarUrl).toBe(
        'https://example.com/avatar.jpg',
      );
    });

    it('should reject duplicate username when updating', async () => {
      // Create another user
      const register2 = await request(app.getHttpServer())
        .post('/graphql')
        .send({
          query: `
            mutation Register($input: RegisterInput!) {
              register(input: $input) {
                accessToken
              }
            }
          `,
          variables: {
            input: {
              email: 'duplicate-test@example.com',
              username: 'duplicate_user',
              password: 'TestPassword123!',
            },
          },
        });

      const token2 = register2.body.data.register.accessToken;

      // Try to update to existing username
      const response = await request(app.getHttpServer())
        .post('/graphql')
        .set('Authorization', `Bearer ${token2}`)
        .send({
          query: `
            mutation UpdateUser($input: UpdateUserInput!) {
              updateUser(input: $input) {
                id
                username
              }
            }
          `,
          variables: {
            input: {
              username: 'updated_username',
            },
          },
        });

      expect(response.body.errors).toBeDefined();
      expect(response.body.errors[0].message).toContain('Username already taken');
    });

    it('should set user away status (setUserAwayStatus mutation)', async () => {
      const futureDate = new Date();
      futureDate.setDate(futureDate.getDate() + 7); // 7 days from now

      const response = await request(app.getHttpServer())
        .post('/graphql')
        .set('Authorization', `Bearer ${accessToken}`)
        .send({
          query: `
            mutation SetAwayStatus($input: SetAwayStatusInput!) {
              setUserAwayStatus(input: $input) {
                id
                isAway
                awayUntil
              }
            }
          `,
          variables: {
            input: {
              isAway: true,
              awayUntil: futureDate.toISOString(),
            },
          },
        });

      expect(response.status).toBe(200);
      expect(response.body.errors).toBeUndefined();
      expect(response.body.data.setUserAwayStatus.isAway).toBe(true);
      expect(response.body.data.setUserAwayStatus.awayUntil).toBeDefined();
    });

    it('should reject awayUntil in the past', async () => {
      const pastDate = new Date();
      pastDate.setDate(pastDate.getDate() - 1); // Yesterday

      const response = await request(app.getHttpServer())
        .post('/graphql')
        .set('Authorization', `Bearer ${accessToken}`)
        .send({
          query: `
            mutation SetAwayStatus($input: SetAwayStatusInput!) {
              setUserAwayStatus(input: $input) {
                id
                isAway
              }
            }
          `,
          variables: {
            input: {
              isAway: true,
              awayUntil: pastDate.toISOString(),
            },
          },
        });

      expect(response.body.errors).toBeDefined();
      expect(response.body.errors[0].message).toContain('must be a future date');
    });

    it('should clear away status', async () => {
      const response = await request(app.getHttpServer())
        .post('/graphql')
        .set('Authorization', `Bearer ${accessToken}`)
        .send({
          query: `
            mutation SetAwayStatus($input: SetAwayStatusInput!) {
              setUserAwayStatus(input: $input) {
                id
                isAway
                awayUntil
              }
            }
          `,
          variables: {
            input: {
              isAway: false,
            },
          },
        });

      expect(response.status).toBe(200);
      expect(response.body.data.setUserAwayStatus.isAway).toBe(false);
      expect(response.body.data.setUserAwayStatus.awayUntil).toBeNull();
    });
  });

  describe('Rotation API', () => {
    it('should get rotation schedule (getRotationSchedule query)', async () => {
      const response = await request(app.getHttpServer())
        .post('/graphql')
        .set('Authorization', `Bearer ${accessToken}`)
        .send({
          query: `
            query GetRotationSchedule($groupId: String!) {
              getRotationSchedule(groupId: $groupId) {
                taskId
                taskTitle
                userId
                username
                scheduledDate
                rotationType
                priority
                points
              }
            }
          `,
          variables: {
            groupId: groupId,
          },
        });

      expect(response.status).toBe(200);
      expect(response.body.errors).toBeUndefined();
      expect(Array.isArray(response.body.data.getRotationSchedule)).toBe(true);
      // Note: Empty array expected until recurring task scheduler is implemented (Phase 9)
      expect(response.body.data.getRotationSchedule).toEqual([]);
    });

    it('should get rotation history (getRotationHistory query)', async () => {
      const response = await request(app.getHttpServer())
        .post('/graphql')
        .set('Authorization', `Bearer ${accessToken}`)
        .send({
          query: `
            query GetRotationHistory($groupId: String!, $limit: Int, $offset: Int) {
              getRotationHistory(groupId: $groupId, limit: $limit, offset: $offset) {
                items {
                  taskId
                  taskTitle
                  userId
                  username
                  assignedAt
                  completedAt
                  status
                  rotationType
                  pointsEarned
                }
                total
              }
            }
          `,
          variables: {
            groupId: groupId,
            limit: 20,
            offset: 0,
          },
        });

      expect(response.status).toBe(200);
      expect(response.body.errors).toBeUndefined();
      expect(response.body.data.getRotationHistory.items).toBeDefined();
      expect(response.body.data.getRotationHistory.total).toBeDefined();
      expect(Array.isArray(response.body.data.getRotationHistory.items)).toBe(true);
    });

    it('should get rotation pattern (getRotationPattern query)', async () => {
      const response = await request(app.getHttpServer())
        .post('/graphql')
        .set('Authorization', `Bearer ${accessToken}`)
        .send({
          query: `
            query GetRotationPattern($groupId: String!) {
              getRotationPattern(groupId: $groupId) {
                rotationType
                currentCycle
                currentCycleIndex
                lastRotationAt
                nextRotationAt
                activeMembers {
                  id
                  username
                  avatarUrl
                  isAway
                  awayUntil
                }
                awayMembers {
                  id
                  username
                  awayUntil
                }
              }
            }
          `,
          variables: {
            groupId: groupId,
          },
        });

      expect(response.status).toBe(200);
      expect(response.body.errors).toBeUndefined();
      const pattern = response.body.data.getRotationPattern;
      expect(pattern.rotationType).toBe('ROUND_ROBIN');
      expect(Array.isArray(pattern.currentCycle)).toBe(true);
      expect(Array.isArray(pattern.activeMembers)).toBe(true);
      expect(Array.isArray(pattern.awayMembers)).toBe(true);
    });

    it('should deny access to non-members for rotation queries', async () => {
      // Create another user (not in group)
      const register2 = await request(app.getHttpServer())
        .post('/graphql')
        .send({
          query: `
            mutation Register($input: RegisterInput!) {
              register(input: $input) {
                accessToken
              }
            }
          `,
          variables: {
            input: {
              email: 'outsider@example.com',
              username: 'outsider',
              password: 'TestPassword123!',
            },
          },
        });

      const outsiderToken = register2.body.data.register.accessToken;

      const response = await request(app.getHttpServer())
        .post('/graphql')
        .set('Authorization', `Bearer ${outsiderToken}`)
        .send({
          query: `
            query GetRotationPattern($groupId: String!) {
              getRotationPattern(groupId: $groupId) {
                rotationType
              }
            }
          `,
          variables: {
            groupId: groupId,
          },
        });

      expect(response.body.errors).toBeDefined();
      expect(response.body.errors[0].message).toContain('Access denied');
    });
  });

  describe('Point Transaction History', () => {
    it('should get point transaction history (getPointTransactionHistory query)', async () => {
      const response = await request(app.getHttpServer())
        .post('/graphql')
        .set('Authorization', `Bearer ${accessToken}`)
        .send({
          query: `
            query GetPointTransactionHistory($groupId: String, $limit: Int, $offset: Int) {
              getPointTransactionHistory(groupId: $groupId, limit: $limit, offset: $offset) {
                items {
                  id
                  type
                  amount
                  description
                  relatedTaskId
                  relatedTaskTitle
                  relatedRewardId
                  relatedRewardName
                  createdAt
                }
                total
              }
            }
          `,
          variables: {
            groupId: groupId,
            limit: 10,
            offset: 0,
          },
        });

      expect(response.status).toBe(200);
      expect(response.body.errors).toBeUndefined();
      expect(response.body.data.getPointTransactionHistory.items).toBeDefined();
      expect(response.body.data.getPointTransactionHistory.total).toBeDefined();
      expect(
        Array.isArray(response.body.data.getPointTransactionHistory.items),
      ).toBe(true);
    });

    it('should filter point transactions by group', async () => {
      // Create another group
      const group2Response = await request(app.getHttpServer())
        .post('/graphql')
        .set('Authorization', `Bearer ${accessToken}`)
        .send({
          query: `
            mutation CreateGroup($input: CreateGroupInput!) {
              createGroup(input: $input) {
                id
              }
            }
          `,
          variables: {
            input: {
              name: 'Second Group',
              requiresApproval: true,
              rotationType: 'RANDOM',
              gamificationEnabled: true,
            },
          },
        });

      const group2Id = group2Response.body.data.createGroup.id;

      const response = await request(app.getHttpServer())
        .post('/graphql')
        .set('Authorization', `Bearer ${accessToken}`)
        .send({
          query: `
            query GetPointTransactionHistory($groupId: String, $limit: Int, $offset: Int) {
              getPointTransactionHistory(groupId: $groupId, limit: $limit, offset: $offset) {
                items {
                  id
                }
                total
              }
            }
          `,
          variables: {
            groupId: group2Id,
            limit: 10,
            offset: 0,
          },
        });

      expect(response.status).toBe(200);
      expect(response.body.errors).toBeUndefined();
      // Should return empty since no transactions in new group
      expect(response.body.data.getPointTransactionHistory.total).toBe(0);
    });

    it('should support pagination for point transaction history', async () => {
      const response1 = await request(app.getHttpServer())
        .post('/graphql')
        .set('Authorization', `Bearer ${accessToken}`)
        .send({
          query: `
            query GetPointTransactionHistory($limit: Int, $offset: Int) {
              getPointTransactionHistory(limit: $limit, offset: $offset) {
                items {
                  id
                }
                total
              }
            }
          `,
          variables: {
            limit: 5,
            offset: 0,
          },
        });

      const response2 = await request(app.getHttpServer())
        .post('/graphql')
        .set('Authorization', `Bearer ${accessToken}`)
        .send({
          query: `
            query GetPointTransactionHistory($limit: Int, $offset: Int) {
              getPointTransactionHistory(limit: $limit, offset: $offset) {
                items {
                  id
                }
                total
              }
            }
          `,
          variables: {
            limit: 5,
            offset: 5,
          },
        });

      expect(response1.status).toBe(200);
      expect(response2.status).toBe(200);
      expect(response1.body.data.getPointTransactionHistory.total).toBe(
        response2.body.data.getPointTransactionHistory.total,
      );
    });
  });
});
