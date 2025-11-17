import 'package:dartz/dartz.dart';
import 'package:mobile/core/errors/failure.dart';
import 'package:mobile/data/models/reward.dart';
import 'package:mobile/data/repositories/reward_repository.dart';

class GetGroupRewardsUseCase {
  final RewardRepository repository;

  GetGroupRewardsUseCase(this.repository);

  Future<Either<Failure, List<Reward>>> call(String groupId) {
    return repository.getGroupRewards(groupId);
  }
}
