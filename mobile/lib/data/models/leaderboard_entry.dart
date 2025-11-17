import 'package:freezed_annotation/freezed_annotation.dart';

part 'leaderboard_entry.freezed.dart';
part 'leaderboard_entry.g.dart';

@freezed
class LeaderboardEntry with _$LeaderboardEntry {
  const factory LeaderboardEntry({
    required LeaderboardUser user,
    required int pointsEarned,
    required int rank,
  }) = _LeaderboardEntry;

  factory LeaderboardEntry.fromJson(Map<String, dynamic> json) => _$LeaderboardEntryFromJson(json);
}

@freezed
class LeaderboardUser with _$LeaderboardUser {
  const factory LeaderboardUser({required String id, required String username}) = _LeaderboardUser;

  factory LeaderboardUser.fromJson(Map<String, dynamic> json) => _$LeaderboardUserFromJson(json);
}
