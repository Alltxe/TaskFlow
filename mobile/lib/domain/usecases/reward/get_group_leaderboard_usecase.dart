import 'package:dartz/dartz.dart';
import 'package:taskflow/core/errors/failure.dart';
import 'package:taskflow/data/models/leaderboard_entry.dart';
import 'package:taskflow/data/repositories/reward_repository.dart';

class GetGroupLeaderboardUseCase {
  final RewardRepository repository;

  GetGroupLeaderboardUseCase(this.repository);

  Future<Either<Failure, List<LeaderboardEntry>>> call(String groupId) {
    return repository.getGroupLeaderboard(groupId);
  }
}
