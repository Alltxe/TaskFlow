import { ObjectType, Field, ID, Int } from '@nestjs/graphql';
import { GraphQLJSON } from 'graphql-type-json';

@ObjectType()
export class AuditLogUserType {
  @Field(() => ID)
  id: string;

  @Field(() => String)
  username: string;

  @Field(() => String)
  email: string;
}

@ObjectType()
export class AuditLogType {
  @Field(() => ID)
  id: string;

  @Field(() => String)
  action: string;

  @Field(() => String)
  entityType: string;

  @Field(() => String, { nullable: true })
  entityId?: string | null;

  @Field(() => GraphQLJSON, { nullable: true })
  oldValues?: any;

  @Field(() => GraphQLJSON, { nullable: true })
  newValues?: any;

  @Field(() => Date)
  performedAt: Date;

  @Field(() => String, { nullable: true })
  ipAddress?: string | null;

  @Field(() => String, { nullable: true })
  userId?: string | null;

  @Field(() => AuditLogUserType, { nullable: true })
  user?: AuditLogUserType | null;

  @Field(() => AuditLogUserType, { nullable: true })
  performedBy?: AuditLogUserType | null; // Alias for user
}

@ObjectType()
export class AuditLogListType {
  @Field(() => [AuditLogType])
  logs: AuditLogType[];

  @Field(() => Int)
  total: number;

  @Field(() => Int)
  limit: number;

  @Field(() => Int)
  offset: number;
}
