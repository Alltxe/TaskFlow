import { InputType, Field } from '@nestjs/graphql';
import { IsNotEmpty, MinLength } from 'class-validator';

@InputType()
export class RegisterInput {
  @Field()
  @IsNotEmpty({ message: 'Email is required' })
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
  /** Логин (username) или email */
  @Field({ description: 'Username или email' })
  @IsNotEmpty({ message: 'Login or email is required' })
  identifier: string;

  @Field()
  @IsNotEmpty({ message: 'Password is required' })
  password: string;
}

@InputType()
export class VerifyEmailInput {
  @Field({ description: '6-значный код из письма' })
  @IsNotEmpty({ message: 'Verification code is required' })
  code: string;
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

@InputType()
export class RequestPasswordResetInput {
  @Field({ description: 'Email пользователя для отправки кода сброса пароля' })
  @IsNotEmpty({ message: 'Email is required' })
  email: string;
}

@InputType()
export class ResetPasswordInput {
  @Field({ description: 'Email пользователя' })
  @IsNotEmpty({ message: 'Email is required' })
  email: string;

  @Field({ description: '6-значный код из письма' })
  @IsNotEmpty({ message: 'Reset code is required' })
  code: string;

  @Field({ description: 'Новый пароль' })
  @IsNotEmpty({ message: 'New password is required' })
  @MinLength(6, { message: 'Password must be at least 6 characters long' })
  newPassword: string;
}
