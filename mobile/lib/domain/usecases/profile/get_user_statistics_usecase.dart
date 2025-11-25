import 'package:dartz/dartz.dart';
import 'package:taskflow/core/errors/failure.dart';
import 'package:taskflow/data/models/user_statistics.dart';
import 'package:taskflow/data/repositories/profile_repository.dart';

/// Use case for getting user statistics
class GetUserStatisticsUseCase {
  final ProfileRepository repository;

  GetUserStatisticsUseCase(this.repository);

  Future<Either<Failure, UserStatistics>> call({String? groupId}) async {
    return await repository.getUserStatistics(groupId: groupId);
  }
}
