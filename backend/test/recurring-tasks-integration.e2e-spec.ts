import { Test, TestingModule } from '@nestjs/testing';
import { INestApplication } from '@nestjs/common';
import request from 'supertest';
import { AppModule } from './../src/app.module';
import { PrismaService } from '../src/modules/prisma/prisma.service';

describe('Recurring Tasks Integration (e2e)', () => {
  let app: INestApplication;
  let prisma: PrismaService;
  let accessToken: string;
  let userId: string;
  let groupId: string;
  let recurringTaskId: string;

  beforeAll(async () => {
    const moduleFixture: TestingModule = await Test.createTestingModule({
      imports: [AppModule],
    }).compile();

    app = moduleFixture.createNestApplication();
    await app.init();

    prisma = app.get<PrismaService>(PrismaService);

    // Clean up test data - proper order to handle FK constraints
    await prisma.taskCompletionAttachment.deleteMany({});
    await prisma.taskCompletionHistory.deleteMany({});
    await prisma.taskAttachment.deleteMany({});
    await prisma.notification.deleteMany({});
    await prisma.pointTransaction.deleteMany({});
    await prisma.rewardTransaction.deleteMany({});
    await prisma.reward.deleteMany({});
    await prisma.task.deleteMany({});
    await prisma.groupMember.deleteMany({});
    await prisma.group.deleteMany({});
    await prisma.refreshToken.deleteMany({});
    await prisma.deviceToken.deleteMany({});
    await prisma.notificationPreference.deleteMany({});
    await prisma.auditLog.deleteMany({});
    await prisma.user.deleteMany({});
  });

  afterAll(async () => {
    // Clean up - proper order to handle FK constraints
    await prisma.taskCompletionAttachment.deleteMany({});
    await prisma.taskCompletionHistory.deleteMany({});
    await prisma.taskAttachment.deleteMany({});
    await prisma.notification.deleteMany({});
    await prisma.pointTransaction.deleteMany({});
    await prisma.rewardTransaction.deleteMany({});
    await prisma.reward.deleteMany({});
    await prisma.task.deleteMany({});
    await prisma.groupMember.deleteMany({});
    await prisma.group.deleteMany({});
    await prisma.refreshToken.deleteMany({});
    await prisma.deviceToken.deleteMany({});
    await prisma.notificationPreference.deleteMany({});
    await prisma.auditLog.deleteMany({});
    await prisma.user.deleteMany({});

    await app.close();
  });

  describe('Complete Recurring Task Workflow', () => {
    it('Step 1: Register user and get access token', async () => {
      const response = await request(app.getHttpServer())
        .post('/graphql')
        .send({
          query: `
            mutation Register {
              register(input: {
                email: "recurring-test@example.com"
                username: "recurring-test-user"
                password: "SecurePass123!"
              }) {
                accessToken
                user {
                  id
                  username
                  email
                }
              }
            }
          `,
        });

      expect(response.status).toBe(200);
      expect(response.body.data.register.accessToken).toBeDefined();
      
      accessToken = response.body.data.register.accessToken;
      userId = response.body.data.register.user.id;

      console.log('✅ User created:', userId);
    });

    it('Step 2: Create a group', async () => {
      const response = await request(app.getHttpServer())
        .post('/graphql')
        .set('Authorization', `Bearer ${accessToken}`)
        .send({
          query: `
            mutation CreateGroup {
              createGroup(input: {
                name: "Recurring Tasks Test Group"
                description: "Testing recurring tasks functionality"
                rotationType: "ROUND_ROBIN"
                requiresApproval: false
              }) {
                id
                name
                rotationType
              }
            }
          `,
        });

      if (response.status !== 200) {
        console.error('Create group error:', JSON.stringify(response.body, null, 2));
      }

      expect(response.status).toBe(200);
      expect(response.body.data.createGroup.id).toBeDefined();

      groupId = response.body.data.createGroup.id;

      console.log('✅ Group created:', groupId);
    });

    it('Step 3: Create recurring task with 5-second interval', async () => {
      const now = new Date();
      const deadline = new Date(now.getTime() + 5000); // 5 seconds from now

      const response = await request(app.getHttpServer())
        .post('/graphql')
        .set('Authorization', `Bearer ${accessToken}`)
        .send({
          query: `
            mutation CreateRecurringTask($input: CreateTaskInput!) {
              createTask(input: $input) {
                id
                title
                isRecurring
                recurrenceRule
                deadline
                status
                assignee {
                  id
                  username
                }
              }
            }
          `,
          variables: {
            input: {
              title: 'Quick Recurring Task - Every 5 Seconds',
              description: 'This task recurs every 5 seconds for testing',
              groupId: groupId,
              priority: 'MEDIUM',
              points: 10,
              deadline: deadline.toISOString(),
              isRecurring: true,
              recurrenceRule: 'FREQ=SECONDLY;INTERVAL=5',
              requiresApproval: false,
            },
          },
        });

      if (response.status !== 200) {
        console.error('Create task error:', JSON.stringify(response.body, null, 2));
      }

      expect(response.status).toBe(200);
      expect(response.body.data.createTask.id).toBeDefined();
      expect(response.body.data.createTask.isRecurring).toBe(true);
      expect(response.body.data.createTask.recurrenceRule).toBe('FREQ=SECONDLY;INTERVAL=5');
      
      recurringTaskId = response.body.data.createTask.id;

      console.log('✅ Recurring task created:', recurringTaskId);
      console.log('   Recurrence rule: FREQ=SECONDLY;INTERVAL=5');
      console.log('   Initial deadline:', deadline.toISOString());
    });

    it('Step 4: Complete the first task to enable recurring generation', async () => {
      const response = await request(app.getHttpServer())
        .post('/graphql')
        .set('Authorization', `Bearer ${accessToken}`)
        .send({
          query: `
            mutation CompleteTask($input: CompleteTaskInput!) {
              completeTask(input: $input) {
                id
                status
              }
            }
          `,
          variables: {
            input: {
              taskId: recurringTaskId,
            },
          },
        });

      if (response.status !== 200) {
        console.error('Complete task error:', JSON.stringify(response.body, null, 2));
      }

      expect(response.status).toBe(200);
      expect(response.body.data.completeTask.status).toBe('COMPLETED');

      console.log('✅ Task marked as COMPLETED (template ready for recurring)');
    });

    it('Step 5: Manually generate next recurring task', async () => {
      const response = await request(app.getHttpServer())
        .post('/graphql')
        .set('Authorization', `Bearer ${accessToken}`)
        .send({
          query: `
            mutation GenerateNextTask($taskId: String!) {
              generateNextRecurringTask(taskId: $taskId) {
                id
                title
                deadline
                parentTaskId
                isRecurring
                status
                assignee {
                  id
                  username
                }
              }
            }
          `,
          variables: {
            taskId: recurringTaskId,
          },
        });

      if (response.status !== 200) {
        console.error('Generate next task error:', JSON.stringify(response.body, null, 2));
      }

      expect(response.status).toBe(200);
      expect(response.body.data.generateNextRecurringTask).toBeDefined();

      const generatedTask = response.body.data.generateNextRecurringTask;
      expect(generatedTask.parentTaskId).toBe(recurringTaskId);
      expect(generatedTask.isRecurring).toBe(false);
      expect(generatedTask.status).toBe('PENDING');

      const firstDeadline = new Date(generatedTask.deadline);

      console.log('✅ First child task generated:', generatedTask.id);
      console.log('   Deadline:', firstDeadline.toISOString());

      // Wait 6 seconds to ensure next deadline is ready
      console.log('⏳ Waiting 6 seconds for next interval...');
      await new Promise(resolve => setTimeout(resolve, 6000));
    }, 10000); // 10 second timeout

    it('Step 6: Generate second recurring task (should be ~5 seconds after first)', async () => {
      const response = await request(app.getHttpServer())
        .post('/graphql')
        .set('Authorization', `Bearer ${accessToken}`)
        .send({
          query: `
            mutation GenerateNextTask($taskId: String!) {
              generateNextRecurringTask(taskId: $taskId) {
                id
                title
                deadline
                parentTaskId
                isRecurring
              }
            }
          `,
          variables: {
            taskId: recurringTaskId,
          },
        });

      expect(response.status).toBe(200);
      
      const secondTask = response.body.data.generateNextRecurringTask;
      expect(secondTask.parentTaskId).toBe(recurringTaskId);
      
      const secondDeadline = new Date(secondTask.deadline);
      
      console.log('✅ Second child task generated:', secondTask.id);
      console.log('   Deadline:', secondDeadline.toISOString());
    });

    it('Step 7: Verify recurring task template status', async () => {
      const response = await request(app.getHttpServer())
        .post('/graphql')
        .set('Authorization', `Bearer ${accessToken}`)
        .send({
          query: `
            query GetRecurringTask($taskId: String!) {
              getTask(taskId: $taskId) {
                id
                title
                isRecurring
                recurrenceRule
                status
              }
            }
          `,
          variables: {
            taskId: recurringTaskId,
          },
        });

      if (response.status !== 200) {
        console.error('Get task error (Step 7):', JSON.stringify(response.body, null, 2));
      }

      expect(response.status).toBe(200);
      expect(response.body.data.getTask.isRecurring).toBe(true);
      expect(response.body.data.getTask.recurrenceRule).toBe('FREQ=SECONDLY;INTERVAL=5');
      expect(response.body.data.getTask.status).toBe('COMPLETED');

      console.log('✅ Recurring task template verified');
      console.log(`   Title: ${response.body.data.getTask.title}`);
      console.log(`   Recurrence rule: ${response.body.data.getTask.recurrenceRule}`);
      console.log(`   Status: ${response.body.data.getTask.status}`);
    });

    it('Step 8: Test with even faster interval (2 seconds)', async () => {
      const now = new Date();
      const deadline = new Date(now.getTime() + 2000);

      const createResponse = await request(app.getHttpServer())
        .post('/graphql')
        .set('Authorization', `Bearer ${accessToken}`)
        .send({
          query: `
            mutation CreateRecurringTask($input: CreateTaskInput!) {
              createTask(input: $input) {
                id
                title
                isRecurring
                recurrenceRule
              }
            }
          `,
          variables: {
            input: {
              title: 'Super Fast Recurring - Every 2 Seconds',
              description: 'Testing with 2-second interval',
              groupId: groupId,
              priority: 'LOW',
              points: 5,
              deadline: deadline.toISOString(),
              isRecurring: true,
              recurrenceRule: 'FREQ=SECONDLY;INTERVAL=2',
              requiresApproval: false,
            },
          },
        });

      expect(createResponse.status).toBe(200);
      const fastTaskId = createResponse.body.data.createTask.id;

      console.log('✅ Fast recurring task created:', fastTaskId);
      console.log('   Interval: 2 seconds');

      // Complete it to make it a template
      await request(app.getHttpServer())
        .post('/graphql')
        .set('Authorization', `Bearer ${accessToken}`)
        .send({
          query: `
            mutation CompleteTask($input: CompleteTaskInput!) {
              completeTask(input: $input) {
                id
                status
              }
            }
          `,
          variables: { input: { taskId: fastTaskId } },
        });

      // Generate 3 tasks quickly
      for (let i = 1; i <= 3; i++) {
        const genResponse = await request(app.getHttpServer())
          .post('/graphql')
          .set('Authorization', `Bearer ${accessToken}`)
          .send({
            query: `
              mutation GenerateNextTask($taskId: String!) {
                generateNextRecurringTask(taskId: $taskId) {
                  id
                  deadline
                }
              }
            `,
            variables: { taskId: fastTaskId },
          });

        if (genResponse.status !== 200) {
          console.error(`Generate task ${i} error:`, JSON.stringify(genResponse.body, null, 2));
        }

        const childTask = genResponse.body.data.generateNextRecurringTask;
        console.log(`   Generated task ${i}: ${new Date(childTask.deadline).toISOString()}`);

        // Wait 3 seconds between generations (longer than interval)
        if (i < 3) {
          await new Promise(resolve => setTimeout(resolve, 3000));
        }
      }

      console.log('✅ All 3 fast-interval tasks generated successfully');
    }, 15000); // 15 second timeout for multiple waits
  });

  describe('RFC 5545 Format Validation', () => {
    it('Should accept valid RFC 5545 rules', async () => {
      const validRules = [
        'FREQ=DAILY',
        'FREQ=WEEKLY;BYDAY=MO,WE,FR',
        'FREQ=MONTHLY;BYMONTHDAY=1,15',
        'FREQ=HOURLY;INTERVAL=2',
        'FREQ=MINUTELY;INTERVAL=30',
        'FREQ=SECONDLY;INTERVAL=10',
        'FREQ=WEEKLY;BYDAY=MO,WE,FR;BYHOUR=18;BYMINUTE=30',
      ];

      for (const rule of validRules) {
        const response = await request(app.getHttpServer())
          .post('/graphql')
          .set('Authorization', `Bearer ${accessToken}`)
          .send({
            query: `
              mutation CreateRecurringTask($input: CreateTaskInput!) {
                createTask(input: $input) {
                  id
                  recurrenceRule
                }
              }
            `,
            variables: {
              input: {
                title: `Test: ${rule}`,
                groupId: groupId,
                priority: 'LOW',
                points: 1,
                deadline: new Date().toISOString(),
                isRecurring: true,
                recurrenceRule: rule,
              },
            },
          });

        expect(response.status).toBe(200);
        expect(response.body.data.createTask.recurrenceRule).toBe(rule);
        
        console.log(`✅ Valid rule accepted: ${rule}`);
      }
    });
  });
});
