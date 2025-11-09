import { Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { Prisma } from '@prisma/client';
import type { NotificationPreference, DeviceToken } from '@prisma/client';

@Injectable()
export class NotificationPreferenceService {
  constructor(private prisma: PrismaService) {}

  async getPreference(userId: string): Promise<NotificationPreference | null> {
    return this.prisma.notificationPreference.findUnique({
      where: { userId },
    });
  }

  async upsertPreference(userId: string, data: Partial<NotificationPreference>): Promise<NotificationPreference> {
    const updateData: any = {};
    if (data.enablePush !== undefined) updateData.enablePush = data.enablePush;
    if (data.quietHoursStart !== undefined) updateData.quietHoursStart = data.quietHoursStart;
    if (data.quietHoursEnd !== undefined) updateData.quietHoursEnd = data.quietHoursEnd;
    if (data.mutedTypes !== undefined) updateData.mutedTypes = data.mutedTypes;
    if (data.batchingEnabled !== undefined) updateData.batchingEnabled = data.batchingEnabled;

    return this.prisma.notificationPreference.upsert({
      where: { userId },
      update: updateData,
      create: { 
        userId,
        enablePush: data.enablePush ?? true,
        quietHoursStart: data.quietHoursStart ?? null,
        quietHoursEnd: data.quietHoursEnd ?? null,
        mutedTypes: (data.mutedTypes ?? Prisma.DbNull) as Prisma.InputJsonValue,
        batchingEnabled: data.batchingEnabled ?? false,
      },
    });
  }

  async registerDeviceToken(userId: string, token: string, provider?: string, platform?: string): Promise<DeviceToken> {
    return this.prisma.deviceToken.upsert({
      where: { token },
      update: { userId, provider, platform },
      create: { token, userId, provider, platform },
    });
  }

  async removeDeviceToken(userId: string, token: string): Promise<boolean> {
    const found = await this.prisma.deviceToken.findUnique({ where: { token } });
    if (!found || found.userId !== userId) throw new NotFoundException('Token not found');
    await this.prisma.deviceToken.delete({ where: { token } });
    return true;
  }

  async listDeviceTokens(userId: string): Promise<DeviceToken[]> {
    return this.prisma.deviceToken.findMany({ where: { userId } });
  }
}
