import 'dart:async';
import 'dart:math';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/auth_session.dart';
import '../../../../app/providers/auth_service_providers.dart';
import '../../../../core/services/connectivity_service.dart';
import '../../../core/domain/services/logging_service.dart';
import '../../../../app/providers/offline_service_providers.dart';
import '../../data/models/credentials.dart';
import '../services/token_blacklist_manager.dart' as blacklist;
import '../../infrastructure/logging/token_audit_logger.dart';

part 'token_manager.g.dart';

enum FeatureAvailability {
  fullyAvailable, // Online with valid tokens
  offlineWithCache, // Offline but has valid cached data
  offlineNoCache, // Offline with no cached data
  tokenExpired, // Needs reauthentication
  unauthorized // Never authenticated
}

/// Extension on FeatureAvailability to provide convenience getters
extension FeatureAvailabilityX on FeatureAvailability {
  /// Whether the app can perform online operations
  bool get canPerformOnlineOperations {
    return this == FeatureAvailability.fullyAvailable;
  }

  /// Whether the app has valid tokens
  bool get hasValidTokens {
    return this == FeatureAvailability.fullyAvailable ||
        this == FeatureAvailability.offlineWithCache;
  }
}

/// Manages authentication tokens and their lifecycle according to AWS Cognito specifications
///
/// This provider must be kept alive to prevent disposal during async operations.
/// It's initialized in bootstrap.dart before the app runs.
@Riverpod(keepAlive: true)
class TokenManager extends _$TokenManager {
  Timer? _refreshTimer;
  Timer? _recoveryTimer;
  AuthSession? _cachedSession;
  int _refreshAttempts = 0;
  StreamSubscription? _connectivitySubscription;
  bool _isDisposed = false;
  bool _isInitialized = false;
  Completer<void>? _initializationCompleter;
  static const int _maxRefreshAttempts = 5;
  static const Duration _baseDelay = Duration(seconds: 1);
  // Adaptive refresh thresholds based on token lifetime
  static const Duration _minValidityThreshold = Duration(minutes: 2);
  static const double _shortTokenRefreshPercentage = 0.8; // For tokens < 30 min
  static const double _mediumTokenRefreshPercentage =
      0.75; // For tokens 30-60 min
  static const double _longTokenRefreshPercentage = 0.7; // For tokens > 60 min

  late final blacklist.TokenBlacklistManager _blacklistManager;
  late final LoggingService _auditLogger;

  @override
  FeatureAvailability build() {
    _blacklistManager =
        ref.watch(blacklist.tokenBlacklistManagerProvider.notifier);
    _auditLogger = ref.watch(tokenAuditLoggerProvider);

    // Initialize secure storage
    try {
      // We'll need to create a provider for this
      // _secureStorage = ref.watch(secureTokenStorageProvider);

      // For now, we'll use a placeholder
    } catch (e) {
    // intentional silent catch
    }

    ref.onDispose(() {
      _refreshTimer?.cancel();
      _recoveryTimer?.cancel();
      _connectivitySubscription?.cancel();
      _isDisposed = true;
    });

    return FeatureAvailability.unauthorized;
  }

  Future<void> waitForInitialization() async {
    if (_isInitialized) return;
    _initializationCompleter ??= Completer<void>();
    await _initializationCompleter!.future;
  }

  Future<void> initialize() async {
    if (_isInitialized) {
      return;
    }

    try {
      final storage = ref.read(authLocalDataSourceProvider);
      final connectivityService = ref.read(connectivityServiceProvider);

      // Load cached session atomically as per AWS best practices
      final sessionData = await Future.wait([
        storage.getAuthToken(),
        storage.getIdToken(),
        storage.getRefreshToken(),
        storage.getTokenExpiration(),
      ]);

      final accessToken = sessionData[0] as String?;
      final idToken = sessionData[1] as String?;
      final refreshToken = sessionData[2] as String?;
      final expiresAt = sessionData[3] as DateTime?;

      if (accessToken != null &&
          idToken != null &&
          refreshToken != null &&
          expiresAt != null) {
        _cachedSession = AuthSession(
          accessToken: accessToken,
          idToken: idToken,
          refreshToken: refreshToken,
          expiresAt: expiresAt,
        );

        // Setup refresh timer if we have a valid session
        if (!_isDisposed) {
          _scheduleTokenRefresh();
        }
      } else {
      }

      // Get current connectivity status
      final networkStatus = await connectivityService.checkNetworkStatus();
      final isConnected = networkStatus == NetworkStatus.connected;

      final hasValidTokens = _cachedSession?.expiresAt
              .isAfter(DateTime.now().add(_minValidityThreshold)) ??
          false;

      // Mark as initialized before updating state
      _isInitialized = true;

      // Calculate and update state
      final newState = _calculateState(isConnected, hasValidTokens);
      state = newState;

      // If we're online and have valid tokens, try to refresh them
      if (isConnected && hasValidTokens && !_isDisposed) {
        await _refreshTokens();
      }
    } catch (e) {
      if (!_isDisposed) {
        state = FeatureAvailability.unauthorized;
      }
      rethrow;
    }
  }

