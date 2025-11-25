import 'package:dartz/dartz.dart';
import 'package:taskflow/core/errors/failure.dart';
import 'package:taskflow/data/models/group.dart';
import 'package:taskflow/data/repositories/group_repository.dart';

class GetGroupsUseCase {
  final GroupRepository repository;

  GetGroupsUseCase(this.repository);

  Future<Either<Failure, List<Group>>> call() async {
    return await repository.getUserGroups();
  }
}
