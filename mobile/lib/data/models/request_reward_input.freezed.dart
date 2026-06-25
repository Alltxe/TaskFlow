// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'request_reward_input.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

RequestRewardInput _$RequestRewardInputFromJson(Map<String, dynamic> json) {
  return _RequestRewardInput.fromJson(json);
}

/// @nodoc
mixin _$RequestRewardInput {
  String get rewardId => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $RequestRewardInputCopyWith<RequestRewardInput> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RequestRewardInputCopyWith<$Res> {
  factory $RequestRewardInputCopyWith(
          RequestRewardInput value, $Res Function(RequestRewardInput) then) =
      _$RequestRewardInputCopyWithImpl<$Res, RequestRewardInput>;
  @useResult
  $Res call({String rewardId});
}

/// @nodoc
class _$RequestRewardInputCopyWithImpl<$Res, $Val extends RequestRewardInput>
    implements $RequestRewardInputCopyWith<$Res> {
  _$RequestRewardInputCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? rewardId = null,
  }) {
    return _then(_value.copyWith(
      rewardId: null == rewardId
          ? _value.rewardId
          : rewardId // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$RequestRewardInputImplCopyWith<$Res>
    implements $RequestRewardInputCopyWith<$Res> {
  factory _$$RequestRewardInputImplCopyWith(_$RequestRewardInputImpl value,
          $Res Function(_$RequestRewardInputImpl) then) =
      __$$RequestRewardInputImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String rewardId});
}

/// @nodoc
class __$$RequestRewardInputImplCopyWithImpl<$Res>
    extends _$RequestRewardInputCopyWithImpl<$Res, _$RequestRewardInputImpl>
    implements _$$RequestRewardInputImplCopyWith<$Res> {
  __$$RequestRewardInputImplCopyWithImpl(_$RequestRewardInputImpl _value,
      $Res Function(_$RequestRewardInputImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? rewardId = null,
  }) {
    return _then(_$RequestRewardInputImpl(
      rewardId: null == rewardId
          ? _value.rewardId
          : rewardId // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$RequestRewardInputImpl implements _RequestRewardInput {
  const _$RequestRewardInputImpl({required this.rewardId});

  factory _$RequestRewardInputImpl.fromJson(Map<String, dynamic> json) =>
      _$$RequestRewardInputImplFromJson(json);

  @override
  final String rewardId;

  @override
  String toString() {
    return 'RequestRewardInput(rewardId: $rewardId)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RequestRewardInputImpl &&
            (identical(other.rewardId, rewardId) ||
                other.rewardId == rewardId));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, rewardId);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$RequestRewardInputImplCopyWith<_$RequestRewardInputImpl> get copyWith =>
      __$$RequestRewardInputImplCopyWithImpl<_$RequestRewardInputImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$RequestRewardInputImplToJson(
      this,
    );
  }
}

abstract class _RequestRewardInput implements RequestRewardInput {
  const factory _RequestRewardInput({required final String rewardId}) =
      _$RequestRewardInputImpl;

  factory _RequestRewardInput.fromJson(Map<String, dynamic> json) =
      _$RequestRewardInputImpl.fromJson;

  @override
  String get rewardId;
  @override
  @JsonKey(ignore: true)
  _$$RequestRewardInputImplCopyWith<_$RequestRewardInputImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
