import 'package:freezed_annotation/freezed_annotation.dart';

part 'update_group_request.freezed.dart';
part 'update_group_request.g.dart';

@freezed
class UpdateGroupRequest with _$UpdateGroupRequest {
  const factory UpdateGroupRequest({
    String? name,
    String? description,
    bool? requiresApproval,
    String? rotationType,
    bool? gamificationEnabled,
  }) = _UpdateGroupRequest;

  factory UpdateGroupRequest.fromJson(Map<String, dynamic> json) =>
      _$UpdateGroupRequestFromJson(json);
}
