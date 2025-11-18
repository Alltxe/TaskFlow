// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'group_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$GroupState {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(List<Group> groups) loaded,
    required TResult Function(String message) error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(List<Group> groups)? loaded,
    TResult? Function(String message)? error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(List<Group> groups)? loaded,
    TResult Function(String message)? error,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(GroupStateInitial value) initial,
    required TResult Function(GroupStateLoading value) loading,
    required TResult Function(GroupStateLoaded value) loaded,
    required TResult Function(GroupStateError value) error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(GroupStateInitial value)? initial,
    TResult? Function(GroupStateLoading value)? loading,
    TResult? Function(GroupStateLoaded value)? loaded,
    TResult? Function(GroupStateError value)? error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(GroupStateInitial value)? initial,
    TResult Function(GroupStateLoading value)? loading,
    TResult Function(GroupStateLoaded value)? loaded,
    TResult Function(GroupStateError value)? error,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GroupStateCopyWith<$Res> {
  factory $GroupStateCopyWith(
          GroupState value, $Res Function(GroupState) then) =
      _$GroupStateCopyWithImpl<$Res, GroupState>;
}

/// @nodoc
class _$GroupStateCopyWithImpl<$Res, $Val extends GroupState>
    implements $GroupStateCopyWith<$Res> {
  _$GroupStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;
}

/// @nodoc
abstract class _$$GroupStateInitialImplCopyWith<$Res> {
  factory _$$GroupStateInitialImplCopyWith(_$GroupStateInitialImpl value,
          $Res Function(_$GroupStateInitialImpl) then) =
      __$$GroupStateInitialImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$GroupStateInitialImplCopyWithImpl<$Res>
    extends _$GroupStateCopyWithImpl<$Res, _$GroupStateInitialImpl>
    implements _$$GroupStateInitialImplCopyWith<$Res> {
  __$$GroupStateInitialImplCopyWithImpl(_$GroupStateInitialImpl _value,
      $Res Function(_$GroupStateInitialImpl) _then)
      : super(_value, _then);
}

/// @nodoc

class _$GroupStateInitialImpl implements GroupStateInitial {
  const _$GroupStateInitialImpl();

  @override
  String toString() {
    return 'GroupState.initial()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$GroupStateInitialImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(List<Group> groups) loaded,
    required TResult Function(String message) error,
  }) {
    return initial();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(List<Group> groups)? loaded,
    TResult? Function(String message)? error,
  }) {
    return initial?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(List<Group> groups)? loaded,
    TResult Function(String message)? error,
    required TResult orElse(),
  }) {
    if (initial != null) {
      return initial();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(GroupStateInitial value) initial,
    required TResult Function(GroupStateLoading value) loading,
    required TResult Function(GroupStateLoaded value) loaded,
    required TResult Function(GroupStateError value) error,
  }) {
    return initial(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(GroupStateInitial value)? initial,
    TResult? Function(GroupStateLoading value)? loading,
    TResult? Function(GroupStateLoaded value)? loaded,
    TResult? Function(GroupStateError value)? error,
  }) {
    return initial?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(GroupStateInitial value)? initial,
    TResult Function(GroupStateLoading value)? loading,
    TResult Function(GroupStateLoaded value)? loaded,
    TResult Function(GroupStateError value)? error,
    required TResult orElse(),
  }) {
    if (initial != null) {
      return initial(this);
    }
    return orElse();
  }
}

abstract class GroupStateInitial implements GroupState {
  const factory GroupStateInitial() = _$GroupStateInitialImpl;
}

