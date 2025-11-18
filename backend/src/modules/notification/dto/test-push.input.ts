import { InputType, Field } from '@nestjs/graphql';
import { IsNotEmpty, IsOptional } from 'class-validator';
import { GraphQLJSON } from 'graphql-type-json';

@InputType()
export class TestPushInput {
  @Field()
  @IsNotEmpty()
  title: string;

  @Field()
  @IsNotEmpty()
  body: string;

  @Field(() => GraphQLJSON, { nullable: true })
  @IsOptional()
  data?: Record<string, string>;
}
