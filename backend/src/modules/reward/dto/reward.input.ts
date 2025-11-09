import { Field, ID, InputType, Int } from '@nestjs/graphql';
import { IsBoolean, IsNotEmpty, IsOptional, IsString, IsUrl, IsUUID, Min } from 'class-validator';

@InputType()
export class CreateRewardInput {
  @Field(() => ID)
  @IsString()
  @IsNotEmpty()
  groupId: string;

  @Field()
  @IsString()
  @IsNotEmpty()
  name: string;

  @Field(() => Int)
  @Min(1)
  cost: number;

  @Field({ nullable: true })
  @IsOptional()
  @IsString()
  description?: string;

  @Field({ nullable: true })
  @IsOptional()
  @IsUrl()
  imageUrl?: string;

  @Field({ nullable: true })
  @IsOptional()
  @IsBoolean()
  isActive?: boolean;
}

@InputType()
export class UpdateRewardInput {
  @Field(() => ID)
  @IsString()
  @IsNotEmpty()
  rewardId: string;

  @Field(() => ID)
  @IsString()
  @IsNotEmpty()
  groupId: string;

  @Field({ nullable: true })
  @IsOptional()
  @IsString()
  name?: string;

  @Field(() => Int, { nullable: true })
  @IsOptional()
  @Min(1)
  cost?: number;

  @Field({ nullable: true })
  @IsOptional()
  @IsString()
  description?: string;

  @Field({ nullable: true })
  @IsOptional()
  @IsUrl()
  imageUrl?: string;

  @Field({ nullable: true })
  @IsOptional()
  @IsBoolean()
  isActive?: boolean;
}

@InputType()
export class RequestRewardInput {
  @Field(() => ID)
  @IsString()
  @IsNotEmpty()
  rewardId: string;
}

@InputType()
export class ApproveRewardRequestInput {
  @Field(() => ID)
  @IsString()
  @IsNotEmpty()
  requestId: string;

  @Field()
  @IsBoolean()
  approved: boolean;

  @Field({ nullable: true })
  @IsOptional()
  @IsString()
  reason?: string;
}
