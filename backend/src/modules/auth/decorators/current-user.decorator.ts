import { createParamDecorator, ExecutionContext } from '@nestjs/common';
import { GqlExecutionContext } from '@nestjs/graphql';

/**
 * Декоратор для получения текущего пользователя из контекста GraphQL
 * Пример:
 *  - @CurrentUser()        -> вернет весь объект пользователя
 *  - @CurrentUser('id')    -> вернет только user.id
 */
export const CurrentUser = createParamDecorator(
  (data: unknown, context: ExecutionContext) => {
    const ctx = GqlExecutionContext.create(context);
    const user = ctx.getContext().req.user;

    if (!data || typeof data !== 'string') {
      return user;
    }

    return user?.[data as keyof typeof user];
  },
);
