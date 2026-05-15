import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:taskflow/core/errors/exceptions.dart';
import 'package:taskflow/core/events/app_events.dart';
import 'package:taskflow/data/datasources/auth_local_datasource.dart';
import 'package:taskflow/data/datasources/auth_remote_datasource.dart';
import 'package:taskflow/data/models/login_request.dart';
import 'package:taskflow/data/models/register_request.dart';
import 'package:taskflow/data/models/user.dart';
import 'package:taskflow/data/repositories/auth_repository.dart';
import 'package:taskflow/data/repositories/auth_repository_impl.dart';

/// Provider for secure storage
final secureStorageProvider = Provider<FlutterSecureStorage>((ref) {
  return const FlutterSecureStorage();
});

/// Auth state enum
enum AuthStatus { authenticated, unauthenticated, loading, pendingVerification }

/// Auth state class
class AuthState {
  final AuthStatus status;
  final User? user;
  final String? error;

  const AuthState({required this.status, this.user, this.error});

  const AuthState.authenticated(User user)
    : status = AuthStatus.authenticated,
      user = user,
      error = null;

  const AuthState.unauthenticated([String? error])
    : status = AuthStatus.unauthenticated,
      user = null,
      error = error;

  const AuthState.loading() : status = AuthStatus.loading, user = null, error = null;

  const AuthState.pendingVerification(User user)
    : status = AuthStatus.pendingVerification,
      user = user,
      error = null;
}

/// Provider for AuthRemoteDataSource
final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  return AuthRemoteDataSource();
});

/// Provider for AuthLocalDataSource
final authLocalDataSourceProvider = Provider<AuthLocalDataSource>((ref) {
  final storage = ref.watch(secureStorageProvider);
  return AuthLocalDataSource(storage);
});

/// Provider for AuthRepository
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final remoteDataSource = ref.watch(authRemoteDataSourceProvider);
  final localDataSource = ref.watch(authLocalDataSourceProvider);

  return AuthRepositoryImpl(remoteDataSource: remoteDataSource, localDataSource: localDataSource);
});

/// StateNotifier for auth state management
class AuthStateNotifier extends StateNotifier<AuthState> {
  final AuthRepository _authRepository;
  StreamSubscription? _logoutSubscription;

  AuthStateNotifier(this._authRepository) : super(const AuthState.loading()) {
    _init();
    _listenToLogoutEvents();
  }

  /// Initialize auth state
  Future<void> _init() async {
    try {
      final isAuth = await _authRepository.isAuthenticated();
      if (isAuth) {
        final user = await _authRepository.getCurrentUser();
        if (user != null) {
          state = AuthState.authenticated(user);
        } else {
          state = const AuthState.unauthenticated();
        }
      } else {
        state = const AuthState.unauthenticated();
      }
    } catch (e) {
      state = AuthState.unauthenticated(e.toString());
    }
  }

  /// Listen to logout events from RefreshTokenLink
  void _listenToLogoutEvents() {
    _logoutSubscription = logoutEventController.stream.listen((_) {
      state = const AuthState.unauthenticated('Session expired');
    });
  }

  /// Login by email or username
  Future<void> login(String identifier, String password) async {
    state = const AuthState.loading();
    try {
      final response = await _authRepository.login(
        LoginRequest(email: identifier, password: password),
      );
      state = AuthState.authenticated(response.user);
    } catch (e) {
      state = AuthState.unauthenticated(e is AppException ? e.message : e.toString());
    }
  }

  /// Reset to unauthenticated state
  void resetToUnauthenticated([String? error]) {
    state = AuthState.unauthenticated(error);
  }

  /// Register — stays in pendingVerification until email is confirmed
  Future<void> register(String email, String username, String password) async {
    state = const AuthState.loading();
    try {
      final response = await _authRepository.register(
        RegisterRequest(email: email, username: username, password: password),
      );
      // Stay on register screen showing the code input
      state = AuthState.pendingVerification(response.user);
    } catch (e) {
      state = AuthState.unauthenticated(e is AppException ? e.message : e.toString());
    }
  }

  /// Verify email with 6-digit code
  Future<void> verifyEmailCode(String code) async {
    final currentUser = state.user;
    if (currentUser == null) return;

    state = const AuthState.loading();
    try {
      await _authRepository.verifyEmail(code);
      state = AuthState.authenticated(currentUser);
    } catch (e) {
      // Return to pendingVerification with error — user can retry
      state = AuthState.pendingVerification(currentUser);
      // Re-throw so the UI can show the error
      rethrow;
    }
  }

  /// Resend verification code
  Future<void> resendVerificationCode() async {
    await _authRepository.resendVerificationCode();
  }

  /// Logout
  Future<void> logout() async {
    await _authRepository.logout();
    state = const AuthState.unauthenticated();
  }

  /// Update user data in auth state (e.g., after profile update)
  void updateUser(User user) {
    if (state.status == AuthStatus.authenticated) {
      state = AuthState.authenticated(user);
    }
  }

  /// Check if authenticated
  Future<bool> checkAuth() async {
    final isAuth = await _authRepository.isAuthenticated();
    if (!isAuth) {
      state = const AuthState.unauthenticated();
    }
    return isAuth;
  }

  @override
  void dispose() {
    _logoutSubscription?.cancel();
    super.dispose();
  }
}

/// Provider for AuthStateNotifier
final authStateProvider = StateNotifierProvider<AuthStateNotifier, AuthState>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  return AuthStateNotifier(authRepository);
});
