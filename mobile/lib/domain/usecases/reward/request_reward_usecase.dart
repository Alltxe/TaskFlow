import 'package:dartz/dartz.dart';
import 'package:taskflow/core/errors/failure.dart';
import 'package:taskflow/data/models/request_reward_input.dart';
import 'package:taskflow/data/models/reward_transaction.dart';
import 'package:taskflow/data/repositories/reward_repository.dart';

class RequestRewardUseCase {
  final RewardRepository repository;

  RequestRewardUseCase(this.repository);

  Future<Either<Failure, RewardTransaction>> call(RequestRewardInput input) {
    return repository.requestReward(input);
  }
}
