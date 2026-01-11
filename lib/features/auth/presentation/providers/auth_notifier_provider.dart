import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter/foundation.dart';
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
import 'package:soloadventurer/features/core/domain/services/logging_service.dart';
import 'package:soloadventurer/features/auth/domain/usecases/resend_verification_email.dart'
    as resend;

part 'auth_notifier_provider.g.dart';

/// Provider for GetCurrentUser use case
@riverpod
GetCurrentUser getCurrentUser(GetCurrentUserRef ref) {
  throw UnimplementedError('getCurrentUserProvider must be overridden');
}

/// Provider for IsSignedIn use case
@riverpod
IsSignedIn isSignedIn(IsSignedInRef ref) {
  throw UnimplementedError('isSignedInProvider must be overridden');
}

/// Provider for LoginUseCase
@riverpod
LoginUseCase loginUseCase(LoginUseCaseRef ref) {
  throw UnimplementedError('loginUseCaseProvider must be overridden');
}

/// Provider for SignUp use case
@riverpod
SignUp signUp(SignUpRef ref) {
  throw UnimplementedError('signUpProvider must be overridden');
}

/// Provider for SignOut use case
@riverpod
SignOut signOut(SignOutRef ref) {
  throw UnimplementedError('signOutProvider must be overridden');
}

/// Provider for VerifyEmail use case
@riverpod
VerifyEmail verifyEmail(VerifyEmailRef ref) {
  throw UnimplementedError('verifyEmailProvider must be overridden');
}

/// Provider for ResendVerificationEmail use case
@riverpod
resend.ResendVerificationEmail resendVerificationEmail(
    ResendVerificationEmailRef ref) {
  throw UnimplementedError(
      'resendVerificationEmailProvider must be overridden');
}

/// Provider for ForgotPassword use case
@riverpod
ForgotPassword forgotPassword(ForgotPasswordRef ref) {
  throw UnimplementedError('forgotPasswordProvider must be overridden');
}

/// Provider for ConfirmPasswordReset use case
@riverpod
ConfirmPasswordReset confirmPasswordReset(ConfirmPasswordResetRef ref) {
  throw UnimplementedError('confirmPasswordResetProvider must be overridden');
}

/// Provider for LoggingService
@riverpod
LoggingService loggingService(LoggingServiceRef ref) {
  throw UnimplementedError('loggingServiceProvider must be overridden');
}

/// AuthNotifier - manages authentication state using AsyncNotifier pattern
///
/// Riverpod 3.0 AsyncNotifier Compliant:
/// - Uses AsyncNotifier<AuthState> with AsyncValue wrapper
/// - Loading/error states handled by AsyncValue, NOT manual state fields
/// - UI reads STATE via ref.watch(authProvider)
/// - UI calls methods via ref.read(authProvider.notifier)
@riverpod
class AuthNotifier extends _$AuthNotifier {
  LoggingService get _logger => ref.watch(loggingServiceProvider);

  GetCurrentUser get _getCurrentUser => ref.watch(getCurrentUserProvider);
  IsSignedIn get _isSignedIn => ref.watch(isSignedInProvider);
  LoginUseCase get _login => ref.watch(loginUseCaseProvider);
  SignUp get _signUp => ref.watch(signUpProvider);
  SignOut get _signOut => ref.watch(signOutProvider);
  VerifyEmail get _verifyEmail => ref.watch(verifyEmailProvider);
  resend.ResendVerificationEmail get _resendVerificationEmail =>
      ref.watch(resendVerificationEmailProvider);
  ForgotPassword get _forgotPassword => ref.watch(forgotPasswordProvider);
  ConfirmPasswordReset get _confirmPasswordReset =>
      ref.watch(confirmPasswordResetProvider);

  @override
  FutureOr<AuthState> build() async {
    ref.keepAlive();

    _logger.logAuthEvent(
      event: 'Initialize',
      status: 'Started',
      metadata: {'initial_state': 'unauthenticated'},
    );

    // Check if user is already signed in
    try {
      final isAuthenticated = await _isSignedIn();
      if (isAuthenticated) {
        final user = await _getCurrentUser();
        if (user != null) {
          _logger.logAuthEvent(
            event: 'Initialize',
            status: 'Success',
            metadata: {'user_id': user.id},
          );
          return AuthState.authenticated(user: user);
        }
      }
      _logger.logAuthEvent(
        event: 'Initialize',
        status: 'Success',
        metadata: {'state': 'unauthenticated'},
      );
      return AuthState.initial();
    } catch (e, stack) {
      _logger.logError(
        feature: 'Authentication',
        error: 'Initialize Failed',
        code: 'INIT_ERROR',
        metadata: {'error': e.toString()},
        stackTrace: stack,
      );
      // Return initial state on error - AsyncValue will capture the error
      return AuthState.initial();
    }
  }

