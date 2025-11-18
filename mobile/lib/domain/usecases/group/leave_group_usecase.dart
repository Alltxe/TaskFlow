import 'package:dartz/dartz.dart';
import 'package:mobile/core/errors/failure.dart';
import 'package:mobile/data/repositories/group_repository.dart';

class LeaveGroupUseCase {
  final GroupRepository repository;

  LeaveGroupUseCase(this.repository);

  Future<Either<Failure, void>> call(String groupId) async {
    return await repository.leaveGroup(groupId);
  }
}
