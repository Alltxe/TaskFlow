// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'point_transaction_history.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

PointTransactionHistory _$PointTransactionHistoryFromJson(
    Map<String, dynamic> json) {
  return _PointTransactionHistory.fromJson(json);
}

/// @nodoc
mixin _$PointTransactionHistory {
  List<PointTransaction> get items => throw _privateConstructorUsedError;
  int get total => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $PointTransactionHistoryCopyWith<PointTransactionHistory> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PointTransactionHistoryCopyWith<$Res> {
  factory $PointTransactionHistoryCopyWith(PointTransactionHistory value,
          $Res Function(PointTransactionHistory) then) =
      _$PointTransactionHistoryCopyWithImpl<$Res, PointTransactionHistory>;
  @useResult
  $Res call({List<PointTransaction> items, int total});
}

/// @nodoc
class _$PointTransactionHistoryCopyWithImpl<$Res,
        $Val extends PointTransactionHistory>
    implements $PointTransactionHistoryCopyWith<$Res> {
  _$PointTransactionHistoryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? items = null,
    Object? total = null,
  }) {
    return _then(_value.copyWith(
      items: null == items
          ? _value.items
          : items // ignore: cast_nullable_to_non_nullable
              as List<PointTransaction>,
      total: null == total
          ? _value.total
          : total // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$PointTransactionHistoryImplCopyWith<$Res>
    implements $PointTransactionHistoryCopyWith<$Res> {
  factory _$$PointTransactionHistoryImplCopyWith(
          _$PointTransactionHistoryImpl value,
          $Res Function(_$PointTransactionHistoryImpl) then) =
      __$$PointTransactionHistoryImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({List<PointTransaction> items, int total});
}

/// @nodoc
class __$$PointTransactionHistoryImplCopyWithImpl<$Res>
    extends _$PointTransactionHistoryCopyWithImpl<$Res,
        _$PointTransactionHistoryImpl>
    implements _$$PointTransactionHistoryImplCopyWith<$Res> {
  __$$PointTransactionHistoryImplCopyWithImpl(
      _$PointTransactionHistoryImpl _value,
      $Res Function(_$PointTransactionHistoryImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? items = null,
    Object? total = null,
  }) {
    return _then(_$PointTransactionHistoryImpl(
      items: null == items
          ? _value._items
          : items // ignore: cast_nullable_to_non_nullable
              as List<PointTransaction>,
      total: null == total
          ? _value.total
          : total // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$PointTransactionHistoryImpl implements _PointTransactionHistory {
  const _$PointTransactionHistoryImpl(
      {required final List<PointTransaction> items, required this.total})
      : _items = items;

  factory _$PointTransactionHistoryImpl.fromJson(Map<String, dynamic> json) =>
      _$$PointTransactionHistoryImplFromJson(json);

  final List<PointTransaction> _items;
  @override
  List<PointTransaction> get items {
    if (_items is EqualUnmodifiableListView) return _items;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_items);
  }

  @override
  final int total;

  @override
  String toString() {
    return 'PointTransactionHistory(items: $items, total: $total)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PointTransactionHistoryImpl &&
            const DeepCollectionEquality().equals(other._items, _items) &&
            (identical(other.total, total) || other.total == total));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType, const DeepCollectionEquality().hash(_items), total);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$PointTransactionHistoryImplCopyWith<_$PointTransactionHistoryImpl>
      get copyWith => __$$PointTransactionHistoryImplCopyWithImpl<
          _$PointTransactionHistoryImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PointTransactionHistoryImplToJson(
      this,
    );
  }
}

abstract class _PointTransactionHistory implements PointTransactionHistory {
  const factory _PointTransactionHistory(
      {required final List<PointTransaction> items,
      required final int total}) = _$PointTransactionHistoryImpl;

  factory _PointTransactionHistory.fromJson(Map<String, dynamic> json) =
      _$PointTransactionHistoryImpl.fromJson;

  @override
  List<PointTransaction> get items;
  @override
  int get total;
  @override
  @JsonKey(ignore: true)
  _$$PointTransactionHistoryImplCopyWith<_$PointTransactionHistoryImpl>
      get copyWith => throw _privateConstructorUsedError;
}
