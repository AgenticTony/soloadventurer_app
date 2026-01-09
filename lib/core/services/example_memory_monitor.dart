import 'package:flutter/foundation.dart';
import 'package:soloadventurer/core/services/services.dart';

/// Example 1: Basic Memory Monitoring
///
/// Demonstrates basic initialization and alert handling.
class ExampleBasicMemoryMonitoring {
  Future<void> run() async {
    debugPrint('=== Example 1: Basic Memory Monitoring ===\n');

    await MemoryMonitor.initialize(
      config: const MemoryMonitorConfig(
        warningThresholdBytes: 150 * 1024 * 1024,  // 150 MB
        criticalThresholdBytes: 180 * 1024 * 1024, // 180 MB
        monitoringInterval: Duration(seconds: 5),
      ),
      onAlert: (alert) {
        debugPrint('🚨 ALERT [${alert.level.name}]:');
        debugPrint('  Message: ${alert.message}');
        debugPrint('  Current: ${alert.currentUsageMB.toStringAsFixed(2)} MB');
        debugPrint('  Threshold: ${alert.thresholdMB.toStringAsFixed(0)} MB');

        if (alert.level == MemoryAlertLevel.critical) {
          debugPrint('  ❌ ACTION: Clearing caches!');
          // ImageCacheConfig.clearMemoryCache();
        }
      },
    );

    debugPrint('✅ Memory monitor initialized\n');

    // Listen to memory updates
    final subscription = MemoryMonitor.memoryStream.listen((snapshot) {
      debugPrint(
          '📊 Memory: ${snapshot.memoryUsageMB.toStringAsFixed(2)} MB at ${snapshot.timestamp.toIso8601String()}');
    });

    // Run for 20 seconds
    debugPrint('Monitoring for 20 seconds...\n');
    await Future.delayed(const Duration(seconds: 20));

    // Get statistics
    final stats = await MemoryMonitor.getStatistics();
    debugPrint('\n📈 Statistics:');
    debugPrint(stats.toString());

    // Cancel subscription
    await subscription.cancel();

    // Cleanup
    await MemoryMonitor.dispose();
    debugPrint('\n✅ Memory monitor disposed');
  }
}

/// Example 2: Memory Statistics Display
///
/// Demonstrates displaying memory statistics and trends.
class ExampleMemoryStatistics {
  Future<void> run() async {
    debugPrint('=== Example 2: Memory Statistics ===\n');

    await MemoryMonitor.initialize(
      config: const MemoryMonitorConfig(
        enableTrendAnalysis: true,
      ),
      onAlert: (alert) {
        debugPrint('Alert: ${alert.message}');
      },
    );

    // Wait for some snapshots
    debugPrint('Collecting data for 30 seconds...\n');
    await Future.delayed(const Duration(seconds: 30));

    // Get and display statistics
    final stats = await MemoryMonitor.getStatistics();

    debugPrint('📊 Memory Statistics:');
    debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    debugPrint(
        'Current:   ${stats.currentUsageMB.toStringAsFixed(2).padRight(10)} MB');
    debugPrint(
        'Average:   ${stats.averageUsageMB.toStringAsFixed(2).padRight(10)} MB');
    debugPrint(
        'Peak:      ${stats.peakUsageMB.toStringAsFixed(2).padRight(10)} MB');
    debugPrint(
        'Lowest:    ${stats.lowestUsageMB.toStringAsFixed(2).padRight(10)} MB');
    debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    debugPrint('Snapshots: ${stats.snapshotCount}');
    debugPrint('Duration: ${stats.monitoringDuration.inMinutes} minutes');
    debugPrint('Trend: ${stats.trend.name} (${stats.trendPercentage.toStringAsFixed(1)}%)');

    // Display trend analysis
    debugPrint('\n🔍 Trend Analysis:');
    switch (stats.trend) {
      case MemoryTrend.increasing:
        debugPrint('  ⚠️  Memory usage is INCREASING');
        debugPrint('  ⚠️  Possible memory leak detected!');
        debugPrint('  ⚠️  Investigate memory allocation patterns.');
        break;
      case MemoryTrend.decreasing:
        debugPrint('  ✅ Memory usage is DECREASING');
        debugPrint('  ✅ Good memory management!');
        break;
      case MemoryTrend.stable:
        debugPrint('  ✅ Memory usage is STABLE');
        debugPrint('  ✅ No significant changes detected.');
        break;
    }

    await MemoryMonitor.dispose();
  }
}

