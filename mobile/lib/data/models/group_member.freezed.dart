// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'group_member.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

GroupMemberUser _$GroupMemberUserFromJson(Map<String, dynamic> json) {
  return _GroupMemberUser.fromJson(json);
}

/// @nodoc
mixin _$GroupMemberUser {
  String get id => throw _privateConstructorUsedError;
  String get username => throw _privateConstructorUsedError;
  String? get avatarUrl => throw _privateConstructorUsedError;
  bool get isAway => throw _privateConstructorUsedError;
  DateTime? get awayUntil => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $GroupMemberUserCopyWith<GroupMemberUser> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GroupMemberUserCopyWith<$Res> {
  factory $GroupMemberUserCopyWith(
          GroupMemberUser value, $Res Function(GroupMemberUser) then) =
      _$GroupMemberUserCopyWithImpl<$Res, GroupMemberUser>;
  @useResult
  $Res call(
      {String id,
      String username,
      String? avatarUrl,
      bool isAway,
      DateTime? awayUntil});
}

/// @nodoc
class _$GroupMemberUserCopyWithImpl<$Res, $Val extends GroupMemberUser>
    implements $GroupMemberUserCopyWith<$Res> {
  _$GroupMemberUserCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? username = null,
    Object? avatarUrl = freezed,
    Object? isAway = null,
    Object? awayUntil = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      username: null == username
          ? _value.username
          : username // ignore: cast_nullable_to_non_nullable
              as String,
      avatarUrl: freezed == avatarUrl
          ? _value.avatarUrl
          : avatarUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      isAway: null == isAway
          ? _value.isAway
          : isAway // ignore: cast_nullable_to_non_nullable
              as bool,
      awayUntil: freezed == awayUntil
          ? _value.awayUntil
          : awayUntil // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$GroupMemberUserImplCopyWith<$Res>
    implements $GroupMemberUserCopyWith<$Res> {
  factory _$$GroupMemberUserImplCopyWith(_$GroupMemberUserImpl value,
          $Res Function(_$GroupMemberUserImpl) then) =
      __$$GroupMemberUserImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String username,
      String? avatarUrl,
      bool isAway,
      DateTime? awayUntil});
}

/// @nodoc
class __$$GroupMemberUserImplCopyWithImpl<$Res>
    extends _$GroupMemberUserCopyWithImpl<$Res, _$GroupMemberUserImpl>
    implements _$$GroupMemberUserImplCopyWith<$Res> {
  __$$GroupMemberUserImplCopyWithImpl(
      _$GroupMemberUserImpl _value, $Res Function(_$GroupMemberUserImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? username = null,
    Object? avatarUrl = freezed,
    Object? isAway = null,
    Object? awayUntil = freezed,
  }) {
    return _then(_$GroupMemberUserImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      username: null == username
          ? _value.username
          : username // ignore: cast_nullable_to_non_nullable
              as String,
      avatarUrl: freezed == avatarUrl
          ? _value.avatarUrl
          : avatarUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      isAway: null == isAway
          ? _value.isAway
          : isAway // ignore: cast_nullable_to_non_nullable
              as bool,
      awayUntil: freezed == awayUntil
          ? _value.awayUntil
          : awayUntil // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$GroupMemberUserImpl implements _GroupMemberUser {
  const _$GroupMemberUserImpl(
      {required this.id,
      required this.username,
      this.avatarUrl,
      this.isAway = false,
      this.awayUntil});

  factory _$GroupMemberUserImpl.fromJson(Map<String, dynamic> json) =>
      _$$GroupMemberUserImplFromJson(json);

  @override
  final String id;
  @override
  final String username;
  @override
  final String? avatarUrl;
  @override
  @JsonKey()
  final bool isAway;
  @override
  final DateTime? awayUntil;

  @override
  String toString() {
    return 'GroupMemberUser(id: $id, username: $username, avatarUrl: $avatarUrl, isAway: $isAway, awayUntil: $awayUntil)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GroupMemberUserImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.username, username) ||
                other.username == username) &&
            (identical(other.avatarUrl, avatarUrl) ||
                other.avatarUrl == avatarUrl) &&
            (identical(other.isAway, isAway) || other.isAway == isAway) &&
            (identical(other.awayUntil, awayUntil) ||
                other.awayUntil == awayUntil));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode =>
      Object.hash(runtimeType, id, username, avatarUrl, isAway, awayUntil);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$GroupMemberUserImplCopyWith<_$GroupMemberUserImpl> get copyWith =>
      __$$GroupMemberUserImplCopyWithImpl<_$GroupMemberUserImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$GroupMemberUserImplToJson(
      this,
    );
  }
}

abstract class _GroupMemberUser implements GroupMemberUser {
  const factory _GroupMemberUser(
      {required final String id,
      required final String username,
      final String? avatarUrl,
      final bool isAway,
      final DateTime? awayUntil}) = _$GroupMemberUserImpl;

  factory _GroupMemberUser.fromJson(Map<String, dynamic> json) =
      _$GroupMemberUserImpl.fromJson;

