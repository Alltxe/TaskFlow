// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'group_summary.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

GroupSummary _$GroupSummaryFromJson(Map<String, dynamic> json) {
  return _GroupSummary.fromJson(json);
}

/// @nodoc
mixin _$GroupSummary {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  String get role =>
      throw _privateConstructorUsedError; // 'admin' or 'participant'
  bool get gamificationEnabled => throw _privateConstructorUsedError;
  DateTime get joinedAt => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $GroupSummaryCopyWith<GroupSummary> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GroupSummaryCopyWith<$Res> {
  factory $GroupSummaryCopyWith(
          GroupSummary value, $Res Function(GroupSummary) then) =
      _$GroupSummaryCopyWithImpl<$Res, GroupSummary>;
  @useResult
  $Res call(
      {String id,
      String name,
      String? description,
      String role,
      bool gamificationEnabled,
      DateTime joinedAt});
}

/// @nodoc
class _$GroupSummaryCopyWithImpl<$Res, $Val extends GroupSummary>
    implements $GroupSummaryCopyWith<$Res> {
  _$GroupSummaryCopyWithImpl(this._value, this._then);

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
    Object? role = null,
    Object? gamificationEnabled = null,
    Object? joinedAt = null,
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
      role: null == role
          ? _value.role
          : role // ignore: cast_nullable_to_non_nullable
              as String,
      gamificationEnabled: null == gamificationEnabled
          ? _value.gamificationEnabled
          : gamificationEnabled // ignore: cast_nullable_to_non_nullable
              as bool,
      joinedAt: null == joinedAt
          ? _value.joinedAt
          : joinedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$GroupSummaryImplCopyWith<$Res>
    implements $GroupSummaryCopyWith<$Res> {
  factory _$$GroupSummaryImplCopyWith(
          _$GroupSummaryImpl value, $Res Function(_$GroupSummaryImpl) then) =
      __$$GroupSummaryImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String name,
      String? description,
      String role,
      bool gamificationEnabled,
      DateTime joinedAt});
}

/// @nodoc
class __$$GroupSummaryImplCopyWithImpl<$Res>
    extends _$GroupSummaryCopyWithImpl<$Res, _$GroupSummaryImpl>
    implements _$$GroupSummaryImplCopyWith<$Res> {
  __$$GroupSummaryImplCopyWithImpl(
      _$GroupSummaryImpl _value, $Res Function(_$GroupSummaryImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? description = freezed,
    Object? role = null,
    Object? gamificationEnabled = null,
    Object? joinedAt = null,
  }) {
    return _then(_$GroupSummaryImpl(
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
      role: null == role
          ? _value.role
          : role // ignore: cast_nullable_to_non_nullable
              as String,
      gamificationEnabled: null == gamificationEnabled
          ? _value.gamificationEnabled
          : gamificationEnabled // ignore: cast_nullable_to_non_nullable
              as bool,
      joinedAt: null == joinedAt
          ? _value.joinedAt
          : joinedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$GroupSummaryImpl implements _GroupSummary {
  const _$GroupSummaryImpl(
      {required this.id,
      required this.name,
      this.description,
      required this.role,
      required this.gamificationEnabled,
      required this.joinedAt});

  factory _$GroupSummaryImpl.fromJson(Map<String, dynamic> json) =>
      _$$GroupSummaryImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  final String? description;
  @override
  final String role;
// 'admin' or 'participant'
  @override
  final bool gamificationEnabled;
  @override
  final DateTime joinedAt;

  @override
  String toString() {
    return 'GroupSummary(id: $id, name: $name, description: $description, role: $role, gamificationEnabled: $gamificationEnabled, joinedAt: $joinedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GroupSummaryImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.role, role) || other.role == role) &&
            (identical(other.gamificationEnabled, gamificationEnabled) ||
                other.gamificationEnabled == gamificationEnabled) &&
            (identical(other.joinedAt, joinedAt) ||
                other.joinedAt == joinedAt));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType, id, name, description, role, gamificationEnabled, joinedAt);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$GroupSummaryImplCopyWith<_$GroupSummaryImpl> get copyWith =>
      __$$GroupSummaryImplCopyWithImpl<_$GroupSummaryImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$GroupSummaryImplToJson(
      this,
    );
  }
}

abstract class _GroupSummary implements GroupSummary {
  const factory _GroupSummary(
      {required final String id,
      required final String name,
      final String? description,
      required final String role,
      required final bool gamificationEnabled,
      required final DateTime joinedAt}) = _$GroupSummaryImpl;

  factory _GroupSummary.fromJson(Map<String, dynamic> json) =
      _$GroupSummaryImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  String? get description;
  @override
  String get role;
  @override // 'admin' or 'participant'
  bool get gamificationEnabled;
  @override
  DateTime get joinedAt;
  @override
  @JsonKey(ignore: true)
  _$$GroupSummaryImplCopyWith<_$GroupSummaryImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
