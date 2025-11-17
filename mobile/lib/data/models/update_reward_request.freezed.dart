// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'update_reward_request.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

UpdateRewardRequest _$UpdateRewardRequestFromJson(Map<String, dynamic> json) {
  return _UpdateRewardRequest.fromJson(json);
}

/// @nodoc
mixin _$UpdateRewardRequest {
  String? get name => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  int? get cost => throw _privateConstructorUsedError;
  bool? get isActive => throw _privateConstructorUsedError;
  String? get imageUrl => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $UpdateRewardRequestCopyWith<UpdateRewardRequest> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UpdateRewardRequestCopyWith<$Res> {
  factory $UpdateRewardRequestCopyWith(
          UpdateRewardRequest value, $Res Function(UpdateRewardRequest) then) =
      _$UpdateRewardRequestCopyWithImpl<$Res, UpdateRewardRequest>;
  @useResult
  $Res call(
      {String? name,
      String? description,
      int? cost,
      bool? isActive,
      String? imageUrl});
}

/// @nodoc
class _$UpdateRewardRequestCopyWithImpl<$Res, $Val extends UpdateRewardRequest>
    implements $UpdateRewardRequestCopyWith<$Res> {
  _$UpdateRewardRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = freezed,
    Object? description = freezed,
    Object? cost = freezed,
    Object? isActive = freezed,
    Object? imageUrl = freezed,
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
      cost: freezed == cost
          ? _value.cost
          : cost // ignore: cast_nullable_to_non_nullable
              as int?,
      isActive: freezed == isActive
          ? _value.isActive
          : isActive // ignore: cast_nullable_to_non_nullable
              as bool?,
      imageUrl: freezed == imageUrl
          ? _value.imageUrl
          : imageUrl // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$UpdateRewardRequestImplCopyWith<$Res>
    implements $UpdateRewardRequestCopyWith<$Res> {
  factory _$$UpdateRewardRequestImplCopyWith(_$UpdateRewardRequestImpl value,
          $Res Function(_$UpdateRewardRequestImpl) then) =
      __$$UpdateRewardRequestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String? name,
      String? description,
      int? cost,
      bool? isActive,
      String? imageUrl});
}

/// @nodoc
class __$$UpdateRewardRequestImplCopyWithImpl<$Res>
    extends _$UpdateRewardRequestCopyWithImpl<$Res, _$UpdateRewardRequestImpl>
    implements _$$UpdateRewardRequestImplCopyWith<$Res> {
  __$$UpdateRewardRequestImplCopyWithImpl(_$UpdateRewardRequestImpl _value,
      $Res Function(_$UpdateRewardRequestImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = freezed,
    Object? description = freezed,
    Object? cost = freezed,
    Object? isActive = freezed,
    Object? imageUrl = freezed,
  }) {
    return _then(_$UpdateRewardRequestImpl(
      name: freezed == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String?,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      cost: freezed == cost
          ? _value.cost
          : cost // ignore: cast_nullable_to_non_nullable
              as int?,
      isActive: freezed == isActive
          ? _value.isActive
          : isActive // ignore: cast_nullable_to_non_nullable
              as bool?,
      imageUrl: freezed == imageUrl
          ? _value.imageUrl
          : imageUrl // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$UpdateRewardRequestImpl implements _UpdateRewardRequest {
  const _$UpdateRewardRequestImpl(
      {this.name, this.description, this.cost, this.isActive, this.imageUrl});

  factory _$UpdateRewardRequestImpl.fromJson(Map<String, dynamic> json) =>
      _$$UpdateRewardRequestImplFromJson(json);

  @override
  final String? name;
  @override
  final String? description;
  @override
  final int? cost;
  @override
  final bool? isActive;
  @override
  final String? imageUrl;

  @override
  String toString() {
    return 'UpdateRewardRequest(name: $name, description: $description, cost: $cost, isActive: $isActive, imageUrl: $imageUrl)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UpdateRewardRequestImpl &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.cost, cost) || other.cost == cost) &&
            (identical(other.isActive, isActive) ||
                other.isActive == isActive) &&
            (identical(other.imageUrl, imageUrl) ||
                other.imageUrl == imageUrl));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode =>
      Object.hash(runtimeType, name, description, cost, isActive, imageUrl);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$UpdateRewardRequestImplCopyWith<_$UpdateRewardRequestImpl> get copyWith =>
      __$$UpdateRewardRequestImplCopyWithImpl<_$UpdateRewardRequestImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$UpdateRewardRequestImplToJson(
      this,
    );
  }
}

abstract class _UpdateRewardRequest implements UpdateRewardRequest {
  const factory _UpdateRewardRequest(
      {final String? name,
      final String? description,
      final int? cost,
      final bool? isActive,
      final String? imageUrl}) = _$UpdateRewardRequestImpl;

  factory _UpdateRewardRequest.fromJson(Map<String, dynamic> json) =
      _$UpdateRewardRequestImpl.fromJson;

  @override
  String? get name;
  @override
  String? get description;
  @override
  int? get cost;
  @override
  bool? get isActive;
  @override
  String? get imageUrl;
  @override
  @JsonKey(ignore: true)
  _$$UpdateRewardRequestImplCopyWith<_$UpdateRewardRequestImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
