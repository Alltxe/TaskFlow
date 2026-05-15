// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'task.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Task _$TaskFromJson(Map<String, dynamic> json) {
  return _Task.fromJson(json);
}

/// @nodoc
mixin _$Task {
  String get id => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  DateTime get deadline => throw _privateConstructorUsedError;
  String get priority => throw _privateConstructorUsedError;
  String get status => throw _privateConstructorUsedError;
  int get points => throw _privateConstructorUsedError;
  bool get requiresApproval => throw _privateConstructorUsedError;
  bool get isRecurring => throw _privateConstructorUsedError;
  String? get recurrenceRule => throw _privateConstructorUsedError;
  String? get rotationType => throw _privateConstructorUsedError;
  int get weight => throw _privateConstructorUsedError;
  bool get wasClaimedFromPool => throw _privateConstructorUsedError;
  String? get rejectionReason => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime? get completedAt => throw _privateConstructorUsedError;
  String get groupId => throw _privateConstructorUsedError;
  String get createdById => throw _privateConstructorUsedError;
  String? get assigneeId => throw _privateConstructorUsedError;
  GroupMemberUser? get assignee => throw _privateConstructorUsedError;
  GroupMemberUser? get createdBy => throw _privateConstructorUsedError;
  List<TaskAttachment> get attachments => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $TaskCopyWith<Task> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TaskCopyWith<$Res> {
  factory $TaskCopyWith(Task value, $Res Function(Task) then) =
      _$TaskCopyWithImpl<$Res, Task>;
  @useResult
  $Res call(
      {String id,
      String title,
      String? description,
      DateTime deadline,
      String priority,
      String status,
      int points,
      bool requiresApproval,
      bool isRecurring,
      String? recurrenceRule,
      String? rotationType,
      int weight,
      bool wasClaimedFromPool,
      String? rejectionReason,
      DateTime createdAt,
      DateTime? completedAt,
      String groupId,
      String createdById,
      String? assigneeId,
      GroupMemberUser? assignee,
      GroupMemberUser? createdBy,
      List<TaskAttachment> attachments});

  $GroupMemberUserCopyWith<$Res>? get assignee;
  $GroupMemberUserCopyWith<$Res>? get createdBy;
}

/// @nodoc
class _$TaskCopyWithImpl<$Res, $Val extends Task>
    implements $TaskCopyWith<$Res> {
  _$TaskCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? description = freezed,
    Object? deadline = null,
    Object? priority = null,
    Object? status = null,
    Object? points = null,
    Object? requiresApproval = null,
    Object? isRecurring = null,
    Object? recurrenceRule = freezed,
    Object? rotationType = freezed,
    Object? weight = null,
    Object? wasClaimedFromPool = null,
    Object? rejectionReason = freezed,
    Object? createdAt = null,
    Object? completedAt = freezed,
    Object? groupId = null,
    Object? createdById = null,
    Object? assigneeId = freezed,
    Object? assignee = freezed,
    Object? createdBy = freezed,
    Object? attachments = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      deadline: null == deadline
          ? _value.deadline
          : deadline // ignore: cast_nullable_to_non_nullable
              as DateTime,
      priority: null == priority
          ? _value.priority
          : priority // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      points: null == points
          ? _value.points
          : points // ignore: cast_nullable_to_non_nullable
              as int,
      requiresApproval: null == requiresApproval
          ? _value.requiresApproval
          : requiresApproval // ignore: cast_nullable_to_non_nullable
              as bool,
      isRecurring: null == isRecurring
          ? _value.isRecurring
          : isRecurring // ignore: cast_nullable_to_non_nullable
              as bool,
      recurrenceRule: freezed == recurrenceRule
          ? _value.recurrenceRule
          : recurrenceRule // ignore: cast_nullable_to_non_nullable
              as String?,
      rotationType: freezed == rotationType
          ? _value.rotationType
          : rotationType // ignore: cast_nullable_to_non_nullable
              as String?,
      weight: null == weight
          ? _value.weight
          : weight // ignore: cast_nullable_to_non_nullable
              as int,
      wasClaimedFromPool: null == wasClaimedFromPool
          ? _value.wasClaimedFromPool
          : wasClaimedFromPool // ignore: cast_nullable_to_non_nullable
              as bool,
      rejectionReason: freezed == rejectionReason
          ? _value.rejectionReason
          : rejectionReason // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      completedAt: freezed == completedAt
          ? _value.completedAt
          : completedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      groupId: null == groupId
          ? _value.groupId
          : groupId // ignore: cast_nullable_to_non_nullable
              as String,
      createdById: null == createdById
          ? _value.createdById
          : createdById // ignore: cast_nullable_to_non_nullable
              as String,
      assigneeId: freezed == assigneeId
          ? _value.assigneeId
          : assigneeId // ignore: cast_nullable_to_non_nullable
              as String?,
      assignee: freezed == assignee
          ? _value.assignee
          : assignee // ignore: cast_nullable_to_non_nullable
              as GroupMemberUser?,
      createdBy: freezed == createdBy
          ? _value.createdBy
          : createdBy // ignore: cast_nullable_to_non_nullable
              as GroupMemberUser?,
      attachments: null == attachments
          ? _value.attachments
          : attachments // ignore: cast_nullable_to_non_nullable
              as List<TaskAttachment>,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $GroupMemberUserCopyWith<$Res>? get assignee {
    if (_value.assignee == null) {
      return null;
    }

    return $GroupMemberUserCopyWith<$Res>(_value.assignee!, (value) {
      return _then(_value.copyWith(assignee: value) as $Val);
    });
  }

  @override
  @pragma('vm:prefer-inline')
  $GroupMemberUserCopyWith<$Res>? get createdBy {
    if (_value.createdBy == null) {
      return null;
    }

    return $GroupMemberUserCopyWith<$Res>(_value.createdBy!, (value) {
      return _then(_value.copyWith(createdBy: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$TaskImplCopyWith<$Res> implements $TaskCopyWith<$Res> {
  factory _$$TaskImplCopyWith(
          _$TaskImpl value, $Res Function(_$TaskImpl) then) =
      __$$TaskImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String title,
      String? description,
      DateTime deadline,
      String priority,
      String status,
      int points,
      bool requiresApproval,
      bool isRecurring,
      String? recurrenceRule,
      String? rotationType,
      int weight,
      bool wasClaimedFromPool,
      String? rejectionReason,
      DateTime createdAt,
      DateTime? completedAt,
      String groupId,
      String createdById,
      String? assigneeId,
      GroupMemberUser? assignee,
      GroupMemberUser? createdBy,
      List<TaskAttachment> attachments});

  @override
  $GroupMemberUserCopyWith<$Res>? get assignee;
  @override
  $GroupMemberUserCopyWith<$Res>? get createdBy;
}

/// @nodoc
class __$$TaskImplCopyWithImpl<$Res>
    extends _$TaskCopyWithImpl<$Res, _$TaskImpl>
    implements _$$TaskImplCopyWith<$Res> {
  __$$TaskImplCopyWithImpl(_$TaskImpl _value, $Res Function(_$TaskImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? description = freezed,
    Object? deadline = null,
    Object? priority = null,
    Object? status = null,
    Object? points = null,
    Object? requiresApproval = null,
    Object? isRecurring = null,
    Object? recurrenceRule = freezed,
    Object? rotationType = freezed,
    Object? weight = null,
    Object? wasClaimedFromPool = null,
    Object? rejectionReason = freezed,
    Object? createdAt = null,
    Object? completedAt = freezed,
    Object? groupId = null,
    Object? createdById = null,
    Object? assigneeId = freezed,
    Object? assignee = freezed,
    Object? createdBy = freezed,
    Object? attachments = null,
  }) {
    return _then(_$TaskImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      deadline: null == deadline
          ? _value.deadline
          : deadline // ignore: cast_nullable_to_non_nullable
              as DateTime,
      priority: null == priority
          ? _value.priority
          : priority // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      points: null == points
          ? _value.points
          : points // ignore: cast_nullable_to_non_nullable
              as int,
      requiresApproval: null == requiresApproval
          ? _value.requiresApproval
          : requiresApproval // ignore: cast_nullable_to_non_nullable
              as bool,
      isRecurring: null == isRecurring
          ? _value.isRecurring
          : isRecurring // ignore: cast_nullable_to_non_nullable
              as bool,
      recurrenceRule: freezed == recurrenceRule
          ? _value.recurrenceRule
          : recurrenceRule // ignore: cast_nullable_to_non_nullable
              as String?,
      rotationType: freezed == rotationType
          ? _value.rotationType
          : rotationType // ignore: cast_nullable_to_non_nullable
              as String?,
      weight: null == weight
          ? _value.weight
          : weight // ignore: cast_nullable_to_non_nullable
              as int,
      wasClaimedFromPool: null == wasClaimedFromPool
          ? _value.wasClaimedFromPool
          : wasClaimedFromPool // ignore: cast_nullable_to_non_nullable
              as bool,
      rejectionReason: freezed == rejectionReason
          ? _value.rejectionReason
          : rejectionReason // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      completedAt: freezed == completedAt
          ? _value.completedAt
          : completedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      groupId: null == groupId
          ? _value.groupId
          : groupId // ignore: cast_nullable_to_non_nullable
              as String,
      createdById: null == createdById
          ? _value.createdById
          : createdById // ignore: cast_nullable_to_non_nullable
              as String,
      assigneeId: freezed == assigneeId
          ? _value.assigneeId
          : assigneeId // ignore: cast_nullable_to_non_nullable
              as String?,
      assignee: freezed == assignee
          ? _value.assignee
          : assignee // ignore: cast_nullable_to_non_nullable
              as GroupMemberUser?,
      createdBy: freezed == createdBy
          ? _value.createdBy
          : createdBy // ignore: cast_nullable_to_non_nullable
              as GroupMemberUser?,
      attachments: null == attachments
          ? _value._attachments
          : attachments // ignore: cast_nullable_to_non_nullable
              as List<TaskAttachment>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$TaskImpl implements _Task {
  const _$TaskImpl(
      {required this.id,
      required this.title,
      this.description,
      required this.deadline,
      required this.priority,
      required this.status,
      required this.points,
      required this.requiresApproval,
      required this.isRecurring,
      this.recurrenceRule,
      this.rotationType,
      required this.weight,
      required this.wasClaimedFromPool,
      this.rejectionReason,
      required this.createdAt,
      this.completedAt,
      required this.groupId,
      required this.createdById,
      this.assigneeId,
      this.assignee,
      this.createdBy,
      final List<TaskAttachment> attachments = const []})
      : _attachments = attachments;

  factory _$TaskImpl.fromJson(Map<String, dynamic> json) =>
      _$$TaskImplFromJson(json);

  @override
  final String id;
  @override
  final String title;
  @override
  final String? description;
  @override
  final DateTime deadline;
  @override
  final String priority;
  @override
  final String status;
  @override
  final int points;
  @override
  final bool requiresApproval;
  @override
  final bool isRecurring;
  @override
  final String? recurrenceRule;
  @override
  final String? rotationType;
  @override
  final int weight;
  @override
  final bool wasClaimedFromPool;
  @override
  final String? rejectionReason;
  @override
  final DateTime createdAt;
  @override
  final DateTime? completedAt;
  @override
  final String groupId;
  @override
  final String createdById;
  @override
  final String? assigneeId;
  @override
  final GroupMemberUser? assignee;
  @override
  final GroupMemberUser? createdBy;
  final List<TaskAttachment> _attachments;
  @override
  @JsonKey()
  List<TaskAttachment> get attachments {
    if (_attachments is EqualUnmodifiableListView) return _attachments;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_attachments);
  }

  @override
  String toString() {
    return 'Task(id: $id, title: $title, description: $description, deadline: $deadline, priority: $priority, status: $status, points: $points, requiresApproval: $requiresApproval, isRecurring: $isRecurring, recurrenceRule: $recurrenceRule, rotationType: $rotationType, weight: $weight, wasClaimedFromPool: $wasClaimedFromPool, rejectionReason: $rejectionReason, createdAt: $createdAt, completedAt: $completedAt, groupId: $groupId, createdById: $createdById, assigneeId: $assigneeId, assignee: $assignee, createdBy: $createdBy, attachments: $attachments)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TaskImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.deadline, deadline) ||
                other.deadline == deadline) &&
            (identical(other.priority, priority) ||
                other.priority == priority) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.points, points) || other.points == points) &&
            (identical(other.requiresApproval, requiresApproval) ||
                other.requiresApproval == requiresApproval) &&
            (identical(other.isRecurring, isRecurring) ||
                other.isRecurring == isRecurring) &&
            (identical(other.recurrenceRule, recurrenceRule) ||
                other.recurrenceRule == recurrenceRule) &&
            (identical(other.rotationType, rotationType) ||
                other.rotationType == rotationType) &&
            (identical(other.weight, weight) || other.weight == weight) &&
            (identical(other.wasClaimedFromPool, wasClaimedFromPool) ||
                other.wasClaimedFromPool == wasClaimedFromPool) &&
            (identical(other.rejectionReason, rejectionReason) ||
                other.rejectionReason == rejectionReason) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.completedAt, completedAt) ||
                other.completedAt == completedAt) &&
            (identical(other.groupId, groupId) || other.groupId == groupId) &&
            (identical(other.createdById, createdById) ||
                other.createdById == createdById) &&
            (identical(other.assigneeId, assigneeId) ||
                other.assigneeId == assigneeId) &&
            (identical(other.assignee, assignee) ||
                other.assignee == assignee) &&
            (identical(other.createdBy, createdBy) ||
                other.createdBy == createdBy) &&
            const DeepCollectionEquality()
                .equals(other._attachments, _attachments));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hashAll([
        runtimeType,
        id,
        title,
        description,
        deadline,
        priority,
        status,
        points,
        requiresApproval,
        isRecurring,
        recurrenceRule,
        rotationType,
        weight,
        wasClaimedFromPool,
        rejectionReason,
        createdAt,
        completedAt,
        groupId,
        createdById,
        assigneeId,
        assignee,
        createdBy,
        const DeepCollectionEquality().hash(_attachments)
      ]);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$TaskImplCopyWith<_$TaskImpl> get copyWith =>
      __$$TaskImplCopyWithImpl<_$TaskImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TaskImplToJson(
      this,
    );
  }
}

abstract class _Task implements Task {
  const factory _Task(
      {required final String id,
      required final String title,
      final String? description,
      required final DateTime deadline,
      required final String priority,
      required final String status,
      required final int points,
      required final bool requiresApproval,
      required final bool isRecurring,
      final String? recurrenceRule,
      final String? rotationType,
      required final int weight,
      required final bool wasClaimedFromPool,
      final String? rejectionReason,
      required final DateTime createdAt,
      final DateTime? completedAt,
      required final String groupId,
      required final String createdById,
      final String? assigneeId,
      final GroupMemberUser? assignee,
      final GroupMemberUser? createdBy,
      final List<TaskAttachment> attachments}) = _$TaskImpl;

  factory _Task.fromJson(Map<String, dynamic> json) = _$TaskImpl.fromJson;

  @override
  String get id;
  @override
  String get title;
  @override
  String? get description;
  @override
  DateTime get deadline;
  @override
  String get priority;
  @override
  String get status;
  @override
  int get points;
  @override
  bool get requiresApproval;
  @override
  bool get isRecurring;
  @override
  String? get recurrenceRule;
  @override
  String? get rotationType;
  @override
  int get weight;
  @override
  bool get wasClaimedFromPool;
  @override
  String? get rejectionReason;
  @override
  DateTime get createdAt;
  @override
  DateTime? get completedAt;
  @override
  String get groupId;
  @override
  String get createdById;
  @override
  String? get assigneeId;
  @override
  GroupMemberUser? get assignee;
  @override
  GroupMemberUser? get createdBy;
  @override
  List<TaskAttachment> get attachments;
  @override
  @JsonKey(ignore: true)
  _$$TaskImplCopyWith<_$TaskImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
