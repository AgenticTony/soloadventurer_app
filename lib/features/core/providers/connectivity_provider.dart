import 'dart:async';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

part 'connectivity_provider.g.dart';

@riverpod
class ConnectivityNotifier extends _$ConnectivityNotifier {
  StreamSubscription<List<ConnectivityResult>>? _subscription;

  @override
  bool build() {
    // Initialize as false until we get a real reading
    _initializeConnectivity();
    ref.onDispose(() {
      _subscription?.cancel();
    });
    return false;
  }

  Future<void> _initializeConnectivity() async {
    try {
      final results = await Connectivity().checkConnectivity();
      _updateConnectionState(results);

      _subscription = Connectivity().onConnectivityChanged.listen(
        _updateConnectionState,
        onError: (error) {
          state = false; // Assume offline on errors
        },
      );
    } catch (e) {
      state = false; // Assume offline on errors
    }
  }

  void _updateConnectionState(List<ConnectivityResult> results) {
    // Consider online if any connection type is available
    state = results.any((result) => result != ConnectivityResult.none);
  }
}
