import { Resolver, Query, Mutation, Args } from '@nestjs/graphql';
import { UseGuards, ForbiddenException } from '@nestjs/common';
import { JwtAuthGuard } from '../auth/auth.guard';
import { NotificationService } from './notification.service';
import { NotificationListResult } from './types/notification.type';
import { ListNotificationsInput, MarkNotificationsReadInput } from './dto/notification.input';
import { TestPushInput } from './dto/test-push.input';
import { PushNotificationResultType } from './types/push.type';
import { CurrentUser } from '../auth/decorators/current-user.decorator';
import { User } from '@prisma/client';

@Resolver()
export class NotificationResolver {
  constructor(private notificationService: NotificationService) {}

  @Query(() => NotificationListResult, { description: 'List my notifications (PRD 3.6.3)' })
  @UseGuards(JwtAuthGuard)
  async myNotifications(
    @CurrentUser() user: User,
    @Args('input', { nullable: true }) input?: ListNotificationsInput,
  ) {
    return this.notificationService.list(user.id, input);
  }

  @Mutation(() => Boolean, { description: 'Mark notifications as read (PRD 3.6.3)' })
  @UseGuards(JwtAuthGuard)
  async markNotificationsRead(
    @CurrentUser() user: User,
    @Args('input') input: MarkNotificationsReadInput,
  ) {
    await this.notificationService.markRead(user.id, input.ids);
    return true;
  }

  @Mutation(() => Boolean, { description: 'Mark all my notifications as read (PRD 3.6.3)' })
  @UseGuards(JwtAuthGuard)
  async markAllNotificationsRead(@CurrentUser() user: User) {
    await this.notificationService.markAllRead(user.id);
    return true;
  }

  @Mutation(() => [PushNotificationResultType], { description: 'Отправить тестовое push-уведомление на все мои устройства (Phase 8)' })
  @UseGuards(JwtAuthGuard)
  async sendTestPush(
    @CurrentUser() user: User,
    @Args('input') input: TestPushInput,
  ) {
    if (process.env.NODE_ENV === 'production') {
      throw new ForbiddenException('sendTestPush отключён в продакшене');
    }
    return this.notificationService.testPushToUser(user.id, input.title, input.body, input.data);
  }
}
