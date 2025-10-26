import { InputType, Field } from '@nestjs/graphql';
import { IsNotEmpty, IsOptional, IsBoolean, IsEnum } from 'class-validator';

export enum RotationType {
  ROUND_ROBIN = 'ROUND_ROBIN',
  RANDOM = 'RANDOM',
  WEIGHTED_RANDOM = 'WEIGHTED_RANDOM',
  DISABLED = 'DISABLED',
}

export enum MemberRole {
  ADMIN = 'ADMIN',
  MEMBER = 'MEMBER',
}

@InputType()
export class CreateGroupInput {
  @Field(() => String)
  @IsNotEmpty({ message: 'Название группы обязательно' })
  name: string;

  @Field(() => String, { nullable: true })
  @IsOptional()
  description?: string;

  @Field(() => Boolean, { nullable: true })
  @IsOptional()
  @IsBoolean()
  requiresApproval?: boolean;

  @Field(() => String, { nullable: true })
  @IsOptional()
  rotationType?: string;

  @Field(() => Boolean, { nullable: true })
  @IsOptional()
  @IsBoolean()
  gamificationEnabled?: boolean;
}

@InputType()
export class UpdateGroupInput {
  @Field(() => String, { nullable: true })
  @IsOptional()
  name?: string;

  @Field(() => String, { nullable: true })
  @IsOptional()
  description?: string;

  @Field(() => Boolean, { nullable: true })
  @IsOptional()
  @IsBoolean()
  requiresApproval?: boolean;

  @Field(() => String, { nullable: true })
  @IsOptional()
  @IsEnum(RotationType)
  rotationType?: RotationType;

  @Field(() => Boolean, { nullable: true })
  @IsOptional()
  @IsBoolean()
  gamificationEnabled?: boolean;
}

@InputType()
export class JoinGroupInput {
  @Field(() => String)
  @IsNotEmpty({ message: 'Токен приглашения обязателен' })
  inviteToken: string;
}

@InputType()
export class UpdateMemberRoleInput {
  @Field(() => String)
  @IsNotEmpty({ message: 'ID пользователя обязателен' })
  userId: string;

  @Field(() => String)
  @IsNotEmpty()
  @IsEnum(MemberRole)
  role: MemberRole;
}
