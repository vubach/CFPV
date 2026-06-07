import { Test, TestingModule } from '@nestjs/testing';
import { UnauthorizedException, BadRequestException } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { JwtService } from '@nestjs/jwt';
import * as bcrypt from 'bcrypt';
import { v4 as uuidv4 } from 'uuid';

import { AuthService } from './auth.service';
import { UsersService } from '../users/users.service';
import { RegisterDto } from './dto/register.dto';
import { LoginDto } from './dto/login.dto';
import { VerifyOtpDto } from './dto/verify-otp.dto';
import { ForgotPasswordDto } from './dto/forgot-password.dto';
import { ResetPasswordDto } from './dto/reset-password.dto';
import { User, UserRole } from '../users/entities/user.entity';
import { UserResponseDto } from '../users/dto/user-response.dto';
import { AuthResponseDto } from './dto/auth-response.dto';
import { JwtPayload } from './strategies/jwt.strategy';

// ── Mock external modules ───────────────────────────
jest.mock('bcrypt');
jest.mock('uuid');

const mockedBcrypt = jest.mocked(bcrypt);
const mockedUuid = jest.mocked(uuidv4);

// ── Helpers ─────────────────────────────────────────
const mockDate = new Date('2026-01-01T00:00:00Z');
const hardcodedOtp = '131017';
const jwtSecret = 'test-refresh-secret';

function createMockUser(overrides: Partial<User> = {}): User {
  return {
    id: '550e8400-e29b-41d4-a716-446655440000',
    fullName: 'Test User',
    phone: '0987654321',
    email: 'test@cfpv.com',
    passwordHash: '$2b$12$hashedfake',
    role: UserRole.CUSTOMER,
    isActive: true,
    refreshToken: 'valid-refresh-token',
    createdAt: mockDate,
    updatedAt: mockDate,
    deviceTokens: [],
    ...overrides,
  } as User;
}

function createMockUserResponse(user: User): UserResponseDto {
  return new UserResponseDto({
    id: user.id,
    fullName: user.fullName,
    phone: user.phone,
    email: user.email,
    role: user.role,
    isActive: user.isActive,
    createdAt: user.createdAt,
  });
}

