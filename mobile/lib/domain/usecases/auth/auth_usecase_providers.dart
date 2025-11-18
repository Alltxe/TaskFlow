import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/data/providers/auth_providers.dart';
import 'package:mobile/domain/usecases/auth/check_auth_status_usecase.dart';
import 'package:mobile/domain/usecases/auth/get_current_user_usecase.dart';
import 'package:mobile/domain/usecases/auth/login_usecase.dart';
import 'package:mobile/domain/usecases/auth/logout_usecase.dart';
import 'package:mobile/domain/usecases/auth/refresh_token_usecase.dart';
import 'package:mobile/domain/usecases/auth/register_usecase.dart';

/// Provider for LoginUseCase
final loginUseCaseProvider = Provider<LoginUseCase>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return LoginUseCase(repository);
});

/// Provider for RegisterUseCase
final registerUseCaseProvider = Provider<RegisterUseCase>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return RegisterUseCase(repository);
});

/// Provider for LogoutUseCase
final logoutUseCaseProvider = Provider<LogoutUseCase>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return LogoutUseCase(repository);
});

/// Provider for RefreshTokenUseCase
final refreshTokenUseCaseProvider = Provider<RefreshTokenUseCase>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return RefreshTokenUseCase(repository);
});

/// Provider for GetCurrentUserUseCase
final getCurrentUserUseCaseProvider = Provider<GetCurrentUserUseCase>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return GetCurrentUserUseCase(repository);
});

/// Provider for CheckAuthStatusUseCase
final checkAuthStatusUseCaseProvider = Provider<CheckAuthStatusUseCase>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return CheckAuthStatusUseCase(repository);
});
