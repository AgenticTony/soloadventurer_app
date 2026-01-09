// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'auth_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$AuthState {
  /// Currently authenticated user (null if not logged in)
  User? get user => throw _privateConstructorUsedError;

  /// Whether user is authenticated
  bool get isAuthenticated => throw _privateConstructorUsedError;

  /// Whether user requires MFA
  bool get requiresMFA => throw _privateConstructorUsedError;

  /// Whether user requires email verification
  bool get requiresEmailVerification => throw _privateConstructorUsedError;

  /// Whether user requires password reset
  bool get requiresPasswordReset => throw _privateConstructorUsedError;

  /// The access token for the current session
  String? get accessToken => throw _privateConstructorUsedError;

  /// The ID token for the current session
  String? get idToken => throw _privateConstructorUsedError;

  /// The refresh token for the current session
  String? get refreshToken => throw _privateConstructorUsedError;

  /// The expiration time of the current session
  DateTime? get tokenExpiresAt => throw _privateConstructorUsedError;

  /// Optional session token for tracking
  String? get sessionToken => throw _privateConstructorUsedError;

  /// Last activity timestamp
  DateTime? get lastActivity => throw _privateConstructorUsedError;

  /// Create a copy of AuthState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AuthStateCopyWith<AuthState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AuthStateCopyWith<$Res> {
  factory $AuthStateCopyWith(AuthState value, $Res Function(AuthState) then) =
      _$AuthStateCopyWithImpl<$Res, AuthState>;
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
class _$AuthStateCopyWithImpl<$Res, $Val extends AuthState>
    implements $AuthStateCopyWith<$Res> {
  _$AuthStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

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
    return _then(_value.copyWith(
      user: freezed == user
          ? _value.user
          : user // ignore: cast_nullable_to_non_nullable
              as User?,
      isAuthenticated: null == isAuthenticated
          ? _value.isAuthenticated
          : isAuthenticated // ignore: cast_nullable_to_non_nullable
              as bool,
      requiresMFA: null == requiresMFA
          ? _value.requiresMFA
          : requiresMFA // ignore: cast_nullable_to_non_nullable
              as bool,
      requiresEmailVerification: null == requiresEmailVerification
          ? _value.requiresEmailVerification
          : requiresEmailVerification // ignore: cast_nullable_to_non_nullable
              as bool,
      requiresPasswordReset: null == requiresPasswordReset
          ? _value.requiresPasswordReset
          : requiresPasswordReset // ignore: cast_nullable_to_non_nullable
              as bool,
      accessToken: freezed == accessToken
          ? _value.accessToken
          : accessToken // ignore: cast_nullable_to_non_nullable
              as String?,
      idToken: freezed == idToken
          ? _value.idToken
          : idToken // ignore: cast_nullable_to_non_nullable
              as String?,
      refreshToken: freezed == refreshToken
          ? _value.refreshToken
          : refreshToken // ignore: cast_nullable_to_non_nullable
              as String?,
      tokenExpiresAt: freezed == tokenExpiresAt
          ? _value.tokenExpiresAt
          : tokenExpiresAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      sessionToken: freezed == sessionToken
          ? _value.sessionToken
          : sessionToken // ignore: cast_nullable_to_non_nullable
              as String?,
      lastActivity: freezed == lastActivity
          ? _value.lastActivity
          : lastActivity // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$AuthStateImplCopyWith<$Res>
    implements $AuthStateCopyWith<$Res> {
  factory _$$AuthStateImplCopyWith(
          _$AuthStateImpl value, $Res Function(_$AuthStateImpl) then) =
      __$$AuthStateImplCopyWithImpl<$Res>;
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
class __$$AuthStateImplCopyWithImpl<$Res>
    extends _$AuthStateCopyWithImpl<$Res, _$AuthStateImpl>
    implements _$$AuthStateImplCopyWith<$Res> {
  __$$AuthStateImplCopyWithImpl(
      _$AuthStateImpl _value, $Res Function(_$AuthStateImpl) _then)
      : super(_value, _then);

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
    return _then(_$AuthStateImpl(
      user: freezed == user
          ? _value.user
          : user // ignore: cast_nullable_to_non_nullable
              as User?,
      isAuthenticated: null == isAuthenticated
          ? _value.isAuthenticated
          : isAuthenticated // ignore: cast_nullable_to_non_nullable
              as bool,
      requiresMFA: null == requiresMFA
          ? _value.requiresMFA
          : requiresMFA // ignore: cast_nullable_to_non_nullable
              as bool,
      requiresEmailVerification: null == requiresEmailVerification
          ? _value.requiresEmailVerification
          : requiresEmailVerification // ignore: cast_nullable_to_non_nullable
              as bool,
      requiresPasswordReset: null == requiresPasswordReset
          ? _value.requiresPasswordReset
          : requiresPasswordReset // ignore: cast_nullable_to_non_nullable
              as bool,
      accessToken: freezed == accessToken
          ? _value.accessToken
          : accessToken // ignore: cast_nullable_to_non_nullable
              as String?,
      idToken: freezed == idToken
          ? _value.idToken
          : idToken // ignore: cast_nullable_to_non_nullable
              as String?,
      refreshToken: freezed == refreshToken
          ? _value.refreshToken
          : refreshToken // ignore: cast_nullable_to_non_nullable
              as String?,
      tokenExpiresAt: freezed == tokenExpiresAt
          ? _value.tokenExpiresAt
          : tokenExpiresAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      sessionToken: freezed == sessionToken
          ? _value.sessionToken
          : sessionToken // ignore: cast_nullable_to_non_nullable
              as String?,
      lastActivity: freezed == lastActivity
          ? _value.lastActivity
          : lastActivity // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc

class _$AuthStateImpl extends _AuthState {
  const _$AuthStateImpl(
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

  @override
  String toString() {
    return 'AuthState(user: $user, isAuthenticated: $isAuthenticated, requiresMFA: $requiresMFA, requiresEmailVerification: $requiresEmailVerification, requiresPasswordReset: $requiresPasswordReset, accessToken: $accessToken, idToken: $idToken, refreshToken: $refreshToken, tokenExpiresAt: $tokenExpiresAt, sessionToken: $sessionToken, lastActivity: $lastActivity)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AuthStateImpl &&
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

  /// Create a copy of AuthState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AuthStateImplCopyWith<_$AuthStateImpl> get copyWith =>
      __$$AuthStateImplCopyWithImpl<_$AuthStateImpl>(this, _$identity);
}

abstract class _AuthState extends AuthState {
  const factory _AuthState(
      {final User? user,
      final bool isAuthenticated,
      final bool requiresMFA,
      final bool requiresEmailVerification,
      final bool requiresPasswordReset,
      final String? accessToken,
      final String? idToken,
      final String? refreshToken,
      final DateTime? tokenExpiresAt,
      final String? sessionToken,
      final DateTime? lastActivity}) = _$AuthStateImpl;
  const _AuthState._() : super._();

  /// Currently authenticated user (null if not logged in)
  @override
  User? get user;

  /// Whether user is authenticated
  @override
  bool get isAuthenticated;

  /// Whether user requires MFA
  @override
  bool get requiresMFA;

  /// Whether user requires email verification
  @override
  bool get requiresEmailVerification;

  /// Whether user requires password reset
  @override
  bool get requiresPasswordReset;

  /// The access token for the current session
  @override
  String? get accessToken;

  /// The ID token for the current session
  @override
  String? get idToken;

  /// The refresh token for the current session
  @override
  String? get refreshToken;

  /// The expiration time of the current session
  @override
  DateTime? get tokenExpiresAt;

  /// Optional session token for tracking
  @override
  String? get sessionToken;

  /// Last activity timestamp
  @override
  DateTime? get lastActivity;

  /// Create a copy of AuthState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AuthStateImplCopyWith<_$AuthStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
