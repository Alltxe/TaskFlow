import 'package:freezed_annotation/freezed_annotation.dart';

part 'group_summary.freezed.dart';
part 'group_summary.g.dart';

/// Simplified Group model for profile display
@freezed
class GroupSummary with _$GroupSummary {
  const factory GroupSummary({
    required String id,
    required String name,
    String? description,
    required String role, // 'admin' or 'participant'
    required bool gamificationEnabled,
    required DateTime joinedAt,
  }) = _GroupSummary;

  factory GroupSummary.fromJson(Map<String, dynamic> json) => _$GroupSummaryFromJson(json);
}
