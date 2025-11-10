import {
  Injectable,
  NotFoundException,
  ForbiddenException,
  BadRequestException,
  ConflictException,
} from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import {
  CreateGroupInput,
  UpdateGroupInput,
  JoinGroupInput,
  UpdateMemberRoleInput,
  MemberRole,
} from './dto/group.input';
import { randomBytes } from 'crypto';
import { AuditLogService } from '../audit-log/audit-log.service';

@Injectable()
export class GroupService {
  constructor(
    private prisma: PrismaService,
    private auditLogService: AuditLogService,
  ) {}

  /**
   * Создать группу
   */
  async createGroup(userId: string, input: CreateGroupInput) {
    const { name, description, requiresApproval, rotationType, gamificationEnabled } = input;

    // Генерируем токен приглашения
    const inviteToken = this.generateInviteToken();

    const group = await this.prisma.group.create({
      data: {
        name,
        description,
        inviteToken,
        requiresApproval: requiresApproval ?? true,
        rotationType: (rotationType as any) || 'ROUND_ROBIN',
        gamificationEnabled: gamificationEnabled ?? true,
        createdById: userId,
        members: {
          create: {
            userId,
            role: 'ADMIN',
          },
        },
      },
      include: {
        creator: true,
        members: {
          include: {
            user: true,
          },
        },
      },
    });

    return group;
  }

  /**
   * Получить группу по ID
   */
  async getGroup(groupId: string, userId: string) {
    const group = await this.prisma.group.findUnique({
      where: { id: groupId },
      include: {
        creator: true,
        members: {
          include: {
            user: true,
          },
        },
      },
    });

    if (!group) {
      throw new NotFoundException('Группа не найдена');
    }

    // Проверяем, является ли пользователь членом группы
    const isMember = group.members.some((member) => member.userId === userId);
    if (!isMember) {
      throw new ForbiddenException('Вы не являетесь членом этой группы');
    }

    return group;
  }

  /**
   * Получить все группы пользователя
   */
  async getUserGroups(userId: string) {
    const groups = await this.prisma.group.findMany({
      where: {
        members: {
          some: {
            userId,
          },
        },
      },
      include: {
        creator: true,
        members: {
          include: {
            user: true,
          },
        },
        _count: {
          select: {
            tasks: true,
            members: true,
          },
        },
      },
      orderBy: {
        createdAt: 'desc',
      },
    });

    return groups;
  }

  /**
   * Получить список участников группы (только для админов)
   */
  async getGroupMembers(groupId: string, userId: string) {
    const group = await this.prisma.group.findUnique({
      where: { id: groupId },
      include: {
        members: {
          include: {
            user: true,
          },
        },
      },
    });

    if (!group) {
      throw new NotFoundException('Группа не найдена');
    }

    return group.members;
  }

  /**
   * Обновить группу
   */
  async updateGroup(groupId: string, userId: string, input: UpdateGroupInput) {
    const group = await this.getGroup(groupId, userId);

    // Проверяем права администратора
    const member = group.members.find((m) => m.userId === userId);
    if (!member || member.role !== 'ADMIN') {
      throw new ForbiddenException('Только администраторы могут обновлять группу');
    }

    const updatedGroup = await this.prisma.group.update({
      where: { id: groupId },
      data: {
        ...input,
      },
      include: {
        creator: true,
        members: {
          include: {
            user: true,
          },
        },
      },
    });

    return updatedGroup;
  }

  /**
   * Удалить группу
   */
  async deleteGroup(groupId: string, userId: string) {
    const group = await this.getGroup(groupId, userId);

    // Только создатель может удалить группу
    if (group.createdById !== userId) {
      throw new ForbiddenException('Только создатель может удалить группу');
    }

    await this.prisma.group.delete({
      where: { id: groupId },
    });

    return true;
  }

