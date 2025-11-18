import { ObjectType, Field, ID, registerEnumType, GraphQLISODateTime } from '@nestjs/graphql';
import { NotificationType as NotificationTypeEnum } from '@prisma/client';

registerEnumType(NotificationTypeEnum, { name: 'NotificationTypeEnum' });

@ObjectType()
export class NotificationType {
  @Field(() => ID)
  id: string;

  @Field()
  title: string;

  @Field()
  message: string;

  @Field(() => NotificationTypeEnum)
  type: NotificationTypeEnum;

  @Field()
  isRead: boolean;

  @Field(() => String, { nullable: true })
  relatedEntityType?: string | null;

  @Field(() => String, { nullable: true })
  relatedEntityId?: string | null;

  @Field(() => GraphQLISODateTime)
  createdAt: Date;
}

@ObjectType()
export class NotificationListResult {
  @Field(() => [NotificationType])
  items: NotificationType[];

  @Field()
  total: number;
}
