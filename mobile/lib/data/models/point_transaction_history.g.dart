// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'point_transaction_history.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PointTransactionHistoryImpl _$$PointTransactionHistoryImplFromJson(
        Map<String, dynamic> json) =>
    _$PointTransactionHistoryImpl(
      items: (json['items'] as List<dynamic>)
          .map((e) => PointTransaction.fromJson(e as Map<String, dynamic>))
          .toList(),
      total: (json['total'] as num).toInt(),
    );

Map<String, dynamic> _$$PointTransactionHistoryImplToJson(
        _$PointTransactionHistoryImpl instance) =>
    <String, dynamic>{
      'items': instance.items,
      'total': instance.total,
    };
