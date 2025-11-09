import { Module } from '@nestjs/common';
import { TaskService } from './task.service';
import { TaskResolver } from './task.resolver';
import { AuthModule } from '../auth/auth.module';
import { RotationService } from './rotation.service';

@Module({
  imports: [AuthModule],
  providers: [TaskService, TaskResolver, RotationService],
  exports: [TaskService],
})
export class TaskModule {}
