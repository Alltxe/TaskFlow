import { ObjectType, Field, ID } from '@nestjs/graphql';

@ObjectType()
export class NotificationPreferenceType {
  @Field(() => ID)
  id: string;

  @Field()
  enablePush: boolean;

  @Field({ nullable: true })
  quietHoursStart?: string;

  @Field({ nullable: true })
  quietHoursEnd?: string;

  @Field(() => [String], { nullable: true })
  mutedTypes?: string[];

  @Field()
  batchingEnabled: boolean;

  @Field()
  createdAt: Date;

  @Field()
  updatedAt: Date;
}