  Future<void> _refreshTokens() async {
    if (_isDisposed) return;

    final connectivityService = ref.read(connectivityServiceProvider);
    final isOnline = await connectivityService.hasConnectivity;

    if (!isOnline || _isDisposed) {
      _auditLogger.logTokenEvent(
        event: 'refresh_skipped',
        status: 'info',
        metadata: {'reason': 'offline_or_disposed'},
      );
      return;
    }

    try {
      final storage = ref.read(authLocalDataSourceProvider);
      final remote = ref.read(authRemoteDataSourceProvider);
      final currentRefreshToken = await storage.getRefreshToken();

      if (currentRefreshToken == null || _isDisposed) {
        _auditLogger.logTokenEvent(
          event: 'refresh_failed',
          status: 'error',
          metadata: {'reason': 'no_refresh_token'},
        );
        state = FeatureAvailability.unauthorized;
        return;
      }

      // Check if refresh token is blacklisted
      if (_blacklistManager.isTokenBlacklisted(currentRefreshToken)) {
        _auditLogger.logTokenBlacklist(
          token: currentRefreshToken,
          reason: 'blacklisted_token_detected',
        );
        await clearSession();
        return;
      }

      if (_refreshAttempts >= _maxRefreshAttempts) {
        _auditLogger.logTokenEvent(
          event: 'refresh_failed',
          status: 'error',
          metadata: {
            'reason': 'max_attempts_reached',
            'attempts': _refreshAttempts,
          },
        );
        await clearSession();
        return;
      }

      final backoffDelay = _getBackoffDelay();
      if (backoffDelay > Duration.zero) {
        _auditLogger.logTokenEvent(
          event: 'refresh_backoff',
          status: 'info',
          metadata: {'delay_seconds': backoffDelay.inSeconds},
        );
        await Future.delayed(backoffDelay);
      }

      if (_isDisposed) return;

      final oldSession = _cachedSession;
      final newSession = await remote.refreshToken();

      // Handle token rotation and blacklisting
      if (oldSession != null) {
        await _blacklistManager.handleTokenRotation(oldSession, newSession);
        _auditLogger.logTokenRotation(
          oldSession: oldSession,
          newSession: newSession,
          reason: 'scheduled_refresh',
        );
      }

      await Future.wait([
        storage.saveAuthData(
          newSession.accessToken,
          newSession.refreshToken,
          expiresAt: newSession.expiresAt,
          idToken: newSession.idToken,
        ),
      ]);

      if (_isDisposed) return;

      _cachedSession = newSession;
      _refreshAttempts = 0;
      _scheduleTokenRefresh();

      final networkStatus = await connectivityService.checkNetworkStatus();
      final isConnected = networkStatus == NetworkStatus.connected;
      final hasValidTokens = newSession.expiresAt
          .isAfter(DateTime.now().add(_minValidityThreshold));

      final newState = _calculateState(isConnected, hasValidTokens);
      if (state != newState) {
        _auditLogger.logStateTransition(
          feature: 'token_manager',
          fromState: state.toString(),
          toState: newState.toString(),
        );
        state = newState;
      }

      _auditLogger.logTokenRefresh(
        success: true,
        attemptNumber: _refreshAttempts + 1,
      );
    } catch (e, stackTrace) {
      if (_isDisposed) return;

      _refreshAttempts++;
      _auditLogger.logError(
        feature: 'token_manager',
        error: e.toString(),
        code: 'refresh_failed',
        metadata: {'attempt': _refreshAttempts},
        stackTrace: stackTrace,
      );

      if (_refreshAttempts < _maxRefreshAttempts) {
        _scheduleRecoveryAttempt();
      } else {
        _auditLogger.logTokenEvent(
          event: 'refresh_failed',
          status: 'error',
          metadata: {
            'reason': 'max_attempts_reached',
            'attempts': _refreshAttempts,
          },
        );
        await clearSession();
      }
    }
  }

