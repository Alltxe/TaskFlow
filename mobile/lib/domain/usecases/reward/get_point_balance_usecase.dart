import 'package:dartz/dartz.dart';
import 'package:taskflow/core/errors/failure.dart';
import 'package:taskflow/data/models/point_balance.dart';
import 'package:taskflow/data/repositories/reward_repository.dart';

class GetPointBalanceUseCase {
  final RewardRepository repository;

  GetPointBalanceUseCase(this.repository);

  Future<Either<Failure, PointBalance>> call({String? groupId}) {
    return repository.getPointBalance(groupId: groupId);
  }
}
