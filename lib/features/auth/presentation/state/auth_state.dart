import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:soloadventurer/features/auth/domain/entities/user.dart';

part 'auth_state.freezed.dart';

/// Authentication state of the application
/// Freezed immutable class - all changes create new instances
///
/// Loading and error states are handled by AsyncValue wrapper,
/// not by manual flags in this state.
@freezed
class AuthState with _$AuthState {

  /// Creates a new AuthState instance
  const factory AuthState({
    /// Currently authenticated user (null if not logged in)
    User? user,

    /// Whether user is authenticated
    @Default(false) bool isAuthenticated,

    /// Whether user requires MFA
    @Default(false) bool requiresMFA,

    /// Whether user requires email verification
    @Default(false) bool requiresEmailVerification,

    /// Whether user requires password reset
    @Default(false) bool requiresPasswordReset,

    /// The access token for the current session
    String? accessToken,

    /// The ID token for the current session
    String? idToken,

    /// The refresh token for the current session
    String? refreshToken,

    /// The expiration time of the current session
    DateTime? tokenExpiresAt,

    /// Optional session token for tracking
    String? sessionToken,

    /// Last activity timestamp
    DateTime? lastActivity,
  }) = _AuthState;

  // Computed getters for convenience

  /// Whether a user object exists
  bool get hasUser => user != null;

  /// Whether user is logged in (authenticated AND has user)
  bool get isLoggedIn => isAuthenticated && hasUser;

  // Private constructor for freezed getters
  const AuthState._();

  /// Factory for initial unauthenticated state
  factory AuthState.initial() => const AuthState();

  /// Factory for authenticated state with user
  factory AuthState.authenticated({
    required User user,
    String? accessToken,
    String? idToken,
    String? refreshToken,
    DateTime? tokenExpiresAt,
    bool requiresMFA = false,
  }) =>
      AuthState(
        user: user,
        isAuthenticated: true,
        requiresMFA: requiresMFA,
        requiresEmailVerification: false,
        requiresPasswordReset: false,
        accessToken: accessToken,
        idToken: idToken,
        refreshToken: refreshToken,
        tokenExpiresAt: tokenExpiresAt,
      );

  /// Factory for unverified state
  factory AuthState.unverified({
    required User user,
  }) =>
      AuthState(
        user: user,
        isAuthenticated: false,
        requiresMFA: false,
        requiresEmailVerification: true,
        requiresPasswordReset: false,
      );

  /// Factory for MFA required state
  factory AuthState.mfaRequired({
    required User user,
  }) =>
      AuthState(
        user: user,
        isAuthenticated: false,
        requiresMFA: true,
        requiresEmailVerification: false,
        requiresPasswordReset: false,
      );

  /// Factory for password reset required state
  factory AuthState.passwordResetRequired({
    required User user,
  }) =>
      AuthState(
        user: user,
        isAuthenticated: false,
        requiresMFA: false,
        requiresEmailVerification: false,
        requiresPasswordReset: true,
      );

  /// Factory for unauthenticated state
  factory AuthState.unauthenticated() => const AuthState();
}
