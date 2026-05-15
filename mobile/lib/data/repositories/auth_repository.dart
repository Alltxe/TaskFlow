import 'package:taskflow/data/models/auth_response.dart';
import 'package:taskflow/data/models/auth_tokens.dart';
import 'package:taskflow/data/models/login_request.dart';
import 'package:taskflow/data/models/register_request.dart';
import 'package:taskflow/data/models/user.dart';

/// Repository interface for authentication operations
abstract class AuthRepository {
  /// Login with email and password
  Future<AuthResponse> login(LoginRequest request);

  /// Register new user
  Future<AuthResponse> register(RegisterRequest request);

  /// Logout current user
  Future<void> logout();

  /// Refresh access token
  Future<AuthTokens> refreshToken();

  /// Get current user from cache
  Future<User?> getCurrentUser();

  /// Check if user is authenticated
  Future<bool> isAuthenticated();

  /// Check if access token needs refresh
  Future<bool> needsTokenRefresh();

  /// Verify email with 6-digit code
  Future<void> verifyEmail(String code);

  /// Resend email verification code
  Future<void> resendVerificationCode();

  /// Request password reset — sends a 6-digit code to the given email.
  Future<void> requestPasswordReset(String email);

  /// Reset password using the code sent to email.
  Future<void> resetPassword({
    required String email,
    required String code,
    required String newPassword,
  });
}
