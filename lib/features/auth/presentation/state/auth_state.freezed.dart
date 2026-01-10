// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'auth_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$AuthState {
  /// Currently authenticated user (null if not logged in)
  User? get user;

  /// Whether user is authenticated
  bool get isAuthenticated;

  /// Whether user requires MFA
  bool get requiresMFA;

  /// Whether user requires email verification
  bool get requiresEmailVerification;

  /// Whether user requires password reset
  bool get requiresPasswordReset;

  /// The access token for the current session
  String? get accessToken;

  /// The ID token for the current session
  String? get idToken;

  /// The refresh token for the current session
  String? get refreshToken;

  /// The expiration time of the current session
  DateTime? get tokenExpiresAt;

  /// Optional session token for tracking
  String? get sessionToken;

  /// Last activity timestamp
  DateTime? get lastActivity;

  /// Create a copy of AuthState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $AuthStateCopyWith<AuthState> get copyWith =>
      _$AuthStateCopyWithImpl<AuthState>(this as AuthState, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is AuthState &&
            (identical(other.user, user) || other.user == user) &&
            (identical(other.isAuthenticated, isAuthenticated) ||
                other.isAuthenticated == isAuthenticated) &&
            (identical(other.requiresMFA, requiresMFA) ||
                other.requiresMFA == requiresMFA) &&
            (identical(other.requiresEmailVerification,
                    requiresEmailVerification) ||
                other.requiresEmailVerification == requiresEmailVerification) &&
            (identical(other.requiresPasswordReset, requiresPasswordReset) ||
                other.requiresPasswordReset == requiresPasswordReset) &&
            (identical(other.accessToken, accessToken) ||
                other.accessToken == accessToken) &&
            (identical(other.idToken, idToken) || other.idToken == idToken) &&
            (identical(other.refreshToken, refreshToken) ||
                other.refreshToken == refreshToken) &&
            (identical(other.tokenExpiresAt, tokenExpiresAt) ||
                other.tokenExpiresAt == tokenExpiresAt) &&
            (identical(other.sessionToken, sessionToken) ||
                other.sessionToken == sessionToken) &&
            (identical(other.lastActivity, lastActivity) ||
                other.lastActivity == lastActivity));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      user,
      isAuthenticated,
      requiresMFA,
      requiresEmailVerification,
      requiresPasswordReset,
      accessToken,
      idToken,
      refreshToken,
      tokenExpiresAt,
      sessionToken,
      lastActivity);

  @override
  String toString() {
    return 'AuthState(user: $user, isAuthenticated: $isAuthenticated, requiresMFA: $requiresMFA, requiresEmailVerification: $requiresEmailVerification, requiresPasswordReset: $requiresPasswordReset, accessToken: $accessToken, idToken: $idToken, refreshToken: $refreshToken, tokenExpiresAt: $tokenExpiresAt, sessionToken: $sessionToken, lastActivity: $lastActivity)';
  }
}

/// @nodoc
abstract mixin class $AuthStateCopyWith<$Res> {
  factory $AuthStateCopyWith(AuthState value, $Res Function(AuthState) _then) =
      _$AuthStateCopyWithImpl;
  @useResult
  $Res call(
      {User? user,
      bool isAuthenticated,
      bool requiresMFA,
      bool requiresEmailVerification,
      bool requiresPasswordReset,
      String? accessToken,
      String? idToken,
      String? refreshToken,
      DateTime? tokenExpiresAt,
      String? sessionToken,
      DateTime? lastActivity});
}

/// @nodoc
class _$AuthStateCopyWithImpl<$Res> implements $AuthStateCopyWith<$Res> {
  _$AuthStateCopyWithImpl(this._self, this._then);

  final AuthState _self;
  final $Res Function(AuthState) _then;

