import 'dart:async';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:soloadventurer/app/providers/core_service_providers.dart' as core_providers;
import 'package:soloadventurer/core/services/connectivity_service.dart';
import 'package:soloadventurer/core/services/connectivity_service_impl.dart';

part 'connectivity_provider.g.dart';

/// Riverpod 3.0 Migration Notes:
/// - Converted from `StateNotifier<ConnectivityState>` to `Notifier<ConnectivityState>`
/// - Dependencies injected via ref.watch() in build() method
/// - AutoDispose enabled via @Riverpod annotation
/// - build() returns ConnectivityState not AsyncValue
/// - StreamSubscription management via ref.onDispose()
/// - Constructor auto-load and stream subscription moved to build() method

/// State for connectivity status in the UI
class ConnectivityState {
  final ConnectionType connectionType;
  final bool isConnected;
  final DateTime timestamp;

  const ConnectivityState({
    required this.connectionType,
    required this.isConnected,
    required this.timestamp,
  });

  factory ConnectivityState.fromStatus(ConnectivityStatus status) {
    return ConnectivityState(
      connectionType: status.connectionType,
      isConnected: status.isConnected,
      timestamp: status.timestamp,
    );
  }

  factory ConnectivityState.disconnected() {
    return ConnectivityState(
      connectionType: ConnectionType.none,
      isConnected: false,
      timestamp: DateTime.now(),
    );
  }

  factory ConnectivityState.connected(ConnectionType type) {
    return ConnectivityState(
      connectionType: type,
      isConnected: true,
      timestamp: DateTime.now(),
    );
  }

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

/// Provider for the offline ConnectivityService
@riverpod
ConnectivityService connectivityService(Ref ref) {
  final connectivity = ref.watch(core_providers.connectivityProvider);
  return ConnectivityServiceImpl(connectivity: connectivity, debounceMs: 300);
}

@riverpod
class ConnectivityNotifier extends _$ConnectivityNotifier {
  StreamSubscription<ConnectivityStatus>? _subscription;

  @override
  ConnectivityState build() {
    final connectivityService = ref.watch(connectivityServiceProvider);
    _startMonitoring(connectivityService);
    return ConnectivityState.disconnected();
  }

  void _startMonitoring(ConnectivityService connectivityService) {
    _subscription = connectivityService.connectivityStream.listen(
      (status) {
        state = ConnectivityState.fromStatus(status);
      },
      onError: (error) {
        state = ConnectivityState.disconnected();
      },
    );

    ref.onDispose(() {
      _subscription?.cancel();
      _subscription = null;
    });
  }

  Future<void> checkConnectivity() async {
    final connectivityService = ref.read(connectivityServiceProvider);
    try {
      final status = await connectivityService.checkConnectivity();
      state = ConnectivityState.fromStatus(status);
    } catch (e) {
      state = ConnectivityState.disconnected();
    }
  }

  Future<void> refresh() => checkConnectivity();
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
