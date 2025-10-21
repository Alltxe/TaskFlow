import { Resolver, Mutation, Query, Args } from '@nestjs/graphql';
import { UseGuards } from '@nestjs/common';
import { AuthService } from './auth.service';
import { JwtAuthGuard } from './auth.guard';
import { CurrentUser } from './decorators/current-user.decorator';
import { RegisterInput, LoginInput, ChangePasswordInput } from './dto/auth.input';
import { AuthResponseType } from './types/auth-response.type';
import { UserType } from './types/user.type';
import type { User } from '@prisma/client';

@Resolver()
export class AuthResolver {
  constructor(private authService: AuthService) {}

  /**
   * Регистрация нового пользователя
   */
  @Mutation(() => AuthResponseType, { description: 'Регистрация нового пользователя' })
  async register(@Args('input') input: RegisterInput): Promise<AuthResponseType> {
    return this.authService.register(input);
  }

  /**
   * Вход пользователя
   */
  @Mutation(() => AuthResponseType, { description: 'Вход пользователя' })
  async login(@Args('input') input: LoginInput): Promise<AuthResponseType> {
    return this.authService.login(input);
  }

  /**
   * Получение текущего пользователя (требуется авторизация)
   */
  @Query(() => UserType, { description: 'Получить информацию о текущем пользователе' })
  @UseGuards(JwtAuthGuard)
  async me(@CurrentUser() user: User): Promise<UserType> {
    return this.authService.getCurrentUser(user.id);
  }

  /**
   * Смена пароля (требуется авторизация)
   */
  @Mutation(() => Boolean, { description: 'Сменить пароль текущего пользователя' })
  @UseGuards(JwtAuthGuard)
  async changePassword(
    @CurrentUser() user: User,
    @Args('input') input: ChangePasswordInput,
  ): Promise<boolean> {
    return this.authService.changePassword(user.id, input.oldPassword, input.newPassword);
  }
}
