import { ConfigService } from '@nestjs/config';

export class JwtConfig {
  static accessTokenSecret(config: ConfigService): string {
    return config.get<string>('JWT_ACCESS_SECRET') ?? 'cfpv-access-secret-dev';
  }

  static accessTokenExpiry(config: ConfigService): string {
    return config.get<string>('JWT_ACCESS_EXPIRY') ?? '15m';
  }

  static refreshTokenSecret(config: ConfigService): string {
    return config.get<string>('JWT_REFRESH_SECRET') ?? 'cfpv-refresh-secret-dev';
  }

  static refreshTokenExpiry(config: ConfigService): string {
    return config.get<string>('JWT_REFRESH_EXPIRY') ?? '30d';
  }
}
