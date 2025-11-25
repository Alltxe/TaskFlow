import 'package:freezed_annotation/freezed_annotation.dart';

part 'point_transaction.freezed.dart';
part 'point_transaction.g.dart';

@freezed
class PointTransaction with _$PointTransaction {
  const factory PointTransaction({
    required String id,
    required String type,
    required int amount,
    required String description,
    String? relatedTaskId,
    String? relatedTaskTitle,
    String? relatedRewardId,
    String? relatedRewardName,
    required DateTime createdAt,
  }) = _PointTransaction;

  factory PointTransaction.fromJson(Map<String, dynamic> json) =>
      _$PointTransactionFromJson(json);
}
