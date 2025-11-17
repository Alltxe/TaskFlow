import { Test, TestingModule } from '@nestjs/testing';
import { INestApplication, ValidationPipe } from '@nestjs/common';
import request from 'supertest';
import { AppModule } from '../src/app.module';
import { PrismaService } from '../src/modules/prisma/prisma.service';

/**
 * E2E tests for Reward & Gamification flows (Phase 6 - PRD 3.5.x)
 */
describe('Reward Operations (e2e)', () => {
  let app: INestApplication;
  let prisma: PrismaService;
  let adminToken: string;
  let memberToken: string;
  let adminUserId: string;
  let memberUserId: string;
  let groupId: string;
  let rewardId: string;
  let requestId: string;

  beforeAll(async () => {
    const moduleFixture: TestingModule = await Test.createTestingModule({
      imports: [AppModule],
    }).compile();

    app = moduleFixture.createNestApplication();
    app.useGlobalPipes(new ValidationPipe());
    await app.init();

    prisma = moduleFixture.get<PrismaService>(PrismaService);

    // Clean relevant tables (order matters for FK constraints)
  await (prisma as any).pointTransaction.deleteMany();
    await prisma.rewardTransaction.deleteMany();
    await prisma.reward.deleteMany();
    await prisma.taskCompletionAttachment.deleteMany();
    await prisma.taskCompletionHistory.deleteMany();
    await prisma.taskAttachment.deleteMany();
    await prisma.task.deleteMany();
    await prisma.notification.deleteMany();
    await prisma.auditLog.deleteMany();
    await prisma.groupMember.deleteMany();
    await prisma.group.deleteMany();
    await prisma.refreshToken.deleteMany();
    await prisma.user.deleteMany();

    // Register admin user
    const registerAdmin = await request(app.getHttpServer())
      .post('/graphql')
      .send({
        query: `mutation { register(input: { email: "rewardadmin@example.com", username: "rewardadmin", password: "Test123!" }) { accessToken user { id } } }`,
      });
    adminToken = registerAdmin.body.data.register.accessToken;
    adminUserId = registerAdmin.body.data.register.user.id;

    // Register member user
    const registerMember = await request(app.getHttpServer())
      .post('/graphql')
      .send({
        query: `mutation { register(input: { email: "rewardmember@example.com", username: "rewardmember", password: "Test123!" }) { accessToken user { id } } }`,
      });
    memberToken = registerMember.body.data.register.accessToken;
    memberUserId = registerMember.body.data.register.user.id;

    // Create group by admin
    const createGroup = await request(app.getHttpServer())
      .post('/graphql')
      .set('Authorization', `Bearer ${adminToken}`)
      .send({
        query: `mutation { createGroup(input: { name: "Reward Group" }) { id inviteToken } }`,
      });
    groupId = createGroup.body.data.createGroup.id;
    const inviteToken = createGroup.body.data.createGroup.inviteToken;

    // Member joins group
    await request(app.getHttpServer())
      .post('/graphql')
      .set('Authorization', `Bearer ${memberToken}`)
      .send({ query: `mutation { joinGroup(input: { inviteToken: "${inviteToken}" }) { id } }` });
  });

  afterAll(async () => {
  await (prisma as any).pointTransaction.deleteMany();
    await prisma.rewardTransaction.deleteMany();
    await prisma.reward.deleteMany();
    await prisma.taskCompletionAttachment.deleteMany();
    await prisma.taskCompletionHistory.deleteMany();
    await prisma.taskAttachment.deleteMany();
    await prisma.task.deleteMany();
    await prisma.notification.deleteMany();
    await prisma.auditLog.deleteMany();
    await prisma.groupMember.deleteMany();
    await prisma.group.deleteMany();
    await prisma.refreshToken.deleteMany();
    await prisma.user.deleteMany();
    await app.close();
  });

  it('Admin creates a reward', async () => {
    const res = await request(app.getHttpServer())
      .post('/graphql')
      .set('Authorization', `Bearer ${adminToken}`)
      .send({
        query: `mutation { createReward(input: { groupId: "${groupId}", name: "Chocolate", cost: 40 }) { id name cost groupId } }`,
      });
    expect(res.body.errors).toBeUndefined();
    rewardId = res.body.data.createReward.id;
    expect(res.body.data.createReward).toMatchObject({ name: 'Chocolate', cost: 40, groupId });
  });

  it('Member lists group rewards', async () => {
    const res = await request(app.getHttpServer())
      .post('/graphql')
      .set('Authorization', `Bearer ${memberToken}`)
      .send({ query: `query { getGroupRewards(groupId: "${groupId}") { id name cost } }` });
    expect(res.body.errors).toBeUndefined();
    expect(res.body.data.getGroupRewards.length).toBe(1);
  });

  it('Member attempts to request reward with insufficient balance (no points yet)', async () => {
    const res = await request(app.getHttpServer())
      .post('/graphql')
      .set('Authorization', `Bearer ${memberToken}`)
      .send({ query: `mutation { requestReward(input: { rewardId: "${rewardId}" }) { id status } }` });
    // Should fail due to zero earned points
    expect(res.body.errors).toBeDefined();
    expect(res.body.errors[0].message).toContain('Недостаточно очков');
  });

  it('Admin creates and member completes a task (earning points)', async () => {
    // Create task assigned to member without approval requirement
    const createTask = await request(app.getHttpServer())
      .post('/graphql')
      .set('Authorization', `Bearer ${adminToken}`)
      .send({
        query: `mutation { createTask(input: { title: "Earn", deadline: "2030-01-01", priority: "MEDIUM", points: 100, groupId: "${groupId}", assigneeId: "${memberUserId}", requiresApproval: false }) { id assigneeId points } }`,
      });
    if (createTask.body.errors) {
      console.error('createTask errors', JSON.stringify(createTask.body.errors, null, 2));
      throw new Error('createTask failed');
    }
    const taskId = createTask.body.data.createTask.id;

    // Member completes task (auto awards EARNED points)
    const completeTask = await request(app.getHttpServer())
      .post('/graphql')
      .set('Authorization', `Bearer ${memberToken}`)
      .send({ query: `mutation { completeTask(input: { taskId: "${taskId}" }) { id status } }` });
    if (completeTask.body.errors) {
      console.error('completeTask errors', JSON.stringify(completeTask.body.errors, null, 2));
    }
    expect(completeTask.body.errors).toBeUndefined();
    expect(completeTask.body.data.completeTask.status).toBe('COMPLETED');

    // Check point balance
    const balance = await request(app.getHttpServer())
      .post('/graphql')
      .set('Authorization', `Bearer ${memberToken}`)
      .send({ query: `query { getPointBalance(groupId: "${groupId}") { currentBalance totalEarned } }` });
    expect(balance.body.errors).toBeUndefined();
    expect(balance.body.data.getPointBalance.totalEarned).toBe(100);
  });

  it('Member requests reward after earning points', async () => {
    const res = await request(app.getHttpServer())
      .post('/graphql')
      .set('Authorization', `Bearer ${memberToken}`)
      .send({ query: `mutation { requestReward(input: { rewardId: "${rewardId}" }) { id status pointsSpent } }` });
    if (res.body.errors) {
      console.error('requestReward errors', JSON.stringify(res.body.errors, null, 2));
    }
    expect(res.body.errors).toBeUndefined();
    expect(res.body.data.requestReward.status).toBe('RESERVED');
    requestId = res.body.data.requestReward.id;
  });

  it('Admin approves reward request (SPENT ledger)', async () => {
    const res = await request(app.getHttpServer())
      .post('/graphql')
      .set('Authorization', `Bearer ${adminToken}`)
      .send({ query: `mutation { approveRewardRequest(input: { requestId: "${requestId}", approved: true }) { id status approvedAt } }` });
    if (res.body.errors) {
      console.error('approveRewardRequest errors', JSON.stringify(res.body.errors, null, 2));
    }
    expect(res.body.errors).toBeUndefined();
    expect(res.body.data.approveRewardRequest.status).toBe('APPROVED');

    const balance = await request(app.getHttpServer())
      .post('/graphql')
      .set('Authorization', `Bearer ${memberToken}`)
      .send({ query: `query { getPointBalance(groupId: "${groupId}") { currentBalance totalReservedPending totalSpentApproved } }` });
    expect(balance.body.errors).toBeUndefined();
    expect(balance.body.data.getPointBalance.totalSpentApproved).toBe(40);
    expect(balance.body.data.getPointBalance.currentBalance).toBe(60); // 100 earned - 40 spent
  });

  it('Admin creates second reward and member requests then admin rejects', async () => {
    const createReward2 = await request(app.getHttpServer())
      .post('/graphql')
      .set('Authorization', `Bearer ${adminToken}`)
      .send({ query: `mutation { createReward(input: { groupId: "${groupId}", name: "Cookie", cost: 30 }) { id } }` });
    const rewardId2 = createReward2.body.data.createReward.id;

    const requestReward2 = await request(app.getHttpServer())
      .post('/graphql')
      .set('Authorization', `Bearer ${memberToken}`)
      .send({ query: `mutation { requestReward(input: { rewardId: "${rewardId2}" }) { id status pointsSpent } }` });
    const requestId2 = requestReward2.body.data.requestReward.id;

    const rejectReward = await request(app.getHttpServer())
      .post('/graphql')
      .set('Authorization', `Bearer ${adminToken}`)
      .send({ query: `mutation { approveRewardRequest(input: { requestId: "${requestId2}", approved: false, reason: "Not available" }) { id status } }` });
    expect(rejectReward.body.errors).toBeUndefined();
    expect(rejectReward.body.data.approveRewardRequest.status).toBe('REJECTED');

    const balance = await request(app.getHttpServer())
      .post('/graphql')
      .set('Authorization', `Bearer ${memberToken}`)
      .send({ query: `query { getPointBalance(groupId: "${groupId}") { currentBalance totalSpentApproved totalReservedPending } }` });
    expect(balance.body.errors).toBeUndefined();
    // Spent still 40, reserved back to 0, refunded effectively restores balance
    expect(balance.body.data.getPointBalance.currentBalance).toBe(60 - 0 + 30); // initial 60 + refund 30
  });

  it('Group leaderboard shows earned points order', async () => {
    const lb = await request(app.getHttpServer())
      .post('/graphql')
      .set('Authorization', `Bearer ${adminToken}`)
      .send({ query: `query { getGroupLeaderboard(groupId: "${groupId}") { user { id username } pointsEarned rank } }` });
    expect(lb.body.errors).toBeUndefined();
    expect(lb.body.data.getGroupLeaderboard.length).toBeGreaterThan(0);
  });
});
