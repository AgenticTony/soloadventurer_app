import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soloadventurer/app/di/service_locator.dart';
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
import 'auth_notifier.dart';
import 'package:soloadventurer/features/core/domain/services/logging_service.dart';

export 'auth_notifier.dart';
export '../state/auth_state.dart';

/// Provider for the auth state notifier
final authStateProvider =
    StateNotifierProvider<AuthNotifier, AsyncValue<AuthState>>(
  (ref) => AuthNotifier(
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
  ),
);

/// Provider for the auth initialization state
final authInitProvider = FutureProvider<void>((ref) async {
  // Initialize auth-related services
  await getIt.allReady();
  return;
});

/// Provider for the auth repository
final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => getIt<AuthRepository>(),
);

/// Provider for the get current user use case
final getCurrentUserProvider =
    Provider<GetCurrentUser>((ref) => throw UnimplementedError());

/// Provider for the is signed in use case
final isSignedInProvider =
    Provider<IsSignedIn>((ref) => throw UnimplementedError());

/// Provider for the login use case
final loginProvider =
    Provider<LoginUseCase>((ref) => throw UnimplementedError());

/// Provider for the sign up use case
final signUpProvider = Provider<SignUp>((ref) => throw UnimplementedError());

/// Provider for the sign out use case
final signOutProvider = Provider<SignOut>((ref) => throw UnimplementedError());

/// Provider for the verify email use case
final verifyEmailProvider =
    Provider<VerifyEmail>((ref) => throw UnimplementedError());

/// Provider for the resend verification email use case
final resendVerificationEmailProvider =
    Provider<resend.ResendVerificationEmail>(
        (ref) => throw UnimplementedError());

/// Provider for the forgot password use case
final forgotPasswordProvider =
    Provider<ForgotPassword>((ref) => throw UnimplementedError());

/// Provider for the confirm password reset use case
final confirmPasswordResetProvider =
    Provider<ConfirmPasswordReset>((ref) => throw UnimplementedError());

/// Provider for the logging service
final loggingServiceProvider =
    Provider<LoggingService>((ref) => throw UnimplementedError());