/// Example 3: Device-Specific Configuration
///
/// Demonstrates using different configurations for different devices.
class ExampleDeviceSpecificConfiguration {
  Future<void> run() async {
    debugPrint('=== Example 3: Device-Specific Configuration ===\n');

    // Simulate detecting device capabilities
    final isLowMemoryDevice = _detectLowMemoryDevice();

    final config = isLowMemoryDevice
        ? MemoryMonitorConfig.forLowMemoryDevice()
        : MemoryMonitorConfig.forHighMemoryDevice();

    debugPrint('Device: ${isLowMemoryDevice ? "Low-End" : "High-End"}');
    debugPrint('Warning Threshold: ${config.warningThresholdMB.toStringAsFixed(0)} MB');
    debugPrint('Critical Threshold: ${config.criticalThresholdMB.toStringAsFixed(0)} MB');
    debugPrint('Monitoring Interval: ${config.monitoringInterval.inSeconds}s');
    debugPrint('Max History: ${config.maxHistorySize} snapshots\n');

    await MemoryMonitor.initialize(
      config: config,
      onAlert: (alert) {
        debugPrint('${alert.level.name.toUpperCase()}: ${alert.message}');

        if (isLowMemoryDevice && alert.level == MemoryAlertLevel.warning) {
          // Aggressive cache clearing for low-end devices
          debugPrint('  🔧 Aggressive cache clearing (low-end device)');
          // ImageCacheConfig.clearMemoryCache();
        }
      },
    );

    // Monitor for 15 seconds
    await Future.delayed(const Duration(seconds: 15));

    await MemoryMonitor.dispose();
  }

  bool _detectLowMemoryDevice() {
    // In a real app, you would check actual device memory
    // For this example, we simulate it
    return false; // Assume high-end device
  }
}

/// Example 4: Automatic Cache Management
///
/// Demonstrates automatic cache clearing based on memory alerts.
class ExampleAutomaticCacheManagement {
  Future<void> run() async {
    debugPrint('=== Example 4: Automatic Cache Management ===\n');

    await MemoryMonitor.initialize(
      config: const MemoryMonitorConfig(
        warningThresholdBytes: 120 * 1024 * 1024,  // 120 MB
        criticalThresholdBytes: 150 * 1024 * 1024, // 150 MB
      ),
      onAlert: (alert) {
        debugPrint('🚨 ${alert.level.name} Alert: ${alert.message}');
      },
    );

    // Set up automatic cache management
    MemoryMonitor.memoryStream.listen((snapshot) async {
      final alertLevel = MemoryMonitor.getCurrentAlertLevel();

      if (alertLevel == MemoryAlertLevel.warning) {
        debugPrint('⚠️  Warning level - Clearing image cache');
        // await ImageCacheConfig.clearMemoryCache();
        debugPrint('  ✅ Image cache cleared');
      } else if (alertLevel == MemoryAlertLevel.critical) {
        debugPrint('❌ Critical level - Clearing all caches');
        // await ImageCacheConfig.clearAllCaches();
        debugPrint('  ✅ All caches cleared');

        // Additional cleanup actions
        await _performCriticalCleanup();
      }
    });

    // Monitor for 20 seconds
    debugPrint('Monitoring with auto cache management...\n');
    await Future.delayed(const Duration(seconds: 20));

    await MemoryMonitor.dispose();
  }

