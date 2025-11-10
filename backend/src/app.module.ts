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
import { ThrottlerModule } from '@nestjs/throttler';
import { CacheModule } from '@nestjs/cache-manager';
import { TerminusModule } from '@nestjs/terminus';
import { APP_GUARD } from '@nestjs/core';
import { throttlerConfig } from './common/config/throttler.config';
import { getCacheConfig } from './common/config/cache.config';
import { WinstonModule } from 'nest-winston';
import { loggerConfig } from './common/config/logger.config';
import { GraphqlThrottlerGuard } from './common/guards/graphql-throttler.guard';

@Module({
  imports: [
    // Logging (Winston) - PRD 4.3 Monitoring
    WinstonModule.forRoot(loggerConfig),
    // Rate Limiting (PRD 4.3)
    ThrottlerModule.forRoot(throttlerConfig),
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
  ],
  providers: [
    AppService,
    // Apply rate limiting globally with custom GraphQL-compatible guard
    {
      provide: APP_GUARD,
      useClass: GraphqlThrottlerGuard,
    },
  ],
})
export class AppModule {}
