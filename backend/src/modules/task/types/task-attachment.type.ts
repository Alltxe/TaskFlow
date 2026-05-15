import { ObjectType, Field, ID, Int } from '@nestjs/graphql';

@ObjectType()
export class TaskAttachmentType {
  @Field(() => ID)
  id: string;

  @Field()
  url: string;

  @Field()
  filename: string;

  @Field(() => Int)
  fileSize: number;

  @Field()
  mimeType: string;

  @Field(() => Date)
  uploadedAt: Date;

  @Field()
  taskId: string;

  @Field()
  groupId: string;

  @Field()
  uploadedById: string;
}
