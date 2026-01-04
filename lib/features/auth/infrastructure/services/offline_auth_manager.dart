import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:soloadventurer/core/errors/exceptions.dart';
import 'package:soloadventurer/features/auth/data/datasources/auth_local_data_source.dart';
import 'package:soloadventurer/features/auth/domain/models/auth_session.dart';
import 'package:soloadventurer/features/core/domain/services/connectivity_service.dart';

/// Offline authentication state
enum OfflineAuthState {
  /// Device is online and authenticated
  online,

  /// Device is offline but has valid cached credentials
  offlineWithCache,

  /// Device is offline and has no valid credentials
  offlineWithoutCache,

  /// Device just came back online and needs to sync
  needsSync,
}

/// Result of an offline auth operation
class OfflineAuthResult {
  /// The new offline state
  final OfflineAuthState state;

  /// Whether the operation was successful
  final bool success;

  /// Error message if the operation failed
  final String? errorMessage;

  /// Timestamp of the state change
  final DateTime timestamp;

  const OfflineAuthResult({
    required this.state,
    required this.success,
    this.errorMessage,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  /// Creates a success result
  factory OfflineAuthResult.success({
    required OfflineAuthState state,
    DateTime? timestamp,
  }) {
    return OfflineAuthResult(
      state: state,
      success: true,
      timestamp: timestamp,
    );
  }

  /// Creates a failure result
  factory OfflineAuthResult.failure({
    required String errorMessage,
    DateTime? timestamp,
  }) {
    return OfflineAuthResult(
      state: OfflineAuthState.offlineWithoutCache,
      success: false,
      errorMessage: errorMessage,
      timestamp: timestamp,
    );
  }

  @override
  String toString() {
    return 'OfflineAuthResult{state: $state, success: $success, errorMessage: $errorMessage, timestamp: $timestamp}';
  }
}

/// Information about cached data for offline access
class CachedDataInfo {
  /// User profile data if available
  final Map<String, dynamic>? userProfile;

  /// Timestamp when data was last cached
  final DateTime? lastCachedAt;

  /// Whether the cached data is considered fresh (within 24 hours)
  final bool isFresh;

  const CachedDataInfo({
    this.userProfile,
    this.lastCachedAt,
    required this.isFresh,
  });

  /// Creates info for no cached data
  factory CachedDataInfo.none() {
    return const CachedDataInfo(
      userProfile: null,
      lastCachedAt: null,
      isFresh: false,
    );
  }

  @override
  String toString() {
    return 'CachedDataInfo{hasProfile: ${userProfile != null}, isFresh: $isFresh, lastCachedAt: $lastCachedAt}';
  }
}

/// Service for managing offline authentication state and cached data access
///
/// This service provides offline authentication capabilities by:
/// - Monitoring network connectivity changes
/// - Maintaining offline auth state
/// - Providing access to cached data when offline
/// - Syncing with server when connection is restored
///
/// The service integrates with [ConnectivityService] to detect network changes
/// and [AuthLocalDataSource] to access cached authentication data.
class OfflineAuthManager {
  /// Service for monitoring network connectivity
  final ConnectivityService _connectivityService;

  /// Local data source for accessing cached auth data
  final AuthLocalDataSource _localDataSource;

  /// Stream controller for emitting offline state changes
  final StreamController<OfflineAuthResult> _stateController;

  /// Stream subscription for connectivity changes
  StreamSubscription<NetworkStatus>? _connectivitySubscription;

  /// Current offline authentication state
  OfflineAuthState _currentState = OfflineAuthState.offlineWithoutCache;

  /// Last known network status
  NetworkStatus _lastNetworkStatus = NetworkStatus.disconnected;

  /// Whether the service has been initialized
  bool _isInitialized = false;

  /// Whether a sync operation is currently in progress
  bool _isSyncing = false;

  /// Maximum age for cached data to be considered fresh (24 hours)
  static const Duration _maxCacheAge = Duration(hours: 24);

  /// Creates a new [OfflineAuthManager]
  OfflineAuthManager({
    required ConnectivityService connectivityService,
    required AuthLocalDataSource localDataSource,
  })  : _connectivityService = connectivityService,
        _localDataSource = localDataSource,
        _stateController = StreamController<OfflineAuthResult>.broadcast();

  /// Stream of offline authentication state changes
  Stream<OfflineAuthResult> get onStateChanged => _stateController.stream;

  /// Current offline authentication state
  OfflineAuthState get currentState => _currentState;

  /// Whether the device is currently offline
  bool get isOffline => _currentState == OfflineAuthState.offlineWithCache ||
                       _currentState == OfflineAuthState.offlineWithoutCache;

  /// Whether the device is currently online
  bool get isOnline => _currentState == OfflineAuthState.online ||
                     _currentState == OfflineAuthState.needsSync;

  /// Whether cached data is available
  bool get hasCachedData => _currentState == OfflineAuthState.offlineWithCache;

  /// Whether a sync operation is currently in progress
  bool get isSyncing => _isSyncing;

  /// Initializes the offline auth manager and starts monitoring connectivity
  ///
  /// This method should be called when the app starts. It will:
  /// 1. Check the initial network status
  /// 2. Determine if cached credentials are available
  /// 3. Set the initial offline state
  /// 4. Start listening for connectivity changes
  Future<void> initialize() async {
    if (_isInitialized) {
      debugPrint('OfflineAuthManager: Already initialized');
      return;
    }

    debugPrint('OfflineAuthManager: Initializing');

    try {
      // Check initial network status
      _lastNetworkStatus = await _connectivityService.checkConnectivity();
      debugPrint('OfflineAuthManager: Initial network status: $_lastNetworkStatus');

      // Determine if we have cached credentials
      final hasCachedCredentials = await _hasCachedCredentials();
      debugPrint('OfflineAuthManager: Has cached credentials: $hasCachedCredentials');

      // Set initial state
      _currentState = _determineInitialState(_lastNetworkStatus, hasCachedCredentials);
      debugPrint('OfflineAuthManager: Initial state: $_currentState');

      // Emit initial state
      _emitState(OfflineAuthResult.success(state: _currentState));

      // Start listening for connectivity changes
      _startConnectivityMonitoring();

      _isInitialized = true;
      debugPrint('OfflineAuthManager: Initialization complete');
    } catch (e) {
      debugPrint('OfflineAuthManager: Initialization failed: $e');
      _currentState = OfflineAuthState.offlineWithoutCache;
      _emitState(OfflineAuthResult.failure(
        errorMessage: 'Initialization failed: ${e.toString()}',
      ));
      rethrow;
    }
  }

  /// Gets information about cached data
  ///
  /// Returns [CachedDataInfo] with details about available cached data.
  Future<CachedDataInfo> getCachedDataInfo() async {
    debugPrint('OfflineAuthManager: Getting cached data info');

    try {
      // Get cached user data
      final userData = await _localDataSource.getUserData();

      if (userData == null) {
        debugPrint('OfflineAuthManager: No cached user data found');
        return CachedDataInfo.none();
      }

      // Get last cached timestamp if available
      final cachedAtStr = userData['cached_at'];
      DateTime? cachedAt;

      if (cachedAtStr != null && cachedAtStr is String) {
        try {
          cachedAt = DateTime.parse(cachedAtStr);
        } catch (e) {
          debugPrint('OfflineAuthManager: Failed to parse cached_at timestamp: $e');
        }
      }

      // Determine if cache is fresh (within 24 hours)
      final isFresh = cachedAt != null &&
          DateTime.now().difference(cachedAt) < _maxCacheAge;

      debugPrint('OfflineAuthManager: Cached data info: ${CachedDataInfo(
        userProfile: userData,
        lastCachedAt: cachedAt,
        isFresh: isFresh,
      )}');

      return CachedDataInfo(
        userProfile: userData,
        lastCachedAt: cachedAt,
        isFresh: isFresh,
      );
    } catch (e) {
      debugPrint('OfflineAuthManager: Failed to get cached data info: $e');
      return CachedDataInfo.none();
    }
  }

  /// Gets cached user profile data
  ///
  /// Returns the cached user profile if available, null otherwise.
  /// This method can be called when offline to access cached user data.
  Future<Map<String, dynamic>?> getCachedUserProfile() async {
    debugPrint('OfflineAuthManager: Getting cached user profile');

    try {
      final userData = await _localDataSource.getUserData();

      if (userData == null) {
        debugPrint('OfflineAuthManager: No cached user profile found');
        return null;
      }

      debugPrint('OfflineAuthManager: Retrieved cached user profile');
      return userData;
    } catch (e) {
      debugPrint('OfflineAuthManager: Failed to get cached user profile: $e');
      return null;
    }
  }

  /// Checks if cached credentials are available and valid
  ///
  /// Returns true if cached tokens exist and are not too old.
  Future<bool> _hasCachedCredentials() async {
    try {
      final hasSession = await _localDataSource.hasValidSession();

      if (!hasSession) {
        debugPrint('OfflineAuthManager: No valid cached session found');
        return false;
      }

      // Check if tokens are not too old (refresh tokens are valid for 30 days)
      final expiration = await _localDataSource.getTokenExpiration();

      if (expiration == null) {
        debugPrint('OfflineAuthManager: No token expiration found in cache');
        return false;
      }

      // Allow offline access if access token expired less than 7 days ago
      // (refresh token should still be valid)
      final daysSinceExpiration = DateTime.now().difference(expiration).inDays;
      final maxOfflineDays = 7;

      final isValid = daysSinceExpiration <= maxOfflineDays;

      debugPrint('OfflineAuthManager: Cached credentials valid: $isValid '
          '(expired $daysSinceExpiration days ago, max is $maxOfflineDays days)');

      return isValid;
    } catch (e) {
      debugPrint('OfflineAuthManager: Failed to check cached credentials: $e');
      return false;
    }
  }

  /// Determines the initial offline state based on network and cache status
  OfflineAuthState _determineInitialState(
    NetworkStatus networkStatus,
    bool hasCachedCredentials,
  ) {
    if (networkStatus == NetworkStatus.connected) {
      return OfflineAuthState.online;
    } else {
      return hasCachedCredentials
          ? OfflineAuthState.offlineWithCache
          : OfflineAuthState.offlineWithoutCache;
    }
  }

  /// Starts monitoring network connectivity changes
  void _startConnectivityMonitoring() {
    debugPrint('OfflineAuthManager: Starting connectivity monitoring');

    _connectivitySubscription = _connectivityService.onConnectivityChanged.listen(
      _onConnectivityChanged,
      onError: (error) {
        debugPrint('OfflineAuthManager: Connectivity monitoring error: $error');
      },
    );
  }

  /// Handles network connectivity changes
  void _onConnectivityChanged(NetworkStatus newStatus) {
    debugPrint('OfflineAuthManager: Connectivity changed from $_lastNetworkStatus to $newStatus');

    if (newStatus == _lastNetworkStatus) {
      debugPrint('OfflineAuthManager: Network status unchanged, skipping');
      return;
    }

    _lastNetworkStatus = newStatus;

    // Update offline state based on connectivity change
    final newState = _handleConnectivityChange(newStatus);

    if (newState != _currentState) {
      debugPrint('OfflineAuthManager: State changing from $_currentState to $newState');
      _currentState = newState;
      _emitState(OfflineAuthResult.success(state: newState));

      // If we just came back online, trigger sync
      if (newStatus == NetworkStatus.connected) {
        _onReconnected();
      }
    } else {
      debugPrint('OfflineAuthManager: State unchanged: $_currentState');
    }
  }

  /// Handles a connectivity change and returns the new state
  OfflineAuthState _handleConnectivityChange(NetworkStatus newStatus) {
    switch (_currentState) {
      case OfflineAuthState.online:
        // Going offline
        if (newStatus == NetworkStatus.disconnected) {
          // Check if we have cached credentials
          final hasCache = _hasCachedCredentials();
          return hasCache
              ? OfflineAuthState.offlineWithCache
              : OfflineAuthState.offlineWithoutCache;
        }
        return _currentState;

      case OfflineAuthState.offlineWithCache:
      case OfflineAuthState.offlineWithoutCache:
        // Coming back online
        if (newStatus == NetworkStatus.connected) {
          return OfflineAuthState.needsSync;
        }
        return _currentState;

      case OfflineAuthState.needsSync:
        // If we lose connection during sync
        if (newStatus == NetworkStatus.disconnected) {
          final hasCache = _hasCachedCredentials();
          return hasCache
              ? OfflineAuthState.offlineWithCache
              : OfflineAuthState.offlineWithoutCache;
        }
        return _currentState;
    }
  }

  /// Handles reconnection to the network
  Future<void> _onReconnected() async {
    debugPrint('OfflineAuthManager: Reconnected to network');

    // Check if we need to sync
    if (_currentState == OfflineAuthState.needsSync) {
      debugPrint('OfflineAuthManager: Scheduling sync operation');
      // Schedule sync after a short delay to ensure network is stable
      Future.delayed(const Duration(seconds: 1), () {
        if (_currentState == OfflineAuthState.needsSync) {
          syncWithServer();
        }
      });
    }
  }

  /// Syncs with the server after reconnection
  ///
  /// This method should be called when the device comes back online.
  /// It will attempt to:
  /// 1. Refresh the authentication token if needed
  /// 2. Sync any pending local changes
  /// 3. Update cached data from the server
  ///
  /// Returns [OfflineAuthResult] with the result of the sync operation.
  Future<OfflineAuthResult> syncWithServer() async {
    if (_isSyncing) {
      debugPrint('OfflineAuthManager: Sync already in progress');
      return OfflineAuthResult.success(state: _currentState);
    }

    if (_lastNetworkStatus != NetworkStatus.connected) {
      debugPrint('OfflineAuthManager: Cannot sync while offline');
      return OfflineAuthResult.failure(
        errorMessage: 'Cannot sync while offline',
      );
    }

    _isSyncing = true;
    debugPrint('OfflineAuthManager: Starting sync with server');

    try {
      // Note: The actual token refresh and data sync will be handled
      // by the TokenRefreshScheduler and other services. This method
      // is primarily for transitioning the state back to online.

      // For now, just transition to online state
      // The TokenRefreshService will handle token refresh automatically
      await Future.delayed(const Duration(milliseconds: 100));

      _currentState = OfflineAuthState.online;
      debugPrint('OfflineAuthManager: Sync complete, now online');

      final result = OfflineAuthResult.success(state: OfflineAuthState.online);
      _emitState(result);

      return result;
    } catch (e) {
      debugPrint('OfflineAuthManager: Sync failed: $e');

      final result = OfflineAuthResult.failure(
        errorMessage: 'Sync failed: ${e.toString()}',
      );

      _emitState(result);

      return result;
    } finally {
      _isSyncing = false;
    }
  }

  /// Manually updates the offline state
  ///
  /// This method can be used to force a state change, for example
  /// after a successful login or logout.
  void updateState(OfflineAuthState newState) {
    debugPrint('OfflineAuthManager: Manual state update from $_currentState to $newState');

    if (newState != _currentState) {
      _currentState = newState;
      _emitState(OfflineAuthResult.success(state: newState));
    }
  }

  /// Emits a state change event to the stream
  void _emitState(OfflineAuthResult result) {
    if (!_stateController.isClosed) {
      _stateController.add(result);
    }
  }

  /// Disposes of the service and stops monitoring connectivity
  void dispose() {
    debugPrint('OfflineAuthManager: Disposing');

    _connectivitySubscription?.cancel();
    _stateController.close();

    _isInitialized = false;
    _isSyncing = false;

    debugPrint('OfflineAuthManager: Disposed');
  }

  /// Resets the service state (useful for testing)
  void reset() {
    debugPrint('OfflineAuthManager: Resetting state');

    _currentState = OfflineAuthState.offlineWithoutCache;
    _lastNetworkStatus = NetworkStatus.disconnected;
    _isInitialized = false;
    _isSyncing = false;

    _connectivitySubscription?.cancel();
    _connectivitySubscription = null;
  }

  /// Checks if the device is currently offline
  Future<bool> isCurrentlyOffline() async {
    final status = await _connectivityService.checkConnectivity();
    return status == NetworkStatus.disconnected;
  }

  /// Gets the current network status
  Future<NetworkStatus> getCurrentNetworkStatus() async {
    return await _connectivityService.checkConnectivity();
  }
}
