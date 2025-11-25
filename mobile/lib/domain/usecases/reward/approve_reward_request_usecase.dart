import 'package:dartz/dartz.dart';
import 'package:taskflow/core/errors/failure.dart';
import 'package:taskflow/data/models/reward_transaction.dart';
import 'package:taskflow/data/repositories/reward_repository.dart';

class ApproveRewardRequestUseCase {
  final RewardRepository repository;

  ApproveRewardRequestUseCase(this.repository);

  Future<Either<Failure, RewardTransaction>> call({
    required String requestId,
    required bool approved,
    String? reason,
  }) async {
    return await repository.approveRewardRequest(
      requestId: requestId,
      approved: approved,
      reason: reason,
    );
  }
}
