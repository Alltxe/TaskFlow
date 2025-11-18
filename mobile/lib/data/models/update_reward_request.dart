import 'package:freezed_annotation/freezed_annotation.dart';

part 'update_reward_request.freezed.dart';
part 'update_reward_request.g.dart';

@freezed
class UpdateRewardRequest with _$UpdateRewardRequest {
  const factory UpdateRewardRequest({
    String? name,
    String? description,
    int? cost,
    bool? isActive,
    String? imageUrl,
  }) = _UpdateRewardRequest;

  factory UpdateRewardRequest.fromJson(Map<String, dynamic> json) =>
      _$UpdateRewardRequestFromJson(json);
}
