import { InputType, Field } from '@nestjs/graphql';
import { IsOptional, IsBoolean, IsArray, ArrayNotEmpty, IsString, IsInt, Min } from 'class-validator';
import { NotificationType as NotificationTypeEnum } from '@prisma/client';

@InputType()
export class ListNotificationsInput {
  @Field({ nullable: true })
  @IsOptional()
  @IsBoolean()
  isRead?: boolean;

  @Field(() => NotificationTypeEnum, { nullable: true })
  @IsOptional()
  type?: NotificationTypeEnum;

  @Field({ nullable: true })
  @IsOptional()
  @IsInt()
  @Min(0)
  offset?: number;

  @Field({ nullable: true })
  @IsOptional()
  @IsInt()
  @Min(1)
  limit?: number;
}

@InputType()
export class MarkNotificationsReadInput {
  @Field(() => [String])
  @IsArray()
  @ArrayNotEmpty()
  @IsString({ each: true })
  ids: string[];
}