/// @nodoc
abstract class _$$GroupStateLoadingImplCopyWith<$Res> {
  factory _$$GroupStateLoadingImplCopyWith(_$GroupStateLoadingImpl value,
          $Res Function(_$GroupStateLoadingImpl) then) =
      __$$GroupStateLoadingImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$GroupStateLoadingImplCopyWithImpl<$Res>
    extends _$GroupStateCopyWithImpl<$Res, _$GroupStateLoadingImpl>
    implements _$$GroupStateLoadingImplCopyWith<$Res> {
  __$$GroupStateLoadingImplCopyWithImpl(_$GroupStateLoadingImpl _value,
      $Res Function(_$GroupStateLoadingImpl) _then)
      : super(_value, _then);
}

/// @nodoc

class _$GroupStateLoadingImpl implements GroupStateLoading {
  const _$GroupStateLoadingImpl();

  @override
  String toString() {
    return 'GroupState.loading()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$GroupStateLoadingImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(List<Group> groups) loaded,
    required TResult Function(String message) error,
  }) {
    return loading();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(List<Group> groups)? loaded,
    TResult? Function(String message)? error,
  }) {
    return loading?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(List<Group> groups)? loaded,
    TResult Function(String message)? error,
    required TResult orElse(),
  }) {
    if (loading != null) {
      return loading();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(GroupStateInitial value) initial,
    required TResult Function(GroupStateLoading value) loading,
    required TResult Function(GroupStateLoaded value) loaded,
    required TResult Function(GroupStateError value) error,
  }) {
    return loading(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(GroupStateInitial value)? initial,
    TResult? Function(GroupStateLoading value)? loading,
    TResult? Function(GroupStateLoaded value)? loaded,
    TResult? Function(GroupStateError value)? error,
  }) {
    return loading?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(GroupStateInitial value)? initial,
    TResult Function(GroupStateLoading value)? loading,
    TResult Function(GroupStateLoaded value)? loaded,
    TResult Function(GroupStateError value)? error,
    required TResult orElse(),
  }) {
    if (loading != null) {
      return loading(this);
    }
    return orElse();
  }
}

abstract class GroupStateLoading implements GroupState {
  const factory GroupStateLoading() = _$GroupStateLoadingImpl;
}

/// @nodoc
abstract class _$$GroupStateLoadedImplCopyWith<$Res> {
  factory _$$GroupStateLoadedImplCopyWith(_$GroupStateLoadedImpl value,
          $Res Function(_$GroupStateLoadedImpl) then) =
      __$$GroupStateLoadedImplCopyWithImpl<$Res>;
  @useResult
  $Res call({List<Group> groups});
}

/// @nodoc
class __$$GroupStateLoadedImplCopyWithImpl<$Res>
    extends _$GroupStateCopyWithImpl<$Res, _$GroupStateLoadedImpl>
    implements _$$GroupStateLoadedImplCopyWith<$Res> {
  __$$GroupStateLoadedImplCopyWithImpl(_$GroupStateLoadedImpl _value,
      $Res Function(_$GroupStateLoadedImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? groups = null,
  }) {
    return _then(_$GroupStateLoadedImpl(
      null == groups
          ? _value._groups
          : groups // ignore: cast_nullable_to_non_nullable
              as List<Group>,
    ));
  }
}

/// @nodoc

class _$GroupStateLoadedImpl implements GroupStateLoaded {
  const _$GroupStateLoadedImpl(final List<Group> groups) : _groups = groups;

  final List<Group> _groups;
  @override
  List<Group> get groups {
    if (_groups is EqualUnmodifiableListView) return _groups;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_groups);
  }

  @override
  String toString() {
    return 'GroupState.loaded(groups: $groups)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GroupStateLoadedImpl &&
            const DeepCollectionEquality().equals(other._groups, _groups));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, const DeepCollectionEquality().hash(_groups));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$GroupStateLoadedImplCopyWith<_$GroupStateLoadedImpl> get copyWith =>
      __$$GroupStateLoadedImplCopyWithImpl<_$GroupStateLoadedImpl>(
          this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(List<Group> groups) loaded,
    required TResult Function(String message) error,
  }) {
    return loaded(groups);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(List<Group> groups)? loaded,
    TResult? Function(String message)? error,
  }) {
    return loaded?.call(groups);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(List<Group> groups)? loaded,
    TResult Function(String message)? error,
    required TResult orElse(),
  }) {
    if (loaded != null) {
      return loaded(groups);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(GroupStateInitial value) initial,
    required TResult Function(GroupStateLoading value) loading,
    required TResult Function(GroupStateLoaded value) loaded,
    required TResult Function(GroupStateError value) error,
  }) {
    return loaded(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(GroupStateInitial value)? initial,
    TResult? Function(GroupStateLoading value)? loading,
    TResult? Function(GroupStateLoaded value)? loaded,
    TResult? Function(GroupStateError value)? error,
  }) {
    return loaded?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(GroupStateInitial value)? initial,
    TResult Function(GroupStateLoading value)? loading,
    TResult Function(GroupStateLoaded value)? loaded,
    TResult Function(GroupStateError value)? error,
    required TResult orElse(),
  }) {
    if (loaded != null) {
      return loaded(this);
    }
    return orElse();
  }
}

