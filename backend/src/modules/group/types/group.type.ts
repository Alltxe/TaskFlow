import { ObjectType, Field, ID, Int } from '@nestjs/graphql';

@ObjectType()
export class GroupPreviewType {
  @Field(() => ID)
  id: string;

  @Field(() => String)
  name: string;

  @Field(() => String, { nullable: true })
  description?: string | null;

  @Field(() => Int)
  memberCount: number;

  @Field(() => Boolean)
  requiresApproval: boolean;
}

@ObjectType()
export class GroupMemberUserType {
  @Field(() => ID)
  id: string;

  @Field(() => String)
  username: string;

  @Field(() => String, { nullable: true })
  avatarUrl?: string | null;

  @Field(() => Boolean)
  isAway: boolean;

  @Field(() => Date, { nullable: true })
  awayUntil?: Date | null;
}

@ObjectType()
export class GroupType {
  @Field(() => ID)
  id: string;

  @Field(() => String)
  name: string;

  @Field(() => String, { nullable: true })
  description?: string | null;

  @Field(() => String, { nullable: true })
  inviteToken?: string | null;

  @Field(() => Boolean)
  requiresApproval: boolean;

  @Field(() => String)
  rotationType: string;

  @Field(() => Boolean)
  gamificationEnabled: boolean;

  @Field(() => Date)
  createdAt: Date;

  @Field(() => Date)
  updatedAt: Date;

  @Field(() => String)
  createdById: string;
}

@ObjectType()
export class GroupMemberType {
  @Field(() => ID)
  id: string;

  @Field(() => String)
  userId: string;

  @Field(() => String)
  groupId: string;

  @Field(() => String)
  role: string;

  @Field(() => Date)
  joinedAt: Date;

  @Field(() => Date)
  roleChangedAt: Date;

  @Field(() => GroupMemberUserType)
  user: GroupMemberUserType;
}
