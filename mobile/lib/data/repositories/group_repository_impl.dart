import 'package:dartz/dartz.dart';
import 'package:taskflow/core/errors/exceptions.dart';
import 'package:taskflow/core/errors/failure.dart';
import 'package:taskflow/data/datasources/group_remote_datasource.dart';
import 'package:taskflow/data/models/create_group_request.dart';
import 'package:taskflow/data/models/group.dart';
import 'package:taskflow/data/models/group_member.dart';
import 'package:taskflow/data/models/group_preview.dart';
import 'package:taskflow/data/models/join_group_request.dart';
import 'package:taskflow/data/models/update_group_request.dart';
import 'package:taskflow/data/repositories/group_repository.dart';

class GroupRepositoryImpl implements GroupRepository {
  final GroupRemoteDataSource remoteDataSource;

  GroupRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<Group>>> getUserGroups() async {
    try {
      final groups = await remoteDataSource.getUserGroups();
      return Right(groups);
    } on NetworkException catch (e) {
      return Left(Failure.network(message: e.message, code: e.code));
    } on ServerException catch (e) {
      return Left(Failure.server(message: e.message, code: e.code));
    } on AuthException catch (e) {
      return Left(Failure.auth(message: e.message, code: e.code));
    } catch (e) {
      return Left(Failure.unknown(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Group>> getGroup(String groupId) async {
    try {
      final group = await remoteDataSource.getGroup(groupId);
      return Right(group);
    } on NetworkException catch (e) {
      return Left(Failure.network(message: e.message, code: e.code));
    } on ServerException catch (e) {
      return Left(Failure.server(message: e.message, code: e.code));
    } on AuthException catch (e) {
      return Left(Failure.auth(message: e.message, code: e.code));
    } catch (e) {
      return Left(Failure.unknown(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<GroupMember>>> getGroupMembers(String groupId) async {
    try {
      final members = await remoteDataSource.getGroupMembers(groupId);
      return Right(members);
    } on NetworkException catch (e) {
      return Left(Failure.network(message: e.message, code: e.code));
    } on ServerException catch (e) {
      return Left(Failure.server(message: e.message, code: e.code));
    } on AuthException catch (e) {
      return Left(Failure.auth(message: e.message, code: e.code));
    } catch (e) {
      return Left(Failure.unknown(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Group>> createGroup(CreateGroupRequest request) async {
    try {
      final group = await remoteDataSource.createGroup(request);
      return Right(group);
    } on NetworkException catch (e) {
      return Left(Failure.network(message: e.message, code: e.code));
    } on ServerException catch (e) {
      return Left(Failure.server(message: e.message, code: e.code));
    } on ValidationException catch (e) {
      return Left(Failure.validation(message: e.message, code: e.code));
    } on AuthException catch (e) {
      return Left(Failure.auth(message: e.message, code: e.code));
    } catch (e) {
      return Left(Failure.unknown(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Group>> updateGroup(String groupId, UpdateGroupRequest request) async {
    try {
      final group = await remoteDataSource.updateGroup(groupId, request);
      return Right(group);
    } on NetworkException catch (e) {
      return Left(Failure.network(message: e.message, code: e.code));
    } on ServerException catch (e) {
      return Left(Failure.server(message: e.message, code: e.code));
    } on ValidationException catch (e) {
      return Left(Failure.validation(message: e.message, code: e.code));
    } on AuthException catch (e) {
      return Left(Failure.auth(message: e.message, code: e.code));
    } catch (e) {
      return Left(Failure.unknown(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteGroup(String groupId) async {
    try {
      await remoteDataSource.deleteGroup(groupId);
      return const Right(null);
    } on NetworkException catch (e) {
      return Left(Failure.network(message: e.message, code: e.code));
    } on ServerException catch (e) {
      return Left(Failure.server(message: e.message, code: e.code));
    } on AuthException catch (e) {
      return Left(Failure.auth(message: e.message, code: e.code));
    } catch (e) {
      return Left(Failure.unknown(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Group>> joinGroup(JoinGroupRequest request) async {
    try {
      final group = await remoteDataSource.joinGroup(request);
      return Right(group);
    } on NetworkException catch (e) {
      return Left(Failure.network(message: e.message, code: e.code));
    } on ServerException catch (e) {
      return Left(Failure.server(message: e.message, code: e.code));
    } on ValidationException catch (e) {
      return Left(Failure.validation(message: e.message, code: e.code));
    } on AuthException catch (e) {
      return Left(Failure.auth(message: e.message, code: e.code));
    } catch (e) {
      return Left(Failure.unknown(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> leaveGroup(String groupId) async {
    try {
      await remoteDataSource.leaveGroup(groupId);
      return const Right(null);
    } on NetworkException catch (e) {
      return Left(Failure.network(message: e.message, code: e.code));
    } on ServerException catch (e) {
      return Left(Failure.server(message: e.message, code: e.code));
    } on AuthException catch (e) {
      return Left(Failure.auth(message: e.message, code: e.code));
    } catch (e) {
      return Left(Failure.unknown(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> removeMember(String groupId, String userId) async {
    try {
      await remoteDataSource.removeMember(groupId, userId);
      return const Right(null);
    } on NetworkException catch (e) {
      return Left(Failure.network(message: e.message, code: e.code));
    } on ServerException catch (e) {
      return Left(Failure.server(message: e.message, code: e.code));
    } on AuthException catch (e) {
      return Left(Failure.auth(message: e.message, code: e.code));
    } catch (e) {
      return Left(Failure.unknown(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, GroupMember>> updateMemberRole(
    String groupId,
    String userId,
    String role,
  ) async {
    try {
      final member = await remoteDataSource.updateMemberRole(groupId, userId, role);
      return Right(member);
    } on NetworkException catch (e) {
      return Left(Failure.network(message: e.message, code: e.code));
    } on ServerException catch (e) {
      return Left(Failure.server(message: e.message, code: e.code));
    } on ValidationException catch (e) {
      return Left(Failure.validation(message: e.message, code: e.code));
    } on AuthException catch (e) {
      return Left(Failure.auth(message: e.message, code: e.code));
    } catch (e) {
      return Left(Failure.unknown(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Group>> regenerateInviteToken(String groupId) async {
    try {
      final group = await remoteDataSource.regenerateInviteToken(groupId);
      return Right(group);
    } on NetworkException catch (e) {
      return Left(Failure.network(message: e.message, code: e.code));
    } on ServerException catch (e) {
      return Left(Failure.server(message: e.message, code: e.code));
    } on AuthException catch (e) {
      return Left(Failure.auth(message: e.message, code: e.code));
    } catch (e) {
      return Left(Failure.unknown(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, GroupPreview>> getGroupPreviewByInviteToken(String inviteToken) async {
    try {
      final preview = await remoteDataSource.getGroupPreviewByInviteToken(inviteToken);
      return Right(preview);
    } on NetworkException catch (e) {
      return Left(Failure.network(message: e.message, code: e.code));
    } on ServerException catch (e) {
      return Left(Failure.server(message: e.message, code: e.code));
    } on AuthException catch (e) {
      return Left(Failure.auth(message: e.message, code: e.code));
    } catch (e) {
      return Left(Failure.unknown(message: e.toString()));
    }
  }
}
