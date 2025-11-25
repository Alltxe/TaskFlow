import 'package:dartz/dartz.dart';
import 'package:taskflow/core/errors/failure.dart';
import 'package:taskflow/data/models/point_transaction_history.dart';
import 'package:taskflow/data/repositories/reward_repository.dart';

class GetPointTransactionHistoryUseCase {
  final RewardRepository repository;

  GetPointTransactionHistoryUseCase(this.repository);

  Future<Either<Failure, PointTransactionHistory>> call({
    String? groupId,
    int? limit,
    int? offset,
  }) {
    return repository.getPointTransactionHistory(
      groupId: groupId,
      limit: limit,
      offset: offset,
    );
  }
}
