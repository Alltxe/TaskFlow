import 'package:freezed_annotation/freezed_annotation.dart';

part 'create_task_request.freezed.dart';
part 'create_task_request.g.dart';

@freezed
class CreateTaskRequest with _$CreateTaskRequest {
  const factory CreateTaskRequest({
    required String groupId,
    required String title,
    String? description,
    required DateTime deadline,
    required String priority, // LOW, MEDIUM, HIGH
    int? points,
    String? assigneeId,
    bool? isRecurring,
    String? recurrenceRule,
    String? rotationType,
    int? weight,
  }) = _CreateTaskRequest;

  factory CreateTaskRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateTaskRequestFromJson(json);
}
