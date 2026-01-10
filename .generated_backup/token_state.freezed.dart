// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'token_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$TokenState {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(
            String accessToken, String refreshToken, DateTime expiresAt)
        valid,
    required TResult Function(String refreshToken) expired,
    required TResult Function(String refreshToken) refreshing,
    required TResult Function(String message, bool requiresReauthentication)
        error,
    required TResult Function() empty,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(
            String accessToken, String refreshToken, DateTime expiresAt)?
        valid,
    TResult? Function(String refreshToken)? expired,
    TResult? Function(String refreshToken)? refreshing,
    TResult? Function(String message, bool requiresReauthentication)? error,
    TResult? Function()? empty,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(
            String accessToken, String refreshToken, DateTime expiresAt)?
        valid,
    TResult Function(String refreshToken)? expired,
    TResult Function(String refreshToken)? refreshing,
    TResult Function(String message, bool requiresReauthentication)? error,
    TResult Function()? empty,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(ValidTokenState value) valid,
    required TResult Function(ExpiredTokenState value) expired,
    required TResult Function(RefreshingTokenState value) refreshing,
    required TResult Function(ErrorTokenState value) error,
    required TResult Function(EmptyTokenState value) empty,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(ValidTokenState value)? valid,
    TResult? Function(ExpiredTokenState value)? expired,
    TResult? Function(RefreshingTokenState value)? refreshing,
    TResult? Function(ErrorTokenState value)? error,
    TResult? Function(EmptyTokenState value)? empty,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(ValidTokenState value)? valid,
    TResult Function(ExpiredTokenState value)? expired,
    TResult Function(RefreshingTokenState value)? refreshing,
    TResult Function(ErrorTokenState value)? error,
    TResult Function(EmptyTokenState value)? empty,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TokenStateCopyWith<$Res> {
  factory $TokenStateCopyWith(
          TokenState value, $Res Function(TokenState) then) =
      _$TokenStateCopyWithImpl<$Res, TokenState>;
}

/// @nodoc
class _$TokenStateCopyWithImpl<$Res, $Val extends TokenState>
    implements $TokenStateCopyWith<$Res> {
  _$TokenStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TokenState
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc
abstract class _$$ValidTokenStateImplCopyWith<$Res> {
  factory _$$ValidTokenStateImplCopyWith(_$ValidTokenStateImpl value,
          $Res Function(_$ValidTokenStateImpl) then) =
      __$$ValidTokenStateImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String accessToken, String refreshToken, DateTime expiresAt});
}

