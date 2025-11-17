import 'package:dartz/dartz.dart';
import 'package:mobile/core/errors/failure.dart';
import 'package:mobile/data/repositories/group_repository.dart';

class DeleteGroupUseCase {
  final GroupRepository repository;

  DeleteGroupUseCase(this.repository);

  Future<Either<Failure, void>> call(String groupId) async {
    return await repository.deleteGroup(groupId);
  }
}
