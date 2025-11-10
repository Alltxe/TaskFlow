import 'package:freezed_annotation/freezed_annotation.dart';

part 'failure.freezed.dart';

/// Base class for all failures in the app
/// Uses freezed for immutability and pattern matching
@freezed
class Failure with _$Failure {
  const factory Failure.network({required String message, String? code}) = NetworkFailure;

  const factory Failure.server({required String message, String? code}) = ServerFailure;

  const factory Failure.auth({required String message, String? code}) = AuthFailure;

  const factory Failure.validation({required String message, String? code}) = ValidationFailure;

  const factory Failure.cache({required String message, String? code}) = CacheFailure;

  const factory Failure.permission({required String message, String? code}) = PermissionFailure;

  const factory Failure.notFound({required String message, String? code}) = NotFoundFailure;

  const factory Failure.timeout({required String message, String? code}) = TimeoutFailure;

  const factory Failure.unknown({required String message, String? code}) = UnknownFailure;
}
