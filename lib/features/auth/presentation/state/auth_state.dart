import 'package:equatable/equatable.dart';
import 'package:soloadventurer/features/auth/domain/entities/user.dart';

/// Represents the current state of authentication
class AuthState extends Equatable {
  /// Whether the authentication state is being determined
  final bool isLoading;

  /// Whether the user is authenticated
  final bool isAuthenticated;

  /// Whether this is a newly registered user
  final bool isNewUser;

  /// Whether the user needs to be verified
  final bool needsVerification;

  /// The currently authenticated user, if any
  final User? user;

  /// Any error that occurred during authentication
  final String? error;

  /// Creates a new [AuthState]
  const AuthState({
    this.isLoading = false,
    this.isAuthenticated = false,
    this.isNewUser = false,
    this.needsVerification = false,
    this.user,
    this.error,
  });

  /// Initial unauthenticated state
  factory AuthState.initial() => const AuthState();

  /// Loading state while determining authentication
  factory AuthState.loading() => const AuthState(isLoading: true);

  /// Authenticated state with a user
  factory AuthState.authenticated(User user, {bool isNewUser = false}) =>
      AuthState(
        isAuthenticated: true,
        isNewUser: isNewUser,
        user: user,
      );

  /// Unverified state
  factory AuthState.unverified(User user) => AuthState(
        isAuthenticated: false,
        needsVerification: true,
        user: user,
      );

  /// Error state with an error message
  factory AuthState.error(String message) => AuthState(error: message);

  /// Creates a copy of this state with the given fields replaced with new values
  AuthState copyWith({
    bool? isLoading,
    bool? isAuthenticated,
    bool? isNewUser,
    bool? needsVerification,
    User? user,
    String? error,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      isNewUser: isNewUser ?? this.isNewUser,
      needsVerification: needsVerification ?? this.needsVerification,
      user: user ?? this.user,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props =>
      [isLoading, isAuthenticated, isNewUser, needsVerification, user, error];

  @override
  String toString() {
    return 'AuthState{isLoading: $isLoading, isAuthenticated: $isAuthenticated, isNewUser: $isNewUser, needsVerification: $needsVerification, user: $user, error: $error}';
  }
}