  Future<void> _performCriticalCleanup() async {
    debugPrint('  🔧 Performing critical cleanup:');
    debugPrint('    - Clearing thumbnail cache');
    // await ThumbnailService.clearCache();
    debugPrint('    - Releasing unused resources');
    // _releaseUnusedResources();
    debugPrint('    - Clearing memory history');
    MemoryMonitor.clearHistory();
    debugPrint('  ✅ Critical cleanup complete');
  }
}

/// Example 5: Memory-Leak Detection
///
/// Demonstrates detecting potential memory leaks using trend analysis.
class ExampleMemoryLeakDetection {
  Timer? _leakCheckTimer;

  Future<void> run() async {
    debugPrint('=== Example 5: Memory-Leak Detection ===\n');

    await MemoryMonitor.initialize(
      config: const MemoryMonitorConfig(
        enableTrendAnalysis: true,
        monitoringInterval: Duration(seconds: 2),
      ),
      onAlert: (alert) {
        debugPrint('Alert: ${alert.message}');
      },
    );

    // Start leak detection
    _startLeakDetection();

    // Monitor for 30 seconds
    debugPrint('Monitoring for memory leaks...\n');
    await Future.delayed(const Duration(seconds: 30));

    // Stop leak detection
    _stopLeakDetection();

    await MemoryMonitor.dispose();
  }

  void _startLeakDetection() {
    _leakCheckTimer = Timer.periodic(const Duration(seconds: 10), (_) async {
      final stats = await MemoryMonitor.getStatistics();

      debugPrint('\n🔍 Leak Detection Check:');
      debugPrint('  Trend: ${stats.trend.name}');
      debugPrint('  Change: ${stats.trendPercentage.toStringAsFixed(1)}%');

      if (stats.trend == MemoryTrend.increasing) {
        if (stats.trendPercentage > 30) {
          debugPrint('  ❌ SEVERE: Memory increased by ${stats.trendPercentage.toStringAsFixed(1)}%!');
          debugPrint('  ❌ CRITICAL MEMORY LEAK DETECTED!');
          await _dumpMemoryHistory();
        } else if (stats.trendPercentage > 15) {
          debugPrint('  ⚠️  WARNING: Memory increased by ${stats.trendPercentage.toStringAsFixed(1)}%');
          debugPrint('  ⚠️  Possible memory leak');
        } else {
          debugPrint('  ℹ️  Memory is slightly increasing (${stats.trendPercentage.toStringAsFixed(1)}%)');
        }
      } else if (stats.trend == MemoryTrend.decreasing) {
        debugPrint('  ✅ Memory usage is decreasing. Good!');
      } else {
        debugPrint('  ✅ Memory usage is stable');
      }
    });
  }

  void _stopLeakDetection() {
    _leakCheckTimer?.cancel();
  }

  Future<void> _dumpMemoryHistory() async {
    debugPrint('\n📋 Memory History Dump:');
    final history = MemoryMonitor.getHistory();

    if (history.isEmpty) {
      debugPrint('  (No history available)');
      return;
    }

    for (final snapshot in history) {
      debugPrint(
          '  ${snapshot.timestamp.toIso8601String()} - ${snapshot.memoryUsageMB.toStringAsFixed(2)} MB');
    }
  }
}

/// Example 6: Real-Time Memory Dashboard
///
/// Demonstrates displaying real-time memory updates in a dashboard.
class ExampleRealTimeMemoryDashboard {
  StreamSubscription<MemorySnapshot>? _subscription;

  Future<void> run() async {
    debugPrint('=== Example 6: Real-Time Memory Dashboard ===\n');

    await MemoryMonitor.initialize(
      config: const MemoryMonitorConfig(
        monitoringInterval: Duration(seconds: 2),
      ),
      onAlert: (alert) {
        debugPrint('🚨 ${alert.level.name}: ${alert.message}');
      },
    );

    // Subscribe to memory updates
    _subscription = MemoryMonitor.memoryStream.listen((snapshot) {
      _displayDashboard(snapshot);
    });

    // Run for 20 seconds
    debugPrint('Starting real-time dashboard...\n');
    await Future.delayed(const Duration(seconds: 20));

    // Cleanup
    await _subscription?.cancel();
    await MemoryMonitor.dispose();
  }

