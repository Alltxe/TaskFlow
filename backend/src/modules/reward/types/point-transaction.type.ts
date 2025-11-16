import { ObjectType, Field, ID, Int, registerEnumType } from '@nestjs/graphql';

export enum PointTransactionTypeEnum {
  EARNED = 'EARNED',
  SPENT = 'SPENT',
  RESERVED = 'RESERVED',
  REFUNDED = 'REFUNDED',
}

registerEnumType(PointTransactionTypeEnum, {
  name: 'PointTransactionTypeEnum',
  description: 'Тип транзакции поинтов',
});

@ObjectType()
export class PointTransactionType {
  @Field(() => ID)
  id: string;

  @Field(() => PointTransactionTypeEnum)
  type: PointTransactionTypeEnum;

  @Field(() => Int)
  amount: number;

  @Field(() => String)
  description: string;

  @Field(() => ID, { nullable: true })
  relatedTaskId?: string | null;

  @Field(() => String, { nullable: true })
  relatedTaskTitle?: string | null;

  @Field(() => ID, { nullable: true })
  relatedRewardId?: string | null;

  @Field(() => String, { nullable: true })
  relatedRewardName?: string | null;

  @Field(() => Date)
  createdAt: Date;
}

@ObjectType()
export class PointTransactionHistoryResult {
  @Field(() => [PointTransactionType])
  items: PointTransactionType[];

  @Field(() => Int)
  total: number;
}
