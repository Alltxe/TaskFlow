// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'create_reward_request.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

CreateRewardRequest _$CreateRewardRequestFromJson(Map<String, dynamic> json) {
  return _CreateRewardRequest.fromJson(json);
}

/// @nodoc
mixin _$CreateRewardRequest {
  String get groupId => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  int get cost => throw _privateConstructorUsedError;
  String? get imageUrl => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $CreateRewardRequestCopyWith<CreateRewardRequest> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CreateRewardRequestCopyWith<$Res> {
  factory $CreateRewardRequestCopyWith(
          CreateRewardRequest value, $Res Function(CreateRewardRequest) then) =
      _$CreateRewardRequestCopyWithImpl<$Res, CreateRewardRequest>;
  @useResult
  $Res call(
      {String groupId,
      String name,
      String? description,
      int cost,
      String? imageUrl});
}

/// @nodoc
class _$CreateRewardRequestCopyWithImpl<$Res, $Val extends CreateRewardRequest>
    implements $CreateRewardRequestCopyWith<$Res> {
  _$CreateRewardRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? groupId = null,
    Object? name = null,
    Object? description = freezed,
    Object? cost = null,
    Object? imageUrl = freezed,
  }) {
    return _then(_value.copyWith(
      groupId: null == groupId
          ? _value.groupId
          : groupId // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      cost: null == cost
          ? _value.cost
          : cost // ignore: cast_nullable_to_non_nullable
              as int,
      imageUrl: freezed == imageUrl
          ? _value.imageUrl
          : imageUrl // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$CreateRewardRequestImplCopyWith<$Res>
    implements $CreateRewardRequestCopyWith<$Res> {
  factory _$$CreateRewardRequestImplCopyWith(_$CreateRewardRequestImpl value,
          $Res Function(_$CreateRewardRequestImpl) then) =
      __$$CreateRewardRequestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String groupId,
      String name,
      String? description,
      int cost,
      String? imageUrl});
}

/// @nodoc
class __$$CreateRewardRequestImplCopyWithImpl<$Res>
    extends _$CreateRewardRequestCopyWithImpl<$Res, _$CreateRewardRequestImpl>
    implements _$$CreateRewardRequestImplCopyWith<$Res> {
  __$$CreateRewardRequestImplCopyWithImpl(_$CreateRewardRequestImpl _value,
      $Res Function(_$CreateRewardRequestImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? groupId = null,
    Object? name = null,
    Object? description = freezed,
    Object? cost = null,
    Object? imageUrl = freezed,
  }) {
    return _then(_$CreateRewardRequestImpl(
      groupId: null == groupId
          ? _value.groupId
          : groupId // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      cost: null == cost
          ? _value.cost
          : cost // ignore: cast_nullable_to_non_nullable
              as int,
      imageUrl: freezed == imageUrl
          ? _value.imageUrl
          : imageUrl // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$CreateRewardRequestImpl implements _CreateRewardRequest {
  const _$CreateRewardRequestImpl(
      {required this.groupId,
      required this.name,
      this.description,
      required this.cost,
      this.imageUrl});

  factory _$CreateRewardRequestImpl.fromJson(Map<String, dynamic> json) =>
      _$$CreateRewardRequestImplFromJson(json);

  @override
  final String groupId;
  @override
  final String name;
  @override
  final String? description;
  @override
  final int cost;
  @override
  final String? imageUrl;

  @override
  String toString() {
    return 'CreateRewardRequest(groupId: $groupId, name: $name, description: $description, cost: $cost, imageUrl: $imageUrl)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CreateRewardRequestImpl &&
            (identical(other.groupId, groupId) || other.groupId == groupId) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.cost, cost) || other.cost == cost) &&
            (identical(other.imageUrl, imageUrl) ||
                other.imageUrl == imageUrl));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode =>
      Object.hash(runtimeType, groupId, name, description, cost, imageUrl);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$CreateRewardRequestImplCopyWith<_$CreateRewardRequestImpl> get copyWith =>
      __$$CreateRewardRequestImplCopyWithImpl<_$CreateRewardRequestImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CreateRewardRequestImplToJson(
      this,
    );
  }
}

abstract class _CreateRewardRequest implements CreateRewardRequest {
  const factory _CreateRewardRequest(
      {required final String groupId,
      required final String name,
      final String? description,
      required final int cost,
      final String? imageUrl}) = _$CreateRewardRequestImpl;

  factory _CreateRewardRequest.fromJson(Map<String, dynamic> json) =
      _$CreateRewardRequestImpl.fromJson;

  @override
  String get groupId;
  @override
  String get name;
  @override
  String? get description;
  @override
  int get cost;
  @override
  String? get imageUrl;
  @override
  @JsonKey(ignore: true)
  _$$CreateRewardRequestImplCopyWith<_$CreateRewardRequestImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
