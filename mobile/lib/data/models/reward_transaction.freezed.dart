// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'reward_transaction.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

RewardTransaction _$RewardTransactionFromJson(Map<String, dynamic> json) {
  return _RewardTransaction.fromJson(json);
}

/// @nodoc
mixin _$RewardTransaction {
  String get id => throw _privateConstructorUsedError;
  int get pointsSpent => throw _privateConstructorUsedError;
  String get status => throw _privateConstructorUsedError;
  DateTime get requestedAt => throw _privateConstructorUsedError;
  DateTime? get approvedAt => throw _privateConstructorUsedError;
  DateTime? get rejectedAt => throw _privateConstructorUsedError;
  String? get rejectionReason => throw _privateConstructorUsedError;
  String get rewardId => throw _privateConstructorUsedError;
  String get userId => throw _privateConstructorUsedError;
  String? get groupId => throw _privateConstructorUsedError;
  String? get approvedById => throw _privateConstructorUsedError;
  Reward? get reward => throw _privateConstructorUsedError;
  User? get user => throw _privateConstructorUsedError;
  User? get approvedBy => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $RewardTransactionCopyWith<RewardTransaction> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RewardTransactionCopyWith<$Res> {
  factory $RewardTransactionCopyWith(
          RewardTransaction value, $Res Function(RewardTransaction) then) =
      _$RewardTransactionCopyWithImpl<$Res, RewardTransaction>;
  @useResult
  $Res call(
      {String id,
      int pointsSpent,
      String status,
      DateTime requestedAt,
      DateTime? approvedAt,
      DateTime? rejectedAt,
      String? rejectionReason,
      String rewardId,
      String userId,
      String? groupId,
      String? approvedById,
      Reward? reward,
      User? user,
      User? approvedBy});

  $RewardCopyWith<$Res>? get reward;
  $UserCopyWith<$Res>? get user;
  $UserCopyWith<$Res>? get approvedBy;
}

/// @nodoc
class _$RewardTransactionCopyWithImpl<$Res, $Val extends RewardTransaction>
    implements $RewardTransactionCopyWith<$Res> {
  _$RewardTransactionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? pointsSpent = null,
    Object? status = null,
    Object? requestedAt = null,
    Object? approvedAt = freezed,
    Object? rejectedAt = freezed,
    Object? rejectionReason = freezed,
    Object? rewardId = null,
    Object? userId = null,
    Object? groupId = freezed,
    Object? approvedById = freezed,
    Object? reward = freezed,
    Object? user = freezed,
    Object? approvedBy = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      pointsSpent: null == pointsSpent
          ? _value.pointsSpent
          : pointsSpent // ignore: cast_nullable_to_non_nullable
              as int,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      requestedAt: null == requestedAt
          ? _value.requestedAt
          : requestedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      approvedAt: freezed == approvedAt
          ? _value.approvedAt
          : approvedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      rejectedAt: freezed == rejectedAt
          ? _value.rejectedAt
          : rejectedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      rejectionReason: freezed == rejectionReason
          ? _value.rejectionReason
          : rejectionReason // ignore: cast_nullable_to_non_nullable
              as String?,
      rewardId: null == rewardId
          ? _value.rewardId
          : rewardId // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      groupId: freezed == groupId
          ? _value.groupId
          : groupId // ignore: cast_nullable_to_non_nullable
              as String?,
      approvedById: freezed == approvedById
          ? _value.approvedById
          : approvedById // ignore: cast_nullable_to_non_nullable
              as String?,
      reward: freezed == reward
          ? _value.reward
          : reward // ignore: cast_nullable_to_non_nullable
              as Reward?,
      user: freezed == user
          ? _value.user
          : user // ignore: cast_nullable_to_non_nullable
              as User?,
      approvedBy: freezed == approvedBy
          ? _value.approvedBy
          : approvedBy // ignore: cast_nullable_to_non_nullable
              as User?,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $RewardCopyWith<$Res>? get reward {
    if (_value.reward == null) {
      return null;
    }

    return $RewardCopyWith<$Res>(_value.reward!, (value) {
      return _then(_value.copyWith(reward: value) as $Val);
    });
  }

  @override
  @pragma('vm:prefer-inline')
  $UserCopyWith<$Res>? get user {
    if (_value.user == null) {
      return null;
    }

    return $UserCopyWith<$Res>(_value.user!, (value) {
      return _then(_value.copyWith(user: value) as $Val);
    });
  }

  @override
  @pragma('vm:prefer-inline')
  $UserCopyWith<$Res>? get approvedBy {
    if (_value.approvedBy == null) {
      return null;
    }

    return $UserCopyWith<$Res>(_value.approvedBy!, (value) {
      return _then(_value.copyWith(approvedBy: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$RewardTransactionImplCopyWith<$Res>
    implements $RewardTransactionCopyWith<$Res> {
  factory _$$RewardTransactionImplCopyWith(_$RewardTransactionImpl value,
          $Res Function(_$RewardTransactionImpl) then) =
      __$$RewardTransactionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      int pointsSpent,
      String status,
      DateTime requestedAt,
      DateTime? approvedAt,
      DateTime? rejectedAt,
      String? rejectionReason,
      String rewardId,
      String userId,
      String? groupId,
      String? approvedById,
      Reward? reward,
      User? user,
      User? approvedBy});

  @override
  $RewardCopyWith<$Res>? get reward;
  @override
  $UserCopyWith<$Res>? get user;
  @override
  $UserCopyWith<$Res>? get approvedBy;
}

/// @nodoc
class __$$RewardTransactionImplCopyWithImpl<$Res>
    extends _$RewardTransactionCopyWithImpl<$Res, _$RewardTransactionImpl>
    implements _$$RewardTransactionImplCopyWith<$Res> {
  __$$RewardTransactionImplCopyWithImpl(_$RewardTransactionImpl _value,
      $Res Function(_$RewardTransactionImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? pointsSpent = null,
    Object? status = null,
    Object? requestedAt = null,
    Object? approvedAt = freezed,
    Object? rejectedAt = freezed,
    Object? rejectionReason = freezed,
    Object? rewardId = null,
    Object? userId = null,
    Object? groupId = freezed,
    Object? approvedById = freezed,
    Object? reward = freezed,
    Object? user = freezed,
    Object? approvedBy = freezed,
  }) {
    return _then(_$RewardTransactionImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      pointsSpent: null == pointsSpent
          ? _value.pointsSpent
          : pointsSpent // ignore: cast_nullable_to_non_nullable
              as int,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      requestedAt: null == requestedAt
          ? _value.requestedAt
          : requestedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      approvedAt: freezed == approvedAt
          ? _value.approvedAt
          : approvedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      rejectedAt: freezed == rejectedAt
          ? _value.rejectedAt
          : rejectedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      rejectionReason: freezed == rejectionReason
          ? _value.rejectionReason
          : rejectionReason // ignore: cast_nullable_to_non_nullable
              as String?,
      rewardId: null == rewardId
          ? _value.rewardId
          : rewardId // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      groupId: freezed == groupId
          ? _value.groupId
          : groupId // ignore: cast_nullable_to_non_nullable
              as String?,
      approvedById: freezed == approvedById
          ? _value.approvedById
          : approvedById // ignore: cast_nullable_to_non_nullable
              as String?,
      reward: freezed == reward
          ? _value.reward
          : reward // ignore: cast_nullable_to_non_nullable
              as Reward?,
      user: freezed == user
          ? _value.user
          : user // ignore: cast_nullable_to_non_nullable
              as User?,
      approvedBy: freezed == approvedBy
          ? _value.approvedBy
          : approvedBy // ignore: cast_nullable_to_non_nullable
              as User?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$RewardTransactionImpl implements _RewardTransaction {
  const _$RewardTransactionImpl(
      {required this.id,
      required this.pointsSpent,
      required this.status,
      required this.requestedAt,
      this.approvedAt,
      this.rejectedAt,
      this.rejectionReason,
      required this.rewardId,
      required this.userId,
      this.groupId,
      this.approvedById,
      this.reward,
      this.user,
      this.approvedBy});

  factory _$RewardTransactionImpl.fromJson(Map<String, dynamic> json) =>
      _$$RewardTransactionImplFromJson(json);

  @override
  final String id;
  @override
  final int pointsSpent;
  @override
  final String status;
  @override
  final DateTime requestedAt;
  @override
  final DateTime? approvedAt;
  @override
  final DateTime? rejectedAt;
  @override
  final String? rejectionReason;
  @override
  final String rewardId;
  @override
  final String userId;
  @override
  final String? groupId;
  @override
  final String? approvedById;
  @override
  final Reward? reward;
  @override
  final User? user;
  @override
  final User? approvedBy;

  @override
  String toString() {
    return 'RewardTransaction(id: $id, pointsSpent: $pointsSpent, status: $status, requestedAt: $requestedAt, approvedAt: $approvedAt, rejectedAt: $rejectedAt, rejectionReason: $rejectionReason, rewardId: $rewardId, userId: $userId, groupId: $groupId, approvedById: $approvedById, reward: $reward, user: $user, approvedBy: $approvedBy)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RewardTransactionImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.pointsSpent, pointsSpent) ||
                other.pointsSpent == pointsSpent) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.requestedAt, requestedAt) ||
                other.requestedAt == requestedAt) &&
            (identical(other.approvedAt, approvedAt) ||
                other.approvedAt == approvedAt) &&
            (identical(other.rejectedAt, rejectedAt) ||
                other.rejectedAt == rejectedAt) &&
            (identical(other.rejectionReason, rejectionReason) ||
                other.rejectionReason == rejectionReason) &&
            (identical(other.rewardId, rewardId) ||
                other.rewardId == rewardId) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.groupId, groupId) || other.groupId == groupId) &&
            (identical(other.approvedById, approvedById) ||
                other.approvedById == approvedById) &&
            (identical(other.reward, reward) || other.reward == reward) &&
            (identical(other.user, user) || other.user == user) &&
            (identical(other.approvedBy, approvedBy) ||
                other.approvedBy == approvedBy));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      pointsSpent,
      status,
      requestedAt,
      approvedAt,
      rejectedAt,
      rejectionReason,
      rewardId,
      userId,
      groupId,
      approvedById,
      reward,
      user,
      approvedBy);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$RewardTransactionImplCopyWith<_$RewardTransactionImpl> get copyWith =>
      __$$RewardTransactionImplCopyWithImpl<_$RewardTransactionImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$RewardTransactionImplToJson(
      this,
    );
  }
}

abstract class _RewardTransaction implements RewardTransaction {
  const factory _RewardTransaction(
      {required final String id,
      required final int pointsSpent,
      required final String status,
      required final DateTime requestedAt,
      final DateTime? approvedAt,
      final DateTime? rejectedAt,
      final String? rejectionReason,
      required final String rewardId,
      required final String userId,
      final String? groupId,
      final String? approvedById,
      final Reward? reward,
      final User? user,
      final User? approvedBy}) = _$RewardTransactionImpl;

  factory _RewardTransaction.fromJson(Map<String, dynamic> json) =
      _$RewardTransactionImpl.fromJson;

  @override
  String get id;
  @override
  int get pointsSpent;
  @override
  String get status;
  @override
  DateTime get requestedAt;
  @override
  DateTime? get approvedAt;
  @override
  DateTime? get rejectedAt;
  @override
  String? get rejectionReason;
  @override
  String get rewardId;
  @override
  String get userId;
  @override
  String? get groupId;
  @override
  String? get approvedById;
  @override
  Reward? get reward;
  @override
  User? get user;
  @override
  User? get approvedBy;
  @override
  @JsonKey(ignore: true)
  _$$RewardTransactionImplCopyWith<_$RewardTransactionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
