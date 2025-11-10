import { InputType, Field } from '@nestjs/graphql';
import { IsBoolean, IsOptional, IsString, IsArray } from 'class-validator';

@InputType()
export class UpsertNotificationPreferenceInput {
  @Field({ nullable: true })
  @IsBoolean()
  @IsOptional()
  enablePush?: boolean;

  @Field({ nullable: true })
  @IsString()
  @IsOptional()
  quietHoursStart?: string;

  @Field({ nullable: true })
  @IsString()
  @IsOptional()
  quietHoursEnd?: string;

  @Field(() => [String], { nullable: true })
  @IsArray()
  @IsOptional()
  mutedTypes?: string[];

  @Field({ nullable: true })
  @IsBoolean()
  @IsOptional()
  batchingEnabled?: boolean;
}