  @override
  String get id;
  @override
  String get username;
  @override
  String? get avatarUrl;
  @override
  bool get isAway;
  @override
  DateTime? get awayUntil;
  @override
  @JsonKey(ignore: true)
  _$$GroupMemberUserImplCopyWith<_$GroupMemberUserImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

GroupMember _$GroupMemberFromJson(Map<String, dynamic> json) {
  return _GroupMember.fromJson(json);
}

/// @nodoc
mixin _$GroupMember {
  String get id => throw _privateConstructorUsedError;
  String get userId => throw _privateConstructorUsedError;
  String get groupId => throw _privateConstructorUsedError;
  String get role => throw _privateConstructorUsedError;
  DateTime get joinedAt => throw _privateConstructorUsedError;
  DateTime get roleChangedAt => throw _privateConstructorUsedError;
  GroupMemberUser get user => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $GroupMemberCopyWith<GroupMember> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GroupMemberCopyWith<$Res> {
  factory $GroupMemberCopyWith(
          GroupMember value, $Res Function(GroupMember) then) =
      _$GroupMemberCopyWithImpl<$Res, GroupMember>;
  @useResult
  $Res call(
      {String id,
      String userId,
      String groupId,
      String role,
      DateTime joinedAt,
      DateTime roleChangedAt,
      GroupMemberUser user});

  $GroupMemberUserCopyWith<$Res> get user;
}

/// @nodoc
class _$GroupMemberCopyWithImpl<$Res, $Val extends GroupMember>
    implements $GroupMemberCopyWith<$Res> {
  _$GroupMemberCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? groupId = null,
    Object? role = null,
    Object? joinedAt = null,
    Object? roleChangedAt = null,
    Object? user = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      groupId: null == groupId
          ? _value.groupId
          : groupId // ignore: cast_nullable_to_non_nullable
              as String,
      role: null == role
          ? _value.role
          : role // ignore: cast_nullable_to_non_nullable
              as String,
      joinedAt: null == joinedAt
          ? _value.joinedAt
          : joinedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      roleChangedAt: null == roleChangedAt
          ? _value.roleChangedAt
          : roleChangedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      user: null == user
          ? _value.user
          : user // ignore: cast_nullable_to_non_nullable
              as GroupMemberUser,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $GroupMemberUserCopyWith<$Res> get user {
    return $GroupMemberUserCopyWith<$Res>(_value.user, (value) {
      return _then(_value.copyWith(user: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$GroupMemberImplCopyWith<$Res>
    implements $GroupMemberCopyWith<$Res> {
  factory _$$GroupMemberImplCopyWith(
          _$GroupMemberImpl value, $Res Function(_$GroupMemberImpl) then) =
      __$$GroupMemberImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String userId,
      String groupId,
      String role,
      DateTime joinedAt,
      DateTime roleChangedAt,
      GroupMemberUser user});

  @override
  $GroupMemberUserCopyWith<$Res> get user;
}

/// @nodoc
class __$$GroupMemberImplCopyWithImpl<$Res>
    extends _$GroupMemberCopyWithImpl<$Res, _$GroupMemberImpl>
    implements _$$GroupMemberImplCopyWith<$Res> {
  __$$GroupMemberImplCopyWithImpl(
      _$GroupMemberImpl _value, $Res Function(_$GroupMemberImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? groupId = null,
    Object? role = null,
    Object? joinedAt = null,
    Object? roleChangedAt = null,
    Object? user = null,
  }) {
    return _then(_$GroupMemberImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      groupId: null == groupId
          ? _value.groupId
          : groupId // ignore: cast_nullable_to_non_nullable
              as String,
      role: null == role
          ? _value.role
          : role // ignore: cast_nullable_to_non_nullable
              as String,
      joinedAt: null == joinedAt
          ? _value.joinedAt
          : joinedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      roleChangedAt: null == roleChangedAt
          ? _value.roleChangedAt
          : roleChangedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      user: null == user
          ? _value.user
          : user // ignore: cast_nullable_to_non_nullable
              as GroupMemberUser,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$GroupMemberImpl implements _GroupMember {
  const _$GroupMemberImpl(
      {required this.id,
      required this.userId,
      required this.groupId,
      required this.role,
      required this.joinedAt,
      required this.roleChangedAt,
      required this.user});

  factory _$GroupMemberImpl.fromJson(Map<String, dynamic> json) =>
      _$$GroupMemberImplFromJson(json);

  @override
  final String id;
  @override
  final String userId;
  @override
  final String groupId;
  @override
  final String role;
  @override
  final DateTime joinedAt;
  @override
  final DateTime roleChangedAt;
  @override
  final GroupMemberUser user;

  @override
  String toString() {
    return 'GroupMember(id: $id, userId: $userId, groupId: $groupId, role: $role, joinedAt: $joinedAt, roleChangedAt: $roleChangedAt, user: $user)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GroupMemberImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.groupId, groupId) || other.groupId == groupId) &&
            (identical(other.role, role) || other.role == role) &&
            (identical(other.joinedAt, joinedAt) ||
                other.joinedAt == joinedAt) &&
            (identical(other.roleChangedAt, roleChangedAt) ||
                other.roleChangedAt == roleChangedAt) &&
            (identical(other.user, user) || other.user == user));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType, id, userId, groupId, role, joinedAt, roleChangedAt, user);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$GroupMemberImplCopyWith<_$GroupMemberImpl> get copyWith =>
      __$$GroupMemberImplCopyWithImpl<_$GroupMemberImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$GroupMemberImplToJson(
      this,
    );
  }
}

abstract class _GroupMember implements GroupMember {
  const factory _GroupMember(
      {required final String id,
      required final String userId,
      required final String groupId,
      required final String role,
      required final DateTime joinedAt,
      required final DateTime roleChangedAt,
      required final GroupMemberUser user}) = _$GroupMemberImpl;

  factory _GroupMember.fromJson(Map<String, dynamic> json) =
      _$GroupMemberImpl.fromJson;

  @override
  String get id;
  @override
  String get userId;
  @override
  String get groupId;
  @override
  String get role;
  @override
  DateTime get joinedAt;
  @override
  DateTime get roleChangedAt;
  @override
  GroupMemberUser get user;
  @override
  @JsonKey(ignore: true)
  _$$GroupMemberImplCopyWith<_$GroupMemberImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
