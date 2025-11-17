import 'package:dartz/dartz.dart';
import 'package:mobile/core/errors/failure.dart';
import 'package:mobile/data/models/group.dart';
import 'package:mobile/data/models/group_member.dart';
import 'package:mobile/data/models/create_group_request.dart';
import 'package:mobile/data/models/update_group_request.dart';
import 'package:mobile/data/models/join_group_request.dart';

abstract class GroupRepository {
  Future<Either<Failure, List<Group>>> getUserGroups();
  Future<Either<Failure, Group>> getGroup(String groupId);
  Future<Either<Failure, List<GroupMember>>> getGroupMembers(String groupId);
  Future<Either<Failure, Group>> createGroup(CreateGroupRequest request);
  Future<Either<Failure, Group>> updateGroup(
    String groupId,
    UpdateGroupRequest request,
  );
  Future<Either<Failure, void>> deleteGroup(String groupId);
  Future<Either<Failure, Group>> joinGroup(JoinGroupRequest request);
  Future<Either<Failure, void>> leaveGroup(String groupId);
  Future<Either<Failure, void>> removeMember(String groupId, String userId);
  Future<Either<Failure, GroupMember>> updateMemberRole(
    String groupId,
    String userId,
    String role,
  );
  Future<Either<Failure, Group>> regenerateInviteToken(String groupId);
}