  void _scheduleTokenRefresh() {
    _refreshTimer?.cancel();

    if (_cachedSession == null || _isDisposed) return;

    // Calculate token lifetime and schedule refresh according to AWS best practices
    final tokenLifetime = _cachedSession!.expiresAt.difference(DateTime.now());
    if (tokenLifetime <= Duration.zero) {
      state = FeatureAvailability.tokenExpired;
      if (!_isDisposed) unawaited(_refreshTokens());
      return;
    }

    // Calculate adaptive refresh percentage based on token lifetime
    double refreshPercentage;
    if (tokenLifetime < const Duration(minutes: 30)) {
      refreshPercentage =
          _shortTokenRefreshPercentage; // 80% for short-lived tokens
    } else if (tokenLifetime < const Duration(minutes: 60)) {
      refreshPercentage =
          _mediumTokenRefreshPercentage; // 75% for medium-lived tokens
    } else {
      refreshPercentage =
          _longTokenRefreshPercentage; // 70% for long-lived tokens
    }

    // AWS best practice: refresh at adaptive percentage of token lifetime for smooth token rotation
    final refreshAt = DateTime.now().add(tokenLifetime * refreshPercentage);

    // AWS docs: ensure minimum 2-minute validity threshold
    if (refreshAt.isAfter(DateTime.now().add(_minValidityThreshold))) {
      final delay = refreshAt.difference(DateTime.now());
      _refreshTimer = Timer(delay, () {
        if (!_isDisposed) unawaited(_refreshTokens());
      });
    } else {
      state = FeatureAvailability.tokenExpired;
      if (!_isDisposed) unawaited(_refreshTokens());
    }
  }

  void _scheduleRecoveryAttempt() {
    _recoveryTimer?.cancel();

    if (_isDisposed) return;

    // AWS best practice: implement exponential backoff with jitter for retries
    final delay = _getBackoffDelay();
    _recoveryTimer = Timer(delay, () {
      if (!_isDisposed) unawaited(_refreshTokens());
    });
  }

  Future<void> clearSession() async {
    final storage = ref.read(authLocalDataSourceProvider);
    await storage.clearAuthData();
    _cachedSession = null;
    _refreshTimer?.cancel();
    _recoveryTimer?.cancel();
    _refreshAttempts = 0;
    state = FeatureAvailability.unauthorized;
    _auditLogger.logTokenEvent(
      event: 'session_cleared',
      status: 'info',
    );
  }

  // Public methods for feature checks
  bool get canPerformOnlineOperations =>
      state == FeatureAvailability.fullyAvailable;

  bool get hasValidTokens =>
      _cachedSession?.expiresAt
          .isAfter(DateTime.now().add(_minValidityThreshold)) ??
      false;

  bool get isOffline =>
      state == FeatureAvailability.offlineWithCache ||
      state == FeatureAvailability.offlineNoCache;

  Duration _getBackoffDelay() {
    if (_refreshAttempts == 0) return Duration.zero;
    final delay = _baseDelay * pow(2, _refreshAttempts - 1);
    return delay +
        Duration(
            milliseconds:
                Random().nextInt(1000)); // Add jitter for AWS best practices
  }

  FeatureAvailability _calculateState(bool isOnline, bool hasValidTokens) {

    if (_cachedSession == null) {
      return FeatureAvailability.unauthorized;
    }

    if (!hasValidTokens) {
      if (isOnline) {
        return FeatureAvailability.tokenExpired;
      } else {
        return FeatureAvailability.offlineNoCache;
      }
    }

    if (isOnline) {
      return FeatureAvailability.fullyAvailable;
    } else {
      return FeatureAvailability.offlineWithCache;
    }
  }

