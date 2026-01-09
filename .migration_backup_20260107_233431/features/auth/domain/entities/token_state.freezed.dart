// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'token_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$TokenState {
  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is TokenState);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() {
    return 'TokenState()';
  }
}

/// @nodoc
class $TokenStateCopyWith<$Res> {
  $TokenStateCopyWith(TokenState _, $Res Function(TokenState) __);
}

/// Adds pattern-matching-related methods to [TokenState].
extension TokenStatePatterns on TokenState {
  /// A variant of `map` that fallback to returning `orElse`.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case _:
  ///     return orElse();
  /// }
  /// ```

  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(ValidTokenState value)? valid,
    TResult Function(ExpiredTokenState value)? expired,
    TResult Function(RefreshingTokenState value)? refreshing,
    TResult Function(ErrorTokenState value)? error,
    TResult Function(EmptyTokenState value)? empty,
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case ValidTokenState() when valid != null:
        return valid(_that);
      case ExpiredTokenState() when expired != null:
        return expired(_that);
      case RefreshingTokenState() when refreshing != null:
        return refreshing(_that);
      case ErrorTokenState() when error != null:
        return error(_that);
      case EmptyTokenState() when empty != null:
        return empty(_that);
      case _:
        return orElse();
    }
  }

  /// A `switch`-like method, using callbacks.
  ///
  /// Callbacks receives the raw object, upcasted.
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case final Subclass2 value:
  ///     return ...;
  /// }
  /// ```

  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(ValidTokenState value) valid,
    required TResult Function(ExpiredTokenState value) expired,
    required TResult Function(RefreshingTokenState value) refreshing,
    required TResult Function(ErrorTokenState value) error,
    required TResult Function(EmptyTokenState value) empty,
  }) {
    final _that = this;
    switch (_that) {
      case ValidTokenState():
        return valid(_that);
      case ExpiredTokenState():
        return expired(_that);
      case RefreshingTokenState():
        return refreshing(_that);
      case ErrorTokenState():
        return error(_that);
      case EmptyTokenState():
        return empty(_that);
      case _:
        throw StateError('Unexpected subclass');
    }
  }

  /// A variant of `map` that fallback to returning `null`.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case _:
  ///     return null;
  /// }
  /// ```

  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(ValidTokenState value)? valid,
    TResult? Function(ExpiredTokenState value)? expired,
    TResult? Function(RefreshingTokenState value)? refreshing,
    TResult? Function(ErrorTokenState value)? error,
    TResult? Function(EmptyTokenState value)? empty,
  }) {
    final _that = this;
    switch (_that) {
      case ValidTokenState() when valid != null:
        return valid(_that);
      case ExpiredTokenState() when expired != null:
        return expired(_that);
      case RefreshingTokenState() when refreshing != null:
        return refreshing(_that);
      case ErrorTokenState() when error != null:
        return error(_that);
      case EmptyTokenState() when empty != null:
        return empty(_that);
      case _:
        return null;
    }
  }

  /// A variant of `when` that fallback to an `orElse` callback.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case _:
  ///     return orElse();
  /// }
  /// ```

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
    final _that = this;
    switch (_that) {
      case ValidTokenState() when valid != null:
        return valid(_that.accessToken, _that.refreshToken, _that.expiresAt);
      case ExpiredTokenState() when expired != null:
        return expired(_that.refreshToken);
      case RefreshingTokenState() when refreshing != null:
        return refreshing(_that.refreshToken);
      case ErrorTokenState() when error != null:
        return error(_that.message, _that.requiresReauthentication);
      case EmptyTokenState() when empty != null:
        return empty();
      case _:
        return orElse();
    }
  }

  /// A `switch`-like method, using callbacks.
  ///
  /// As opposed to `map`, this offers destructuring.
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case Subclass2(:final field2):
  ///     return ...;
  /// }
  /// ```

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
    final _that = this;
    switch (_that) {
      case ValidTokenState():
        return valid(_that.accessToken, _that.refreshToken, _that.expiresAt);
      case ExpiredTokenState():
        return expired(_that.refreshToken);
      case RefreshingTokenState():
        return refreshing(_that.refreshToken);
      case ErrorTokenState():
        return error(_that.message, _that.requiresReauthentication);
      case EmptyTokenState():
        return empty();
      case _:
        throw StateError('Unexpected subclass');
    }
  }

  /// A variant of `when` that fallback to returning `null`
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case _:
  ///     return null;
  /// }
  /// ```

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
    final _that = this;
    switch (_that) {
      case ValidTokenState() when valid != null:
        return valid(_that.accessToken, _that.refreshToken, _that.expiresAt);
      case ExpiredTokenState() when expired != null:
        return expired(_that.refreshToken);
      case RefreshingTokenState() when refreshing != null:
        return refreshing(_that.refreshToken);
      case ErrorTokenState() when error != null:
        return error(_that.message, _that.requiresReauthentication);
      case EmptyTokenState() when empty != null:
        return empty();
      case _:
        return null;
    }
  }
}

