import 'package:dartz/dartz.dart';
import 'package:mobile/core/errors/failure.dart';
import 'package:mobile/data/models/group_member.dart';
import 'package:mobile/data/repositories/group_repository.dart';

class GetGroupMembersUseCase {
  final GroupRepository repository;

  GetGroupMembersUseCase(this.repository);

  Future<Either<Failure, List<GroupMember>>> call(String groupId) async {
    return await repository.getGroupMembers(groupId);
  }
}
