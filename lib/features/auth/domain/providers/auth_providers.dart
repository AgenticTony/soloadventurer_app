import 'dart:convert';
import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:soloadventurer/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:soloadventurer/features/auth/domain/entities/user.dart';
import 'package:soloadventurer/features/auth/domain/notifiers/auth_notifier.dart';
import 'package:soloadventurer/features/auth/domain/state/auth_state.dart';
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
import 'package:soloadventurer/features/core/domain/services/logging_service.dart';

/// Authentication configuration constants
const _kMaxFailedAttempts = 5;
const _kTokenRefreshThreshold =
    Duration(minutes: 5); // Refresh 5 mins before expiry
const _kMaxJitterSeconds = 30; // Max random jitter for token refresh
const _kLockoutDuration = Duration(minutes: 15); // Account lockout duration
const _kMetricsKey = 'auth_metrics'; // Storage key for auth metrics

/// JWT token claims and payload
typedef JWTPayload = ({
  String sub,
  String iss,
  int exp,
  int iat,
  String? email,
  String? name,
  List<String> groups,
});

/// Authentication metrics state
typedef AuthMetricsState = ({
  int failedAttempts,
  DateTime? lastFailedAttempt,
  bool isLocked,
  Duration? lockoutRemaining,
  List<String> recentErrors,
  DateTime? lastSuccessfulLogin,
  String? lastLoginIp,
  String? lastLoginDevice,
});

/// Parses a JWT token and returns its payload
JWTPayload? _parseJwt(String token) {
  try {
    final parts = token.split('.');
    if (parts.length != 3) return null;

    final payload = json.decode(
      utf8.decode(base64Url.decode(base64Url.normalize(parts[1]))),
    ) as Map<String, dynamic>;

    return (
      sub: payload['sub'] as String,
      iss: payload['iss'] as String,
      exp: payload['exp'] as int,
      iat: payload['iat'] as int,
      email: payload['email'] as String?,
      name: payload['name'] as String?,
      groups:
          (payload['cognito:groups'] as List<dynamic>?)?.cast<String>() ?? [],
    );
  } catch (e) {
    return null;
  }
}

/// Group of authentication-related providers that manage the app's auth state
/// and user information using AWS Cognito.
///
/// Usage:
/// ```dart
/// // Watch for auth state changes
/// final authState = ref.watch(authStateProvider);
///
/// // Check if user is authenticated
/// final isLoggedIn = ref.watch(isAuthenticatedProvider);
///
/// // Get current user
/// final user = ref.watch(currentUserProvider);
///
/// // Access auth methods
/// final auth = ref.read(authNotifierProvider.notifier);
/// await auth.signIn(email, password);
///
/// // Check session status
/// final isSessionValid = ref.watch(sessionStatusProvider);
///
/// // Monitor auth metrics
/// final metrics = ref.watch(authMetricsProvider);
/// ```

/// Provider for the auth data source
final authDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  return getIt<AuthRemoteDataSource>();
});

/// Provider for the auth repository
final authRepositoryProvider =
    Provider<AuthRepository>((ref) => getIt<AuthRepository>());

/// Provider for the get current user use case
final getCurrentUserProvider = Provider<GetCurrentUser>(
    (ref) => GetCurrentUser(ref.watch(authRepositoryProvider)));

/// Provider for the is signed in use case
final isSignedInProvider = Provider<IsSignedIn>(
    (ref) => IsSignedIn(ref.watch(authRepositoryProvider)));

/// Provider for the login use case
final loginProvider = Provider<LoginUseCase>(
    (ref) => LoginUseCase(ref.watch(authRepositoryProvider)));

/// Provider for the sign up use case
final signUpProvider =
    Provider<SignUp>((ref) => SignUp(ref.watch(authRepositoryProvider)));

/// Provider for the sign out use case
final signOutProvider =
    Provider<SignOut>((ref) => SignOut(ref.watch(authRepositoryProvider)));

/// Provider for the verify email use case
final verifyEmailProvider = Provider<VerifyEmail>(
    (ref) => VerifyEmail(ref.watch(authRepositoryProvider)));

/// Provider for the resend verification email use case
final resendVerificationEmailProvider =
    Provider<resend.ResendVerificationEmail>(
  (ref) => resend.ResendVerificationEmail(ref.watch(authRepositoryProvider)),
);

/// Provider for the forgot password use case
final forgotPasswordProvider = Provider<ForgotPassword>(
    (ref) => ForgotPassword(ref.watch(authRepositoryProvider)));

/// Provider for the confirm password reset use case
final confirmPasswordResetProvider = Provider<ConfirmPasswordReset>(
  (ref) => ConfirmPasswordReset(ref.watch(authRepositoryProvider)),
);

/// Provider for the logging service
final loggingServiceProvider =
    Provider<LoggingService>((ref) => getIt<LoggingService>());

/// Provider for the auth notifier
final authNotifierProvider =
    StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref.watch(authDataSourceProvider));
});

/// Provider for the auth state
final authStateProvider = Provider<AuthState>((ref) {
  return ref.watch(authNotifierProvider);
});

