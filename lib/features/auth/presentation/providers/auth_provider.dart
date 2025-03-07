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
import 'package:soloadventurer/features/auth/domain/usecases/resend_verification_email.dart'
    as resend;
import 'package:soloadventurer/features/auth/domain/usecases/forgot_password.dart';
import 'package:soloadventurer/features/auth/domain/usecases/confirm_password_reset.dart';
import 'package:soloadventurer/features/auth/presentation/state/auth_state.dart';
import 'package:soloadventurer/features/core/domain/services/logging_service.dart';
import 'package:soloadventurer/features/core/infrastructure/services/logging_service_impl.dart';
import 'package:flutter/foundation.dart';
import 'package:soloadventurer/features/auth/domain/models/auth_session.dart';
import 'package:soloadventurer/features/auth/presentation/providers/token_notifier.dart';

/// Auth provider that manages authentication state
final authProvider =
    StateNotifierProvider<AuthNotifier, AsyncValue<AuthState>>((ref) {
  final tokenNotifier = ref.watch(tokenNotifierProvider);
  return AuthNotifier(
    getCurrentUser: getIt<GetCurrentUser>(),
    isSignedIn: getIt<IsSignedIn>(),
    login: getIt<LoginUseCase>(),
    signUp: getIt<SignUp>(),
    signOut: getIt<SignOut>(),
    verifyEmail: getIt<VerifyEmail>(),
    resendVerificationEmail: getIt<resend.ResendVerificationEmail>(),
    forgotPassword: getIt<ForgotPassword>(),
    confirmPasswordReset: getIt<ConfirmPasswordReset>(),
    logger: getIt<LoggingService>(),
    tokenNotifier: tokenNotifier,
  );
});

/// Auth initialization provider that handles the initial authentication check
/// and sets up the auth state accordingly
final authInitProvider = FutureProvider.autoDispose((ref) async {
  final logger = ref.watch(loggingServiceImplProvider);
  logger.logAuthEvent(
    event: 'InitializeAuth',
    status: 'Started',
    metadata: {'source': 'authInitProvider'},
  );

  try {
    final isSignedIn = getIt<IsSignedIn>();
    final getCurrentUser = getIt<GetCurrentUser>();

    final isAuthenticated = await isSignedIn();
    if (isAuthenticated) {
      final user = await getCurrentUser();
      if (user != null) {
        logger.logAuthEvent(
          event: 'InitializeAuth',
          status: 'Success',
          metadata: {'user_id': user.id, 'state': 'authenticated'},
        );
        ref.read(authProvider.notifier).initialize();
        return;
      }
    }

    logger.logAuthEvent(
      event: 'InitializeAuth',
      status: 'Success',
      metadata: {'state': 'unauthenticated'},
    );
    ref.read(authProvider.notifier).initialize();
  } catch (e, stack) {
    logger.logError(
      feature: 'Authentication',
      error: 'Failed to initialize auth state',
      metadata: {'error': e.toString()},
      stackTrace: stack,
    );
    rethrow;
  }
});

