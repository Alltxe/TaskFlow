import 'package:dartz/dartz.dart';
import 'package:mobile/core/errors/failure.dart';
import 'package:mobile/data/models/group_summary.dart';
import 'package:mobile/data/models/user.dart';
import 'package:mobile/data/models/user_statistics.dart';

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
