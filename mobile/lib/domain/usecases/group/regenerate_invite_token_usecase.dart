import 'package:dartz/dartz.dart';
import 'package:mobile/core/errors/failure.dart';
import 'package:mobile/data/models/group.dart';
import 'package:mobile/data/repositories/group_repository.dart';

class RegenerateInviteTokenUseCase {
  final GroupRepository repository;

  RegenerateInviteTokenUseCase(this.repository);

  Future<Either<Failure, Group>> call(String groupId) async {
    return await repository.regenerateInviteToken(groupId);
  }
}
