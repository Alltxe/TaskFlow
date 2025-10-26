import { InputType, Field } from '@nestjs/graphql';
import { IsEmail, IsNotEmpty, MinLength } from 'class-validator';

@InputType()
export class RegisterInput {
  @Field()
  @IsEmail({}, { message: 'incorrect email' })
  email: string;

  @Field()
  @IsNotEmpty({ message: 'Username is required' })
  username: string;

  @Field()
  @IsNotEmpty({ message: 'Password is required' })
  @MinLength(6, { message: 'Password must be at least 6 characters long' })
  password: string;
}

@InputType()
export class LoginInput {
  @Field()
  @IsEmail({}, { message: 'incorrect email' })
  email: string;

  @Field()
  @IsNotEmpty({ message: 'Password is required' })
  password: string;
}

@InputType()
export class ChangePasswordInput {
  @Field()
  @IsNotEmpty({ message: 'Current password is required' })
  oldPassword: string;

  @Field()
  @IsNotEmpty({ message: 'New password is required' })
  @MinLength(6, { message: 'Password must be at least 6 characters long' })
  newPassword: string;
}

@InputType()
export class RefreshTokenInput {
  @Field()
  @IsNotEmpty({ message: 'Refresh token is required' })
  refreshToken: string;
}
