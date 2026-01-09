library;

import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

/// Connection type enum for different connectivity states
enum ConnectionType {
  /// WiFi connection
  wifi,

  /// Cellular/mobile data connection
  cellular,

  /// No connection
  none,

  /// Unknown connection type (ethernet, vpn, bluetooth, etc.)
  other,
}

/// Represents the current network connectivity state
enum NetworkStatus {
  /// Device has a valid network connection
  connected,

  /// Device has no network connection
  disconnected
}

/// Connectivity status data class with detailed connection information
class ConnectivityStatus {
  /// Current connection type
  final ConnectionType connectionType;

  /// Whether device has any network connectivity
  final bool isConnected;

  /// Timestamp when this status was determined
  final DateTime timestamp;

  /// Creates a new [ConnectivityStatus] instance
  const ConnectivityStatus({
    required this.connectionType,
    required this.isConnected,
    required this.timestamp,
  });

  /// Creates a status from ConnectivityResult
  factory ConnectivityStatus.fromConnectivityResult(
    List<ConnectivityResult> results,
  ) {
    final timestamp = DateTime.now();

    // Check if we have any connection
    if (results.isEmpty || results.contains(ConnectivityResult.none)) {
      return ConnectivityStatus(
        connectionType: ConnectionType.none,
        isConnected: false,
        timestamp: timestamp,
      );
    }

    // Determine primary connection type (prefer wifi over cellular)
    if (results.contains(ConnectivityResult.wifi)) {
      return ConnectivityStatus(
        connectionType: ConnectionType.wifi,
        isConnected: true,
        timestamp: timestamp,
      );
    } else if (results.contains(ConnectivityResult.mobile)) {
      return ConnectivityStatus(
        connectionType: ConnectionType.cellular,
        isConnected: true,
        timestamp: timestamp,
      );
    } else if (results.contains(ConnectivityResult.ethernet)) {
      return ConnectivityStatus(
        connectionType: ConnectionType.other,
        isConnected: true,
        timestamp: timestamp,
      );
    } else if (results.contains(ConnectivityResult.vpn)) {
      return ConnectivityStatus(
        connectionType: ConnectionType.other,
        isConnected: true,
        timestamp: timestamp,
      );
    } else if (results.contains(ConnectivityResult.bluetooth)) {
      return ConnectivityStatus(
        connectionType: ConnectionType.other,
        isConnected: true,
        timestamp: timestamp,
      );
    } else {
      // Unknown connection type - assume connected but type is other
      return ConnectivityStatus(
        connectionType: ConnectionType.other,
        isConnected: true,
        timestamp: timestamp,
      );
    }
  }

  /// Creates a disconnected status
  factory ConnectivityStatus.disconnected() {
    return ConnectivityStatus(
      connectionType: ConnectionType.none,
      isConnected: false,
      timestamp: DateTime.now(),
    );
  }

  /// Creates a connected status with specified type
  factory ConnectivityStatus.connected(ConnectionType type) {
    return ConnectivityStatus(
      connectionType: type,
      isConnected: true,
      timestamp: DateTime.now(),
    );
  }

  /// Converts to NetworkStatus enum
  NetworkStatus toNetworkStatus() {
    return isConnected ? NetworkStatus.connected : NetworkStatus.disconnected;
  }

  @override
  String toString() {
    return 'ConnectivityStatus{connectionType: $connectionType, '
        'isConnected: $isConnected, timestamp: $timestamp}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ConnectivityStatus &&
        other.connectionType == connectionType &&
        other.isConnected == isConnected;
  }

  @override
  int get hashCode => connectionType.hashCode ^ isConnected.hashCode;
}

/// Abstract interface for connectivity operations
///
/// This interface defines the contract for network connectivity monitoring.
/// It provides both stream-based updates for reactive programming and
/// synchronous checks for immediate status retrieval.
///
/// Following Clean Architecture principles, this interface belongs in the
/// core layer as it's a cross-cutting concern used by multiple features.
///
/// See: https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html
abstract class ConnectivityService {
  /// Stream of connectivity status updates
  ///
  /// This stream emits a new [ConnectivityStatus] whenever the network
  /// connectivity changes. The stream is debounced to prevent rapid
  /// successive updates.
  Stream<ConnectivityStatus> get connectivityStream;

