import 'package:dartz/dartz.dart';
import 'package:taskflow/core/errors/exceptions.dart';
import 'package:taskflow/core/errors/failure.dart';
import 'package:taskflow/data/datasources/reward_remote_datasource.dart';
import 'package:taskflow/data/models/leaderboard_entry.dart';
import 'package:taskflow/data/models/reward.dart';
import 'package:taskflow/data/models/user_statistics.dart';
import 'package:taskflow/data/repositories/reward_repository.dart';

class RewardRepositoryImpl implements RewardRepository {
  final RewardRemoteDataSource remoteDataSource;

  RewardRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, List<Reward>>> getGroupRewards(String groupId) async {
    try {
      final rewards = await remoteDataSource.getGroupRewards(groupId);
      return Right(rewards);
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on AuthException catch (e) {
      return Left(AuthFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserStatistics>> getUserStatistics(String groupId) async {
    try {
      final stats = await remoteDataSource.getUserStatistics(groupId);
      return Right(stats);
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on AuthException catch (e) {
      return Left(AuthFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<LeaderboardEntry>>> getGroupLeaderboard(String groupId) async {
    try {
      final leaderboard = await remoteDataSource.getGroupLeaderboard(groupId);
      return Right(leaderboard);
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on AuthException catch (e) {
      return Left(AuthFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }
}
