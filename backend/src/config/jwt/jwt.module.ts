import { Module } from '@nestjs/common';
import { JwtModule } from '@nestjs/jwt';
import { ConfigModule, ConfigService } from '@nestjs/config';
import { JwtConfig } from './jwt.config';

@Module({
  imports: [
    JwtModule.registerAsync({
      imports: [ConfigModule],
      inject: [ConfigService],
      useFactory: (config: ConfigService) => ({
        secret: JwtConfig.accessTokenSecret(config),
        signOptions: {
          expiresIn: JwtConfig.accessTokenExpiry(config),
        },
      }),
      global: true,
    }),
  ],
  exports: [JwtModule],
})
export class JwtConfigModule {}
