import 'package:dartz/dartz.dart';
import 'package:taskflow/core/errors/failure.dart';
import 'package:taskflow/data/repositories/reward_repository.dart';

class DeleteRewardUseCase {
  final RewardRepository repository;

  DeleteRewardUseCase(this.repository);

  Future<Either<Failure, bool>> call({
    required String rewardId,
    required String groupId,
  }) async {
    return await repository.deleteReward(
      rewardId: rewardId,
      groupId: groupId,
    );
  }
}
