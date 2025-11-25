import 'package:dartz/dartz.dart';
import 'package:taskflow/core/errors/failure.dart';
import 'package:taskflow/data/models/reward_transaction.dart';
import 'package:taskflow/data/repositories/reward_repository.dart';

class GetGroupRewardRequestsUseCase {
  final RewardRepository repository;

  GetGroupRewardRequestsUseCase(this.repository);

  Future<Either<Failure, List<RewardTransaction>>> call(String groupId) async {
    return await repository.getGroupRewardRequests(groupId);
  }
}
