import { ObjectType, Field, ID, Int } from '@nestjs/graphql';
import { GroupMemberUserType } from '../../group/types/group.type';

/**
 * Rotation Pattern - configuration and state of group rotation
 * Implements BACKEND_API_REQUIREMENTS.md - getRotationPattern query (Important - Phase 5.1)
 */
@ObjectType()
export class RotationPatternType {
  @Field(() => String, { description: 'Rotation type of the group' })
  rotationType: string;

  @Field(() => [String], { description: 'Array of user IDs in rotation order (CYCLIC only)' })
  currentCycle: string[];

  @Field(() => Int, { nullable: true, description: 'Current index in cycle (CYCLIC only, 0-based)' })
  currentCycleIndex?: number | null;

  @Field(() => Date, { nullable: true, description: 'Date of last rotation assignment' })
  lastRotationAt?: Date | null;

  @Field(() => Date, { nullable: true, description: 'Date of next planned rotation assignment' })
  nextRotationAt?: Date | null;

  @Field(() => [GroupMemberUserType], { description: 'Active members (not away)' })
  activeMembers: GroupMemberUserType[];

  @Field(() => [GroupMemberUserType], { description: 'Members currently away' })
  awayMembers: GroupMemberUserType[];
}

