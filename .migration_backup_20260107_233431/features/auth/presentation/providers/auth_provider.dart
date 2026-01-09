import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:soloadventurer/core/errors/exceptions.dart';
import 'package:soloadventurer/features/auth/domain/usecases/login.dart';
import 'package:soloadventurer/features/auth/domain/usecases/sign_up.dart';
import 'package:soloadventurer/features/auth/domain/usecases/verify_email.dart';
import 'package:soloadventurer/features/auth/domain/usecases/forgot_password.dart';
import 'package:soloadventurer/features/auth/domain/usecases/confirm_password_reset.dart';
import 'package:soloadventurer/features/auth/domain/entities/user.dart';
import 'package:soloadventurer/features/auth/presentation/state/auth_state.dart';
import 'package:soloadventurer/features/core/domain/services/logging_service.dart';
import 'package:soloadventurer/features/auth/domain/repositories/auth_repository.dart';
import 'package:soloadventurer/features/auth/domain/providers/auth_providers.dart'
    show
        getCurrentUserProvider,
        isSignedInProvider,
        loginProvider,
        signUpProvider,
        signOutProvider,
        verifyEmailProvider,
        resendVerificationEmailProvider,
        forgotPasswordProvider,
        confirmPasswordResetProvider,
        loggingServiceProvider;

part 'auth_provider.g.dart';

/// Provider for the auth repository (kept for DI compatibility)
@Riverpod(keepAlive: true)
AuthRepository authRepository(Ref ref) {
  throw UnimplementedError('authRepositoryProvider must be overridden');
}

/// Provider for the logging service (kept for DI compatibility)
@Riverpod(keepAlive: true)
LoggingService loggingService(Ref ref) {
  throw UnimplementedError('loggingServiceProvider must be overridden');
}

/// Auth notifier that manages the authentication state
@Riverpod(keepAlive: true)
class AuthNotifier extends _$AuthNotifier {
  LoggingService get _logger => ref.read(loggingServiceProvider);

  /// Updates state with proper logging
  void _updateState(AsyncValue<AuthState> newState) {
    final previousState = state.value;
    state = newState;

    if (previousState != newState.value) {
      _logger.logStateTransition(
        feature: 'Authentication',
        fromState: previousState?.toString() ?? 'null',
        toState: newState.value?.toString() ?? 'null',
        metadata: {
          'is_loading': newState.isLoading,
          'has_error': newState.hasError,
          'is_authenticated': newState.value?.isAuthenticated ?? false,
        },
        stackTrace: StackTrace.current,
      );
    }
  }

  @override
  AsyncValue<AuthState> build() {
    _logger.logAuthEvent(
      event: 'Initialize',
      status: 'Started',
      metadata: {'initial_state': 'unauthenticated'},
    );

    // Don't auto-initialize - let consumers explicitly call initialize()
    // This allows for better control over when initialization happens
    return const AsyncValue.data(AuthState.initial());
  }

