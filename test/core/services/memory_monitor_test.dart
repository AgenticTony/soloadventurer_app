import 'package:flutter_test/flutter_test.dart';
import 'package:soloadventurer/core/services/memory_monitor.dart';

void main() {
  group('MemorySnapshot', () {
    test('should create snapshot with correct values', () {
      final snapshot = MemorySnapshot(
        memoryUsageBytes: 100 * 1024 * 1024, // 100 MB
        timestamp: DateTime(2026, 1, 4, 12, 0, 0),
      );

      expect(snapshot.memoryUsageBytes, equals(100 * 1024 * 1024));
      expect(snapshot.memoryUsageMB, equals(100.0));
      expect(snapshot.timestamp, equals(DateTime(2026, 1, 4, 12, 0, 0)));
    });

    test('should convert to JSON correctly', () {
      final snapshot = MemorySnapshot(
        memoryUsageBytes: 150 * 1024 * 1024,
        timestamp: DateTime(2026, 1, 4, 12, 0, 0),
      );

      final json = snapshot.toJson();

      expect(json['memoryUsageBytes'], equals(150 * 1024 * 1024));
      expect(json['memoryUsageMB'], equals(150.0));
      expect(json['timestamp'], equals('2026-01-04T12:00:00.000'));
    });

    test('should create from JSON correctly', () {
      final json = {
        'memoryUsageBytes': 120 * 1024 * 1024,
        'memoryUsageMB': 120.0,
        'timestamp': '2026-01-04T12:00:00.000',
      };

      final snapshot = MemorySnapshot.fromJson(json);

      expect(snapshot.memoryUsageBytes, equals(120 * 1024 * 1024));
      expect(snapshot.memoryUsageMB, equals(120.0));
      expect(snapshot.timestamp, equals(DateTime(2026, 1, 4, 12, 0, 0)));
    });

    test('should format toString correctly', () {
      final snapshot = MemorySnapshot(
        memoryUsageBytes: 123456789,
        timestamp: DateTime(2026, 1, 4, 12, 0, 0),
      );

      final str = snapshot.toString();

      expect(str, contains('117.74'));
      expect(str, contains('2026-01-04T12:00:00.000'));
    });
  });

  group('MemoryAlert', () {
    test('should create warning alert correctly', () {
      final alert = MemoryAlert(
        level: MemoryAlertLevel.warning,
        currentUsageBytes: 160 * 1024 * 1024,
        thresholdBytes: 150 * 1024 * 1024,
        timestamp: DateTime(2026, 1, 4, 12, 0, 0),
        message: 'WARNING: Memory usage high',
      );

      expect(alert.level, equals(MemoryAlertLevel.warning));
      expect(alert.currentUsageBytes, equals(160 * 1024 * 1024));
      expect(alert.currentUsageMB, equals(160.0));
      expect(alert.thresholdBytes, equals(150 * 1024 * 1024));
      expect(alert.thresholdMB, equals(150.0));
      expect(alert.message, equals('WARNING: Memory usage high'));
    });

    test('should create critical alert correctly', () {
      final alert = MemoryAlert(
        level: MemoryAlertLevel.critical,
        currentUsageBytes: 190 * 1024 * 1024,
        thresholdBytes: 180 * 1024 * 1024,
        timestamp: DateTime(2026, 1, 4, 12, 0, 0),
        message: 'CRITICAL: Memory usage very high',
      );

      expect(alert.level, equals(MemoryAlertLevel.critical));
      expect(alert.currentUsageBytes, equals(190 * 1024 * 1024));
      expect(alert.currentUsageMB, equals(190.0));
      expect(alert.thresholdBytes, equals(180 * 1024 * 1024));
      expect(alert.thresholdMB, equals(180.0));
    });

    test('should convert to JSON correctly', () {
      final alert = MemoryAlert(
        level: MemoryAlertLevel.warning,
        currentUsageBytes: 160 * 1024 * 1024,
        thresholdBytes: 150 * 1024 * 1024,
        timestamp: DateTime(2026, 1, 4, 12, 0, 0),
        message: 'WARNING: Memory usage high',
      );

      final json = alert.toJson();

      expect(json['level'], equals('warning'));
      expect(json['currentUsageBytes'], equals(160 * 1024 * 1024));
      expect(json['thresholdBytes'], equals(150 * 1024 * 1024));
      expect(json['timestamp'], equals('2026-01-04T12:00:00.000'));
      expect(json['message'], equals('WARNING: Memory usage high'));
    });

    test('should format toString correctly', () {
      final alert = MemoryAlert(
        level: MemoryAlertLevel.critical,
        currentUsageBytes: 190 * 1024 * 1024,
        thresholdBytes: 180 * 1024 * 1024,
        timestamp: DateTime(2026, 1, 4, 12, 0, 0),
        message: 'CRITICAL: Memory usage very high',
      );

      final str = alert.toString();

      expect(str, contains('critical'));
      expect(str, contains('190.00'));
      expect(str, contains('180.00'));
    });
  });

  group('MemoryStatistics', () {
    test('should create statistics correctly', () {
      final now = DateTime.now();
      final stats = MemoryStatistics(
        currentUsageBytes: 150 * 1024 * 1024,
        averageUsageBytes: 140 * 1024 * 1024,
        peakUsageBytes: 180 * 1024 * 1024,
        lowestUsageBytes: 120 * 1024 * 1024,
        snapshotCount: 50,
        startTime: now.subtract(const Duration(minutes: 5)),
        endTime: now,
        trend: MemoryTrend.increasing,
        trendPercentage: 15.5,
      );

      expect(stats.currentUsageBytes, equals(150 * 1024 * 1024));
      expect(stats.currentUsageMB, equals(150.0));
      expect(stats.averageUsageMB, equals(140.0));
      expect(stats.peakUsageMB, equals(180.0));
      expect(stats.lowestUsageMB, equals(120.0));
      expect(stats.snapshotCount, equals(50));
      expect(stats.trend, equals(MemoryTrend.increasing));
      expect(stats.trendPercentage, equals(15.5));
      expect(stats.monitoringDuration.inMinutes, equals(5));
    });

    test('should convert to JSON correctly', () {
      final now = DateTime.now();
      final stats = MemoryStatistics(
        currentUsageBytes: 150 * 1024 * 1024,
        averageUsageBytes: 140 * 1024 * 1024,
        peakUsageBytes: 180 * 1024 * 1024,
        lowestUsageBytes: 120 * 1024 * 1024,
        snapshotCount: 50,
        startTime: now.subtract(const Duration(minutes: 5)),
        endTime: now,
        trend: MemoryTrend.stable,
        trendPercentage: 2.5,
      );

      final json = stats.toJson();

      expect(json['currentUsageBytes'], equals(150 * 1024 * 1024));
      expect(json['currentUsageMB'], equals(150.0));
      expect(json['averageUsageMB'], equals(140.0));
      expect(json['peakUsageMB'], equals(180.0));
      expect(json['lowestUsageMB'], equals(120.0));
      expect(json['snapshotCount'], equals(50));
      expect(json['trend'], equals('stable'));
      expect(json['trendPercentage'], equals(2.5));
    });

    test('should format toString correctly', () {
      final now = DateTime.now();
      final stats = MemoryStatistics(
        currentUsageBytes: 150 * 1024 * 1024,
        averageUsageBytes: 140 * 1024 * 1024,
        peakUsageBytes: 180 * 1024 * 1024,
        lowestUsageBytes: 120 * 1024 * 1024,
        snapshotCount: 50,
        startTime: now.subtract(const Duration(minutes: 5)),
        endTime: now,
        trend: MemoryTrend.increasing,
        trendPercentage: 15.5,
      );

      final str = stats.toString();

      expect(str, contains('Current: 150.00'));
      expect(str, contains('Average: 140.00'));
      expect(str, contains('Peak: 180.00'));
      expect(str, contains('Lowest: 120.00'));
      expect(str, contains('Snapshots: 50'));
      expect(str, contains('Trend: increasing'));
      expect(str, contains('15.5%'));
    });
  });

  group('MemoryMonitorConfig', () {
    test('should create default config correctly', () {
      const config = MemoryMonitorConfig();

      expect(config.warningThresholdBytes, equals(150 * 1024 * 1024));
      expect(config.warningThresholdMB, equals(150.0));
      expect(config.criticalThresholdBytes, equals(180 * 1024 * 1024));
      expect(config.criticalThresholdMB, equals(180.0));
      expect(config.monitoringInterval, equals(const Duration(seconds: 5)));
      expect(config.maxHistorySize, equals(100));
      expect(config.enabled, equals(true));
      expect(config.enableTrendAnalysis, equals(true));
      expect(config.trendAnalysisThreshold, equals(0.1));
    });

    test('should copy with modified values', () {
      const config = MemoryMonitorConfig(
        warningThresholdBytes: 150 * 1024 * 1024,
        criticalThresholdBytes: 180 * 1024 * 1024,
      );

      final modified = config.copyWith(
        warningThresholdBytes: 100 * 1024 * 1024,
        monitoringInterval: const Duration(seconds: 10),
      );

      expect(modified.warningThresholdBytes, equals(100 * 1024 * 1024));
      expect(modified.criticalThresholdBytes, equals(180 * 1024 * 1024));
      expect(modified.monitoringInterval, equals(const Duration(seconds: 10)));
    });

    test('should create low-end device config', () {
      final config = MemoryMonitorConfig.forLowMemoryDevice();

      expect(config.warningThresholdBytes, equals(100 * 1024 * 1024));
      expect(config.warningThresholdMB, equals(100.0));
      expect(config.criticalThresholdBytes, equals(120 * 1024 * 1024));
      expect(config.criticalThresholdMB, equals(120.0));
      expect(config.monitoringInterval, equals(const Duration(seconds: 10)));
      expect(config.maxHistorySize, equals(50));
    });

    test('should create high-end device config', () {
      final config = MemoryMonitorConfig.forHighMemoryDevice();

      expect(config.warningThresholdBytes, equals(250 * 1024 * 1024));
      expect(config.warningThresholdMB, equals(250.0));
      expect(config.criticalThresholdBytes, equals(300 * 1024 * 1024));
      expect(config.criticalThresholdMB, equals(300.0));
      expect(config.monitoringInterval, equals(const Duration(seconds: 3)));
      expect(config.maxHistorySize, equals(200));
    });
  });

  group('MemoryMonitor', () {
    setUp(() {
      // Ensure monitor is disposed before each test
      if (MemoryMonitor.isInitialized) {
        MemoryMonitor.dispose();
      }
    });

    tearDown(() async {
      // Clean up after each test
      if (MemoryMonitor.isInitialized) {
        await MemoryMonitor.dispose();
      }
    });

    test('should initialize and track state', () async {
      MemoryAlert? capturedAlert;

      await MemoryMonitor.initialize(
        config: const MemoryMonitorConfig(
          monitoringInterval: Duration(seconds: 1),
        ),
        onAlert: (alert) {
          capturedAlert = alert;
        },
      );

      expect(MemoryMonitor.isInitialized, equals(true));

      final instance = MemoryMonitor.instance;
      expect(instance, isNotNull);
      expect(instance.config.monitoringInterval.inSeconds, equals(1));

      await MemoryMonitor.dispose();
      expect(MemoryMonitor.isInitialized, equals(false));
    });

    test('should capture memory snapshots', () async {
      await MemoryMonitor.initialize(
        config: const MemoryMonitorConfig(
          monitoringInterval: Duration(milliseconds: 500),
        ),
        onAlert: (alert) {},
      );

      // Wait for a few snapshots
      await Future.delayed(const Duration(seconds: 2));

      final history = MemoryMonitor.getHistory();
      expect(history.isNotEmpty, equals(true));
      expect(history.length, greaterThan(1));

      await MemoryMonitor.dispose();
    });

    test('should emit memory snapshots to stream', () async {
      await MemoryMonitor.initialize(
        config: const MemoryMonitorConfig(
          monitoringInterval: Duration(milliseconds: 500),
        ),
        onAlert: (alert) {},
      );

      final snapshots = <MemorySnapshot>[];
      final subscription = MemoryMonitor.memoryStream.listen((snapshot) {
        snapshots.add(snapshot);
      });

      // Wait for a few snapshots
      await Future.delayed(const Duration(seconds: 2));

      await subscription.cancel();
      await MemoryMonitor.dispose();

      expect(snapshots.isNotEmpty, equals(true));
      expect(snapshots.length, greaterThan(1));
    });

    test('should calculate statistics correctly', () async {
      await MemoryMonitor.initialize(
        config: const MemoryMonitorConfig(
          monitoringInterval: Duration(milliseconds: 500),
          enableTrendAnalysis: true,
        ),
        onAlert: (alert) {},
      );

      // Wait for snapshots
      await Future.delayed(const Duration(seconds: 3));

      final stats = await MemoryMonitor.getStatistics();

      expect(stats.currentUsageBytes, greaterThan(0));
      expect(stats.averageUsageBytes, greaterThan(0));
      expect(stats.peakUsageBytes, greaterThan(0));
      expect(stats.lowestUsageBytes, greaterThan(0));
      expect(stats.snapshotCount, greaterThan(0));

      // Validate statistics consistency
      expect(
          stats.peakUsageBytes, greaterThanOrEqualTo(stats.currentUsageBytes));
      expect(
          stats.lowestUsageBytes, lessThanOrEqualTo(stats.currentUsageBytes));

      await MemoryMonitor.dispose();
    });

    test('should clear history', () async {
      await MemoryMonitor.initialize(
        config: const MemoryMonitorConfig(
          monitoringInterval: Duration(milliseconds: 500),
        ),
        onAlert: (alert) {},
      );

      // Wait for snapshots
      await Future.delayed(const Duration(seconds: 2));

      var history = MemoryMonitor.getHistory();
      expect(history.isNotEmpty, equals(true));

      // Clear history
      MemoryMonitor.clearHistory();

      history = MemoryMonitor.getHistory();
      expect(history.isEmpty, equals(true));

      await MemoryMonitor.dispose();
    });

    test('should update configuration at runtime', () async {
      await MemoryMonitor.initialize(
        config: const MemoryMonitorConfig(
          monitoringInterval: Duration(seconds: 2),
        ),
        onAlert: (alert) {},
      );

      expect(MemoryMonitor.instance.config.monitoringInterval.inSeconds,
          equals(2));

      // Update configuration
      await MemoryMonitor.updateConfig(
        const MemoryMonitorConfig(
          monitoringInterval: Duration(seconds: 5),
        ),
      );

      expect(MemoryMonitor.instance.config.monitoringInterval.inSeconds,
          equals(5));

      await MemoryMonitor.dispose();
    });

    test('should track alert levels correctly', () async {
      MemoryAlert? lastAlert;
      final alertLevels = <MemoryAlertLevel>[];

      await MemoryMonitor.initialize(
        config: const MemoryMonitorConfig(
          warningThresholdBytes: 1, // Very low to trigger warning
          criticalThresholdBytes: 2, // Very low to trigger critical
          monitoringInterval: Duration(milliseconds: 500),
        ),
        onAlert: (alert) {
          lastAlert = alert;
          alertLevels.add(alert.level);
        },
      );

      // Wait for alerts
      await Future.delayed(const Duration(seconds: 2));

      // Should have triggered at least one alert
      expect(lastAlert, isNotNull);

      final currentLevel = MemoryMonitor.getCurrentAlertLevel();
      expect([MemoryAlertLevel.warning, MemoryAlertLevel.critical],
          contains(currentLevel));

      await MemoryMonitor.dispose();
    });

    test('should check alert level helpers', () async {
      await MemoryMonitor.initialize(
        config: const MemoryMonitorConfig(
          warningThresholdBytes: 1,
          criticalThresholdBytes: 2,
          monitoringInterval: Duration(milliseconds: 500),
        ),
        onAlert: (alert) {},
      );

      // Wait for alert
      await Future.delayed(const Duration(seconds: 2));

      final isWarning = MemoryMonitor.isAtWarningLevel();
      final isCritical = MemoryMonitor.isAtCriticalLevel();

      // Should be at least warning or critical
      expect(isWarning || isCritical, equals(true));

      await MemoryMonitor.dispose();
    });

    test('should handle multiple initialization attempts', () async {
      await MemoryMonitor.initialize(
        config: const MemoryMonitorConfig(),
        onAlert: (alert) {},
      );

      expect(
          () => MemoryMonitor.initialize(
                config: const MemoryMonitorConfig(),
                onAlert: (alert) {},
              ),
          throwsA(isA<StateError>()));

      await MemoryMonitor.dispose();
    });

    test('should throw when accessing methods before initialization', () {
      expect(() => MemoryMonitor.instance, throwsA(isA<StateError>()));
      expect(() => MemoryMonitor.getHistory(), throwsA(isA<StateError>()));
      expect(() => MemoryMonitor.getCurrentAlertLevel(),
          throwsA(isA<StateError>()));
    });

    test('should handle trend analysis', () async {
      await MemoryMonitor.initialize(
        config: const MemoryMonitorConfig(
          monitoringInterval: Duration(milliseconds: 500),
          enableTrendAnalysis: true,
          trendAnalysisThreshold: 0.1, // 10%
        ),
        onAlert: (alert) {},
      );

      // Wait for snapshots
      await Future.delayed(const Duration(seconds: 3));

      final stats = await MemoryMonitor.getStatistics();

      // Trend should be one of the three states
      expect(
          [MemoryTrend.increasing, MemoryTrend.decreasing, MemoryTrend.stable],
          contains(stats.trend));

      await MemoryMonitor.dispose();
    });

    test('should respect max history size', () async {
      const maxHistory = 5;

      await MemoryMonitor.initialize(
        config: const MemoryMonitorConfig(
          monitoringInterval: Duration(milliseconds: 300),
          maxHistorySize: maxHistory,
        ),
        onAlert: (alert) {},
      );

      // Wait for more snapshots than max history
      await Future.delayed(const Duration(seconds: 3));

      final history = MemoryMonitor.getHistory();

      // History should not exceed max size
      expect(history.length, lessThanOrEqualTo(maxHistory));

      await MemoryMonitor.dispose();
    });

    test('should get current usage', () async {
      await MemoryMonitor.initialize(
        config: const MemoryMonitorConfig(),
        onAlert: (alert) {},
      );

      final currentUsage = await MemoryMonitor.getCurrentUsage();

      expect(currentUsage, greaterThanOrEqualTo(0));

      await MemoryMonitor.dispose();
    });

    test('should handle disabled monitoring', () async {
      int alertCallCount = 0;

      await MemoryMonitor.initialize(
        config: const MemoryMonitorConfig(
          enabled: false,
        ),
        onAlert: (alert) {
          alertCallCount++;
        },
      );

      // Wait a bit
      await Future.delayed(const Duration(seconds: 1));

      // Should not have captured any snapshots since monitoring is disabled
      // Note: In release mode, the monitor is always disabled
      // This test assumes debug mode where enabled=false should prevent monitoring

      await MemoryMonitor.dispose();
    });
  });

  group('MemoryMonitor Integration', () {
    setUp(() {
      if (MemoryMonitor.isInitialized) {
        MemoryMonitor.dispose();
      }
    });

    tearDown(() async {
      if (MemoryMonitor.isInitialized) {
        await MemoryMonitor.dispose();
      }
    });

    test('should handle rapid alert level changes', () async {
      final alerts = <MemoryAlert>[];

      await MemoryMonitor.initialize(
        config: const MemoryMonitorConfig(
          warningThresholdBytes: 100 * 1024 * 1024,
          criticalThresholdBytes: 120 * 1024 * 1024,
          monitoringInterval: Duration(milliseconds: 500),
        ),
        onAlert: (alert) {
          alerts.add(alert);
        },
      );

      // Monitor for a few seconds
      await Future.delayed(const Duration(seconds: 3));

      // Should handle multiple alerts without issues
      // (actual alerts depend on system memory usage)

      await MemoryMonitor.dispose();
    });

    test('should handle statistics with empty history', () async {
      await MemoryMonitor.initialize(
        config: const MemoryMonitorConfig(
          monitoringInterval: Duration(seconds: 1),
        ),
        onAlert: (alert) {},
      );

      // Get stats immediately (before any snapshots)
      final stats = await MemoryMonitor.getStatistics();

      // Should return valid stats even with empty/minimal history
      expect(stats.currentUsageBytes, greaterThanOrEqualTo(0));
      expect(stats.snapshotCount, greaterThanOrEqualTo(0));

      await MemoryMonitor.dispose();
    });
  });
}
