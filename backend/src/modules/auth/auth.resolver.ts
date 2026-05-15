import { Resolver, Mutation, Query, Args } from '@nestjs/graphql';
import { UseGuards } from '@nestjs/common';
import { AuthService } from './auth.service';
import { JwtAuthGuard } from './auth.guard';
import { CurrentUser } from './decorators/current-user.decorator';
import {
  RegisterInput,
  LoginInput,
  ChangePasswordInput,
  RefreshTokenInput,
  VerifyEmailInput,
  RequestPasswordResetInput,
  ResetPasswordInput,
} from './dto/auth.input';
import { AuthResponseType } from './types/auth-response.type';
import { UserType } from './types/user.type';

@Resolver()
export class AuthResolver {
  constructor(private authService: AuthService) {}

  @Mutation(() => AuthResponseType, {
    description:
      'Регистрация. После регистрации на email отправляется 6-значный код подтверждения.',
  })
  async register(@Args('input') input: RegisterInput): Promise<AuthResponseType> {
    return this.authService.register(input);
  }

  @Mutation(() => AuthResponseType, {
    description: 'Вход по логину (username) или email и паролю.',
  })
  async login(@Args('input') input: LoginInput): Promise<AuthResponseType> {
    return this.authService.login(input);
  }

  @Query(() => UserType, {
    description: 'Получить информацию о текущем пользователе (требуется авторизация).',
  })
  @UseGuards(JwtAuthGuard)
  async me(@CurrentUser() user: any): Promise<UserType> {
    return this.authService.getCurrentUser(user.id);
  }

  @Mutation(() => UserType, {
    description:
      'Подтверждение email по 6-значному коду, отправленному при регистрации. Требуется авторизация.',
  })
  @UseGuards(JwtAuthGuard)
  async verifyEmail(
    @CurrentUser() user: any,
    @Args('input') input: VerifyEmailInput,
  ): Promise<UserType> {
    return this.authService.verifyEmail(user.id, input);
  }

  @Mutation(() => Boolean, {
    description:
      'Повторно отправить код подтверждения email. Требуется авторизация.',
  })
  @UseGuards(JwtAuthGuard)
  async resendVerificationCode(@CurrentUser() user: any): Promise<boolean> {
    return this.authService.resendVerificationCode(user.id);
  }

  @Mutation(() => Boolean, {
    description: 'Сменить пароль текущего пользователя (требуется авторизация).',
  })
  @UseGuards(JwtAuthGuard)
  async changePassword(
    @CurrentUser() user: any,
    @Args('input') input: ChangePasswordInput,
  ): Promise<boolean> {
    return this.authService.changePassword(
      user.id,
      input.oldPassword,
      input.newPassword,
    );
  }

  @Mutation(() => Boolean, {
    description:
      'Запросить сброс пароля: отправляет 6-значный код на email. Не требует авторизации.',
  })
  async requestPasswordReset(
    @Args('input') input: RequestPasswordResetInput,
  ): Promise<boolean> {
    return this.authService.requestPasswordReset(input);
  }

  @Mutation(() => Boolean, {
    description:
      'Сбросить пароль по коду из письма. Не требует авторизации.',
  })
  async resetPassword(
    @Args('input') input: ResetPasswordInput,
  ): Promise<boolean> {
    return this.authService.resetPassword(input);
  }

  @Mutation(() => AuthResponseType, {
    description: 'Обновить access token с помощью refresh token.',
  })
  async refreshToken(
    @Args('input') input: RefreshTokenInput,
  ): Promise<AuthResponseType> {
    return this.authService.refreshAccessToken(input);
  }

  @Mutation(() => Boolean, {
    description: 'Выход из системы (отзыв refresh token).',
  })
  async logout(
    @Args('refreshToken') refreshToken: string,
  ): Promise<boolean> {
    return this.authService.revokeRefreshToken(refreshToken);
  }

  @Mutation(() => Number, {
    description: 'Выход из всех устройств (требуется авторизация).',
  })
  @UseGuards(JwtAuthGuard)
  async logoutAll(@CurrentUser() user: any): Promise<number> {
    return this.authService.revokeAllUserTokens(user.id);
  }
}
