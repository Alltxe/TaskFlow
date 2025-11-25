import 'package:dartz/dartz.dart';
import 'package:taskflow/core/errors/failure.dart';
import 'package:taskflow/data/models/group.dart';
import 'package:taskflow/data/models/update_group_request.dart';
import 'package:taskflow/data/repositories/group_repository.dart';

class UpdateGroupUseCase {
  final GroupRepository repository;

  UpdateGroupUseCase(this.repository);

  Future<Either<Failure, Group>> call(
    String groupId,
    UpdateGroupRequest request,
  ) async {
    return await repository.updateGroup(groupId, request);
  }
}
