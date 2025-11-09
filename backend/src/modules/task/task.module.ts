import { Module } from '@nestjs/common';
import { ScheduleModule } from '@nestjs/schedule';
import { TaskService } from './task.service';
import { TaskResolver } from './task.resolver';
import { AuthModule } from '../auth/auth.module';
import { RotationService } from './rotation.service';
import { DeadlineService } from './deadline.service';
import { AuditLogModule } from '../audit-log/audit-log.module';

@Module({
  imports: [AuthModule, ScheduleModule.forRoot(), AuditLogModule],
  providers: [TaskService, TaskResolver, RotationService, DeadlineService],
  exports: [TaskService, DeadlineService],
})
export class TaskModule {}
