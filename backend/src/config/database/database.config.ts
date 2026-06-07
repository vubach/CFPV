import { TypeOrmModuleOptions } from '@nestjs/typeorm';
import { ConfigService } from '@nestjs/config';

export class DatabaseConfig {
  static create(config: ConfigService): TypeOrmModuleOptions {
    return {
      type: 'postgres',
      url: config.get<string>('DATABASE_URL'),
      autoLoadEntities: true,
      synchronize: config.get<string>('NODE_ENV') === 'development',
      logging: config.get<string>('NODE_ENV') === 'development',
      ssl: config.get<string>('NODE_ENV') === 'production' ? { rejectUnauthorized: false } : false,
    };
  }
}
