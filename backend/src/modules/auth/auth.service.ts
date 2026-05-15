import {
  Injectable,
  UnauthorizedException,
  ConflictException,
  BadRequestException,
} from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import * as bcrypt from 'bcrypt';
import { PrismaService } from '../prisma/prisma.service';
import { MailService } from '../mail/mail.service';
import {
  RegisterInput,
  LoginInput,
  RefreshTokenInput,
  VerifyEmailInput,
  RequestPasswordResetInput,
  ResetPasswordInput,
} from './dto/auth.input';
import { AuthResponseType } from './types/auth-response.type';
import { UserType } from './types/user.type';
import { JWT_CONFIG } from './auth.config';
import { randomBytes } from 'crypto';

export interface JwtPayload {
  id: string;
  email: string;
  username: string;
}

const EMAIL_CODE_TTL_MINUTES = parseInt(
  process.env.EMAIL_VERIFICATION_CODE_TTL_MINUTES || '15',
  10,
);

@Injectable()
export class AuthService {
  constructor(
    private prisma: PrismaService,
    private jwtService: JwtService,
    private mailService: MailService,
  ) {}

  /**
   * Регистрация нового пользователя.
   * После создания — генерирует и отправляет 6-значный код подтверждения email.
   */
  async register(input: RegisterInput): Promise<AuthResponseType> {
    const { email, username, password } = input;

    if (!this.isValidEmail(email)) {
      throw new BadRequestException('Incorrect email');
    }

    if (password.length < 6) {
      throw new BadRequestException(
        'Password must be at least 6 characters long',
      );
    }

    const existingByEmail = await this.prisma.user.findUnique({
      where: { email },
    });
    if (existingByEmail) {
      throw new ConflictException('User with this email already exists');
    }

    const existingByUsername = await this.prisma.user.findUnique({
      where: { username },
    });
    if (existingByUsername) {
      throw new ConflictException('Username is already taken');
    }

    const passwordHash = await this.hashPassword(password);

    const user = await this.prisma.user.create({
      data: { email, username, passwordHash },
    });

    await this.sendVerificationCode(user.id, email, username);

    const accessToken = await this.generateAccessToken(user);
    const refreshToken = await this.generateRefreshToken(user);

    return {
      accessToken,
      refreshToken,
      user: this.excludePassword(user),
    };
  }

  /**
   * Генерирует новый 6-значный код и отправляет его на email пользователя.
   * Любые предыдущие неиспользованные коды остаются в БД (истекут сами).
   */
  private async sendVerificationCode(
    userId: string,
    email: string,
    username: string,
  ): Promise<void> {
    const code = this.generateVerificationCode();
    const expiresAt = new Date();
    expiresAt.setMinutes(expiresAt.getMinutes() + EMAIL_CODE_TTL_MINUTES);

    await this.prisma.emailVerification.create({
      data: { userId, code, expiresAt },
    });

    await this.mailService.sendEmailVerificationCode(email, username, code);
  }

  /**
   * Подтверждение email по 6-значному коду.
   * Повторно запрашивает код, если предыдущий истёк — нужно вызвать resendVerificationCode.
   */
  async verifyEmail(userId: string, input: VerifyEmailInput): Promise<UserType> {
    const user = await this.prisma.user.findUnique({ where: { id: userId } });
    if (!user) {
      throw new UnauthorizedException('User not found');
    }

    if (user.emailVerifiedAt) {
      throw new BadRequestException('Email is already verified');
    }

    const verification = await this.prisma.emailVerification.findFirst({
      where: {
        userId,
        code: input.code,
        usedAt: null,
        expiresAt: { gt: new Date() },
      },
      orderBy: { createdAt: 'desc' },
    });

    if (!verification) {
      throw new BadRequestException('Invalid or expired verification code');
    }

    const [updatedUser] = await this.prisma.$transaction([
      this.prisma.user.update({
        where: { id: userId },
        data: { emailVerifiedAt: new Date() },
      }),
      this.prisma.emailVerification.update({
        where: { id: verification.id },
        data: { usedAt: new Date() },
      }),
    ]);

    return this.excludePassword(updatedUser);
  }

