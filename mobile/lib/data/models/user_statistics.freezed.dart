// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'user_statistics.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

UserStatistics _$UserStatisticsFromJson(Map<String, dynamic> json) {
  return _UserStatistics.fromJson(json);
}

/// @nodoc
mixin _$UserStatistics {
  /// User ID
  String get userId => throw _privateConstructorUsedError;

  /// Current point balance (total earned - total spent)
  int get currentPointBalance => throw _privateConstructorUsedError;

  /// Total points earned from completed tasks
  int get totalPointsEarned => throw _privateConstructorUsedError;

  /// Total points spent on rewards
  int get totalPointsSpent => throw _privateConstructorUsedError;

  /// Total number of tasks completed
  int get tasksCompleted => throw _privateConstructorUsedError;

  /// Total number of tasks assigned to user
  int get tasksAssigned => throw _privateConstructorUsedError;

  /// Task completion rate (completed / assigned) as percentage
  double get completionRate => throw _privateConstructorUsedError;

  /// Number of tasks completed on time
  int get tasksCompletedOnTime => throw _privateConstructorUsedError;

  /// On-time completion percentage
  double get onTimePercentage => throw _privateConstructorUsedError;

  /// Leaderboard position (1-based, null if no completions)
  int? get leaderboardPosition => throw _privateConstructorUsedError;

  /// Group ID for group-specific statistics (null for overall stats)
  String? get groupId => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $UserStatisticsCopyWith<UserStatistics> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UserStatisticsCopyWith<$Res> {
  factory $UserStatisticsCopyWith(
          UserStatistics value, $Res Function(UserStatistics) then) =
      _$UserStatisticsCopyWithImpl<$Res, UserStatistics>;
  @useResult
  $Res call(
      {String userId,
      int currentPointBalance,
      int totalPointsEarned,
      int totalPointsSpent,
      int tasksCompleted,
      int tasksAssigned,
      double completionRate,
      int tasksCompletedOnTime,
      double onTimePercentage,
      int? leaderboardPosition,
      String? groupId});
}

/// @nodoc
class _$UserStatisticsCopyWithImpl<$Res, $Val extends UserStatistics>
    implements $UserStatisticsCopyWith<$Res> {
  _$UserStatisticsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userId = null,
    Object? currentPointBalance = null,
    Object? totalPointsEarned = null,
    Object? totalPointsSpent = null,
    Object? tasksCompleted = null,
    Object? tasksAssigned = null,
    Object? completionRate = null,
    Object? tasksCompletedOnTime = null,
    Object? onTimePercentage = null,
    Object? leaderboardPosition = freezed,
    Object? groupId = freezed,
  }) {
    return _then(_value.copyWith(
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      currentPointBalance: null == currentPointBalance
          ? _value.currentPointBalance
          : currentPointBalance // ignore: cast_nullable_to_non_nullable
              as int,
      totalPointsEarned: null == totalPointsEarned
          ? _value.totalPointsEarned
          : totalPointsEarned // ignore: cast_nullable_to_non_nullable
              as int,
      totalPointsSpent: null == totalPointsSpent
          ? _value.totalPointsSpent
          : totalPointsSpent // ignore: cast_nullable_to_non_nullable
              as int,
      tasksCompleted: null == tasksCompleted
          ? _value.tasksCompleted
          : tasksCompleted // ignore: cast_nullable_to_non_nullable
              as int,
      tasksAssigned: null == tasksAssigned
          ? _value.tasksAssigned
          : tasksAssigned // ignore: cast_nullable_to_non_nullable
              as int,
      completionRate: null == completionRate
          ? _value.completionRate
          : completionRate // ignore: cast_nullable_to_non_nullable
              as double,
      tasksCompletedOnTime: null == tasksCompletedOnTime
          ? _value.tasksCompletedOnTime
          : tasksCompletedOnTime // ignore: cast_nullable_to_non_nullable
              as int,
      onTimePercentage: null == onTimePercentage
          ? _value.onTimePercentage
          : onTimePercentage // ignore: cast_nullable_to_non_nullable
              as double,
      leaderboardPosition: freezed == leaderboardPosition
          ? _value.leaderboardPosition
          : leaderboardPosition // ignore: cast_nullable_to_non_nullable
              as int?,
      groupId: freezed == groupId
          ? _value.groupId
          : groupId // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$UserStatisticsImplCopyWith<$Res>
    implements $UserStatisticsCopyWith<$Res> {
  factory _$$UserStatisticsImplCopyWith(_$UserStatisticsImpl value,
          $Res Function(_$UserStatisticsImpl) then) =
      __$$UserStatisticsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String userId,
      int currentPointBalance,
      int totalPointsEarned,
      int totalPointsSpent,
      int tasksCompleted,
      int tasksAssigned,
      double completionRate,
      int tasksCompletedOnTime,
      double onTimePercentage,
      int? leaderboardPosition,
      String? groupId});
}

/// @nodoc
class __$$UserStatisticsImplCopyWithImpl<$Res>
    extends _$UserStatisticsCopyWithImpl<$Res, _$UserStatisticsImpl>
    implements _$$UserStatisticsImplCopyWith<$Res> {
  __$$UserStatisticsImplCopyWithImpl(
      _$UserStatisticsImpl _value, $Res Function(_$UserStatisticsImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userId = null,
    Object? currentPointBalance = null,
    Object? totalPointsEarned = null,
    Object? totalPointsSpent = null,
    Object? tasksCompleted = null,
    Object? tasksAssigned = null,
    Object? completionRate = null,
    Object? tasksCompletedOnTime = null,
    Object? onTimePercentage = null,
    Object? leaderboardPosition = freezed,
    Object? groupId = freezed,
  }) {
    return _then(_$UserStatisticsImpl(
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      currentPointBalance: null == currentPointBalance
          ? _value.currentPointBalance
          : currentPointBalance // ignore: cast_nullable_to_non_nullable
              as int,
      totalPointsEarned: null == totalPointsEarned
          ? _value.totalPointsEarned
          : totalPointsEarned // ignore: cast_nullable_to_non_nullable
              as int,
      totalPointsSpent: null == totalPointsSpent
          ? _value.totalPointsSpent
          : totalPointsSpent // ignore: cast_nullable_to_non_nullable
              as int,
      tasksCompleted: null == tasksCompleted
          ? _value.tasksCompleted
          : tasksCompleted // ignore: cast_nullable_to_non_nullable
              as int,
      tasksAssigned: null == tasksAssigned
          ? _value.tasksAssigned
          : tasksAssigned // ignore: cast_nullable_to_non_nullable
              as int,
      completionRate: null == completionRate
          ? _value.completionRate
          : completionRate // ignore: cast_nullable_to_non_nullable
              as double,
      tasksCompletedOnTime: null == tasksCompletedOnTime
          ? _value.tasksCompletedOnTime
          : tasksCompletedOnTime // ignore: cast_nullable_to_non_nullable
              as int,
      onTimePercentage: null == onTimePercentage
          ? _value.onTimePercentage
          : onTimePercentage // ignore: cast_nullable_to_non_nullable
              as double,
      leaderboardPosition: freezed == leaderboardPosition
          ? _value.leaderboardPosition
          : leaderboardPosition // ignore: cast_nullable_to_non_nullable
              as int?,
      groupId: freezed == groupId
          ? _value.groupId
          : groupId // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$UserStatisticsImpl implements _UserStatistics {
  const _$UserStatisticsImpl(
      {required this.userId,
      required this.currentPointBalance,
      required this.totalPointsEarned,
      required this.totalPointsSpent,
      required this.tasksCompleted,
      required this.tasksAssigned,
      required this.completionRate,
      required this.tasksCompletedOnTime,
      required this.onTimePercentage,
      this.leaderboardPosition,
      this.groupId});

  factory _$UserStatisticsImpl.fromJson(Map<String, dynamic> json) =>
      _$$UserStatisticsImplFromJson(json);

  /// User ID
  @override
  final String userId;

  /// Current point balance (total earned - total spent)
  @override
  final int currentPointBalance;

  /// Total points earned from completed tasks
  @override
  final int totalPointsEarned;

  /// Total points spent on rewards
  @override
  final int totalPointsSpent;

  /// Total number of tasks completed
  @override
  final int tasksCompleted;

  /// Total number of tasks assigned to user
  @override
  final int tasksAssigned;

  /// Task completion rate (completed / assigned) as percentage
  @override
  final double completionRate;

  /// Number of tasks completed on time
  @override
  final int tasksCompletedOnTime;

  /// On-time completion percentage
  @override
  final double onTimePercentage;

  /// Leaderboard position (1-based, null if no completions)
  @override
  final int? leaderboardPosition;

  /// Group ID for group-specific statistics (null for overall stats)
  @override
  final String? groupId;

  @override
  String toString() {
    return 'UserStatistics(userId: $userId, currentPointBalance: $currentPointBalance, totalPointsEarned: $totalPointsEarned, totalPointsSpent: $totalPointsSpent, tasksCompleted: $tasksCompleted, tasksAssigned: $tasksAssigned, completionRate: $completionRate, tasksCompletedOnTime: $tasksCompletedOnTime, onTimePercentage: $onTimePercentage, leaderboardPosition: $leaderboardPosition, groupId: $groupId)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UserStatisticsImpl &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.currentPointBalance, currentPointBalance) ||
                other.currentPointBalance == currentPointBalance) &&
            (identical(other.totalPointsEarned, totalPointsEarned) ||
                other.totalPointsEarned == totalPointsEarned) &&
            (identical(other.totalPointsSpent, totalPointsSpent) ||
                other.totalPointsSpent == totalPointsSpent) &&
            (identical(other.tasksCompleted, tasksCompleted) ||
                other.tasksCompleted == tasksCompleted) &&
            (identical(other.tasksAssigned, tasksAssigned) ||
                other.tasksAssigned == tasksAssigned) &&
            (identical(other.completionRate, completionRate) ||
                other.completionRate == completionRate) &&
            (identical(other.tasksCompletedOnTime, tasksCompletedOnTime) ||
                other.tasksCompletedOnTime == tasksCompletedOnTime) &&
            (identical(other.onTimePercentage, onTimePercentage) ||
                other.onTimePercentage == onTimePercentage) &&
            (identical(other.leaderboardPosition, leaderboardPosition) ||
                other.leaderboardPosition == leaderboardPosition) &&
            (identical(other.groupId, groupId) || other.groupId == groupId));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      userId,
      currentPointBalance,
      totalPointsEarned,
      totalPointsSpent,
      tasksCompleted,
      tasksAssigned,
      completionRate,
      tasksCompletedOnTime,
      onTimePercentage,
      leaderboardPosition,
      groupId);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$UserStatisticsImplCopyWith<_$UserStatisticsImpl> get copyWith =>
      __$$UserStatisticsImplCopyWithImpl<_$UserStatisticsImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$UserStatisticsImplToJson(
      this,
    );
  }
}

abstract class _UserStatistics implements UserStatistics {
  const factory _UserStatistics(
      {required final String userId,
      required final int currentPointBalance,
      required final int totalPointsEarned,
      required final int totalPointsSpent,
      required final int tasksCompleted,
      required final int tasksAssigned,
      required final double completionRate,
      required final int tasksCompletedOnTime,
      required final double onTimePercentage,
      final int? leaderboardPosition,
      final String? groupId}) = _$UserStatisticsImpl;

  factory _UserStatistics.fromJson(Map<String, dynamic> json) =
      _$UserStatisticsImpl.fromJson;

  @override

  /// User ID
  String get userId;
  @override

  /// Current point balance (total earned - total spent)
  int get currentPointBalance;
  @override

  /// Total points earned from completed tasks
  int get totalPointsEarned;
  @override

  /// Total points spent on rewards
  int get totalPointsSpent;
  @override

  /// Total number of tasks completed
  int get tasksCompleted;
  @override

  /// Total number of tasks assigned to user
  int get tasksAssigned;
  @override

  /// Task completion rate (completed / assigned) as percentage
  double get completionRate;
  @override

  /// Number of tasks completed on time
  int get tasksCompletedOnTime;
  @override

  /// On-time completion percentage
  double get onTimePercentage;
  @override

  /// Leaderboard position (1-based, null if no completions)
  int? get leaderboardPosition;
  @override

  /// Group ID for group-specific statistics (null for overall stats)
  String? get groupId;
  @override
  @JsonKey(ignore: true)
  _$$UserStatisticsImplCopyWith<_$UserStatisticsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
