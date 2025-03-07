import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soloadventurer/core/errors/exceptions.dart';
import 'package:soloadventurer/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:soloadventurer/features/auth/domain/state/auth_state.dart';

/// Notifier that manages authentication state
class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRemoteDataSource _authDataSource;

  /// Creates a new [AuthNotifier]
  AuthNotifier(this._authDataSource) : super(AuthState.initial()) {
    _initializeAuthState();
  }

  /// Initialize the authentication state
  Future<void> _initializeAuthState() async {
    state = AuthState.loading();
    try {
      final user = await _authDataSource.getCurrentUser();
      if (user != null) {
        state = AuthState.authenticated(user, ''); // TODO: Get actual token
      } else {
        state = AuthState.initial();
      }
    } catch (e) {
      state = AuthState.error(e.toString());
    }
  }

  /// Sign in with email and password
  Future<void> signIn(String email, String password) async {
    state = AuthState.loading();
    try {
      final (user, token) = await _authDataSource.signIn(email, password);
      state = AuthState.authenticated(user, token);
    } on AuthException catch (e) {
      if (e.code == 'EMAIL_NOT_VERIFIED') {
        // Keep the current user in state for verification
        state = AuthState.requiresVerification(state.user!);
      } else if (e.code == 'PASSWORD_RESET_REQUIRED') {
        // Keep the current user in state for password reset
        state = AuthState.requiresPasswordReset(state.user!);
      } else {
        state = AuthState.error(e.message, e.code);
      }
    } catch (e) {
      state = AuthState.error(e.toString());
    }
  }

  /// Register a new user
  Future<void> register({
    required String email,
    required String password,
    required String name,
  }) async {
    state = AuthState.loading();
    try {
      final (user, requiresVerification) = await _authDataSource.register(
        email: email,
        password: password,
        name: name,
      );

      if (requiresVerification) {
        state = AuthState.requiresVerification(user);
      } else {
        state =
            AuthState.authenticated(user, ''); // Token will be set on sign in
      }
    } on AuthException catch (e) {
      state = AuthState.error(e.message, e.code);
    } catch (e) {
      state = AuthState.error(e.toString());
    }
  }

  /// Verify email with confirmation code
  Future<void> verifyEmail(String code) async {
    if (!state.requiresEmailVerification) {
      state = AuthState.error('No email verification pending');
      return;
    }

    state = state.copyWith(isLoading: true, error: null);
    try {
      await _authDataSource.verifyEmail(code, state.user!.email);
      // After verification, user needs to sign in
      state = AuthState.initial();
    } on AuthException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.message,
        errorCode: e.code,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Request password reset
  Future<void> forgotPassword(String email) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _authDataSource.forgotPassword(email);
      state = state.copyWith(
        isLoading: false,
        requiresPasswordReset: true,
      );
    } on AuthException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.message,
        errorCode: e.code,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Complete password reset
  Future<void> confirmPasswordReset(
    String email,
    String code,
    String newPassword,
  ) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _authDataSource.confirmForgotPassword(email, code, newPassword);
      state = AuthState.initial(); // User needs to sign in with new password
    } on AuthException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.message,
        errorCode: e.code,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Sign out the current user
  Future<void> signOut() async {
    state = state.copyWith(isLoading: true);
    try {
      await _authDataSource.signOut();
      state = AuthState.initial();
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Resend verification email
  Future<void> resendVerificationEmail() async {
    if (!state.requiresEmailVerification) {
      state = AuthState.error('No email verification pending');
      return;
    }

    state = state.copyWith(isLoading: true, error: null);
    try {
      await _authDataSource.resendVerificationEmail();
      state = state.copyWith(isLoading: false);
    } on AuthException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.message,
        errorCode: e.code,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }
}
