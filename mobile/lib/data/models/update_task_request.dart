import 'package:freezed_annotation/freezed_annotation.dart';

part 'update_task_request.freezed.dart';
part 'update_task_request.g.dart';

@freezed
class UpdateTaskRequest with _$UpdateTaskRequest {
  const factory UpdateTaskRequest({
    String? title,
    String? description,
    DateTime? deadline,
    String? priority,
    int? points,
    String? assigneeId,
    int? weight,
  }) = _UpdateTaskRequest;

  factory UpdateTaskRequest.fromJson(Map<String, dynamic> json) =>
      _$UpdateTaskRequestFromJson(json);
}
