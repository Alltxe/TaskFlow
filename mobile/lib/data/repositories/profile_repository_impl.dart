import 'package:dartz/dartz.dart';
import 'package:taskflow/core/errors/exceptions.dart';
import 'package:taskflow/core/errors/failure.dart';
import 'package:taskflow/data/datasources/profile_remote_datasource.dart';
import 'package:taskflow/data/models/group_summary.dart';
import 'package:taskflow/data/models/user.dart';
import 'package:taskflow/data/models/user_statistics.dart';
import 'package:taskflow/data/repositories/profile_repository.dart';

/// Implementation of ProfileRepository
class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDataSource remoteDataSource;

  ProfileRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, User>> getCurrentUserProfile() async {
    try {
      final user = await remoteDataSource.getCurrentUserProfile();
      return Right(user);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } on AuthException catch (e) {
      return Left(AuthFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserStatistics>> getUserStatistics({String? groupId}) async {
    try {
      final statistics = await remoteDataSource.getUserStatistics(groupId: groupId);
      return Right(statistics);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } on AuthException catch (e) {
      return Left(AuthFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<GroupSummary>>> getUserGroups() async {
    try {
      final groups = await remoteDataSource.getUserGroups();
      return Right(groups);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } on AuthException catch (e) {
      return Left(AuthFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, User>> updateProfile({
    String? username,
    String? avatarUrl,
    bool? isAway,
    DateTime? awayUntil,
  }) async {
    try {
      final user = await remoteDataSource.updateProfile(
        username: username,
        avatarUrl: avatarUrl,
        isAway: isAway,
        awayUntil: awayUntil,
      );
      return Right(user);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } on AuthException catch (e) {
      return Left(AuthFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> uploadAvatar(String filePath) async {
    try {
      final avatarUrl = await remoteDataSource.uploadAvatar(filePath);
      return Right(avatarUrl);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } on AuthException catch (e) {
      return Left(AuthFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
