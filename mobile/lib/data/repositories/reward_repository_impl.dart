import 'package:dartz/dartz.dart';
import 'package:taskflow/core/errors/exceptions.dart';
import 'package:taskflow/core/errors/failure.dart';
import 'package:taskflow/data/datasources/reward_remote_datasource.dart';
import 'package:taskflow/data/models/leaderboard_entry.dart';
import 'package:taskflow/data/models/point_balance.dart';
import 'package:taskflow/data/models/point_transaction_history.dart';
import 'package:taskflow/data/models/request_reward_input.dart';
import 'package:taskflow/data/models/reward.dart';
import 'package:taskflow/data/models/reward_transaction.dart';
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

  @override
  Future<Either<Failure, RewardTransaction>> requestReward(RequestRewardInput input) async {
    try {
      final transaction = await remoteDataSource.requestReward(input);
      return Right(transaction);
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
  Future<Either<Failure, List<RewardTransaction>>> getMyRewardRequests({String? groupId}) async {
    try {
      final requests = await remoteDataSource.getMyRewardRequests(groupId: groupId);
      return Right(requests);
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
  Future<Either<Failure, PointBalance>> getPointBalance({String? groupId}) async {
    try {
      final balance = await remoteDataSource.getPointBalance(groupId: groupId);
      return Right(balance);
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
  Future<Either<Failure, PointTransactionHistory>> getPointTransactionHistory({
    String? groupId,
    int? limit,
    int? offset,
  }) async {
    try {
      final history = await remoteDataSource.getPointTransactionHistory(
        groupId: groupId,
        limit: limit,
        offset: offset,
      );
      return Right(history);
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
  Future<Either<Failure, Reward>> createReward({
    required String groupId,
    required String name,
    required int cost,
    String? description,
    String? imageUrl,
    bool? isActive,
  }) async {
    try {
      final reward = await remoteDataSource.createReward(
        groupId: groupId,
        name: name,
        cost: cost,
        description: description,
        imageUrl: imageUrl,
        isActive: isActive,
      );
      return Right(reward);
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
  Future<Either<Failure, Reward>> updateReward({
    required String rewardId,
    required String groupId,
    String? name,
    int? cost,
    String? description,
    String? imageUrl,
    bool? isActive,
  }) async {
    try {
      final reward = await remoteDataSource.updateReward(
        rewardId: rewardId,
        groupId: groupId,
        name: name,
        cost: cost,
        description: description,
        imageUrl: imageUrl,
        isActive: isActive,
      );
      return Right(reward);
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
  Future<Either<Failure, bool>> deleteReward({
    required String rewardId,
    required String groupId,
  }) async {
    try {
      final result = await remoteDataSource.deleteReward(
        rewardId: rewardId,
        groupId: groupId,
      );
      return Right(result);
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
  Future<Either<Failure, List<RewardTransaction>>> getGroupRewardRequests(String groupId) async {
    try {
      final requests = await remoteDataSource.getGroupRewardRequests(groupId);
      return Right(requests);
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
  Future<Either<Failure, RewardTransaction>> approveRewardRequest({
    required String requestId,
    required bool approved,
    String? reason,
  }) async {
    try {
      final transaction = await remoteDataSource.approveRewardRequest(
        requestId: requestId,
        approved: approved,
        reason: reason,
      );
      return Right(transaction);
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
