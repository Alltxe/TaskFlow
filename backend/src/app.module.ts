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
import { HealthModule } from './modules/health/health.module';
import { StorageModule } from './modules/storage/storage.module';
import { WellKnownModule } from './modules/well-known/well-known.module';
import { CacheModule } from '@nestjs/cache-manager';
import { TerminusModule } from '@nestjs/terminus';
import { getCacheConfig } from './common/config/cache.config';
import { WinstonModule } from 'nest-winston';
import { loggerConfig } from './common/config/logger.config';

@Module({
  imports: [
    // Logging (Winston) - PRD 4.3 Monitoring
    WinstonModule.forRoot(loggerConfig),
    // Caching - Redis in production, memory in dev (PRD 4.1 Performance)
    CacheModule.registerAsync({
      isGlobal: true,
      useFactory: getCacheConfig,
    }),
    // Health checks
    TerminusModule,
    HealthModule,
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
    StorageModule,
    WellKnownModule,
  ],
  providers: [
    AppService,
  ],
})
export class AppModule {}
