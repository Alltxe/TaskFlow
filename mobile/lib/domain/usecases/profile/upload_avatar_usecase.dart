import 'package:dartz/dartz.dart';
import 'package:taskflow/core/errors/failure.dart';
import 'package:taskflow/data/repositories/profile_repository.dart';

/// Use case for uploading user avatar
class UploadAvatarUseCase {
  final ProfileRepository repository;

  UploadAvatarUseCase(this.repository);

  Future<Either<Failure, String>> call(String filePath) async {
    return await repository.uploadAvatar(filePath);
  }
}
