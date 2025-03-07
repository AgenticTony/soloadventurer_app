import 'package:soloadventurer/features/auth/domain/entities/user.dart';

/// Represents the authentication state of the application
class AuthState {
  /// The current user, if authenticated
  final User? user;

  /// Whether the user is authenticated
  final bool isAuthenticated;

  /// Whether the user requires MFA
  final bool requiresMFA;

  /// Whether the user requires email verification
  final bool requiresEmailVerification;

  /// Whether the user requires password reset
  final bool requiresPasswordReset;

  /// The access token for the current session
  final String? accessToken;

  /// The ID token for the current session
  final String? idToken;

  /// The refresh token for the current session
  final String? refreshToken;

  /// The expiration time of the current session
  final DateTime? tokenExpiresAt;

  /// Creates an initial authentication state
  const AuthState.initial()
      : user = null,
        isAuthenticated = false,
        requiresMFA = false,
        requiresEmailVerification = false,
        requiresPasswordReset = false,
        accessToken = null,
        idToken = null,
        refreshToken = null,
        tokenExpiresAt = null;

  /// Creates an authenticated state with the given user and tokens
  const AuthState.authenticated({
    required User user,
    required String accessToken,
    required String idToken,
    required String refreshToken,
    required DateTime tokenExpiresAt,
    bool requiresMFA = false,
  })  : user = user,
        isAuthenticated = true,
        requiresMFA = requiresMFA,
        requiresEmailVerification = false,
        requiresPasswordReset = false,
        accessToken = accessToken,
        idToken = idToken,
        refreshToken = refreshToken,
        tokenExpiresAt = tokenExpiresAt;

  /// Creates an unverified state with the given user
  const AuthState.unverified({
    required User user,
  })  : user = user,
        isAuthenticated = false,
        requiresMFA = false,
        requiresEmailVerification = true,
        requiresPasswordReset = false,
        accessToken = null,
        idToken = null,
        refreshToken = null,
        tokenExpiresAt = null;

  /// Creates an MFA required state with the given user
  const AuthState.mfaRequired({
    required User user,
  })  : user = user,
        isAuthenticated = false,
        requiresMFA = true,
        requiresEmailVerification = false,
        requiresPasswordReset = false,
        accessToken = null,
        idToken = null,
        refreshToken = null,
        tokenExpiresAt = null;

  /// Creates a password reset required state with the given user
  const AuthState.passwordResetRequired({
    required User user,
  })  : user = user,
        isAuthenticated = false,
        requiresMFA = false,
        requiresEmailVerification = false,
        requiresPasswordReset = true,
        accessToken = null,
        idToken = null,
        refreshToken = null,
        tokenExpiresAt = null;

  /// Creates an unauthenticated state
  const AuthState.unauthenticated()
      : user = null,
        isAuthenticated = false,
        requiresMFA = false,
        requiresEmailVerification = false,
        requiresPasswordReset = false,
        accessToken = null,
        idToken = null,
        refreshToken = null,
        tokenExpiresAt = null;

  /// Creates a loading state
  const AuthState.loading()
      : user = null,
        isAuthenticated = false,
        requiresMFA = false,
        requiresEmailVerification = false,
        requiresPasswordReset = false,
        accessToken = null,
        idToken = null,
        refreshToken = null,
        tokenExpiresAt = null;

  /// Creates an error state
  const AuthState.error()
      : user = null,
        isAuthenticated = false,
        requiresMFA = false,
        requiresEmailVerification = false,
        requiresPasswordReset = false,
        accessToken = null,
        idToken = null,
        refreshToken = null,
        tokenExpiresAt = null;

  /// Creates a copy of this state with the given fields replaced with new values
  AuthState copyWith({
    User? user,
    bool? isAuthenticated,
    bool? requiresMFA,
    bool? requiresEmailVerification,
    bool? requiresPasswordReset,
    String? accessToken,
    String? idToken,
    String? refreshToken,
    DateTime? tokenExpiresAt,
  }) {
    return AuthState(
      user: user ?? this.user,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      requiresMFA: requiresMFA ?? this.requiresMFA,
      requiresEmailVerification:
          requiresEmailVerification ?? this.requiresEmailVerification,
      requiresPasswordReset:
          requiresPasswordReset ?? this.requiresPasswordReset,
      accessToken: accessToken ?? this.accessToken,
      idToken: idToken ?? this.idToken,
      refreshToken: refreshToken ?? this.refreshToken,
      tokenExpiresAt: tokenExpiresAt ?? this.tokenExpiresAt,
    );
  }

  /// Creates an authentication state with the given fields
  const AuthState({
    this.user,
    this.isAuthenticated = false,
    this.requiresMFA = false,
    this.requiresEmailVerification = false,
    this.requiresPasswordReset = false,
    this.accessToken,
    this.idToken,
    this.refreshToken,
    this.tokenExpiresAt,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AuthState &&
          runtimeType == other.runtimeType &&
          user == other.user &&
          isAuthenticated == other.isAuthenticated &&
          requiresMFA == other.requiresMFA &&
          requiresEmailVerification == other.requiresEmailVerification &&
          requiresPasswordReset == other.requiresPasswordReset &&
          accessToken == other.accessToken &&
          idToken == other.idToken &&
          refreshToken == other.refreshToken &&
          tokenExpiresAt == other.tokenExpiresAt;

  @override
  int get hashCode =>
      user.hashCode ^
      isAuthenticated.hashCode ^
      requiresMFA.hashCode ^
      requiresEmailVerification.hashCode ^
      requiresPasswordReset.hashCode ^
      accessToken.hashCode ^
      idToken.hashCode ^
      refreshToken.hashCode ^
      tokenExpiresAt.hashCode;
}
