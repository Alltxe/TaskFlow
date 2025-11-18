import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_statistics.freezed.dart';
part 'user_statistics.g.dart';

/// User statistics model (from backend schema.gql UserStatistics type)
@freezed
class UserStatistics with _$UserStatistics {
  const factory UserStatistics({
    /// User ID
    required String userId,

    /// Current point balance (total earned - total spent)
    required int currentPointBalance,

    /// Total points earned from completed tasks
    required int totalPointsEarned,

    /// Total points spent on rewards
    required int totalPointsSpent,

    /// Total number of tasks completed
    required int tasksCompleted,

    /// Total number of tasks assigned to user
    required int tasksAssigned,

    /// Task completion rate (completed / assigned) as percentage
    required double completionRate,

    /// Number of tasks completed on time
    required int tasksCompletedOnTime,

    /// On-time completion percentage
    required double onTimePercentage,

    /// Leaderboard position (1-based, null if no completions)
    int? leaderboardPosition,

    /// Group ID for group-specific statistics (null for overall stats)
    String? groupId,
  }) = _UserStatistics;

  factory UserStatistics.fromJson(Map<String, dynamic> json) => _$UserStatisticsFromJson(json);
}
