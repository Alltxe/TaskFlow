import { Field, ID, Int, ObjectType } from '@nestjs/graphql';
import { UserType } from '../../auth/types/user.type';

@ObjectType()
export class RewardType {
  @Field(() => ID)
  id: string;

  @Field()
  name: string;

  @Field({ nullable: true })
  description?: string;

  @Field(() => Int)
  cost: number;

  @Field()
  isActive: boolean;

  @Field({ nullable: true })
  imageUrl?: string;

  @Field()
  createdAt: Date;

  @Field(() => ID)
  groupId: string;

  @Field(() => ID)
  createdById: string;
}

@ObjectType()
export class RewardTransactionType {
  @Field(() => ID)
  id: string;

  @Field(() => Int)
  pointsSpent: number;

  @Field()
  status: string;

  @Field()
  requestedAt: Date;

  @Field({ nullable: true })
  approvedAt?: Date;

  @Field({ nullable: true })
  rejectedAt?: Date;

  @Field({ nullable: true })
  rejectionReason?: string;

  @Field(() => ID)
  userId: string;

  @Field(() => ID)
  rewardId: string;

  @Field(() => ID, { nullable: true })
  approvedById?: string;

  @Field(() => UserType, { nullable: true })
  user?: UserType;

  @Field(() => RewardType, { nullable: true })
  reward?: RewardType;
}

@ObjectType()
export class PointBalanceType {
  @Field(() => Int)
  totalEarned: number;

  @Field(() => Int)
  totalSpentApproved: number;

  @Field(() => Int)
  totalReservedPending: number;

  @Field(() => Int)
  currentBalance: number;

  @Field(() => Int)
  availableBalance: number;
}

@ObjectType()
export class LeaderboardEntryType {
  @Field(() => UserType)
  user: UserType;

  @Field(() => Int)
  pointsEarned: number;

  @Field(() => Int)
  rank: number;
}
