import 'package:flutter/foundation.dart';
import 'package:soloadventurer/features/auth/domain/entities/user.dart';

/// Represents the current authentication state of the application
@immutable
class AuthState {
  /// Whether authentication is in progress
  final bool isLoading;

  /// Whether the user is logged in
  final bool isLoggedIn;

  /// Current error message, if any
  final String? error;

  /// Error code for specific error handling
  final String? errorCode;

  /// Currently authenticated user
  final User? user;

  /// Access token for API calls
  final String? accessToken;

  /// Whether email verification is required
  final bool requiresEmailVerification;

  /// Whether password reset is required
  final bool requiresPasswordReset;

  /// Creates a new [AuthState]
  const AuthState({
    this.isLoading = false,
    this.isLoggedIn = false,
    this.error,
    this.errorCode,
    this.user,
    this.accessToken,
    this.requiresEmailVerification = false,
    this.requiresPasswordReset = false,
  });

  /// Creates a copy of this state with the given fields replaced
  AuthState copyWith({
    bool? isLoading,
    bool? isLoggedIn,
    String? error,
    String? errorCode,
    User? user,
    String? accessToken,
    bool? requiresEmailVerification,
    bool? requiresPasswordReset,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
      error: error, // Intentionally not using ?? to allow clearing errors
      errorCode:
          errorCode, // Intentionally not using ?? to allow clearing codes
      user: user ?? this.user,
      accessToken: accessToken ?? this.accessToken,
      requiresEmailVerification:
          requiresEmailVerification ?? this.requiresEmailVerification,
      requiresPasswordReset:
          requiresPasswordReset ?? this.requiresPasswordReset,
    );
  }

  /// Creates an initial state
  factory AuthState.initial() => const AuthState();

  /// Creates a loading state
  factory AuthState.loading() => const AuthState(isLoading: true);

  /// Creates an authenticated state
  factory AuthState.authenticated(User user, String accessToken) => AuthState(
        isLoggedIn: true,
        user: user,
        accessToken: accessToken,
      );

  /// Creates an error state
  factory AuthState.error(String message, [String? code]) => AuthState(
        error: message,
        errorCode: code,
      );

  /// Creates a state requiring email verification
  factory AuthState.requiresVerification(User user) => AuthState(
        user: user,
        requiresEmailVerification: true,
      );

  /// Creates a state requiring password reset
  factory AuthState.requiresPasswordReset(User user) => AuthState(
        user: user,
        requiresPasswordReset: true,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AuthState &&
          runtimeType == other.runtimeType &&
          isLoading == other.isLoading &&
          isLoggedIn == other.isLoggedIn &&
          error == other.error &&
          errorCode == other.errorCode &&
          user == other.user &&
          accessToken == other.accessToken &&
          requiresEmailVerification == other.requiresEmailVerification &&
          requiresPasswordReset == other.requiresPasswordReset;

  @override
  int get hashCode =>
      isLoading.hashCode ^
      isLoggedIn.hashCode ^
      error.hashCode ^
      errorCode.hashCode ^
      user.hashCode ^
      accessToken.hashCode ^
      requiresEmailVerification.hashCode ^
      requiresPasswordReset.hashCode;

  @override
  String toString() =>
      'AuthState(isLoading: $isLoading, isLoggedIn: $isLoggedIn, error: $error, '
      'errorCode: $errorCode, user: $user, hasToken: ${accessToken != null}, '
      'requiresEmailVerification: $requiresEmailVerification, '
      'requiresPasswordReset: $requiresPasswordReset)';
}
