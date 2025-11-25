import 'package:dartz/dartz.dart';
import 'package:taskflow/core/errors/failure.dart';
import 'package:taskflow/data/models/user.dart';
import 'package:taskflow/data/repositories/profile_repository.dart';

/// Use case for updating user profile
class UpdateProfileUseCase {
  final ProfileRepository repository;

  UpdateProfileUseCase(this.repository);

  Future<Either<Failure, User>> call({
    String? username,
    String? avatarUrl,
    bool? isAway,
    DateTime? awayUntil,
  }) async {
    return await repository.updateProfile(
      username: username,
      avatarUrl: avatarUrl,
      isAway: isAway,
      awayUntil: awayUntil,
    );
  }
}