  /**
   * Повторная отправка кода подтверждения.
   */
  async resendVerificationCode(userId: string): Promise<boolean> {
    const user = await this.prisma.user.findUnique({ where: { id: userId } });
    if (!user) {
      throw new UnauthorizedException('User not found');
    }

    if (user.emailVerifiedAt) {
      throw new BadRequestException('Email is already verified');
    }

    await this.sendVerificationCode(user.id, user.email, user.username);
    return true;
  }

  /**
   * Вход пользователя по username ИЛИ email и паролю.
   */
  async login(input: LoginInput): Promise<AuthResponseType> {
    const { identifier, password } = input;

    const isEmail = this.isValidEmail(identifier);

    const user = isEmail
      ? await this.prisma.user.findUnique({ where: { email: identifier } })
      : await this.prisma.user.findUnique({ where: { username: identifier } });

    if (!user) {
      throw new UnauthorizedException('Incorrect login or password');
    }

    const isPasswordValid = await this.verifyPassword(password, user.passwordHash);
    if (!isPasswordValid) {
      throw new UnauthorizedException('Incorrect login or password');
    }

    const accessToken = await this.generateAccessToken(user);
    const refreshToken = await this.generateRefreshToken(user);

    return {
      accessToken,
      refreshToken,
      user: this.excludePassword(user),
    };
  }

  /**
   * Получение текущего пользователя по токену.
   */
  async getCurrentUser(userId: string): Promise<UserType> {
    const user = await this.prisma.user.findUnique({ where: { id: userId } });
    if (!user) {
      throw new UnauthorizedException('User not found');
    }
    return this.excludePassword(user);
  }

  /**
   * Валидация пользователя для JWT стратегии.
   */
  async validateUser(payload: JwtPayload): Promise<any | null> {
    return this.prisma.user.findUnique({ where: { id: payload.id } });
  }

  /**
   * Обновление access token с помощью refresh token.
   */
  async refreshAccessToken(input: RefreshTokenInput): Promise<AuthResponseType> {
    const { refreshToken } = input;

    const tokens = await this.prisma.refreshToken.findMany({
      where: {
        revokedAt: null,
        expiresAt: { gt: new Date() },
      },
      include: { user: true },
    });

    let validToken: (typeof tokens)[0] | null = null;
    for (const token of tokens) {
      const isValid = await bcrypt.compare(refreshToken, token.tokenHash);
      if (isValid) {
        validToken = token;
        break;
      }
    }

    if (!validToken) {
      throw new UnauthorizedException('Invalid or expired refresh token');
    }

    const accessToken = await this.generateAccessToken(validToken.user);
    const newRefreshToken = await this.generateRefreshToken(validToken.user);

    await this.prisma.refreshToken.update({
      where: { id: validToken.id },
      data: { revokedAt: new Date() },
    });

    return {
      accessToken,
      refreshToken: newRefreshToken,
      user: this.excludePassword(validToken.user),
    };
  }

  /**
   * Отзыв refresh token (logout).
   */
  async revokeRefreshToken(refreshToken: string): Promise<boolean> {
    const tokens = await this.prisma.refreshToken.findMany({
      where: { revokedAt: null },
    });

    for (const token of tokens) {
      const isValid = await bcrypt.compare(refreshToken, token.tokenHash);
      if (isValid) {
        await this.prisma.refreshToken.update({
          where: { id: token.id },
          data: { revokedAt: new Date() },
        });
        return true;
      }
    }

    return false;
  }

  /**
   * Отзыв всех refresh tokens пользователя.
   */
  async revokeAllUserTokens(userId: string): Promise<number> {
    const result = await this.prisma.refreshToken.updateMany({
      where: { userId, revokedAt: null },
      data: { revokedAt: new Date() },
    });
    return result.count;
  }