  void _displayDashboard(MemorySnapshot snapshot) {
    // Clear console (simulated)
    // In a real app, this would update a UI widget

    final alertLevel = MemoryMonitor.getCurrentAlertLevel();
    final alertIcon = alertLevel == MemoryAlertLevel.critical
        ? '🔴'
        : alertLevel == MemoryAlertLevel.warning
            ? '🟡'
            : '🟢';

    debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    debugPrint('📊 Real-Time Memory Dashboard');
    debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    debugPrint('Status: $alertIcon ${alertLevel.name.toUpperCase()}');
    debugPrint(
        'Memory: ${snapshot.memoryUsageMB.toStringAsFixed(2)} MB (${snapshot.memoryUsageBytes} bytes)');
    debugPrint(
        'Time: ${snapshot.timestamp.toIso8601String()}');

    // Show threshold indicators
    final config = MemoryMonitor.instance.config;
    final warningPercent =
        (snapshot.memoryUsageBytes / config.warningThresholdBytes * 100).clamp(0, 100);
    final criticalPercent =
        (snapshot.memoryUsageBytes / config.criticalThresholdBytes * 100).clamp(0, 100);

    debugPrint('Warning: ${warningPercent.toStringAsFixed(0)}% of ${config.warningThresholdMB.toStringAsFixed(0)} MB');
    debugPrint('Critical: ${criticalPercent.toStringAsFixed(0)}% of ${config.criticalThresholdMB.toStringAsFixed(0)} MB');

    debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');
  }
}

/// Example 7: Memory History Analysis
///
/// Demonstrates analyzing memory usage over time.
class ExampleMemoryHistoryAnalysis {
  Future<void> run() async {
    debugPrint('=== Example 7: Memory History Analysis ===\n');

    await MemoryMonitor.initialize(
      config: const MemoryMonitorConfig(
        maxHistorySize: 50,
        monitoringInterval: Duration(seconds: 1),
      ),
      onAlert: (alert) {
        debugPrint('Alert: ${alert.message}');
      },
    );

    // Collect history
    debugPrint('Collecting memory history...\n');
    await Future.delayed(const Duration(seconds: 20));

    // Get history
    final history = MemoryMonitor.getHistory();
    debugPrint('📜 Memory History (${history.length} snapshots):');
    debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

    // Display first 5 and last 5 snapshots
    final first5 = history.take(5).toList();
    final last5 = history.skip(history.length - 5).toList();

    debugPrint('First 5 snapshots:');
    for (final snapshot in first5) {
      debugPrint(
          '  ${snapshot.timestamp.toIso8601String()} - ${snapshot.memoryUsageMB.toStringAsFixed(2)} MB');
    }

    debugPrint('\nLast 5 snapshots:');
    for (final snapshot in last5) {
      debugPrint(
          '  ${snapshot.timestamp.toIso8601String()} - ${snapshot.memoryUsageMB.toStringAsFixed(2)} MB');
    }

    // Calculate statistics
    if (history.isNotEmpty) {
      final totalMemory =
          history.fold<int>(0, (sum, s) => sum + s.memoryUsageBytes);
      final avgMemory = totalMemory / history.length;
      final maxMemory =
          history.map((s) => s.memoryUsageBytes).reduce((a, b) => a > b ? a : b);
      final minMemory =
          history.map((s) => s.memoryUsageBytes).reduce((a, b) => a < b ? a : b);

      debugPrint('\n📊 History Statistics:');
      debugPrint('  Total snapshots: ${history.length}');
      debugPrint('  Average: ${(avgMemory / 1024 / 1024).toStringAsFixed(2)} MB');
      debugPrint('  Peak: ${(maxMemory / 1024 / 1024).toStringAsFixed(2)} MB');
      debugPrint('  Lowest: ${(minMemory / 1024 / 1024).toStringAsFixed(2)} MB');
      debugPrint(
          '  Range: ${((maxMemory - minMemory) / 1024 / 1024).toStringAsFixed(2)} MB');
    }

    await MemoryMonitor.dispose();
  }
}

