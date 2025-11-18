import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:mobile/data/models/task_enums.dart';

part 'task_filter.freezed.dart';

/// Task filter model for filtering task lists (PRD 3.8.3)
@freezed
class TaskFilter with _$TaskFilter {
  const factory TaskFilter({
    /// Filter by task status
    TaskStatus? status,

    /// Filter by task priority
    TaskPriority? priority,

    /// Filter by executor/assignee ID
    String? assigneeId,

    /// Filter by minimum deadline date
    DateTime? deadlineFrom,

    /// Filter by maximum deadline date
    DateTime? deadlineTo,

    /// Filter by minimum points
    int? minPoints,

    /// Filter by maximum points
    int? maxPoints,

    /// Filter by group ID
    String? groupId,

    /// Search query for title/description
    String? searchQuery,
  }) = _TaskFilter;

  /// Empty filter (no filtering applied)
  static const empty = TaskFilter();
}
