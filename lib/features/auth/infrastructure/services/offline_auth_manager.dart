import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:soloadventurer/core/errors/exceptions.dart';
import 'package:soloadventurer/features/auth/data/datasources/auth_local_data_source.dart';
import 'package:soloadventurer/features/auth/domain/entities/user.dart';
import 'package:soloadventurer/features/auth/domain/models/auth_session.dart';
import 'package:soloadventurer/features/auth/domain/repositories/auth_repository.dart';
import 'package:soloadventurer/features/auth/infrastructure/services/token_refresh_service.dart';
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

/// Progress of a sync operation
enum SyncStep {
  /// Sync is starting
  starting,

  /// Refreshing authentication token
  refreshingToken,

  /// Syncing user data
  syncingUserData,

  /// Syncing pending changes
  syncingPendingChanges,

  /// Sync completed successfully
  completed,

  /// Sync failed
  failed,
}

/// Result of a sync operation
class SyncProgress {
  /// Current sync step
  final SyncStep step;

  /// Progress percentage (0-100)
  final int progress;

  /// Error message if sync failed
  final String? errorMessage;

  /// Whether the sync operation completed successfully
  final bool isSuccess;

  /// Timestamp of this progress update
  final DateTime timestamp;

  const SyncProgress({
    required this.step,
    required this.progress,
    this.errorMessage,
    required this.isSuccess,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  /// Creates a starting progress
  factory SyncProgress.starting() {
    return const SyncProgress(
      step: SyncStep.starting,
      progress: 0,
      isSuccess: false,
    );
  }

  /// Creates a token refresh progress
  factory SyncProgress.refreshingToken({required int progress}) {
    return SyncProgress(
      step: SyncStep.refreshingToken,
      progress: progress,
      isSuccess: false,
    );
  }

  /// Creates a syncing user data progress
  factory SyncProgress.syncingUserData({required int progress}) {
    return SyncProgress(
      step: SyncStep.syncingUserData,
      progress: progress,
      isSuccess: false,
    );
  }

  /// Creates a syncing pending changes progress
  factory SyncProgress.syncingPendingChanges({required int progress}) {
    return SyncProgress(
      step: SyncStep.syncingPendingChanges,
      progress: progress,
      isSuccess: false,
    );
  }

  /// Creates a completed progress
  factory SyncProgress.completed() {
    return const SyncProgress(
      step: SyncStep.completed,
      progress: 100,
      isSuccess: true,
    );
  }

  /// Creates a failed progress
  factory SyncProgress.failed({required String errorMessage}) {
    return SyncProgress(
      step: SyncStep.failed,
      progress: 0,
      isSuccess: false,
      errorMessage: errorMessage,
    );
  }

  @override
  String toString() {
    return 'SyncProgress{step: $step, progress: $progress, isSuccess: $isSuccess, errorMessage: $errorMessage}';
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
/// The service integrates with [ConnectivityService] to detect network changes,
/// [AuthLocalDataSource] to access cached authentication data,
/// [TokenRefreshService] to refresh tokens when reconnected, and
/// [AuthRepository] to fetch fresh data from the server.
class OfflineAuthManager {
  /// Service for monitoring network connectivity
  final ConnectivityService _connectivityService;

  /// Local data source for accessing cached auth data
  final AuthLocalDataSource _localDataSource;

  /// Service for refreshing authentication tokens
  final TokenRefreshService? _tokenRefreshService;

  /// Repository for authentication operations
  final AuthRepository? _authRepository;

  /// Stream controller for emitting offline state changes
  final StreamController<OfflineAuthResult> _stateController;

  /// Stream controller for emitting sync progress updates
  final StreamController<SyncProgress> _syncProgressController;

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
  ///
  /// The [tokenRefreshService] and [authRepository] are optional but required
  /// for full sync functionality. If not provided, sync will only handle
  /// state transitions without refreshing tokens or fetching fresh data.
  OfflineAuthManager({
    required ConnectivityService connectivityService,
    required AuthLocalDataSource localDataSource,
    TokenRefreshService? tokenRefreshService,
    AuthRepository? authRepository,
  })  : _connectivityService = connectivityService,
        _localDataSource = localDataSource,
        _tokenRefreshService = tokenRefreshService,
        _authRepository = authRepository,
        _stateController = StreamController<OfflineAuthResult>.broadcast(),
        _syncProgressController = StreamController<SyncProgress>.broadcast();

  /// Stream of offline authentication state changes
  Stream<OfflineAuthResult> get onStateChanged => _stateController.stream;

  /// Stream of sync progress updates
  Stream<SyncProgress> get onSyncProgress => _syncProgressController.stream;

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
  /// 2. Sync any pending local changes (if implemented)
  /// 3. Update cached data from the server
  ///
  /// Returns [OfflineAuthResult] with the result of the sync operation.
  ///
  /// Emits [SyncProgress] updates to the [onSyncProgress] stream during the sync process.
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

    // Emit starting progress
    _emitSyncProgress(SyncProgress.starting());

    try {
      // Step 1: Check if we need to refresh the token
      if (_tokenRefreshService != null) {
        debugPrint('OfflineAuthManager: Checking if token refresh is needed');

        _emitSyncProgress(SyncProgress.refreshingToken(progress: 10));

        // Check if token is expired
        final isExpired = await _localDataSource.isTokenExpired();

        if (isExpired) {
          debugPrint('OfflineAuthManager: Token is expired, refreshing...');

          _emitSyncProgress(SyncProgress.refreshingToken(progress: 20));

          try {
            // Refresh the token using TokenRefreshService
            await _tokenRefreshService!.refreshToken();

            debugPrint('OfflineAuthManager: Token refreshed successfully');

            _emitSyncProgress(SyncProgress.refreshingToken(progress: 40));
          } catch (e) {
            debugPrint('OfflineAuthManager: Token refresh failed: $e');

            _emitSyncProgress(SyncProgress.failed(
              errorMessage: 'Token refresh failed: ${e.toString()}',
            ));

            // Don't fail the entire sync if token refresh fails
            // The user might still be able to access cached data
          }
        } else {
          debugPrint('OfflineAuthManager: Token is still valid, skipping refresh');
          _emitSyncProgress(SyncProgress.refreshingToken(progress: 40));
        }
      } else {
        debugPrint('OfflineAuthManager: TokenRefreshService not available, skipping token refresh');
      }

      // Step 2: Sync user data from server
      if (_authRepository != null) {
        debugPrint('OfflineAuthManager: Fetching fresh user data from server');

        _emitSyncProgress(SyncProgress.syncingUserData(progress: 60));

        try {
          // Get current user from server
          final user = await _authRepository!.getCurrentUser();

          if (user != null) {
            debugPrint('OfflineAuthManager: User data fetched: ${user.email}');

            // Cache the user data with current timestamp
            final userData = {
              'id': user.id,
              'email': user.email,
              'username': user.username,
              'created_at': user.createdAt.toIso8601String(),
              'last_login_at': user.lastLoginAt?.toIso8601String(),
              'cached_at': DateTime.now().toIso8601String(),
            };

            await _localDataSource.cacheUserData(userData);

            debugPrint('OfflineAuthManager: User data cached successfully');

            _emitSyncProgress(SyncProgress.syncingUserData(progress: 80));
          } else {
            debugPrint('OfflineAuthManager: No user data returned from server');
          }
        } catch (e) {
          debugPrint('OfflineAuthManager: Failed to fetch user data: $e');

          // Don't fail the entire sync if user data sync fails
          // Cached data might still be available
        }
      } else {
        debugPrint('OfflineAuthManager: AuthRepository not available, skipping user data sync');
      }

      // Step 3: Sync pending changes (placeholder for future implementation)
      debugPrint('OfflineAuthManager: Checking for pending changes to sync');
      _emitSyncProgress(SyncProgress.syncingPendingChanges(progress: 90));

      // TODO: Implement pending changes sync when needed
      // For now, just simulate this step
      await Future.delayed(const Duration(milliseconds: 50));

      // Step 4: Mark sync as complete and transition to online state
      _currentState = OfflineAuthState.online;
      debugPrint('OfflineAuthManager: Sync complete, now online');

      _emitSyncProgress(SyncProgress.completed());

      final result = OfflineAuthResult.success(state: OfflineAuthState.online);
      _emitState(result);

      return result;
    } catch (e) {
      debugPrint('OfflineAuthManager: Sync failed: $e');

      _emitSyncProgress(SyncProgress.failed(
        errorMessage: 'Sync failed: ${e.toString()}',
      ));

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

  /// Emits a sync progress event to the stream
  void _emitSyncProgress(SyncProgress progress) {
    if (!_syncProgressController.isClosed) {
      _syncProgressController.add(progress);
    }
  }

  /// Disposes of the service and stops monitoring connectivity
  void dispose() {
    debugPrint('OfflineAuthManager: Disposing');

    _connectivitySubscription?.cancel();
    _stateController.close();
    _syncProgressController.close();

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