/// Provides the current user if authenticated, null otherwise
final currentUserProvider = Provider<User?>((ref) {
  return ref.watch(authNotifierProvider.select((state) => state.user));
});

/// Indicates if the user is fully authenticated
final isAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(authNotifierProvider.select((state) => state.isLoggedIn));
});

/// Indicates if any authentication operation is in progress
final isLoadingProvider = Provider<bool>((ref) {
  return ref.watch(authNotifierProvider).isLoading;
});

/// Provides the current authentication error message if any
final authErrorProvider = Provider<String?>((ref) {
  return ref.watch(authNotifierProvider.select((state) => state.error));
});

/// Provides the specific error code for more detailed error handling
final authErrorCodeProvider = Provider<String?>((ref) {
  return ref.watch(authNotifierProvider.select((state) => state.errorCode));
});

/// Indicates if email verification is required
final requiresVerificationProvider = Provider<bool>((ref) {
  return ref.watch(
      authNotifierProvider.select((state) => state.requiresEmailVerification));
});

/// Indicates if password reset is required
final requiresPasswordResetProvider = Provider<bool>((ref) {
  return ref.watch(
      authNotifierProvider.select((state) => state.requiresPasswordReset));
});

/// Provides the current access token for authenticated requests
final accessTokenProvider = Provider<String?>((ref) {
  return ref.watch(authNotifierProvider.select((state) => state.accessToken));
});

/// Provider for parsed JWT token information
final jwtTokenProvider = Provider<JWTPayload?>((ref) {
  final token = ref.watch(accessTokenProvider);
  if (token == null) return null;
  return _parseJwt(token);
});

/// Provides detailed token and session information
final tokenInfoProvider = Provider<
    ({
      String? accessToken,
      DateTime? accessTokenExpiresAt,
      String? refreshToken,
      DateTime? refreshTokenExpiresAt,
      bool needsRefresh,
      Duration timeUntilRefresh,
      JWTPayload? claims,
    })>((ref) {
  final token = ref.watch(accessTokenProvider);
  final jwt = ref.watch(jwtTokenProvider);

  if (token == null) {
    return (
      accessToken: null,
      accessTokenExpiresAt: null,
      refreshToken: null,
      refreshTokenExpiresAt: null,
      needsRefresh: false,
      timeUntilRefresh: Duration.zero,
      claims: null,
    );
  }

  final now = DateTime.now();
  final expiresAt = jwt != null
      ? DateTime.fromMillisecondsSinceEpoch(jwt.exp * 1000)
      : now.add(const Duration(minutes: 60));
  final refreshAt = expiresAt.subtract(_kTokenRefreshThreshold);

  // Add jitter to prevent token storms
  final jitter = Duration(seconds: Random().nextInt(_kMaxJitterSeconds));

  return (
    accessToken: token,
    accessTokenExpiresAt: expiresAt,
    refreshToken: null, // TODO: Add refresh token handling
    refreshTokenExpiresAt: null,
    needsRefresh: now.isAfter(refreshAt),
    timeUntilRefresh: refreshAt.difference(now) + jitter,
    claims: jwt,
  );
});

/// Provides session status information with token validity
final sessionStatusProvider = Provider<
    ({
      bool isValid,
      bool needsRefresh,
      DateTime? expiresAt,
    })>((ref) {
  final tokenInfo = ref.watch(tokenInfoProvider);
  return (
    isValid: tokenInfo.accessToken != null && !tokenInfo.needsRefresh,
    needsRefresh: tokenInfo.needsRefresh,
    expiresAt: tokenInfo.accessTokenExpiresAt,
  );
});

/// Notifier for managing authentication metrics with persistence
class AuthMetricsNotifier extends StateNotifier<AuthMetricsState> {
  final SharedPreferences _prefs;

  AuthMetricsNotifier(this._prefs) : super(_loadInitialState(_prefs));

  static AuthMetricsState _loadInitialState(SharedPreferences prefs) {
    final json = prefs.getString(_kMetricsKey);
    if (json == null) {
      return (
        failedAttempts: 0,
        lastFailedAttempt: null,
        isLocked: false,
        lockoutRemaining: null,
        recentErrors: [],
        lastSuccessfulLogin: null,
        lastLoginIp: null,
        lastLoginDevice: null,
      );
    }

    try {
      final data = jsonDecode(json) as Map<String, dynamic>;
      return (
        failedAttempts: data['failedAttempts'] as int? ?? 0,
        lastFailedAttempt: data['lastFailedAttempt'] != null
            ? DateTime.parse(data['lastFailedAttempt'] as String)
            : null,
        isLocked: data['isLocked'] as bool? ?? false,
        lockoutRemaining: data['lockoutUntil'] != null
            ? DateTime.parse(data['lockoutUntil'] as String)
                .difference(DateTime.now())
            : null,
        recentErrors:
            (data['recentErrors'] as List<dynamic>?)?.cast<String>() ?? [],
        lastSuccessfulLogin: data['lastSuccessfulLogin'] != null
            ? DateTime.parse(data['lastSuccessfulLogin'] as String)
            : null,
        lastLoginIp: data['lastLoginIp'] as String?,
        lastLoginDevice: data['lastLoginDevice'] as String?,
      );
    } catch (e) {
      return (
        failedAttempts: 0,
        lastFailedAttempt: null,
        isLocked: false,
        lockoutRemaining: null,
        recentErrors: [],
        lastSuccessfulLogin: null,
        lastLoginIp: null,
        lastLoginDevice: null,
      );
    }
  }