  Future<void> refreshToken() async {
    if (_isDisposed) return;

    final connectivityService = ref.read(connectivityServiceProvider);
    final isOnline = await connectivityService.hasConnectivity;

    if (!isOnline || _isDisposed) {
      return;
    }

    try {
      final storage = ref.read(authLocalDataSourceProvider);
      final remote = ref.read(authRemoteDataSourceProvider);

      final newSession = await remote.refreshToken();

      // Store new session data
      await Future.wait([
        storage.setAuthToken(newSession.accessToken),
        storage.setIdToken(newSession.idToken),
        storage.setRefreshToken(newSession.refreshToken),
        storage.setTokenExpiration(newSession.expiresAt),
      ]);

      _cachedSession = newSession;
      _scheduleTokenRefresh();
      state = FeatureAvailability.fullyAvailable;
    } catch (e) {
      state = FeatureAvailability.unauthorized;
    }
  }

  Future<void> reauthenticate(String username, String password) async {
    if (_isDisposed) return;

    final connectivityService = ref.read(connectivityServiceProvider);
    final isOnline = await connectivityService.hasConnectivity;

    if (!isOnline || _isDisposed) {
      return;
    }

    try {
      state = FeatureAvailability.unauthorized;
      final storage = ref.read(authLocalDataSourceProvider);
      final remote = ref.read(authRemoteDataSourceProvider);

      // Clear existing session
      await storage.clearSession();
      _cachedSession = null;

      // Attempt to reauthenticate
      final newTokens = await remote.reauthenticate(
        Credentials(username: username, password: password),
      );

      // Convert AuthTokens to AuthSession
      final newSession = AuthSession(
        accessToken: newTokens.accessToken,
        idToken: newTokens.idToken,
        refreshToken: newTokens.refreshToken,
        expiresAt: DateTime.now().add(const Duration(
            minutes: 60)), // Default to 1 hour if expiresIn is not available
      );

      // Store new session data
      await Future.wait([
        storage.setAuthToken(newSession.accessToken),
        storage.setIdToken(newSession.idToken),
        storage.setRefreshToken(newSession.refreshToken),
        storage.setTokenExpiration(newSession.expiresAt),
      ]);

      _cachedSession = newSession;
      _scheduleTokenRefresh();
      state = FeatureAvailability.fullyAvailable;
    } catch (e) {
      state = FeatureAvailability.unauthorized;
    }
  }

  Future<void> handleOffline() async {
    if (_isDisposed) return;

    final storage = ref.read(authLocalDataSourceProvider);
    final hasLocalData = await storage.hasValidSession();

    if (hasLocalData) {
      state = FeatureAvailability.offlineWithCache;
    } else {
      state = FeatureAvailability.offlineNoCache;
    }
  }

  Future<void> handleOnline() async {
    if (_isDisposed) return;

    final storage = ref.read(authLocalDataSourceProvider);
    final hasLocalData = await storage.hasValidSession();

    if (hasLocalData) {
      await refreshToken();
    } else {
      state = FeatureAvailability.unauthorized;
    }
  }

  /// Refreshes the TokenManager state by reloading tokens from storage.
  ///
  /// This should be called after authentication events (login, signup, etc.)
  /// to update the TokenManager's state with the newly stored tokens.
  Future<void> refreshState() async {
    if (_isDisposed) return;

    try {
      final connectivityService = ref.read(connectivityServiceProvider);

      // Load tokens from storage
      final storage = ref.read(authLocalDataSourceProvider);
      final sessionData = await Future.wait([
        storage.getAuthToken(),
        storage.getIdToken(),
        storage.getRefreshToken(),
        storage.getTokenExpiration(),
      ]);

      final accessToken = sessionData[0] as String?;
      final idToken = sessionData[1] as String?;
      final refreshToken = sessionData[2] as String?;
      final expiresAt = sessionData[3] as DateTime?;

      if (accessToken != null &&
          idToken != null &&
          refreshToken != null &&
          expiresAt != null) {
        _cachedSession = AuthSession(
          accessToken: accessToken,
          idToken: idToken,
          refreshToken: refreshToken,
          expiresAt: expiresAt,
        );
        _scheduleTokenRefresh();
      } else {
        _cachedSession = null;
      }

      // Get current connectivity status
      final networkStatus = await connectivityService.checkNetworkStatus();
      final isConnected = networkStatus == NetworkStatus.connected;
      final hasValidTokens = _cachedSession?.expiresAt
              .isAfter(DateTime.now().add(_minValidityThreshold)) ??
          false;

      // Calculate and update state
      final newState = _calculateState(isConnected, hasValidTokens);
      state = newState;
    } catch (e) {
      // On error, set state to unauthorized
      if (!_isDisposed) {
        state = FeatureAvailability.unauthorized;
      }
    }
  }
}
