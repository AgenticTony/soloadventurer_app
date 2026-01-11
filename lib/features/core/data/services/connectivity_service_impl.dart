import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/services/connectivity_service.dart';

part 'connectivity_service_impl.g.dart';

class ConnectivityServiceImpl implements ConnectivityService {
  final Connectivity _connectivity;
  final _statusController = StreamController<NetworkStatus>.broadcast();
  NetworkStatus _lastKnownStatus = NetworkStatus.disconnected;

  ConnectivityServiceImpl({Connectivity? connectivity})
      : _connectivity = connectivity ?? Connectivity() {
    // Initialize stream with current status
    checkConnectivity().then((status) {
      _lastKnownStatus = status;
      _statusController.add(status);
    });

    // Listen to native connectivity changes
    _connectivity.onConnectivityChanged.listen((results) {
      // If any connection type is available, consider it connected
      final status = results.isEmpty
          ? NetworkStatus.disconnected
          : _mapConnectivityResult(results.first);
      _lastKnownStatus = status;
      _statusController.add(status);
    });
  }

  @override
  Stream<NetworkStatus> get onConnectivityChanged => _statusController.stream;

  @override
  Future<NetworkStatus> checkConnectivity() async {
    final results = await _connectivity.checkConnectivity();
    final status = results.isEmpty
        ? NetworkStatus.disconnected
        : _mapConnectivityResult(results.first);
    _lastKnownStatus = status;
    return status;
  }

  @override
  Future<bool> get hasConnectivity async {
    final status = await checkConnectivity();
    return status == NetworkStatus.connected;
  }

  @override
  bool get hasConnectivitySync => _lastKnownStatus == NetworkStatus.connected;

  @override
  void dispose() {
    _statusController.close();
  }

  NetworkStatus _mapConnectivityResult(ConnectivityResult result) {
    switch (result) {
      case ConnectivityResult.none:
        return NetworkStatus.disconnected;
      case ConnectivityResult.bluetooth:
      case ConnectivityResult.wifi:
      case ConnectivityResult.ethernet:
      case ConnectivityResult.mobile:
      case ConnectivityResult.vpn:
      case ConnectivityResult.other:
        return NetworkStatus.connected;
    }
  }
}

@riverpod
ConnectivityService connectivityServiceImpl(Ref ref) {
  final service = ConnectivityServiceImpl();
  ref.onDispose(() => service.dispose());
  return service;
}
