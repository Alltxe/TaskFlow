import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:mobile/data/models/reward.dart';
import 'package:mobile/data/models/user.dart';

part 'reward_transaction.freezed.dart';
part 'reward_transaction.g.dart';

@freezed
class RewardTransaction with _$RewardTransaction {
  const factory RewardTransaction({
    required String id,
    required int pointsSpent,
    required String status,
    required DateTime requestedAt,
    DateTime? approvedAt,
    DateTime? rejectedAt,
    String? rejectionReason,
    required String rewardId,
    required String userId,
    required String groupId,
    String? approvedById,
    Reward? reward,
    User? user,
    User? approvedBy,
  }) = _RewardTransaction;

  factory RewardTransaction.fromJson(Map<String, dynamic> json) =>
      _$RewardTransactionFromJson(json);
}
