import { Test, TestingModule } from '@nestjs/testing';
import { JwtService } from '@nestjs/jwt';
import {
  UnauthorizedException,
  ConflictException,
  BadRequestException,
} from '@nestjs/common';
import * as bcrypt from 'bcrypt';
import { AuthService } from './auth.service';
import { PrismaService } from '../prisma/prisma.service';
import { RegisterInput, LoginInput, RefreshTokenInput } from './dto/auth.input';

// Mock bcrypt
jest.mock('bcrypt');

describe('AuthService', () => {
  let service: AuthService;
  let prismaService: PrismaService;
  let jwtService: JwtService;

  const mockUser = {
    id: 'user-id-123',
    email: 'test@example.com',
    username: 'testuser',
    passwordHash: 'hashed_password',
    createdAt: new Date(),
    updatedAt: new Date(),
  };

  const mockUserWithoutPassword = {
    id: 'user-id-123',
    email: 'test@example.com',
    username: 'testuser',
    createdAt: mockUser.createdAt,
    updatedAt: mockUser.updatedAt,
  };

  const mockPrismaService = {
    user: {
      findUnique: jest.fn(),
      create: jest.fn(),
      update: jest.fn(),
    },
    refreshToken: {
      create: jest.fn(),
      findMany: jest.fn(),
      update: jest.fn(),
      updateMany: jest.fn(),
    },
  };

  const mockJwtService = {
    sign: jest.fn(),
    verify: jest.fn(),
  };

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [
        AuthService,
        {
          provide: PrismaService,
          useValue: mockPrismaService,
        },
        {
          provide: JwtService,
          useValue: mockJwtService,
        },
      ],
    }).compile();

    service = module.get<AuthService>(AuthService);
    prismaService = module.get<PrismaService>(PrismaService);
    jwtService = module.get<JwtService>(JwtService);

    // Reset all mocks before each test
    jest.clearAllMocks();
  });

  it('should be defined', () => {
    expect(service).toBeDefined();
  });

  describe('register', () => {
    const registerInput: RegisterInput = {
      email: 'newuser@example.com',
      username: 'newuser',
      password: 'password123',
    };

    it('should successfully register a new user', async () => {
      mockPrismaService.user.findUnique.mockResolvedValue(null);
      mockPrismaService.user.create.mockResolvedValue(mockUser);
      mockPrismaService.refreshToken.create.mockResolvedValue({});
      (bcrypt.hash as jest.Mock).mockResolvedValue('hashed_password');
      mockJwtService.sign.mockReturnValue('mock_token');

      const result = await service.register(registerInput);

      expect(result).toHaveProperty('accessToken');
      expect(result).toHaveProperty('refreshToken');
      expect(result).toHaveProperty('user');
      expect(result.user).not.toHaveProperty('passwordHash');
      expect(mockPrismaService.user.create).toHaveBeenCalledWith({
        data: {
          email: registerInput.email,
          username: registerInput.username,
          passwordHash: 'hashed_password',
        },
      });
    });

    it('should throw BadRequestException for invalid email', async () => {
      const invalidInput = { ...registerInput, email: 'invalid-email' };

      await expect(service.register(invalidInput)).rejects.toThrow(
        BadRequestException,
      );
      await expect(service.register(invalidInput)).rejects.toThrow(
        'incorrect email',
      );
    });

    it('should throw BadRequestException for short password', async () => {
      const invalidInput = { ...registerInput, password: '12345' };

      await expect(service.register(invalidInput)).rejects.toThrow(
        BadRequestException,
      );
      await expect(service.register(invalidInput)).rejects.toThrow(
        'Password must be at least 6 characters long',
      );
    });

    it('should throw ConflictException if user already exists', async () => {
      mockPrismaService.user.findUnique.mockResolvedValue(mockUser);

      await expect(service.register(registerInput)).rejects.toThrow(
        ConflictException,
      );
      await expect(service.register(registerInput)).rejects.toThrow(
        'User with this email already exists',
      );
    });
  });

  describe('login', () => {
    const loginInput: LoginInput = {
      email: 'test@example.com',
      password: 'password123',
    };

    it('should successfully login a user with correct credentials', async () => {
      mockPrismaService.user.findUnique.mockResolvedValue(mockUser);
      mockPrismaService.refreshToken.create.mockResolvedValue({});
      (bcrypt.compare as jest.Mock).mockResolvedValue(true);
      mockJwtService.sign.mockReturnValue('mock_token');

      const result = await service.login(loginInput);

      expect(result).toHaveProperty('accessToken');
      expect(result).toHaveProperty('refreshToken');
      expect(result).toHaveProperty('user');
      expect(result.user).not.toHaveProperty('passwordHash');
      expect(mockPrismaService.user.findUnique).toHaveBeenCalledWith({
        where: { email: loginInput.email },
      });
    });

    it('should throw UnauthorizedException if user not found', async () => {
      mockPrismaService.user.findUnique.mockResolvedValue(null);

      await expect(service.login(loginInput)).rejects.toThrow(
        UnauthorizedException,
      );
      await expect(service.login(loginInput)).rejects.toThrow(
        'Incorrect email or password',
      );
    });

    it('should throw UnauthorizedException if password is incorrect', async () => {
      mockPrismaService.user.findUnique.mockResolvedValue(mockUser);
      (bcrypt.compare as jest.Mock).mockResolvedValue(false);

      await expect(service.login(loginInput)).rejects.toThrow(
        UnauthorizedException,
      );
      await expect(service.login(loginInput)).rejects.toThrow(
        'Incorrect email or password',
      );
    });
  });

  describe('getCurrentUser', () => {
    it('should return user without password', async () => {
      mockPrismaService.user.findUnique.mockResolvedValue(mockUser);

      const result = await service.getCurrentUser('user-id-123');

      expect(result).toEqual(mockUserWithoutPassword);
      expect(result).not.toHaveProperty('passwordHash');
      expect(mockPrismaService.user.findUnique).toHaveBeenCalledWith({
        where: { id: 'user-id-123' },
      });
    });

    it('should throw UnauthorizedException if user not found', async () => {
      mockPrismaService.user.findUnique.mockResolvedValue(null);

      await expect(service.getCurrentUser('invalid-id')).rejects.toThrow(
        UnauthorizedException,
      );
      await expect(service.getCurrentUser('invalid-id')).rejects.toThrow(
        'User not found',
      );
    });
  });

  describe('validateUser', () => {
    it('should return user if found', async () => {
      const payload = {
        id: 'user-id-123',
        email: 'test@example.com',
        username: 'testuser',
      };
      mockPrismaService.user.findUnique.mockResolvedValue(mockUser);

      const result = await service.validateUser(payload);

      expect(result).toEqual(mockUser);
      expect(mockPrismaService.user.findUnique).toHaveBeenCalledWith({
        where: { id: payload.id },
      });
    });

    it('should return null if user not found', async () => {
      const payload = {
        id: 'invalid-id',
        email: 'test@example.com',
        username: 'testuser',
      };
      mockPrismaService.user.findUnique.mockResolvedValue(null);

      const result = await service.validateUser(payload);

      expect(result).toBeNull();
    });
  });

  describe('refreshAccessToken', () => {
    const refreshTokenInput: RefreshTokenInput = {
      refreshToken: 'valid_refresh_token',
    };

    const mockRefreshToken = {
      id: 'token-id-123',
      tokenHash: 'hashed_token',
      userId: 'user-id-123',
      expiresAt: new Date(Date.now() + 7 * 24 * 60 * 60 * 1000),
      revokedAt: null,
      createdAt: new Date(),
      user: mockUser,
    };

    it('should successfully refresh access token', async () => {
      mockPrismaService.refreshToken.findMany.mockResolvedValue([
        mockRefreshToken,
      ]);
      mockPrismaService.refreshToken.update.mockResolvedValue({});
      mockPrismaService.refreshToken.create.mockResolvedValue({});
      (bcrypt.compare as jest.Mock).mockResolvedValue(true);
      (bcrypt.hash as jest.Mock).mockResolvedValue('new_hashed_token');
      mockJwtService.sign.mockReturnValue('new_access_token');

      const result = await service.refreshAccessToken(refreshTokenInput);

      expect(result).toHaveProperty('accessToken');
      expect(result).toHaveProperty('refreshToken');
      expect(result).toHaveProperty('user');
      expect(result.user).not.toHaveProperty('passwordHash');
      expect(mockPrismaService.refreshToken.update).toHaveBeenCalledWith({
        where: { id: mockRefreshToken.id },
        data: { revokedAt: expect.any(Date) },
      });
    });

    it('should throw UnauthorizedException for invalid refresh token', async () => {
      mockPrismaService.refreshToken.findMany.mockResolvedValue([
        mockRefreshToken,
      ]);
      (bcrypt.compare as jest.Mock).mockResolvedValue(false);

      await expect(
        service.refreshAccessToken(refreshTokenInput),
      ).rejects.toThrow(UnauthorizedException);
      await expect(
        service.refreshAccessToken(refreshTokenInput),
      ).rejects.toThrow('Invalid or expired refresh token');
    });

    it('should throw UnauthorizedException for expired refresh token', async () => {
      const expiredToken = {
        ...mockRefreshToken,
        expiresAt: new Date(Date.now() - 1000),
      };
      mockPrismaService.refreshToken.findMany.mockResolvedValue([expiredToken]);

      await expect(
        service.refreshAccessToken(refreshTokenInput),
      ).rejects.toThrow(UnauthorizedException);
    });
  });

  describe('revokeRefreshToken', () => {
    const mockRefreshToken = {
      id: 'token-id-123',
      tokenHash: 'hashed_token',
      userId: 'user-id-123',
      expiresAt: new Date(Date.now() + 7 * 24 * 60 * 60 * 1000),
      revokedAt: null,
      createdAt: new Date(),
    };

    it('should successfully revoke a refresh token', async () => {
      mockPrismaService.refreshToken.findMany.mockResolvedValue([
        mockRefreshToken,
      ]);
      mockPrismaService.refreshToken.update.mockResolvedValue({});
      (bcrypt.compare as jest.Mock).mockResolvedValue(true);

      const result = await service.revokeRefreshToken('valid_refresh_token');

      expect(result).toBe(true);
      expect(mockPrismaService.refreshToken.update).toHaveBeenCalledWith({
        where: { id: mockRefreshToken.id },
        data: { revokedAt: expect.any(Date) },
      });
    });

    it('should return false if token not found', async () => {
      mockPrismaService.refreshToken.findMany.mockResolvedValue([
        mockRefreshToken,
      ]);
      (bcrypt.compare as jest.Mock).mockResolvedValue(false);

      const result = await service.revokeRefreshToken('invalid_token');

      expect(result).toBe(false);
    });
  });

  describe('revokeAllUserTokens', () => {
    it('should revoke all user tokens', async () => {
      mockPrismaService.refreshToken.updateMany.mockResolvedValue({ count: 3 });

      const result = await service.revokeAllUserTokens('user-id-123');

      expect(result).toBe(3);
      expect(mockPrismaService.refreshToken.updateMany).toHaveBeenCalledWith({
        where: {
          userId: 'user-id-123',
          revokedAt: null,
        },
        data: {
          revokedAt: expect.any(Date),
        },
      });
    });

    it('should return 0 if no tokens to revoke', async () => {
      mockPrismaService.refreshToken.updateMany.mockResolvedValue({ count: 0 });

      const result = await service.revokeAllUserTokens('user-id-123');

      expect(result).toBe(0);
    });
  });

  describe('changePassword', () => {
    it('should successfully change password', async () => {
      mockPrismaService.user.findUnique.mockResolvedValue(mockUser);
      mockPrismaService.user.update.mockResolvedValue(mockUser);
      (bcrypt.compare as jest.Mock).mockResolvedValue(true);
      (bcrypt.hash as jest.Mock).mockResolvedValue('new_hashed_password');

      const result = await service.changePassword(
        'user-id-123',
        'oldPassword123',
        'newPassword123',
      );

      expect(result).toBe(true);
      expect(mockPrismaService.user.update).toHaveBeenCalledWith({
        where: { id: 'user-id-123' },
        data: { passwordHash: 'new_hashed_password' },
      });
    });

    it('should throw UnauthorizedException if user not found', async () => {
      mockPrismaService.user.findUnique.mockResolvedValue(null);

      await expect(
        service.changePassword('invalid-id', 'oldPassword', 'newPassword'),
      ).rejects.toThrow(UnauthorizedException);
      await expect(
        service.changePassword('invalid-id', 'oldPassword', 'newPassword'),
      ).rejects.toThrow('User not found');
    });

    it('should throw UnauthorizedException if old password is incorrect', async () => {
      mockPrismaService.user.findUnique.mockResolvedValue(mockUser);
      (bcrypt.compare as jest.Mock).mockResolvedValue(false);

      await expect(
        service.changePassword('user-id-123', 'wrongPassword', 'newPassword123'),
      ).rejects.toThrow(UnauthorizedException);
      await expect(
        service.changePassword('user-id-123', 'wrongPassword', 'newPassword123'),
      ).rejects.toThrow('Incorrect current password');
    });

    it('should throw BadRequestException if new password is too short', async () => {
      mockPrismaService.user.findUnique.mockResolvedValue(mockUser);
      (bcrypt.compare as jest.Mock).mockResolvedValue(true);

      await expect(
        service.changePassword('user-id-123', 'oldPassword123', '12345'),
      ).rejects.toThrow(BadRequestException);
      await expect(
        service.changePassword('user-id-123', 'oldPassword123', '12345'),
      ).rejects.toThrow('Password must be at least 6 characters long');
    });
  });
});
