// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'create_group_request.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

CreateGroupRequest _$CreateGroupRequestFromJson(Map<String, dynamic> json) {
  return _CreateGroupRequest.fromJson(json);
}

/// @nodoc
mixin _$CreateGroupRequest {
  String get name => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  bool get requiresApproval => throw _privateConstructorUsedError;
  String get rotationType => throw _privateConstructorUsedError;
  bool get gamificationEnabled => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $CreateGroupRequestCopyWith<CreateGroupRequest> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CreateGroupRequestCopyWith<$Res> {
  factory $CreateGroupRequestCopyWith(
          CreateGroupRequest value, $Res Function(CreateGroupRequest) then) =
      _$CreateGroupRequestCopyWithImpl<$Res, CreateGroupRequest>;
  @useResult
  $Res call(
      {String name,
      String? description,
      bool requiresApproval,
      String rotationType,
      bool gamificationEnabled});
}

/// @nodoc
class _$CreateGroupRequestCopyWithImpl<$Res, $Val extends CreateGroupRequest>
    implements $CreateGroupRequestCopyWith<$Res> {
  _$CreateGroupRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? description = freezed,
    Object? requiresApproval = null,
    Object? rotationType = null,
    Object? gamificationEnabled = null,
  }) {
    return _then(_value.copyWith(
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
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
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$CreateGroupRequestImplCopyWith<$Res>
    implements $CreateGroupRequestCopyWith<$Res> {
  factory _$$CreateGroupRequestImplCopyWith(_$CreateGroupRequestImpl value,
          $Res Function(_$CreateGroupRequestImpl) then) =
      __$$CreateGroupRequestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String name,
      String? description,
      bool requiresApproval,
      String rotationType,
      bool gamificationEnabled});
}

/// @nodoc
class __$$CreateGroupRequestImplCopyWithImpl<$Res>
    extends _$CreateGroupRequestCopyWithImpl<$Res, _$CreateGroupRequestImpl>
    implements _$$CreateGroupRequestImplCopyWith<$Res> {
  __$$CreateGroupRequestImplCopyWithImpl(_$CreateGroupRequestImpl _value,
      $Res Function(_$CreateGroupRequestImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? description = freezed,
    Object? requiresApproval = null,
    Object? rotationType = null,
    Object? gamificationEnabled = null,
  }) {
    return _then(_$CreateGroupRequestImpl(
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
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
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$CreateGroupRequestImpl implements _CreateGroupRequest {
  const _$CreateGroupRequestImpl(
      {required this.name,
      this.description,
      this.requiresApproval = true,
      this.rotationType = 'ROUND_ROBIN',
      this.gamificationEnabled = true});

  factory _$CreateGroupRequestImpl.fromJson(Map<String, dynamic> json) =>
      _$$CreateGroupRequestImplFromJson(json);

  @override
  final String name;
  @override
  final String? description;
  @override
  @JsonKey()
  final bool requiresApproval;
  @override
  @JsonKey()
  final String rotationType;
  @override
  @JsonKey()
  final bool gamificationEnabled;

  @override
  String toString() {
    return 'CreateGroupRequest(name: $name, description: $description, requiresApproval: $requiresApproval, rotationType: $rotationType, gamificationEnabled: $gamificationEnabled)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CreateGroupRequestImpl &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.requiresApproval, requiresApproval) ||
                other.requiresApproval == requiresApproval) &&
            (identical(other.rotationType, rotationType) ||
                other.rotationType == rotationType) &&
            (identical(other.gamificationEnabled, gamificationEnabled) ||
                other.gamificationEnabled == gamificationEnabled));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, name, description,
      requiresApproval, rotationType, gamificationEnabled);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$CreateGroupRequestImplCopyWith<_$CreateGroupRequestImpl> get copyWith =>
      __$$CreateGroupRequestImplCopyWithImpl<_$CreateGroupRequestImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CreateGroupRequestImplToJson(
      this,
    );
  }
}

abstract class _CreateGroupRequest implements CreateGroupRequest {
  const factory _CreateGroupRequest(
      {required final String name,
      final String? description,
      final bool requiresApproval,
      final String rotationType,
      final bool gamificationEnabled}) = _$CreateGroupRequestImpl;

  factory _CreateGroupRequest.fromJson(Map<String, dynamic> json) =
      _$CreateGroupRequestImpl.fromJson;

  @override
  String get name;
  @override
  String? get description;
  @override
  bool get requiresApproval;
  @override
  String get rotationType;
  @override
  bool get gamificationEnabled;
  @override
  @JsonKey(ignore: true)
  _$$CreateGroupRequestImplCopyWith<_$CreateGroupRequestImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
