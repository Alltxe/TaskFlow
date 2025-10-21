import { ObjectType, Field, ID } from '@nestjs/graphql';

@ObjectType()
export class UserType {
  @Field(() => ID)
  id: string;

  @Field(() => String)
  email: string;

  @Field(() => String)
  username: string;

  @Field(() => String, { nullable: true })
  avatarUrl?: string | null;

  @Field(() => Boolean)
  isAway: boolean;

  @Field(() => Date, { nullable: true })
  awayUntil?: Date | null;

  @Field(() => Date)
  createdAt: Date;

  @Field(() => Date)
  updatedAt: Date;
}
