import 'dart:convert';
import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:soloadventurer/features/auth/domain/entities/user.dart';
import 'package:soloadventurer/app/providers/auth_service_providers.dart';
import 'package:soloadventurer/features/auth/domain/repositories/auth_repository.dart';
import 'package:soloadventurer/features/core/infrastructure/services/logging_service_impl.dart';
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
import 'package:soloadventurer/features/auth/presentation/providers/auth_provider.dart'
    show authProvider;

part 'auth_providers.g.dart';

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

/// Re-export of authRepositoryProvider from app/providers/auth_service_providers.dart
/// The authRepositoryProvider is now defined in app/providers/auth_service_providers.dart

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
/// Re-exports loggingServiceProvider from infrastructure layer
final loggingServiceProvider = loggingServiceImplProvider;

// NOTE: authNotifierProvider moved to presentation layer
// See: lib/features/auth/presentation/providers/auth_provider.dart

/// Backward-compatible alias for the auth provider from presentation layer
/// @deprecated Import authProvider from presentation/providers/auth_provider.dart directly
final authNotifierProvider = authProvider;

// NOTE: Token info providers depend on accessTokenProvider which is in presentation layer
// TODO: Move token info providers to core or presentation layer

/// Notifier for managing authentication metrics with persistence
@riverpod
class AuthMetricsNotifier extends _$AuthMetricsNotifier {
  @override
  AuthMetricsState build() {
    final prefs = ref.watch(sharedPrefsProvider);
    return _loadInitialState(prefs);
  }

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

  Future<void> _persistState(SharedPreferences prefs) async {
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

    await prefs.setString(_kMetricsKey, jsonEncode(data));
  }

  void recordFailedAttempt(String error) {
    final prefs = ref.watch(sharedPrefsProvider);
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
    _persistState(prefs);
  }

  void recordSuccessfulLogin(String? ip, String? device) {
    final prefs = ref.watch(sharedPrefsProvider);
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
    _persistState(prefs);
  }

  void checkLockStatus() {
    final prefs = ref.watch(sharedPrefsProvider);
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
      _persistState(prefs);
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

// Note: authMetricsNotifierProvider and authMetricsProvider are now auto-generated
// by the @riverpod annotation on AuthMetricsNotifier
// The providers are available as:
// - authMetricsNotifierProvider (for accessing the notifier)
// - authMetricsProvider (for accessing the state)

/// Provides a map of all auth-related states for comprehensive UI updates
// NOTE: authStatusProvider depends on authNotifierProvider which is in presentation layer
// TODO: Update authStatusProvider to use presentation layer authNotifierProvider

/// Utility provider for auth-related UI states
// NOTE: authUIProvider depends on authNotifierProvider which is in presentation layer
// TODO: Update authUIProvider to use presentation layer authNotifierProvider
