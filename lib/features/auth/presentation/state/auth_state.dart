import 'package:equatable/equatable.dart';
import 'package:soloadventurer/features/auth/domain/entities/user.dart';

/// Authentication state of the application
/// Immutable class - all changes create new instances via copyWith
///
/// Loading and error states are handled by AsyncValue wrapper,
/// not by manual flags in this state.
class AuthState extends Equatable {
  /// Currently authenticated user (null if not logged in)
  final User? user;

  /// Whether user is authenticated
  final bool isAuthenticated;

  /// Whether user requires MFA
  final bool requiresMFA;

  /// Whether user requires email verification
  final bool requiresEmailVerification;

  /// Whether user requires password reset
  final bool requiresPasswordReset;

  /// The access token for the current session
  final String? accessToken;

  /// The ID token for the current session
  final String? idToken;

  /// The refresh token for the current session
  final String? refreshToken;

  /// The expiration time of the current session
  final DateTime? tokenExpiresAt;

  /// Optional session token for tracking
  final String? sessionToken;

  /// Last activity timestamp
  final DateTime? lastActivity;

  /// Creates a new AuthState instance
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
    this.sessionToken,
    this.lastActivity,
  });

  /// Initial unauthenticated state
  factory AuthState.initial() => const AuthState();

  /// Unauthenticated state
  factory AuthState.unauthenticated() => const AuthState(isAuthenticated: false);

  /// Creates an authenticated state from a user
  factory AuthState.authenticated({
    required User user,
    String? accessToken,
    String? idToken,
    String? refreshToken,
    DateTime? tokenExpiresAt,
  }) {
    return AuthState(
      user: user,
      isAuthenticated: true,
      accessToken: accessToken,
      idToken: idToken,
      refreshToken: refreshToken,
      tokenExpiresAt: tokenExpiresAt,
    );
  }

  /// Creates an unverified state (user exists but email not verified)
  factory AuthState.unverified({required User user}) {
    return AuthState(
      user: user,
      isAuthenticated: false,
      requiresEmailVerification: true,
    );
  }

  /// Creates an MFA required state
  factory AuthState.mfaRequired({required User user}) {
    return AuthState(
      user: user,
      isAuthenticated: false,
      requiresMFA: true,
    );
  }

  /// Creates a password reset required state
  factory AuthState.passwordResetRequired({required User user}) {
    return AuthState(
      user: user,
      isAuthenticated: false,
      requiresPasswordReset: true,
    );
  }

  @override
  List<Object?> get props => [
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
        lastActivity,
      ];

  /// Creates a copy of this state with the given fields replaced
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
    String? sessionToken,
    DateTime? lastActivity,
    // Use nullable bool to allow setting to null
    bool? clearUser,
    bool? clearAccessToken,
    bool? clearIdToken,
    bool? clearRefreshToken,
    bool? clearTokenExpiresAt,
    bool? clearSessionToken,
    bool? clearLastActivity,
  }) {
    return AuthState(
      user: clearUser == true ? null : (user ?? this.user),
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      requiresMFA: requiresMFA ?? this.requiresMFA,
      requiresEmailVerification:
          requiresEmailVerification ?? this.requiresEmailVerification,
      requiresPasswordReset:
          requiresPasswordReset ?? this.requiresPasswordReset,
      accessToken: clearAccessToken == true ? null : (accessToken ?? this.accessToken),
      idToken: clearIdToken == true ? null : (idToken ?? this.idToken),
      refreshToken: clearRefreshToken == true ? null : (refreshToken ?? this.refreshToken),
      tokenExpiresAt: clearTokenExpiresAt == true ? null : (tokenExpiresAt ?? this.tokenExpiresAt),
      sessionToken: clearSessionToken == true ? null : (sessionToken ?? this.sessionToken),
      lastActivity: clearLastActivity == true ? null : (lastActivity ?? this.lastActivity),
    );
  }

  /// Whether a user object exists
  bool get hasUser => user != null;

  /// Whether user is logged in (authenticated AND has user)
  bool get isLoggedIn => isAuthenticated && hasUser;

  @override
  String toString() {
    return 'AuthState{'
        'isAuthenticated: $isAuthenticated, '
        'requiresMFA: $requiresMFA, '
        'requiresEmailVerification: $requiresEmailVerification, '
        'requiresPasswordReset: $requiresPasswordReset, '
        'hasUser: $hasUser, '
        'isLoggedIn: $isLoggedIn'
        '}';
  }
}
