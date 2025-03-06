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

    // Set loading state using Riverpod's state management
    state = AuthState.loading();

    try {
      final user = await _login(LoginParams(
        email: email,
        password: password,
      ));

      if (!mounted) return;

      // Successfully authenticated - update state immutably
      state = AuthState.authenticated(user);
    } on ValidationException catch (e) {
      if (!mounted) return;

      // Handle validation errors from domain layer
      final firstError = e.errors.values
          .firstWhere(
            (errors) => errors.isNotEmpty,
            orElse: () => ['Please check your input'],
          )
          .first;
      state = AuthState.error(firstError);
    } on AuthException catch (e) {
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
        state = AuthState.unverified(tempUser);
        return;
      } else if (errorStr.contains('passwordresetrequiredexception')) {
        // Handle forced password reset as per Cognito flow
        state = state.copyWith(
            requiresPasswordReset: true,
            error: 'Password reset required. Please reset your password',
            errorCode: 'PASSWORD_RESET_REQUIRED');
        return;
      } else if (errorStr.contains('limitexceededexception')) {
        // Handle rate limiting as per Cognito best practices
        final minutes = errorStr.contains('try again in')
            ? errorStr.split('try again in')[1].split('minutes')[0].trim()
            : '15';
        userMessage =
            'Too many attempts. Please wait $minutes minute${minutes == '1' ? '' : 's'} before trying again';
        errorCode = 'RATE_LIMIT_EXCEEDED';
      } else if (errorStr.contains('invalidpasswordexception')) {
        userMessage =
            'Password must be at least 8 characters long and contain uppercase, lowercase, numbers and special characters';
        errorCode = 'INVALID_PASSWORD_FORMAT';
      } else if (errorStr.contains('expiredtokenexception')) {
        userMessage = 'Your session has expired. Please sign in again';
        errorCode = 'SESSION_EXPIRED';
      } else if (errorStr.contains('software_token_mfa_not_found')) {
        userMessage =
            'Multi-factor authentication is required. Please set up MFA in your account settings';
        errorCode = 'MFA_REQUIRED';
      } else {
        debugPrint('Unhandled Cognito error: $e');
        userMessage = 'Unable to sign in. Please try again';
        errorCode = 'AUTHENTICATION_ERROR';
      }

      // Update state immutably with error details
      state = AuthState.error(userMessage, errorCode);
    } catch (e) {
      if (!mounted) return;
      debugPrint('Unexpected error during sign in: $e');

      // Handle unexpected errors
      state = AuthState.error(
          'An unexpected error occurred. Please try again later',
          'UNKNOWN_ERROR');
    }
  }

  /// Register with email and password
  Future<void> signUp({
    required String email,
    required String password,
    required String name,
  }) async {
    debugPrint('AuthNotifier: Starting sign up');

    // Set initial loading state
    state = AuthState.loading();

    try {
      final result = await _signUp(SignUpParams(
        email: email,
        password: password,
        name: name,
      ));
      final (user, needsVerification) = result;

      // Handle the signup result according to Cognito flow
      if (needsVerification) {
        debugPrint('AuthNotifier: User requires email verification');
        state = AuthState.unverified(user);
      } else {
        debugPrint('AuthNotifier: User signed up and verified');
        state = AuthState.authenticated(user);
      }
    } on ValidationException catch (e) {
      debugPrint('AuthNotifier: Validation error during sign up: $e');
      final firstError = e.errors.values
          .firstWhere(
            (errors) => errors.isNotEmpty,
            orElse: () => ['Please check your input'],
          )
          .first;
      state = AuthState.error(firstError, 'VALIDATION_ERROR');
    } on AuthException catch (e) {
      debugPrint('AuthNotifier: Auth error during sign up: $e');
      final errorStr = e.message.toLowerCase();
      String userMessage;
      String errorCode;

      // Handle Cognito-specific signup errors
      if (errorStr.contains('usernameexistsexception') ||
          errorStr.contains('already exists')) {
        userMessage = 'An account with this email already exists';
        errorCode = 'USER_EXISTS';
      } else if (errorStr.contains('invalidpasswordexception')) {
        userMessage =
            'Password must be at least 8 characters long and contain uppercase, lowercase, numbers and special characters';
        errorCode = 'INVALID_PASSWORD_FORMAT';
      } else if (errorStr.contains('invalidparameterexception')) {
        userMessage = 'Please provide valid email and password';
        errorCode = 'INVALID_PARAMETERS';
      } else if (errorStr.contains('limitexceededexception')) {
        userMessage = 'Too many signup attempts. Please try again later';
        errorCode = 'RATE_LIMIT_EXCEEDED';
      } else {
        userMessage = 'Failed to create account. Please try again';
        errorCode = 'SIGNUP_ERROR';
      }

      state = AuthState.error(userMessage, errorCode);
    } catch (e) {
      debugPrint('AuthNotifier: Unexpected error during sign up: $e');
      state = AuthState.error(
          'An unexpected error occurred. Please try again later',
          'UNKNOWN_ERROR');
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
    debugPrint('AuthNotifier: Starting password reset process');
    try {
      debugPrint('AuthNotifier: Setting loading state');
      state = state.copyWith(isLoading: true);

      debugPrint('AuthNotifier: Calling forgotPassword use case');
      await _forgotPassword(params);

      debugPrint(
          'AuthNotifier: Password reset initiated successfully, updating state');
      state = state.copyWith(
        isLoading: false,
        requiresPasswordReset: true,
        error: null,
      );
      debugPrint('AuthNotifier: New state after password reset: $state');
    } catch (e) {
      debugPrint('AuthNotifier: Error during password reset: $e');
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
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
