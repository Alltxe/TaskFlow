import {
  Injectable,
  UnauthorizedException,
  ConflictException,
  BadRequestException,
} from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import * as bcrypt from 'bcrypt';
import { PrismaService } from '../prisma/prisma.service';
import { User } from '@prisma/client';
import { RegisterInput, LoginInput } from './dto/auth.input';
import { AuthResponseType } from './types/auth-response.type';
import { UserType } from './types/user.type';

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

    // Генерация токена
    const accessToken = await this.generateToken(user);

    return {
      accessToken,
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

    // Генерация токена
    const accessToken = await this.generateToken(user);

    return {
      accessToken,
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
  async validateUser(payload: JwtPayload): Promise<User | null> {
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
  private async generateToken(user: User): Promise<string> {
    const payload: JwtPayload = {
      id: user.id,
      email: user.email,
      username: user.username,
    };

    return this.jwtService.sign(payload);
  }

  /**
   * Исключение пароля из объекта пользователя
   */
  private excludePassword(user: User): UserType {
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
