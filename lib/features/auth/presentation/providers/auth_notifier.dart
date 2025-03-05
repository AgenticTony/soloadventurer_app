import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soloadventurer/app/di/service_locator.dart';
import 'package:soloadventurer/core/errors/exceptions.dart';
import 'package:soloadventurer/features/auth/domain/entities/user.dart';
import 'package:soloadventurer/features/auth/domain/usecases/get_current_user.dart';
import 'package:soloadventurer/features/auth/domain/usecases/is_signed_in.dart';
import 'package:soloadventurer/features/auth/domain/usecases/login.dart';
import 'package:soloadventurer/features/auth/domain/usecases/sign_out.dart';
import 'package:soloadventurer/features/auth/domain/usecases/sign_up.dart';
import 'package:soloadventurer/features/auth/domain/usecases/verify_email.dart';
import 'package:soloadventurer/features/auth/domain/usecases/forgot_password.dart';
import 'package:soloadventurer/features/auth/domain/usecases/confirm_password_reset.dart';
import 'package:soloadventurer/features/auth/presentation/state/auth_state.dart';
import 'package:flutter/foundation.dart';

/// Auth state notifier
class AuthNotifier extends StateNotifier<AuthState> {
  final GetCurrentUser _getCurrentUser;
  final IsSignedIn _isSignedIn;
  final LoginUseCase _login;
  final SignUp _signUp;
  final SignOut _signOut;
  final VerifyEmail _verifyEmail;
  final ForgotPassword _forgotPassword;
  final ConfirmPasswordReset _confirmPasswordReset;

  /// Creates a new [AuthNotifier] with the given use cases
  AuthNotifier({
    required GetCurrentUser getCurrentUser,
    required IsSignedIn isSignedIn,
    required LoginUseCase login,
    required SignUp signUp,
    required SignOut signOut,
    required VerifyEmail verifyEmail,
    required ForgotPassword forgotPassword,
    required ConfirmPasswordReset confirmPasswordReset,
  })  : _getCurrentUser = getCurrentUser,
        _isSignedIn = isSignedIn,
        _login = login,
        _signUp = signUp,
        _signOut = signOut,
        _verifyEmail = verifyEmail,
        _forgotPassword = forgotPassword,
        _confirmPasswordReset = confirmPasswordReset,
        super(AuthState.initial());

  /// Set state to authenticated with user
  void setAuthenticated(User user) {
    if (!mounted) return;
    state = AuthState.authenticated(user);
  }

  /// Set state to initial
  void setInitial() {
    if (!mounted) return;
    state = AuthState.initial();
  }

  /// Set state to loading
  void setLoading() {
    if (!mounted) return;
    state = AuthState.loading();
  }

  /// Set state to error
  void setError(String message) {
    if (!mounted) return;
    state = AuthState.error(message);
  }

  /// Sign in with email and password
  Future<void> signIn(String email, String password) async {
    if (!mounted) return;
    setLoading();

    try {
      final user = await _login(LoginParams(
        email: email,
        password: password,
      ));

      if (!mounted) return;
      setAuthenticated(user);
    } catch (e) {
      if (!mounted) return;
      setError(e.toString());
    }
  }

  /// Register with email and password
  Future<void> signUp({
    required String email,
    required String password,
    required String name,
  }) async {
    debugPrint('AuthNotifier: Starting sign up');
    state = AuthState.loading();

    try {
      final result = await _signUp(SignUpParams(
        email: email,
        password: password,
        name: name,
      ));
      final (user, needsVerification) = result;

      if (needsVerification) {
        state = AuthState.unverified(user);
      } else {
        state = AuthState.authenticated(user);
      }
    } catch (e) {
      state = AuthState.error(e.toString());
    }
  }

  /// Sign out
  Future<void> signOut() async {
    if (!mounted) return;
    setLoading();

    try {
      await _signOut();
      if (!mounted) return;
      setInitial();
    } catch (e) {
      if (!mounted) return;
      setError(e.toString());
    }
  }

  /// Verify email with confirmation code
  Future<void> verifyEmail(String code, String email) async {
    final currentUser = state.user;
    state = AuthState.loading().copyWith(user: currentUser);

    try {
      await _verifyEmail(VerifyEmailParams(code: code, email: email));

      if (currentUser != null) {
        state = AuthState.authenticated(currentUser);
      } else {
        final user = await _getCurrentUser();
        if (user != null) {
          state = AuthState.authenticated(user);
        } else {
          state = AuthState.initial();
        }
      }
    } catch (e) {
      state = AuthState.error(e.toString()).copyWith(user: currentUser);
    }
  }

  /// Initiates password reset process
  Future<void> forgotPassword(ForgotPasswordParams params) async {
    try {
      state = state.copyWith(isLoading: true);
      await _forgotPassword(params);
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false);
      rethrow;
    }
  }

  /// Confirm password reset with code and new password
  Future<void> confirmPasswordReset({
    required String email,
    required String code,
    required String newPassword,
  }) async {
    if (!mounted) return;
    state = AuthState.loading();

    try {
      await _confirmPasswordReset(ConfirmPasswordResetParams(
        email: email,
        code: code,
        newPassword: newPassword,
      ));
      if (!mounted) return;
      state = AuthState.initial();
    } catch (e) {
      if (!mounted) return;
      state = AuthState.error(e.toString());
    }
  }

  /// Clear any error in the state
  void clearError() {
    if (!mounted) return;
    state = state.copyWith(error: null);
  }

  /// Clear verification state when going back to signup
  void clearVerificationState() {
    if (!mounted) return;
    state = state.copyWith(
      requiresEmailVerification: false,
      error: null,
    );
  }

  /// Resend verification email
  Future<void> resendVerificationEmail() async {
    if (!mounted) return;
    final currentUser = state.user;
    state = AuthState.loading().copyWith(user: currentUser);

    try {
      await _verifyEmail(VerifyEmailParams(
        code: '', // Empty code for resend
        email: currentUser?.email ?? '',
      ));

      if (currentUser != null) {
        state = AuthState.unverified(currentUser);
      } else {
        state = AuthState.initial();
      }
    } catch (e) {
      state = AuthState.error(e.toString()).copyWith(user: currentUser);
    }
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
    verifyEmail: getIt<VerifyEmail>(),
    forgotPassword: getIt<ForgotPassword>(),
    confirmPasswordReset: getIt<ConfirmPasswordReset>(),
  );
});
