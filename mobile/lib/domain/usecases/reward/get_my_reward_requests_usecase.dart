import 'package:dartz/dartz.dart';
import 'package:taskflow/core/errors/failure.dart';
import 'package:taskflow/data/models/reward_transaction.dart';
import 'package:taskflow/data/repositories/reward_repository.dart';

class GetMyRewardRequestsUseCase {
  final RewardRepository repository;

  GetMyRewardRequestsUseCase(this.repository);

  Future<Either<Failure, List<RewardTransaction>>> call({String? groupId}) {
    return repository.getMyRewardRequests(groupId: groupId);
  }
}