  /// Sign in with email and password
  Future<void> signIn(String email, String password) async {
    _logger.logAuthEvent(
      event: 'SignIn',
      status: 'Started',
      metadata: {'email': email},
    );

    state = const AsyncValue.loading();

    state = await AsyncValue.guard(() async {
      try {
        final user = await _login(LoginParams(
          email: email,
          password: password,
        ));

        _logger.logAuthEvent(
          event: 'SignIn',
          status: 'Success',
          metadata: {'user_id': user.id},
        );

        return AuthState.authenticated(user: user);
      } on ValidationException catch (e, stack) {
        _logger.logError(
          feature: 'Authentication',
          error: 'Validation Error',
          code: 'VALIDATION_ERROR',
          metadata: {'errors': e.errors},
          stackTrace: stack,
        );

        final firstError = e.errors.values
            .firstWhere(
              (errors) => errors.isNotEmpty,
              orElse: () => ['Please check your input'],
            )
            .first;
        throw AuthException(firstError);
      } on AuthException catch (e) {
        // Map Cognito-specific error codes to user-friendly messages
        final errorStr = e.message.toLowerCase();

        if (errorStr.contains('usernotfoundexception') ||
            errorStr.contains('user does not exist') ||
            errorStr.contains('no account found')) {
          throw const AuthException('No account found with this email');
        } else if (errorStr.contains('notauthorizedexception') ||
            errorStr.contains('incorrect username or password')) {
          throw const AuthException('Wrong password. Please try again');
        } else if (errorStr.contains('usernotconfirmedexception')) {
          // Handle unverified user - return unverified state
          final tempUser = User(
            id: email,
            email: email,
            username: email.split('@')[0],
            createdAt: DateTime.now(),
          );
          return AuthState.unverified(user: tempUser);
        } else if (errorStr.contains('passwordresetreq')) {
          // Handle password reset required
          final tempUser = User(
            id: email,
            email: email,
            username: email.split('@')[0],
            createdAt: DateTime.now(),
          );
          return AuthState.passwordResetRequired(user: tempUser);
        } else if (errorStr.contains('limitexceededexception')) {
          throw const AuthException(
              'Too many attempts. Please try again later');
        } else if (errorStr.contains('toomanyrequests')) {
          throw const AuthException(
              'Too many requests. Please try again later');
        } else if (errorStr.contains('mfamethod')) {
          // Handle MFA required
          final tempUser = User(
            id: email,
            email: email,
            username: email.split('@')[0],
            createdAt: DateTime.now(),
          );
          return AuthState.mfaRequired(user: tempUser);
        } else {
          throw AuthException(e.message);
        }
      }
    });
  }

  /// Sign up a new user
  Future<void> signUp({
    required String email,
    required String password,
    required String name,
  }) async {
    state = const AsyncValue.loading();

    state = await AsyncValue.guard(() async {
      try {
        final (user, needsVerification) = await _signUp(SignUpParams(
          email: email,
          password: password,
          name: name,
        ));

        if (needsVerification) {
          debugPrint('AuthNotifier: User requires email verification');
          return AuthState.unverified(user: user);
        } else {
          debugPrint('AuthNotifier: User signed up and verified');
          _logger.logAuthEvent(
            event: 'SignUp',
            status: 'Success',
            metadata: {'user_id': user.id},
          );
          return AuthState.authenticated(user: user);
        }
      } on ValidationException catch (e) {
        debugPrint('AuthNotifier: Validation error during sign up: $e');

        final firstError = e.errors.values
            .firstWhere(
              (errors) => errors.isNotEmpty,
              orElse: () => ['Please check your input'],
            )
            .first;
        throw AuthException(firstError);
      } on AuthException catch (e) {
        debugPrint('AuthNotifier: Auth error during sign up: $e');

        final errorStr = e.message.toLowerCase();
        String userMessage;

        if (errorStr.contains('username exists')) {
          userMessage = 'An account with this email already exists';
        } else if (errorStr.contains('password') &&
            errorStr.contains('requirement')) {
          userMessage = 'Password does not meet requirements';
        } else {
          userMessage = e.message;
        }

        throw AuthException(userMessage);
      } catch (e, stack) {
        debugPrint('AuthNotifier: Unexpected error during sign up: $e');
        _logger.logError(
          feature: 'Authentication',
          error: 'SignUp Failed',
          code: 'SIGN_UP_ERROR',
          metadata: {'error': e.toString()},
          stackTrace: stack,
        );
        throw const AuthException(
            'An unexpected error occurred. Please try again later');
      }
    });
  }

