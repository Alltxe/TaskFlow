import 'package:dartz/dartz.dart';
import 'package:taskflow/core/errors/failure.dart';
import 'package:taskflow/data/models/leaderboard_entry.dart';
import 'package:taskflow/data/models/reward.dart';
import 'package:taskflow/data/models/user_statistics.dart';

abstract class RewardRepository {
  Future<Either<Failure, List<Reward>>> getGroupRewards(String groupId);
  Future<Either<Failure, UserStatistics>> getUserStatistics(String groupId);
  Future<Either<Failure, List<LeaderboardEntry>>> getGroupLeaderboard(String groupId);
}
