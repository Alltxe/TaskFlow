import { ObjectType, Field, ID, Int } from '@nestjs/graphql';

/**
 * Rotation History Entry - represents a past task assignment through rotation
 * Implements BACKEND_API_REQUIREMENTS.md - getRotationHistory query (Critical - Phase 5.1)
 */
@ObjectType()
export class RotationHistoryEntry {
  @Field(() => ID, { description: 'Task ID' })
  taskId: string;

  @Field(() => String, { description: 'Task title' })
  taskTitle: string;

  @Field(() => ID, { description: 'User ID who was assigned the task' })
  userId: string;

  @Field(() => String, { description: 'Username of assignee' })
  username: string;

  @Field(() => String, { nullable: true, description: 'Avatar URL of assignee' })
  avatarUrl?: string | null;

  @Field(() => Date, { description: 'Date and time when task was assigned' })
  assignedAt: Date;

  @Field(() => Date, { nullable: true, description: 'Date and time when task was completed (null if not completed)' })
  completedAt?: Date | null;

  @Field(() => String, { description: 'Current task status' })
  status: string;

  @Field(() => String, { description: 'Rotation type used for assignment' })
  rotationType: string;

  @Field(() => Int, { description: 'Points earned for completion (0 if not completed)' })
  pointsEarned: number;
}

/**
 * Paginated result for rotation history
 */
@ObjectType()
export class RotationHistoryResult {
  @Field(() => [RotationHistoryEntry], { description: 'List of rotation history entries' })
  items: RotationHistoryEntry[];

  @Field(() => Int, { description: 'Total number of entries' })
  total: number;
}
