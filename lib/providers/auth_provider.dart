import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/auth_service.dart';
import '../services/session_manager.dart';

// Auth state enum
enum AuthState {
  initial,
  authenticated,
  unauthenticated,
  loading,
  error,
}

// Auth state class
class AuthStateData {
  final AuthState state;
  final String? username;
  final String? errorMessage;

  AuthStateData({
    required this.state,
    this.username,
    this.errorMessage,
  });

  AuthStateData copyWith({
    AuthState? state,
    String? username,
    String? errorMessage,
  }) {
    return AuthStateData(
      state: state ?? this.state,
      username: username ?? this.username,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

// Auth notifier
class AuthNotifier extends StateNotifier<AuthStateData> {
  final AuthService _authService;
  final SessionManager _sessionManager = SessionManager();

  AuthNotifier(this._authService)
      : super(AuthStateData(state: AuthState.initial)) {
    _initialize();
  }

  Future<void> _initialize() async {
    state = state.copyWith(state: AuthState.loading);

    await _sessionManager.initialize();

    if (_sessionManager.isAuthenticated) {
      state = AuthStateData(
        state: AuthState.authenticated,
        username: _sessionManager.username,
      );
    } else {
      state = AuthStateData(state: AuthState.unauthenticated);
    }
  }

  Future<void> signIn({
    required String username,
    required String password,
  }) async {
    state = state.copyWith(state: AuthState.loading);

    try {
      final success = await _authService.signIn(
        username: username,
        password: password,
      );

      if (success) {
        // Start session management
        await _sessionManager.startSession();

        state = AuthStateData(
          state: AuthState.authenticated,
          username: username,
        );
      } else {
        state = AuthStateData(
          state: AuthState.error,
          errorMessage: 'Invalid credentials',
        );
      }
    } catch (e) {
      state = AuthStateData(
        state: AuthState.error,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> signUp({
    required String username,
    required String password,
    required String email,
    required String firstName,
    required String lastName,
    required String displayName,
  }) async {
    state = state.copyWith(state: AuthState.loading);

    try {
      final success = await _authService.signUp(
        username: username,
        password: password,
        email: email,
        firstName: firstName,
        lastName: lastName,
        displayName: displayName,
      );

      if (success) {
        state = AuthStateData(
          state: AuthState.unauthenticated,
          username: username,
        );
      } else {
        state = AuthStateData(
          state: AuthState.error,
          errorMessage: 'Failed to sign up',
        );
      }
    } catch (e) {
      state = AuthStateData(
        state: AuthState.error,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> confirmSignUp({
    required String username,
    required String confirmationCode,
  }) async {
    state = state.copyWith(state: AuthState.loading);

    try {
      final success = await _authService.confirmSignUp(
        username: username,
        confirmationCode: confirmationCode,
      );

      if (success) {
        state = AuthStateData(state: AuthState.unauthenticated);
      } else {
        state = AuthStateData(
          state: AuthState.error,
          errorMessage: 'Failed to confirm sign up',
        );
      }
    } catch (e) {
      state = AuthStateData(
        state: AuthState.error,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> signOut() async {
    state = state.copyWith(state: AuthState.loading);

    try {
      // End session management
      await _sessionManager.endSession();

      state = AuthStateData(state: AuthState.unauthenticated);
    } catch (e) {
      state = AuthStateData(
        state: AuthState.error,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> refreshSession() async {
    state = state.copyWith(state: AuthState.loading);

    try {
      final success = await _sessionManager.forceTokenRefresh();

      if (success) {
        state = AuthStateData(
          state: AuthState.authenticated,
          username: _sessionManager.username,
        );
      } else {
        state = AuthStateData(state: AuthState.unauthenticated);
      }
    } catch (e) {
      state = AuthStateData(
        state: AuthState.error,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> forgotPassword({required String username}) async {
    state = state.copyWith(state: AuthState.loading);

    try {
      final success = await _authService.forgotPassword(username: username);

      if (success) {
        state = AuthStateData(
          state: AuthState.unauthenticated,
          username: username,
        );
      } else {
        state = AuthStateData(
          state: AuthState.error,
          errorMessage: 'Failed to initiate password reset',
        );
      }
    } catch (e) {
      state = AuthStateData(
        state: AuthState.error,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> confirmForgotPassword({
    required String confirmationCode,
    required String newPassword,
  }) async {
    state = state.copyWith(state: AuthState.loading);

    try {
      final success = await _authService.confirmForgotPassword(
        confirmationCode: confirmationCode,
        newPassword: newPassword,
      );

      if (success) {
        state = AuthStateData(state: AuthState.unauthenticated);
      } else {
        state = AuthStateData(
          state: AuthState.error,
          errorMessage: 'Failed to confirm new password',
        );
      }
    } catch (e) {
      state = AuthStateData(
        state: AuthState.error,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> resendConfirmationCode({required String username}) async {
    state = state.copyWith(state: AuthState.loading);

    try {
      final success = await _authService.resendConfirmationCode(
        username: username,
      );

      if (success) {
        state = AuthStateData(
          state: AuthState.unauthenticated,
          username: username,
        );
      } else {
        state = AuthStateData(
          state: AuthState.error,
          errorMessage: 'Failed to resend confirmation code',
        );
      }
    } catch (e) {
      state = AuthStateData(
        state: AuthState.error,
        errorMessage: e.toString(),
      );
    }
  }
}

// Providers
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

final authProvider = StateNotifierProvider<AuthNotifier, AuthStateData>((ref) {
  final authService = ref.watch(authServiceProvider);
  return AuthNotifier(authService);
});
