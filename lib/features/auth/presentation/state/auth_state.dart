import 'package:equatable/equatable.dart';
import 'package:soloadventurer/features/auth/domain/entities/user.dart';

/// Represents the current state of authentication
class AuthState extends Equatable {
  /// Whether the authentication state is being determined
  final bool isLoading;

  /// The currently authenticated user, if any
  final User? user;

  /// Any error that occurred during authentication
  final String? error;

  /// Creates a new [AuthState]
  const AuthState({
    this.isLoading = false,
    this.user,
    this.error,
  });

  /// Initial unauthenticated state
  factory AuthState.initial() => const AuthState();

  /// Loading state while determining authentication
  factory AuthState.loading() => const AuthState(isLoading: true);

  /// Authenticated state with a user
  factory AuthState.authenticated(User user) => AuthState(user: user);

  /// Error state with an error message
  factory AuthState.error(String message) => AuthState(error: message);

  /// Whether the user is authenticated
  bool get isAuthenticated => user != null;

  /// Creates a copy of this state with the given fields replaced with new values
  AuthState copyWith({
    bool? isLoading,
    User? user,
    Object? error = const Object(),
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      user: user ?? this.user,
      error: error == const Object() ? this.error : error as String?,
    );
  }

  @override
  List<Object?> get props => [isLoading, user, error];
}
