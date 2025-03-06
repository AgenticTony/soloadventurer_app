import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/auth_session.dart';
import '../../data/providers/auth_data_providers.dart';
import '../../../core/domain/services/connectivity_service.dart';
import '../../../core/data/services/connectivity_service_impl.dart';

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

  @override
  FeatureAvailability build() {
    debugPrint('TokenManager: Building with new state');

    // Watch connectivity changes through our service
    final connectivityService = ref.watch(connectivityServiceImplProvider);
    debugPrint(
        'TokenManager: Current connectivity: ${connectivityService.hasConnectivitySync}');

    // Setup connectivity monitoring and session initialization only once
    if (_connectivitySubscription == null) {
      debugPrint('TokenManager: Setting up connectivity monitoring');
      debugPrint('TokenManager: Creating new connectivity subscription');
      _connectivitySubscription =
          connectivityService.onConnectivityChanged.listen((status) {
        if (_isDisposed) {
          debugPrint('TokenManager: Ignoring connectivity change - disposed');
          return;
        }
        debugPrint('TokenManager: Received connectivity change: $status');
        _handleConnectivityChange(status);
      });

      // Ensure cleanup on dispose
      ref.onDispose(() {
        debugPrint('TokenManager: Disposing');
        debugPrint('TokenManager: Cleaning up resources');
        _isDisposed = true;
        _connectivitySubscription?.cancel();
        _refreshTimer?.cancel();
        _recoveryTimer?.cancel();
        _initializationCompleter = null;
      });

      // Initialize session if not already initialized
      if (!_isInitialized) {
        debugPrint('TokenManager: Not initialized, starting initialization');
        debugPrint('TokenManager: Creating initialization completer');
        _initializationCompleter = Completer<void>();

        // Initialize synchronously to maintain state
        initialize().then((_) {
          if (!_isDisposed) {
            debugPrint(
                'TokenManager: Initialization completed, calculating new state');
            final newState = _calculateCurrentState();
            if (state != newState) {
              debugPrint(
                  'TokenManager: Updating state from $state to $newState after initialization');
              state = newState;
            }
          } else {
            debugPrint('TokenManager: Skipping state update - disposed');
          }
        }).catchError((error) {
          debugPrint('TokenManager: Initialization failed: $error');
          if (!_isDisposed) {
            state = FeatureAvailability.unauthorized;
          }
        });
      }
    }

    return state;
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
      debugPrint('TokenManager: Skipping refresh - offline or disposed');
      return;
    }

    try {
      final storage = ref.read(authLocalDataSourceProvider);
      final remote = ref.read(authRemoteDataSourceProvider);
      final currentRefreshToken = await storage.getRefreshToken();

      // According to AWS docs: if refresh token is expired, user must re-authenticate
      if (currentRefreshToken == null || _isDisposed) {
        debugPrint(
            'TokenManager: No refresh token available, requiring re-authentication');
        state = FeatureAvailability.unauthorized;
        return;
      }

      // AWS best practice: implement max retries with exponential backoff
      if (_refreshAttempts >= _maxRefreshAttempts) {
        debugPrint(
            'TokenManager: Max refresh attempts reached, requiring re-authentication');
        await clearSession();
        return;
      }

      // Apply exponential backoff with jitter as per AWS best practices
      final backoffDelay = _getBackoffDelay();
      if (backoffDelay > Duration.zero) {
        debugPrint(
            'TokenManager: Implementing backoff delay of ${backoffDelay.inSeconds} seconds before refresh attempt');
        await Future.delayed(backoffDelay);
      }

      if (_isDisposed) return;

      // Attempt to refresh tokens
      final newSession = await remote.refreshToken();

      // AWS best practice: atomically save all token data
      await Future.wait([
        storage.saveAuthData(
          newSession.accessToken,
          newSession.refreshToken,
          expiresAt: newSession.expiresAt,
          idToken: newSession.idToken,
        ),
      ]);

      if (_isDisposed) return;

      // Update memory cache
      _cachedSession = newSession;
      _refreshAttempts = 0; // Reset attempts on success

      // Schedule next refresh at 75% of token lifetime as per AWS best practices
      _scheduleTokenRefresh();

      // Update state based on current connectivity
      final networkStatus = await connectivityService.checkConnectivity();
      final isConnected = networkStatus == NetworkStatus.connected;
      final hasValidTokens = newSession.expiresAt
          .isAfter(DateTime.now().add(_minValidityThreshold));

      final newState = _calculateState(isConnected, hasValidTokens);
      if (state != newState) {
        debugPrint(
            'TokenManager: Updating state after refresh from $state to $newState');
        state = newState;
      }

      debugPrint('TokenManager: Token refresh successful');
    } catch (e) {
      if (_isDisposed) return;

      _refreshAttempts++;
      debugPrint('Token refresh failed (attempt $_refreshAttempts): $e');

      // AWS best practice: implement recovery with exponential backoff
      if (_refreshAttempts < _maxRefreshAttempts) {
        _scheduleRecoveryAttempt();
      } else {
        debugPrint(
            'TokenManager: Max refresh attempts reached, requiring re-authentication');
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
    debugPrint('TokenManager: Session cleared');
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
}
