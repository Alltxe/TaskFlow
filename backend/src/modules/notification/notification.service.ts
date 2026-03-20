import { Injectable, Logger, Inject, forwardRef } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { NotificationType as NotificationTypeEnum } from '@prisma/client';
import { NotificationPreferenceService } from '../notification-preference/notification-preference.service';
import { FirebaseService } from '../firebase/firebase.service';

interface NotifyPayload {
  userId: string;
  title: string;
  message: string;
  type: NotificationTypeEnum;
  relatedEntityType?: string | null;
  relatedEntityId?: string | null;
  sentById?: string | null;
}

@Injectable()
export class NotificationService {
  private readonly logger = new Logger(NotificationService.name);

  constructor(
    private prisma: PrismaService,
    @Inject(forwardRef(() => NotificationPreferenceService))
    private preferenceService: NotificationPreferenceService,
    private firebaseService: FirebaseService,
  ) {}

  async notify(payload: NotifyPayload) {
    // Check user notification preferences
    const prefs = await this.preferenceService.getPreference(payload.userId);
    if (prefs) {
      // Muted types
      if (prefs.mutedTypes && Array.isArray(prefs.mutedTypes)) {
        if (prefs.mutedTypes.includes(payload.type)) {
          this.logger.debug(`Notification type ${payload.type} muted for user=${payload.userId}`);
          return null;
        }
      }
      // Quiet hours
      if (prefs.quietHoursStart && prefs.quietHoursEnd) {
        const now = new Date();
        const start = parseTime(prefs.quietHoursStart);
        const end = parseTime(prefs.quietHoursEnd);
        if (isWithinQuietHours(now, start, end)) {
          this.logger.debug(`Notification suppressed due to quiet hours for user=${payload.userId}`);
          return null;
        }
      }
      // Push flag (for future push integration)
      if (!prefs.enablePush) {
        this.logger.debug(`Push notifications disabled for user=${payload.userId}`);
        // For now, still create in-app notification
      }
    }
    const notification = await this.prisma.notification.create({
      data: {
        userId: payload.userId,
        title: payload.title,
        message: payload.message,
        type: payload.type as any,
        relatedEntityType: payload.relatedEntityType || null,
        relatedEntityId: payload.relatedEntityId || null,
        sentById: payload.sentById || null,
      },
    });

    this.logger.debug(
      `Notification created (${notification.type}) for user=${notification.userId}: ${notification.title}`,
    );

      // Send push notification by default unless explicitly disabled in preferences
      if ((prefs?.enablePush ?? true) && this.firebaseService.isInitialized()) {
        await this.sendPushNotificationToUser(payload.userId, payload.title, payload.message, {
          type: payload.type,
          entityType: payload.relatedEntityType || '',
          entityId: payload.relatedEntityId || '',
        });
      }

    return notification;
  }

  /**
   * Send a test push notification to all current user's devices.
   * Does not create an in-app notification. Respects enablePush flag and
   * cleans up invalid tokens. Intended for GraphQL test mutation.
   */
  async testPushToUser(
    userId: string,
    title: string,
    message: string,
    data?: Record<string, string>,
  ) {
    // If Firebase isn't initialized, short-circuit with an explicit result
    if (!this.firebaseService.isInitialized()) {
      return [] as { success: boolean; messageId?: string; error?: string }[];
    }

    const prefs = await this.preferenceService.getPreference(userId);
    if (prefs && prefs.enablePush === false) {
      this.logger.debug(`Test push skipped: enablePush=false for user=${userId}`);
      return [] as { success: boolean; messageId?: string; error?: string }[];
    }

    // Reuse internal batching logic and cleanup by calling the same helper
    try {
  const deviceTokens = await this.prisma.deviceToken.findMany({
        where: { userId },
        select: { token: true },
      });

      if (deviceTokens.length === 0) {
        this.logger.debug(`Test push: no device tokens for user=${userId}`);
        return [] as { success: boolean; messageId?: string; error?: string }[];
      }

      const tokens = deviceTokens.map((d) => d.token);
      const results = await this.firebaseService.sendBatchPushNotifications(
        tokens,
        title,
        message,
        data,
      );

      // Cleanup invalid tokens same as notify path
      const invalidTokens = results
        .filter((r) => !r.success && r.error === 'Invalid FCM token')
        .map((_, idx) => tokens[idx]);
      if (invalidTokens.length > 0) {
  await this.prisma.deviceToken.deleteMany({ where: { token: { in: invalidTokens } } });
      }

      return results;
    } catch (error) {
      this.logger.error(`Test push failed for user=${userId}`, error);
      return [] as { success: boolean; messageId?: string; error?: string }[];
    }
  }

