import { Test, TestingModule } from '@nestjs/testing';
import {
  NotFoundException,
  ForbiddenException,
  BadRequestException,
  ConflictException,
} from '@nestjs/common';
import { GroupService } from './group.service';
import { PrismaService } from '../prisma/prisma.service';
import { AuditLogService } from '../audit-log/audit-log.service';
import {
  CreateGroupInput,
  UpdateGroupInput,
  JoinGroupInput,
  UpdateMemberRoleInput,
  MemberRole,
} from './dto/group.input';

describe('GroupService', () => {
  let service: GroupService;
  let prismaService: PrismaService;

  const mockUser = {
    id: 'user-id-123',
    email: 'test@example.com',
    username: 'testuser',
    createdAt: new Date(),
    updatedAt: new Date(),
  };

  const mockUser2 = {
    id: 'user-id-456',
    email: 'test2@example.com',
    username: 'testuser2',
    createdAt: new Date(),
    updatedAt: new Date(),
  };

  const mockGroup = {
    id: 'group-id-123',
    name: 'Test Group',
    description: 'Test Description',
    inviteToken: 'test-token-123',
    requiresApproval: true,
    rotationType: 'ROUND_ROBIN',
    gamificationEnabled: true,
    createdById: 'user-id-123',
    createdAt: new Date(),
    updatedAt: new Date(),
    creator: mockUser,
    members: [
      {
        id: 'member-id-123',
        userId: 'user-id-123',
        groupId: 'group-id-123',
        role: 'ADMIN',
        joinedAt: new Date(),
        roleChangedAt: null,
        user: mockUser,
      },
    ],
  };

  const mockPrismaService = {
    group: {
      create: jest.fn(),
      findUnique: jest.fn(),
      findMany: jest.fn(),
      update: jest.fn(),
      delete: jest.fn(),
    },
    groupMember: {
      create: jest.fn(),
      deleteMany: jest.fn(),
      update: jest.fn(),
    },
  };

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [
        GroupService,
        {
          provide: PrismaService,
          useValue: mockPrismaService,
        },
        {
          provide: AuditLogService,
          useValue: {
            logRoleChange: jest.fn(),
            createLog: jest.fn(),
          },
        },
      ],
    }).compile();

    service = module.get<GroupService>(GroupService);
    prismaService = module.get<PrismaService>(PrismaService);

    // Clear all mocks before each test
    jest.clearAllMocks();
  });

  it('should be defined', () => {
    expect(service).toBeDefined();
  });

  describe('createGroup', () => {
    it('should create a group successfully', async () => {
      const input: CreateGroupInput = {
        name: 'Test Group',
        description: 'Test Description',
        requiresApproval: true,
        rotationType: 'ROUND_ROBIN',
        gamificationEnabled: true,
      };

      mockPrismaService.group.create.mockResolvedValue(mockGroup);

      const result = await service.createGroup(mockUser.id, input);

      expect(result).toEqual(mockGroup);
      expect(mockPrismaService.group.create).toHaveBeenCalledWith(
        expect.objectContaining({
          data: expect.objectContaining({
            name: input.name,
            description: input.description,
            requiresApproval: input.requiresApproval,
            rotationType: input.rotationType,
            gamificationEnabled: input.gamificationEnabled,
            createdById: mockUser.id,
            inviteToken: expect.any(String),
          }),
        }),
      );
    });

    it('should create a group with default values', async () => {
      const input: CreateGroupInput = {
        name: 'Test Group',
      };

      const groupWithDefaults = {
        ...mockGroup,
        description: null,
        requiresApproval: true,
        rotationType: 'ROUND_ROBIN',
        gamificationEnabled: true,
      };

      mockPrismaService.group.create.mockResolvedValue(groupWithDefaults);

      const result = await service.createGroup(mockUser.id, input);

      expect(result).toEqual(groupWithDefaults);
      expect(mockPrismaService.group.create).toHaveBeenCalledWith(
        expect.objectContaining({
          data: expect.objectContaining({
            name: input.name,
            requiresApproval: true,
            rotationType: 'ROUND_ROBIN',
            gamificationEnabled: true,
          }),
        }),
      );
    });
  });

  describe('getGroup', () => {
    it('should return group if user is a member', async () => {
      mockPrismaService.group.findUnique.mockResolvedValue(mockGroup);

      const result = await service.getGroup(mockGroup.id, mockUser.id);

      expect(result).toEqual(mockGroup);
      expect(mockPrismaService.group.findUnique).toHaveBeenCalledWith(
        expect.objectContaining({
          where: { id: mockGroup.id },
        }),
      );
    });

    it('should throw NotFoundException if group does not exist', async () => {
      mockPrismaService.group.findUnique.mockResolvedValue(null);

      await expect(service.getGroup('invalid-id', mockUser.id)).rejects.toThrow(
        NotFoundException,
      );
    });

    it('should throw ForbiddenException if user is not a member', async () => {
      mockPrismaService.group.findUnique.mockResolvedValue(mockGroup);

      await expect(service.getGroup(mockGroup.id, 'non-member-id')).rejects.toThrow(
        ForbiddenException,
      );
    });
  });

  describe('getUserGroups', () => {
    it('should return all groups for a user', async () => {
      const groups = [mockGroup];
      mockPrismaService.group.findMany.mockResolvedValue(groups);

      const result = await service.getUserGroups(mockUser.id);

      expect(result).toEqual(groups);
      expect(mockPrismaService.group.findMany).toHaveBeenCalledWith(
        expect.objectContaining({
          where: {
            members: {
              some: {
                userId: mockUser.id,
              },
            },
          },
        }),
      );
    });

    it('should return empty array if user has no groups', async () => {
      mockPrismaService.group.findMany.mockResolvedValue([]);

      const result = await service.getUserGroups(mockUser.id);

      expect(result).toEqual([]);
    });
  });

  describe('updateGroup', () => {
    it('should update group successfully as admin', async () => {
      const input: UpdateGroupInput = {
        name: 'Updated Group',
        description: 'Updated Description',
      };

      const updatedGroup = { ...mockGroup, ...input };

      mockPrismaService.group.findUnique.mockResolvedValue(mockGroup);
      mockPrismaService.group.update.mockResolvedValue(updatedGroup);

      const result = await service.updateGroup(mockGroup.id, mockUser.id, input);

      expect(result).toEqual(updatedGroup);
      expect(mockPrismaService.group.update).toHaveBeenCalledWith(
        expect.objectContaining({
          where: { id: mockGroup.id },
          data: input,
        }),
      );
    });

    it('should throw ForbiddenException if user is not admin', async () => {
      const groupWithMember = {
        ...mockGroup,
        members: [
          {
            id: 'member-id-456',
            userId: mockUser2.id,
            groupId: mockGroup.id,
            role: 'MEMBER',
            joinedAt: new Date(),
            roleChangedAt: null,
            user: mockUser2,
          },
        ],
      };

      mockPrismaService.group.findUnique.mockResolvedValue(groupWithMember);

      const input: UpdateGroupInput = { name: 'Updated Group' };

      await expect(
        service.updateGroup(mockGroup.id, mockUser2.id, input),
      ).rejects.toThrow(ForbiddenException);
    });

    it('should ignore null values for non-nullable update fields', async () => {
      const input: UpdateGroupInput = {
        name: null as any,
        description: 'Updated Description',
        requiresApproval: null as any,
        rotationType: null as any,
        gamificationEnabled: null as any,
      };

      const updatedGroup = {
        ...mockGroup,
        description: 'Updated Description',
      };

      mockPrismaService.group.findUnique.mockResolvedValue(mockGroup);
      mockPrismaService.group.update.mockResolvedValue(updatedGroup);

      await service.updateGroup(mockGroup.id, mockUser.id, input);

      expect(mockPrismaService.group.update).toHaveBeenCalledWith(
        expect.objectContaining({
          where: { id: mockGroup.id },
          data: {
            description: 'Updated Description',
          },
        }),
      );
    });
  });

  describe('deleteGroup', () => {
    it('should delete group successfully as creator', async () => {
      mockPrismaService.group.findUnique.mockResolvedValue(mockGroup);
      mockPrismaService.group.delete.mockResolvedValue(mockGroup);

      const result = await service.deleteGroup(mockGroup.id, mockUser.id);

      expect(result).toBe(true);
      expect(mockPrismaService.group.delete).toHaveBeenCalledWith({
        where: { id: mockGroup.id },
      });
    });

    it('should throw ForbiddenException if user is not creator', async () => {
      mockPrismaService.group.findUnique.mockResolvedValue(mockGroup);

      await expect(service.deleteGroup(mockGroup.id, 'other-user-id')).rejects.toThrow(
        ForbiddenException,
      );
    });
  });

  describe('joinGroup', () => {
    it('should join group successfully with valid token', async () => {
      const input: JoinGroupInput = {
        inviteToken: 'test-token-123',
      };

      const groupAfterJoin = {
        ...mockGroup,
        members: [
          ...mockGroup.members,
          {
            id: 'member-id-456',
            userId: mockUser2.id,
            groupId: mockGroup.id,
            role: 'MEMBER',
            joinedAt: new Date(),
            roleChangedAt: null,
            user: mockUser2,
          },
        ],
      };

      mockPrismaService.group.findUnique
        .mockResolvedValueOnce(mockGroup)
        .mockResolvedValueOnce(groupAfterJoin);
      mockPrismaService.groupMember.create.mockResolvedValue({
        id: 'member-id-456',
        userId: mockUser2.id,
        groupId: mockGroup.id,
        role: 'MEMBER',
      });

      const result = await service.joinGroup(mockUser2.id, input);

      expect(result).toEqual(groupAfterJoin);
      expect(mockPrismaService.groupMember.create).toHaveBeenCalledWith({
        data: {
          userId: mockUser2.id,
          groupId: mockGroup.id,
          role: 'MEMBER',
        },
      });
    });

    it('should throw NotFoundException with invalid token', async () => {
      const input: JoinGroupInput = {
        inviteToken: 'invalid-token',
      };

      mockPrismaService.group.findUnique.mockResolvedValue(null);

      await expect(service.joinGroup(mockUser2.id, input)).rejects.toThrow(
        NotFoundException,
      );
    });

    it('should throw ConflictException if user is already a member', async () => {
      const input: JoinGroupInput = {
        inviteToken: 'test-token-123',
      };

      mockPrismaService.group.findUnique.mockResolvedValue(mockGroup);

      await expect(service.joinGroup(mockUser.id, input)).rejects.toThrow(
        ConflictException,
      );
    });
  });

  describe('leaveGroup', () => {
    it('should leave group successfully as member', async () => {
      const groupWithTwoMembers = {
        ...mockGroup,
        members: [
          ...mockGroup.members,
          {
            id: 'member-id-456',
            userId: mockUser2.id,
            groupId: mockGroup.id,
            role: 'MEMBER',
            joinedAt: new Date(),
            roleChangedAt: null,
            user: mockUser2,
          },
        ],
      };

      mockPrismaService.group.findUnique.mockResolvedValue(groupWithTwoMembers);
      mockPrismaService.groupMember.deleteMany.mockResolvedValue({ count: 1 });

      const result = await service.leaveGroup(mockGroup.id, mockUser2.id);

      expect(result).toBe(true);
      expect(mockPrismaService.groupMember.deleteMany).toHaveBeenCalledWith({
        where: {
          groupId: mockGroup.id,
          userId: mockUser2.id,
        },
      });
    });

    it('should throw BadRequestException if creator tries to leave', async () => {
      mockPrismaService.group.findUnique.mockResolvedValue(mockGroup);

      await expect(service.leaveGroup(mockGroup.id, mockUser.id)).rejects.toThrow(
        BadRequestException,
      );
    });
  });

  describe('removeMember', () => {
    it('should remove member successfully as admin', async () => {
      const groupWithTwoMembers = {
        ...mockGroup,
        members: [
          ...mockGroup.members,
          {
            id: 'member-id-456',
            userId: mockUser2.id,
            groupId: mockGroup.id,
            role: 'MEMBER',
            joinedAt: new Date(),
            roleChangedAt: null,
            user: mockUser2,
          },
        ],
      };

      mockPrismaService.group.findUnique.mockResolvedValue(groupWithTwoMembers);
      mockPrismaService.groupMember.deleteMany.mockResolvedValue({ count: 1 });

      const result = await service.removeMember(
        mockGroup.id,
        mockUser.id,
        mockUser2.id,
      );

      expect(result).toBe(true);
      expect(mockPrismaService.groupMember.deleteMany).toHaveBeenCalledWith({
        where: {
          groupId: mockGroup.id,
          userId: mockUser2.id,
        },
      });
    });

    it('should throw ForbiddenException if user is not admin', async () => {
      const groupWithTwoMembers = {
        ...mockGroup,
        members: [
          mockGroup.members[0],
          {
            id: 'member-id-456',
            userId: mockUser2.id,
            groupId: mockGroup.id,
            role: 'MEMBER',
            joinedAt: new Date(),
            roleChangedAt: null,
            user: mockUser2,
          },
        ],
      };

      mockPrismaService.group.findUnique.mockResolvedValue(groupWithTwoMembers);

      await expect(
        service.removeMember(mockGroup.id, mockUser2.id, mockUser.id),
      ).rejects.toThrow(ForbiddenException);
    });

    it('should throw BadRequestException when trying to remove creator', async () => {
      mockPrismaService.group.findUnique.mockResolvedValue(mockGroup);

      await expect(
        service.removeMember(mockGroup.id, mockUser.id, mockUser.id),
      ).rejects.toThrow(BadRequestException);
    });

    it('should throw NotFoundException if member does not exist', async () => {
      mockPrismaService.group.findUnique.mockResolvedValue(mockGroup);

      await expect(
        service.removeMember(mockGroup.id, mockUser.id, 'non-existent-user'),
      ).rejects.toThrow(NotFoundException);
    });
  });

  describe('updateMemberRole', () => {
    it('should update member role successfully as admin', async () => {
      const groupWithTwoMembers = {
        ...mockGroup,
        members: [
          ...mockGroup.members,
          {
            id: 'member-id-456',
            userId: mockUser2.id,
            groupId: mockGroup.id,
            role: 'MEMBER',
            joinedAt: new Date(),
            roleChangedAt: null,
            user: mockUser2,
          },
        ],
      };

      const input: UpdateMemberRoleInput = {
        userId: mockUser2.id,
        role: MemberRole.ADMIN,
      };

      const updatedMember = {
        id: 'member-id-456',
        userId: mockUser2.id,
        groupId: mockGroup.id,
        role: 'ADMIN',
        joinedAt: new Date(),
        roleChangedAt: new Date(),
        user: mockUser2,
        group: groupWithTwoMembers,
      };

      mockPrismaService.group.findUnique.mockResolvedValue(groupWithTwoMembers);
      mockPrismaService.groupMember.update.mockResolvedValue(updatedMember);

      const result = await service.updateMemberRole(mockGroup.id, mockUser.id, input);

      expect(result).toEqual(updatedMember);
      expect(mockPrismaService.groupMember.update).toHaveBeenCalledWith(
        expect.objectContaining({
          data: {
            role: input.role,
            roleChangedAt: expect.any(Date),
          },
        }),
      );
    });

    it('should throw ForbiddenException if user is not admin', async () => {
      const groupWithTwoMembers = {
        ...mockGroup,
        members: [
          mockGroup.members[0],
          {
            id: 'member-id-456',
            userId: mockUser2.id,
            groupId: mockGroup.id,
            role: 'MEMBER',
            joinedAt: new Date(),
            roleChangedAt: null,
            user: mockUser2,
          },
        ],
      };

      const input: UpdateMemberRoleInput = {
        userId: mockUser.id,
        role: MemberRole.ADMIN,
      };

      mockPrismaService.group.findUnique.mockResolvedValue(groupWithTwoMembers);

      await expect(
        service.updateMemberRole(mockGroup.id, mockUser2.id, input),
      ).rejects.toThrow(ForbiddenException);
    });

    it('should throw BadRequestException when trying to change creator role', async () => {
      const input: UpdateMemberRoleInput = {
        userId: mockUser.id,
        role: MemberRole.MEMBER,
      };

      mockPrismaService.group.findUnique.mockResolvedValue(mockGroup);

      await expect(
        service.updateMemberRole(mockGroup.id, mockUser.id, input),
      ).rejects.toThrow(BadRequestException);
    });

    it('should throw NotFoundException if member does not exist', async () => {
      const input: UpdateMemberRoleInput = {
        userId: 'non-existent-user',
        role: MemberRole.ADMIN,
      };

      mockPrismaService.group.findUnique.mockResolvedValue(mockGroup);

      await expect(
        service.updateMemberRole(mockGroup.id, mockUser.id, input),
      ).rejects.toThrow(NotFoundException);
    });
  });

  describe('regenerateInviteToken', () => {
    it('should regenerate invite token successfully as admin', async () => {
      const updatedGroup = {
        ...mockGroup,
        inviteToken: 'new-token-456',
      };

      mockPrismaService.group.findUnique.mockResolvedValue(mockGroup);
      mockPrismaService.group.update.mockResolvedValue(updatedGroup);

      const result = await service.regenerateInviteToken(mockGroup.id, mockUser.id);

      expect(result).toBe('new-token-456');
      expect(mockPrismaService.group.update).toHaveBeenCalledWith({
        where: { id: mockGroup.id },
        data: { inviteToken: expect.any(String) },
      });
    });

    it('should throw ForbiddenException if user is not admin', async () => {
      const groupWithMember = {
        ...mockGroup,
        members: [
          {
            id: 'member-id-456',
            userId: mockUser2.id,
            groupId: mockGroup.id,
            role: 'MEMBER',
            joinedAt: new Date(),
            roleChangedAt: null,
            user: mockUser2,
          },
        ],
      };

      mockPrismaService.group.findUnique.mockResolvedValue(groupWithMember);

      await expect(
        service.regenerateInviteToken(mockGroup.id, mockUser2.id),
      ).rejects.toThrow(ForbiddenException);
    });
  });

  describe('getGroupMembers', () => {
    it('should return group members', async () => {
      mockPrismaService.group.findUnique.mockResolvedValue(mockGroup);

      const result = await service.getGroupMembers(mockGroup.id, mockUser.id);

      expect(result).toEqual(mockGroup.members);
    });

    it('should throw NotFoundException if group does not exist', async () => {
      mockPrismaService.group.findUnique.mockResolvedValue(null);

      await expect(service.getGroupMembers('invalid-id', mockUser.id)).rejects.toThrow(
        NotFoundException,
      );
    });
  });
});
