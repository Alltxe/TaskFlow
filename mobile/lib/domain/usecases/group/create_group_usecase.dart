import 'package:dartz/dartz.dart';
import 'package:mobile/core/errors/failure.dart';
import 'package:mobile/data/models/create_group_request.dart';
import 'package:mobile/data/models/group.dart';
import 'package:mobile/data/repositories/group_repository.dart';

class CreateGroupUseCase {
  final GroupRepository repository;

  CreateGroupUseCase(this.repository);

  Future<Either<Failure, Group>> call(CreateGroupRequest request) async {
    return await repository.createGroup(request);
  }
}
