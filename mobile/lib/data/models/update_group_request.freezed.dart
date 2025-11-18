// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'update_group_request.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

UpdateGroupRequest _$UpdateGroupRequestFromJson(Map<String, dynamic> json) {
  return _UpdateGroupRequest.fromJson(json);
}

/// @nodoc
mixin _$UpdateGroupRequest {
  String? get name => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  bool? get requiresApproval => throw _privateConstructorUsedError;
  String? get rotationType => throw _privateConstructorUsedError;
  bool? get gamificationEnabled => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $UpdateGroupRequestCopyWith<UpdateGroupRequest> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UpdateGroupRequestCopyWith<$Res> {
  factory $UpdateGroupRequestCopyWith(
          UpdateGroupRequest value, $Res Function(UpdateGroupRequest) then) =
      _$UpdateGroupRequestCopyWithImpl<$Res, UpdateGroupRequest>;
  @useResult
  $Res call(
      {String? name,
      String? description,
      bool? requiresApproval,
      String? rotationType,
      bool? gamificationEnabled});
}

/// @nodoc
class _$UpdateGroupRequestCopyWithImpl<$Res, $Val extends UpdateGroupRequest>
    implements $UpdateGroupRequestCopyWith<$Res> {
  _$UpdateGroupRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = freezed,
    Object? description = freezed,
    Object? requiresApproval = freezed,
    Object? rotationType = freezed,
    Object? gamificationEnabled = freezed,
  }) {
    return _then(_value.copyWith(
      name: freezed == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String?,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      requiresApproval: freezed == requiresApproval
          ? _value.requiresApproval
          : requiresApproval // ignore: cast_nullable_to_non_nullable
              as bool?,
      rotationType: freezed == rotationType
          ? _value.rotationType
          : rotationType // ignore: cast_nullable_to_non_nullable
              as String?,
      gamificationEnabled: freezed == gamificationEnabled
          ? _value.gamificationEnabled
          : gamificationEnabled // ignore: cast_nullable_to_non_nullable
              as bool?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$UpdateGroupRequestImplCopyWith<$Res>
    implements $UpdateGroupRequestCopyWith<$Res> {
  factory _$$UpdateGroupRequestImplCopyWith(_$UpdateGroupRequestImpl value,
          $Res Function(_$UpdateGroupRequestImpl) then) =
      __$$UpdateGroupRequestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String? name,
      String? description,
      bool? requiresApproval,
      String? rotationType,
      bool? gamificationEnabled});
}

/// @nodoc
class __$$UpdateGroupRequestImplCopyWithImpl<$Res>
    extends _$UpdateGroupRequestCopyWithImpl<$Res, _$UpdateGroupRequestImpl>
    implements _$$UpdateGroupRequestImplCopyWith<$Res> {
  __$$UpdateGroupRequestImplCopyWithImpl(_$UpdateGroupRequestImpl _value,
      $Res Function(_$UpdateGroupRequestImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = freezed,
    Object? description = freezed,
    Object? requiresApproval = freezed,
    Object? rotationType = freezed,
    Object? gamificationEnabled = freezed,
  }) {
    return _then(_$UpdateGroupRequestImpl(
      name: freezed == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String?,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      requiresApproval: freezed == requiresApproval
          ? _value.requiresApproval
          : requiresApproval // ignore: cast_nullable_to_non_nullable
              as bool?,
      rotationType: freezed == rotationType
          ? _value.rotationType
          : rotationType // ignore: cast_nullable_to_non_nullable
              as String?,
      gamificationEnabled: freezed == gamificationEnabled
          ? _value.gamificationEnabled
          : gamificationEnabled // ignore: cast_nullable_to_non_nullable
              as bool?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$UpdateGroupRequestImpl implements _UpdateGroupRequest {
  const _$UpdateGroupRequestImpl(
      {this.name,
      this.description,
      this.requiresApproval,
      this.rotationType,
      this.gamificationEnabled});

  factory _$UpdateGroupRequestImpl.fromJson(Map<String, dynamic> json) =>
      _$$UpdateGroupRequestImplFromJson(json);

  @override
  final String? name;
  @override
  final String? description;
  @override
  final bool? requiresApproval;
  @override
  final String? rotationType;
  @override
  final bool? gamificationEnabled;

  @override
  String toString() {
    return 'UpdateGroupRequest(name: $name, description: $description, requiresApproval: $requiresApproval, rotationType: $rotationType, gamificationEnabled: $gamificationEnabled)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UpdateGroupRequestImpl &&
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
  _$$UpdateGroupRequestImplCopyWith<_$UpdateGroupRequestImpl> get copyWith =>
      __$$UpdateGroupRequestImplCopyWithImpl<_$UpdateGroupRequestImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$UpdateGroupRequestImplToJson(
      this,
    );
  }
}

abstract class _UpdateGroupRequest implements UpdateGroupRequest {
  const factory _UpdateGroupRequest(
      {final String? name,
      final String? description,
      final bool? requiresApproval,
      final String? rotationType,
      final bool? gamificationEnabled}) = _$UpdateGroupRequestImpl;

  factory _UpdateGroupRequest.fromJson(Map<String, dynamic> json) =
      _$UpdateGroupRequestImpl.fromJson;

  @override
  String? get name;
  @override
  String? get description;
  @override
  bool? get requiresApproval;
  @override
  String? get rotationType;
  @override
  bool? get gamificationEnabled;
  @override
  @JsonKey(ignore: true)
  _$$UpdateGroupRequestImplCopyWith<_$UpdateGroupRequestImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
