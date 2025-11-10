import { ObjectType, Field } from '@nestjs/graphql';

@ObjectType({ description: 'Result of a push notification send attempt (Phase 8)'} )
export class PushNotificationResultType {
  @Field()
  success: boolean;

  @Field({ nullable: true })
  messageId?: string;

  @Field({ nullable: true })
  error?: string;
}
