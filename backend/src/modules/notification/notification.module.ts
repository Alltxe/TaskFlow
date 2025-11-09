import { Module, forwardRef } from '@nestjs/common';
import { NotificationService } from './notification.service';
import { NotificationResolver } from './notification.resolver';
import { AuthModule } from '../auth/auth.module';
import { PrismaModule } from '../prisma/prisma.module';
import { NotificationPreferenceModule } from '../notification-preference/notification-preference.module';

@Module({
  imports: [PrismaModule, AuthModule, forwardRef(() => NotificationPreferenceModule)],
  providers: [NotificationService, NotificationResolver],
  exports: [NotificationService],
})
export class NotificationModule {}
