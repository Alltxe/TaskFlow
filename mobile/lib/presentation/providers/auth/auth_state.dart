import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:taskflow/data/models/user.dart';

part 'auth_state.freezed.dart';

@freezed
class AuthState with _$AuthState {
  /// Initial state - checking authentication
  const factory AuthState.initial() = AuthStateInitial;

  /// Authenticated state
  const factory AuthState.authenticated(User user) = AuthStateAuthenticated;

  /// Unauthenticated state
  const factory AuthState.unauthenticated() = AuthStateUnauthenticated;

  /// Loading state (during login/register)
  const factory AuthState.loading() = AuthStateLoading;

  /// Error state
  const factory AuthState.error(String message) = AuthStateError;
}
