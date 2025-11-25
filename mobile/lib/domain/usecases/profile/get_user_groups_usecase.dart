import 'package:dartz/dartz.dart';
import 'package:taskflow/core/errors/failure.dart';
import 'package:taskflow/data/models/group_summary.dart';
import 'package:taskflow/data/repositories/profile_repository.dart';

/// Use case for getting user's groups
class GetUserGroupsUseCase {
  final ProfileRepository repository;

  GetUserGroupsUseCase(this.repository);

  Future<Either<Failure, List<GroupSummary>>> call() async {
    return await repository.getUserGroups();
  }
}
