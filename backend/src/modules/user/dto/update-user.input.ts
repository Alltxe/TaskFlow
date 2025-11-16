import { InputType, Field } from '@nestjs/graphql';
import { IsString, IsOptional, Length, Matches, IsUrl } from 'class-validator';

/**
 * Input DTO for updating user profile
 * Implements BACKEND_API_REQUIREMENTS.md - updateUser mutation (Critical - Phase 8.1)
 * PRD 3.1.2 - User Profile Management
 */
@InputType()
export class UpdateUserInput {
  @Field({ nullable: true, description: 'New username (3-30 characters, alphanumeric and underscore only)' })
  @IsOptional()
  @IsString()
  @Length(3, 30, { message: 'Username must be between 3 and 30 characters' })
  @Matches(/^[a-zA-Z0-9_]+$/, {
    message: 'Username can only contain letters, numbers, and underscores',
  })
  username?: string;

  @Field({ nullable: true, description: 'URL of user avatar image' })
  @IsOptional()
  @IsString()
  @IsUrl({}, { message: 'Avatar URL must be a valid URL' })
  avatarUrl?: string;
}
