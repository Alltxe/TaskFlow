import { Test, TestingModule } from '@nestjs/testing';
import { INestApplication, ValidationPipe } from '@nestjs/common';
import request from 'supertest';
import { AppModule } from '../src/app.module';
import { PrismaService } from '../src/modules/prisma/prisma.service';

/**
 * E2E tests for Notification flows (Phase 8 - PRD 3.6.3)
 */
describe('Notification Operations (e2e)', () => {
  let app: INestApplication;
  let prisma: PrismaService;
  let adminToken: string;
  let memberToken: string;
  let adminUserId: string;
  let memberUserId: string;
  let groupId: string;
  let taskId: string;

  beforeAll(async () => {
    const moduleFixture: TestingModule = await Test.createTestingModule({
      imports: [AppModule],
    }).compile();

    app = moduleFixture.createNestApplication();
    app.useGlobalPipes(new ValidationPipe());
    await app.init();

    prisma = moduleFixture.get<PrismaService>(PrismaService);

    // Clean tables that may interfere
    await prisma.notification.deleteMany();
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

    // Register admin
    const regAdmin = await request(app.getHttpServer())
      .post('/graphql')
      .send({ query: `mutation { register(input: { email: "notifadmin@test.com", username: "notifadmin", password: "Test123!" }) { accessToken user { id } } }` });
    adminToken = regAdmin.body.data.register.accessToken;
    adminUserId = regAdmin.body.data.register.user.id;

    // Register member
    const regMember = await request(app.getHttpServer())
      .post('/graphql')
      .send({ query: `mutation { register(input: { email: "notifmember@test.com", username: "notifmember", password: "Test123!" }) { accessToken user { id } } }` });
    memberToken = regMember.body.data.register.accessToken;
    memberUserId = regMember.body.data.register.user.id;

    // Create group by admin
    const createGroup = await request(app.getHttpServer())
      .post('/graphql')
      .set('Authorization', `Bearer ${adminToken}`)
      .send({ query: `mutation { createGroup(input: { name: "Notif Group" }) { id inviteToken } }` });
    groupId = createGroup.body.data.createGroup.id;
    const inviteToken = createGroup.body.data.createGroup.inviteToken;

    // Member joins group
    await request(app.getHttpServer())
      .post('/graphql')
      .set('Authorization', `Bearer ${memberToken}`)
      .send({ query: `mutation { joinGroup(input: { inviteToken: "${inviteToken}" }) { id } }` });

    // Create a task assigned to member to trigger assignment notification
    const createTask = await request(app.getHttpServer())
      .post('/graphql')
      .set('Authorization', `Bearer ${adminToken}`)
      .send({ query: `mutation { createTask(input: { title: "Assigned Task", deadline: "2030-01-01", priority: "MEDIUM", points: 50, groupId: "${groupId}", assigneeId: "${memberUserId}" }) { id } }` });
    if (createTask.body.errors) {
      console.error('createTask errors', JSON.stringify(createTask.body.errors, null, 2));
      throw new Error('createTask failed');
    }
    taskId = createTask.body.data.createTask.id;
  });

  afterAll(async () => {
    await prisma.notification.deleteMany();
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

  it('Member sees assignment notification', async () => {
    const res = await request(app.getHttpServer())
      .post('/graphql')
      .set('Authorization', `Bearer ${memberToken}`)
      .send({ query: `query { myNotifications { total items { id title type relatedEntityId } } }` });
    expect(res.body.errors).toBeUndefined();
    expect(res.body.data.myNotifications.total).toBeGreaterThanOrEqual(1);
    const found = res.body.data.myNotifications.items.find((n: any) => n.relatedEntityId === taskId);
    expect(found).toBeDefined();
  });

  it('Member completes task requiring approval triggers admin notification', async () => {
    // Create approval-required task
    const createTask2 = await request(app.getHttpServer())
      .post('/graphql')
      .set('Authorization', `Bearer ${adminToken}`)
      .send({ query: `mutation { createTask(input: { title: "Needs Review", deadline: "2030-01-02", priority: "HIGH", points: 80, groupId: "${groupId}", assigneeId: "${memberUserId}", requiresApproval: true }) { id } }` });
    const task2Id = createTask2.body.data.createTask.id;

    // Member completes
    const complete = await request(app.getHttpServer())
      .post('/graphql')
      .set('Authorization', `Bearer ${memberToken}`)
      .send({ query: `mutation { completeTask(input: { taskId: "${task2Id}" }) { id status } }` });
    expect(complete.body.errors).toBeUndefined();

    // Admin fetch notifications
    const adminNotifications = await request(app.getHttpServer())
      .post('/graphql')
      .set('Authorization', `Bearer ${adminToken}`)
      .send({ query: `query { myNotifications { total items { id title type relatedEntityId } } }` });
    expect(adminNotifications.body.errors).toBeUndefined();
    const pendingReview = adminNotifications.body.data.myNotifications.items.find((n: any) => n.relatedEntityId === task2Id);
    expect(pendingReview).toBeDefined();
  });

  it('Admin approves task and member sees approval notification then marks it read', async () => {
    // Create a third task requiring approval
    const createTask3 = await request(app.getHttpServer())
      .post('/graphql')
      .set('Authorization', `Bearer ${adminToken}`)
      .send({ query: `mutation { createTask(input: { title: "Approve Me", deadline: "2030-01-03", priority: "LOW", points: 30, groupId: "${groupId}", assigneeId: "${memberUserId}", requiresApproval: true }) { id } }` });
    const task3Id = createTask3.body.data.createTask.id;

    // Member completes
    await request(app.getHttpServer())
      .post('/graphql')
      .set('Authorization', `Bearer ${memberToken}`)
      .send({ query: `mutation { completeTask(input: { taskId: "${task3Id}" }) { id status } }` });

    // Admin approves
    await request(app.getHttpServer())
      .post('/graphql')
      .set('Authorization', `Bearer ${adminToken}`)
      .send({ query: `mutation { approveTask(input: { taskId: "${task3Id}", approved: true }) { id status } }` });

    // Member fetch notifications looking for TASK_APPROVED
    const memberNotifications = await request(app.getHttpServer())
      .post('/graphql')
      .set('Authorization', `Bearer ${memberToken}`)
      .send({ query: `query { myNotifications { items { id type relatedEntityId isRead } } }` });

    const approvalNotif = memberNotifications.body.data.myNotifications.items.find((n: any) => n.relatedEntityId === task3Id && n.type === 'TASK_APPROVED');
    expect(approvalNotif).toBeDefined();

    // Mark it read
    const markRead = await request(app.getHttpServer())
      .post('/graphql')
      .set('Authorization', `Bearer ${memberToken}`)
      .send({ query: `mutation { markNotificationsRead(input: { ids: ["${approvalNotif.id}"] }) }` });
    expect(markRead.body.errors).toBeUndefined();

    // Fetch again to ensure isRead toggled
    const after = await request(app.getHttpServer())
      .post('/graphql')
      .set('Authorization', `Bearer ${memberToken}`)
      .send({ query: `query { myNotifications { items { id type relatedEntityId isRead } } }` });
    const reread = after.body.data.myNotifications.items.find((n: any) => n.id === approvalNotif.id);
    expect(reread.isRead).toBe(true);
  });

  it('Reward request creates admin notification and rejection creates member notification', async () => {
    // Create reward
    const createReward = await request(app.getHttpServer())
      .post('/graphql')
      .set('Authorization', `Bearer ${adminToken}`)
      .send({ query: `mutation { createReward(input: { groupId: "${groupId}", name: "Sticker", cost: 10 }) { id } }` });
    const rewardId = createReward.body.data.createReward.id;

    // Member earns points: create a quick auto-approval task
    const earnTask = await request(app.getHttpServer())
      .post('/graphql')
      .set('Authorization', `Bearer ${adminToken}`)
      .send({ query: `mutation { createTask(input: { title: "EarnQuick", deadline: "2030-02-01", priority: "LOW", points: 20, groupId: "${groupId}", assigneeId: "${memberUserId}", requiresApproval: false }) { id } }` });
    const earnTaskId = earnTask.body.data.createTask.id;
    await request(app.getHttpServer())
      .post('/graphql')
      .set('Authorization', `Bearer ${memberToken}`)
      .send({ query: `mutation { completeTask(input: { taskId: "${earnTaskId}" }) { id status } }` });

    // Member requests reward (admin should get REWARD_REQUESTED)
    const requestReward = await request(app.getHttpServer())
      .post('/graphql')
      .set('Authorization', `Bearer ${memberToken}`)
      .send({ query: `mutation { requestReward(input: { rewardId: "${rewardId}" }) { id status } }` });
    const rewardTransactionId = requestReward.body.data.requestReward.id;

    // Admin notifications should include REWARD_REQUESTED
    const adminNotifs = await request(app.getHttpServer())
      .post('/graphql')
      .set('Authorization', `Bearer ${adminToken}`)
      .send({ query: `query { myNotifications { items { id type relatedEntityId } } }` });
    const rewardRequested = adminNotifs.body.data.myNotifications.items.find((n: any) => n.relatedEntityId === rewardTransactionId && n.type === 'REWARD_REQUESTED');
    expect(rewardRequested).toBeDefined();

    // Admin rejects request
    await request(app.getHttpServer())
      .post('/graphql')
      .set('Authorization', `Bearer ${adminToken}`)
      .send({ query: `mutation { approveRewardRequest(input: { requestId: "${rewardTransactionId}", approved: false, reason: "Out of stock" }) { id status } }` });

    // Member sees REWARD_REJECTED
    const memberNotifsAfter = await request(app.getHttpServer())
      .post('/graphql')
      .set('Authorization', `Bearer ${memberToken}`)
      .send({ query: `query { myNotifications { items { id type relatedEntityId } } }` });
    const rewardRejected = memberNotifsAfter.body.data.myNotifications.items.find((n: any) => n.relatedEntityId === rewardTransactionId && n.type === 'REWARD_REJECTED');
    expect(rewardRejected).toBeDefined();
  });
});
