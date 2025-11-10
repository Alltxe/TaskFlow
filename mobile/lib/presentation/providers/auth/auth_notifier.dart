import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/core/errors/exceptions.dart';
import 'package:mobile/data/models/login_request.dart';
import 'package:mobile/data/models/register_request.dart';
import 'package:mobile/data/models/user.dart';
import 'package:mobile/domain/usecases/auth/auth_usecase_providers.dart';
import 'package:mobile/presentation/providers/auth/auth_state.dart';

/// StateNotifier for authentication
class AuthNotifier extends StateNotifier<AuthState> {
  final Ref ref;

  AuthNotifier(this.ref) : super(const AuthState.initial()) {
    checkAuthStatus();
  }

  /// Check current authentication status
  Future<void> checkAuthStatus() async {
    try {
      final checkAuthStatus = ref.read(checkAuthStatusUseCaseProvider);
      final isAuthenticated = await checkAuthStatus();

      if (isAuthenticated) {
        final getCurrentUser = ref.read(getCurrentUserUseCaseProvider);
        final user = await getCurrentUser();

        if (user != null) {
          state = AuthState.authenticated(user);
        } else {
          state = const AuthState.unauthenticated();
        }
      } else {
        state = const AuthState.unauthenticated();
      }
    } catch (e) {
      state = const AuthState.unauthenticated();
    }
  }

  /// Login with email and password
  Future<void> login(String email, String password) async {
    state = const AuthState.loading();

    try {
      final loginUseCase = ref.read(loginUseCaseProvider);
      final request = LoginRequest(email: email, password: password);
      final response = await loginUseCase(request);

      state = AuthState.authenticated(response.user);
    } on AuthException catch (e) {
      state = AuthState.error(e.message);
    } on ValidationException catch (e) {
      state = AuthState.error(e.message);
    } on NetworkException catch (e) {
      state = AuthState.error(e.message);
    } on ServerException catch (e) {
      state = AuthState.error(e.message);
    } catch (e) {
      state = AuthState.error(e.toString());
    }
  }

  /// Register new user
  Future<void> register(String email, String username, String password) async {
    state = const AuthState.loading();

    try {
      final registerUseCase = ref.read(registerUseCaseProvider);
      final request = RegisterRequest(email: email, username: username, password: password);
      final response = await registerUseCase(request);

      state = AuthState.authenticated(response.user);
    } on AuthException catch (e) {
      state = AuthState.error(e.message);
    } on ValidationException catch (e) {
      state = AuthState.error(e.message);
    } on NetworkException catch (e) {
      state = AuthState.error(e.message);
    } on ServerException catch (e) {
      state = AuthState.error(e.message);
    } catch (e) {
      state = AuthState.error(e.toString());
    }
  }

  /// Logout current user
  Future<void> logout() async {
    try {
      final logoutUseCase = ref.read(logoutUseCaseProvider);
      await logoutUseCase();
      state = const AuthState.unauthenticated();
    } catch (e) {
      state = AuthState.error(e.toString());
    }
  }

  /// Refresh access token
  Future<void> refreshToken() async {
    try {
      final refreshTokenUseCase = ref.read(refreshTokenUseCaseProvider);
      await refreshTokenUseCase();
      // Token refreshed successfully, keep current state
    } on AuthException catch (e) {
      // Refresh token expired or invalid, logout user
      state = AuthState.error(e.message);
      await logout();
    } catch (e) {
      state = AuthState.error(e.toString());
    }
  }

  /// Clear error state
  void clearError() {
    if (state is AuthStateError) {
      state = const AuthState.unauthenticated();
    }
  }
}

/// Provider for AuthNotifier
final authNotifierProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref);
});

/// Provider for current user (convenience provider)
final currentUserProvider = Provider<User?>((ref) {
  final authState = ref.watch(authNotifierProvider);
  return authState.maybeWhen(authenticated: (user) => user, orElse: () => null);
});

/// Provider for authentication status (convenience provider)
final isAuthenticatedProvider = Provider<bool>((ref) {
  final authState = ref.watch(authNotifierProvider);
  return authState.maybeWhen(authenticated: (_) => true, orElse: () => false);
});
