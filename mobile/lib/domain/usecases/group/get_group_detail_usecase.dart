import 'package:dartz/dartz.dart';
import 'package:taskflow/core/errors/failure.dart';
import 'package:taskflow/data/models/group.dart';
import 'package:taskflow/data/repositories/group_repository.dart';

class GetGroupDetailUseCase {
  final GroupRepository repository;

  GetGroupDetailUseCase(this.repository);

  Future<Either<Failure, Group>> call(String groupId) async {
    return await repository.getGroup(groupId);
  }
}
