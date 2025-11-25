import 'package:dartz/dartz.dart';
import 'package:taskflow/core/errors/failure.dart';
import 'package:taskflow/data/models/group_summary.dart';
import 'package:taskflow/data/models/user.dart';
import 'package:taskflow/data/models/user_statistics.dart';

/// Repository interface for user profile operations
abstract class ProfileRepository {
  /// Get current user profile
  Future<Either<Failure, User>> getCurrentUserProfile();

  /// Get user statistics (optionally for a specific group)
  Future<Either<Failure, UserStatistics>> getUserStatistics({String? groupId});

  /// Get user's groups
  Future<Either<Failure, List<GroupSummary>>> getUserGroups();

  /// Update user profile
  Future<Either<Failure, User>> updateProfile({
    String? username,
    String? avatarUrl,
    bool? isAway,
    DateTime? awayUntil,
  });

  /// Upload avatar image and return the URL
  Future<Either<Failure, String>> uploadAvatar(String filePath);
}