  /// Sign out the current user
  Future<void> signOut() async {
    state = const AsyncValue.loading();

    state = await AsyncValue.guard(() async {
      try {
        await _signOut();
        _logger.logAuthEvent(
          event: 'SignOut',
          status: 'Success',
          metadata: {},
        );
        return AuthState.initial();
      } catch (e, stack) {
        _logger.logError(
          feature: 'Authentication',
          error: 'SignOut Failed',
          code: 'SIGN_OUT_ERROR',
          metadata: {'error': e.toString()},
          stackTrace: stack,
        );
        throw AuthException(e.toString());
      }
    });
  }

  /// Verify email with confirmation code
  Future<void> verifyEmail(String code, String email) async {
    state = const AsyncValue.loading();

    state = await AsyncValue.guard(() async {
      // Get current user from previous state if available
      final currentUser = state.value?.user;

      try {
        await _verifyEmail(VerifyEmailParams(code: code, email: email));

        if (currentUser != null) {
          return AuthState.authenticated(user: currentUser);
        } else {
          final user = await _getCurrentUser();
          if (user != null) {
            return AuthState.authenticated(user: user);
          } else {
            return AuthState.initial();
          }
        }
      } catch (e, stack) {
        _logger.logError(
          feature: 'Authentication',
          error: 'VerifyEmail Failed',
          code: 'VERIFY_EMAIL_ERROR',
          metadata: {'error': e.toString()},
          stackTrace: stack,
        );
        throw AuthException(e.toString());
      }
    });
  }

  /// Request password reset for email
  Future<void> forgotPassword(String email) async {
    state = const AsyncValue.loading();

    state = await AsyncValue.guard(() async {
      try {
        await _forgotPassword(ForgotPasswordParams(identifier: email));

        // Create temporary user for password reset flow
        final tempUser = User(
          id: email,
          email: email,
          username: email.split('@')[0],
          createdAt: DateTime.now(),
        );

        // Update state to indicate password reset required
        return AuthState(
          user: tempUser,
          requiresPasswordReset: true,
        );
      } on ValidationException catch (e) {
        final firstError = e.errors.values
            .firstWhere(
              (errors) => errors.isNotEmpty,
              orElse: () => ['Please check your input'],
            )
            .first;
        throw AuthException(firstError);
      } on AuthException catch (e) {
        throw AuthException(e.message);
      } catch (e, stack) {
        _logger.logError(
          feature: 'Authentication',
          error: 'ForgotPassword Failed',
          code: 'FORGOT_PASSWORD_ERROR',
          metadata: {'error': e.toString()},
          stackTrace: stack,
        );
        throw const AuthException('Failed to request password reset');
      }
    });
  }

  /// Complete password reset with code and new password
  Future<void> confirmPasswordReset({
    required String code,
    required String newPassword,
    required String email,
  }) async {
    state = const AsyncValue.loading();

    state = await AsyncValue.guard(() async {
      try {
        await _confirmPasswordReset(ConfirmPasswordResetParams(
          code: code,
          newPassword: newPassword,
          email: email,
        ));

        return AuthState.initial();
      } catch (e, stack) {
        _logger.logError(
          feature: 'Authentication',
          error: 'ConfirmPasswordReset Failed',
          code: 'CONFIRM_PASSWORD_RESET_ERROR',
          metadata: {'error': e.toString()},
          stackTrace: stack,
        );
        throw AuthException(e.toString());
      }
    });
  }

  /// Resend verification email
  Future<void> resendVerificationEmail() async {
    // Capture current user before setting loading state
    final currentUser = state.value?.user;

    state = const AsyncValue.loading();

    state = await AsyncValue.guard(() async {
      try {
        if (currentUser == null || currentUser.email.isEmpty) {
          throw Exception('No email available for verification');
        }

        await _resendVerificationEmail();

        // Return to unverified state
        return AuthState.unverified(user: currentUser);
      } catch (e, stack) {
        _logger.logError(
          feature: 'Authentication',
          error: 'ResendVerificationEmail Failed',
          code: 'RESEND_VERIFICATION_EMAIL_ERROR',
          metadata: {'error': e.toString()},
          stackTrace: stack,
        );
        throw AuthException(e.toString());
      }
    });
  }
}

/// Provider alias for backward compatibility - using the generated provider name
@Deprecated('Use authProvider instead, will be removed in future version')
final authNotifierProvider = authProvider;

/// Provider alias for backward compatibility with tests
/// Maps authStateProvider to authProvider for consistency
final authStateProvider = authProvider;
