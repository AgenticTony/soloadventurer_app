import 'dart:async';

/// Network connection type
enum NetworkConnectionType {
  /// No network connectivity
  none,

  /// Device is not connected to any network
  disconnected,

  /// Ethernet/Wired connection
  ethernet,

  /// WiFi connection
  wifi,

  /// Mobile/cellular connection (2G, 3G, 4G, 5G)
  mobile,

  /// Bluetooth tethering
  bluetooth,

  /// VPN connection
  vpn,

  /// Other connection type
  other,
}

/// Network status information
class NetworkStatus {
  /// Whether device is currently online
  final bool isOnline;

  /// Type of network connection
  final NetworkConnectionType connectionType;

  /// Timestamp when this status was detected
  final DateTime timestamp;

  const NetworkStatus({
    required this.isOnline,
    required this.connectionType,
    required this.timestamp,
  });

  /// Creates an offline status
  factory NetworkStatus.offline() {
    return NetworkStatus(
      isOnline: false,
      connectionType: NetworkConnectionType.none,
      timestamp: DateTime.now(),
    );
  }

  /// Creates an online status with the given connection type
  factory NetworkStatus.online(NetworkConnectionType connectionType) {
    return NetworkStatus(
      isOnline: true,
      connectionType: connectionType,
      timestamp: DateTime.now(),
    );
  }

  /// Copy with method for immutability
  NetworkStatus copyWith({
    bool? isOnline,
    NetworkConnectionType? connectionType,
    DateTime? timestamp,
  }) {
    return NetworkStatus(
      isOnline: isOnline ?? this.isOnline,
      connectionType: connectionType ?? this.connectionType,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  @override
  String toString() =>
      'NetworkStatus(isOnline: $isOnline, connectionType: $connectionType, '
      'timestamp: $timestamp)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is NetworkStatus &&
        other.isOnline == isOnline &&
        other.connectionType == connectionType &&
        other.timestamp == timestamp;
  }

  @override
  int get hashCode => isOnline.hashCode ^ connectionType.hashCode ^ timestamp.hashCode;
}

/// Abstract interface for monitoring network connectivity
///
/// Implementations should:
/// - Monitor network state changes in real-time
/// - Provide streams for reactive updates
/// - Handle network type transitions
/// - Detect offline/online status changes
abstract class NetworkConnectivity {
  /// Current network status
  NetworkStatus get currentStatus;

  /// Stream of network status changes
  ///
  /// Emits a new [NetworkStatus] whenever the network state changes.
  Stream<NetworkStatus> get statusStream;

  /// Stream that emits [true] when device comes online
  ///
  /// Only emits when transitioning from offline to online.
  Stream<bool> get onOnline;

  /// Stream that emits [true] when device goes offline
  ///
  /// Only emits when transitioning from online to offline.
  Stream<bool> get onOffline;

  /// Check if device is currently online
  ///
  /// Returns [true] if device has network connectivity
  bool get isOnline;

  /// Get the current network connection type
  ///
  /// Returns [NetworkConnectionType.none] if device is offline
  NetworkConnectionType get connectionType;

  /// Initialize the connectivity monitor
  ///
  /// Should be called before using the service to ensure
  /// initial network status is captured.
  Future<void> initialize();

  /// Start monitoring network status
  ///
  /// Begins listening for network changes and updating streams.
  Future<void> startMonitoring();

  /// Stop monitoring network status
  ///
  /// Stops listening for network changes and closes streams.
  Future<void> stopMonitoring();

  /// Dispose of resources
  ///
  /// Equivalent to calling [stopMonitoring].
  void dispose();
}

/// Provider signature for dependency injection
typedef NetworkConnectivityProvider = NetworkConnectivity Function();