  Future<void> _persistState() async {
    final now = DateTime.now();
    final data = {
      'failedAttempts': state.failedAttempts,
      'lastFailedAttempt': state.lastFailedAttempt?.toIso8601String(),
      'isLocked': state.isLocked,
      'lockoutUntil':
          state.isLocked ? now.add(_kLockoutDuration).toIso8601String() : null,
      'recentErrors': state.recentErrors,
      'lastSuccessfulLogin': state.lastSuccessfulLogin?.toIso8601String(),
      'lastLoginIp': state.lastLoginIp,
      'lastLoginDevice': state.lastLoginDevice,
    };

    await _prefs.setString(_kMetricsKey, jsonEncode(data));
  }

  void recordFailedAttempt(String error) {
    final now = DateTime.now();
    state = (
      failedAttempts: state.failedAttempts + 1,
      lastFailedAttempt: now,
      isLocked: state.failedAttempts + 1 >= _kMaxFailedAttempts,
      lockoutRemaining: state.failedAttempts + 1 >= _kMaxFailedAttempts
          ? _kLockoutDuration
          : null,
      recentErrors: [...state.recentErrors, error].take(10).toList(),
      lastSuccessfulLogin: state.lastSuccessfulLogin,
      lastLoginIp: state.lastLoginIp,
      lastLoginDevice: state.lastLoginDevice,
    );
    _persistState();
  }

  void recordSuccessfulLogin(String? ip, String? device) {
    state = (
      failedAttempts: 0,
      lastFailedAttempt: null,
      isLocked: false,
      lockoutRemaining: null,
      recentErrors: [],
      lastSuccessfulLogin: DateTime.now(),
      lastLoginIp: ip,
      lastLoginDevice: device,
    );
    _persistState();
  }

  void checkLockStatus() {
    if (!state.isLocked) return;

    final now = DateTime.now();
    final lockoutEnds = state.lastFailedAttempt!.add(_kLockoutDuration);

    if (now.isAfter(lockoutEnds)) {
      state = (
        failedAttempts: 0,
        lastFailedAttempt: null,
        isLocked: false,
        lockoutRemaining: null,
        recentErrors: state.recentErrors,
        lastSuccessfulLogin: state.lastSuccessfulLogin,
        lastLoginIp: state.lastLoginIp,
        lastLoginDevice: state.lastLoginDevice,
      );
      _persistState();
    } else {
      state = (
        failedAttempts: state.failedAttempts,
        lastFailedAttempt: state.lastFailedAttempt,
        isLocked: state.isLocked,
        lockoutRemaining: lockoutEnds.difference(now),
        recentErrors: state.recentErrors,
        lastSuccessfulLogin: state.lastSuccessfulLogin,
        lastLoginIp: state.lastLoginIp,
        lastLoginDevice: state.lastLoginDevice,
      );
    }
  }
}

/// Provider for shared preferences instance
final sharedPrefsProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('Must override sharedPrefsProvider with instance');
});

/// Provider for auth metrics with persistence
final authMetricsNotifierProvider =
    StateNotifierProvider<AuthMetricsNotifier, AuthMetricsState>((ref) {
  final prefs = ref.watch(sharedPrefsProvider);
  return AuthMetricsNotifier(prefs);
});

/// Tracks authentication metrics and events
final authMetricsProvider = Provider<AuthMetricsState>((ref) {
  final metrics = ref.watch(authMetricsNotifierProvider);

  // Check and update lock status
  ref.read(authMetricsNotifierProvider.notifier).checkLockStatus();

  return metrics;
});

/// Provides a map of all auth-related states for comprehensive UI updates
final authStatusProvider = Provider<Map<String, bool>>((ref) {
  final state = ref.watch(authNotifierProvider);
  final session = ref.watch(sessionStatusProvider);
  final metrics = ref.watch(authMetricsProvider);

  return {
    'isAuthenticated': state.isLoggedIn,
    'isLoading': state.isLoading,
    'requiresVerification': state.requiresEmailVerification,
    'requiresPasswordReset': state.requiresPasswordReset,
    'hasError': state.error != null,
    'hasValidSession': session.isValid,
    'needsSessionRefresh': session.needsRefresh,
    'isLocked': metrics.isLocked,
  };
});

/// Utility provider for auth-related UI states
final authUIProvider = Provider<
    ({
      bool isLoading,
      bool canSubmit,
      String? error,
      String? errorCode,
      bool isLocked,
    })>((ref) {
  final state = ref.watch(authNotifierProvider);
  final metrics = ref.watch(authMetricsProvider);

  return (
    isLoading: state.isLoading,
    canSubmit: !state.isLoading && state.error == null && !metrics.isLocked,
    error: state.error,
    errorCode: state.errorCode,
    isLocked: metrics.isLocked,
  );
});
