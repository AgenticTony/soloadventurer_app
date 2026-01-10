import 'package:soloadventurer/core/monitoring/performance/network_monitor.dart';

/// A mock implementation of [NetworkMonitor] for testing
class MockNetworkMonitor extends NetworkMonitor {
  @override
  void trackRequest(String endpoint) {
    // Do nothing in tests
  }

  @override
  void trackResponse(String path, int statusCode) {
    // Do nothing in tests
  }

  @override
  void trackError(String path, String errorMessage) {
    // Do nothing in tests
  }

  @override
  void trackRequestAndResponse({
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