/// @nodoc
class __$$ValidTokenStateImplCopyWithImpl<$Res>
    extends _$TokenStateCopyWithImpl<$Res, _$ValidTokenStateImpl>
    implements _$$ValidTokenStateImplCopyWith<$Res> {
  __$$ValidTokenStateImplCopyWithImpl(
      _$ValidTokenStateImpl _value, $Res Function(_$ValidTokenStateImpl) _then)
      : super(_value, _then);

  /// Create a copy of TokenState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? accessToken = null,
    Object? refreshToken = null,
    Object? expiresAt = null,
  }) {
    return _then(_$ValidTokenStateImpl(
      accessToken: null == accessToken
          ? _value.accessToken
          : accessToken // ignore: cast_nullable_to_non_nullable
              as String,
      refreshToken: null == refreshToken
          ? _value.refreshToken
          : refreshToken // ignore: cast_nullable_to_non_nullable
              as String,
      expiresAt: null == expiresAt
          ? _value.expiresAt
          : expiresAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// @nodoc

class _$ValidTokenStateImpl implements ValidTokenState {
  const _$ValidTokenStateImpl(
      {required this.accessToken,
      required this.refreshToken,
      required this.expiresAt});

  @override
  final String accessToken;
  @override
  final String refreshToken;
  @override
  final DateTime expiresAt;

  @override
  String toString() {
    return 'TokenState.valid(accessToken: $accessToken, refreshToken: $refreshToken, expiresAt: $expiresAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ValidTokenStateImpl &&
            (identical(other.accessToken, accessToken) ||
                other.accessToken == accessToken) &&
            (identical(other.refreshToken, refreshToken) ||
                other.refreshToken == refreshToken) &&
            (identical(other.expiresAt, expiresAt) ||
                other.expiresAt == expiresAt));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, accessToken, refreshToken, expiresAt);

  /// Create a copy of TokenState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ValidTokenStateImplCopyWith<_$ValidTokenStateImpl> get copyWith =>
      __$$ValidTokenStateImplCopyWithImpl<_$ValidTokenStateImpl>(
          this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(
            String accessToken, String refreshToken, DateTime expiresAt)
        valid,
    required TResult Function(String refreshToken) expired,
    required TResult Function(String refreshToken) refreshing,
    required TResult Function(String message, bool requiresReauthentication)
        error,
    required TResult Function() empty,
  }) {
    return valid(accessToken, refreshToken, expiresAt);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(
            String accessToken, String refreshToken, DateTime expiresAt)?
        valid,
    TResult? Function(String refreshToken)? expired,
    TResult? Function(String refreshToken)? refreshing,
    TResult? Function(String message, bool requiresReauthentication)? error,
    TResult? Function()? empty,
  }) {
    return valid?.call(accessToken, refreshToken, expiresAt);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(
            String accessToken, String refreshToken, DateTime expiresAt)?
        valid,
    TResult Function(String refreshToken)? expired,
    TResult Function(String refreshToken)? refreshing,
    TResult Function(String message, bool requiresReauthentication)? error,
    TResult Function()? empty,
    required TResult orElse(),
  }) {
    if (valid != null) {
      return valid(accessToken, refreshToken, expiresAt);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(ValidTokenState value) valid,
    required TResult Function(ExpiredTokenState value) expired,
    required TResult Function(RefreshingTokenState value) refreshing,
    required TResult Function(ErrorTokenState value) error,
    required TResult Function(EmptyTokenState value) empty,
  }) {
    return valid(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(ValidTokenState value)? valid,
    TResult? Function(ExpiredTokenState value)? expired,
    TResult? Function(RefreshingTokenState value)? refreshing,
    TResult? Function(ErrorTokenState value)? error,
    TResult? Function(EmptyTokenState value)? empty,
  }) {
    return valid?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(ValidTokenState value)? valid,
    TResult Function(ExpiredTokenState value)? expired,
    TResult Function(RefreshingTokenState value)? refreshing,
    TResult Function(ErrorTokenState value)? error,
    TResult Function(EmptyTokenState value)? empty,
    required TResult orElse(),
  }) {
    if (valid != null) {
      return valid(this);
    }
    return orElse();
  }
}

abstract class ValidTokenState implements TokenState {
  const factory ValidTokenState(
      {required final String accessToken,
      required final String refreshToken,
      required final DateTime expiresAt}) = _$ValidTokenStateImpl;

  String get accessToken;
  String get refreshToken;
  DateTime get expiresAt;

  /// Create a copy of TokenState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ValidTokenStateImplCopyWith<_$ValidTokenStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$ExpiredTokenStateImplCopyWith<$Res> {
  factory _$$ExpiredTokenStateImplCopyWith(_$ExpiredTokenStateImpl value,
          $Res Function(_$ExpiredTokenStateImpl) then) =
      __$$ExpiredTokenStateImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String refreshToken});
}

