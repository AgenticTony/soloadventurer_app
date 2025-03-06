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

/// Auth initialization provider
final authInitProvider = FutureProvider.autoDispose((ref) async {
  final isSignedIn = getIt<IsSignedIn>();
  final getCurrentUser = getIt<GetCurrentUser>();

  final isAuthenticated = await isSignedIn();
  if (isAuthenticated) {
    final user = await getCurrentUser();
    if (user != null) {
      ref.read(authProvider.notifier).setAuthenticated(user);
      return;
    }
  }
  ref.read(authProvider.notifier).setInitial();
});

/// Auth state notifier
class AuthNotifier extends StateNotifier<AuthState> {
  final GetCurrentUser _getCurrentUser;
  final IsSignedIn _isSignedIn;
  final LoginUseCase _login;
  final SignUp _signUp;
  final SignOut _signOut;
  final VerifyEmail _verifyEmail;
  final ResendVerificationEmail _resendVerificationEmail;
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
    required ResendVerificationEmail resendVerificationEmail,
    required ForgotPassword forgotPassword,
    required ConfirmPasswordReset confirmPasswordReset,
  })  : _getCurrentUser = getCurrentUser,
        _isSignedIn = isSignedIn,
        _login = login,
        _signUp = signUp,
        _signOut = signOut,
        _verifyEmail = verifyEmail,
        _resendVerificationEmail = resendVerificationEmail,
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
    debugPrint('AuthNotifier: Current state before loading: $state');
    state = AuthState.loading();
    debugPrint('AuthNotifier: State set to loading: $state');

    try {
      debugPrint('AuthNotifier: Calling _signUp use case');
      final result = await _signUp(SignUpParams(
        email: email,
        password: password,
        name: name,
      ));
      final (user, needsVerification) = result;
      debugPrint('AuthNotifier: Sign up successful, user: $user');
      debugPrint('AuthNotifier: Needs verification: $needsVerification');
      debugPrint('AuthNotifier: Current state before setting state: $state');

      if (needsVerification) {
        debugPrint('AuthNotifier: Creating unverified state');
        final unverifiedState = AuthState.unverified(user);
        debugPrint('AuthNotifier: Unverified state created: $unverifiedState');
        debugPrint('AuthNotifier: Setting state to unverified');
        state = unverifiedState;
        debugPrint('AuthNotifier: New state set: $state');
        debugPrint(
            'AuthNotifier: requiresEmailVerification: ${state.requiresEmailVerification}');
        debugPrint('AuthNotifier: user: ${state.user}');
      } else {
        state = AuthState.authenticated(user);
      }
    } catch (e) {
      debugPrint('AuthNotifier: Sign up failed: $e');
      debugPrint('AuthNotifier: Setting error state');
      state = AuthState.error(e.toString());
      debugPrint('AuthNotifier: Error state set: $state');
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
    debugPrint('AuthNotifier: Starting email verification');
    debugPrint('AuthNotifier: Current state before loading: $state');

    // Preserve the current user while setting loading state
    final currentUser = state.user;
    state = AuthState.loading().copyWith(user: currentUser);
    debugPrint('AuthNotifier: Loading state with preserved user: $state');

    try {
      await _verifyEmail(VerifyEmailParams(code: code, email: email));
      debugPrint('AuthNotifier: Email verification successful');

      // After successful verification, use the current user directly
      if (currentUser != null) {
        debugPrint(
            'AuthNotifier: Setting authenticated state with current user');
        state = AuthState.authenticated(currentUser);
      } else {
        debugPrint(
            'AuthNotifier: No user available, attempting to get current user');
        try {
          final user = await _getCurrentUser();
          if (user != null) {
            debugPrint(
                'AuthNotifier: Setting authenticated state with fetched user');
            state = AuthState.authenticated(user);
          } else {
            debugPrint(
                'AuthNotifier: No user data available, setting initial state');
            state = AuthState.initial();
          }
        } catch (e) {
          debugPrint('AuthNotifier: Error getting user after verification: $e');
          throw AuthException('Failed to get user after verification');
        }
      }
    } catch (e) {
      debugPrint('AuthNotifier: Email verification failed: $e');
      // Preserve the user even in error state
      state = AuthState.error(e.toString()).copyWith(user: currentUser);
    }
  }

  /// Resend verification email
  Future<void> resendVerificationEmail() async {
    debugPrint('AuthNotifier: Resending verification email');

    // Preserve the current user while setting loading state
    final currentUser = state.user;
    state = AuthState.loading().copyWith(user: currentUser);
    debugPrint('AuthNotifier: Loading state with preserved user: $state');

    try {
      await _resendVerificationEmail();
      debugPrint('AuthNotifier: Verification email resent successfully');

      if (currentUser != null) {
        debugPrint(
            'AuthNotifier: Setting unverified state with preserved user');
        state = AuthState.unverified(currentUser);
      } else {
        debugPrint('AuthNotifier: No user to preserve, checking current user');
        final user = await _getCurrentUser();
        if (user != null) {
          state = AuthState.unverified(user);
        } else {
          state = AuthState.initial();
        }
      }
    } catch (e) {
      debugPrint('AuthNotifier: Failed to resend verification email: $e');
      // Preserve the user even in error state
      state = AuthState.error(e.toString()).copyWith(user: currentUser);
    }
  }

  /// Initiates password reset process
  Future<void> forgotPassword(ForgotPasswordParams params) async {
    try {
      state = state.copyWith(isLoading: true);
      await _forgotPassword(params);
      state = state.copyWith(
        isLoading: false,
        requiresPasswordReset: true,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
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
      state = AuthState.initial(); // User needs to sign in with new password
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
    resendVerificationEmail: getIt<ResendVerificationEmail>(),
    forgotPassword: getIt<ForgotPassword>(),
    confirmPasswordReset: getIt<ConfirmPasswordReset>(),
  );
});
