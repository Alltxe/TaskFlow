import 'package:dartz/dartz.dart';
import 'package:taskflow/core/errors/failure.dart';
import 'package:taskflow/data/models/reward.dart';
import 'package:taskflow/data/repositories/reward_repository.dart';

class GetGroupRewardsUseCase {
  final RewardRepository repository;

  GetGroupRewardsUseCase(this.repository);

  Future<Either<Failure, List<Reward>>> call(String groupId) {
    return repository.getGroupRewards(groupId);
  }
}
