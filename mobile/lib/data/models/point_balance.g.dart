// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'point_balance.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PointBalanceImpl _$$PointBalanceImplFromJson(Map<String, dynamic> json) =>
    _$PointBalanceImpl(
      totalEarned: (json['totalEarned'] as num).toInt(),
      totalSpentApproved: (json['totalSpentApproved'] as num).toInt(),
      totalReservedPending: (json['totalReservedPending'] as num).toInt(),
      currentBalance: (json['currentBalance'] as num).toInt(),
      availableBalance: (json['availableBalance'] as num).toInt(),
    );

Map<String, dynamic> _$$PointBalanceImplToJson(_$PointBalanceImpl instance) =>
    <String, dynamic>{
      'totalEarned': instance.totalEarned,
      'totalSpentApproved': instance.totalSpentApproved,
      'totalReservedPending': instance.totalReservedPending,
      'currentBalance': instance.currentBalance,
      'availableBalance': instance.availableBalance,
    };
