import 'package:freezed_annotation/freezed_annotation.dart';

part 'point_balance.freezed.dart';
part 'point_balance.g.dart';

@freezed
class PointBalance with _$PointBalance {
  const factory PointBalance({
    required int totalEarned,
    required int totalSpentApproved,
    required int totalReservedPending,
    required int currentBalance,
    required int availableBalance,
  }) = _PointBalance;

  factory PointBalance.fromJson(Map<String, dynamic> json) =>
      _$PointBalanceFromJson(json);
}
