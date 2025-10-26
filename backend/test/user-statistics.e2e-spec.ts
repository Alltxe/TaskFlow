import { Test, TestingModule } from '@nestjs/testing';
import { INestApplication } from '@nestjs/common';
import request from 'supertest';
import { AppModule } from '../src/app.module';
import { PrismaService } from '../src/modules/prisma/prisma.service';

describe('User Statistics (e2e)', () => {
  let app: INestApplication;
  let prisma: PrismaService;

  // Test users
  let testUser1: any;
  let testUser2: any;
  let testUser1Token: string;
  let testUser2Token: string;

  // Test group
  let testGroup: any;

  beforeAll(async () => {
    const moduleFixture: TestingModule = await Test.createTestingModule({
      imports: [AppModule],
    }).compile();

    app = moduleFixture.createNestApplication();
    prisma = app.get<PrismaService>(PrismaService);
    await app.init();

    // Create test users
    const user1Response = await request(app.getHttpServer())
      .post('/graphql')
      .send({
        query: `
          mutation {
            register(input: {
              email: "stats-user1@test.com"
              username: "stats-user1"
              password: "password123"
            }) {
              accessToken
              user {
                id
                email
                username
              }
            }
          }
        `,
      });

    testUser1 = user1Response.body.data.register.user;
    testUser1Token = user1Response.body.data.register.accessToken;

    const user2Response = await request(app.getHttpServer())
      .post('/graphql')
      .send({
        query: `
          mutation {
            register(input: {
              email: "stats-user2@test.com"
              username: "stats-user2"
              password: "password123"
            }) {
              accessToken
              user {
                id
                email
                username
              }
            }
          }
        `,
      });

    testUser2 = user2Response.body.data.register.user;
    testUser2Token = user2Response.body.data.register.accessToken;

    // Create test group
    const groupResponse = await request(app.getHttpServer())
      .post('/graphql')
      .set('Authorization', `Bearer ${testUser1Token}`)
      .send({
        query: `
          mutation {
            createGroup(input: {
              name: "Test Statistics Group"
              description: "Group for testing statistics"
            }) {
              id
              name
              inviteToken
            }
          }
        `,
      });

    testGroup = groupResponse.body.data.createGroup;

    // Add user2 to the group
    await request(app.getHttpServer())
      .post('/graphql')
      .set('Authorization', `Bearer ${testUser2Token}`)
      .send({
        query: `
          mutation {
            joinGroup(token: "${testGroup.inviteToken}") {
              id
            }
          }
        `,
      });
  });

  afterAll(async () => {
    // Cleanup test data
    await prisma.taskCompletionHistory.deleteMany({
      where: {
        userId: {
          in: [testUser1.id, testUser2.id],
        },
      },
    });

    await prisma.task.deleteMany({
      where: {
        groupId: testGroup.id,
      },
    });

    await prisma.groupMember.deleteMany({
      where: {
        groupId: testGroup.id,
      },
    });

    await prisma.group.deleteMany({
      where: {
        id: testGroup.id,
      },
    });

    await prisma.user.deleteMany({
      where: {
        email: {
          contains: 'stats-user',
        },
      },
    });

    await app.close();
  });

  describe('myStatistics query', () => {
    it('should return zero statistics for new user with no activity', async () => {
      const response = await request(app.getHttpServer())
        .post('/graphql')
        .set('Authorization', `Bearer ${testUser1Token}`)
        .send({
          query: `
            query {
              myStatistics {
                userId
                currentPointBalance
                totalPointsEarned
                totalPointsSpent
                tasksCompleted
                tasksAssigned
                completionRate
                tasksCompletedOnTime
                onTimePercentage
                leaderboardPosition
                groupId
              }
            }
          `,
        })
        .expect(200);

      expect(response.body.errors).toBeUndefined();
      expect(response.body.data.myStatistics).toBeDefined();

      const stats = response.body.data.myStatistics;
      expect(stats.currentPointBalance).toBe(0);
      expect(stats.totalPointsEarned).toBe(0);
      expect(stats.totalPointsSpent).toBe(0);
      expect(stats.tasksCompleted).toBe(0);
      expect(stats.tasksAssigned).toBe(0);
      expect(stats.completionRate).toBe(0);
      expect(stats.tasksCompletedOnTime).toBe(0);
      expect(stats.onTimePercentage).toBe(0);
      expect(stats.leaderboardPosition).toBeNull();
      expect(stats.groupId).toBeNull();
    });

    it('should require authentication', async () => {
      const response = await request(app.getHttpServer())
        .post('/graphql')
        .send({
          query: `
            query {
              myStatistics {
                userId
                currentPointBalance
              }
            }
          `,
        })
        .expect(200);

      expect(response.body.errors).toBeDefined();
      expect(response.body.errors[0].message).toMatch(/Unauthorized|Требуется авторизация/);
    });

    it('should return group-specific statistics when groupId is provided', async () => {
      const response = await request(app.getHttpServer())
        .post('/graphql')
        .set('Authorization', `Bearer ${testUser1Token}`)
        .send({
          query: `
            query {
              myStatistics(groupId: "${testGroup.id}") {
                userId
                groupId
                currentPointBalance
                tasksCompleted
              }
            }
          `,
        })
        .expect(200);

      expect(response.body.errors).toBeUndefined();
      const stats = response.body.data.myStatistics;
      expect(stats.groupId).toBe(testGroup.id);
    });
  });

  describe('userStatistics query', () => {
    it('should return statistics for a specific user by ID', async () => {
      const response = await request(app.getHttpServer())
        .post('/graphql')
        .set('Authorization', `Bearer ${testUser1Token}`)
        .send({
          query: `
            query {
              userStatistics(userId: "${testUser2.id}") {
                userId
                currentPointBalance
                totalPointsEarned
                tasksCompleted
              }
            }
          `,
        })
        .expect(200);

      expect(response.body.errors).toBeUndefined();
      expect(response.body.data.userStatistics).toBeDefined();

      const stats = response.body.data.userStatistics;
      expect(stats.userId).toBe(testUser2.id);
    });

    it('should return group-specific statistics for another user', async () => {
      const response = await request(app.getHttpServer())
        .post('/graphql')
        .set('Authorization', `Bearer ${testUser1Token}`)
        .send({
          query: `
            query {
              userStatistics(userId: "${testUser2.id}", groupId: "${testGroup.id}") {
                userId
                groupId
                currentPointBalance
              }
            }
          `,
        })
        .expect(200);

      expect(response.body.errors).toBeUndefined();
      const stats = response.body.data.userStatistics;
      expect(stats.userId).toBe(testUser2.id);
      expect(stats.groupId).toBe(testGroup.id);
    });

    it('should require authentication', async () => {
      const response = await request(app.getHttpServer())
        .post('/graphql')
        .send({
          query: `
            query {
              userStatistics(userId: "${testUser2.id}") {
                userId
                currentPointBalance
              }
            }
          `,
        })
        .expect(200);

      expect(response.body.errors).toBeDefined();
      expect(response.body.errors[0].message).toMatch(/Unauthorized|Требуется авторизация/);
    });
  });

  describe('Statistics with real task data', () => {
    let task1: any;
    let task2: any;

    beforeAll(async () => {
      // Create tasks for user1
      const task1Response = await request(app.getHttpServer())
        .post('/graphql')
        .set('Authorization', `Bearer ${testUser1Token}`)
        .send({
          query: `
            mutation {
              createTask(input: {
                groupId: "${testGroup.id}"
                title: "Test Task 1"
                description: "First test task"
                deadline: "${new Date(Date.now() + 86400000).toISOString()}"
                priority: "MEDIUM"
                points: 100
                assigneeId: "${testUser1.id}"
              }) {
                id
                title
                points
              }
            }
          `,
        });

      // Check if task creation succeeded
      if (task1Response.body.errors) {
        console.log('Task 1 creation errors:', JSON.stringify(task1Response.body.errors, null, 2));
        throw new Error('Failed to create task1: ' + JSON.stringify(task1Response.body.errors));
      }
      
      if (!task1Response.body.data || !task1Response.body.data.createTask) {
        throw new Error('Failed to create task1: no data returned');
      }

      task1 = task1Response.body.data.createTask;

      const task2Response = await request(app.getHttpServer())
        .post('/graphql')
        .set('Authorization', `Bearer ${testUser1Token}`)
        .send({
          query: `
            mutation {
              createTask(input: {
                groupId: "${testGroup.id}"
                title: "Test Task 2"
                description: "Second test task"
                deadline: "${new Date(Date.now() + 86400000).toISOString()}"
                priority: "HIGH"
                points: 150
                assigneeId: "${testUser1.id}"
              }) {
                id
                title
                points
              }
            }
          `,
        });

      // Check if task creation succeeded
      if (task2Response.body.errors) {
        console.log('Task 2 creation errors:', JSON.stringify(task2Response.body.errors, null, 2));
        throw new Error('Failed to create task2: ' + JSON.stringify(task2Response.body.errors));
      }
      
      if (!task2Response.body.data || !task2Response.body.data.createTask) {
        throw new Error('Failed to create task2: no data returned');
      }

      task2 = task2Response.body.data.createTask;

      // Complete task1
      const completeResponse = await request(app.getHttpServer())
        .post('/graphql')
        .set('Authorization', `Bearer ${testUser1Token}`)
        .send({
          query: `
            mutation {
              completeTask(input: { taskId: "${task1.id}" }) {
                id
                status
              }
            }
          `,
        });

      if (completeResponse.body.errors) {
        console.log('Complete task errors:', JSON.stringify(completeResponse.body.errors, null, 2));
      }

      // Approve task1
      const approveResponse = await request(app.getHttpServer())
        .post('/graphql')
        .set('Authorization', `Bearer ${testUser1Token}`)
        .send({
          query: `
            mutation {
              approveTask(input: { taskId: "${task1.id}", approved: true }) {
                id
                status
              }
            }
          `,
        });

      if (approveResponse.body.errors) {
        console.log('Approve task errors:', JSON.stringify(approveResponse.body.errors, null, 2));
      }
    });

    it('should reflect completed tasks in statistics', async () => {
      const response = await request(app.getHttpServer())
        .post('/graphql')
        .set('Authorization', `Bearer ${testUser1Token}`)
        .send({
          query: `
            query {
              myStatistics(groupId: "${testGroup.id}") {
                userId
                currentPointBalance
                totalPointsEarned
                totalPointsSpent
                tasksCompleted
                tasksAssigned
                completionRate
                leaderboardPosition
              }
            }
          `,
        })
        .expect(200);

      expect(response.body.errors).toBeUndefined();
      const stats = response.body.data.myStatistics;

      expect(stats.tasksCompleted).toBeGreaterThanOrEqual(1);
      expect(stats.tasksAssigned).toBeGreaterThanOrEqual(1); // At least one task assigned
      expect(stats.totalPointsEarned).toBeGreaterThan(0);
      expect(stats.currentPointBalance).toBeDefined();
      expect(stats.totalPointsSpent).toBeDefined();
      // Balance should equal earned minus spent
      expect(stats.currentPointBalance).toBe(stats.totalPointsEarned - stats.totalPointsSpent);
    });

    it('should calculate completion rate correctly', async () => {
      const response = await request(app.getHttpServer())
        .post('/graphql')
        .set('Authorization', `Bearer ${testUser1Token}`)
        .send({
          query: `
            query {
              myStatistics(groupId: "${testGroup.id}") {
                tasksCompleted
                tasksAssigned
                completionRate
              }
            }
          `,
        })
        .expect(200);

      const stats = response.body.data.myStatistics;
      if (stats.tasksAssigned > 0) {
        const expectedRate = (stats.tasksCompleted / stats.tasksAssigned) * 100;
        expect(stats.completionRate).toBeCloseTo(expectedRate, 1);
      }
    });

    it('should show leaderboard position when user has completions', async () => {
      const response = await request(app.getHttpServer())
        .post('/graphql')
        .set('Authorization', `Bearer ${testUser1Token}`)
        .send({
          query: `
            query {
              myStatistics(groupId: "${testGroup.id}") {
                leaderboardPosition
                tasksCompleted
              }
            }
          `,
        })
        .expect(200);

      const stats = response.body.data.myStatistics;
      if (stats.tasksCompleted > 0) {
        expect(stats.leaderboardPosition).toBeGreaterThanOrEqual(1);
      }
    });
  });

  describe('Multiple users leaderboard', () => {
    it('should rank users correctly based on points earned', async () => {
      const user1Stats = await request(app.getHttpServer())
        .post('/graphql')
        .set('Authorization', `Bearer ${testUser1Token}`)
        .send({
          query: `
            query {
              myStatistics(groupId: "${testGroup.id}") {
                userId
                totalPointsEarned
                leaderboardPosition
              }
            }
          `,
        });

      const user2Stats = await request(app.getHttpServer())
        .post('/graphql')
        .set('Authorization', `Bearer ${testUser2Token}`)
        .send({
          query: `
            query {
              myStatistics(groupId: "${testGroup.id}") {
                userId
                totalPointsEarned
                leaderboardPosition
              }
            }
          `,
        });

      const stats1 = user1Stats.body.data.myStatistics;
      const stats2 = user2Stats.body.data.myStatistics;

      // If both have points, verify ranking logic
      if (stats1.totalPointsEarned > 0 && stats2.totalPointsEarned > 0) {
        if (stats1.totalPointsEarned > stats2.totalPointsEarned) {
          expect(stats1.leaderboardPosition).toBeLessThan(stats2.leaderboardPosition);
        } else if (stats2.totalPointsEarned > stats1.totalPointsEarned) {
          expect(stats2.leaderboardPosition).toBeLessThan(stats1.leaderboardPosition);
        }
      }
    });
  });
});
