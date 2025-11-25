import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:taskflow/data/models/point_transaction.dart';

part 'point_transaction_history.freezed.dart';
part 'point_transaction_history.g.dart';

@freezed
class PointTransactionHistory with _$PointTransactionHistory {
  const factory PointTransactionHistory({
    required List<PointTransaction> items,
    required int total,
  }) = _PointTransactionHistory;

  factory PointTransactionHistory.fromJson(Map<String, dynamic> json) =>
      _$PointTransactionHistoryFromJson(json);
}
