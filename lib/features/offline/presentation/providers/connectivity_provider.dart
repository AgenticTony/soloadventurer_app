import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soloadventurer/app/di/service_locator.dart';
import 'package:soloadventurer/features/offline/domain/services/connectivity_service.dart';

/// Provider for the ConnectivityService from DI
///
/// This provides access to the singleton ConnectivityService instance
/// managed by GetIt dependency injection.
final connectivityServiceProvider = Provider<ConnectivityService>((ref) {
  return getIt<ConnectivityService>();
});

/// State for connectivity status in the UI
///
/// This wraps [ConnectivityStatus] with additional helper methods
/// for easy consumption by UI components.
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

/// Notifier for managing connectivity state
///
/// This notifier subscribes to [ConnectivityService]'s stream
/// and exposes the current connectivity status to UI components.
/// It automatically handles subscription lifecycle and disposal.
class ConnectivityNotifier extends StateNotifier<ConnectivityState> {
  /// Reference to the ConnectivityService
  final ConnectivityService _connectivityService;

  /// Subscription to connectivity status stream
  StreamSubscription<ConnectivityStatus>? _subscription;

  /// Creates a new [ConnectivityNotifier]
  ///
  /// [_connectivityService] - The connectivity service to monitor
  ConnectivityNotifier(this._connectivityService)
      : super(ConnectivityState.disconnected()) {
    // Start monitoring connectivity
    _startMonitoring();
  }

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
  ///
  /// This performs a one-time check of connectivity status
  /// and updates the state accordingly.
  Future<void> checkConnectivity() async {
    try {
      final status = await _connectivityService.checkConnectivity();
      state = ConnectivityState.fromStatus(status);
    } catch (e) {
      state = ConnectivityState.disconnected();
    }
  }

  /// Refresh connectivity status
  ///
  /// Alias for [checkConnectivity] for more semantic usage
  Future<void> refresh() => checkConnectivity();

  @override
  void dispose() {
    // Cancel subscription when notifier is disposed
    _subscription?.cancel();
    _subscription = null;
    super.dispose();
  }
}

/// Provider for connectivity state
///
/// This provider exposes the current connectivity status to the app.
/// It auto-disposes when no longer being listened to, which helps
/// with resource management.
///
/// Example usage:
/// ```dart
/// final connectivityState = ref.watch(connectivityProvider);
/// if (connectivityState.isConnected) {
///   // App is online
/// } else {
///   // App is offline
/// }
/// ```
///
/// To access individual properties:
/// ```dart
/// final isConnected = ref.watch(connectivityProvider.select(
///   (state) => state.isConnected,
/// ));
///
/// final connectionType = ref.watch(connectivityProvider.select(
///   (state) => state.connectionType,
/// ));
/// ```
final connectivityProvider =
    StateNotifierProvider.autoDispose<ConnectivityNotifier, ConnectivityState>(
  (ref) {
    // Get the ConnectivityService from DI
    final connectivityService = ref.watch(connectivityServiceProvider);

    // Create and return the notifier
    final notifier = ConnectivityNotifier(connectivityService);

    // Dispose the notifier when provider is disposed
    ref.onDispose(() {
      notifier.dispose();
    });

    return notifier;
  },
);

/// Selector provider for connection status
///
/// Provides easy access to boolean connection status.
/// This is useful for widgets that only need to know if connected.
///
/// Example:
/// ```dart
/// final isConnected = ref.watch(isConnectedProvider);
/// ```
final isConnectedProvider = Provider.autoDispose<bool>((ref) {
  return ref.watch(connectivityProvider).isConnected;
});

/// Selector provider for connection type
///
/// Provides easy access to the current connection type.
/// This is useful for widgets that need to know the type of connection.
///
/// Example:
/// ```dart
/// final connectionType = ref.watch(connectionTypeProvider);
/// if (connectionType == ConnectionType.wifi) {
///   // On WiFi
/// }
/// ```
final connectionTypeProvider = Provider.autoDispose<ConnectionType>((ref) {
  return ref.watch(connectivityProvider).connectionType;
});

/// Selector provider for offline status
///
/// Returns true when device is NOT connected to any network.
/// This is a convenience provider for more readable code.
///
/// Example:
/// ```dart
/// final isOffline = ref.watch(isOfflineProvider);
/// if (isOffline) {
///   // Show offline banner
/// }
/// ```
final isOfflineProvider = Provider.autoDispose<bool>((ref) {
  return !ref.watch(connectivityProvider).isConnected;
});
