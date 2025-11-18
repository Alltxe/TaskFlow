// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'create_task_request.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

CreateTaskRequest _$CreateTaskRequestFromJson(Map<String, dynamic> json) {
  return _CreateTaskRequest.fromJson(json);
}

/// @nodoc
mixin _$CreateTaskRequest {
  String get groupId => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  DateTime get deadline => throw _privateConstructorUsedError;
  String get priority =>
      throw _privateConstructorUsedError; // LOW, MEDIUM, HIGH
  int get points => throw _privateConstructorUsedError;
  bool? get requiresApproval => throw _privateConstructorUsedError;
  String? get assigneeId => throw _privateConstructorUsedError;
  bool? get isRecurring => throw _privateConstructorUsedError;
  String? get recurrenceRule => throw _privateConstructorUsedError;
  String? get rotationType => throw _privateConstructorUsedError;
  int? get weight => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $CreateTaskRequestCopyWith<CreateTaskRequest> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CreateTaskRequestCopyWith<$Res> {
  factory $CreateTaskRequestCopyWith(
          CreateTaskRequest value, $Res Function(CreateTaskRequest) then) =
      _$CreateTaskRequestCopyWithImpl<$Res, CreateTaskRequest>;
  @useResult
  $Res call(
      {String groupId,
      String title,
      String? description,
      DateTime deadline,
      String priority,
      int points,
      bool? requiresApproval,
      String? assigneeId,
      bool? isRecurring,
      String? recurrenceRule,
      String? rotationType,
      int? weight});
}

/// @nodoc
class _$CreateTaskRequestCopyWithImpl<$Res, $Val extends CreateTaskRequest>
    implements $CreateTaskRequestCopyWith<$Res> {
  _$CreateTaskRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? groupId = null,
    Object? title = null,
    Object? description = freezed,
    Object? deadline = null,
    Object? priority = null,
    Object? points = null,
    Object? requiresApproval = freezed,
    Object? assigneeId = freezed,
    Object? isRecurring = freezed,
    Object? recurrenceRule = freezed,
    Object? rotationType = freezed,
    Object? weight = freezed,
  }) {
    return _then(_value.copyWith(
      groupId: null == groupId
          ? _value.groupId
          : groupId // ignore: cast_nullable_to_non_nullable
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
      points: null == points
          ? _value.points
          : points // ignore: cast_nullable_to_non_nullable
              as int,
      requiresApproval: freezed == requiresApproval
          ? _value.requiresApproval
          : requiresApproval // ignore: cast_nullable_to_non_nullable
              as bool?,
      assigneeId: freezed == assigneeId
          ? _value.assigneeId
          : assigneeId // ignore: cast_nullable_to_non_nullable
              as String?,
      isRecurring: freezed == isRecurring
          ? _value.isRecurring
          : isRecurring // ignore: cast_nullable_to_non_nullable
              as bool?,
      recurrenceRule: freezed == recurrenceRule
          ? _value.recurrenceRule
          : recurrenceRule // ignore: cast_nullable_to_non_nullable
              as String?,
      rotationType: freezed == rotationType
          ? _value.rotationType
          : rotationType // ignore: cast_nullable_to_non_nullable
              as String?,
      weight: freezed == weight
          ? _value.weight
          : weight // ignore: cast_nullable_to_non_nullable
              as int?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$CreateTaskRequestImplCopyWith<$Res>
    implements $CreateTaskRequestCopyWith<$Res> {
  factory _$$CreateTaskRequestImplCopyWith(_$CreateTaskRequestImpl value,
          $Res Function(_$CreateTaskRequestImpl) then) =
      __$$CreateTaskRequestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String groupId,
      String title,
      String? description,
      DateTime deadline,
      String priority,
      int points,
      bool? requiresApproval,
      String? assigneeId,
      bool? isRecurring,
      String? recurrenceRule,
      String? rotationType,
      int? weight});
}

/// @nodoc
class __$$CreateTaskRequestImplCopyWithImpl<$Res>
    extends _$CreateTaskRequestCopyWithImpl<$Res, _$CreateTaskRequestImpl>
    implements _$$CreateTaskRequestImplCopyWith<$Res> {
  __$$CreateTaskRequestImplCopyWithImpl(_$CreateTaskRequestImpl _value,
      $Res Function(_$CreateTaskRequestImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? groupId = null,
    Object? title = null,
    Object? description = freezed,
    Object? deadline = null,
    Object? priority = null,
    Object? points = null,
    Object? requiresApproval = freezed,
    Object? assigneeId = freezed,
    Object? isRecurring = freezed,
    Object? recurrenceRule = freezed,
    Object? rotationType = freezed,
    Object? weight = freezed,
  }) {
    return _then(_$CreateTaskRequestImpl(
      groupId: null == groupId
          ? _value.groupId
          : groupId // ignore: cast_nullable_to_non_nullable
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
      points: null == points
          ? _value.points
          : points // ignore: cast_nullable_to_non_nullable
              as int,
      requiresApproval: freezed == requiresApproval
          ? _value.requiresApproval
          : requiresApproval // ignore: cast_nullable_to_non_nullable
              as bool?,
      assigneeId: freezed == assigneeId
          ? _value.assigneeId
          : assigneeId // ignore: cast_nullable_to_non_nullable
              as String?,
      isRecurring: freezed == isRecurring
          ? _value.isRecurring
          : isRecurring // ignore: cast_nullable_to_non_nullable
              as bool?,
      recurrenceRule: freezed == recurrenceRule
          ? _value.recurrenceRule
          : recurrenceRule // ignore: cast_nullable_to_non_nullable
              as String?,
      rotationType: freezed == rotationType
          ? _value.rotationType
          : rotationType // ignore: cast_nullable_to_non_nullable
              as String?,
      weight: freezed == weight
          ? _value.weight
          : weight // ignore: cast_nullable_to_non_nullable
              as int?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$CreateTaskRequestImpl implements _CreateTaskRequest {
  const _$CreateTaskRequestImpl(
      {required this.groupId,
      required this.title,
      this.description,
      required this.deadline,
      required this.priority,
      required this.points,
      this.requiresApproval,
      this.assigneeId,
      this.isRecurring,
      this.recurrenceRule,
      this.rotationType,
      this.weight});

  factory _$CreateTaskRequestImpl.fromJson(Map<String, dynamic> json) =>
      _$$CreateTaskRequestImplFromJson(json);

  @override
  final String groupId;
  @override
  final String title;
  @override
  final String? description;
  @override
  final DateTime deadline;
  @override
  final String priority;
// LOW, MEDIUM, HIGH
  @override
  final int points;
  @override
  final bool? requiresApproval;
  @override
  final String? assigneeId;
  @override
  final bool? isRecurring;
  @override
  final String? recurrenceRule;
  @override
  final String? rotationType;
  @override
  final int? weight;

  @override
  String toString() {
    return 'CreateTaskRequest(groupId: $groupId, title: $title, description: $description, deadline: $deadline, priority: $priority, points: $points, requiresApproval: $requiresApproval, assigneeId: $assigneeId, isRecurring: $isRecurring, recurrenceRule: $recurrenceRule, rotationType: $rotationType, weight: $weight)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CreateTaskRequestImpl &&
            (identical(other.groupId, groupId) || other.groupId == groupId) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.deadline, deadline) ||
                other.deadline == deadline) &&
            (identical(other.priority, priority) ||
                other.priority == priority) &&
            (identical(other.points, points) || other.points == points) &&
            (identical(other.requiresApproval, requiresApproval) ||
                other.requiresApproval == requiresApproval) &&
            (identical(other.assigneeId, assigneeId) ||
                other.assigneeId == assigneeId) &&
            (identical(other.isRecurring, isRecurring) ||
                other.isRecurring == isRecurring) &&
            (identical(other.recurrenceRule, recurrenceRule) ||
                other.recurrenceRule == recurrenceRule) &&
            (identical(other.rotationType, rotationType) ||
                other.rotationType == rotationType) &&
            (identical(other.weight, weight) || other.weight == weight));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      groupId,
      title,
      description,
      deadline,
      priority,
      points,
      requiresApproval,
      assigneeId,
      isRecurring,
      recurrenceRule,
      rotationType,
      weight);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$CreateTaskRequestImplCopyWith<_$CreateTaskRequestImpl> get copyWith =>
      __$$CreateTaskRequestImplCopyWithImpl<_$CreateTaskRequestImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CreateTaskRequestImplToJson(
      this,
    );
  }
}

abstract class _CreateTaskRequest implements CreateTaskRequest {
  const factory _CreateTaskRequest(
      {required final String groupId,
      required final String title,
      final String? description,
      required final DateTime deadline,
      required final String priority,
      required final int points,
      final bool? requiresApproval,
      final String? assigneeId,
      final bool? isRecurring,
      final String? recurrenceRule,
      final String? rotationType,
      final int? weight}) = _$CreateTaskRequestImpl;

  factory _CreateTaskRequest.fromJson(Map<String, dynamic> json) =
      _$CreateTaskRequestImpl.fromJson;

  @override
  String get groupId;
  @override
  String get title;
  @override
  String? get description;
  @override
  DateTime get deadline;
  @override
  String get priority;
  @override // LOW, MEDIUM, HIGH
  int get points;
  @override
  bool? get requiresApproval;
  @override
  String? get assigneeId;
  @override
  bool? get isRecurring;
  @override
  String? get recurrenceRule;
  @override
  String? get rotationType;
  @override
  int? get weight;
  @override
  @JsonKey(ignore: true)
  _$$CreateTaskRequestImplCopyWith<_$CreateTaskRequestImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
