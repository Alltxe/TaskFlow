import { Resolver, Query, Mutation, Args } from '@nestjs/graphql';
import { UseGuards } from '@nestjs/common';
import { NotificationPreferenceService } from './notification-preference.service';
import { NotificationPreferenceType } from './types/notification-preference.type';
import { DeviceTokenType } from './types/device-token.type';
import { UpsertNotificationPreferenceInput } from './dto/notification-preference.input';
import { RegisterDeviceTokenInput, RemoveDeviceTokenInput } from './dto/device-token.input';
import { JwtAuthGuard } from '../auth/auth.guard';
import { CurrentUser } from '../auth/decorators/current-user.decorator';
import type { User } from '@prisma/client';

@Resolver()
export class NotificationPreferenceResolver {
  constructor(private readonly service: NotificationPreferenceService) {}

  @Query(() => NotificationPreferenceType, { description: 'Get my notification preferences' })
  @UseGuards(JwtAuthGuard)
  async myNotificationPreference(@CurrentUser() user: User) {
    return this.service.getPreference(user.id);
  }

  @Mutation(() => NotificationPreferenceType, { description: 'Upsert my notification preferences' })
  @UseGuards(JwtAuthGuard)
  async upsertNotificationPreference(
    @CurrentUser() user: User,
    @Args('input') input: UpsertNotificationPreferenceInput,
  ) {
    return this.service.upsertPreference(user.id, input);
  }

  @Mutation(() => DeviceTokenType, { description: 'Register a device token for push notifications' })
  @UseGuards(JwtAuthGuard)
  async registerDeviceToken(
    @CurrentUser() user: User,
    @Args('input') input: RegisterDeviceTokenInput,
  ) {
    return this.service.registerDeviceToken(user.id, input.token, input.provider, input.platform);
  }

  @Mutation(() => Boolean, { description: 'Remove a device token' })
  @UseGuards(JwtAuthGuard)
  async removeDeviceToken(
    @CurrentUser() user: User,
    @Args('input') input: RemoveDeviceTokenInput,
  ) {
    return this.service.removeDeviceToken(user.id, input.token);
  }

  @Query(() => [DeviceTokenType], { description: 'List my registered device tokens' })
  @UseGuards(JwtAuthGuard)
  async myDeviceTokens(@CurrentUser() user: User) {
    return this.service.listDeviceTokens(user.id);
  }
}
