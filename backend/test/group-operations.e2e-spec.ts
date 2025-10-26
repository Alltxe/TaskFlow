import { Test, TestingModule } from '@nestjs/testing';
import { INestApplication, ValidationPipe } from '@nestjs/common';
import request from 'supertest';
import { AppModule } from '../src/app.module';
import { PrismaService } from '../src/modules/prisma/prisma.service';

describe('Group Operations (e2e)', () => {
  let app: INestApplication;
  let prismaService: PrismaService;
  let authToken: string;
  let authToken2: string;
  let userId: string;
  let userId2: string;
  let groupId: string;
  let inviteToken: string;

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

    // Register and login first user
    const registerResponse1 = await request(app.getHttpServer())
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
            email: 'grouptest1@example.com',
            username: 'grouptest1',
            password: 'Test123!@#',
          },
        },
      });

    authToken = registerResponse1.body.data.register.accessToken;
    userId = registerResponse1.body.data.register.user.id;

    // Register and login second user
    const registerResponse2 = await request(app.getHttpServer())
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
            email: 'grouptest2@example.com',
            username: 'grouptest2',
            password: 'Test123!@#',
          },
        },
      });

    authToken2 = registerResponse2.body.data.register.accessToken;
    userId2 = registerResponse2.body.data.register.user.id;
  });

  afterAll(async () => {
    // Clean up in correct order (from dependent to independent)
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

  describe('Group Creation', () => {
    it('should create a group with default values', async () => {
      const response = await request(app.getHttpServer())
        .post('/graphql')
        .set('Authorization', `Bearer ${authToken}`)
        .send({
          query: `
            mutation CreateGroup($input: CreateGroupInput!) {
              createGroup(input: $input) {
                id
                name
                description
                inviteToken
                requiresApproval
                rotationType
                gamificationEnabled
                createdById
              }
            }
          `,
          variables: {
            input: {
              name: 'Test Family Group',
            },
          },
        });

      expect(response.body.errors).toBeUndefined();
      expect(response.body.data.createGroup).toMatchObject({
        name: 'Test Family Group',
        description: null,
        requiresApproval: true,
        rotationType: 'ROUND_ROBIN',
        gamificationEnabled: true,
        createdById: userId,
      });
      expect(response.body.data.createGroup.inviteToken).toBeDefined();

      groupId = response.body.data.createGroup.id;
      inviteToken = response.body.data.createGroup.inviteToken;
    });

    it('should create a group with custom values', async () => {
      const response = await request(app.getHttpServer())
        .post('/graphql')
        .set('Authorization', `Bearer ${authToken}`)
        .send({
          query: `
            mutation CreateGroup($input: CreateGroupInput!) {
              createGroup(input: $input) {
                id
                name
                description
                requiresApproval
                rotationType
                gamificationEnabled
              }
            }
          `,
          variables: {
            input: {
              name: 'Custom Group',
              description: 'A custom group description',
              requiresApproval: false,
              rotationType: 'RANDOM',
              gamificationEnabled: false,
            },
          },
        });

      expect(response.body.errors).toBeUndefined();
      expect(response.body.data.createGroup).toMatchObject({
        name: 'Custom Group',
        description: 'A custom group description',
        requiresApproval: false,
        rotationType: 'RANDOM',
        gamificationEnabled: false,
      });
    });

    it('should fail to create a group without authentication', async () => {
      const response = await request(app.getHttpServer())
        .post('/graphql')
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
              name: 'Unauthorized Group',
            },
          },
        });

      expect(response.body.errors).toBeDefined();
      expect(response.body.errors[0].message).toContain('Требуется авторизация');
    });
  });

  describe('Group Retrieval', () => {
    it('should get a group by ID', async () => {
      const response = await request(app.getHttpServer())
        .post('/graphql')
        .set('Authorization', `Bearer ${authToken}`)
        .send({
          query: `
            query GetGroup($groupId: String!) {
              getGroup(groupId: $groupId) {
                id
                name
                createdById
              }
            }
          `,
          variables: {
            groupId: groupId,
          },
        });

      expect(response.body.errors).toBeUndefined();
      expect(response.body.data.getGroup).toMatchObject({
        id: groupId,
        name: 'Test Family Group',
      });
    });

    it('should get all user groups', async () => {
      const response = await request(app.getHttpServer())
        .post('/graphql')
        .set('Authorization', `Bearer ${authToken}`)
        .send({
          query: `
            query GetUserGroups {
              getUserGroups {
                id
                name
              }
            }
          `,
        });

      expect(response.body.errors).toBeUndefined();
      expect(response.body.data.getUserGroups).toHaveLength(2);
    });

    it('should fail to get group if user is not a member', async () => {
      const response = await request(app.getHttpServer())
        .post('/graphql')
        .set('Authorization', `Bearer ${authToken2}`)
        .send({
          query: `
            query GetGroup($groupId: String!) {
              getGroup(groupId: $groupId) {
                id
                name
              }
            }
          `,
          variables: {
            groupId: groupId,
          },
        });

      expect(response.body.errors).toBeDefined();
      expect(response.body.errors[0].message).toContain(
        'Вы не являетесь членом этой группы',
      );
    });
  });

  describe('Join Group', () => {
    it('should join group with valid invite token', async () => {
      const response = await request(app.getHttpServer())
        .post('/graphql')
        .set('Authorization', `Bearer ${authToken2}`)
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

      expect(response.body.errors).toBeUndefined();
      expect(response.body.data.joinGroup).toBeDefined();
      expect(response.body.data.joinGroup.id).toBe(groupId);
      
      // Verify member was added by querying members as admin
      const membersResponse = await request(app.getHttpServer())
        .post('/graphql')
        .set('Authorization', `Bearer ${authToken}`)
        .send({
          query: `
            query GetGroupMembers($groupId: String!) {
              getGroupMembers(groupId: $groupId) {
                userId
                role
              }
            }
          `,
          variables: {
            groupId: groupId,
          },
        });
      
      expect(membersResponse.body.data.getGroupMembers).toHaveLength(2);
      expect(
        membersResponse.body.data.getGroupMembers.some(
          (m: any) => m.userId === userId2 && m.role === 'MEMBER',
        ),
      ).toBe(true);
    });

    it('should fail to join with invalid token', async () => {
      const response = await request(app.getHttpServer())
        .post('/graphql')
        .set('Authorization', `Bearer ${authToken2}`)
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
              inviteToken: 'invalid-token-123',
            },
          },
        });

      expect(response.body.errors).toBeDefined();
      expect(response.body.errors[0].message).toContain('не найдена');
    });

    it('should fail to join if already a member', async () => {
      const response = await request(app.getHttpServer())
        .post('/graphql')
        .set('Authorization', `Bearer ${authToken}`)
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
              inviteToken: inviteToken,
            },
          },
        });

      expect(response.body.errors).toBeDefined();
      expect(response.body.errors[0].message).toContain('уже являетесь членом');
    });
  });

  describe('Update Group', () => {
    it('should update group as admin', async () => {
      const response = await request(app.getHttpServer())
        .post('/graphql')
        .set('Authorization', `Bearer ${authToken}`)
        .send({
          query: `
            mutation UpdateGroup($groupId: String!, $input: UpdateGroupInput!) {
              updateGroup(groupId: $groupId, input: $input) {
                id
                name
                description
                requiresApproval
              }
            }
          `,
          variables: {
            groupId: groupId,
            input: {
              name: 'Updated Group Name',
              description: 'Updated description',
              requiresApproval: false,
            },
          },
        });

      expect(response.body.errors).toBeUndefined();
      expect(response.body.data.updateGroup).toMatchObject({
        id: groupId,
        name: 'Updated Group Name',
        description: 'Updated description',
        requiresApproval: false,
      });
    });

    it('should fail to update group as non-admin member', async () => {
      const response = await request(app.getHttpServer())
        .post('/graphql')
        .set('Authorization', `Bearer ${authToken2}`)
        .send({
          query: `
            mutation UpdateGroup($groupId: String!, $input: UpdateGroupInput!) {
              updateGroup(groupId: $groupId, input: $input) {
                id
                name
              }
            }
          `,
          variables: {
            groupId: groupId,
            input: {
              name: 'Unauthorized Update',
            },
          },
        });

      expect(response.body.errors).toBeDefined();
      expect(response.body.errors[0].message).toContain('Только администраторы');
    });
  });

  describe('Member Role Management', () => {
    it('should update member role as admin', async () => {
      const response = await request(app.getHttpServer())
        .post('/graphql')
        .set('Authorization', `Bearer ${authToken}`)
        .send({
          query: `
            mutation UpdateMemberRole($groupId: String!, $input: UpdateMemberRoleInput!) {
              updateMemberRole(groupId: $groupId, input: $input) {
                id
                role
                userId
              }
            }
          `,
          variables: {
            groupId: groupId,
            input: {
              userId: userId2,
              role: 'ADMIN',
            },
          },
        });

      expect(response.body.errors).toBeUndefined();
      expect(response.body.data.updateMemberRole).toMatchObject({
        role: 'ADMIN',
        userId: userId2,
      });
    });

    it('should fail to update member role as non-admin', async () => {
      // First, demote user2 back to member
      await request(app.getHttpServer())
        .post('/graphql')
        .set('Authorization', `Bearer ${authToken}`)
        .send({
          query: `
            mutation UpdateMemberRole($groupId: String!, $input: UpdateMemberRoleInput!) {
              updateMemberRole(groupId: $groupId, input: $input) {
                id
                role
              }
            }
          `,
          variables: {
            groupId: groupId,
            input: {
              userId: userId2,
              role: 'MEMBER',
            },
          },
        });

      // Try to update role as non-admin
      const response = await request(app.getHttpServer())
        .post('/graphql')
        .set('Authorization', `Bearer ${authToken2}`)
        .send({
          query: `
            mutation UpdateMemberRole($groupId: String!, $input: UpdateMemberRoleInput!) {
              updateMemberRole(groupId: $groupId, input: $input) {
                id
                role
              }
            }
          `,
          variables: {
            groupId: groupId,
            input: {
              userId: userId,
              role: 'MEMBER',
            },
          },
        });

      expect(response.body.errors).toBeDefined();
      expect(response.body.errors[0].message).toContain('Только администраторы');
    });
  });

  describe('Remove Member', () => {
    let thirdUserId: string;
    let authToken3: string;

    beforeAll(async () => {
      // Register third user
      const registerResponse = await request(app.getHttpServer())
        .post('/graphql')
        .send({
          query: `
            mutation Register($input: RegisterInput!) {
              register(input: $input) {
                accessToken
                user {
                  id
                }
              }
            }
          `,
          variables: {
            input: {
              email: 'grouptest3@example.com',
              username: 'grouptest3',
              password: 'Test123!@#',
            },
          },
        });

      authToken3 = registerResponse.body.data.register.accessToken;
      thirdUserId = registerResponse.body.data.register.user.id;

      // Join the group
      await request(app.getHttpServer())
        .post('/graphql')
        .set('Authorization', `Bearer ${authToken3}`)
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
              inviteToken: inviteToken,
            },
          },
        });
    });

    it('should remove member as admin', async () => {
      const response = await request(app.getHttpServer())
        .post('/graphql')
        .set('Authorization', `Bearer ${authToken}`)
        .send({
          query: `
            mutation RemoveMember($groupId: String!, $userId: String!) {
              removeMember(groupId: $groupId, userId: $userId)
            }
          `,
          variables: {
            groupId: groupId,
            userId: thirdUserId,
          },
        });

      expect(response.body.errors).toBeUndefined();
      expect(response.body.data.removeMember).toBe(true);
    });

    it('should fail to remove member as non-admin', async () => {
      const response = await request(app.getHttpServer())
        .post('/graphql')
        .set('Authorization', `Bearer ${authToken2}`)
        .send({
          query: `
            mutation RemoveMember($groupId: String!, $userId: String!) {
              removeMember(groupId: $groupId, userId: $userId)
            }
          `,
          variables: {
            groupId: groupId,
            userId: userId,
          },
        });

      expect(response.body.errors).toBeDefined();
      expect(response.body.errors[0].message).toContain('Только администраторы');
    });
  });

  describe('Leave Group', () => {
    it('should allow member to leave group', async () => {
      const response = await request(app.getHttpServer())
        .post('/graphql')
        .set('Authorization', `Bearer ${authToken2}`)
        .send({
          query: `
            mutation LeaveGroup($groupId: String!) {
              leaveGroup(groupId: $groupId)
            }
          `,
          variables: {
            groupId: groupId,
          },
        });

      expect(response.body.errors).toBeUndefined();
      expect(response.body.data.leaveGroup).toBe(true);
    });

    it('should fail to leave group as creator', async () => {
      const response = await request(app.getHttpServer())
        .post('/graphql')
        .set('Authorization', `Bearer ${authToken}`)
        .send({
          query: `
            mutation LeaveGroup($groupId: String!) {
              leaveGroup(groupId: $groupId)
            }
          `,
          variables: {
            groupId: groupId,
          },
        });

      expect(response.body.errors).toBeDefined();
      expect(response.body.errors[0].message).toContain('Создатель группы не может');
    });
  });

  describe('Regenerate Invite Token', () => {
    it('should regenerate invite token as admin', async () => {
      const response = await request(app.getHttpServer())
        .post('/graphql')
        .set('Authorization', `Bearer ${authToken}`)
        .send({
          query: `
            mutation RegenerateInviteToken($groupId: String!) {
              regenerateInviteToken(groupId: $groupId)
            }
          `,
          variables: {
            groupId: groupId,
          },
        });

      expect(response.body.errors).toBeUndefined();
      expect(response.body.data.regenerateInviteToken).toBeDefined();
      expect(response.body.data.regenerateInviteToken).not.toBe(inviteToken);
      
      // Update inviteToken for subsequent tests
      inviteToken = response.body.data.regenerateInviteToken;
    });
  });

  describe('Delete Group', () => {
    it('should fail to delete group as non-creator', async () => {
      // Re-add user2 to group
      await request(app.getHttpServer())
        .post('/graphql')
        .set('Authorization', `Bearer ${authToken2}`)
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
              inviteToken: inviteToken,
            },
          },
        });

      // Promote user2 to admin
      await request(app.getHttpServer())
        .post('/graphql')
        .set('Authorization', `Bearer ${authToken}`)
        .send({
          query: `
            mutation UpdateMemberRole($groupId: String!, $input: UpdateMemberRoleInput!) {
              updateMemberRole(groupId: $groupId, input: $input) {
                id
              }
            }
          `,
          variables: {
            groupId: groupId,
            input: {
              userId: userId2,
              role: 'ADMIN',
            },
          },
        });

      const response = await request(app.getHttpServer())
        .post('/graphql')
        .set('Authorization', `Bearer ${authToken2}`)
        .send({
          query: `
            mutation DeleteGroup($groupId: String!) {
              deleteGroup(groupId: $groupId)
            }
          `,
          variables: {
            groupId: groupId,
          },
        });

      expect(response.body.errors).toBeDefined();
      expect(response.body.errors[0].message).toContain('Только создатель');
    });

    it('should delete group as creator', async () => {
      const response = await request(app.getHttpServer())
        .post('/graphql')
        .set('Authorization', `Bearer ${authToken}`)
        .send({
          query: `
            mutation DeleteGroup($groupId: String!) {
              deleteGroup(groupId: $groupId)
            }
          `,
          variables: {
            groupId: groupId,
          },
        });

      expect(response.body.errors).toBeUndefined();
      expect(response.body.data.deleteGroup).toBe(true);

      // Verify group is deleted
      const getResponse = await request(app.getHttpServer())
        .post('/graphql')
        .set('Authorization', `Bearer ${authToken}`)
        .send({
          query: `
            query GetGroup($groupId: String!) {
              getGroup(groupId: $groupId) {
                id
              }
            }
          `,
          variables: {
            groupId: groupId,
          },
        });

      expect(getResponse.body.errors).toBeDefined();
    });
  });
});
