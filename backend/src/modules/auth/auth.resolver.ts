import { Resolver, Mutation, Query, Args } from '@nestjs/graphql';
import { UseGuards } from '@nestjs/common';
import { AuthService } from './auth.service';
import { JwtAuthGuard } from './auth.guard';
import { CurrentUser } from './decorators/current-user.decorator';
import { RegisterInput, LoginInput, ChangePasswordInput, RefreshTokenInput } from './dto/auth.input';
import { AuthResponseType } from './types/auth-response.type';
import { UserType } from './types/user.type';
import { SkipThrottle, Throttle } from '@nestjs/throttler';

@Resolver()
export class AuthResolver {
  constructor(private authService: AuthService) {}

  /**
   * Регистрация нового пользователя
   * Rate limit: 5 requests per minute (PRD 4.3)
   */
  @Mutation(() => AuthResponseType, { description: 'Регистрация нового пользователя' })
  @Throttle({ auth: { limit: 5, ttl: 60000 } })
  async register(@Args('input') input: RegisterInput): Promise<AuthResponseType> {
    return this.authService.register(input);
  }

  /**
   * Вход пользователя
   * Rate limit: 5 requests per minute (PRD 4.3)
   */
  @Mutation(() => AuthResponseType, { description: 'Вход пользователя' })
  @Throttle({ auth: { limit: 5, ttl: 60000 } })
  async login(@Args('input') input: LoginInput): Promise<AuthResponseType> {
    return this.authService.login(input);
  }

  /**
   * Получение текущего пользователя (требуется авторизация)
   */
  @Query(() => UserType, { description: 'Получить информацию о текущем пользователе' })
  @UseGuards(JwtAuthGuard)
  async me(@CurrentUser() user: any): Promise<UserType> {
    return this.authService.getCurrentUser(user.id);
  }

  /**
   * Смена пароля (требуется авторизация)
   */
  @Mutation(() => Boolean, { description: 'Сменить пароль текущего пользователя' })
  @UseGuards(JwtAuthGuard)
  async changePassword(
    @CurrentUser() user: any,
    @Args('input') input: ChangePasswordInput,
  ): Promise<boolean> {
    return this.authService.changePassword(user.id, input.oldPassword, input.newPassword);
  }

  /**
   * Обновление access token с помощью refresh token
   * Rate limit: 5 requests per minute (PRD 4.3)
   */
  @Mutation(() => AuthResponseType, { description: 'Обновить access token с помощью refresh token' })
  @Throttle({ auth: { limit: 5, ttl: 60000 } })
  async refreshToken(@Args('input') input: RefreshTokenInput): Promise<AuthResponseType> {
    return this.authService.refreshAccessToken(input);
  }

  /**
   * Выход из системы (отзыв refresh token)
   */
  @Mutation(() => Boolean, { description: 'Выход из системы (отзыв refresh token)' })
  @Throttle({ auth: { limit: 5, ttl: 60000 } })
  async logout(@Args('refreshToken') refreshToken: string): Promise<boolean> {
    return this.authService.revokeRefreshToken(refreshToken);
  }

  /**
   * Выход из всех устройств (отзыв всех refresh tokens пользователя)
   */
  @Mutation(() => Number, { description: 'Выход из всех устройств' })
  @UseGuards(JwtAuthGuard)
  async logoutAll(@CurrentUser() user: any): Promise<number> {
    return this.authService.revokeAllUserTokens(user.id);
  }
}
