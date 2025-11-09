import { Injectable, Logger, OnModuleInit } from '@nestjs/common';
import * as admin from 'firebase-admin';

export interface PushNotificationPayload {
  token: string;
  title: string;
  body: string;
  data?: Record<string, string>;
}

export interface PushNotificationResult {
  success: boolean;
  messageId?: string;
  error?: string;
}

@Injectable()
export class FirebaseService implements OnModuleInit {
  private readonly logger = new Logger(FirebaseService.name);
  private app: admin.app.App | null = null;

  onModuleInit() {
    this.initializeFirebase();
  }

  private initializeFirebase() {
    try {
      // Check if Firebase is already initialized
      if (admin.apps.length > 0) {
        this.app = admin.app();
        this.logger.log('Firebase Admin SDK already initialized');
        return;
      }

      const projectId = process.env.FIREBASE_PROJECT_ID;
      const privateKey = process.env.FIREBASE_PRIVATE_KEY?.replace(/\\n/g, '\n');
      const clientEmail = process.env.FIREBASE_CLIENT_EMAIL;

      if (!projectId || !privateKey || !clientEmail) {
        this.logger.warn(
          'Firebase credentials not configured. Push notifications will be disabled. ' +
          'Please set FIREBASE_PROJECT_ID, FIREBASE_PRIVATE_KEY, and FIREBASE_CLIENT_EMAIL environment variables.',
        );
        return;
      }

      this.app = admin.initializeApp({
        credential: admin.credential.cert({
          projectId,
          privateKey,
          clientEmail,
        }),
      });

      this.logger.log('Firebase Admin SDK initialized successfully');
    } catch (error) {
      this.logger.error('Failed to initialize Firebase Admin SDK', error);
      this.app = null;
    }
  }

  /**
   * Send a push notification via FCM
   * @param payload - Notification payload with token, title, body, and optional data
   * @param retries - Number of retry attempts (default: 2)
   * @returns Promise<PushNotificationResult>
   */
  async sendPushNotification(
    payload: PushNotificationPayload,
    retries = 2,
  ): Promise<PushNotificationResult> {
    if (!this.app) {
      this.logger.warn('Firebase not initialized. Skipping push notification.');
      return { success: false, error: 'Firebase not initialized' };
    }

    const { token, title, body, data } = payload;

    const message: admin.messaging.Message = {
      token,
      notification: {
        title,
        body,
      },
      data: data || {},
      android: {
        priority: 'high',
        notification: {
          sound: 'default',
          priority: 'high',
        },
      },
      apns: {
        payload: {
          aps: {
            sound: 'default',
            badge: 1,
          },
        },
      },
    };

    for (let attempt = 0; attempt <= retries; attempt++) {
      try {
        const messageId = await admin.messaging().send(message);
        this.logger.log(`Push notification sent successfully: ${messageId}`);
        return { success: true, messageId };
      } catch (error: any) {
        const isLastAttempt = attempt === retries;

        // Handle specific FCM errors
        if (
          error.code === 'messaging/invalid-registration-token' ||
          error.code === 'messaging/registration-token-not-registered'
        ) {
          this.logger.warn(`Invalid or unregistered FCM token: ${token}`);
          return { success: false, error: 'Invalid FCM token' };
        }

        this.logger.error(
          `Push notification failed (attempt ${attempt + 1}/${retries + 1}): ${error.message}`,
          error.stack,
        );

        if (isLastAttempt) {
          return { success: false, error: error.message };
        }

        // Exponential backoff: 1s, 2s, 4s...
        const delayMs = Math.pow(2, attempt) * 1000;
        await new Promise((resolve) => setTimeout(resolve, delayMs));
      }
    }

    return { success: false, error: 'Max retries exceeded' };
  }

  /**
   * Send push notifications to multiple tokens (batch)
   * @param tokens - Array of FCM device tokens
   * @param title - Notification title
   * @param body - Notification body
   * @param data - Optional data payload
   * @returns Promise<PushNotificationResult[]>
   */
  async sendBatchPushNotifications(
    tokens: string[],
    title: string,
    body: string,
    data?: Record<string, string>,
  ): Promise<PushNotificationResult[]> {
    const results = await Promise.all(
      tokens.map((token) =>
        this.sendPushNotification({ token, title, body, data }),
      ),
    );

    const successCount = results.filter((r) => r.success).length;
    this.logger.log(
      `Batch push notification completed: ${successCount}/${tokens.length} successful`,
    );

    return results;
  }

  /**
   * Check if Firebase is properly initialized
   */
  isInitialized(): boolean {
    return this.app !== null;
  }
}
