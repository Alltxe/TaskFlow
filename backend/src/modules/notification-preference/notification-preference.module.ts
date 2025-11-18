import { Module, forwardRef } from '@nestjs/common';
import { NotificationPreferenceService } from './notification-preference.service';
import { NotificationPreferenceResolver } from './notification-preference.resolver';
import { PrismaModule } from '../prisma/prisma.module';

@Module({
  imports: [PrismaModule],
  providers: [NotificationPreferenceService, NotificationPreferenceResolver],
  exports: [NotificationPreferenceService],
})
export class NotificationPreferenceModule {}
