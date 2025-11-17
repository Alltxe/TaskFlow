import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:mobile/data/models/group_member.dart';

part 'task.freezed.dart';
part 'task.g.dart';

@freezed
class Task with _$Task {
  const factory Task({
    required String id,
    required String title,
    String? description,
    required DateTime deadline,
    required String priority,
    required String status,
    required int points,
    required bool requiresApproval,
    required bool isRecurring,
    String? recurrenceRule,
    String? rotationType,
    required int weight,
    required bool wasClaimedFromPool,
    String? rejectionReason,
    required DateTime createdAt,
    DateTime? completedAt,
    required String groupId,
    required String createdById,
    String? assigneeId,
    GroupMemberUser? assignee,
    GroupMemberUser? createdBy,
  }) = _Task;

  factory Task.fromJson(Map<String, dynamic> json) => _$TaskFromJson(json);
}
