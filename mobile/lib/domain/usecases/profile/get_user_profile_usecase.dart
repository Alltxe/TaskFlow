import 'package:dartz/dartz.dart';
import 'package:mobile/core/errors/failure.dart';
import 'package:mobile/data/models/user.dart';
import 'package:mobile/data/repositories/profile_repository.dart';

/// Use case for getting current user profile
class GetUserProfileUseCase {
  final ProfileRepository repository;

  GetUserProfileUseCase(this.repository);

  Future<Either<Failure, User>> call() async {
    return await repository.getCurrentUserProfile();
  }
}
