import { InputType, Field } from '@nestjs/graphql';
import { IsString, IsOptional } from 'class-validator';

@InputType()
export class RegisterDeviceTokenInput {
  @Field()
  @IsString()
  token: string;

  @Field({ nullable: true })
  @IsString()
  @IsOptional()
  provider?: string;

  @Field({ nullable: true })
  @IsString()
  @IsOptional()
  platform?: string;
}

@InputType()
export class RemoveDeviceTokenInput {
  @Field()
  @IsString()
  token: string;
}