  /// Stream of network status changes (simplified enum version)
  Stream<NetworkStatus> get onConnectivityChanged;

  /// Check current connectivity status
  ///
  /// Returns the current connectivity status without starting the monitoring
  /// stream. This is useful for one-time checks.
  Future<ConnectivityStatus> checkConnectivity();

  /// Current network status (simplified enum version)
  Future<NetworkStatus> checkNetworkStatus();

  /// Whether the device currently has connectivity (async)
  Future<bool> get hasConnectivity;

  /// Whether the device currently has connectivity (synchronous)
  bool get hasConnectivitySync;

  /// Dispose any resources
  void dispose();
}

/// Implementation of ConnectivityService
///
/// This service provides a stream-based API for monitoring network connectivity
/// changes. It handles debouncing to prevent rapid status changes and provides
/// initial connectivity check on startup.
///
/// The implementation uses the connectivity_plus plugin to detect network
/// changes and wraps it in a more convenient API with debouncing and
/// detailed status information.
class ConnectivityServiceImpl implements ConnectivityService {
  /// Connectivity plugin instance
  final Connectivity _connectivity;

  /// Stream controller for detailed connectivity status updates
  StreamController<ConnectivityStatus>? _statusStreamController;

  /// Stream controller for simplified network status updates
  StreamController<NetworkStatus>? _networkStatusStreamController;

  /// Subscription to connectivity plugin's onConnectivityChanged stream
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;

  /// Timer for debouncing connectivity changes
  Timer? _debounceTimer;

  /// Debounce delay to prevent rapid status changes (milliseconds)
  final int debounceMs;

  /// Last emitted connectivity status
  ConnectivityStatus? _lastStatus;

  /// Last known network status (simplified)
  NetworkStatus _lastKnownNetworkStatus = NetworkStatus.disconnected;

  /// Creates a new [ConnectivityServiceImpl] instance
  ///
  /// [connectivity] - Connectivity plugin instance (defaults to Connectivity())
  /// [debounceMs] - Debounce delay in milliseconds (default: 300ms)
  ConnectivityServiceImpl({
    Connectivity? connectivity,
    this.debounceMs = 300,
  }) : _connectivity = connectivity ?? Connectivity() {
    // Initialize with current status
    _initializeStatus();
  }

  /// Initialize the service with current connectivity status
  void _initializeStatus() {
    checkConnectivity().then((status) {
      _lastStatus = status;
      _lastKnownNetworkStatus = status.toNetworkStatus();

      // Emit initial status if streams are active
      if (_statusStreamController != null &&
          !_statusStreamController!.isClosed) {
        _statusStreamController!.add(status);
      }
      if (_networkStatusStreamController != null &&
          !_networkStatusStreamController!.isClosed) {
        _networkStatusStreamController!.add(status.toNetworkStatus());
      }

      debugPrint('🌐 Connectivity initialized: ${status.connectionType} '
          '(connected: ${status.isConnected})');
    });
  }

  @override
  Stream<ConnectivityStatus> get connectivityStream {
    _statusStreamController ??= StreamController<ConnectivityStatus>.broadcast(
      onListen: _startMonitoring,
      onCancel: _stopMonitoring,
    );

    // If we already have a status, emit it immediately
    if (_lastStatus != null && !_statusStreamController!.isClosed) {
      // Use a delayed microtask to avoid emitting during synchronous construction
      Future.microtask(() {
        if (_statusStreamController != null &&
            !_statusStreamController!.isClosed) {
          _statusStreamController!.add(_lastStatus!);
        }
      });
    }

    return _statusStreamController!.stream;
  }

  @override
  Stream<NetworkStatus> get onConnectivityChanged {
    _networkStatusStreamController ??=
        StreamController<NetworkStatus>.broadcast(
      onListen: _startMonitoring,
      onCancel: _stopMonitoring,
    );

    // If we already have a status, emit it immediately
    if (_lastStatus != null && !_networkStatusStreamController!.isClosed) {
      // Use a delayed microtask to avoid emitting during synchronous construction
      Future.microtask(() {
        if (_networkStatusStreamController != null &&
            !_networkStatusStreamController!.isClosed) {
          _networkStatusStreamController!.add(_lastStatus!.toNetworkStatus());
        }
      });
    }

    return _networkStatusStreamController!.stream;
  }

