import 'package:dartz/dartz.dart';
import 'package:mobile/core/errors/failure.dart';
import 'package:mobile/data/models/group_member.dart';
import 'package:mobile/data/repositories/group_repository.dart';

class UpdateMemberRoleUseCase {
  final GroupRepository repository;

  UpdateMemberRoleUseCase(this.repository);

  Future<Either<Failure, GroupMember>> call(
    String groupId,
    String userId,
    String role,
  ) async {
    return await repository.updateMemberRole(groupId, userId, role);
  }
}