abstract class GroupStateLoaded implements GroupState {
  const factory GroupStateLoaded(final List<Group> groups) =
      _$GroupStateLoadedImpl;

  List<Group> get groups;
  @JsonKey(ignore: true)
  _$$GroupStateLoadedImplCopyWith<_$GroupStateLoadedImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$GroupStateErrorImplCopyWith<$Res> {
  factory _$$GroupStateErrorImplCopyWith(_$GroupStateErrorImpl value,
          $Res Function(_$GroupStateErrorImpl) then) =
      __$$GroupStateErrorImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String message});
}

/// @nodoc
class __$$GroupStateErrorImplCopyWithImpl<$Res>
    extends _$GroupStateCopyWithImpl<$Res, _$GroupStateErrorImpl>
    implements _$$GroupStateErrorImplCopyWith<$Res> {
  __$$GroupStateErrorImplCopyWithImpl(
      _$GroupStateErrorImpl _value, $Res Function(_$GroupStateErrorImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? message = null,
  }) {
    return _then(_$GroupStateErrorImpl(
      null == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$GroupStateErrorImpl implements GroupStateError {
  const _$GroupStateErrorImpl(this.message);

  @override
  final String message;

  @override
  String toString() {
    return 'GroupState.error(message: $message)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GroupStateErrorImpl &&
            (identical(other.message, message) || other.message == message));
  }

  @override
  int get hashCode => Object.hash(runtimeType, message);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$GroupStateErrorImplCopyWith<_$GroupStateErrorImpl> get copyWith =>
      __$$GroupStateErrorImplCopyWithImpl<_$GroupStateErrorImpl>(
          this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(List<Group> groups) loaded,
    required TResult Function(String message) error,
  }) {
    return error(message);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(List<Group> groups)? loaded,
    TResult? Function(String message)? error,
  }) {
    return error?.call(message);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(List<Group> groups)? loaded,
    TResult Function(String message)? error,
    required TResult orElse(),
  }) {
    if (error != null) {
      return error(message);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(GroupStateInitial value) initial,
    required TResult Function(GroupStateLoading value) loading,
    required TResult Function(GroupStateLoaded value) loaded,
    required TResult Function(GroupStateError value) error,
  }) {
    return error(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(GroupStateInitial value)? initial,
    TResult? Function(GroupStateLoading value)? loading,
    TResult? Function(GroupStateLoaded value)? loaded,
    TResult? Function(GroupStateError value)? error,
  }) {
    return error?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(GroupStateInitial value)? initial,
    TResult Function(GroupStateLoading value)? loading,
    TResult Function(GroupStateLoaded value)? loaded,
    TResult Function(GroupStateError value)? error,
    required TResult orElse(),
  }) {
    if (error != null) {
      return error(this);
    }
    return orElse();
  }
}

abstract class GroupStateError implements GroupState {
  const factory GroupStateError(final String message) = _$GroupStateErrorImpl;

  String get message;
  @JsonKey(ignore: true)
  _$$GroupStateErrorImplCopyWith<_$GroupStateErrorImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
