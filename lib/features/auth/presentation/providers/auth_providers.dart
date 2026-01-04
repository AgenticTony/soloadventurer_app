import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soloadventurer/features/auth/domain/entities/user.dart';
import 'package:soloadventurer/features/auth/domain/repositories/auth_repository.dart';
import 'package:soloadventurer/features/auth/domain/usecases/confirm_password_reset.dart';
import 'package:soloadventurer/features/auth/domain/usecases/forgot_password.dart';
import 'package:soloadventurer/features/auth/domain/usecases/get_current_user.dart';
import 'package:soloadventurer/features/auth/domain/usecases/is_signed_in.dart';
import 'package:soloadventurer/features/auth/domain/usecases/login.dart';
import 'package:soloadventurer/features/auth/domain/usecases/sign_out.dart';
import 'package:soloadventurer/features/auth/domain/usecases/sign_up.dart';
import 'package:soloadventurer/features/auth/domain/usecases/verify_email.dart';
import 'package:soloadventurer/features/auth/domain/usecases/resend_verification_email.dart';
import 'package:soloadventurer/features/auth/presentation/notifiers/auth_notifier.dart';
import 'package:soloadventurer/features/auth/presentation/state/auth_state.dart';
import 'package:soloadventurer/features/core/domain/services/logging_service.dart';
import 'package:soloadventurer/features/auth/infrastructure/services/token_refresh_scheduler.dart';
import 'package:soloadventurer/features/auth/data/datasources/auth_local_data_source.dart';
import 'package:soloadventurer/features/auth/data/providers/auth_data_providers.dart';
import 'package:soloadventurer/app/di/service_locator.dart';
import 'package:soloadventurer/features/auth/infrastructure/services/persistent_session_manager.dart';

/// Provider for the auth repository
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return getIt<AuthRepository>();
});

/// Provider for the get current user use case
final getCurrentUserProvider = Provider<GetCurrentUser>((ref) {
  return GetCurrentUser(ref.watch(authRepositoryProvider));
});

/// Provider for the is signed in use case
final isSignedInProvider = Provider<IsSignedIn>((ref) {
  return IsSignedIn(ref.watch(authRepositoryProvider));
});

/// Provider for the login use case
final loginProvider = Provider<LoginUseCase>((ref) {
  return LoginUseCase(ref.watch(authRepositoryProvider));
});

/// Provider for the sign up use case
final signUpProvider = Provider<SignUp>((ref) {
  return SignUp(ref.watch(authRepositoryProvider));
});

/// Provider for the sign out use case
final signOutProvider = Provider<SignOut>((ref) {
  return SignOut(ref.watch(authRepositoryProvider));
});

/// Provider for the verify email use case
final verifyEmailProvider = Provider<VerifyEmail>((ref) {
  return VerifyEmail(ref.watch(authRepositoryProvider));
});

/// Provider for the resend verification email use case
final resendVerificationEmailProvider = Provider<ResendVerificationEmail>((ref) {
  return ResendVerificationEmail(ref.watch(authRepositoryProvider));
});

/// Provider for the forgot password use case
final forgotPasswordProvider = Provider<ForgotPassword>((ref) {
  return ForgotPassword(ref.watch(authRepositoryProvider));
});

/// Provider for the confirm password reset use case
final confirmPasswordResetProvider = Provider<ConfirmPasswordReset>((ref) {
  return ConfirmPasswordReset(ref.watch(authRepositoryProvider));
});

/// Provider for the logging service
final loggingServiceProvider = Provider<LoggingService>((ref) {
  return getIt<LoggingService>();
});

/// Provider for the token refresh scheduler
final tokenRefreshSchedulerProvider = Provider<TokenRefreshScheduler>((ref) {
  return getIt<TokenRefreshScheduler>();
});

/// Provider for the auth local data source
final authLocalDataSourceProvider = Provider<AuthLocalDataSource>((ref) {
  return getIt<AuthLocalDataSource>();
});

/// Provider for the persistent session manager
final persistentSessionManagerProvider = Provider<PersistentSessionManager>((ref) {
  return getIt<PersistentSessionManager>();
});

/// Provider for the auth notifier
final authNotifierProvider = StateNotifierProvider<AuthNotifier, AsyncValue<AuthState>>((ref) {
  return AuthNotifier(
    getCurrentUser: ref.watch(getCurrentUserProvider),
    isSignedIn: ref.watch(isSignedInProvider),
    login: ref.watch(loginProvider),
    signUp: ref.watch(signUpProvider),
    signOut: ref.watch(signOutProvider),
    verifyEmail: ref.watch(verifyEmailProvider),
    resendVerificationEmail: ref.watch(resendVerificationEmailProvider),
    forgotPassword: ref.watch(forgotPasswordProvider),
    confirmPasswordReset: ref.watch(confirmPasswordResetProvider),
    logger: ref.watch(loggingServiceProvider),
    refreshScheduler: ref.watch(tokenRefreshSchedulerProvider),
    localDataSource: ref.watch(authLocalDataSourceProvider),
    sessionManager: ref.watch(persistentSessionManagerProvider),
    authRepository: ref.watch(authRepositoryProvider),
  );
});

/// Provider for the auth state
final authStateProvider = Provider<AuthState?>((ref) {
  return ref.watch(authNotifierProvider).value;
});

/// Provider for the current user
final currentUserProvider = Provider<User?>((ref) {
  return ref.watch(authStateProvider)?.user;
});

/// Provider for checking if user is authenticated
final isAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(authStateProvider)?.isAuthenticated ?? false;
});

/// Provider for checking if auth is loading
final isAuthLoadingProvider = Provider<bool>((ref) {
  return ref.watch(authNotifierProvider).isLoading;
});

/// Provider for auth error
final authErrorProvider = Provider<String?>((ref) {
  if (ref.watch(authNotifierProvider).hasError) {
    return ref.watch(authNotifierProvider).error.toString();
  }
  return null;
});
