import 'package:dartz/dartz.dart';
import 'package:taskflow/core/errors/failure.dart';
import 'package:taskflow/data/models/leaderboard_entry.dart';
import 'package:taskflow/data/models/point_balance.dart';
import 'package:taskflow/data/models/point_transaction_history.dart';
import 'package:taskflow/data/models/request_reward_input.dart';
import 'package:taskflow/data/models/reward.dart';
import 'package:taskflow/data/models/reward_transaction.dart';
import 'package:taskflow/data/models/user_statistics.dart';

abstract class RewardRepository {
  Future<Either<Failure, List<Reward>>> getGroupRewards(String groupId);
  Future<Either<Failure, UserStatistics>> getUserStatistics(String groupId);
  Future<Either<Failure, List<LeaderboardEntry>>> getGroupLeaderboard(String groupId);
  Future<Either<Failure, RewardTransaction>> requestReward(RequestRewardInput input);
  Future<Either<Failure, List<RewardTransaction>>> getMyRewardRequests({String? groupId});
  Future<Either<Failure, PointBalance>> getPointBalance({String? groupId});
  Future<Either<Failure, PointTransactionHistory>> getPointTransactionHistory({
    String? groupId,
    int? limit,
    int? offset,
  });

  // Admin-only methods
  Future<Either<Failure, Reward>> createReward({
    required String groupId,
    required String name,
    required int cost,
    String? description,
    String? imageUrl,
    bool? isActive,
  });
  Future<Either<Failure, Reward>> updateReward({
    required String rewardId,
    required String groupId,
    String? name,
    int? cost,
    String? description,
    String? imageUrl,
    bool? isActive,
  });
  Future<Either<Failure, bool>> deleteReward({
    required String rewardId,
    required String groupId,
  });
  Future<Either<Failure, List<RewardTransaction>>> getGroupRewardRequests(String groupId);
  Future<Either<Failure, RewardTransaction>> approveRewardRequest({
    required String requestId,
    required bool approved,
    String? reason,
  });
}
