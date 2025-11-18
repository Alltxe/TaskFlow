import 'package:dartz/dartz.dart';
import 'package:mobile/core/errors/failure.dart';
import 'package:mobile/data/models/group.dart';
import 'package:mobile/data/repositories/group_repository.dart';

class GetGroupsUseCase {
  final GroupRepository repository;

  GetGroupsUseCase(this.repository);

  Future<Either<Failure, List<Group>>> call() async {
    return await repository.getUserGroups();
  }
}
