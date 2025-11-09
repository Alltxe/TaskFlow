import { Test, TestingModule } from '@nestjs/testing';
import { INestApplication, ValidationPipe } from '@nestjs/common';
import request from 'supertest';
import { AppModule } from '../src/app.module';
import { PrismaService } from '../src/modules/prisma/prisma.service';

describe('Task Operations (e2e)', () => {
  let app: INestApplication;
  let prismaService: PrismaService;
  let adminToken: string;
  let memberToken: string;
  let adminId: string;
  let memberId: string;
  let groupId: string;
  let taskId: string;

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
    await prismaService.user.deleteMany();

    // Register admin user
    const adminResponse = await request(app.getHttpServer())
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
            email: 'taskadmin@example.com',
            username: 'taskadmin',
            password: 'Test123!@#',
          },
        },
      });

    adminToken = adminResponse.body.data.register.accessToken;
    adminId = adminResponse.body.data.register.user.id;

    // Register member user
    const memberResponse = await request(app.getHttpServer())
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
            email: 'taskmember@example.com',
            username: 'taskmember',
            password: 'Test123!@#',
          },
        },
      });

    memberToken = memberResponse.body.data.register.accessToken;
    memberId = memberResponse.body.data.register.user.id;

    // Create a group as admin
    const createGroupResponse = await request(app.getHttpServer())
      .post('/graphql')
      .set('Authorization', `Bearer ${adminToken}`)
      .send({
        query: `
          mutation CreateGroup($input: CreateGroupInput!) {
            createGroup(input: $input) {
              id
              name
              inviteToken
            }
          }
        `,
        variables: {
          input: {
            name: 'Task Test Group',
            requiresApproval: true,
            rotationType: 'ROUND_ROBIN',
            gamificationEnabled: true,
          },
        },
      });

    groupId = createGroupResponse.body.data.createGroup.id;
    const inviteToken = createGroupResponse.body.data.createGroup.inviteToken;

    // Member joins the group
    const joinResponse = await request(app.getHttpServer())
      .post('/graphql')
      .set('Authorization', `Bearer ${memberToken}`)
      .send({
        query: `
          mutation JoinGroup($input: JoinGroupInput!) {
            joinGroup(input: $input) {
              id
              name
            }
          }
        `,
        variables: {
          input: {
            inviteToken: inviteToken,
          },
        },
      });

    // Verify member joined successfully
    if (joinResponse.body.errors) {
      console.log('Join Group Errors:', JSON.stringify(joinResponse.body.errors, null, 2));
      throw new Error('Failed to join group');
    }
  });

  afterAll(async () => {
    // Clean up in correct order
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
    await prismaService.user.deleteMany();

    await app.close();
  });

  // ===================================
  // Task CRUD Operations (PRD 3.3.1)
  // ===================================

  describe('Task CRUD Operations', () => {
    it('should allow admin to create a task', async () => {
      const response = await request(app.getHttpServer())
        .post('/graphql')
        .set('Authorization', `Bearer ${adminToken}`)
        .send({
          query: `
            mutation CreateTask($input: CreateTaskInput!) {
              createTask(input: $input) {
                id
                title
                description
                priority
                points
                status
                requiresApproval
                assignee {
                  id
                  username
                }
                createdBy {
                  id
                  username
                }
              }
            }
          `,
          variables: {
            input: {
              title: 'Test Task 1',
              description: 'This is a test task',
              deadline: new Date(Date.now() + 86400000).toISOString(), // Tomorrow
              priority: 'MEDIUM',
              points: 100,
              requiresApproval: true,
              groupId: groupId,
              assigneeId: memberId,
            },
          },
        });

      expect(response.status).toBe(200);
      if (response.body.errors) {
        console.log('GraphQL Errors:', JSON.stringify(response.body.errors, null, 2));
      }
      expect(response.body.errors).toBeUndefined();
      expect(response.body.data.createTask).toBeDefined();
      expect(response.body.data.createTask.title).toBe('Test Task 1');
      expect(response.body.data.createTask.status).toBe('PENDING');
      expect(response.body.data.createTask.assignee.id).toBe(memberId);
      expect(response.body.data.createTask.createdBy.id).toBe(adminId);

      taskId = response.body.data.createTask.id;
    });

    it('should NOT allow non-admin to create a task', async () => {
      const response = await request(app.getHttpServer())
        .post('/graphql')
        .set('Authorization', `Bearer ${memberToken}`)
        .send({
          query: `
            mutation CreateTask($input: CreateTaskInput!) {
              createTask(input: $input) {
                id
                title
              }
            }
          `,
          variables: {
            input: {
              title: 'Unauthorized Task',
              description: 'Should fail',
              deadline: new Date(Date.now() + 86400000).toISOString(),
              priority: 'LOW',
              points: 50,
              groupId: groupId,
            },
          },
        });

      expect(response.status).toBe(200);
      expect(response.body.errors).toBeDefined();
      expect(response.body.errors[0].message).toContain('администраторы');
    });

    it('should allow admin to update a task', async () => {
      const response = await request(app.getHttpServer())
        .post('/graphql')
        .set('Authorization', `Bearer ${adminToken}`)
        .send({
          query: `
            mutation UpdateTask($taskId: String!, $input: UpdateTaskInput!) {
              updateTask(taskId: $taskId, input: $input) {
                id
                title
                description
                priority
              }
            }
          `,
          variables: {
            taskId: taskId,
            input: {
              title: 'Updated Task Title',
              description: 'Updated description',
              priority: 'HIGH',
            },
          },
        });

      expect(response.status).toBe(200);
      expect(response.body.data.updateTask.title).toBe('Updated Task Title');
      expect(response.body.data.updateTask.priority).toBe('HIGH');
    });

    it('should allow admin to delete a task', async () => {
      // Create a task to delete
      const createResponse = await request(app.getHttpServer())
        .post('/graphql')
        .set('Authorization', `Bearer ${adminToken}`)
        .send({
          query: `
            mutation CreateTask($input: CreateTaskInput!) {
              createTask(input: $input) {
                id
              }
            }
          `,
          variables: {
            input: {
              title: 'Task to Delete',
              description: 'Will be deleted',
              deadline: new Date(Date.now() + 86400000).toISOString(),
              priority: 'LOW',
              points: 50,
              groupId: groupId,
            },
          },
        });

      const deleteTaskId = createResponse.body.data.createTask.id;

      const deleteResponse = await request(app.getHttpServer())
        .post('/graphql')
        .set('Authorization', `Bearer ${adminToken}`)
        .send({
          query: `
            mutation DeleteTask($taskId: String!) {
              deleteTask(taskId: $taskId)
            }
          `,
          variables: {
            taskId: deleteTaskId,
          },
        });

      expect(deleteResponse.status).toBe(200);
      expect(deleteResponse.body.data.deleteTask).toBe(true);
    });

    it('should retrieve group tasks', async () => {
      const response = await request(app.getHttpServer())
        .post('/graphql')
        .set('Authorization', `Bearer ${adminToken}`)
        .send({
          query: `
            query GetGroupTasks($groupId: String!) {
              getGroupTasks(groupId: $groupId) {
                id
                title
                status
                assignee {
                  id
                  username
                }
              }
            }
          `,
          variables: {
            groupId: groupId,
          },
        });

      expect(response.status).toBe(200);
      expect(response.body.data.getGroupTasks).toBeDefined();
      expect(Array.isArray(response.body.data.getGroupTasks)).toBe(true);
      expect(response.body.data.getGroupTasks.length).toBeGreaterThan(0);
    });

    it('should retrieve user tasks', async () => {
      const response = await request(app.getHttpServer())
        .post('/graphql')
        .set('Authorization', `Bearer ${memberToken}`)
        .send({
          query: `
            query GetUserTasks {
              getUserTasks {
                id
                title
                status
                assignee {
                  id
                  username
                }
              }
            }
          `,
        });

      expect(response.status).toBe(200);
      expect(response.body.data.getUserTasks).toBeDefined();
      expect(Array.isArray(response.body.data.getUserTasks)).toBe(true);
    });
  });

  // ================================================
  // Task State Machine (PRD 3.3.4)
  // ================================================

  describe('Task State Transitions', () => {
    let stateTaskId: string;

    beforeEach(async () => {
      // Create a fresh task for each state transition test
      const response = await request(app.getHttpServer())
        .post('/graphql')
        .set('Authorization', `Bearer ${adminToken}`)
        .send({
          query: `
            mutation CreateTask($input: CreateTaskInput!) {
              createTask(input: $input) {
                id
                status
              }
            }
          `,
          variables: {
            input: {
              title: 'State Test Task',
              description: 'Testing state transitions',
              deadline: new Date(Date.now() + 86400000).toISOString(),
              priority: 'MEDIUM',
              points: 100,
              requiresApproval: true,
              groupId: groupId,
              assigneeId: memberId,
            },
          },
        });

      stateTaskId = response.body.data.createTask.id;
    });

    it('should transition from PENDING to AWAITING_APPROVAL when member completes task', async () => {
      const response = await request(app.getHttpServer())
        .post('/graphql')
        .set('Authorization', `Bearer ${memberToken}`)
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
              taskId: stateTaskId,
            },
          },
        });

      expect(response.status).toBe(200);
      expect(response.body.data.completeTask.status).toBe('AWAITING_APPROVAL');
    });

    it('should transition from AWAITING_APPROVAL to COMPLETED when admin approves', async () => {
      // First, member completes the task
      await request(app.getHttpServer())
        .post('/graphql')
        .set('Authorization', `Bearer ${memberToken}`)
        .send({
          query: `
            mutation CompleteTask($input: CompleteTaskInput!) {
              completeTask(input: $input) {
                id
              }
            }
          `,
          variables: {
            input: {
              taskId: stateTaskId,
            },
          },
        });

      // Then admin approves
      const approveResponse = await request(app.getHttpServer())
        .post('/graphql')
        .set('Authorization', `Bearer ${adminToken}`)
        .send({
          query: `
            mutation ApproveTask($input: ApproveTaskInput!) {
              approveTask(input: $input) {
                id
                status
                completedAt
              }
            }
          `,
          variables: {
            input: {
              taskId: stateTaskId,
              approved: true,
            },
          },
        });

      expect(approveResponse.status).toBe(200);
      expect(approveResponse.body.data.approveTask.status).toBe('COMPLETED');
      expect(approveResponse.body.data.approveTask.completedAt).toBeDefined();
    });

    it('should transition from AWAITING_APPROVAL back to PENDING when admin rejects', async () => {
      // Member completes the task
      await request(app.getHttpServer())
        .post('/graphql')
        .set('Authorization', `Bearer ${memberToken}`)
        .send({
          query: `
            mutation CompleteTask($input: CompleteTaskInput!) {
              completeTask(input: $input) {
                id
              }
            }
          `,
          variables: {
            input: {
              taskId: stateTaskId,
            },
          },
        });

      // Admin rejects
      const rejectResponse = await request(app.getHttpServer())
        .post('/graphql')
        .set('Authorization', `Bearer ${adminToken}`)
        .send({
          query: `
            mutation ApproveTask($input: ApproveTaskInput!) {
              approveTask(input: $input) {
                id
                status
              }
            }
          `,
          variables: {
            input: {
              taskId: stateTaskId,
              approved: false,
            },
          },
        });

      expect(rejectResponse.status).toBe(200);
      expect(rejectResponse.body.data.approveTask.status).toBe('PENDING');
    });

    it('should NOT allow non-assignee to complete a task', async () => {
      const response = await request(app.getHttpServer())
        .post('/graphql')
        .set('Authorization', `Bearer ${adminToken}`) // Admin, not assignee
        .send({
          query: `
            mutation CompleteTask($input: CompleteTaskInput!) {
              completeTask(input: $input) {
                id
              }
            }
          `,
          variables: {
            input: {
              taskId: stateTaskId,
            },
          },
        });

      expect(response.status).toBe(200);
      expect(response.body.errors).toBeDefined();
      expect(response.body.errors[0].message).toContain('исполнитель');
    });

    it('should NOT allow non-admin to approve a task', async () => {
      // Member completes the task
      await request(app.getHttpServer())
        .post('/graphql')
        .set('Authorization', `Bearer ${memberToken}`)
        .send({
          query: `
            mutation CompleteTask($input: CompleteTaskInput!) {
              completeTask(input: $input) {
                id
              }
            }
          `,
          variables: {
            input: {
              taskId: stateTaskId,
            },
          },
        });

      // Member tries to approve (should fail)
      const approveResponse = await request(app.getHttpServer())
        .post('/graphql')
        .set('Authorization', `Bearer ${memberToken}`)
        .send({
          query: `
            mutation ApproveTask($input: ApproveTaskInput!) {
              approveTask(input: $input) {
                id
              }
            }
          `,
          variables: {
            input: {
              taskId: stateTaskId,
              approved: true,
            },
          },
        });

      expect(approveResponse.status).toBe(200);
      expect(approveResponse.body.errors).toBeDefined();
      expect(approveResponse.body.errors[0].message).toContain('администраторы');
    });
  });

  // ================================================
  // Task Completion and Point Awards (PRD 3.5.1-3.5.2, 3.6.1-3.6.2)
  // ================================================

  describe('Task Completion and Point Awards', () => {
    it('should create TaskCompletionHistory when task is approved', async () => {
      // Create task
      const createResponse = await request(app.getHttpServer())
        .post('/graphql')
        .set('Authorization', `Bearer ${adminToken}`)
        .send({
          query: `
            mutation CreateTask($input: CreateTaskInput!) {
              createTask(input: $input) {
                id
              }
            }
          `,
          variables: {
            input: {
              title: 'Points Test Task',
              description: 'Testing point awards',
              deadline: new Date(Date.now() + 86400000).toISOString(),
              priority: 'HIGH',
              points: 150,
              requiresApproval: true,
              groupId: groupId,
              assigneeId: memberId,
            },
          },
        });

      const pointsTaskId = createResponse.body.data.createTask.id;

      // Member completes
      await request(app.getHttpServer())
        .post('/graphql')
        .set('Authorization', `Bearer ${memberToken}`)
        .send({
          query: `
            mutation CompleteTask($input: CompleteTaskInput!) {
              completeTask(input: $input) {
                id
              }
            }
          `,
          variables: {
            input: {
              taskId: pointsTaskId,
            },
          },
        });

      // Admin approves
      await request(app.getHttpServer())
        .post('/graphql')
        .set('Authorization', `Bearer ${adminToken}`)
        .send({
          query: `
            mutation ApproveTask($input: ApproveTaskInput!) {
              approveTask(input: $input) {
                id
              }
            }
          `,
          variables: {
            input: {
              taskId: pointsTaskId,
              approved: true,
            },
          },
        });

      // Verify completion history exists
      const history = await prismaService.taskCompletionHistory.findFirst({
        where: {
          taskId: pointsTaskId,
          userId: memberId,
        },
      });

      expect(history).toBeDefined();
      expect(history!.pointsAwarded).toBe(150);
      expect(history!.wasOnTime).toBe(true);
      expect(history!.approvedById).toBe(adminId);
    });

    it('should auto-complete task without approval if requiresApproval is false', async () => {
      // Create task without approval requirement
      const createResponse = await request(app.getHttpServer())
        .post('/graphql')
        .set('Authorization', `Bearer ${adminToken}`)
        .send({
          query: `
            mutation CreateTask($input: CreateTaskInput!) {
              createTask(input: $input) {
                id
              }
            }
          `,
          variables: {
            input: {
              title: 'Auto-Complete Task',
              description: 'No approval needed',
              deadline: new Date(Date.now() + 86400000).toISOString(),
              priority: 'LOW',
              points: 50,
              requiresApproval: false,
              groupId: groupId,
              assigneeId: memberId,
            },
          },
        });

      const autoTaskId = createResponse.body.data.createTask.id;

      // Member completes - should go directly to COMPLETED
      const completeResponse = await request(app.getHttpServer())
        .post('/graphql')
        .set('Authorization', `Bearer ${memberToken}`)
        .send({
          query: `
            mutation CompleteTask($input: CompleteTaskInput!) {
              completeTask(input: $input) {
                id
                status
                completedAt
              }
            }
          `,
          variables: {
            input: {
              taskId: autoTaskId,
            },
          },
        });

      expect(completeResponse.status).toBe(200);
      expect(completeResponse.body.data.completeTask.status).toBe('COMPLETED');
      expect(completeResponse.body.data.completeTask.completedAt).toBeDefined();

      // Verify completion history
      const history = await prismaService.taskCompletionHistory.findFirst({
        where: {
          taskId: autoTaskId,
        },
      });

      expect(history).toBeDefined();
      expect(history!.pointsAwarded).toBe(50);
    });
  });

  // ================================================
  // Rotation Algorithms (PRD 3.4.1)
  // ================================================

  describe('Rotation Algorithms', () => {
    it('should assign tasks using Round Robin algorithm', async () => {
      // Create group with Round Robin rotation
      const groupResponse = await request(app.getHttpServer())
        .post('/graphql')
        .set('Authorization', `Bearer ${adminToken}`)
        .send({
          query: `
            mutation CreateGroup($input: CreateGroupInput!) {
              createGroup(input: $input) {
                id
                rotationType
                inviteToken
              }
            }
          `,
          variables: {
            input: {
              name: 'Round Robin Group',
              requiresApproval: false,
              rotationType: 'ROUND_ROBIN',
              gamificationEnabled: true,
            },
          },
        });

      const rrGroupId = groupResponse.body.data.createGroup.id;
      const rrInviteToken = groupResponse.body.data.createGroup.inviteToken;

      // Member joins
      await request(app.getHttpServer())
        .post('/graphql')
        .set('Authorization', `Bearer ${memberToken}`)
        .send({
          query: `
            mutation JoinGroup($input: JoinGroupInput!) {
              joinGroup(input: $input) {
                id
              }
            }
          `,
          variables: {
            input: {
              inviteToken: rrInviteToken,
            },
          },
        });

      // Create first task without assignee (should auto-assign via Round Robin)
      const task1Response = await request(app.getHttpServer())
        .post('/graphql')
        .set('Authorization', `Bearer ${adminToken}`)
        .send({
          query: `
            mutation CreateTask($input: CreateTaskInput!) {
              createTask(input: $input) {
                id
                assignee {
                  id
                }
              }
            }
          `,
          variables: {
            input: {
              title: 'RR Task 1',
              description: 'First task',
              deadline: new Date(Date.now() + 86400000).toISOString(),
              priority: 'MEDIUM',
              points: 100,
              groupId: rrGroupId,
            },
          },
        });

      const firstAssigneeId = task1Response.body.data.createTask.assignee.id;
      expect(firstAssigneeId).toBeDefined();

      // Create second task - should assign to the other member
      const task2Response = await request(app.getHttpServer())
        .post('/graphql')
        .set('Authorization', `Bearer ${adminToken}`)
        .send({
          query: `
            mutation CreateTask($input: CreateTaskInput!) {
              createTask(input: $input) {
                id
                assignee {
                  id
                }
              }
            }
          `,
          variables: {
            input: {
              title: 'RR Task 2',
              description: 'Second task',
              deadline: new Date(Date.now() + 86400000).toISOString(),
              priority: 'MEDIUM',
              points: 100,
              groupId: rrGroupId,
            },
          },
        });

      const secondAssigneeId = task2Response.body.data.createTask.assignee.id;
      expect(secondAssigneeId).toBeDefined();
      expect(secondAssigneeId).not.toBe(firstAssigneeId); // Should be different
    });

    it('should skip users marked as away in rotation', async () => {
      // Mark member as away
      await prismaService.user.update({
        where: { id: memberId },
        data: {
          isAway: true,
          awayUntil: new Date(Date.now() + 86400000),
        },
      });

      // Create task - should assign to admin (only available user)
      const taskResponse = await request(app.getHttpServer())
        .post('/graphql')
        .set('Authorization', `Bearer ${adminToken}`)
        .send({
          query: `
            mutation CreateTask($input: CreateTaskInput!) {
              createTask(input: $input) {
                id
                assignee {
                  id
                }
              }
            }
          `,
          variables: {
            input: {
              title: 'Away Test Task',
              description: 'Testing away user skip',
              deadline: new Date(Date.now() + 86400000).toISOString(),
              priority: 'MEDIUM',
              points: 100,
              groupId: groupId,
            },
          },
        });

      const assigneeId = taskResponse.body.data.createTask.assignee?.id;
      expect(assigneeId).toBe(adminId); // Should assign to admin, not away member

      // Reset member away status
      await prismaService.user.update({
        where: { id: memberId },
        data: {
          isAway: false,
          awayUntil: null,
        },
      });
    });

    it('should use load balancing to assign to lowest accumulated weight when imbalance >= 2x', async () => {
      // Create load balancing group
      const lbGroupResponse = await request(app.getHttpServer())
        .post('/graphql')
        .set('Authorization', `Bearer ${adminToken}`)
        .send({
          query: `
            mutation CreateGroup($input: CreateGroupInput!) {
              createGroup(input: $input) { id inviteToken rotationType }
            }
          `,
          variables: {
            input: {
              name: 'Load Balancing Group',
              requiresApproval: false,
              rotationType: 'LOAD_BALANCING',
              gamificationEnabled: true,
            },
          },
        });

      const lbGroupId = lbGroupResponse.body.data.createGroup.id;
      const lbInviteToken = lbGroupResponse.body.data.createGroup.inviteToken;

      // Member joins LB group
      await request(app.getHttpServer())
        .post('/graphql')
        .set('Authorization', `Bearer ${memberToken}`)
        .send({
          query: `
            mutation JoinGroup($input: JoinGroupInput!) { joinGroup(input: $input) { id } }
          `,
          variables: { input: { inviteToken: lbInviteToken } },
        });

      // Simulate prior completions to create imbalance: admin has high accumulated weight
      // We create tasks already completed assigned to admin.
      for (let i = 0; i < 3; i++) {
        const heavyTaskResponse = await request(app.getHttpServer())
          .post('/graphql')
          .set('Authorization', `Bearer ${adminToken}`)
          .send({
            query: `
              mutation CreateTask($input: CreateTaskInput!) { createTask(input: $input) { id } }
            `,
            variables: {
              input: {
                title: `Heavy Admin Task ${i+1}`,
                deadline: new Date(Date.now() + 86400000).toISOString(),
                priority: 'MEDIUM',
                points: 50,
                groupId: lbGroupId,
                assigneeId: adminId,
                weight: 10,
                rotationType: 'LOAD_BALANCING'
              },
            },
          });
        const heavyTaskId = heavyTaskResponse.body.data.createTask.id;
        // Complete to record completion history (group requiresApproval=false)
        await request(app.getHttpServer())
          .post('/graphql')
          .set('Authorization', `Bearer ${adminToken}`)
          .send({
            query: `mutation CompleteTask($input: CompleteTaskInput!) { completeTask(input: $input) { id status } }`,
            variables: { input: { taskId: heavyTaskId } },
          });
      }

      // Create new heavy task without assignee - should go to member (lowest load)
      const balancedAssignResponse = await request(app.getHttpServer())
        .post('/graphql')
        .set('Authorization', `Bearer ${adminToken}`)
        .send({
          query: `
            mutation CreateTask($input: CreateTaskInput!) { createTask(input: $input) { id assignee { id } } }
          `,
          variables: {
            input: {
              title: 'New Heavy Balanced Task',
              deadline: new Date(Date.now() + 86400000).toISOString(),
              priority: 'HIGH',
              points: 120,
              groupId: lbGroupId,
              weight: 8,
              rotationType: 'LOAD_BALANCING',
            },
          },
        });

      const assignedAssigneeId = balancedAssignResponse.body.data.createTask.assignee.id;
      expect(assignedAssigneeId).toBe(memberId); // Should prefer member due to imbalance
    });

    it('should fallback to round robin when imbalance < 2x', async () => {
      // Create load balancing group (low imbalance)
      const lb2GroupResponse = await request(app.getHttpServer())
        .post('/graphql')
        .set('Authorization', `Bearer ${adminToken}`)
        .send({
          query: `
            mutation CreateGroup($input: CreateGroupInput!) {
              createGroup(input: $input) { id inviteToken rotationType }
            }
          `,
          variables: {
            input: {
              name: 'LB Fallback Group',
              requiresApproval: false,
              rotationType: 'LOAD_BALANCING',
              gamificationEnabled: true,
            },
          },
        });

      const lb2GroupId = lb2GroupResponse.body.data.createGroup.id;
      const lb2InviteToken = lb2GroupResponse.body.data.createGroup.inviteToken;

      // Member joins
      await request(app.getHttpServer())
        .post('/graphql')
        .set('Authorization', `Bearer ${memberToken}`)
        .send({
          query: `mutation JoinGroup($input: JoinGroupInput!) { joinGroup(input: $input) { id } }`,
          variables: { input: { inviteToken: lb2InviteToken } },
        });

      // Create small balanced history: admin weight 4, member weight 3 (ratio < 2)
      // Admin completion (assignee admin)
      {
        const t = await request(app.getHttpServer())
          .post('/graphql')
          .set('Authorization', `Bearer ${adminToken}`)
          .send({
            query: `mutation CreateTask($input: CreateTaskInput!) { createTask(input: $input) { id } }`,
            variables: { input: { title: 'Admin small', deadline: new Date(Date.now()+86400000).toISOString(), priority: 'LOW', points: 10, groupId: lb2GroupId, assigneeId: adminId, weight: 4, rotationType: 'LOAD_BALANCING' } },
          });
        const id = t.body.data.createTask.id;
        await request(app.getHttpServer())
          .post('/graphql')
          .set('Authorization', `Bearer ${adminToken}`)
          .send({ query: `mutation CompleteTask($input: CompleteTaskInput!) { completeTask(input: $input) { id status } }`, variables: { input: { taskId: id } } });
      }

      // Member completion (assignee member)
      {
        const t = await request(app.getHttpServer())
          .post('/graphql')
          .set('Authorization', `Bearer ${adminToken}`)
          .send({
            query: `mutation CreateTask($input: CreateTaskInput!) { createTask(input: $input) { id } }`,
            variables: { input: { title: 'Member small', deadline: new Date(Date.now()+86400000).toISOString(), priority: 'LOW', points: 10, groupId: lb2GroupId, assigneeId: memberId, weight: 3, rotationType: 'LOAD_BALANCING' } },
          });
        const id = t.body.data.createTask.id;
        // Member must complete their assigned task
        await request(app.getHttpServer())
          .post('/graphql')
          .set('Authorization', `Bearer ${memberToken}`)
          .send({ query: `mutation CompleteTask($input: CompleteTaskInput!) { completeTask(input: $input) { id status } }`, variables: { input: { taskId: id } } });
      }

      // Now create a new task without assignee; imbalance < 2x, expect RR fallback
      // Since last assigned task was to member (in prior step), RR next should be admin
      const rrFallback = await request(app.getHttpServer())
        .post('/graphql')
        .set('Authorization', `Bearer ${adminToken}`)
        .send({
          query: `mutation CreateTask($input: CreateTaskInput!) { createTask(input: $input) { id assignee { id } } }`,
          variables: { input: { title: 'RR Fallback', deadline: new Date(Date.now()+86400000).toISOString(), priority: 'MEDIUM', points: 20, groupId: lb2GroupId, rotationType: 'LOAD_BALANCING', weight: 2 } },
        });

      const rrAssigneeId = rrFallback.body.data.createTask.assignee.id;
      expect(rrAssigneeId).toBe(adminId); // RR after member -> admin
    });
  });

  // ================================================
  // Up-for-Grabs Pool (PRD 3.4.2)
  // ================================================

  describe('Up-for-Grabs Pool (ClaimTask)', () => {
    let upForGrabsTaskId: string;

    beforeEach(async () => {
      // Create a task without assignee (Up-for-Grabs)
      const response = await request(app.getHttpServer())
        .post('/graphql')
        .set('Authorization', `Bearer ${adminToken}`)
        .send({
          query: `
            mutation CreateTask($input: CreateTaskInput!) {
              createTask(input: $input) {
                id
                assignee {
                  id
                }
              }
            }
          `,
          variables: {
            input: {
              title: 'Up-for-Grabs Task',
              description: 'Task available for claiming',
              deadline: new Date(Date.now() + 86400000).toISOString(),
              priority: 'HIGH',
              points: 200,
              groupId: groupId,
              rotationType: 'DISABLED', // Explicitly disable rotation for Up-for-Grabs
              // NO assigneeId - Up-for-Grabs!
            },
          },
        });

      upForGrabsTaskId = response.body.data.createTask.id;
    });

    it('should allow member to claim an unassigned task', async () => {
      const response = await request(app.getHttpServer())
        .post('/graphql')
        .set('Authorization', `Bearer ${memberToken}`)
        .send({
          query: `
            mutation ClaimTask($input: ClaimTaskInput!) {
              claimTask(input: $input) {
                id
                assignee {
                  id
                  username
                }
                wasClaimedFromPool
                status
              }
            }
          `,
          variables: {
            input: {
              taskId: upForGrabsTaskId,
            },
          },
        });

      expect(response.status).toBe(200);
      if (response.body.errors) {
        console.log('ClaimTask Errors:', JSON.stringify(response.body.errors, null, 2));
      }
      expect(response.body.errors).toBeUndefined();
      expect(response.body.data.claimTask.assignee.id).toBe(memberId);
      expect(response.body.data.claimTask.wasClaimedFromPool).toBe(true);
      expect(response.body.data.claimTask.status).toBe('PENDING');
    });

    it('should NOT allow claiming already assigned task', async () => {
      // First member claims it
      await request(app.getHttpServer())
        .post('/graphql')
        .set('Authorization', `Bearer ${memberToken}`)
        .send({
          query: `
            mutation ClaimTask($input: ClaimTaskInput!) {
              claimTask(input: $input) {
                id
              }
            }
          `,
          variables: {
            input: {
              taskId: upForGrabsTaskId,
            },
          },
        });

      // Admin tries to claim the same task
      const secondClaim = await request(app.getHttpServer())
        .post('/graphql')
        .set('Authorization', `Bearer ${adminToken}`)
        .send({
          query: `
            mutation ClaimTask($input: ClaimTaskInput!) {
              claimTask(input: $input) {
                id
              }
            }
          `,
          variables: {
            input: {
              taskId: upForGrabsTaskId,
            },
          },
        });

      expect(secondClaim.status).toBe(200);
      expect(secondClaim.body.errors).toBeDefined();
      expect(secondClaim.body.errors[0].message).toContain('уже назначена');
    });

    it('should award bonus points (1.5x) for claimed tasks on completion', async () => {
      // Member claims task
      await request(app.getHttpServer())
        .post('/graphql')
        .set('Authorization', `Bearer ${memberToken}`)
        .send({
          query: `
            mutation ClaimTask($input: ClaimTaskInput!) {
              claimTask(input: $input) {
                id
              }
            }
          `,
          variables: {
            input: {
              taskId: upForGrabsTaskId,
            },
          },
        });

      // Member completes task
      await request(app.getHttpServer())
        .post('/graphql')
        .set('Authorization', `Bearer ${memberToken}`)
        .send({
          query: `
            mutation CompleteTask($input: CompleteTaskInput!) {
              completeTask(input: $input) {
                id
              }
            }
          `,
          variables: {
            input: {
              taskId: upForGrabsTaskId,
            },
          },
        });

      // Admin approves
      await request(app.getHttpServer())
        .post('/graphql')
        .set('Authorization', `Bearer ${adminToken}`)
        .send({
          query: `
            mutation ApproveTask($input: ApproveTaskInput!) {
              approveTask(input: $input) {
                id
              }
            }
          `,
          variables: {
            input: {
              taskId: upForGrabsTaskId,
              approved: true,
            },
          },
        });

      // Verify points awarded with 1.5x multiplier
      const history = await prismaService.taskCompletionHistory.findFirst({
        where: {
          taskId: upForGrabsTaskId,
        },
      });

      expect(history).toBeDefined();
      expect(history!.pointsAwarded).toBe(300); // 200 * 1.5 = 300 (Up-for-Grabs bonus)
    });
  });
});
