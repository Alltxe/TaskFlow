import 'package:dartz/dartz.dart';
import 'package:taskflow/core/errors/failure.dart';
import 'package:taskflow/data/models/group.dart';
import 'package:taskflow/data/models/join_group_request.dart';
import 'package:taskflow/data/repositories/group_repository.dart';

class JoinGroupUseCase {
  final GroupRepository repository;

  JoinGroupUseCase(this.repository);

  Future<Either<Failure, Group>> call(JoinGroupRequest request) async {
    return await repository.joinGroup(request);
  }
}