  /**
   * Смена пароля.
   */
  async changePassword(
    userId: string,
    oldPassword: string,
    newPassword: string,
  ): Promise<boolean> {
    const user = await this.prisma.user.findUnique({ where: { id: userId } });
    if (!user) {
      throw new UnauthorizedException('User not found');
    }

    const isPasswordValid = await this.verifyPassword(oldPassword, user.passwordHash);
    if (!isPasswordValid) {
      throw new UnauthorizedException('Incorrect current password');
    }

    if (newPassword.length < 6) {
      throw new BadRequestException(
        'Password must be at least 6 characters long',
      );
    }

    const newPasswordHash = await this.hashPassword(newPassword);

    await this.prisma.user.update({
      where: { id: userId },
      data: { passwordHash: newPasswordHash },
    });

    return true;
  }

  /**
   * Запрос сброса пароля: отправляет 6-значный код на email.
   * Не раскрывает, существует ли пользователь (всегда возвращает true).
   */
  async requestPasswordReset(input: RequestPasswordResetInput): Promise<boolean> {
    const user = await this.prisma.user.findUnique({
      where: { email: input.email },
    });

    if (!user) {
      // Не раскрываем существование аккаунта
      return true;
    }

    const code = this.generateVerificationCode();
    const ttl = parseInt(
      process.env.EMAIL_VERIFICATION_CODE_TTL_MINUTES || '15',
      10,
    );
    const expiresAt = new Date();
    expiresAt.setMinutes(expiresAt.getMinutes() + ttl);

    await this.prisma.passwordResetToken.create({
      data: { userId: user.id, code, expiresAt },
    });

    await this.mailService.sendPasswordResetCode(
      user.email,
      user.username,
      code,
      ttl,
    );

    return true;
  }

  /**
   * Сброс пароля по коду из письма.
   */
  async resetPassword(input: ResetPasswordInput): Promise<boolean> {
    const user = await this.prisma.user.findUnique({
      where: { email: input.email },
    });

    if (!user) {
      throw new BadRequestException('Invalid or expired reset code');
    }

    const token = await this.prisma.passwordResetToken.findFirst({
      where: {
        userId: user.id,
        code: input.code,
        usedAt: null,
        expiresAt: { gt: new Date() },
      },
      orderBy: { createdAt: 'desc' },
    });

    if (!token) {
      throw new BadRequestException('Invalid or expired reset code');
    }

    if (input.newPassword.length < 6) {
      throw new BadRequestException(
        'Password must be at least 6 characters long',
      );
    }

    const newPasswordHash = await this.hashPassword(input.newPassword);

    await this.prisma.$transaction([
      this.prisma.user.update({
        where: { id: user.id },
        data: { passwordHash: newPasswordHash },
      }),
      this.prisma.passwordResetToken.update({
        where: { id: token.id },
        data: { usedAt: new Date() },
      }),
    ]);

    return true;
  }

  // ─── Приватные вспомогательные методы ───────────────────────────────────────

  private async hashPassword(password: string): Promise<string> {
    return bcrypt.hash(password, 10);
  }

  private async verifyPassword(password: string, hash: string): Promise<boolean> {
    return bcrypt.compare(password, hash);
  }

  private async generateAccessToken(user: any): Promise<string> {
    const payload: JwtPayload = {
      id: user.id,
      email: user.email,
      username: user.username,
    };
    return this.jwtService.sign(payload as any, {
      expiresIn: JWT_CONFIG.accessTokenExpiresIn as any,
      secret: JWT_CONFIG.secret as any,
    });
  }

  private async generateRefreshToken(user: any): Promise<string> {
    const token = randomBytes(32).toString('hex');
    const tokenHash = await bcrypt.hash(token, 10);

    const expiresAt = new Date();
    const days = parseInt(
      JWT_CONFIG.refreshTokenExpiresIn.replace('d', ''),
      10,
    );
    expiresAt.setDate(expiresAt.getDate() + days);

    await this.prisma.refreshToken.create({
      data: { tokenHash, userId: user.id, expiresAt },
    });

    return token;
  }

  private generateVerificationCode(): string {
    return Math.floor(100000 + Math.random() * 900000).toString();
  }

  private excludePassword(user: any): UserType {
    const { passwordHash, ...rest } = user;
    return rest as UserType;
  }

  private isValidEmail(value: string): boolean {
    return /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(value);
  }
}
