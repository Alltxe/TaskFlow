import 'package:dartz/dartz.dart';
import 'package:mobile/core/errors/failure.dart';
import 'package:mobile/data/repositories/group_repository.dart';

class RemoveMemberUseCase {
  final GroupRepository repository;

  RemoveMemberUseCase(this.repository);

  Future<Either<Failure, void>> call(String groupId, String userId) async {
    return await repository.removeMember(groupId, userId);
  }
}