  /// Create a copy of AuthState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? user = freezed,
    Object? isAuthenticated = null,
    Object? requiresMFA = null,
    Object? requiresEmailVerification = null,
    Object? requiresPasswordReset = null,
    Object? accessToken = freezed,
    Object? idToken = freezed,
    Object? refreshToken = freezed,
    Object? tokenExpiresAt = freezed,
    Object? sessionToken = freezed,
    Object? lastActivity = freezed,
  }) {
    return _then(_self.copyWith(
      user: freezed == user
          ? _self.user
          : user // ignore: cast_nullable_to_non_nullable
              as User?,
      isAuthenticated: null == isAuthenticated
          ? _self.isAuthenticated
          : isAuthenticated // ignore: cast_nullable_to_non_nullable
              as bool,
      requiresMFA: null == requiresMFA
          ? _self.requiresMFA
          : requiresMFA // ignore: cast_nullable_to_non_nullable
              as bool,
      requiresEmailVerification: null == requiresEmailVerification
          ? _self.requiresEmailVerification
          : requiresEmailVerification // ignore: cast_nullable_to_non_nullable
              as bool,
      requiresPasswordReset: null == requiresPasswordReset
          ? _self.requiresPasswordReset
          : requiresPasswordReset // ignore: cast_nullable_to_non_nullable
              as bool,
      accessToken: freezed == accessToken
          ? _self.accessToken
          : accessToken // ignore: cast_nullable_to_non_nullable
              as String?,
      idToken: freezed == idToken
          ? _self.idToken
          : idToken // ignore: cast_nullable_to_non_nullable
              as String?,
      refreshToken: freezed == refreshToken
          ? _self.refreshToken
          : refreshToken // ignore: cast_nullable_to_non_nullable
              as String?,
      tokenExpiresAt: freezed == tokenExpiresAt
          ? _self.tokenExpiresAt
          : tokenExpiresAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      sessionToken: freezed == sessionToken
          ? _self.sessionToken
          : sessionToken // ignore: cast_nullable_to_non_nullable
              as String?,
      lastActivity: freezed == lastActivity
          ? _self.lastActivity
          : lastActivity // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// Adds pattern-matching-related methods to [AuthState].
extension AuthStatePatterns on AuthState {
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
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_AuthState value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _AuthState() when $default != null:
        return $default(_that);
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
  TResult map<TResult extends Object?>(
    TResult Function(_AuthState value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _AuthState():
        return $default(_that);
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
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_AuthState value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _AuthState() when $default != null:
        return $default(_that);
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
  TResult maybeWhen<TResult extends Object?>(
    TResult Function(
            User? user,
            bool isAuthenticated,
            bool requiresMFA,
            bool requiresEmailVerification,
            bool requiresPasswordReset,
            String? accessToken,
            String? idToken,
            String? refreshToken,
            DateTime? tokenExpiresAt,
            String? sessionToken,
            DateTime? lastActivity)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _AuthState() when $default != null:
        return $default(
            _that.user,
            _that.isAuthenticated,
            _that.requiresMFA,
            _that.requiresEmailVerification,
            _that.requiresPasswordReset,
            _that.accessToken,
            _that.idToken,
            _that.refreshToken,
            _that.tokenExpiresAt,
            _that.sessionToken,
            _that.lastActivity);
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
  TResult when<TResult extends Object?>(
    TResult Function(
            User? user,
            bool isAuthenticated,
            bool requiresMFA,
            bool requiresEmailVerification,
            bool requiresPasswordReset,
            String? accessToken,
            String? idToken,
            String? refreshToken,
            DateTime? tokenExpiresAt,
            String? sessionToken,
            DateTime? lastActivity)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _AuthState():
        return $default(
            _that.user,
            _that.isAuthenticated,
            _that.requiresMFA,
            _that.requiresEmailVerification,
            _that.requiresPasswordReset,
            _that.accessToken,
            _that.idToken,
            _that.refreshToken,
            _that.tokenExpiresAt,
            _that.sessionToken,
            _that.lastActivity);
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
  TResult? whenOrNull<TResult extends Object?>(
    TResult? Function(
            User? user,
            bool isAuthenticated,
            bool requiresMFA,
            bool requiresEmailVerification,
            bool requiresPasswordReset,
            String? accessToken,
            String? idToken,
            String? refreshToken,
            DateTime? tokenExpiresAt,
            String? sessionToken,
            DateTime? lastActivity)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _AuthState() when $default != null:
        return $default(
            _that.user,
            _that.isAuthenticated,
            _that.requiresMFA,
            _that.requiresEmailVerification,
            _that.requiresPasswordReset,
            _that.accessToken,
            _that.idToken,
            _that.refreshToken,
            _that.tokenExpiresAt,
            _that.sessionToken,
            _that.lastActivity);
      case _:
        return null;
    }
  }
}

/// @nodoc

class _AuthState extends AuthState {
  const _AuthState(
      {this.user,
      this.isAuthenticated = false,
      this.requiresMFA = false,
      this.requiresEmailVerification = false,
      this.requiresPasswordReset = false,
      this.accessToken,
      this.idToken,
      this.refreshToken,
      this.tokenExpiresAt,
      this.sessionToken,
      this.lastActivity})
      : super._();

  /// Currently authenticated user (null if not logged in)
  @override
  final User? user;

  /// Whether user is authenticated
  @override
  @JsonKey()
  final bool isAuthenticated;

  /// Whether user requires MFA
  @override
  @JsonKey()
  final bool requiresMFA;

  /// Whether user requires email verification
  @override
  @JsonKey()
  final bool requiresEmailVerification;

  /// Whether user requires password reset
  @override
  @JsonKey()
  final bool requiresPasswordReset;

  /// The access token for the current session
  @override
  final String? accessToken;

  /// The ID token for the current session
  @override
  final String? idToken;

  /// The refresh token for the current session
  @override
  final String? refreshToken;

  /// The expiration time of the current session
  @override
  final DateTime? tokenExpiresAt;

  /// Optional session token for tracking
  @override
  final String? sessionToken;

  /// Last activity timestamp
  @override
  final DateTime? lastActivity;

  /// Create a copy of AuthState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$AuthStateCopyWith<_AuthState> get copyWith =>
      __$AuthStateCopyWithImpl<_AuthState>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _AuthState &&
            (identical(other.user, user) || other.user == user) &&
            (identical(other.isAuthenticated, isAuthenticated) ||
                other.isAuthenticated == isAuthenticated) &&
            (identical(other.requiresMFA, requiresMFA) ||
                other.requiresMFA == requiresMFA) &&
            (identical(other.requiresEmailVerification,
                    requiresEmailVerification) ||
                other.requiresEmailVerification == requiresEmailVerification) &&
            (identical(other.requiresPasswordReset, requiresPasswordReset) ||
                other.requiresPasswordReset == requiresPasswordReset) &&
            (identical(other.accessToken, accessToken) ||
                other.accessToken == accessToken) &&
            (identical(other.idToken, idToken) || other.idToken == idToken) &&
            (identical(other.refreshToken, refreshToken) ||
                other.refreshToken == refreshToken) &&
            (identical(other.tokenExpiresAt, tokenExpiresAt) ||
                other.tokenExpiresAt == tokenExpiresAt) &&
            (identical(other.sessionToken, sessionToken) ||
                other.sessionToken == sessionToken) &&
            (identical(other.lastActivity, lastActivity) ||
                other.lastActivity == lastActivity));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      user,
      isAuthenticated,
      requiresMFA,
      requiresEmailVerification,
      requiresPasswordReset,
      accessToken,
      idToken,
      refreshToken,
      tokenExpiresAt,
      sessionToken,
      lastActivity);

  @override
  String toString() {
    return 'AuthState(user: $user, isAuthenticated: $isAuthenticated, requiresMFA: $requiresMFA, requiresEmailVerification: $requiresEmailVerification, requiresPasswordReset: $requiresPasswordReset, accessToken: $accessToken, idToken: $idToken, refreshToken: $refreshToken, tokenExpiresAt: $tokenExpiresAt, sessionToken: $sessionToken, lastActivity: $lastActivity)';
  }
}

/// @nodoc
abstract mixin class _$AuthStateCopyWith<$Res>
    implements $AuthStateCopyWith<$Res> {
  factory _$AuthStateCopyWith(
          _AuthState value, $Res Function(_AuthState) _then) =
      __$AuthStateCopyWithImpl;
  @override
  @useResult
  $Res call(
      {User? user,
      bool isAuthenticated,
      bool requiresMFA,
      bool requiresEmailVerification,
      bool requiresPasswordReset,
      String? accessToken,
      String? idToken,
      String? refreshToken,
      DateTime? tokenExpiresAt,
      String? sessionToken,
      DateTime? lastActivity});
}

/// @nodoc
class __$AuthStateCopyWithImpl<$Res> implements _$AuthStateCopyWith<$Res> {
  __$AuthStateCopyWithImpl(this._self, this._then);

  final _AuthState _self;
  final $Res Function(_AuthState) _then;

  /// Create a copy of AuthState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? user = freezed,
    Object? isAuthenticated = null,
    Object? requiresMFA = null,
    Object? requiresEmailVerification = null,
    Object? requiresPasswordReset = null,
    Object? accessToken = freezed,
    Object? idToken = freezed,
    Object? refreshToken = freezed,
    Object? tokenExpiresAt = freezed,
    Object? sessionToken = freezed,
    Object? lastActivity = freezed,
  }) {
    return _then(_AuthState(
      user: freezed == user
          ? _self.user
          : user // ignore: cast_nullable_to_non_nullable
              as User?,
      isAuthenticated: null == isAuthenticated
          ? _self.isAuthenticated
          : isAuthenticated // ignore: cast_nullable_to_non_nullable
              as bool,
      requiresMFA: null == requiresMFA
          ? _self.requiresMFA
          : requiresMFA // ignore: cast_nullable_to_non_nullable
              as bool,
      requiresEmailVerification: null == requiresEmailVerification
          ? _self.requiresEmailVerification
          : requiresEmailVerification // ignore: cast_nullable_to_non_nullable
              as bool,
      requiresPasswordReset: null == requiresPasswordReset
          ? _self.requiresPasswordReset
          : requiresPasswordReset // ignore: cast_nullable_to_non_nullable
              as bool,
      accessToken: freezed == accessToken
          ? _self.accessToken
          : accessToken // ignore: cast_nullable_to_non_nullable
              as String?,
      idToken: freezed == idToken
          ? _self.idToken
          : idToken // ignore: cast_nullable_to_non_nullable
              as String?,
      refreshToken: freezed == refreshToken
          ? _self.refreshToken
          : refreshToken // ignore: cast_nullable_to_non_nullable
              as String?,
      tokenExpiresAt: freezed == tokenExpiresAt
          ? _self.tokenExpiresAt
          : tokenExpiresAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      sessionToken: freezed == sessionToken
          ? _self.sessionToken
          : sessionToken // ignore: cast_nullable_to_non_nullable
              as String?,
      lastActivity: freezed == lastActivity
          ? _self.lastActivity
          : lastActivity // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

// dart format on
