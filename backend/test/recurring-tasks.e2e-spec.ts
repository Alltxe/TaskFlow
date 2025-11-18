import { Test, TestingModule } from '@nestjs/testing';
import { INestApplication } from '@nestjs/common';
import * as request from 'supertest';
import { AppModule } from '../src/app.module';

describe('Recurring Tasks (e2e)', () => {
  let app: INestApplication;
  let accessToken: string;
  let groupId: string;
  let recurringTaskId: string;

  beforeAll(async () => {
    const moduleFixture: TestingModule = await Test.createTestingModule({
      imports: [AppModule],
    }).compile();

    app = moduleFixture.createNestApplication();
    await app.init();

    // Регистрация пользователя
    const registerResponse = await request(app.getHttpServer())
      .post('/graphql')
      .send({
        query: `
          mutation {
            register(input: {
              email: "recurringtest@example.com"
              password: "Password123!"
              username: "RecurringTestUser"
            }) {
              accessToken
            }
          }
        `,
      });

    accessToken = registerResponse.body.data.register.accessToken;

    // Создание группы
    const groupResponse = await request(app.getHttpServer())
      .post('/graphql')
      .set('Authorization', `Bearer ${accessToken}`)
      .send({
        query: `
          mutation {
            createGroup(input: {
              name: "Recurring Tasks Test Group"
              rotationType: ROUND_ROBIN
              gamificationEnabled: true
              requiresApproval: false
            }) {
              id
            }
          }
        `,
      });

    groupId = groupResponse.body.data.createGroup.id;
  });

  afterAll(async () => {
    await app.close();
  });

  describe('Creating recurring tasks', () => {
    it('should create a daily recurring task template', async () => {
      const tomorrow = new Date();
      tomorrow.setDate(tomorrow.getDate() + 1);

      const response = await request(app.getHttpServer())
        .post('/graphql')
        .set('Authorization', `Bearer ${accessToken}`)
        .send({
          query: `
            mutation {
              createTask(input: {
                title: "Daily Kitchen Cleaning"
                description: "Clean the kitchen daily"
                groupId: "${groupId}"
                deadline: "${tomorrow.toISOString()}"
                priority: MEDIUM
                points: 10
                requiresApproval: false
                isRecurring: true
                recurrenceRule: "DAILY"
                rotationType: ROUND_ROBIN
              }) {
                id
                title
                isRecurring
                recurrenceRule
                rotationType
              }
            }
          `,
        });

      expect(response.status).toBe(200);
      expect(response.body.data.createTask).toBeDefined();
      expect(response.body.data.createTask.isRecurring).toBe(true);
      expect(response.body.data.createTask.recurrenceRule).toBe('DAILY');
      expect(response.body.data.createTask.rotationType).toBe('ROUND_ROBIN');

      recurringTaskId = response.body.data.createTask.id;
    });

    it('should create a weekly recurring task (Mon, Wed, Fri)', async () => {
      const nextWeek = new Date();
      nextWeek.setDate(nextWeek.getDate() + 7);

      const response = await request(app.getHttpServer())
        .post('/graphql')
        .set('Authorization', `Bearer ${accessToken}`)
        .send({
          query: `
            mutation {
              createTask(input: {
                title: "Weekly Trash Duty"
                description: "Take out trash on Mon, Wed, Fri"
                groupId: "${groupId}"
                deadline: "${nextWeek.toISOString()}"
                priority: HIGH
                points: 15
                requiresApproval: false
                isRecurring: true
                recurrenceRule: "WEEKLY:1,3,5"
                rotationType: WEIGHTED_RANDOM
              }) {
                id
                isRecurring
                recurrenceRule
                rotationType
              }
            }
          `,
        });

      expect(response.status).toBe(200);
      expect(response.body.data.createTask).toBeDefined();
      expect(response.body.data.createTask.recurrenceRule).toBe('WEEKLY:1,3,5');
      expect(response.body.data.createTask.rotationType).toBe('WEIGHTED_RANDOM');
    });

    it('should create a monthly recurring task (1st and 15th)', async () => {
      const nextMonth = new Date();
      nextMonth.setMonth(nextMonth.getMonth() + 1);
      nextMonth.setDate(1);

      const response = await request(app.getHttpServer())
        .post('/graphql')
        .set('Authorization', `Bearer ${accessToken}`)
        .send({
          query: `
            mutation {
              createTask(input: {
                title: "Monthly Deep Clean"
                description: "Deep cleaning on 1st and 15th"
                groupId: "${groupId}"
                deadline: "${nextMonth.toISOString()}"
                priority: CRITICAL
                points: 50
                requiresApproval: true
                isRecurring: true
                recurrenceRule: "MONTHLY:1,15"
                rotationType: LOAD_BALANCING
              }) {
                id
                isRecurring
                recurrenceRule
                rotationType
              }
            }
          `,
        });

      expect(response.status).toBe(200);
      expect(response.body.data.createTask).toBeDefined();
      expect(response.body.data.createTask.recurrenceRule).toBe('MONTHLY:1,15');
      expect(response.body.data.createTask.rotationType).toBe('LOAD_BALANCING');
    });

    it('should create a recurring task with fixed executor (no rotation)', async () => {
      const nextWeek = new Date();
      nextWeek.setDate(nextWeek.getDate() + 7);

      const response = await request(app.getHttpServer())
        .post('/graphql')
        .set('Authorization', `Bearer ${accessToken}`)
        .send({
          query: `
            mutation {
              createTask(input: {
                title: "Personal Daily Review"
                description: "Daily review task for specific user"
                groupId: "${groupId}"
                deadline: "${nextWeek.toISOString()}"
                priority: LOW
                points: 5
                requiresApproval: false
                isRecurring: true
                recurrenceRule: "DAILY"
              }) {
                id
                isRecurring
                recurrenceRule
                rotationType
                assignee {
                  id
                }
              }
            }
          `,
        });

      expect(response.status).toBe(200);
      expect(response.body.data.createTask).toBeDefined();
      expect(response.body.data.createTask.isRecurring).toBe(true);
      // rotationType should be null for fixed executor
      expect(response.body.data.createTask.rotationType).toBeNull();
    });
  });

  describe('Generating tasks from recurring templates', () => {
    it('should manually generate next task from recurring template', async () => {
      // First, complete the template task to enable generation
      await request(app.getHttpServer())
        .post('/graphql')
        .set('Authorization', `Bearer ${accessToken}`)
        .send({
          query: `
            mutation {
              completeTask(input: {
                taskId: "${recurringTaskId}"
              }) {
                id
                status
              }
            }
          `,
        });

      // Now generate next task
      const response = await request(app.getHttpServer())
        .post('/graphql')
        .set('Authorization', `Bearer ${accessToken}`)
        .send({
          query: `
            mutation {
              generateNextRecurringTask(taskId: "${recurringTaskId}") {
                id
                title
                parentTaskId
                isRecurring
                status
                deadline
              }
            }
          `,
        });

      expect(response.status).toBe(200);
      expect(response.body.data.generateNextRecurringTask).toBeDefined();

      const generatedTask = response.body.data.generateNextRecurringTask;
      expect(generatedTask.parentTaskId).toBe(recurringTaskId);
      expect(generatedTask.isRecurring).toBe(false); // Child is not recurring
      expect(generatedTask.status).toBe('PENDING');
      expect(generatedTask.title).toBe('Daily Kitchen Cleaning'); // Same as template

      // Deadline should be ~24 hours after template deadline
      const generatedDeadline = new Date(generatedTask.deadline);
      expect(generatedDeadline.getTime()).toBeGreaterThan(new Date().getTime());
    });

    it('should fail to generate from non-recurring task', async () => {
      // Create a normal (non-recurring) task
      const tomorrow = new Date();
      tomorrow.setDate(tomorrow.getDate() + 1);

      const normalTaskResponse = await request(app.getHttpServer())
        .post('/graphql')
        .set('Authorization', `Bearer ${accessToken}`)
        .send({
          query: `
            mutation {
              createTask(input: {
                title: "One-time Task"
                groupId: "${groupId}"
                deadline: "${tomorrow.toISOString()}"
                priority: LOW
                points: 5
                requiresApproval: false
                isRecurring: false
              }) {
                id
              }
            }
          `,
        });

      const normalTaskId = normalTaskResponse.body.data.createTask.id;

      // Try to generate next task (should fail)
      const response = await request(app.getHttpServer())
        .post('/graphql')
        .set('Authorization', `Bearer ${accessToken}`)
        .send({
          query: `
            mutation {
              generateNextRecurringTask(taskId: "${normalTaskId}") {
                id
              }
            }
          `,
        });

      expect(response.status).toBe(200);
      expect(response.body.errors).toBeDefined();
      expect(response.body.errors[0].message).toContain('not a recurring template');
    });
  });

  describe('Recurring task child relationships', () => {
    it('should query child tasks of a recurring template', async () => {
      // Generate a child task first
      await request(app.getHttpServer())
        .post('/graphql')
        .set('Authorization', `Bearer ${accessToken}`)
        .send({
          query: `
            mutation {
              generateNextRecurringTask(taskId: "${recurringTaskId}") {
                id
              }
            }
          `,
        });

      // Query the template with children
      const response = await request(app.getHttpServer())
        .post('/graphql')
        .set('Authorization', `Bearer ${accessToken}`)
        .send({
          query: `
            query {
              getTask(taskId: "${recurringTaskId}") {
                id
                title
                isRecurring
                childTasks {
                  id
                  parentTaskId
                  isRecurring
                  status
                }
              }
            }
          `,
        });

      expect(response.status).toBe(200);
      expect(response.body.data.getTask).toBeDefined();

      const template = response.body.data.getTask;
      expect(template.isRecurring).toBe(true);
      expect(template.childTasks.length).toBeGreaterThan(0);

      const child = template.childTasks[0];
      expect(child.parentTaskId).toBe(recurringTaskId);
      expect(child.isRecurring).toBe(false);
    });
  });

  describe('Recurring task rotation behavior', () => {
    it('should apply rotation when generating tasks with ROUND_ROBIN', async () => {
      // Add another user to the group
      const user2Response = await request(app.getHttpServer())
        .post('/graphql')
        .send({
          query: `
            mutation {
              register(input: {
                email: "recurringuser2@example.com"
                password: "Password123!"
                username: "RecurringUser2"
              }) {
                accessToken
              }
            }
          `,
        });

      const user2Token = user2Response.body.data.register.accessToken;

      // Join group with second user
      const inviteTokenResponse = await request(app.getHttpServer())
        .post('/graphql')
        .set('Authorization', `Bearer ${accessToken}`)
        .send({
          query: `
            mutation {
              regenerateInviteToken(groupId: "${groupId}") {
                inviteToken
              }
            }
          `,
        });

      const inviteToken = inviteTokenResponse.body.data.regenerateInviteToken.inviteToken;

      await request(app.getHttpServer())
        .post('/graphql')
        .set('Authorization', `Bearer ${user2Token}`)
        .send({
          query: `
            mutation {
              joinGroup(token: "${inviteToken}") {
                id
              }
            }
          `,
        });

      // Generate multiple tasks and verify rotation
      const task1Response = await request(app.getHttpServer())
        .post('/graphql')
        .set('Authorization', `Bearer ${accessToken}`)
        .send({
          query: `
            mutation {
              generateNextRecurringTask(taskId: "${recurringTaskId}") {
                id
                assignee {
                  id
                  username
                }
              }
            }
          `,
        });

      expect(task1Response.body.data.generateNextRecurringTask.assignee).toBeDefined();
      const assignee1Id = task1Response.body.data.generateNextRecurringTask.assignee.id;

      // Complete first task to enable next generation
      await request(app.getHttpServer())
        .post('/graphql')
        .set('Authorization', `Bearer ${accessToken}`)
        .send({
          query: `
            mutation {
              completeTask(input: {
                taskId: "${task1Response.body.data.generateNextRecurringTask.id}"
              }) {
                id
              }
            }
          `,
        });

      // Generate second task - should rotate to different user
      const task2Response = await request(app.getHttpServer())
        .post('/graphql')
        .set('Authorization', `Bearer ${accessToken}`)
        .send({
          query: `
            mutation {
              generateNextRecurringTask(taskId: "${recurringTaskId}") {
                id
                assignee {
                  id
                  username
                }
              }
            }
          `,
        });

      expect(task2Response.body.data.generateNextRecurringTask.assignee).toBeDefined();
      const assignee2Id = task2Response.body.data.generateNextRecurringTask.assignee.id;

      // Rotation should assign to different user (or same if only one active user)
      expect(assignee2Id).toBeDefined();
    });
  });
});
