// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'task_filter.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$TaskFilter {
  /// Filter by task status
  TaskStatus? get status => throw _privateConstructorUsedError;

  /// Filter by task priority
  TaskPriority? get priority => throw _privateConstructorUsedError;

  /// Filter by executor/assignee ID
  String? get assigneeId => throw _privateConstructorUsedError;

  /// Filter by minimum deadline date
  DateTime? get deadlineFrom => throw _privateConstructorUsedError;

  /// Filter by maximum deadline date
  DateTime? get deadlineTo => throw _privateConstructorUsedError;

  /// Filter by minimum points
  int? get minPoints => throw _privateConstructorUsedError;

  /// Filter by maximum points
  int? get maxPoints => throw _privateConstructorUsedError;

  /// Filter by group ID
  String? get groupId => throw _privateConstructorUsedError;

  /// Search query for title/description
  String? get searchQuery => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $TaskFilterCopyWith<TaskFilter> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TaskFilterCopyWith<$Res> {
  factory $TaskFilterCopyWith(
          TaskFilter value, $Res Function(TaskFilter) then) =
      _$TaskFilterCopyWithImpl<$Res, TaskFilter>;
  @useResult
  $Res call(
      {TaskStatus? status,
      TaskPriority? priority,
      String? assigneeId,
      DateTime? deadlineFrom,
      DateTime? deadlineTo,
      int? minPoints,
      int? maxPoints,
      String? groupId,
      String? searchQuery});
}