/// Auth state notifier that manages authentication state using AsyncValue
/// for better error handling and loading states
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
  final TokenNotifier _tokenNotifier;

  /// Creates a new [AuthNotifier] with the given use cases and logger
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
    required TokenNotifier tokenNotifier,
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
        _tokenNotifier = tokenNotifier,
        super(AsyncValue.data(AuthState.initial())) {
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

    _updateState(const AsyncValue.loading());

    final newState = await AsyncValue.guard(() async {
      final isAuthenticated = await _isSignedIn();
      if (isAuthenticated) {
        final user = await _getCurrentUser();
        final session = _tokenNotifier.currentSession;
        if (user != null && session != null) {
          _logger.logAuthEvent(
            event: 'Initialize',
            status: 'Success',
            metadata: {'user_id': user.id},
          );
          return AuthState.authenticated(
            user: user,
            accessToken: session.accessToken,
            idToken: session.idToken,
            refreshToken: session.refreshToken,
            tokenExpiresAt: session.expiresAt,
          );
        }
      }
      _logger.logAuthEvent(
        event: 'Initialize',
        status: 'Success',
        metadata: {'state': 'unauthenticated'},
      );
      return AuthState.initial();
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

      final session = _tokenNotifier.currentSession;
      if (session == null) {
        _updateState(AsyncValue.data(AuthState.initial()));
        return;
      }

      _updateState(AsyncValue.data(AuthState.authenticated(
        user: user,
        accessToken: session.accessToken,
        idToken: session.idToken,
        refreshToken: session.refreshToken,
        tokenExpiresAt: session.expiresAt,
      )));
    } on ValidationException catch (e, stack) {
      if (!mounted) return;

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

      _updateState(AsyncValue.error(firstError, stack));
    } on AuthException catch (e, stack) {
      if (!mounted) return;

      final errorStr = e.message.toLowerCase();
      final tempUser = User(
        id: email,
        email: email,
        username: email.split('@')[0],
        createdAt: DateTime.now(),
      );

      if (errorStr.contains('usernotconfirmedexception')) {
        _updateState(AsyncValue.data(AuthState.unverified(user: tempUser)));
        return;
      } else if (errorStr.contains('mfamethod')) {
        _updateState(AsyncValue.data(AuthState.mfaRequired(user: tempUser)));
        return;
      }

      _logger.logError(
        feature: 'Authentication',
        error: 'Authentication Error',
        code: e.code,
        metadata: {'message': e.message},
        stackTrace: stack,
      );

      _updateState(AsyncValue.error(e.message, stack));
    } catch (e, stack) {
      if (!mounted) return;

      _logger.logError(
        feature: 'Authentication',
        error: 'Unexpected Error',
        metadata: {'error': e.toString()},
        stackTrace: stack,
      );

      _updateState(AsyncValue.error('An unexpected error occurred', stack));
    }
  }

  /// Sign up a new user
  Future<void> signUp({
    required String email,
    required String password,
    required String name,
  }) async {
    if (!mounted) return;

    _logger.logAuthEvent(
      event: 'SignUp',
      status: 'Started',
      metadata: {'email': email},
    );

    _updateState(const AsyncValue.loading());

    try {
      final result = await _signUp(SignUpParams(
        email: email,
        password: password,
        name: name,
      ));
      final (user, needsVerification) = result;

      if (!mounted) return;

      _logger.logAuthEvent(
        event: 'SignUp',
        status: 'Success',
        metadata: {
          'user_id': user.id,
          'needs_verification': needsVerification,
        },
      );

      if (needsVerification) {
        _updateState(AsyncValue.data(AuthState.unverified(user: user)));
      } else {
        final session = _tokenNotifier.currentSession;
        if (session == null) {
          _updateState(AsyncValue.data(AuthState.initial()));
          return;
        }

        _updateState(AsyncValue.data(AuthState.authenticated(
          user: user,
          accessToken: session.accessToken,
          idToken: session.idToken,
          refreshToken: session.refreshToken,
          tokenExpiresAt: session.expiresAt,
        )));
      }
    } catch (e, stack) {
      if (!mounted) return;

      _logger.logError(
        feature: 'Authentication',
        error: 'SignUp Error',
        metadata: {'error': e.toString()},
        stackTrace: stack,
      );

      _updateState(AsyncValue.error(e.toString(), stack));
    }
  }

  /// Sign out
  Future<void> signOut() async {
    if (!mounted) return;

    _logger.logAuthEvent(
      event: 'SignOut',
      status: 'Started',
    );

    _updateState(const AsyncValue.loading());

    try {
      await _signOut();
      _tokenNotifier.clearSession();

      if (!mounted) return;

      _logger.logAuthEvent(
        event: 'SignOut',
        status: 'Success',
      );

      _updateState(AsyncValue.data(AuthState.initial()));
    } catch (e, stack) {
      if (!mounted) return;

      _logger.logError(
        feature: 'Authentication',
        error: 'Failed to sign out',
        metadata: {'error': e.toString()},
        stackTrace: stack,
      );

      _updateState(AsyncValue.error('Failed to sign out', stack));
    }
  }
}
