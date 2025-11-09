import { Module } from '@nestjs/common';
import { AppService } from './app.service';
import { GraphQlModule } from './modules/graph-ql/graph-ql.module';
import { UserModule } from './modules/user/user.module';
import { AuthModule } from './modules/auth/auth.module';
import { PrismaModule } from './modules/prisma/prisma.module';
import { GroupModule } from './modules/group/group.module';
import { TaskModule } from './modules/task/task.module';
import { RewardModule } from './modules/reward/reward.module';
import { NotificationModule } from './modules/notification/notification.module';
import { AuditLogModule } from './modules/audit-log/audit-log.module';
import { NotificationPreferenceModule } from './modules/notification-preference/notification-preference.module';
import { FirebaseModule } from './modules/firebase/firebase.module';

@Module({
  imports: [
    PrismaModule,
    FirebaseModule,
    GraphQlModule,
    UserModule,
    AuthModule,
    GroupModule,
    TaskModule,
    RewardModule,
    NotificationModule,
    AuditLogModule,
    NotificationPreferenceModule,
  ],
  providers: [AppService],
})
export class AppModule {}