/// @nodoc
class _$TaskFilterCopyWithImpl<$Res, $Val extends TaskFilter>
    implements $TaskFilterCopyWith<$Res> {
  _$TaskFilterCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? status = freezed,
    Object? priority = freezed,
    Object? assigneeId = freezed,
    Object? deadlineFrom = freezed,
    Object? deadlineTo = freezed,
    Object? minPoints = freezed,
    Object? maxPoints = freezed,
    Object? groupId = freezed,
    Object? searchQuery = freezed,
  }) {
    return _then(_value.copyWith(
      status: freezed == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as TaskStatus?,
      priority: freezed == priority
          ? _value.priority
          : priority // ignore: cast_nullable_to_non_nullable
              as TaskPriority?,
      assigneeId: freezed == assigneeId
          ? _value.assigneeId
          : assigneeId // ignore: cast_nullable_to_non_nullable
              as String?,
      deadlineFrom: freezed == deadlineFrom
          ? _value.deadlineFrom
          : deadlineFrom // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      deadlineTo: freezed == deadlineTo
          ? _value.deadlineTo
          : deadlineTo // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      minPoints: freezed == minPoints
          ? _value.minPoints
          : minPoints // ignore: cast_nullable_to_non_nullable
              as int?,
      maxPoints: freezed == maxPoints
          ? _value.maxPoints
          : maxPoints // ignore: cast_nullable_to_non_nullable
              as int?,
      groupId: freezed == groupId
          ? _value.groupId
          : groupId // ignore: cast_nullable_to_non_nullable
              as String?,
      searchQuery: freezed == searchQuery
          ? _value.searchQuery
          : searchQuery // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$TaskFilterImplCopyWith<$Res>
    implements $TaskFilterCopyWith<$Res> {
  factory _$$TaskFilterImplCopyWith(
          _$TaskFilterImpl value, $Res Function(_$TaskFilterImpl) then) =
      __$$TaskFilterImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {TaskStatus? status,
      TaskPriority? priority,
      String? assigneeId,
      DateTime? deadlineFrom,
      DateTime? deadlineTo,
      int? minPoints,
      int? maxPoints,
      String? groupId,
      String? searchQuery});
}

/// @nodoc
class __$$TaskFilterImplCopyWithImpl<$Res>
    extends _$TaskFilterCopyWithImpl<$Res, _$TaskFilterImpl>
    implements _$$TaskFilterImplCopyWith<$Res> {
  __$$TaskFilterImplCopyWithImpl(
      _$TaskFilterImpl _value, $Res Function(_$TaskFilterImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? status = freezed,
    Object? priority = freezed,
    Object? assigneeId = freezed,
    Object? deadlineFrom = freezed,
    Object? deadlineTo = freezed,
    Object? minPoints = freezed,
    Object? maxPoints = freezed,
    Object? groupId = freezed,
    Object? searchQuery = freezed,
  }) {
    return _then(_$TaskFilterImpl(
      status: freezed == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as TaskStatus?,
      priority: freezed == priority
          ? _value.priority
          : priority // ignore: cast_nullable_to_non_nullable
              as TaskPriority?,
      assigneeId: freezed == assigneeId
          ? _value.assigneeId
          : assigneeId // ignore: cast_nullable_to_non_nullable
              as String?,
      deadlineFrom: freezed == deadlineFrom
          ? _value.deadlineFrom
          : deadlineFrom // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      deadlineTo: freezed == deadlineTo
          ? _value.deadlineTo
          : deadlineTo // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      minPoints: freezed == minPoints
          ? _value.minPoints
          : minPoints // ignore: cast_nullable_to_non_nullable
              as int?,
      maxPoints: freezed == maxPoints
          ? _value.maxPoints
          : maxPoints // ignore: cast_nullable_to_non_nullable
              as int?,
      groupId: freezed == groupId
          ? _value.groupId
          : groupId // ignore: cast_nullable_to_non_nullable
              as String?,
      searchQuery: freezed == searchQuery
          ? _value.searchQuery
          : searchQuery // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc

class _$TaskFilterImpl implements _TaskFilter {
  const _$TaskFilterImpl(
      {this.status,
      this.priority,
      this.assigneeId,
      this.deadlineFrom,
      this.deadlineTo,
      this.minPoints,
      this.maxPoints,
      this.groupId,
      this.searchQuery});

  /// Filter by task status
  @override
  final TaskStatus? status;

  /// Filter by task priority
  @override
  final TaskPriority? priority;

  /// Filter by executor/assignee ID
  @override
  final String? assigneeId;

  /// Filter by minimum deadline date
  @override
  final DateTime? deadlineFrom;

  /// Filter by maximum deadline date
  @override
  final DateTime? deadlineTo;

  /// Filter by minimum points
  @override
  final int? minPoints;

  /// Filter by maximum points
  @override
  final int? maxPoints;

  /// Filter by group ID
  @override
  final String? groupId;

  /// Search query for title/description
  @override
  final String? searchQuery;

  @override
  String toString() {
    return 'TaskFilter(status: $status, priority: $priority, assigneeId: $assigneeId, deadlineFrom: $deadlineFrom, deadlineTo: $deadlineTo, minPoints: $minPoints, maxPoints: $maxPoints, groupId: $groupId, searchQuery: $searchQuery)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TaskFilterImpl &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.priority, priority) ||
                other.priority == priority) &&
            (identical(other.assigneeId, assigneeId) ||
                other.assigneeId == assigneeId) &&
            (identical(other.deadlineFrom, deadlineFrom) ||
                other.deadlineFrom == deadlineFrom) &&
            (identical(other.deadlineTo, deadlineTo) ||
                other.deadlineTo == deadlineTo) &&
            (identical(other.minPoints, minPoints) ||
                other.minPoints == minPoints) &&
            (identical(other.maxPoints, maxPoints) ||
                other.maxPoints == maxPoints) &&
            (identical(other.groupId, groupId) || other.groupId == groupId) &&
            (identical(other.searchQuery, searchQuery) ||
                other.searchQuery == searchQuery));
  }

  @override
  int get hashCode => Object.hash(runtimeType, status, priority, assigneeId,
      deadlineFrom, deadlineTo, minPoints, maxPoints, groupId, searchQuery);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$TaskFilterImplCopyWith<_$TaskFilterImpl> get copyWith =>
      __$$TaskFilterImplCopyWithImpl<_$TaskFilterImpl>(this, _$identity);
}

abstract class _TaskFilter implements TaskFilter {
  const factory _TaskFilter(
      {final TaskStatus? status,
      final TaskPriority? priority,
      final String? assigneeId,
      final DateTime? deadlineFrom,
      final DateTime? deadlineTo,
      final int? minPoints,
      final int? maxPoints,
      final String? groupId,
      final String? searchQuery}) = _$TaskFilterImpl;

  @override

  /// Filter by task status
  TaskStatus? get status;
  @override

  /// Filter by task priority
  TaskPriority? get priority;
  @override

  /// Filter by executor/assignee ID
  String? get assigneeId;
  @override

  /// Filter by minimum deadline date
  DateTime? get deadlineFrom;
  @override

  /// Filter by maximum deadline date
  DateTime? get deadlineTo;
  @override

  /// Filter by minimum points
  int? get minPoints;
  @override

  /// Filter by maximum points
  int? get maxPoints;
  @override

  /// Filter by group ID
  String? get groupId;
  @override

  /// Search query for title/description
  String? get searchQuery;
  @override
  @JsonKey(ignore: true)
  _$$TaskFilterImplCopyWith<_$TaskFilterImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
