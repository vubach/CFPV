import { Injectable, Logger, OnModuleInit } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import * as admin from 'firebase-admin';

@Injectable()
export class FcmService implements OnModuleInit {
  private readonly logger = new Logger(FcmService.name);
  private initialized = false;

  constructor(private readonly config: ConfigService) {}

  onModuleInit() {
    const serviceAccountPath = this.config.get<string>('FCM_SERVICE_ACCOUNT_PATH');

    if (serviceAccountPath) {
      try {
        const serviceAccount = require(serviceAccountPath);
        admin.initializeApp({ credential: admin.credential.cert(serviceAccount) });
        this.initialized = true;
        this.logger.log('Firebase Admin initialized');
      } catch (err) {
        this.logger.warn(`Failed to initialize Firebase Admin: ${err}`);
      }
    } else {
      const serverKey = this.config.get<string>('FCM_SERVER_KEY');
      if (serverKey) {
        try {
          admin.initializeApp({
            credential: admin.credential.applicationDefault(),
          });
          this.initialized = true;
          this.logger.log('Firebase Admin initialized (application default)');
        } catch (err) {
          this.logger.warn(`Failed to initialize Firebase Admin: ${err}`);
        }
      } else {
        this.logger.warn(
          'Firebase not configured — FCM_SERVICE_ACCOUNT_PATH or FCM_SERVER_KEY missing. ' +
            'Push notifications disabled.',
        );
      }
    }
  }

  async send(
    token: string,
    title: string,
    body: string,
    data?: Record<string, string>,
  ): Promise<void> {
    if (!this.initialized) {
      this.logger.warn(`FCM not available, skipping notification: ${title}`);
      return;
    }

    const message: admin.messaging.TokenMessage = {
      token,
      notification: { title, body },
      data: data ?? {},
      apns: {
        payload: {
          aps: { sound: 'default', badge: 1 },
        },
      },
      android: {
        priority: 'high',
        notification: { channelId: 'default', priority: 'high' },
      },
    };

    await admin.messaging().send(message);
    this.logger.log(`FCM sent to ${token.slice(0, 20)}...: ${title}`);
  }
}
