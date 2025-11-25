import 'package:dartz/dartz.dart';
import 'package:taskflow/core/errors/failure.dart';
import 'package:taskflow/data/models/reward.dart';
import 'package:taskflow/data/repositories/reward_repository.dart';

class CreateRewardUseCase {
  final RewardRepository repository;

  CreateRewardUseCase(this.repository);

  Future<Either<Failure, Reward>> call({
    required String groupId,
    required String name,
    required int cost,
    String? description,
    String? imageUrl,
    bool? isActive,
  }) async {
    return await repository.createReward(
      groupId: groupId,
      name: name,
      cost: cost,
      description: description,
      imageUrl: imageUrl,
      isActive: isActive ?? true,
    );
  }
}