// ── Module Setup ────────────────────────────────────
describe('AuthService', () => {
  let service: AuthService;
  let usersService: jest.Mocked<UsersService>;
  let jwtService: jest.Mocked<JwtService>;
  let configService: jest.Mocked<ConfigService>;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [
        AuthService,
        {
          provide: UsersService,
          useValue: {
            create: jest.fn(),
            findById: jest.fn(),
            findByPhone: jest.fn(),
            findByLogin: jest.fn(),
            updateRefreshToken: jest.fn(),
            updatePassword: jest.fn(),
            toResponse: jest.fn(),
          },
        },
        {
          provide: JwtService,
          useValue: {
            sign: jest.fn(),
            verify: jest.fn(),
          },
        },
        {
          provide: ConfigService,
          useValue: {
            get: jest.fn().mockImplementation((key: string, defaultValue?: any) => {
              const config: Record<string, any> = {
                OTP_HARDCODED: hardcodedOtp,
                JWT_REFRESH_SECRET: jwtSecret,
                JWT_REFRESH_EXPIRY: '30d',
              };
              return config[key] ?? defaultValue;
            }),
          },
        },
      ],
    }).compile();

    service = module.get<AuthService>(AuthService);
    usersService = module.get(UsersService) as jest.Mocked<UsersService>;
    jwtService = module.get(JwtService) as jest.Mocked<JwtService>;
    configService = module.get(ConfigService) as jest.Mocked<ConfigService>;

    // Default config stubs
    configService.get.mockImplementation((key: string, defaultValue?: any) => {
      const config: Record<string, any> = {
        OTP_HARDCODED: hardcodedOtp,
        JWT_REFRESH_SECRET: jwtSecret,
        JWT_REFRESH_EXPIRY: '30d',
      };
      return config[key] ?? defaultValue;
    });

    // Default uuid
    mockedUuid.mockReturnValue('uuid-jwtid-12345');

    // Default bcrypt
    (mockedBcrypt.compare as jest.Mock).mockResolvedValue(true);
    (mockedBcrypt.hash as jest.Mock).mockResolvedValue('$2b$12$hashedfake');

    // Default jwt
    jwtService.sign.mockReturnValue('signed-jwt-token');
    jwtService.verify.mockImplementation(
      (token: string) =>
        ({
          sub: '550e8400-e29b-41d4-a716-446655440000',
          phone: '0987654321',
          role: 'customer',
        }) as JwtPayload,
    );

    // Default UsersService
    const user = createMockUser();
    usersService.findById.mockResolvedValue(user);
    usersService.findByPhone.mockResolvedValue(user);
    usersService.findByLogin.mockResolvedValue(user);
    usersService.toResponse.mockImplementation((u: User) => createMockUserResponse(u));
    usersService.updateRefreshToken.mockResolvedValue(undefined);
    usersService.updatePassword.mockResolvedValue(undefined);
    usersService.create.mockResolvedValue(user);
  });

  afterEach(() => {
    jest.clearAllMocks();
  });

  // ────────────────────────────────────────────────────
  //  register()
  // ────────────────────────────────────────────────────
  describe('register', () => {
    const dto: RegisterDto = {
      fullName: 'Test User',
      phone: '0987654321',
      email: 'test@cfpv.com',
      password: 'securePass123',
    };

    it('should create a user and return a success message', async () => {
      const result = await service.register(dto);

      expect(usersService.create).toHaveBeenCalledWith(
        expect.objectContaining({
          fullName: 'Test User',
          phone: '0987654321',
          email: 'test@cfpv.com',
          password: 'securePass123',
        }),
      );
      expect(result).toEqual({ message: 'OTP sent to your phone' });
    });

    it('should propagate errors from UsersService.create (e.g. duplicate phone)', async () => {
      usersService.create.mockRejectedValue(
        new BadRequestException('Phone number already registered'),
      );

      await expect(service.register(dto)).rejects.toThrow('Phone number already registered');
    });

    it('should work without an email', async () => {
      const noEmailDto: RegisterDto = {
        fullName: 'No Email',
        phone: '0987654322',
        password: 'securePass123',
      };

      await service.register(noEmailDto);

      expect(usersService.create).toHaveBeenCalledWith(
        expect.not.objectContaining({ email: expect.anything() }),
      );
    });
  });

  // ────────────────────────────────────────────────────
  //  verifyOtp()
  // ────────────────────────────────────────────────────
  describe('verifyOtp', () => {
    const dto: VerifyOtpDto = {
      phone: '0987654321',
      otp: hardcodedOtp,
    };

    it('should verify OTP, find user, and return tokens', async () => {
      const result = await service.verifyOtp(dto);

      expect(usersService.findByPhone).toHaveBeenCalledWith('0987654321');
      expect(result).toBeInstanceOf(AuthResponseDto);
      expect(result.accessToken).toBe('signed-jwt-token');
      expect(result.refreshToken).toBe('signed-jwt-token');
      expect(result.user.id).toBe('550e8400-e29b-41d4-a716-446655440000');
    });

    it('should throw BadRequestException for invalid OTP', async () => {
      const invalidDto: VerifyOtpDto = { phone: '0987654321', otp: '000000' };

      await expect(service.verifyOtp(invalidDto)).rejects.toThrow(BadRequestException);
      await expect(service.verifyOtp(invalidDto)).rejects.toThrow('Invalid verification code');
    });

    it('should throw UnauthorizedException when user is not found', async () => {
      usersService.findByPhone.mockResolvedValue(null);

      await expect(service.verifyOtp(dto)).rejects.toThrow(UnauthorizedException);
      await expect(service.verifyOtp(dto)).rejects.toThrow('User not found');
    });

    it('should throw UnauthorizedException when account is inactive', async () => {
      usersService.findByPhone.mockResolvedValue(createMockUser({ isActive: false }));

      await expect(service.verifyOtp(dto)).rejects.toThrow(UnauthorizedException);
      await expect(service.verifyOtp(dto)).rejects.toThrow('Account is deactivated');
    });
  });

  // ────────────────────────────────────────────────────
  //  login()
  // ────────────────────────────────────────────────────
  describe('login', () => {
    const dto: LoginDto = {
      login: '0987654321',
      password: 'securePass123',
    };

    it('should authenticate with phone and return tokens', async () => {
      const result = await service.login(dto);

      expect(usersService.findByLogin).toHaveBeenCalledWith('0987654321');
      expect(mockedBcrypt.compare).toHaveBeenCalledWith('securePass123', expect.any(String));
      expect(result.accessToken).toBe('signed-jwt-token');
    });

    it('should authenticate with email when login contains @', async () => {
      const emailDto: LoginDto = { login: 'test@cfpv.com', password: 'securePass123' };

      await service.login(emailDto);

      expect(usersService.findByLogin).toHaveBeenCalledWith('test@cfpv.com');
    });

    it('should throw UnauthorizedException when user not found', async () => {
      usersService.findByLogin.mockResolvedValue(null);

      await expect(service.login(dto)).rejects.toThrow(UnauthorizedException);
      await expect(service.login(dto)).rejects.toThrow('Invalid credentials');
    });

    it('should throw UnauthorizedException when password is wrong', async () => {
      (mockedBcrypt.compare as jest.Mock).mockResolvedValue(false);

      await expect(service.login(dto)).rejects.toThrow(UnauthorizedException);
      await expect(service.login(dto)).rejects.toThrow('Invalid credentials');
    });

    it('should throw UnauthorizedException when account is inactive', async () => {
      usersService.findByLogin.mockResolvedValue(createMockUser({ isActive: false }));

      await expect(service.login(dto)).rejects.toThrow(UnauthorizedException);
      await expect(service.login(dto)).rejects.toThrow('Account is deactivated');
    });
  });

  // ────────────────────────────────────────────────────
  //  forgotPassword()
  // ────────────────────────────────────────────────────
  describe('forgotPassword', () => {
    const dto: ForgotPasswordDto = { phone: '0987654321' };

    it('should return success message when user is found', async () => {
      const result = await service.forgotPassword(dto);

      expect(usersService.findByPhone).toHaveBeenCalledWith('0987654321');
      expect(result).toEqual({ message: 'OTP sent to your phone' });
    });

    it('should return non-revealing message when user is not found', async () => {
      usersService.findByPhone.mockResolvedValue(null);

      const result = await service.forgotPassword(dto);

      expect(result).toEqual({
        message: 'If the phone is registered, an OTP has been sent',
      });
    });
  });

  // ────────────────────────────────────────────────────
  //  resetPassword()
  // ────────────────────────────────────────────────────
  describe('resetPassword', () => {
    const dto: ResetPasswordDto = {
      phone: '0987654321',
      otp: hardcodedOtp,
      newPassword: 'newSecurePass456',
    };

    it('should update password and return success message', async () => {
      const result = await service.resetPassword(dto);

      expect(usersService.findByPhone).toHaveBeenCalledWith('0987654321');
      expect(usersService.updatePassword).toHaveBeenCalledWith(
        '550e8400-e29b-41d4-a716-446655440000',
        'newSecurePass456',
      );
      expect(result).toEqual({ message: 'Password updated successfully' });
    });

    it('should throw BadRequestException for invalid OTP', async () => {
      const invalidDto: ResetPasswordDto = {
        phone: '0987654321',
        otp: '000000',
        newPassword: 'newSecurePass456',
      };

      await expect(service.resetPassword(invalidDto)).rejects.toThrow(BadRequestException);
      await expect(service.resetPassword(invalidDto)).rejects.toThrow('Invalid verification code');
    });

    it('should throw UnauthorizedException when user not found', async () => {
      usersService.findByPhone.mockResolvedValue(null);

      await expect(service.resetPassword(dto)).rejects.toThrow(UnauthorizedException);
      await expect(service.resetPassword(dto)).rejects.toThrow('User not found');
    });
  });

  // ────────────────────────────────────────────────────
  //  refreshToken()
  // ────────────────────────────────────────────────────
  describe('refreshToken', () => {
    const validToken = 'valid-refresh-token';
    const expiredToken = 'expired-refresh-token';

    it('should verify token, find user, check revocation, and generate new tokens', async () => {
      const user = createMockUser({ refreshToken: validToken });
      usersService.findById.mockResolvedValue(user);

      const result = await service.refreshToken(validToken);

      expect(jwtService.verify).toHaveBeenCalledWith(validToken, {
        secret: jwtSecret,
      });
      expect(usersService.findById).toHaveBeenCalledWith(
        '550e8400-e29b-41d4-a716-446655440000',
      );
      expect(usersService.updateRefreshToken).toHaveBeenCalled();
      expect(result.accessToken).toBe('signed-jwt-token');
      expect(result.refreshToken).toBe('signed-jwt-token');
    });

    it('should throw UnauthorizedException for invalid/expired token', async () => {
      jwtService.verify.mockImplementation(() => {
        throw new Error('jwt expired');
      });

      await expect(service.refreshToken(expiredToken)).rejects.toThrow(UnauthorizedException);
      await expect(service.refreshToken(expiredToken)).rejects.toThrow(
        'Invalid or expired refresh token',
      );
    });

    it('should throw UnauthorizedException when user not found', async () => {
      usersService.findById.mockResolvedValue(null);

      await expect(service.refreshToken(validToken)).rejects.toThrow(UnauthorizedException);
      await expect(service.refreshToken(validToken)).rejects.toThrow(
        'User not found or deactivated',
      );
    });

    it('should throw UnauthorizedException when account is deactivated', async () => {
      usersService.findById.mockResolvedValue(createMockUser({ isActive: false }));

      await expect(service.refreshToken(validToken)).rejects.toThrow(UnauthorizedException);
      await expect(service.refreshToken(validToken)).rejects.toThrow(
        'User not found or deactivated',
      );
    });

    it('should throw UnauthorizedException when refresh token has been revoked', async () => {
      const user = createMockUser({ refreshToken: 'different-token' });
      usersService.findById.mockResolvedValue(user);

      await expect(service.refreshToken(validToken)).rejects.toThrow(UnauthorizedException);
      await expect(service.refreshToken(validToken)).rejects.toThrow(
        'Refresh token has been revoked',
      );
    });
  });
});