/// @nodoc
class __$$ExpiredTokenStateImplCopyWithImpl<$Res>
    extends _$TokenStateCopyWithImpl<$Res, _$ExpiredTokenStateImpl>
    implements _$$ExpiredTokenStateImplCopyWith<$Res> {
  __$$ExpiredTokenStateImplCopyWithImpl(_$ExpiredTokenStateImpl _value,
      $Res Function(_$ExpiredTokenStateImpl) _then)
      : super(_value, _then);

  /// Create a copy of TokenState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? refreshToken = null,
  }) {
    return _then(_$ExpiredTokenStateImpl(
      refreshToken: null == refreshToken
          ? _value.refreshToken
          : refreshToken // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$ExpiredTokenStateImpl implements ExpiredTokenState {
  const _$ExpiredTokenStateImpl({required this.refreshToken});

  @override
  final String refreshToken;

  @override
  String toString() {
    return 'TokenState.expired(refreshToken: $refreshToken)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ExpiredTokenStateImpl &&
            (identical(other.refreshToken, refreshToken) ||
                other.refreshToken == refreshToken));
  }

  @override
  int get hashCode => Object.hash(runtimeType, refreshToken);

  /// Create a copy of TokenState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ExpiredTokenStateImplCopyWith<_$ExpiredTokenStateImpl> get copyWith =>
      __$$ExpiredTokenStateImplCopyWithImpl<_$ExpiredTokenStateImpl>(
          this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(
            String accessToken, String refreshToken, DateTime expiresAt)
        valid,
    required TResult Function(String refreshToken) expired,
    required TResult Function(String refreshToken) refreshing,
    required TResult Function(String message, bool requiresReauthentication)
        error,
    required TResult Function() empty,
  }) {
    return expired(refreshToken);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(
            String accessToken, String refreshToken, DateTime expiresAt)?
        valid,
    TResult? Function(String refreshToken)? expired,
    TResult? Function(String refreshToken)? refreshing,
    TResult? Function(String message, bool requiresReauthentication)? error,
    TResult? Function()? empty,
  }) {
    return expired?.call(refreshToken);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(
            String accessToken, String refreshToken, DateTime expiresAt)?
        valid,
    TResult Function(String refreshToken)? expired,
    TResult Function(String refreshToken)? refreshing,
    TResult Function(String message, bool requiresReauthentication)? error,
    TResult Function()? empty,
    required TResult orElse(),
  }) {
    if (expired != null) {
      return expired(refreshToken);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(ValidTokenState value) valid,
    required TResult Function(ExpiredTokenState value) expired,
    required TResult Function(RefreshingTokenState value) refreshing,
    required TResult Function(ErrorTokenState value) error,
    required TResult Function(EmptyTokenState value) empty,
  }) {
    return expired(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(ValidTokenState value)? valid,
    TResult? Function(ExpiredTokenState value)? expired,
    TResult? Function(RefreshingTokenState value)? refreshing,
    TResult? Function(ErrorTokenState value)? error,
    TResult? Function(EmptyTokenState value)? empty,
  }) {
    return expired?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(ValidTokenState value)? valid,
    TResult Function(ExpiredTokenState value)? expired,
    TResult Function(RefreshingTokenState value)? refreshing,
    TResult Function(ErrorTokenState value)? error,
    TResult Function(EmptyTokenState value)? empty,
    required TResult orElse(),
  }) {
    if (expired != null) {
      return expired(this);
    }
    return orElse();
  }
}

abstract class ExpiredTokenState implements TokenState {
  const factory ExpiredTokenState({required final String refreshToken}) =
      _$ExpiredTokenStateImpl;

  String get refreshToken;

  /// Create a copy of TokenState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ExpiredTokenStateImplCopyWith<_$ExpiredTokenStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$RefreshingTokenStateImplCopyWith<$Res> {
  factory _$$RefreshingTokenStateImplCopyWith(_$RefreshingTokenStateImpl value,
          $Res Function(_$RefreshingTokenStateImpl) then) =
      __$$RefreshingTokenStateImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String refreshToken});
}

/// @nodoc
class __$$RefreshingTokenStateImplCopyWithImpl<$Res>
    extends _$TokenStateCopyWithImpl<$Res, _$RefreshingTokenStateImpl>
    implements _$$RefreshingTokenStateImplCopyWith<$Res> {
  __$$RefreshingTokenStateImplCopyWithImpl(_$RefreshingTokenStateImpl _value,
      $Res Function(_$RefreshingTokenStateImpl) _then)
      : super(_value, _then);

  /// Create a copy of TokenState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? refreshToken = null,
  }) {
    return _then(_$RefreshingTokenStateImpl(
      refreshToken: null == refreshToken
          ? _value.refreshToken
          : refreshToken // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$RefreshingTokenStateImpl implements RefreshingTokenState {
  const _$RefreshingTokenStateImpl({required this.refreshToken});

  @override
  final String refreshToken;

  @override
  String toString() {
    return 'TokenState.refreshing(refreshToken: $refreshToken)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RefreshingTokenStateImpl &&
            (identical(other.refreshToken, refreshToken) ||
                other.refreshToken == refreshToken));
  }

  @override
  int get hashCode => Object.hash(runtimeType, refreshToken);

  /// Create a copy of TokenState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$RefreshingTokenStateImplCopyWith<_$RefreshingTokenStateImpl>
      get copyWith =>
          __$$RefreshingTokenStateImplCopyWithImpl<_$RefreshingTokenStateImpl>(
              this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(
            String accessToken, String refreshToken, DateTime expiresAt)
        valid,
    required TResult Function(String refreshToken) expired,
    required TResult Function(String refreshToken) refreshing,
    required TResult Function(String message, bool requiresReauthentication)
        error,
    required TResult Function() empty,
  }) {
    return refreshing(refreshToken);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(
            String accessToken, String refreshToken, DateTime expiresAt)?
        valid,
    TResult? Function(String refreshToken)? expired,
    TResult? Function(String refreshToken)? refreshing,
    TResult? Function(String message, bool requiresReauthentication)? error,
    TResult? Function()? empty,
  }) {
    return refreshing?.call(refreshToken);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(
            String accessToken, String refreshToken, DateTime expiresAt)?
        valid,
    TResult Function(String refreshToken)? expired,
    TResult Function(String refreshToken)? refreshing,
    TResult Function(String message, bool requiresReauthentication)? error,
    TResult Function()? empty,
    required TResult orElse(),
  }) {
    if (refreshing != null) {
      return refreshing(refreshToken);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(ValidTokenState value) valid,
    required TResult Function(ExpiredTokenState value) expired,
    required TResult Function(RefreshingTokenState value) refreshing,
    required TResult Function(ErrorTokenState value) error,
    required TResult Function(EmptyTokenState value) empty,
  }) {
    return refreshing(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(ValidTokenState value)? valid,
    TResult? Function(ExpiredTokenState value)? expired,
    TResult? Function(RefreshingTokenState value)? refreshing,
    TResult? Function(ErrorTokenState value)? error,
    TResult? Function(EmptyTokenState value)? empty,
  }) {
    return refreshing?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(ValidTokenState value)? valid,
    TResult Function(ExpiredTokenState value)? expired,
    TResult Function(RefreshingTokenState value)? refreshing,
    TResult Function(ErrorTokenState value)? error,
    TResult Function(EmptyTokenState value)? empty,
    required TResult orElse(),
  }) {
    if (refreshing != null) {
      return refreshing(this);
    }
    return orElse();
  }
}