  /// Initialize the auth state
  Future<void> initialize() async {
    _logger.logAuthEvent(
      event: 'Initialize',
      status: 'InProgress',
    );

    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      final isSignedInUseCase = ref.read(isSignedInProvider);
      final getCurrentUserUseCase = ref.read(getCurrentUserProvider);

      final isAuthenticated = await isSignedInUseCase();
      if (isAuthenticated) {
        final user = await getCurrentUserUseCase();
        if (user != null) {
          _logger.logAuthEvent(
            event: 'Initialize',
            status: 'Success',
            metadata: {'user_id': user.id},
          );
          return AuthState.authenticated(
            user: user,
            accessToken: user.accessToken,
            idToken: user.idToken,
            refreshToken: user.refreshToken,
            tokenExpiresAt: user.tokenExpiresAt,
          );
        }
      }
      _logger.logAuthEvent(
        event: 'Initialize',
        status: 'Success',
        metadata: {'state': 'unauthenticated'},
      );
      return const AuthState.initial();
    });

    _updateState(state);
  }

  /// Sign in with email and password
  Future<void> signIn(String email, String password) async {
    _logger.logAuthEvent(
      event: 'SignIn',
      status: 'Started',
      metadata: {'email': email},
    );

    state = const AsyncLoading();

    try {
      final loginUseCase = ref.read(loginProvider);
      final user = await loginUseCase(LoginParams(email: email, password: password));

      _logger.logAuthEvent(
        event: 'SignIn',
        status: 'Success',
        metadata: {'user_id': user.id},
      );

      state = AsyncValue.data(AuthState.authenticated(
        user: user,
        accessToken: user.accessToken,
        idToken: user.idToken,
        refreshToken: user.refreshToken,
        tokenExpiresAt: user.tokenExpiresAt,
      ));
    } on ValidationException catch (e, stack) {
      _logger.logError(
        feature: 'Authentication',
        error: 'Validation Error',
        code: 'VALIDATION_ERROR',
        metadata: {'errors': e.errors},
        stackTrace: stack,
      );

      // Handle validation errors from domain layer
      final firstError = e.errors.values
          .firstWhere(
            (errors) => errors.isNotEmpty,
            orElse: () => ['Please check your input'],
          )
          .first;
      state = AsyncValue.error(firstError, stack);
    } on AuthException catch (e, stack) {
      // Map Cognito-specific error codes to user-friendly messages
      final errorStr = e.message.toLowerCase();
      String userMessage;
      String? errorCode = e.code;

      // Handle specific Cognito error cases as per AWS docs
      if (errorStr.contains('usernotfoundexception') ||
          errorStr.contains('user does not exist') ||
          errorStr.contains('no account found')) {
        userMessage = 'No account found with this email';
        errorCode = 'USER_NOT_FOUND';
      } else if (errorStr.contains('notauthorizedexception') ||
          errorStr.contains('incorrect username or password')) {
        userMessage = 'Wrong password. Please try again';
        errorCode = 'INVALID_PASSWORD';
      } else if (errorStr.contains('usernotconfirmedexception')) {
        // Handle unverified user as per Cognito flow
        final tempUser = User(
          id: email,
          email: email,
          username: email.split('@')[0],
          createdAt: DateTime.now(),
        );
        state = AsyncValue.data(AuthState.unverified(user: tempUser));
        return;
      } else if (errorStr.contains('passwordresetreq')) {
        // Handle password reset required
        final tempUser = User(
          id: email,
          email: email,
          username: email.split('@')[0],
          createdAt: DateTime.now(),
        );
        state = AsyncValue.data(AuthState(
          user: tempUser,
          requiresPasswordReset: true,
        ));
        return;
      } else if (errorStr.contains('limitexceededexception')) {
        userMessage = 'Too many attempts. Please try again later';
        errorCode = 'LIMIT_EXCEEDED';
      } else if (errorStr.contains('toomanyrequests')) {
        userMessage = 'Too many requests. Please try again later';
        errorCode = 'TOO_MANY_REQUESTS';
      } else if (errorStr.contains('mfamethod')) {
        // Handle MFA required
        final tempUser = User(
          id: email,
          email: email,
          username: email.split('@')[0],
          createdAt: DateTime.now(),
        );
        state = AsyncValue.data(AuthState.unverified(user: tempUser));
        return;
      } else {
        userMessage = e.message;
      }

      _logger.logError(
        feature: 'Authentication',
        error: userMessage,
        code: errorCode ?? 'AUTH_ERROR',
        metadata: {'email': email},
        stackTrace: stack,
      );

      state = AsyncValue.error(userMessage, stack);
    } catch (e, stack) {
      final message = 'An unexpected error occurred: ${e.toString()}';
      _logger.logError(
        feature: 'Authentication',
        error: message,
        code: 'UNKNOWN_ERROR',
        stackTrace: stack,
      );
      state = AsyncValue.error(message, stack);
    }
  }

  /// Sign up a new user
  Future<void> signUp({
    required String email,
    required String password,
    required String name,
  }) async {
    state = const AsyncLoading();

    try {
      final signUpUseCase = ref.read(signUpProvider);
      final (user, needsVerification) = await signUpUseCase(SignUpParams(
        email: email,
        password: password,
        name: name,
      ));

      if (needsVerification) {
        debugPrint('AuthNotifier: User requires email verification');
        state = AsyncValue.data(AuthState.unverified(user: user));
      } else {
        debugPrint('AuthNotifier: User signed up and verified');
        state = AsyncValue.data(AuthState.authenticated(
          user: user,
          accessToken: user.accessToken,
          idToken: user.idToken,
          refreshToken: user.refreshToken,
          tokenExpiresAt: user.tokenExpiresAt,
        ));
      }
    } on ValidationException catch (e, stack) {
      debugPrint('AuthNotifier: Validation error during sign up: $e');
      final firstError = e.errors.values
          .firstWhere(
            (errors) => errors.isNotEmpty,
            orElse: () => ['Please check your input'],
          )
          .first;
      state = AsyncValue.error(firstError, stack);
    } on AuthException catch (e, stack) {
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

      state = AsyncValue.error(userMessage, stack);
    } catch (e, stack) {
      debugPrint('AuthNotifier: Unexpected error during sign up: $e');
      state = AsyncValue.error(
          'An unexpected error occurred. Please try again later', stack);
    }
  }

  /// Sign out the current user
  Future<void> signOut() async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      final signOutUseCase = ref.read(signOutProvider);
      await signOutUseCase();
      return const AuthState.initial();
    });
  }

  /// Verify email with confirmation code
  Future<void> verifyEmail(String code, String email) async {
    final currentUser = state.value?.user;
    state = const AsyncLoading();

    try {
      final verifyEmailUseCase = ref.read(verifyEmailProvider);
      await verifyEmailUseCase(VerifyEmailParams(code: code, email: email));

      if (currentUser != null) {
        state = AsyncValue.data(AuthState.authenticated(user: currentUser));
      } else {
        final getCurrentUserUseCase = ref.read(getCurrentUserProvider);
        final user = await getCurrentUserUseCase();
        if (user != null) {
          state = AsyncValue.data(AuthState.authenticated(
            user: user,
            accessToken: user.accessToken,
            idToken: user.idToken,
            refreshToken: user.refreshToken,
            tokenExpiresAt: user.tokenExpiresAt,
          ));
        } else {
          state = const AsyncValue.data(AuthState.initial());
        }
      }
    } catch (e, stack) {
      state = AsyncValue.error(e.toString(), stack);
    }
  }

  /// Request password reset
  Future<void> forgotPassword(String email) async {
    state = const AsyncLoading();

    try {
      final forgotPasswordUseCase = ref.read(forgotPasswordProvider);
      await forgotPasswordUseCase(ForgotPasswordParams(identifier: email));

      // Create temporary user for password reset flow
      final tempUser = User(
        id: email,
        email: email,
        username: email.split('@')[0],
        createdAt: DateTime.now(),
      );

      // Update state to indicate password reset required
      state = AsyncValue.data(AuthState(
        user: tempUser,
        requiresPasswordReset: true,
      ));
    } on ValidationException catch (e, stack) {
      final firstError = e.errors.values
          .firstWhere(
            (errors) => errors.isNotEmpty,
            orElse: () => ['Please check your input'],
          )
          .first;
      state = AsyncValue.error(firstError, stack);
    } on AuthException catch (e, stack) {
      state = AsyncValue.error(e.message, stack);
    } catch (e, stack) {
      state = AsyncValue.error('Failed to request password reset', stack);
    }
  }

  /// Confirm password reset
  Future<void> confirmPasswordReset({
    required String email,
    required String code,
    required String newPassword,
  }) async {
    state = const AsyncLoading();

    try {
      final confirmPasswordResetUseCase = ref.read(confirmPasswordResetProvider);
      await confirmPasswordResetUseCase(ConfirmPasswordResetParams(
        email: email,
        code: code,
        newPassword: newPassword,
      ));
      state = const AsyncValue.data(AuthState.initial());
    } catch (e, stack) {
      state = AsyncValue.error(e.toString(), stack);
    }
  }

  /// Resend verification email
  Future<void> resendVerificationEmail() async {
    // Capture previous state before setting loading
    final previousState = state.value ?? const AuthState.initial();
    state = const AsyncLoading();

    try {
      final currentUser = previousState.user;
      if (currentUser == null || currentUser.email.isEmpty) {
        throw Exception('No email available for verification');
      }

      final resendVerificationEmailUseCase = ref.read(resendVerificationEmailProvider);
      await resendVerificationEmailUseCase();

      // Return the previous state to maintain UI state
      state = AsyncValue.data(previousState);
    } catch (e, stack) {
      state = AsyncValue.error(e.toString(), stack);
    }
  }
}
