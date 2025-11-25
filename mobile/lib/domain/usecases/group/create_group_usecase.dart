import 'package:dartz/dartz.dart';
import 'package:taskflow/core/errors/failure.dart';
import 'package:taskflow/data/models/create_group_request.dart';
import 'package:taskflow/data/models/group.dart';
import 'package:taskflow/data/repositories/group_repository.dart';

class CreateGroupUseCase {
  final GroupRepository repository;

  CreateGroupUseCase(this.repository);

  Future<Either<Failure, Group>> call(CreateGroupRequest request) async {
    return await repository.createGroup(request);
  }
}