abstract class RefreshingTokenState implements TokenState {
  const factory RefreshingTokenState({required final String refreshToken}) =
      _$RefreshingTokenStateImpl;

  String get refreshToken;

  /// Create a copy of TokenState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$RefreshingTokenStateImplCopyWith<_$RefreshingTokenStateImpl>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$ErrorTokenStateImplCopyWith<$Res> {
  factory _$$ErrorTokenStateImplCopyWith(_$ErrorTokenStateImpl value,
          $Res Function(_$ErrorTokenStateImpl) then) =
      __$$ErrorTokenStateImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String message, bool requiresReauthentication});
}

/// @nodoc
class __$$ErrorTokenStateImplCopyWithImpl<$Res>
    extends _$TokenStateCopyWithImpl<$Res, _$ErrorTokenStateImpl>
    implements _$$ErrorTokenStateImplCopyWith<$Res> {
  __$$ErrorTokenStateImplCopyWithImpl(
      _$ErrorTokenStateImpl _value, $Res Function(_$ErrorTokenStateImpl) _then)
      : super(_value, _then);

  /// Create a copy of TokenState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? message = null,
    Object? requiresReauthentication = null,
  }) {
    return _then(_$ErrorTokenStateImpl(
      message: null == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
      requiresReauthentication: null == requiresReauthentication
          ? _value.requiresReauthentication
          : requiresReauthentication // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc

class _$ErrorTokenStateImpl implements ErrorTokenState {
  const _$ErrorTokenStateImpl(
      {required this.message, required this.requiresReauthentication});

  @override
  final String message;
  @override
  final bool requiresReauthentication;

  @override
  String toString() {
    return 'TokenState.error(message: $message, requiresReauthentication: $requiresReauthentication)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ErrorTokenStateImpl &&
            (identical(other.message, message) || other.message == message) &&
            (identical(
                    other.requiresReauthentication, requiresReauthentication) ||
                other.requiresReauthentication == requiresReauthentication));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, message, requiresReauthentication);

  /// Create a copy of TokenState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ErrorTokenStateImplCopyWith<_$ErrorTokenStateImpl> get copyWith =>
      __$$ErrorTokenStateImplCopyWithImpl<_$ErrorTokenStateImpl>(
          this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(
            String accessToken, String refreshToken, DateTime expiresAt)
        valid,
    required TResult Function(String refreshToken) expired,
    required TResult Function(String refreshToken) refreshing,
    required TResult Function(String message, bool requiresReauthentication)
        error,
    required TResult Function() empty,
  }) {
    return error(message, requiresReauthentication);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(
            String accessToken, String refreshToken, DateTime expiresAt)?
        valid,
    TResult? Function(String refreshToken)? expired,
    TResult? Function(String refreshToken)? refreshing,
    TResult? Function(String message, bool requiresReauthentication)? error,
    TResult? Function()? empty,
  }) {
    return error?.call(message, requiresReauthentication);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(
            String accessToken, String refreshToken, DateTime expiresAt)?
        valid,
    TResult Function(String refreshToken)? expired,
    TResult Function(String refreshToken)? refreshing,
    TResult Function(String message, bool requiresReauthentication)? error,
    TResult Function()? empty,
    required TResult orElse(),
  }) {
    if (error != null) {
      return error(message, requiresReauthentication);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(ValidTokenState value) valid,
    required TResult Function(ExpiredTokenState value) expired,
    required TResult Function(RefreshingTokenState value) refreshing,
    required TResult Function(ErrorTokenState value) error,
    required TResult Function(EmptyTokenState value) empty,
  }) {
    return error(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(ValidTokenState value)? valid,
    TResult? Function(ExpiredTokenState value)? expired,
    TResult? Function(RefreshingTokenState value)? refreshing,
    TResult? Function(ErrorTokenState value)? error,
    TResult? Function(EmptyTokenState value)? empty,
  }) {
    return error?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(ValidTokenState value)? valid,
    TResult Function(ExpiredTokenState value)? expired,
    TResult Function(RefreshingTokenState value)? refreshing,
    TResult Function(ErrorTokenState value)? error,
    TResult Function(EmptyTokenState value)? empty,
    required TResult orElse(),
  }) {
    if (error != null) {
      return error(this);
    }
    return orElse();
  }
}