  @override
  Future<ConnectivityStatus> checkConnectivity() async {
    try {
      final results = await _connectivity.checkConnectivity();
      final status = ConnectivityStatus.fromConnectivityResult(results);

      _lastStatus = status;
      _lastKnownNetworkStatus = status.toNetworkStatus();

      debugPrint('🌐 Connectivity check: ${status.connectionType} '
          '(connected: ${status.isConnected})');

      return status;
    } catch (e) {
      debugPrint('❌ Error checking connectivity: $e');

      // Return disconnected status on error
      final status = ConnectivityStatus.disconnected();
      _lastStatus = status;
      _lastKnownNetworkStatus = NetworkStatus.disconnected;
      return status;
    }
  }

  @override
  Future<NetworkStatus> checkNetworkStatus() async {
    final status = await checkConnectivity();
    return status.toNetworkStatus();
  }

  @override
  Future<bool> get hasConnectivity async {
    final status = await checkConnectivity();
    return status.isConnected;
  }

  @override
  bool get hasConnectivitySync =>
      _lastKnownNetworkStatus == NetworkStatus.connected;

  /// Start monitoring connectivity changes
  void _startMonitoring() {
    if (_connectivitySubscription != null) {
      // Already monitoring
      return;
    }

    debugPrint('🌐 Starting connectivity monitoring...');

    // Listen to connectivity changes
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen(
      (results) {
        _handleConnectivityChange(results);
      },
      onError: (error) {
        debugPrint('❌ Connectivity stream error: $error');
        _emitDisconnectedStatus();
      },
    );
  }

  /// Stop monitoring connectivity changes
  void _stopMonitoring() {
    // Only stop if no streams are actively listening
    final hasActiveListeners = (_statusStreamController != null &&
            _statusStreamController!.hasListener) ||
        (_networkStatusStreamController != null &&
            _networkStatusStreamController!.hasListener);

    if (hasActiveListeners) {
      return; // Still have listeners, don't stop
    }

    debugPrint('🌐 Stopping connectivity monitoring...');

    _debounceTimer?.cancel();
    _debounceTimer = null;

    _connectivitySubscription?.cancel();
    _connectivitySubscription = null;
  }

  /// Handle connectivity change with debouncing
  void _handleConnectivityChange(List<ConnectivityResult> results) {
    // Cancel any pending debounce timer
    _debounceTimer?.cancel();

    final newStatus = ConnectivityStatus.fromConnectivityResult(results);

    // If status hasn't changed, skip emitting
    if (_lastStatus != null && _lastStatus == newStatus) {
      return;
    }

    // Set debounce timer
    _debounceTimer = Timer(Duration(milliseconds: debounceMs), () {
      _lastStatus = newStatus;
      _lastKnownNetworkStatus = newStatus.toNetworkStatus();

      // Emit to both streams
      if (_statusStreamController != null &&
          !_statusStreamController!.isClosed) {
        _statusStreamController!.add(newStatus);
      }
      if (_networkStatusStreamController != null &&
          !_networkStatusStreamController!.isClosed) {
        _networkStatusStreamController!.add(newStatus.toNetworkStatus());
      }

      debugPrint('🌐 Connectivity changed: ${newStatus.connectionType} '
          '(connected: ${newStatus.isConnected})');
    });
  }

  /// Emit a disconnected status (used on errors)
  void _emitDisconnectedStatus() {
    final status = ConnectivityStatus.disconnected();

    _lastStatus = status;
    _lastKnownNetworkStatus = NetworkStatus.disconnected;

    if (_statusStreamController != null && !_statusStreamController!.isClosed) {
      _statusStreamController!.add(status);
    }
    if (_networkStatusStreamController != null &&
        !_networkStatusStreamController!.isClosed) {
      _networkStatusStreamController!.add(NetworkStatus.disconnected);
    }
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _debounceTimer = null;

    _connectivitySubscription?.cancel();
    _connectivitySubscription = null;

    _statusStreamController?.close();
    _statusStreamController = null;

    _networkStatusStreamController?.close();
    _networkStatusStreamController = null;

    _lastStatus = null;
  }
}
