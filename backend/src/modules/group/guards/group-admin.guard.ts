import {
  Injectable,
  CanActivate,
  ExecutionContext,
  ForbiddenException,
} from '@nestjs/common';
import { GqlExecutionContext } from '@nestjs/graphql';
import { PrismaService } from '../../prisma/prisma.service';

@Injectable()
export class GroupAdminGuard implements CanActivate {
  constructor(private prisma: PrismaService) {}

  async canActivate(context: ExecutionContext): Promise<boolean> {
    const ctx = GqlExecutionContext.create(context);
    const args = ctx.getArgs();
    const request = ctx.getContext().req;
    const user = request.user;

    if (!user) {
      throw new ForbiddenException('Требуется авторизация');
    }

    const groupId = args.groupId || args.input?.groupId;

    if (!groupId) {
      throw new ForbiddenException('ID группы не указан');
    }

    const member = await this.prisma.groupMember.findFirst({
      where: {
        groupId,
        userId: user.id,
      },
    });

    if (!member) {
      throw new ForbiddenException('Вы не являетесь участником группы');
    }

    if (member.role !== 'ADMIN') {
      throw new ForbiddenException(
        'Только администраторы могут выполнять это действие',
      );
    }

    return true;
  }
}
