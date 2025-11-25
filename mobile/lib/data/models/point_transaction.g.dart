// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'point_transaction.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PointTransactionImpl _$$PointTransactionImplFromJson(
        Map<String, dynamic> json) =>
    _$PointTransactionImpl(
      id: json['id'] as String,
      type: json['type'] as String,
      amount: (json['amount'] as num).toInt(),
      description: json['description'] as String,
      relatedTaskId: json['relatedTaskId'] as String?,
      relatedTaskTitle: json['relatedTaskTitle'] as String?,
      relatedRewardId: json['relatedRewardId'] as String?,
      relatedRewardName: json['relatedRewardName'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$$PointTransactionImplToJson(
        _$PointTransactionImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': instance.type,
      'amount': instance.amount,
      'description': instance.description,
      'relatedTaskId': instance.relatedTaskId,
      'relatedTaskTitle': instance.relatedTaskTitle,
      'relatedRewardId': instance.relatedRewardId,
      'relatedRewardName': instance.relatedRewardName,
      'createdAt': instance.createdAt.toIso8601String(),
    };
