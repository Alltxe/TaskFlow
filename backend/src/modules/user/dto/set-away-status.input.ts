import { InputType, Field } from '@nestjs/graphql';
import { IsBoolean, IsOptional, IsDateString } from 'class-validator';

/**
 * Input DTO for setting user "Away" status
 * Implements BACKEND_API_REQUIREMENTS.md - setUserAwayStatus mutation (Critical - Phase 5.3)
 * PRD 3.1.2 - User Profile Management
 * PRD 3.4.1 - Rotation Algorithm (Away status affects rotation)
 */
@InputType()
export class SetAwayStatusInput {
  @Field({ description: 'Flag indicating if user is away' })
  @IsBoolean({ message: 'isAway must be a boolean value' })
  isAway!: boolean;

  @Field({ nullable: true, description: 'Date when user will return (null for indefinite)' })
  @IsOptional()
  @IsDateString({}, { message: 'awayUntil must be a valid ISO 8601 date string' })
  awayUntil?: string;
}
