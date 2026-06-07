import {
  Injectable,
  UnauthorizedException,
  BadRequestException,
  Logger,
} from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { JwtService } from '@nestjs/jwt';
import * as bcrypt from 'bcrypt';
import { v4 as uuidv4 } from 'uuid';

import { UsersService } from '../users/users.service';
import { CreateUserDto } from '../users/dto/create-user.dto';
import { RegisterDto } from './dto/register.dto';
import { LoginDto } from './dto/login.dto';
import { VerifyOtpDto } from './dto/verify-otp.dto';
import { ForgotPasswordDto } from './dto/forgot-password.dto';
import { ResetPasswordDto } from './dto/reset-password.dto';
import { AuthResponseDto } from './dto/auth-response.dto';
import { JwtPayload } from './strategies/jwt.strategy';

@Injectable()
export class AuthService {
  private readonly logger = new Logger(AuthService.name);
  private readonly hardcodedOtp: string;

  constructor(
    private readonly usersService: UsersService,
    private readonly jwtService: JwtService,
    private readonly config: ConfigService,
  ) {
    this.hardcodedOtp = this.config.get<string>('OTP_HARDCODED', '131017');
  }

  // ── Register ──────────────────────────────────────
  async register(dto: RegisterDto): Promise<{ message: string }> {
    const createDto = new CreateUserDto();
    createDto.fullName = dto.fullName;
    createDto.phone = dto.phone;
    createDto.email = dto.email;
    createDto.password = dto.password;

    await this.usersService.create(createDto);

    this.logger.log(`User registered: ${dto.phone}`);
    return { message: 'OTP sent to your phone' };
  }

  // ── Verify OTP ─────────────────────────────────────
  async verifyOtp(dto: VerifyOtpDto, userAgent?: string): Promise<AuthResponseDto> {
    const isValid = dto.otp === this.hardcodedOtp;
    if (!isValid) {
      throw new BadRequestException('Invalid verification code');
    }

    const user = await this.usersService.findByPhone(dto.phone);
    if (!user) {
      throw new UnauthorizedException('User not found');
    }

    if (!user.isActive) {
      throw new UnauthorizedException('Account is deactivated');
    }

    return this.generateTokens(user, userAgent);
  }

  // ── Login ──────────────────────────────────────────
  async login(dto: LoginDto, userAgent?: string): Promise<AuthResponseDto> {
    const user = await this.usersService.findByLogin(dto.login);
    if (!user) {
      throw new UnauthorizedException('Invalid credentials');
    }

    if (!user.isActive) {
      throw new UnauthorizedException('Account is deactivated');
    }

    const isPasswordValid = await bcrypt.compare(dto.password, user.passwordHash);
    if (!isPasswordValid) {
      throw new UnauthorizedException('Invalid credentials');
    }

    return this.generateTokens(user, userAgent);
  }

  // ── Forgot Password ────────────────────────────────
  async forgotPassword(dto: ForgotPasswordDto): Promise<{ message: string }> {
    const user = await this.usersService.findByPhone(dto.phone);
    if (!user) {
      // Don't reveal whether the phone exists
      return { message: 'If the phone is registered, an OTP has been sent' };
    }

    this.logger.log(`Password reset OTP sent to: ${dto.phone}`);
    return { message: 'OTP sent to your phone' };
  }

  // ── Reset Password ─────────────────────────────────
  async resetPassword(dto: ResetPasswordDto): Promise<{ message: string }> {
    const isValid = dto.otp === this.hardcodedOtp;
    if (!isValid) {
      throw new BadRequestException('Invalid verification code');
    }

    const user = await this.usersService.findByPhone(dto.phone);
    if (!user) {
      throw new UnauthorizedException('User not found');
    }

    await this.usersService.updatePassword(user.id, dto.newPassword);

    this.logger.log(`Password reset for: ${dto.phone}`);
    return { message: 'Password updated successfully' };
  }

  // ── Refresh Token ──────────────────────────────────
  async refreshToken(
    refreshToken: string,
    userAgent?: string,
  ): Promise<AuthResponseDto> {
    let payload: JwtPayload;
    try {
      payload = this.jwtService.verify<JwtPayload>(refreshToken, {
        secret: this.config.get<string>('JWT_REFRESH_SECRET') ?? 'cfpv-refresh-secret-dev',
      });
    } catch {
      throw new UnauthorizedException('Invalid or expired refresh token');
    }

    const user = await this.usersService.findById(payload.sub);
    if (!user || !user.isActive) {
      throw new UnauthorizedException('User not found or deactivated');
    }

    if (user.refreshToken !== refreshToken) {
      throw new UnauthorizedException('Refresh token has been revoked');
    }

    return this.generateTokens(user, userAgent);
  }

  // ── Token Generation ───────────────────────────────
  private async generateTokens(
    user: { id: string; phone: string; role: string },
    _userAgent?: string,
  ): Promise<AuthResponseDto> {
    const payload: JwtPayload = {
      sub: user.id,
      phone: user.phone,
      role: user.role,
    };

    const jwtid = uuidv4();

    const accessToken = this.jwtService.sign(payload, { jwtid });

    const refreshToken = this.jwtService.sign(payload, {
      secret: this.config.get<string>('JWT_REFRESH_SECRET') ?? 'cfpv-refresh-secret-dev',
      expiresIn: this.config.get<string>('JWT_REFRESH_EXPIRY') ?? '30d',
      jwtid,
    });

    // Store refresh token for revocation check
    // Token is self-validating (JWT verify checks signature + expiry)
    await this.usersService.updateRefreshToken(user.id, refreshToken);

    const fullUser = await this.usersService.findById(user.id);
    const userResponse = this.usersService.toResponse(fullUser!);

    return new AuthResponseDto({
      accessToken,
      refreshToken,
      user: userResponse,
    });
  }
}
