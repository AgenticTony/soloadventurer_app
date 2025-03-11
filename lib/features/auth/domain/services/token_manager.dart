import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/auth_session.dart';
import '../../data/providers/auth_data_providers.dart';
import '../../../core/domain/services/connectivity_service.dart';
import '../../../core/data/services/connectivity_service_impl.dart';
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

/// Manages authentication tokens and their lifecycle according to AWS Cognito specifications
@riverpod
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
  static const Duration _refreshThreshold = Duration(minutes: 5);
  static const Duration _minValidityThreshold = Duration(minutes: 2);
  static const double _refreshAtTokenLifetimePercentage = 0.75;

  late final blacklist.TokenBlacklistManager _blacklistManager;
  late final TokenAuditLogger _auditLogger;

  @override
  FeatureAvailability build() {
    _blacklistManager =
        ref.watch(blacklist.tokenBlacklistManagerProvider.notifier);
    _auditLogger = ref.watch(tokenAuditLoggerProvider.notifier);
    ref.onDispose(() {
      _refreshTimer?.cancel();
      _recoveryTimer?.cancel();
      _connectivitySubscription?.cancel();
      _isDisposed = true;
    });
    return FeatureAvailability.unauthorized;
  }

  FeatureAvailability _calculateCurrentState() {
    debugPrint('TokenManager: Calculating current state');
    final connectivityService = ref.read(connectivityServiceImplProvider);
    final hasValidTokens = _cachedSession?.expiresAt
            .isAfter(DateTime.now().add(_minValidityThreshold)) ??
        false;

    debugPrint('TokenManager: Has valid tokens: $hasValidTokens');
    debugPrint(
        'TokenManager: Cached session expiry: ${_cachedSession?.expiresAt}');
    debugPrint('TokenManager: Current time: ${DateTime.now()}');
    debugPrint('TokenManager: Min validity threshold: $_minValidityThreshold');

    final newState = _calculateState(
        connectivityService.hasConnectivitySync, hasValidTokens);
    debugPrint('TokenManager: Calculated state: $newState');
    return newState;
  }

  Future<void> _initializeAndNotify() async {
    try {
      await initialize();
      if (!_isDisposed && _initializationCompleter != null) {
        _initializationCompleter!.complete();
      }
    } catch (e) {
      if (!_isDisposed && _initializationCompleter != null) {
        _initializationCompleter!.completeError(e);
      }
      rethrow;
    }
  }

  Future<void> waitForInitialization() async {
    if (_isInitialized) return;
    _initializationCompleter ??= Completer<void>();
    await _initializationCompleter!.future;
  }

  Future<void> initialize() async {
    if (_isInitialized) {
      debugPrint('TokenManager: Already initialized, skipping initialization');
      return;
    }

    try {
      debugPrint('TokenManager: Starting initialization');
      final storage = ref.read(authLocalDataSourceProvider);
      final connectivityService = ref.read(connectivityServiceImplProvider);

      debugPrint('TokenManager: Loading cached session data');
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

      debugPrint('TokenManager: Loaded session data:');
      debugPrint('  - Has access token: ${accessToken != null}');
      debugPrint('  - Has ID token: ${idToken != null}');
      debugPrint('  - Has refresh token: ${refreshToken != null}');
      debugPrint('  - Expires at: $expiresAt');

      if (accessToken != null &&
          idToken != null &&
          refreshToken != null &&
          expiresAt != null) {
        debugPrint('TokenManager: Creating cached session from loaded data');
        _cachedSession = AuthSession(
          accessToken: accessToken,
          idToken: idToken,
          refreshToken: refreshToken,
          expiresAt: expiresAt,
        );

        // Setup refresh timer if we have a valid session
        if (!_isDisposed) {
          debugPrint('TokenManager: Setting up token refresh schedule');
          _scheduleTokenRefresh();
        }
      } else {
        debugPrint(
            'TokenManager: Incomplete session data, no cached session created');
      }

      // Get current connectivity status
      debugPrint('TokenManager: Checking current connectivity status');
      final networkStatus = await connectivityService.checkConnectivity();
      final isConnected = networkStatus == NetworkStatus.connected;
      debugPrint(
          'TokenManager: Initial connectivity status: $networkStatus (connected: $isConnected)');

      final hasValidTokens = _cachedSession?.expiresAt
              .isAfter(DateTime.now().add(_minValidityThreshold)) ??
          false;
      debugPrint('TokenManager: Has valid tokens: $hasValidTokens');

      // Mark as initialized before updating state
      debugPrint('TokenManager: Marking as initialized');
      _isInitialized = true;

      // Calculate and update state
      final newState = _calculateState(isConnected, hasValidTokens);
      debugPrint('TokenManager: Calculated initial state: $newState');
      state = newState;

      debugPrint('TokenManager: Initialization complete');

      // If we're online and have valid tokens, try to refresh them
      if (isConnected && hasValidTokens && !_isDisposed) {
        debugPrint(
            'TokenManager: Initiating token refresh after initialization');
        await _refreshTokens();
      }
    } catch (e) {
      debugPrint('TokenManager: Failed to initialize session: $e');
      debugPrint('TokenManager: Stack trace: ${StackTrace.current}');
      if (!_isDisposed) {
        state = FeatureAvailability.unauthorized;
      }
      rethrow;
    }
  }

  Future<void> _refreshTokens() async {
    if (_isDisposed) return;

    final connectivityService = ref.read(connectivityServiceImplProvider);
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

      final networkStatus = await connectivityService.checkConnectivity();
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
      debugPrint('TokenManager: Token expired, initiating immediate refresh');
      state = FeatureAvailability.tokenExpired;
      if (!_isDisposed) unawaited(_refreshTokens());
      return;
    }

    // AWS best practice: refresh at 75% of token lifetime to ensure smooth token rotation
    final refreshAt =
        DateTime.now().add(tokenLifetime * _refreshAtTokenLifetimePercentage);

    // AWS docs: ensure minimum 2-minute validity threshold
    if (refreshAt.isAfter(DateTime.now().add(_minValidityThreshold))) {
      final delay = refreshAt.difference(DateTime.now());
      debugPrint(
          'TokenManager: Scheduling token refresh in ${delay.inSeconds} seconds (75% of token lifetime)');
      _refreshTimer = Timer(delay, () {
        if (!_isDisposed) unawaited(_refreshTokens());
      });
      debugPrint('Token refresh scheduled for ${refreshAt.toIso8601String()}');
    } else {
      debugPrint(
          'TokenManager: Token too close to expiry, refreshing immediately');
      state = FeatureAvailability.tokenExpired;
      if (!_isDisposed) unawaited(_refreshTokens());
    }
  }

  void _scheduleRecoveryAttempt() {
    _recoveryTimer?.cancel();

    if (_isDisposed) return;

    // AWS best practice: implement exponential backoff with jitter for retries
    final delay = _getBackoffDelay();
    debugPrint(
        'TokenManager: Scheduling recovery with exponential backoff in ${delay.inSeconds} seconds (attempt ${_refreshAttempts + 1}/$_maxRefreshAttempts)');
    _recoveryTimer = Timer(delay, () {
      if (!_isDisposed) unawaited(_refreshTokens());
    });
    debugPrint('Recovery attempt scheduled with exponential backoff');
  }

  void _handleConnectivityChange(NetworkStatus status) {
    if (!_isInitialized) {
      debugPrint(
          'TokenManager: Ignoring connectivity change - not initialized');
      return;
    }

    debugPrint('TokenManager: Connectivity changed to $status');

    // Update state immediately based on new connectivity
    final isOnline = status == NetworkStatus.connected;
    final hasValidTokens = _cachedSession?.expiresAt
            .isAfter(DateTime.now().add(_minValidityThreshold)) ??
        false;

    debugPrint('TokenManager: Handling connectivity change');
    debugPrint('  - Online: $isOnline');
    debugPrint('  - Valid tokens: $hasValidTokens');
    debugPrint('  - Session expiry: ${_cachedSession?.expiresAt}');
    debugPrint('  - Current time: ${DateTime.now()}');
    debugPrint('  - Min validity threshold: $_minValidityThreshold');

    // Calculate new state based on current conditions
    final newState = _calculateState(isOnline, hasValidTokens);
    debugPrint('TokenManager: State transition');
    debugPrint('  - Current state: $state');
    debugPrint('  - New state: $newState');

    // Always update state to ensure transitions are captured
    state = newState;
    debugPrint('TokenManager: State updated to $newState');

    // Schedule token refresh if we're transitioning to online state
    if (isOnline && hasValidTokens) {
      debugPrint('TokenManager: Online with valid tokens, scheduling refresh');
      _scheduleTokenRefresh();

      // Try to refresh tokens when we regain connectivity
      debugPrint(
          'TokenManager: Regained connectivity, initiating token refresh');
      unawaited(_refreshTokens());
    }
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
          .isAfter(DateTime.now().add(_refreshThreshold)) ??
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
    debugPrint('TokenManager: Calculating state');
    debugPrint('  - Online: $isOnline');
    debugPrint('  - Has valid tokens: $hasValidTokens');
    debugPrint('  - Has cached session: ${_cachedSession != null}');
    debugPrint('  - Current state: $state');

    if (_cachedSession == null) {
      debugPrint('TokenManager: No cached session, returning unauthorized');
      return FeatureAvailability.unauthorized;
    }

    if (!hasValidTokens) {
      debugPrint('TokenManager: Tokens not valid');
      if (isOnline) {
        debugPrint(
            'TokenManager: Online with invalid tokens, returning tokenExpired');
        return FeatureAvailability.tokenExpired;
      } else {
        debugPrint(
            'TokenManager: Offline with invalid tokens, returning offlineNoCache');
        return FeatureAvailability.offlineNoCache;
      }
    }

    if (isOnline) {
      debugPrint(
          'TokenManager: Online with valid tokens, returning fullyAvailable');
      return FeatureAvailability.fullyAvailable;
    } else {
      debugPrint(
          'TokenManager: Offline with valid tokens, returning offlineWithCache');
      return FeatureAvailability.offlineWithCache;
    }
  }

  Future<void> refreshToken() async {
    if (_isDisposed) return;

    final connectivityService = ref.read(connectivityServiceImplProvider);
    final isOnline = await connectivityService.hasConnectivity;

    if (!isOnline || _isDisposed) {
      debugPrint('TokenManager: Skipping refresh - offline or disposed');
      return;
    }

    try {
      final storage = ref.read(authLocalDataSourceProvider);
      final remote = ref.read(authRemoteDataSourceProvider);

      debugPrint('TokenManager: Attempting to refresh token');
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
      debugPrint('TokenManager: Token refresh successful');
    } catch (e) {
      debugPrint('TokenManager: Token refresh failed: $e');
      state = FeatureAvailability.unauthorized;
    }
  }

  Future<void> reauthenticate(String username, String password) async {
    if (_isDisposed) return;

    final connectivityService = ref.read(connectivityServiceImplProvider);
    final isOnline = await connectivityService.hasConnectivity;

    if (!isOnline || _isDisposed) {
      debugPrint(
          'TokenManager: Skipping reauthentication - offline or disposed');
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
      debugPrint('TokenManager: Reauthentication successful');
    } catch (e) {
      debugPrint('TokenManager: Reauthentication failed: $e');
      state = FeatureAvailability.unauthorized;
    }
  }

  Future<void> handleOffline() async {
    if (_isDisposed) return;

    debugPrint('TokenManager: Handling offline state');
    final storage = ref.read(authLocalDataSourceProvider);
    final hasLocalData = await storage.hasValidSession();

    if (hasLocalData) {
      debugPrint('TokenManager: Found valid local session data');
      state = FeatureAvailability.offlineWithCache;
    } else {
      debugPrint('TokenManager: No valid local session data');
      state = FeatureAvailability.offlineNoCache;
    }
  }

  Future<void> handleOnline() async {
    if (_isDisposed) return;

    debugPrint('TokenManager: Handling online state');
    final storage = ref.read(authLocalDataSourceProvider);
    final hasLocalData = await storage.hasValidSession();

    if (hasLocalData) {
      debugPrint('TokenManager: Found valid local session, refreshing token');
      await refreshToken();
    } else {
      debugPrint('TokenManager: No valid local session');
      state = FeatureAvailability.unauthorized;
    }
  }
}
