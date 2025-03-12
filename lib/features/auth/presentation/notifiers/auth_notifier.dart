import 'package:flutter_riverpod/flutter_riverpod.dart';
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

/// Auth state notifier with AsyncValue pattern for better error handling
class AuthNotifier extends StateNotifier<AsyncValue<AuthState>> {
  final GetCurrentUser _getCurrentUser;
  final IsSignedIn _isSignedIn;
  final LoginUseCase _login;
  final SignUp _signUp;
  final SignOut _signOut;
  final VerifyEmail _verifyEmail;
  final ForgotPassword _forgotPassword;
  final ConfirmPasswordReset _confirmPasswordReset;
  final LoggingService _logger;

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
    required LoggingService logger,
  })  : _getCurrentUser = getCurrentUser,
        _isSignedIn = isSignedIn,
        _login = login,
        _signUp = signUp,
        _signOut = signOut,
        _verifyEmail = verifyEmail,
        _forgotPassword = forgotPassword,
        _confirmPasswordReset = confirmPasswordReset,
        _logger = logger,
        super(const AsyncValue.data(AuthState.initial())) {
    _logger.logAuthEvent(
      event: 'Initialize',
      status: 'Started',
      metadata: {'initial_state': 'unauthenticated'},
    );
  }

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

  /// Initialize auth state
  Future<void> initialize() async {
    if (!mounted) return;

    _logger.logAuthEvent(
      event: 'Initialize',
      status: 'InProgress',
    );

    // Set loading state
    _updateState(const AsyncValue.loading());

    // Use AsyncValue.guard for automatic error handling
    final newState = await AsyncValue.guard(() async {
      final isAuthenticated = await _isSignedIn();
      if (isAuthenticated) {
        final user = await _getCurrentUser();
        if (user != null) {
          _logger.logAuthEvent(
            event: 'Initialize',
            status: 'Success',
            metadata: {'user_id': user.id},
          );
          return AuthState.authenticated(user);
        }
      }
      _logger.logAuthEvent(
        event: 'Initialize',
        status: 'Success',
        metadata: {'state': 'unauthenticated'},
      );
      return const AuthState.initial();
    });

    if (!mounted) return;
    _updateState(newState);
  }

  /// Sign in with email and password
  Future<void> signIn(String email, String password) async {
    if (!mounted) return;

    _logger.logAuthEvent(
      event: 'SignIn',
      status: 'Started',
      metadata: {'email': email},
    );

    // Set loading state
    _updateState(const AsyncValue.loading());

    try {
      final user = await _login(LoginParams(
        email: email,
        password: password,
      ));

      if (!mounted) return;

      _logger.logAuthEvent(
        event: 'SignIn',
        status: 'Success',
        metadata: {'user_id': user.id},
      );

      // Successfully authenticated
      _updateState(AsyncValue.data(AuthState.authenticated(user)));
    } on ValidationException catch (e, stack) {
      if (!mounted) return;

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
      _updateState(AsyncValue.error(firstError, stack));
    } on AuthException catch (e, stack) {
      if (!mounted) return;

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
        _updateState(AsyncValue.data(AuthState.unverified(tempUser)));
        return;
      } else if (errorStr.contains('passwordresetreq')) {
        // Handle password reset required
        final tempUser = User(
          id: email,
          email: email,
          username: email.split('@')[0],
          createdAt: DateTime.now(),
        );
        _updateState(AsyncValue.data(AuthState(
          user: tempUser,
          requiresPasswordReset: true,
        )));
        return;
      } else if (errorStr.contains('limitexceededexception')) {
        userMessage = 'Too many attempts. Please try again later';
        errorCode = 'LIMIT_EXCEEDED';
      } else if (errorStr.contains('toomanyrequests')) {
        userMessage = 'Too many requests. Please try again later';
        errorCode = 'TOO_MANY_REQUESTS';
      } else if (errorStr.contains('mfamethod')) {
        // Handle MFA required - we need to add this method to AuthState
        final tempUser = User(
          id: email,
          email: email,
          username: email.split('@')[0],
          createdAt: DateTime.now(),
        );
        // Use existing state method until we add requiresMFA
        _updateState(AsyncValue.data(AuthState.unverified(tempUser)));
        return;
      } else {
        userMessage = e.message;
      }

      // Set error state with code
      final authState = AuthState.error(userMessage, errorCode);
      _updateState(AsyncValue.error(userMessage, stack));
    } catch (e, stack) {
      if (!mounted) return;

      // Handle generic errors
      final message = 'An unexpected error occurred: ${e.toString()}';
      _updateState(AsyncValue.error(message, stack));
    }
  }

  /// Sign up a new user
  Future<void> signUp(SignUpParams params) async {
    if (!mounted) return;

    // Set initial loading state
    _updateState(const AsyncValue.loading());

    try {
      final (user, needsVerification) = await _signUp(params);

      if (!mounted) return;

      if (needsVerification) {
        debugPrint('AuthNotifier: User requires email verification');
        _updateState(AsyncValue.data(AuthState.unverified(user)));
      } else {
        debugPrint('AuthNotifier: User signed up and verified');
        _updateState(AsyncValue.data(AuthState.authenticated(user)));
      }
    } on ValidationException catch (e, stack) {
      debugPrint('AuthNotifier: Validation error during sign up: $e');
      if (!mounted) return;

      final firstError = e.errors.values
          .firstWhere(
            (errors) => errors.isNotEmpty,
            orElse: () => ['Please check your input'],
          )
          .first;
      _updateState(AsyncValue.error(firstError, stack));
    } on AuthException catch (e, stack) {
      debugPrint('AuthNotifier: Auth error during sign up: $e');
      if (!mounted) return;

      final errorStr = e.message.toLowerCase();
      String userMessage;
      String errorCode = e.code ?? 'UNKNOWN_ERROR';

      if (errorStr.contains('username exists')) {
        userMessage = 'An account with this email already exists';
        errorCode = 'USERNAME_EXISTS';
      } else if (errorStr.contains('password') &&
          errorStr.contains('requirement')) {
        userMessage = 'Password does not meet requirements';
        errorCode = 'INVALID_PASSWORD';
      } else {
        userMessage = e.message;
      }

      _updateState(AsyncValue.error(userMessage, stack));
    } catch (e, stack) {
      debugPrint('AuthNotifier: Unexpected error during sign up: $e');
      if (!mounted) return;
      _updateState(AsyncValue.error(
          'An unexpected error occurred. Please try again later', stack));
    }
  }

  /// Sign out the current user
  Future<void> signOut() async {
    if (!mounted) return;
    _updateState(const AsyncValue.loading());

    try {
      await _signOut();
      if (!mounted) return;
      _updateState(const AsyncValue.data(AuthState.initial()));
    } catch (e, stack) {
      if (!mounted) return;
      _updateState(AsyncValue.error(e.toString(), stack));
    }
  }

  /// Verify email with confirmation code
  Future<void> verifyEmail(String code, String email) async {
    final currentUser = state.value?.user;
    _updateState(const AsyncValue.loading());

    try {
      await _verifyEmail(VerifyEmailParams(code: code, email: email));

      if (currentUser != null) {
        _updateState(AsyncValue.data(AuthState.authenticated(currentUser)));
      } else {
        final user = await _getCurrentUser();
        if (user != null) {
          _updateState(AsyncValue.data(AuthState.authenticated(user)));
        } else {
          _updateState(const AsyncValue.data(AuthState.initial()));
        }
      }
    } catch (e, stack) {
      _updateState(AsyncValue.error(e.toString(), stack));
    }
  }

  /// Request password reset for email
  Future<void> forgotPassword(String email) async {
    if (!mounted) return;

    _updateState(const AsyncValue.loading());

    try {
      await _forgotPassword(ForgotPasswordParams(identifier: email));

      if (!mounted) return;

      // Create temporary user for password reset flow
      final tempUser = User(
        id: email,
        email: email,
        username: email.split('@')[0],
        createdAt: DateTime.now(),
      );

      // Update state to indicate password reset required
      _updateState(AsyncValue.data(AuthState(
        user: tempUser,
        requiresPasswordReset: true,
      )));
    } on ValidationException catch (e, stack) {
      if (!mounted) return;
      final firstError = e.errors.values
          .firstWhere(
            (errors) => errors.isNotEmpty,
            orElse: () => ['Please check your input'],
          )
          .first;
      _updateState(AsyncValue.error(firstError, stack));
    } on AuthException catch (e, stack) {
      if (!mounted) return;
      _updateState(AsyncValue.error(e.message, stack));
    } catch (e, stack) {
      if (!mounted) return;
      _updateState(AsyncValue.error('Failed to request password reset', stack));
    }
  }

  /// Complete password reset with code and new password
  Future<void> confirmPasswordReset({
    required String code,
    required String newPassword,
    required String email,
  }) async {
    if (!mounted) return;
    _updateState(const AsyncValue.loading());

    try {
      await _confirmPasswordReset(ConfirmPasswordResetParams(
        code: code,
        newPassword: newPassword,
        email: email,
      ));
      if (!mounted) return;
      _updateState(const AsyncValue.data(AuthState.initial()));
    } catch (e, stack) {
      if (!mounted) return;
      _updateState(AsyncValue.error(e.toString(), stack));
    }
  }

  /// Resend verification email
  Future<void> resendVerificationEmail() async {
    if (!mounted) return;
    final currentUser = state.value?.user;
    _updateState(const AsyncValue.loading());

    try {
      if (currentUser == null || currentUser.email.isEmpty) {
        throw Exception('No email available for verification');
      }

      // This would be a call to a use case in a real implementation
      // await _resendVerificationEmail(currentUser.email);

      _updateState(AsyncValue.data(AuthState.unverified(currentUser)));
    } catch (e, stack) {
      _updateState(AsyncValue.error(e.toString(), stack));
    }
  }
}
