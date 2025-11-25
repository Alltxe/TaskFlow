// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reward_transaction.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$RewardTransactionImpl _$$RewardTransactionImplFromJson(
        Map<String, dynamic> json) =>
    _$RewardTransactionImpl(
      id: json['id'] as String,
      pointsSpent: (json['pointsSpent'] as num).toInt(),
      status: json['status'] as String,
      requestedAt: DateTime.parse(json['requestedAt'] as String),
      approvedAt: json['approvedAt'] == null
          ? null
          : DateTime.parse(json['approvedAt'] as String),
      rejectedAt: json['rejectedAt'] == null
          ? null
          : DateTime.parse(json['rejectedAt'] as String),
      rejectionReason: json['rejectionReason'] as String?,
      rewardId: json['rewardId'] as String,
      userId: json['userId'] as String,
      groupId: json['groupId'] as String?,
      approvedById: json['approvedById'] as String?,
      reward: json['reward'] == null
          ? null
          : Reward.fromJson(json['reward'] as Map<String, dynamic>),
      user: json['user'] == null
          ? null
          : User.fromJson(json['user'] as Map<String, dynamic>),
      approvedBy: json['approvedBy'] == null
          ? null
          : User.fromJson(json['approvedBy'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$RewardTransactionImplToJson(
        _$RewardTransactionImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'pointsSpent': instance.pointsSpent,
      'status': instance.status,
      'requestedAt': instance.requestedAt.toIso8601String(),
      'approvedAt': instance.approvedAt?.toIso8601String(),
      'rejectedAt': instance.rejectedAt?.toIso8601String(),
      'rejectionReason': instance.rejectionReason,
      'rewardId': instance.rewardId,
      'userId': instance.userId,
      'groupId': instance.groupId,
      'approvedById': instance.approvedById,
      'reward': instance.reward,
      'user': instance.user,
      'approvedBy': instance.approvedBy,
    };
