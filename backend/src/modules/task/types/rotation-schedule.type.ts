import { ObjectType, Field, ID, Int } from '@nestjs/graphql';

/**
 * Rotation Schedule Entry - represents a planned task assignment through rotation
 * Implements BACKEND_API_REQUIREMENTS.md - getRotationSchedule query (Critical - Phase 5.1)
 */
@ObjectType()
export class RotationScheduleEntry {
  @Field(() => ID, { description: 'Task ID (for recurring tasks - template ID)' })
  taskId: string;

  @Field(() => String, { description: 'Task title' })
  taskTitle: string;

  @Field(() => ID, { description: 'User ID who will be assigned the task' })
  userId: string;

  @Field(() => String, { description: 'Username of assignee' })
  username: string;

  @Field(() => String, { nullable: true, description: 'Avatar URL of assignee' })
  avatarUrl?: string | null;

  @Field(() => Date, { description: 'Scheduled assignment date and time' })
  scheduledDate: Date;

  @Field(() => String, { description: 'Rotation type for this task' })
  rotationType: string;

  @Field(() => String, { description: 'Task priority level' })
  priority: string;

  @Field(() => Int, { description: 'Base points for task completion' })
  points: number;
}
