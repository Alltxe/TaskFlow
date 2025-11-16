import { Module } from '@nestjs/common';
import { ScheduleModule } from '@nestjs/schedule';
import { TaskService } from './task.service';
import { TaskResolver } from './task.resolver';
import { AuthModule } from '../auth/auth.module';
import { RotationService } from './rotation.service';
import { DeadlineService } from './deadline.service';
import { RecurringTaskService } from './recurring-task.service';
import { AuditLogModule } from '../audit-log/audit-log.module';
import { NotificationModule } from '../notification/notification.module';

// Conditionally include scheduling in non-test environments to avoid lingering timers in Jest
const scheduleImport = process.env.JEST_WORKER_ID ? [] : [ScheduleModule.forRoot()];

@Module({
  imports: [AuthModule, ...scheduleImport, AuditLogModule, NotificationModule],
  providers: [TaskService, TaskResolver, RotationService, DeadlineService, RecurringTaskService],
  exports: [TaskService, DeadlineService, RecurringTaskService],
})
export class TaskModule {}
