// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'point_balance.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

PointBalance _$PointBalanceFromJson(Map<String, dynamic> json) {
  return _PointBalance.fromJson(json);
}

/// @nodoc
mixin _$PointBalance {
  int get totalEarned => throw _privateConstructorUsedError;
  int get totalSpentApproved => throw _privateConstructorUsedError;
  int get totalReservedPending => throw _privateConstructorUsedError;
  int get currentBalance => throw _privateConstructorUsedError;
  int get availableBalance => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $PointBalanceCopyWith<PointBalance> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PointBalanceCopyWith<$Res> {
  factory $PointBalanceCopyWith(
          PointBalance value, $Res Function(PointBalance) then) =
      _$PointBalanceCopyWithImpl<$Res, PointBalance>;
  @useResult
  $Res call(
      {int totalEarned,
      int totalSpentApproved,
      int totalReservedPending,
      int currentBalance,
      int availableBalance});
}

/// @nodoc
class _$PointBalanceCopyWithImpl<$Res, $Val extends PointBalance>
    implements $PointBalanceCopyWith<$Res> {
  _$PointBalanceCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? totalEarned = null,
    Object? totalSpentApproved = null,
    Object? totalReservedPending = null,
    Object? currentBalance = null,
    Object? availableBalance = null,
  }) {
    return _then(_value.copyWith(
      totalEarned: null == totalEarned
          ? _value.totalEarned
          : totalEarned // ignore: cast_nullable_to_non_nullable
              as int,
      totalSpentApproved: null == totalSpentApproved
          ? _value.totalSpentApproved
          : totalSpentApproved // ignore: cast_nullable_to_non_nullable
              as int,
      totalReservedPending: null == totalReservedPending
          ? _value.totalReservedPending
          : totalReservedPending // ignore: cast_nullable_to_non_nullable
              as int,
      currentBalance: null == currentBalance
          ? _value.currentBalance
          : currentBalance // ignore: cast_nullable_to_non_nullable
              as int,
      availableBalance: null == availableBalance
          ? _value.availableBalance
          : availableBalance // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$PointBalanceImplCopyWith<$Res>
    implements $PointBalanceCopyWith<$Res> {
  factory _$$PointBalanceImplCopyWith(
          _$PointBalanceImpl value, $Res Function(_$PointBalanceImpl) then) =
      __$$PointBalanceImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int totalEarned,
      int totalSpentApproved,
      int totalReservedPending,
      int currentBalance,
      int availableBalance});
}

/// @nodoc
class __$$PointBalanceImplCopyWithImpl<$Res>
    extends _$PointBalanceCopyWithImpl<$Res, _$PointBalanceImpl>
    implements _$$PointBalanceImplCopyWith<$Res> {
  __$$PointBalanceImplCopyWithImpl(
      _$PointBalanceImpl _value, $Res Function(_$PointBalanceImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? totalEarned = null,
    Object? totalSpentApproved = null,
    Object? totalReservedPending = null,
    Object? currentBalance = null,
    Object? availableBalance = null,
  }) {
    return _then(_$PointBalanceImpl(
      totalEarned: null == totalEarned
          ? _value.totalEarned
          : totalEarned // ignore: cast_nullable_to_non_nullable
              as int,
      totalSpentApproved: null == totalSpentApproved
          ? _value.totalSpentApproved
          : totalSpentApproved // ignore: cast_nullable_to_non_nullable
              as int,
      totalReservedPending: null == totalReservedPending
          ? _value.totalReservedPending
          : totalReservedPending // ignore: cast_nullable_to_non_nullable
              as int,
      currentBalance: null == currentBalance
          ? _value.currentBalance
          : currentBalance // ignore: cast_nullable_to_non_nullable
              as int,
      availableBalance: null == availableBalance
          ? _value.availableBalance
          : availableBalance // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$PointBalanceImpl implements _PointBalance {
  const _$PointBalanceImpl(
      {required this.totalEarned,
      required this.totalSpentApproved,
      required this.totalReservedPending,
      required this.currentBalance,
      required this.availableBalance});

  factory _$PointBalanceImpl.fromJson(Map<String, dynamic> json) =>
      _$$PointBalanceImplFromJson(json);

  @override
  final int totalEarned;
  @override
  final int totalSpentApproved;
  @override
  final int totalReservedPending;
  @override
  final int currentBalance;
  @override
  final int availableBalance;

  @override
  String toString() {
    return 'PointBalance(totalEarned: $totalEarned, totalSpentApproved: $totalSpentApproved, totalReservedPending: $totalReservedPending, currentBalance: $currentBalance, availableBalance: $availableBalance)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PointBalanceImpl &&
            (identical(other.totalEarned, totalEarned) ||
                other.totalEarned == totalEarned) &&
            (identical(other.totalSpentApproved, totalSpentApproved) ||
                other.totalSpentApproved == totalSpentApproved) &&
            (identical(other.totalReservedPending, totalReservedPending) ||
                other.totalReservedPending == totalReservedPending) &&
            (identical(other.currentBalance, currentBalance) ||
                other.currentBalance == currentBalance) &&
            (identical(other.availableBalance, availableBalance) ||
                other.availableBalance == availableBalance));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, totalEarned, totalSpentApproved,
      totalReservedPending, currentBalance, availableBalance);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$PointBalanceImplCopyWith<_$PointBalanceImpl> get copyWith =>
      __$$PointBalanceImplCopyWithImpl<_$PointBalanceImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PointBalanceImplToJson(
      this,
    );
  }
}

abstract class _PointBalance implements PointBalance {
  const factory _PointBalance(
      {required final int totalEarned,
      required final int totalSpentApproved,
      required final int totalReservedPending,
      required final int currentBalance,
      required final int availableBalance}) = _$PointBalanceImpl;

  factory _PointBalance.fromJson(Map<String, dynamic> json) =
      _$PointBalanceImpl.fromJson;

  @override
  int get totalEarned;
  @override
  int get totalSpentApproved;
  @override
  int get totalReservedPending;
  @override
  int get currentBalance;
  @override
  int get availableBalance;
  @override
  @JsonKey(ignore: true)
  _$$PointBalanceImplCopyWith<_$PointBalanceImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
