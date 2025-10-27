import { InputType, Field, Int } from '@nestjs/graphql';
import { IsNotEmpty, IsString, IsInt, Min, IsOptional, IsBoolean, IsEnum, IsDateString } from 'class-validator';

enum TaskPriority {
  LOW = 'LOW',
  MEDIUM = 'MEDIUM',
  HIGH = 'HIGH',
  CRITICAL = 'CRITICAL',
}

enum RotationType {
  ROUND_ROBIN = 'ROUND_ROBIN',
  RANDOM = 'RANDOM',
  WEIGHTED_RANDOM = 'WEIGHTED_RANDOM',
  DISABLED = 'DISABLED',
}

@InputType()
export class CreateTaskInput {
  @Field(() => String)
  @IsNotEmpty()
  @IsString()
  title: string;

  @Field(() => String, { nullable: true })
  @IsOptional()
  @IsString()
  description?: string;

  @Field(() => String)
  @IsNotEmpty()
  @IsDateString()
  deadline: string;

  @Field(() => String)
  @IsNotEmpty()
  @IsEnum(TaskPriority)
  priority: TaskPriority;

  @Field(() => Int)
  @IsNotEmpty()
  @IsInt()
  @Min(1)
  points: number;

  @Field(() => Boolean, { nullable: true, defaultValue: true })
  @IsOptional()
  @IsBoolean()
  requiresApproval?: boolean;

  @Field(() => Boolean, { nullable: true, defaultValue: false })
  @IsOptional()
  @IsBoolean()
  isRecurring?: boolean;

  @Field(() => String, { nullable: true })
  @IsOptional()
  @IsString()
  recurrenceRule?: string;

  @Field(() => String, { nullable: true })
  @IsOptional()
  @IsEnum(RotationType)
  rotationType?: RotationType;

  @Field(() => Int, { nullable: true, defaultValue: 1 })
  @IsOptional()
  @IsInt()
  @Min(1)
  weight?: number;

  @Field(() => String)
  @IsNotEmpty()
  @IsString()
  groupId: string;

  @Field(() => String, { nullable: true })
  @IsOptional()
  @IsString()
  assigneeId?: string;
}

@InputType()
export class UpdateTaskInput {
  @Field(() => String, { nullable: true })
  @IsOptional()
  @IsString()
  title?: string;

  @Field(() => String, { nullable: true })
  @IsOptional()
  @IsString()
  description?: string;

  @Field(() => String, { nullable: true })
  @IsOptional()
  @IsDateString()
  deadline?: string;

  @Field(() => String, { nullable: true })
  @IsOptional()
  @IsEnum(TaskPriority)
  priority?: TaskPriority;

  @Field(() => Int, { nullable: true })
  @IsOptional()
  @IsInt()
  @Min(1)
  points?: number;

  @Field(() => Boolean, { nullable: true })
  @IsOptional()
  @IsBoolean()
  requiresApproval?: boolean;

  @Field(() => String, { nullable: true })
  @IsOptional()
  @IsString()
  assigneeId?: string;
}

@InputType()
export class CompleteTaskInput {
  @Field(() => String)
  @IsNotEmpty()
  @IsString()
  taskId: string;
}

@InputType()
export class ApproveTaskInput {
  @Field(() => String)
  @IsNotEmpty()
  @IsString()
  taskId: string;

  @Field(() => Boolean)
  @IsNotEmpty()
  @IsBoolean()
  approved: boolean;
}