/// @nodoc

class ValidTokenState implements TokenState {
  const ValidTokenState(
      {required this.accessToken,
      required this.refreshToken,
      required this.expiresAt});

  final String accessToken;
  final String refreshToken;
  final DateTime expiresAt;

  /// Create a copy of TokenState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $ValidTokenStateCopyWith<ValidTokenState> get copyWith =>
      _$ValidTokenStateCopyWithImpl<ValidTokenState>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is ValidTokenState &&
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

  @override
  String toString() {
    return 'TokenState.valid(accessToken: $accessToken, refreshToken: $refreshToken, expiresAt: $expiresAt)';
  }
}

/// @nodoc
abstract mixin class $ValidTokenStateCopyWith<$Res>
    implements $TokenStateCopyWith<$Res> {
  factory $ValidTokenStateCopyWith(
          ValidTokenState value, $Res Function(ValidTokenState) _then) =
      _$ValidTokenStateCopyWithImpl;
  @useResult
  $Res call({String accessToken, String refreshToken, DateTime expiresAt});
}

/// @nodoc
class _$ValidTokenStateCopyWithImpl<$Res>
    implements $ValidTokenStateCopyWith<$Res> {
  _$ValidTokenStateCopyWithImpl(this._self, this._then);

  final ValidTokenState _self;
  final $Res Function(ValidTokenState) _then;

  /// Create a copy of TokenState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? accessToken = null,
    Object? refreshToken = null,
    Object? expiresAt = null,
  }) {
    return _then(ValidTokenState(
      accessToken: null == accessToken
          ? _self.accessToken
          : accessToken // ignore: cast_nullable_to_non_nullable
              as String,
      refreshToken: null == refreshToken
          ? _self.refreshToken
          : refreshToken // ignore: cast_nullable_to_non_nullable
              as String,
      expiresAt: null == expiresAt
          ? _self.expiresAt
          : expiresAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// @nodoc

class ExpiredTokenState implements TokenState {
  const ExpiredTokenState({required this.refreshToken});

  final String refreshToken;

  /// Create a copy of TokenState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $ExpiredTokenStateCopyWith<ExpiredTokenState> get copyWith =>
      _$ExpiredTokenStateCopyWithImpl<ExpiredTokenState>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is ExpiredTokenState &&
            (identical(other.refreshToken, refreshToken) ||
                other.refreshToken == refreshToken));
  }

  @override
  int get hashCode => Object.hash(runtimeType, refreshToken);

  @override
  String toString() {
    return 'TokenState.expired(refreshToken: $refreshToken)';
  }
}

/// @nodoc
abstract mixin class $ExpiredTokenStateCopyWith<$Res>
    implements $TokenStateCopyWith<$Res> {
  factory $ExpiredTokenStateCopyWith(
          ExpiredTokenState value, $Res Function(ExpiredTokenState) _then) =
      _$ExpiredTokenStateCopyWithImpl;
  @useResult
  $Res call({String refreshToken});
}

/// @nodoc
class _$ExpiredTokenStateCopyWithImpl<$Res>
    implements $ExpiredTokenStateCopyWith<$Res> {
  _$ExpiredTokenStateCopyWithImpl(this._self, this._then);

  final ExpiredTokenState _self;
  final $Res Function(ExpiredTokenState) _then;

  /// Create a copy of TokenState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? refreshToken = null,
  }) {
    return _then(ExpiredTokenState(
      refreshToken: null == refreshToken
          ? _self.refreshToken
          : refreshToken // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class RefreshingTokenState implements TokenState {
  const RefreshingTokenState({required this.refreshToken});

  final String refreshToken;

  /// Create a copy of TokenState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $RefreshingTokenStateCopyWith<RefreshingTokenState> get copyWith =>
      _$RefreshingTokenStateCopyWithImpl<RefreshingTokenState>(
          this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is RefreshingTokenState &&
            (identical(other.refreshToken, refreshToken) ||
                other.refreshToken == refreshToken));
  }

  @override
  int get hashCode => Object.hash(runtimeType, refreshToken);

  @override
  String toString() {
    return 'TokenState.refreshing(refreshToken: $refreshToken)';
  }
}

/// @nodoc
abstract mixin class $RefreshingTokenStateCopyWith<$Res>
    implements $TokenStateCopyWith<$Res> {
  factory $RefreshingTokenStateCopyWith(RefreshingTokenState value,
          $Res Function(RefreshingTokenState) _then) =
      _$RefreshingTokenStateCopyWithImpl;
  @useResult
  $Res call({String refreshToken});
}

/// @nodoc
class _$RefreshingTokenStateCopyWithImpl<$Res>
    implements $RefreshingTokenStateCopyWith<$Res> {
  _$RefreshingTokenStateCopyWithImpl(this._self, this._then);

  final RefreshingTokenState _self;
  final $Res Function(RefreshingTokenState) _then;

  /// Create a copy of TokenState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? refreshToken = null,
  }) {
    return _then(RefreshingTokenState(
      refreshToken: null == refreshToken
          ? _self.refreshToken
          : refreshToken // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class ErrorTokenState implements TokenState {
  const ErrorTokenState(
      {required this.message, required this.requiresReauthentication});

  final String message;
  final bool requiresReauthentication;

  /// Create a copy of TokenState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $ErrorTokenStateCopyWith<ErrorTokenState> get copyWith =>
      _$ErrorTokenStateCopyWithImpl<ErrorTokenState>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is ErrorTokenState &&
            (identical(other.message, message) || other.message == message) &&
            (identical(
                    other.requiresReauthentication, requiresReauthentication) ||
                other.requiresReauthentication == requiresReauthentication));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, message, requiresReauthentication);

  @override
  String toString() {
    return 'TokenState.error(message: $message, requiresReauthentication: $requiresReauthentication)';
  }
}

/// @nodoc
abstract mixin class $ErrorTokenStateCopyWith<$Res>
    implements $TokenStateCopyWith<$Res> {
  factory $ErrorTokenStateCopyWith(
          ErrorTokenState value, $Res Function(ErrorTokenState) _then) =
      _$ErrorTokenStateCopyWithImpl;
  @useResult
  $Res call({String message, bool requiresReauthentication});
}

/// @nodoc
class _$ErrorTokenStateCopyWithImpl<$Res>
    implements $ErrorTokenStateCopyWith<$Res> {
  _$ErrorTokenStateCopyWithImpl(this._self, this._then);

  final ErrorTokenState _self;
  final $Res Function(ErrorTokenState) _then;

  /// Create a copy of TokenState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? message = null,
    Object? requiresReauthentication = null,
  }) {
    return _then(ErrorTokenState(
      message: null == message
          ? _self.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
      requiresReauthentication: null == requiresReauthentication
          ? _self.requiresReauthentication
          : requiresReauthentication // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc

class EmptyTokenState implements TokenState {
  const EmptyTokenState();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is EmptyTokenState);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() {
    return 'TokenState.empty()';
  }
}

// dart format on
