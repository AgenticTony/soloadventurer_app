import 'dart:async';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:soloadventurer/core/services/connectivity_service.dart';
import 'package:soloadventurer/app/providers/offline_service_providers.dart';

part 'connectivity_provider.g.dart';

/// Re-export of connectivityServiceProvider from app/providers/offline_service_providers.dart
/// This maintains backward compatibility for existing imports
// The connectivityServiceProvider is now defined in app/providers/offline_service_providers.dart

/// Notifier for managing connectivity state
@Riverpod(keepAlive: true)
class ConnectivityNotifier extends _$ConnectivityNotifier {
  /// Subscription to connectivity status stream
  StreamSubscription<ConnectivityStatus>? _subscription;

  @override
  ConnectivityState build() {
    final connectivityService = ref.watch(connectivityServiceProvider);
    _connectivityService = connectivityService;
    _startMonitoring();
    return ConnectivityState.disconnected();
  }

  late final ConnectivityService _connectivityService;

  /// Start monitoring connectivity changes
  void _startMonitoring() {
    // Subscribe to connectivity status updates
    _subscription = _connectivityService.connectivityStream.listen(
      (status) {
        // Update state when connectivity changes
        state = ConnectivityState.fromStatus(status);
      },
      onError: (error) {
        // Handle errors by setting disconnected state
        state = ConnectivityState.disconnected();
      },
    );
  }

  /// Check current connectivity status
  Future<void> checkConnectivity() async {
    try {
      final status = await _connectivityService.checkConnectivity();
      state = ConnectivityState.fromStatus(status);
    } catch (e) {
      state = ConnectivityState.disconnected();
    }
  }

  /// Refresh connectivity status
  Future<void> refresh() => checkConnectivity();
}

/// State for connectivity status in the UI
class ConnectivityState {
  /// Current connection type
  final ConnectionType connectionType;

  /// Whether device is connected to network
  final bool isConnected;

  /// Timestamp when status was last updated
  final DateTime timestamp;

  /// Creates a new [ConnectivityState] instance
  const ConnectivityState({
    required this.connectionType,
    required this.isConnected,
    required this.timestamp,
  });

  /// Creates a state from ConnectivityStatus
  factory ConnectivityState.fromStatus(ConnectivityStatus status) {
    return ConnectivityState(
      connectionType: status.connectionType,
      isConnected: status.isConnected,
      timestamp: status.timestamp,
    );
  }

  /// Creates a disconnected state
  factory ConnectivityState.disconnected() {
    return ConnectivityState(
      connectionType: ConnectionType.none,
      isConnected: false,
      timestamp: DateTime.now(),
    );
  }

  /// Creates a connected state with specified type
  factory ConnectivityState.connected(ConnectionType type) {
    return ConnectivityState(
      connectionType: type,
      isConnected: true,
      timestamp: DateTime.now(),
    );
  }

  /// Copy with method for immutability
  ConnectivityState copyWith({
    ConnectionType? connectionType,
    bool? isConnected,
    DateTime? timestamp,
  }) {
    return ConnectivityState(
      connectionType: connectionType ?? this.connectionType,
      isConnected: isConnected ?? this.isConnected,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  @override
  String toString() {
    return 'ConnectivityState{connectionType: $connectionType, '
        'isConnected: $isConnected, timestamp: $timestamp}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ConnectivityState &&
        other.connectionType == connectionType &&
        other.isConnected == isConnected;
  }

  @override
  int get hashCode => connectionType.hashCode ^ isConnected.hashCode;
}

/// Selector provider for connection status
@riverpod
bool isConnected(Ref ref) {
  return ref.watch(connectivityProvider).isConnected;
}

/// Selector provider for connection type
@riverpod
ConnectionType connectionType(Ref ref) {
  return ref.watch(connectivityProvider).connectionType;
}

/// Selector provider for offline status
@riverpod
bool isOffline(Ref ref) {
  return !ref.watch(connectivityProvider).isConnected;
}
