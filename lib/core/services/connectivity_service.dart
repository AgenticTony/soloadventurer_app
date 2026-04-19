import 'package:connectivity_plus/connectivity_plus.dart';

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
