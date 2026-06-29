import 'package:freezed_annotation/freezed_annotation.dart';

part 'request_reward_input.freezed.dart';
part 'request_reward_input.g.dart';

@freezed
class RequestRewardInput with _$RequestRewardInput {
  const factory RequestRewardInput({
    required String rewardId,
  }) = _RequestRewardInput;

  factory RequestRewardInput.fromJson(Map<String, dynamic> json) =>
      _$RequestRewardInputFromJson(json);
}
