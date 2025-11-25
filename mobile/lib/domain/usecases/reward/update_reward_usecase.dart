import 'package:dartz/dartz.dart';
import 'package:taskflow/core/errors/failure.dart';
import 'package:taskflow/data/models/reward.dart';
import 'package:taskflow/data/repositories/reward_repository.dart';

class UpdateRewardUseCase {
  final RewardRepository repository;

  UpdateRewardUseCase(this.repository);

  Future<Either<Failure, Reward>> call({
    required String rewardId,
    required String groupId,
    String? name,
    int? cost,
    String? description,
    String? imageUrl,
    bool? isActive,
  }) async {
    return await repository.updateReward(
      rewardId: rewardId,
      groupId: groupId,
      name: name,
      cost: cost,
      description: description,
      imageUrl: imageUrl,
      isActive: isActive,
    );
  }
}
