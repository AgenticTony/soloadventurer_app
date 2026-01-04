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

  /// Unknown connection type (ethernet, vpn, etc.)
  other,
}

/// Connectivity status data class
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

/// Service to monitor network connectivity changes
///
/// This service provides a stream-based API for monitoring network connectivity
/// changes. It handles debouncing to prevent rapid status changes and provides
/// initial connectivity check on startup.
///
/// Example usage:
/// ```dart
/// final connectivityService = ConnectivityService();
///
/// // Listen to connectivity changes
/// connectivityService.connectivityStream.listen((status) {
///   print('Connected: ${status.isConnected}');
///   print('Type: ${status.connectionType}');
/// });
///
/// // Check current connectivity
/// final currentStatus = await connectivityService.checkConnectivity();
/// ```
class ConnectivityService {
  /// Connectivity plugin instance
  final Connectivity _connectivity;

  /// Stream controller for connectivity status updates
  StreamController<ConnectivityStatus>? _streamController;

  /// Subscription to connectivity plugin's onConnectivityChanged stream
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;

  /// Timer for debouncing connectivity changes
  Timer? _debounceTimer;

  /// Debounce delay to prevent rapid status changes (milliseconds)
  final int debounceMs;

  /// Last emitted connectivity status
  ConnectivityStatus? _lastStatus;

  /// Creates a new [ConnectivityService] instance
  ///
  /// [connectivity] - Connectivity plugin instance (defaults to Connectivity())
  /// [debounceMs] - Debounce delay in milliseconds (default: 300ms)
  ConnectivityService({
    Connectivity? connectivity,
    this.debounceMs = 300,
  }) : _connectivity = connectivity ?? Connectivity();

  /// Stream of connectivity status updates
  ///
  /// This stream emits a new [ConnectivityStatus] whenever the network
  /// connectivity changes. The stream is debounced to prevent rapid
  /// successive updates.
  Stream<ConnectivityStatus> get connectivityStream {
    _streamController ??= StreamController<ConnectivityStatus>.broadcast(
      onListen: _startMonitoring,
      onCancel: _stopMonitoring,
    );

    return _streamController!.stream;
  }

  /// Check current connectivity status
  ///
  /// Returns the current connectivity status without starting the monitoring
  /// stream. This is useful for one-time checks.
  Future<ConnectivityStatus> checkConnectivity() async {
    try {
      final results = await _connectivity.checkConnectivity();
      final status = ConnectivityStatus.fromConnectivityResult(results);

      _lastStatus = status;

      debugPrint('🌐 Connectivity check: ${status.connectionType} '
          '(connected: ${status.isConnected})');

      return status;
    } catch (e) {
      debugPrint('❌ Error checking connectivity: $e');

      // Return disconnected status on error
      final status = ConnectivityStatus.disconnected();
      _lastStatus = status;
      return status;
    }
  }

  /// Start monitoring connectivity changes
  void _startMonitoring() {
    if (_connectivitySubscription != null) {
      // Already monitoring
      return;
    }

    debugPrint('🌐 Starting connectivity monitoring...');

    // Perform initial check
    checkConnectivity().then((status) {
      if (_streamController != null && !_streamController!.isClosed) {
        _streamController!.add(status);
      }
    });

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

      if (_streamController != null && !_streamController!.isClosed) {
        _streamController!.add(newStatus);
      }

      debugPrint('🌐 Connectivity changed: ${newStatus.connectionType} '
          '(connected: ${newStatus.isConnected})');
    });
  }

  /// Emit a disconnected status (used on errors)
  void _emitDisconnectedStatus() {
    final status = ConnectivityStatus.disconnected();

    _lastStatus = status;

    if (_streamController != null && !_streamController!.isClosed) {
      _streamController!.add(status);
    }
  }

  /// Dispose of resources
  ///
  /// Call this when the service is no longer needed to prevent memory leaks.
  void dispose() {
    _stopMonitoring();

    _streamController?.close();
    _streamController = null;

    _lastStatus = null;
  }
}
