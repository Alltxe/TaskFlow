import { ObjectType, Field, ID } from '@nestjs/graphql';

@ObjectType()
export class DeviceTokenType {
  @Field(() => ID)
  id: string;

  @Field()
  token: string;

  @Field({ nullable: true })
  provider?: string;

  @Field({ nullable: true })
  platform?: string;

  @Field()
  createdAt: Date;

  @Field()
  updatedAt: Date;
}