/// Example 8: Dynamic Configuration Updates
///
/// Demonstrates updating monitoring configuration at runtime.
class ExampleDynamicConfiguration {
  Future<void> run() async {
    debugPrint('=== Example 8: Dynamic Configuration Updates ===\n');

    // Start with default config
    await MemoryMonitor.initialize(
      config: const MemoryMonitorConfig(
        warningThresholdBytes: 150 * 1024 * 1024,
        criticalThresholdBytes: 180 * 1024 * 1024,
        monitoringInterval: Duration(seconds: 5),
      ),
      onAlert: (alert) {
        debugPrint('Alert: ${alert.message}');
      },
    );

    debugPrint('✅ Initialized with default config');
    _displayCurrentConfig();

    // Monitor for 10 seconds
    debugPrint('\nMonitoring for 10 seconds...');
    await Future.delayed(const Duration(seconds: 10));

    // Update to aggressive monitoring
    debugPrint('\n🔄 Updating to aggressive monitoring...\n');
    await MemoryMonitor.updateConfig(
      const MemoryMonitorConfig(
        warningThresholdBytes: 100 * 1024 * 1024,
        criticalThresholdBytes: 120 * 1024 * 1024,
        monitoringInterval: Duration(seconds: 2),
      ),
    );

    _displayCurrentConfig();

    // Monitor for 10 more seconds
    debugPrint('\nMonitoring for 10 more seconds...');
    await Future.delayed(const Duration(seconds: 10));

    // Update to conservative monitoring
    debugPrint('\n🔄 Updating to conservative monitoring...\n');
    await MemoryMonitor.updateConfig(
      const MemoryMonitorConfig(
        warningThresholdBytes: 200 * 1024 * 1024,
        criticalThresholdBytes: 250 * 1024 * 1024,
        monitoringInterval: Duration(seconds: 10),
      ),
    );

    _displayCurrentConfig();

    // Monitor for 10 more seconds
    debugPrint('\nMonitoring for 10 more seconds...');
    await Future.delayed(const Duration(seconds: 10));

    await MemoryMonitor.dispose();
  }

  void _displayCurrentConfig() {
    final config = MemoryMonitor.instance.config;
    debugPrint('📋 Current Configuration:');
    debugPrint('  Warning threshold: ${config.warningThresholdMB.toStringAsFixed(0)} MB');
    debugPrint('  Critical threshold: ${config.criticalThresholdMB.toStringAsFixed(0)} MB');
    debugPrint('  Monitoring interval: ${config.monitoringInterval.inSeconds}s');
    debugPrint('  Max history: ${config.maxHistorySize}');
    debugPrint('  Trend analysis: ${config.enableTrendAnalysis}');
  }
}

/// Main example runner
///
/// Run all examples sequentially.
Future<void> main() async {
  // Note: These examples are for demonstration purposes
  // In a real app, you would only initialize MemoryMonitor once

  // Example 1: Basic monitoring
  // await ExampleBasicMemoryMonitoring().run();

  // Example 2: Statistics
  // await ExampleMemoryStatistics().run();

  // Example 3: Device-specific config
  // await ExampleDeviceSpecificConfiguration().run();

  // Example 4: Auto cache management
  // await ExampleAutomaticCacheManagement().run();

  // Example 5: Leak detection
  // await ExampleMemoryLeakDetection().run();

  // Example 6: Real-time dashboard
  // await ExampleRealTimeMemoryDashboard().run();

  // Example 7: History analysis
  // await ExampleMemoryHistoryAnalysis().run();

  // Example 8: Dynamic config
  // await ExampleDynamicConfiguration().run();

  debugPrint('\n✅ All examples completed!');
}