abstract class ErrorTokenState implements TokenState {
  const factory ErrorTokenState(
      {required final String message,
      required final bool requiresReauthentication}) = _$ErrorTokenStateImpl;

  String get message;
  bool get requiresReauthentication;

  /// Create a copy of TokenState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ErrorTokenStateImplCopyWith<_$ErrorTokenStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$EmptyTokenStateImplCopyWith<$Res> {
  factory _$$EmptyTokenStateImplCopyWith(_$EmptyTokenStateImpl value,
          $Res Function(_$EmptyTokenStateImpl) then) =
      __$$EmptyTokenStateImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$EmptyTokenStateImplCopyWithImpl<$Res>
    extends _$TokenStateCopyWithImpl<$Res, _$EmptyTokenStateImpl>
    implements _$$EmptyTokenStateImplCopyWith<$Res> {
  __$$EmptyTokenStateImplCopyWithImpl(
      _$EmptyTokenStateImpl _value, $Res Function(_$EmptyTokenStateImpl) _then)
      : super(_value, _then);

  /// Create a copy of TokenState
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$EmptyTokenStateImpl implements EmptyTokenState {
  const _$EmptyTokenStateImpl();

  @override
  String toString() {
    return 'TokenState.empty()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$EmptyTokenStateImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(
            String accessToken, String refreshToken, DateTime expiresAt)
        valid,
    required TResult Function(String refreshToken) expired,
    required TResult Function(String refreshToken) refreshing,
    required TResult Function(String message, bool requiresReauthentication)
        error,
    required TResult Function() empty,
  }) {
    return empty();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(
            String accessToken, String refreshToken, DateTime expiresAt)?
        valid,
    TResult? Function(String refreshToken)? expired,
    TResult? Function(String refreshToken)? refreshing,
    TResult? Function(String message, bool requiresReauthentication)? error,
    TResult? Function()? empty,
  }) {
    return empty?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(
            String accessToken, String refreshToken, DateTime expiresAt)?
        valid,
    TResult Function(String refreshToken)? expired,
    TResult Function(String refreshToken)? refreshing,
    TResult Function(String message, bool requiresReauthentication)? error,
    TResult Function()? empty,
    required TResult orElse(),
  }) {
    if (empty != null) {
      return empty();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(ValidTokenState value) valid,
    required TResult Function(ExpiredTokenState value) expired,
    required TResult Function(RefreshingTokenState value) refreshing,
    required TResult Function(ErrorTokenState value) error,
    required TResult Function(EmptyTokenState value) empty,
  }) {
    return empty(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(ValidTokenState value)? valid,
    TResult? Function(ExpiredTokenState value)? expired,
    TResult? Function(RefreshingTokenState value)? refreshing,
    TResult? Function(ErrorTokenState value)? error,
    TResult? Function(EmptyTokenState value)? empty,
  }) {
    return empty?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(ValidTokenState value)? valid,
    TResult Function(ExpiredTokenState value)? expired,
    TResult Function(RefreshingTokenState value)? refreshing,
    TResult Function(ErrorTokenState value)? error,
    TResult Function(EmptyTokenState value)? empty,
    required TResult orElse(),
  }) {
    if (empty != null) {
      return empty(this);
    }
    return orElse();
  }
}

abstract class EmptyTokenState implements TokenState {
  const factory EmptyTokenState() = _$EmptyTokenStateImpl;
}
