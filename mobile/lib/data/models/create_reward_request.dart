import 'package:freezed_annotation/freezed_annotation.dart';

part 'create_reward_request.freezed.dart';
part 'create_reward_request.g.dart';

@freezed
class CreateRewardRequest with _$CreateRewardRequest {
  const factory CreateRewardRequest({
    required String groupId,
    required String name,
    String? description,
    required int cost,
    String? imageUrl,
  }) = _CreateRewardRequest;

  factory CreateRewardRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateRewardRequestFromJson(json);
}
