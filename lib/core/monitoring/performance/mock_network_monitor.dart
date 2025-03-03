import 'package:soloadventurer/core/monitoring/performance/network_monitor.dart';

/// A mock implementation of [NetworkMonitor] for testing
class MockNetworkMonitor extends NetworkMonitor {
  @override
  void trackRequest({
    required String path,
    required Duration duration,
    required int statusCode,
    required int responseSize,
    bool isError = false,
    String? errorMessage,
  }) {
    // Do nothing in tests
  }
}
