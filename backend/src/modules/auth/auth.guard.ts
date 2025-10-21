import { Injectable, ExecutionContext, UnauthorizedException } from '@nestjs/common';
import { AuthGuard } from '@nestjs/passport';
import { GqlExecutionContext } from '@nestjs/graphql';

/**
 * Guard для защиты GraphQL резолверов с помощью JWT
 */
@Injectable()
export class JwtAuthGuard extends AuthGuard('jwt') {
  /**
   * Получаем request из GraphQL контекста
   */
  getRequest(context: ExecutionContext) {
    const ctx = GqlExecutionContext.create(context);
    return ctx.getContext().req;
  }

  /**
   * Обработка ошибок авторизации
   */
  handleRequest(err: any, user: any, info: any) {
    if (err || !user) {
      throw err || new UnauthorizedException('Требуется авторизация');
    }
    return user;
  }
}