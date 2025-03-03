import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soloadventurer/app/di/service_locator.dart';
import 'package:soloadventurer/features/auth/domain/entities/user.dart';
import 'package:soloadventurer/features/auth/domain/usecases/get_current_user.dart';
import 'package:soloadventurer/features/auth/domain/usecases/is_signed_in.dart';
import 'package:soloadventurer/features/auth/domain/usecases/login.dart';
import 'package:soloadventurer/features/auth/domain/usecases/sign_out.dart';
import 'package:soloadventurer/features/auth/domain/usecases/sign_up.dart';

/// Authentication state
class AuthState {
  final bool isLoading;
  final User? user;
  final String? error;
  final bool isAuthenticated;

  /// Creates a new [AuthState] with the given values
  const AuthState({
    this.isLoading = false,
    this.user,
    this.error,
    this.isAuthenticated = false,
  });

  /// Creates a copy of this state with the given values
  AuthState copyWith({
    bool? isLoading,
    User? user,
    String? error,
    bool? isAuthenticated,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      user: user ?? this.user,
      error: error, // Clear error if null is passed
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
    );
  }

  /// Initial state with no user and not authenticated
  factory AuthState.initial() => const AuthState();

  /// Loading state
  factory AuthState.loading() => const AuthState(isLoading: true);

  /// Authenticated state with user
  factory AuthState.authenticated(User user) => AuthState(
        isLoading: false,
        user: user,
        isAuthenticated: true,
      );

  /// Error state
  factory AuthState.error(String message) => AuthState(
        isLoading: false,
        error: message,
      );
}

/// Auth state notifier
class AuthNotifier extends StateNotifier<AuthState> {
  final GetCurrentUser _getCurrentUser;
  final IsSignedIn _isSignedIn;
  final LoginUseCase _login;
  final SignUp _signUp;
  final SignOut _signOut;

  /// Creates a new [AuthNotifier] with the given use cases
  AuthNotifier({
    required GetCurrentUser getCurrentUser,
    required IsSignedIn isSignedIn,
    required LoginUseCase login,
    required SignUp signUp,
    required SignOut signOut,
  })  : _getCurrentUser = getCurrentUser,
        _isSignedIn = isSignedIn,
        _login = login,
        _signUp = signUp,
        _signOut = signOut,
        super(AuthState.initial()) {
    // Initialize auth state when created
    initializeAuth();
  }

  /// Initialize the auth state by checking if the user is signed in
  Future<void> initializeAuth() async {
    state = AuthState.loading();

    try {
      final isAuthenticated = await _isSignedIn();

      if (isAuthenticated) {
        final user = await _getCurrentUser();

        if (user != null) {
          state = AuthState.authenticated(user);
          return;
        }
      }

      state = AuthState.initial();
    } catch (e) {
      state = AuthState.error(e.toString());
    }
  }

  /// Sign in with email and password
  Future<void> signIn({required String email, required String password}) async {
    state = AuthState.loading();

    try {
      final user = await _login(LoginParams(
        email: email,
        password: password,
      ));

      state = AuthState.authenticated(user);
    } catch (e) {
      state = AuthState.error(e.toString());
    }
  }

  /// Sign up with email, password and name
  Future<void> signUp({
    required String email,
    required String password,
    required String name,
  }) async {
    state = AuthState.loading();

    try {
      final user = await _signUp(SignUpParams(
        email: email,
        password: password,
        name: name,
      ));

      state = AuthState.authenticated(user);
    } catch (e) {
      state = AuthState.error(e.toString());
    }
  }

  /// Sign out
  Future<void> signOut() async {
    state = AuthState.loading();

    try {
      await _signOut();
      state = AuthState.initial();
    } catch (e) {
      state = AuthState.error(e.toString());
    }
  }

  /// Clear any error in the state
  void clearError() {
    state = state.copyWith(error: '');
  }
}

/// Provider for the auth state
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(
    getCurrentUser: getIt<GetCurrentUser>(),
    isSignedIn: getIt<IsSignedIn>(),
    login: getIt<LoginUseCase>(),
    signUp: getIt<SignUp>(),
    signOut: getIt<SignOut>(),
  );
});
