import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soloadventurer/features/auth/domain/entities/user.dart';
import 'package:soloadventurer/features/auth/domain/repositories/auth_repository.dart';
import 'package:soloadventurer/features/auth/domain/usecases/get_current_user.dart';
import 'package:soloadventurer/features/auth/domain/usecases/is_signed_in.dart';
import 'package:soloadventurer/features/auth/domain/usecases/login.dart';
import 'package:soloadventurer/features/auth/domain/usecases/sign_out.dart';
import 'package:soloadventurer/features/auth/domain/usecases/sign_up.dart';
import 'package:soloadventurer/features/auth/domain/usecases/verify_email.dart';
import 'package:soloadventurer/features/auth/domain/usecases/resend_verification_email.dart'
    as resend;
import 'package:soloadventurer/features/auth/domain/usecases/forgot_password.dart';
import 'package:soloadventurer/features/auth/domain/usecases/confirm_password_reset.dart';
import 'package:soloadventurer/features/auth/presentation/state/auth_state.dart';
import 'package:soloadventurer/features/core/domain/services/logging_service.dart';

/// Provider for the auth repository
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  throw UnimplementedError('authRepositoryProvider must be overridden');
});

/// Provider for the auth notifier
///
/// This provider uses `keepAlive()` to preserve authentication state
/// throughout the app lifecycle. The auth state should persist even when
/// no widgets are actively listening (e.g., during navigation).
///
/// Cleanup is handled via `ref.onDispose()` to ensure proper disposal
/// of resources when the provider container is disposed.
final authNotifierProvider =
    StateNotifierProvider<AuthNotifier, AsyncValue<AuthState>>((ref) {
  throw UnimplementedError('authNotifierProvider must be overridden');
  // Note: Implementation should:
  // 1. Create the notifier with required dependencies
  // 2. Call ref.keepAlive() to preserve auth state
  // 3. Add ref.onDispose(() => notifier.dispose()) for cleanup
});

/// Provider for the logging service
final loggingServiceProvider = Provider<LoggingService>((ref) {
  throw UnimplementedError('loggingServiceProvider must be overridden');
});

/// Auth notifier that manages the authentication state
class AuthNotifier extends StateNotifier<AsyncValue<AuthState>> {
  final GetCurrentUser _getCurrentUser;
  final IsSignedIn _isSignedIn;
  final LoginUseCase _login;
  final SignUp _signUp;
  final SignOut _signOut;
  final VerifyEmail _verifyEmail;
  final resend.ResendVerificationEmail _resendVerificationEmail;
  final ForgotPassword _forgotPassword;
  final ConfirmPasswordReset _confirmPasswordReset;
  final LoggingService _logger;

  /// Creates a new [AuthNotifier]
  AuthNotifier({
    required GetCurrentUser getCurrentUser,
    required IsSignedIn isSignedIn,
    required LoginUseCase login,
    required SignUp signUp,
    required SignOut signOut,
    required VerifyEmail verifyEmail,
    required resend.ResendVerificationEmail resendVerificationEmail,
    required ForgotPassword forgotPassword,
    required ConfirmPasswordReset confirmPasswordReset,
    required LoggingService logger,
  })  : _getCurrentUser = getCurrentUser,
        _isSignedIn = isSignedIn,
        _login = login,
        _signUp = signUp,
        _signOut = signOut,
        _verifyEmail = verifyEmail,
        _resendVerificationEmail = resendVerificationEmail,
        _forgotPassword = forgotPassword,
        _confirmPasswordReset = confirmPasswordReset,
        _logger = logger,
        super(const AsyncValue.data(AuthState.initial()));

  /// Initialize the auth state
  Future<void> initialize() async {
    if (!mounted) return;

    state = const AsyncValue.loading();

    final newState = await AsyncValue.guard(() async {
      final isAuthenticated = await _isSignedIn();
      if (isAuthenticated) {
        final user = await _getCurrentUser();
        if (user != null) {
          return AuthState.authenticated(user);
        }
      }
      return const AuthState.initial();
    });

    if (!mounted) return;
    state = newState;
  }

  /// Sign in with email and password
  Future<void> signIn(String email, String password) async {
    if (!mounted) return;

    state = const AsyncValue.loading();

    try {
      final user = await _login(LoginParams(email: email, password: password));
      if (!mounted) return;
      state = AsyncValue.data(AuthState.authenticated(user));
    } catch (e, stack) {
      if (!mounted) return;
      state = AsyncValue.error(e.toString(), stack);
    }
  }

  /// Sign up a new user
  Future<void> signUp({
    required String email,
    required String password,
    required String name,
  }) async {
    if (!mounted) return;

    state = const AsyncValue.loading();

    try {
      final (user, needsVerification) = await _signUp(SignUpParams(
        email: email,
        password: password,
        name: name,
      ));

      if (!mounted) return;

      if (needsVerification) {
        state = AsyncValue.data(AuthState.unverified(user: user));
      } else {
        state = AsyncValue.data(AuthState.authenticated(user));
      }
    } catch (e, stack) {
      if (!mounted) return;
      state = AsyncValue.error(e.toString(), stack);
    }
  }

  /// Sign out the current user
  Future<void> signOut() async {
    if (!mounted) return;

    state = const AsyncValue.loading();

    try {
      await _signOut();
      if (!mounted) return;
      state = const AsyncValue.data(AuthState.initial());
    } catch (e, stack) {
      if (!mounted) return;
      state = AsyncValue.error(e.toString(), stack);
    }
  }

  /// Verify email with confirmation code
  Future<void> verifyEmail(String code, String email) async {
    if (!mounted) return;

    state = const AsyncValue.loading();

    try {
      await _verifyEmail(VerifyEmailParams(code: code, email: email));
      if (!mounted) return;
      state = const AsyncValue.data(AuthState.initial());
    } catch (e, stack) {
      if (!mounted) return;
      state = AsyncValue.error(e.toString(), stack);
    }
  }

  /// Request password reset
  Future<void> forgotPassword(String email) async {
    if (!mounted) return;

    state = const AsyncValue.loading();

    try {
      await _forgotPassword(ForgotPasswordParams(identifier: email));
      if (!mounted) return;
      state = const AsyncValue.data(AuthState.initial());
    } catch (e, stack) {
      if (!mounted) return;
      state = AsyncValue.error(e.toString(), stack);
    }
  }

  /// Confirm password reset
  Future<void> confirmPasswordReset({
    required String email,
    required String code,
    required String newPassword,
  }) async {
    if (!mounted) return;

    state = const AsyncValue.loading();

    try {
      await _confirmPasswordReset(ConfirmPasswordResetParams(
        email: email,
        code: code,
        newPassword: newPassword,
      ));
      if (!mounted) return;
      state = const AsyncValue.data(AuthState.initial());
    } catch (e, stack) {
      if (!mounted) return;
      state = AsyncValue.error(e.toString(), stack);
    }
  }

  /// Resend verification email
  Future<void> resendVerificationEmail() async {
    if (!mounted) return;

    state = const AsyncValue.loading();

    try {
      await _resendVerificationEmail();
      if (!mounted) return;

      // Keep the current state but remove loading
      if (state.hasValue) {
        state = AsyncValue.data(state.value!);
      } else {
        state = const AsyncValue.data(AuthState.initial());
      }
    } catch (e, stack) {
      if (!mounted) return;
      state = AsyncValue.error(e.toString(), stack);
    }
  }
}
