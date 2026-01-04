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
import 'package:soloadventurer/features/auth/infrastructure/services/token_refresh_scheduler.dart';
import 'package:soloadventurer/features/auth/data/datasources/auth_local_data_source.dart';
import 'package:soloadventurer/features/auth/domain/models/auth_session.dart';

/// Provider for the auth repository
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  throw UnimplementedError('authRepositoryProvider must be overridden');
});

/// Provider for the auth notifier
final authNotifierProvider =
    StateNotifierProvider<AuthNotifier, AsyncValue<AuthState>>((ref) {
  throw UnimplementedError('authNotifierProvider must be overridden');
});

/// Provider for the logging service
final loggingServiceProvider = Provider<LoggingService>((ref) {
  throw UnimplementedError('loggingServiceProvider must be overridden');
});

/// Provider for the token refresh scheduler
final tokenRefreshSchedulerProvider =
    Provider<TokenRefreshScheduler>((ref) {
  throw UnimplementedError('tokenRefreshSchedulerProvider must be overridden');
});

/// Provider for the auth local data source
final authLocalDataSourceProvider =
    Provider<AuthLocalDataSource>((ref) {
  throw UnimplementedError('authLocalDataSourceProvider must be overridden');
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
  final TokenRefreshScheduler _refreshScheduler;
  final AuthLocalDataSource _localDataSource;

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
    required TokenRefreshScheduler refreshScheduler,
    required AuthLocalDataSource localDataSource,
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
        _refreshScheduler = refreshScheduler,
        _localDataSource = localDataSource,
        super(const AsyncValue.data(AuthState.initial()));

  /// Initialize the auth state
  Future<void> initialize() async {
    state = const AsyncValue.loading();

    final newState = await AsyncValue.guard(() async {
      final isAuthenticated = await _isSignedIn();
      if (isAuthenticated) {
        final user = await _getCurrentUser();
        if (user != null) {
          // Start the refresh scheduler with the current session
          await _startRefreshScheduler();
          return AuthState.authenticated(user);
        }
      }
      return const AuthState.initial();
    });

    state = newState;
  }

  /// Starts the token refresh scheduler with the current session
  Future<void> _startRefreshScheduler() async {
    try {
      final accessToken = await _localDataSource.getAuthToken();
      final idToken = await _localDataSource.getIdToken();
      final refreshToken = await _localDataSource.getRefreshToken();
      final expiresAt = await _localDataSource.getTokenExpiration();

      if (accessToken != null &&
          idToken != null &&
          refreshToken != null &&
          expiresAt != null) {
        final session = AuthSession(
          accessToken: accessToken,
          idToken: idToken,
          refreshToken: refreshToken,
          expiresAt: expiresAt,
        );
        _refreshScheduler.start(session);
        debugPrint('AuthNotifier: Token refresh scheduler started');
      } else {
        debugPrint('AuthNotifier: Incomplete session data, scheduler not started');
      }
    } catch (e) {
      debugPrint('AuthNotifier: Failed to start refresh scheduler: $e');
    }
  }

  /// Stops the token refresh scheduler
  void _stopRefreshScheduler() {
    _refreshScheduler.stop();
    debugPrint('AuthNotifier: Token refresh scheduler stopped');
  }

  /// Sign in with email and password
  Future<void> signIn(String email, String password) async {
    state = const AsyncValue.loading();

    try {
      final user = await _login(LoginParams(email: email, password: password));
      // Start the refresh scheduler after successful login
      await _startRefreshScheduler();
      state = AsyncValue.data(AuthState.authenticated(user));
    } catch (e, stack) {
      state = AsyncValue.error(e.toString(), stack);
    }
  }

  /// Sign up a new user
  Future<void> signUp({
    required String email,
    required String password,
    required String name,
  }) async {
    state = const AsyncValue.loading();

    try {
      final (user, needsVerification) = await _signUp(SignUpParams(
        email: email,
        password: password,
        name: name,
      ));

      if (needsVerification) {
        state = AsyncValue.data(AuthState.unverified(user: user));
      } else {
        // Start the refresh scheduler after successful registration (if logged in)
        await _startRefreshScheduler();
        state = AsyncValue.data(AuthState.authenticated(user));
      }
    } catch (e, stack) {
      state = AsyncValue.error(e.toString(), stack);
    }
  }

  /// Sign out the current user
  Future<void> signOut() async {
    state = const AsyncValue.loading();

    try {
      // Stop the refresh scheduler before signing out
      _stopRefreshScheduler();
      await _signOut();
      state = const AsyncValue.data(AuthState.initial());
    } catch (e, stack) {
      state = AsyncValue.error(e.toString(), stack);
    }
  }

  /// Verify email with confirmation code
  Future<void> verifyEmail(String code, String email) async {
    state = const AsyncValue.loading();

    try {
      await _verifyEmail(VerifyEmailParams(code: code, email: email));
      state = const AsyncValue.data(AuthState.initial());
    } catch (e, stack) {
      state = AsyncValue.error(e.toString(), stack);
    }
  }

  /// Request password reset
  Future<void> forgotPassword(String email) async {
    state = const AsyncValue.loading();

    try {
      await _forgotPassword(ForgotPasswordParams(identifier: email));
      state = const AsyncValue.data(AuthState.initial());
    } catch (e, stack) {
      state = AsyncValue.error(e.toString(), stack);
    }
  }

  /// Confirm password reset
  Future<void> confirmPasswordReset({
    required String email,
    required String code,
    required String newPassword,
  }) async {
    state = const AsyncValue.loading();

    try {
      await _confirmPasswordReset(ConfirmPasswordResetParams(
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
    state = const AsyncValue.loading();

    try {
      await _resendVerificationEmail();
      // Keep the current state but remove loading
      if (state.hasValue) {
        state = AsyncValue.data(state.value!);
      } else {
        state = const AsyncValue.data(AuthState.initial());
      }
    } catch (e, stack) {
      state = AsyncValue.error(e.toString(), stack);
    }
  }
}
