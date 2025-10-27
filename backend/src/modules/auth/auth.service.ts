import {
  Injectable,
  UnauthorizedException,
  ConflictException,
  BadRequestException,
} from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import * as bcrypt from 'bcrypt';
import { PrismaService } from '../prisma/prisma.service';
import { RegisterInput, LoginInput, RefreshTokenInput } from './dto/auth.input';
import { AuthResponseType } from './types/auth-response.type';
import { UserType } from './types/user.type';
import { JWT_CONFIG } from './auth.config';
import { randomBytes } from 'crypto';

export interface JwtPayload {
  id: string;
  email: string;
  username: string;
}

@Injectable()
export class AuthService {
  constructor(
    private prisma: PrismaService,
    private jwtService: JwtService,
  ) {}

  /**
   * Регистрация нового пользователя
   */
  async register(input: RegisterInput): Promise<AuthResponseType> {
    const { email, username, password } = input;

    // Проверка валидности email
    if (!this.isValidEmail(email)) {
      throw new BadRequestException('incorrect email');
    }

    // Проверка длины пароля
    if (password.length < 6) {
      throw new BadRequestException('Password must be at least 6 characters long');
    }

    // Проверка существования пользователя
    const existingUser = await this.prisma.user.findUnique({
      where: { email },
    });

    if (existingUser) {
      throw new ConflictException('User with this email already exists');
    }

    // Хеширование пароля
    const passwordHash = await this.hashPassword(password);

    // Создание пользователя
    const user = await this.prisma.user.create({
      data: {
        email,
        username,
        passwordHash,
      },
    });

    // Генерация токенов
    const accessToken = await this.generateAccessToken(user);
    const refreshToken = await this.generateRefreshToken(user);

    return {
      accessToken,
      refreshToken,
      user: this.excludePassword(user),
    };
  }

  /**
   * Вход пользователя
   */
  async login(input: LoginInput): Promise<AuthResponseType> {
    const { email, password } = input;

    // Поиск пользователя
    const user = await this.prisma.user.findUnique({
      where: { email },
    });

    if (!user) {
      throw new UnauthorizedException('Incorrect email or password');
    }

    // Проверка пароля
    const isPasswordValid = await this.verifyPassword(
      password,
      user.passwordHash,
    );

    if (!isPasswordValid) {
      throw new UnauthorizedException('Incorrect email or password');
    }

    // Генерация токенов
    const accessToken = await this.generateAccessToken(user);
    const refreshToken = await this.generateRefreshToken(user);

    return {
      accessToken,
      refreshToken,
      user: this.excludePassword(user),
    };
  }

  /**
   * Получение текущего пользователя по токену
   */
  async getCurrentUser(userId: string): Promise<UserType> {
    const user = await this.prisma.user.findUnique({
      where: { id: userId },
    });

    if (!user) {
      throw new UnauthorizedException('User not found');
    }

    return this.excludePassword(user);
  }

  /**
   * Валидация пользователя для JWT стратегии
   */
  async validateUser(payload: JwtPayload): Promise<any | null> {
    const user = await this.prisma.user.findUnique({
      where: { id: payload.id },
    });

    return user;
  }

  /**
   * Хеширование пароля
   */
  private async hashPassword(password: string): Promise<string> {
    const saltRounds = 10;
    return bcrypt.hash(password, saltRounds);
  }

  /**
   * Проверка пароля
   */
  private async verifyPassword(
    password: string,
    hash: string,
  ): Promise<boolean> {
    return bcrypt.compare(password, hash);
  }

  /**
   * Генерация JWT токена
   */
  private async generateToken(user: any): Promise<string> {
    const payload: JwtPayload = {
      id: user.id,
      email: user.email,
      username: user.username,
    };

    return this.jwtService.sign(payload);
  }

  /**
   * Генерация access token (короткоживущий)
   */
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

  /**
   * Генерация refresh token (долгоживущий)
   */
  private async generateRefreshToken(user: any): Promise<string> {
    // Генерация случайного токена
    const token = randomBytes(32).toString('hex');
    
    // Хеширование токена для безопасного хранения
    const tokenHash = await bcrypt.hash(token, 10);
    
    // Вычисление времени истечения
    const expiresAt = new Date();
    const days = parseInt(JWT_CONFIG.refreshTokenExpiresIn.replace('d', ''));
    expiresAt.setDate(expiresAt.getDate() + days);

    // Сохранение хеша токена в БД
    await this.prisma.refreshToken.create({
      data: {
        tokenHash,
        userId: user.id,
        expiresAt,
      },
    });

    return token;
  }

  /**
   * Обновление access token с помощью refresh token
   */
  async refreshAccessToken(input: RefreshTokenInput): Promise<AuthResponseType> {
    const { refreshToken } = input;

    // Поиск всех активных refresh tokens пользователей
    const tokens = await this.prisma.refreshToken.findMany({
      where: {
        revokedAt: null,
        expiresAt: {
          gt: new Date(),
        },
      },
      include: {
        user: true,
      },
    });

    // Проверка токена по хешу
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

    // Генерация нового access token
    const accessToken = await this.generateAccessToken(validToken.user);
    
    // Опционально: ротация refresh token (генерация нового)
    const newRefreshToken = await this.generateRefreshToken(validToken.user);
    
    // Отзыв старого refresh token
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
   * Отзыв refresh token (logout)
   */
  async revokeRefreshToken(refreshToken: string): Promise<boolean> {
    // Поиск всех активных refresh tokens
    const tokens = await this.prisma.refreshToken.findMany({
      where: {
        revokedAt: null,
      },
    });

    // Проверка токена по хешу
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
   * Отзыв всех refresh tokens пользователя
   */
  async revokeAllUserTokens(userId: string): Promise<number> {
    const result = await this.prisma.refreshToken.updateMany({
      where: {
        userId,
        revokedAt: null,
      },
      data: {
        revokedAt: new Date(),
      },
    });

    return result.count;
  }

  /**
   * Исключение пароля из объекта пользователя
   */
  private excludePassword(user: any): UserType {
    const { passwordHash, ...userWithoutPassword } = user;
    return userWithoutPassword as UserType;
  }

  /**
   * Простая валидация email
   */
  private isValidEmail(email: string): boolean {
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    return emailRegex.test(email);
  }

  /**
   * Смена пароля
   */
  async changePassword(
    userId: string,
    oldPassword: string,
    newPassword: string,
  ): Promise<boolean> {
    const user = await this.prisma.user.findUnique({
      where: { id: userId },
    });

    if (!user) {
      throw new UnauthorizedException('User not found');
    }

    // Проверка старого пароля
    const isPasswordValid = await this.verifyPassword(
      oldPassword,
      user.passwordHash,
    );

    if (!isPasswordValid) {
      throw new UnauthorizedException('Incorrect current password');
    }

    // Проверка длины нового пароля
    if (newPassword.length < 6) {
      throw new BadRequestException('Password must be at least 6 characters long');
    }

    // Хеширование нового пароля
    const newPasswordHash = await this.hashPassword(newPassword);

    // Обновление пароля
    await this.prisma.user.update({
      where: { id: userId },
      data: { passwordHash: newPasswordHash },
    });

    return true;
  }
}