  /**
   * Присоединиться к группе по токену
   */
  async joinGroup(userId: string, input: JoinGroupInput) {
    const { inviteToken } = input;

    const group = await this.prisma.group.findUnique({
      where: { inviteToken },
      include: {
        members: true,
      },
    });

    if (!group) {
      throw new NotFoundException('Группа не найдена или токен недействителен');
    }

    // Проверяем, не является ли пользователь уже членом
    const existingMember = group.members.find((m) => m.userId === userId);
    if (existingMember) {
      throw new ConflictException('Вы уже являетесь членом этой группы');
    }

    // Добавляем пользователя в группу
    await this.prisma.groupMember.create({
      data: {
        userId,
        groupId: group.id,
        role: 'MEMBER',
      },
    });

    return this.getGroup(group.id, userId);
  }

  /**
   * Покинуть группу
   */
  async leaveGroup(groupId: string, userId: string) {
    const group = await this.getGroup(groupId, userId);

    // Создатель не может покинуть группу
    if (group.createdById === userId) {
      throw new BadRequestException('Создатель группы не может покинуть её. Удалите группу вместо этого.');
    }

    await this.prisma.groupMember.deleteMany({
      where: {
        groupId,
        userId,
      },
    });

    return true;
  }

  /**
   * Удалить участника из группы
   */
  async removeMember(groupId: string, adminId: string, memberUserId: string) {
    const group = await this.getGroup(groupId, adminId);

    // Проверяем права администратора
    const admin = group.members.find((m) => m.userId === adminId);
    if (!admin || admin.role !== 'ADMIN') {
      throw new ForbiddenException('Только администраторы могут удалять участников');
    }

    // Нельзя удалить создателя
    if (memberUserId === group.createdById) {
      throw new BadRequestException('Нельзя удалить создателя группы');
    }

    // Проверяем, существует ли участник
    const memberExists = group.members.some((m) => m.userId === memberUserId);
    if (!memberExists) {
      throw new NotFoundException('Участник не найден в группе');
    }

    await this.prisma.groupMember.deleteMany({
      where: {
        groupId,
        userId: memberUserId,
      },
    });

    return true;
  }

  /**
   * Изменить роль участника
   */
  async updateMemberRole(groupId: string, adminId: string, input: UpdateMemberRoleInput) {
    const { userId, role } = input;
    const group = await this.getGroup(groupId, adminId);

    // Проверяем права администратора
    const admin = group.members.find((m) => m.userId === adminId);
    if (!admin || admin.role !== 'ADMIN') {
      throw new ForbiddenException('Только администраторы могут изменять роли');
    }

    // Нельзя изменить роль создателя
    if (userId === group.createdById) {
      throw new BadRequestException('Нельзя изменить роль создателя группы');
    }

    // Проверяем, существует ли участник
    const member = group.members.find((m) => m.userId === userId);
    if (!member) {
      throw new NotFoundException('Участник не найден в группе');
    }

    const oldRole = member.role;

    const updatedMember = await this.prisma.groupMember.update({
      where: { id: member.id },
      data: {
        role,
        roleChangedAt: new Date(),
      },
      include: {
        user: true,
        group: true,
      },
    });

    // Audit log for role change (PRD 3.6.4)
    await this.auditLogService.logRoleChange(
      groupId,
      userId,
      oldRole,
      role,
      adminId,
    );

    return updatedMember;
  }

  /**
   * Сгенерировать новый токен приглашения
   */
  async regenerateInviteToken(groupId: string, userId: string) {
    const group = await this.getGroup(groupId, userId);

    // Проверяем права администратора
    const member = group.members.find((m) => m.userId === userId);
    if (!member || member.role !== 'ADMIN') {
      throw new ForbiddenException('Только администраторы могут обновлять токен приглашения');
    }

    const newToken = this.generateInviteToken();

    const updatedGroup = await this.prisma.group.update({
      where: { id: groupId },
      data: { inviteToken: newToken },
    });

    return updatedGroup.inviteToken;
  }

  /**
   * Генерировать уникальный токен приглашения
   */
  private generateInviteToken(): string {
    return randomBytes(16).toString('hex');
  }
}
