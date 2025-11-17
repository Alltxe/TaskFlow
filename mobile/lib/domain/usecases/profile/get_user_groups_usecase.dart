import 'package:dartz/dartz.dart';
import 'package:mobile/core/errors/failure.dart';
import 'package:mobile/data/models/group_summary.dart';
import 'package:mobile/data/repositories/profile_repository.dart';

/// Use case for getting user's groups
class GetUserGroupsUseCase {
  final ProfileRepository repository;

  GetUserGroupsUseCase(this.repository);

  Future<Either<Failure, List<GroupSummary>>> call() async {
    return await repository.getUserGroups();
  }
}
