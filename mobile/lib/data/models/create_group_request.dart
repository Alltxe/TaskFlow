import 'package:freezed_annotation/freezed_annotation.dart';

part 'create_group_request.freezed.dart';
part 'create_group_request.g.dart';

@freezed
class CreateGroupRequest with _$CreateGroupRequest {
  const factory CreateGroupRequest({
    required String name,
    String? description,
    @Default(true) bool requiresApproval,
    @Default('ROUND_ROBIN') String rotationType,
    @Default(true) bool gamificationEnabled,
  }) = _CreateGroupRequest;

  factory CreateGroupRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateGroupRequestFromJson(json);
}
