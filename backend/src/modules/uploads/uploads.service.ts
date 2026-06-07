import { Injectable, Logger } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { existsSync, mkdirSync } from 'fs';
import { join } from 'path';

@Injectable()
export class UploadsService {
  private readonly logger = new Logger(UploadsService.name);
  readonly uploadDir: string;

  constructor(private readonly config: ConfigService) {
    this.uploadDir = this.config.get<string>('UPLOAD_DIR', './uploads');
    if (!existsSync(this.uploadDir)) {
      mkdirSync(this.uploadDir, { recursive: true });
    }
    this.logger.log(`Upload directory: ${this.uploadDir}`);
  }

  getAvatarUrl(filename: string): string {
    return `/uploads/avatars/${filename}`;
  }

  getAvatarPath(filename: string): string {
    return join(this.uploadDir, 'avatars', filename);
  }
}
