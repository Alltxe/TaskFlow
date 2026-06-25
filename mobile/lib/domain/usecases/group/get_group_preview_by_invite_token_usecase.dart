import 'package:dartz/dartz.dart';
import 'package:taskflow/core/errors/failure.dart';
import 'package:taskflow/data/models/group_preview.dart';
import 'package:taskflow/data/repositories/group_repository.dart';

class GetGroupPreviewByInviteTokenUseCase {
  final GroupRepository repository;

  GetGroupPreviewByInviteTokenUseCase(this.repository);

  Future<Either<Failure, GroupPreview>> call(String inviteToken) {
    return repository.getGroupPreviewByInviteToken(inviteToken);
  }
}
