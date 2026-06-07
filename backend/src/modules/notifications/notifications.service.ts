import { Injectable, Logger } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { DeviceToken } from '../users/entities/device-token.entity';
import { FcmService } from './fcm.service';

@Injectable()
export class NotificationsService {
  private readonly logger = new Logger(NotificationsService.name);

  constructor(
    @InjectRepository(DeviceToken)
    private readonly deviceRepo: Repository<DeviceToken>,
    private readonly fcmService: FcmService,
  ) {}

  async registerDevice(
    userId: string,
    fcmToken: string,
    platform: string,
  ): Promise<void> {
    const existing = await this.deviceRepo.findOne({
      where: { userId, fcmToken },
    });

    if (existing) {
      existing.platform = platform;
      await this.deviceRepo.save(existing);
      this.logger.log(`Device token updated: ${fcmToken.slice(0, 20)}...`);
      return;
    }

    const device = this.deviceRepo.create({ userId, fcmToken, platform });
    await this.deviceRepo.save(device);
    this.logger.log(`Device token registered: ${fcmToken.slice(0, 20)}...`);
  }

  async unregisterDevice(userId: string, tokenId: string): Promise<void> {
    await this.deviceRepo.delete({ id: tokenId, userId });
    this.logger.log(`Device token removed: ${tokenId}`);
  }

  async sendToUser(
    userId: string,
    title: string,
    body: string,
    data?: Record<string, string>,
  ): Promise<void> {
    const tokens = await this.deviceRepo.find({
      where: { userId },
      select: ['fcmToken'],
    });

    if (tokens.length === 0) {
      this.logger.warn(`No device tokens for user ${userId}`);
      return;
    }

    for (const token of tokens) {
      try {
        await this.fcmService.send(token.fcmToken, title, body, data);
      } catch (err) {
        this.logger.error(
          `FCM send failed for token ${token.fcmToken.slice(0, 20)}...: ${err}`,
        );
      }
    }
  }
}
