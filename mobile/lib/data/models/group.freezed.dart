// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'group.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Group _$GroupFromJson(Map<String, dynamic> json) {
  return _Group.fromJson(json);
}

/// @nodoc
mixin _$Group {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  String get inviteToken => throw _privateConstructorUsedError;
  bool get requiresApproval => throw _privateConstructorUsedError;
  String get rotationType => throw _privateConstructorUsedError;
  bool get gamificationEnabled => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime get updatedAt => throw _privateConstructorUsedError;
  String get createdById => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $GroupCopyWith<Group> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GroupCopyWith<$Res> {
  factory $GroupCopyWith(Group value, $Res Function(Group) then) =
      _$GroupCopyWithImpl<$Res, Group>;
  @useResult
  $Res call(
      {String id,
      String name,
      String? description,
      String inviteToken,
      bool requiresApproval,
      String rotationType,
      bool gamificationEnabled,
      DateTime createdAt,
      DateTime updatedAt,
      String createdById});
}

/// @nodoc
class _$GroupCopyWithImpl<$Res, $Val extends Group>
    implements $GroupCopyWith<$Res> {
  _$GroupCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? description = freezed,
    Object? inviteToken = null,
    Object? requiresApproval = null,
    Object? rotationType = null,
    Object? gamificationEnabled = null,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? createdById = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      inviteToken: null == inviteToken
          ? _value.inviteToken
          : inviteToken // ignore: cast_nullable_to_non_nullable
              as String,
      requiresApproval: null == requiresApproval
          ? _value.requiresApproval
          : requiresApproval // ignore: cast_nullable_to_non_nullable
              as bool,
      rotationType: null == rotationType
          ? _value.rotationType
          : rotationType // ignore: cast_nullable_to_non_nullable
              as String,
      gamificationEnabled: null == gamificationEnabled
          ? _value.gamificationEnabled
          : gamificationEnabled // ignore: cast_nullable_to_non_nullable
              as bool,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      createdById: null == createdById
          ? _value.createdById
          : createdById // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$GroupImplCopyWith<$Res> implements $GroupCopyWith<$Res> {
  factory _$$GroupImplCopyWith(
          _$GroupImpl value, $Res Function(_$GroupImpl) then) =
      __$$GroupImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String name,
      String? description,
      String inviteToken,
      bool requiresApproval,
      String rotationType,
      bool gamificationEnabled,
      DateTime createdAt,
      DateTime updatedAt,
      String createdById});
}

/// @nodoc
class __$$GroupImplCopyWithImpl<$Res>
    extends _$GroupCopyWithImpl<$Res, _$GroupImpl>
    implements _$$GroupImplCopyWith<$Res> {
  __$$GroupImplCopyWithImpl(
      _$GroupImpl _value, $Res Function(_$GroupImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? description = freezed,
    Object? inviteToken = null,
    Object? requiresApproval = null,
    Object? rotationType = null,
    Object? gamificationEnabled = null,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? createdById = null,
  }) {
    return _then(_$GroupImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      inviteToken: null == inviteToken
          ? _value.inviteToken
          : inviteToken // ignore: cast_nullable_to_non_nullable
              as String,
      requiresApproval: null == requiresApproval
          ? _value.requiresApproval
          : requiresApproval // ignore: cast_nullable_to_non_nullable
              as bool,
      rotationType: null == rotationType
          ? _value.rotationType
          : rotationType // ignore: cast_nullable_to_non_nullable
              as String,
      gamificationEnabled: null == gamificationEnabled
          ? _value.gamificationEnabled
          : gamificationEnabled // ignore: cast_nullable_to_non_nullable
              as bool,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      createdById: null == createdById
          ? _value.createdById
          : createdById // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$GroupImpl implements _Group {
  const _$GroupImpl(
      {required this.id,
      required this.name,
      this.description,
      required this.inviteToken,
      required this.requiresApproval,
      required this.rotationType,
      required this.gamificationEnabled,
      required this.createdAt,
      required this.updatedAt,
      required this.createdById});

  factory _$GroupImpl.fromJson(Map<String, dynamic> json) =>
      _$$GroupImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  final String? description;
  @override
  final String inviteToken;
  @override
  final bool requiresApproval;
  @override
  final String rotationType;
  @override
  final bool gamificationEnabled;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;
  @override
  final String createdById;

  @override
  String toString() {
    return 'Group(id: $id, name: $name, description: $description, inviteToken: $inviteToken, requiresApproval: $requiresApproval, rotationType: $rotationType, gamificationEnabled: $gamificationEnabled, createdAt: $createdAt, updatedAt: $updatedAt, createdById: $createdById)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GroupImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.inviteToken, inviteToken) ||
                other.inviteToken == inviteToken) &&
            (identical(other.requiresApproval, requiresApproval) ||
                other.requiresApproval == requiresApproval) &&
            (identical(other.rotationType, rotationType) ||
                other.rotationType == rotationType) &&
            (identical(other.gamificationEnabled, gamificationEnabled) ||
                other.gamificationEnabled == gamificationEnabled) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.createdById, createdById) ||
                other.createdById == createdById));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      name,
      description,
      inviteToken,
      requiresApproval,
      rotationType,
      gamificationEnabled,
      createdAt,
      updatedAt,
      createdById);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$GroupImplCopyWith<_$GroupImpl> get copyWith =>
      __$$GroupImplCopyWithImpl<_$GroupImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$GroupImplToJson(
      this,
    );
  }
}

abstract class _Group implements Group {
  const factory _Group(
      {required final String id,
      required final String name,
      final String? description,
      required final String inviteToken,
      required final bool requiresApproval,
      required final String rotationType,
      required final bool gamificationEnabled,
      required final DateTime createdAt,
      required final DateTime updatedAt,
      required final String createdById}) = _$GroupImpl;

  factory _Group.fromJson(Map<String, dynamic> json) = _$GroupImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  String? get description;
  @override
  String get inviteToken;
  @override
  bool get requiresApproval;
  @override
  String get rotationType;
  @override
  bool get gamificationEnabled;
  @override
  DateTime get createdAt;
  @override
  DateTime get updatedAt;
  @override
  String get createdById;
  @override
  @JsonKey(ignore: true)
  _$$GroupImplCopyWith<_$GroupImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
