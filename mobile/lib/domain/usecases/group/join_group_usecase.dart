import 'package:dartz/dartz.dart';
import 'package:mobile/core/errors/failure.dart';
import 'package:mobile/data/models/group.dart';
import 'package:mobile/data/models/join_group_request.dart';
import 'package:mobile/data/repositories/group_repository.dart';

class JoinGroupUseCase {
  final GroupRepository repository;

  JoinGroupUseCase(this.repository);

  Future<Either<Failure, Group>> call(JoinGroupRequest request) async {
    return await repository.joinGroup(request);
  }
}
