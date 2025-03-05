import 'package:equatable/equatable.dart';
import 'package:soloadventurer/features/auth/domain/entities/user.dart';

/// Represents the current state of authentication
class AuthState extends Equatable {
  /// The current user, if any
  final User? user;

  /// Whether the state is loading
  final bool isLoading;

  /// Any error message
  final String? error;

  /// The error code, if any
  final String? errorCode;

  /// Whether email verification is required
  final bool requiresEmailVerification;

  /// Whether password reset is required
  final bool requiresPasswordReset;

  /// Creates a new [AuthState]
  const AuthState({
    this.user,
    this.isLoading = false,
    this.error,
    this.errorCode,
    this.requiresEmailVerification = false,
    this.requiresPasswordReset = false,
  });

  /// Creates an initial state
  factory AuthState.initial() {
    return const AuthState();
  }

  /// Creates a loading state
  factory AuthState.loading() {
    return const AuthState(isLoading: true);
  }

  /// Creates an error state
  factory AuthState.error(String message, [String? code]) {
    return AuthState(
      error: message,
      errorCode: code,
    );
  }

  /// Creates an authenticated state
  factory AuthState.authenticated(User user) {
    return AuthState(user: user);
  }

  /// Creates an unverified state
  factory AuthState.unverified(User user) {
    return AuthState(
      user: user,
      requiresEmailVerification: true,
    );
  }

  /// Creates a copy of this state with the given fields replaced with new values
  AuthState copyWith({
    User? user,
    bool? isLoading,
    String? error,
    String? errorCode,
    bool? requiresEmailVerification,
    bool? requiresPasswordReset,
  }) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      errorCode: errorCode,
      requiresEmailVerification:
          requiresEmailVerification ?? this.requiresEmailVerification,
      requiresPasswordReset:
          requiresPasswordReset ?? this.requiresPasswordReset,
    );
  }

  /// Whether the user is logged in
  bool get isLoggedIn => user != null && !requiresEmailVerification;

  /// Whether the user is authenticated (has a valid user object)
  bool get isAuthenticated => user != null;

  /// Whether the user needs to verify their email
  bool get needsVerification => requiresEmailVerification;

  /// Whether the user is new (just registered)
  bool get isNewUser => user != null && requiresEmailVerification;

  @override
  List<Object?> get props => [
        user,
        isLoading,
        error,
        errorCode,
        requiresEmailVerification,
        requiresPasswordReset,
      ];

  @override
  String toString() {
    return 'AuthState(user: $user, isLoading: $isLoading, error: $error, errorCode: $errorCode, requiresEmailVerification: $requiresEmailVerification, requiresPasswordReset: $requiresPasswordReset)';
  }
}
