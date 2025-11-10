import { ObjectType, Field, ID, Int } from '@nestjs/graphql';
import { GroupMemberUserType } from '../../group/types/group.type';

@ObjectType()
export class TaskType {
  @Field(() => ID)
  id: string;

  @Field(() => String)
  title: string;

  @Field(() => String, { nullable: true })
  description?: string | null;

  @Field(() => Date)
  deadline: Date;

  @Field(() => String)
  priority: string;

  @Field(() => String)
  status: string;

  @Field(() => Int)
  points: number;

  @Field(() => Boolean)
  requiresApproval: boolean;

  @Field(() => Boolean)
  isRecurring: boolean;

  @Field(() => String, { nullable: true })
  recurrenceRule?: string | null;

  @Field(() => String, { nullable: true })
  rotationType?: string | null;

  @Field(() => Int)
  weight: number;

  @Field(() => Boolean)
  wasClaimedFromPool: boolean;

  @Field(() => String, { nullable: true })
  rejectionReason?: string | null;

  @Field(() => Date)
  createdAt: Date;

  @Field(() => Date, { nullable: true })
  completedAt?: Date | null;

  @Field(() => String)
  groupId: string;

  @Field(() => String)
  createdById: string;

  @Field(() => String, { nullable: true })
  assigneeId?: string | null;

  @Field(() => String, { nullable: true })
  approvedById?: string | null;

  @Field(() => String, { nullable: true })
  parentTaskId?: string | null;

  @Field(() => GroupMemberUserType, { nullable: true })
  assignee?: GroupMemberUserType | null;

  @Field(() => GroupMemberUserType)
  createdBy: GroupMemberUserType;
}
