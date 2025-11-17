import 'package:dartz/dartz.dart';
import 'package:mobile/core/errors/failure.dart';
import 'package:mobile/data/models/user_statistics.dart';
import 'package:mobile/data/repositories/profile_repository.dart';

/// Use case for getting user statistics
class GetUserStatisticsUseCase {
  final ProfileRepository repository;

  GetUserStatisticsUseCase(this.repository);

  Future<Either<Failure, UserStatistics>> call({String? groupId}) async {
    return await repository.getUserStatistics(groupId: groupId);
  }
}