    /**
     * Send push notification to all registered devices of a user
     * @private
     */
    private async sendPushNotificationToUser(
      userId: string,
      title: string,
      body: string,
      data?: Record<string, string>,
    ) {
      try {
        // Get all device tokens for the user
  const deviceTokens = await this.prisma.deviceToken.findMany({
          where: { userId },
          select: { token: true },
        });

        if (deviceTokens.length === 0) {
          this.logger.debug(`No device tokens found for user=${userId}`);
          return;
        }

        const tokens = deviceTokens.map((dt) => dt.token);
        this.logger.debug(`Sending push notification to ${tokens.length} device(s) for user=${userId}`);

        const results = await this.firebaseService.sendBatchPushNotifications(
          tokens,
          title,
          body,
          data,
        );

        // Clean up invalid tokens
        const invalidTokens = results
          .filter((r) => !r.success && r.error === 'Invalid FCM token')
          .map((r, idx) => tokens[idx]);

        if (invalidTokens.length > 0) {
          this.logger.warn(`Removing ${invalidTokens.length} invalid FCM tokens`);
          await this.prisma.deviceToken.deleteMany({
            where: { token: { in: invalidTokens } },
          });
        }
      } catch (error) {
        this.logger.error(`Failed to send push notification to user=${userId}`, error);
        // Don't throw - push notification failure shouldn't break the flow
      }
    }

  async notifyGroupAdmins(
    groupId: string,
    build: (adminUserId: string) => Omit<NotifyPayload, 'userId'>,
  ) {
    const admins = await this.prisma.groupMember.findMany({
      where: { groupId, role: 'ADMIN' },
      select: { userId: true },
    });
    const results = [] as any[];
    for (const a of admins) {
      const data = build(a.userId);
      results.push(
        await this.notify({
          ...data,
          userId: a.userId,
        }),
      );
    }
    return results;
  }

  async list(userId: string, filters?: {
    isRead?: boolean;
    type?: NotificationTypeEnum;
    offset?: number;
    limit?: number;
  }) {
    const where: any = { userId };
    if (filters?.isRead !== undefined) where.isRead = filters.isRead;
    if (filters?.type) where.type = filters.type;

    const [items, total] = await Promise.all([
      this.prisma.notification.findMany({
        where,
        orderBy: { createdAt: 'desc' },
        skip: filters?.offset || 0,
        take: filters?.limit || 50,
      }),
      this.prisma.notification.count({ where }),
    ]);

    return { items, total };
  }

  async markRead(userId: string, ids: string[]) {
    const res = await this.prisma.notification.updateMany({
      where: { id: { in: ids }, userId },
      data: { isRead: true },
    });
    return res.count;
  }

  async markAllRead(userId: string) {
    const res = await this.prisma.notification.updateMany({
      where: { userId, isRead: false },
      data: { isRead: true },
    });
    return res.count;
  }
}

// Helper: parse "HH:mm" string to Date
function parseTime(str: string): Date {
  const [h, m] = str.split(':').map(Number);
  const d = new Date();
  d.setHours(h, m, 0, 0);
  return d;
}

// Helper: check if now is within quiet hours
function isWithinQuietHours(now: Date, start: Date, end: Date): boolean {
  const nowMinutes = now.getHours() * 60 + now.getMinutes();
  const startMinutes = start.getHours() * 60 + start.getMinutes();
  const endMinutes = end.getHours() * 60 + end.getMinutes();
  if (startMinutes < endMinutes) {
    return nowMinutes >= startMinutes && nowMinutes < endMinutes;
  } else {
    // Quiet hours cross midnight
    return nowMinutes >= startMinutes || nowMinutes < endMinutes;
  }
}