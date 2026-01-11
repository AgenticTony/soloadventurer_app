import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'connectivity_service.g.dart';

/// Represents the current network connectivity state
enum NetworkStatus {
  /// Device has a valid network connection
  connected,

  /// Device has no network connection
  disconnected
}

/// Abstract interface for connectivity operations
abstract class ConnectivityService {
  /// Stream of network status changes
  Stream<NetworkStatus> get onConnectivityChanged;

  /// Current network status
  Future<NetworkStatus> checkConnectivity();

  /// Whether the device currently has connectivity
  Future<bool> get hasConnectivity;

  /// Whether the device currently has connectivity (synchronous)
  bool get hasConnectivitySync;

  /// Dispose any resources
  void dispose();
}

/// Provider for the connectivity service implementation
@riverpod
ConnectivityService connectivityService(Ref ref) {
  throw UnimplementedError('Connectivity service implementation not provided');
}

/// Provider that exposes the current network status
@riverpod
class NetworkStatusNotifier extends _$NetworkStatusNotifier {
  @override
  Future<NetworkStatus> build() async {
    final service = ref.watch(connectivityServiceProvider);

    // Listen to connectivity changes
    ref.listen(connectivityServiceProvider, (_, __) async {
      state = const AsyncLoading();
      state = AsyncData(await service.checkConnectivity());
    });

    // Setup stream subscription
    final subscription = service.onConnectivityChanged.listen((status) {
      state = AsyncData(status);
    });

    // Cleanup on dispose
    ref.onDispose(() {
      subscription.cancel();
    });

    return service.checkConnectivity();
  }

  Future<bool> get hasConnectivity async {
    final status = await future;
    return status == NetworkStatus.connected;
  }
}
