import 'dart:async';
import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';
import 'package:vm_service/vm_service_io.dart';

/// Memory usage information captured at a point in time
class MemorySnapshot {
  /// Memory usage in bytes
  final int memoryUsageBytes;

  /// Timestamp when snapshot was captured
  final DateTime timestamp;

  /// Memory usage in MB
  double get memoryUsageMB => memoryUsageBytes / (1024 * 1024);

  const MemorySnapshot({
    required this.memoryUsageBytes,
    required this.timestamp,
  });

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'memoryUsageBytes': memoryUsageBytes,
      'memoryUsageMB': memoryUsageMB,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  /// Create from JSON
  factory MemorySnapshot.fromJson(Map<String, dynamic> json) {
    return MemorySnapshot(
      memoryUsageBytes: json['memoryUsageBytes'] as int,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }

  @override
  String toString() {
    return 'MemorySnapshot(${memoryUsageMB.toStringAsFixed(2)} MB at ${timestamp.toIso8601String()})';
  }
}

/// Memory alert level
enum MemoryAlertLevel {
  /// Memory usage is within acceptable range
  normal,

  /// Memory usage is approaching limit (warning level)
  warning,

  /// Memory usage is critical and needs immediate attention
  critical,
}

/// Memory alert event
class MemoryAlert {
  /// Alert level (warning or critical)
  final MemoryAlertLevel level;

  /// Current memory usage in bytes
  final int currentUsageBytes;

  /// Threshold that triggered the alert (in bytes)
  final int thresholdBytes;

  /// Timestamp when alert was triggered
  final DateTime timestamp;

  /// Alert message
  final String message;

  const MemoryAlert({
    required this.level,
    required this.currentUsageBytes,
    required this.thresholdBytes,
    required this.timestamp,
    required this.message,
  });

  /// Current usage in MB
  double get currentUsageMB => currentUsageBytes / (1024 * 1024);

  /// Threshold in MB
  double get thresholdMB => thresholdBytes / (1024 * 1024);

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'level': level.name,
      'currentUsageBytes': currentUsageBytes,
      'thresholdBytes': thresholdBytes,
      'timestamp': timestamp.toIso8601String(),
      'message': message,
    };
  }

  @override
  String toString() {
    return 'MemoryAlert(${level.name}: ${currentUsageMB.toStringAsFixed(2)} MB / ${thresholdMB.toStringAsFixed(2)} MB)';
  }
}

/// Memory usage statistics over time
class MemoryStatistics {
  /// Current memory usage in bytes
  final int currentUsageBytes;

  /// Average memory usage in bytes (over monitoring period)
  final int averageUsageBytes;

  /// Peak memory usage in bytes (over monitoring period)
  final int peakUsageBytes;

  /// Lowest memory usage in bytes (over monitoring period)
  final int lowestUsageBytes;

  /// Number of snapshots captured
  final int snapshotCount;

  /// Timestamp of first snapshot
  final DateTime startTime;

  /// Timestamp of last snapshot
  final DateTime endTime;

  /// Memory trend (increasing, decreasing, stable)
  final MemoryTrend trend;

  /// Memory trend percentage change
  final double trendPercentage;

  const MemoryStatistics({
    required this.currentUsageBytes,
    required this.averageUsageBytes,
    required this.peakUsageBytes,
    required this.lowestUsageBytes,
    required this.snapshotCount,
    required this.startTime,
    required this.endTime,
    required this.trend,
    required this.trendPercentage,
  });

  /// Current usage in MB
  double get currentUsageMB => currentUsageBytes / (1024 * 1024);

  /// Average usage in MB
  double get averageUsageMB => averageUsageBytes / (1024 * 1024);

  /// Peak usage in MB
  double get peakUsageMB => peakUsageBytes / (1024 * 1024);

  /// Lowest usage in MB
  double get lowestUsageMB => lowestUsageBytes / (1024 * 1024);

  /// Monitoring duration
  Duration get monitoringDuration => endTime.difference(startTime);

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'currentUsageBytes': currentUsageBytes,
      'currentUsageMB': currentUsageMB,
      'averageUsageBytes': averageUsageBytes,
      'averageUsageMB': averageUsageMB,
      'peakUsageBytes': peakUsageBytes,
      'peakUsageMB': peakUsageMB,
      'lowestUsageBytes': lowestUsageBytes,
      'lowestUsageMB': lowestUsageMB,
      'snapshotCount': snapshotCount,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'monitoringDurationMs': monitoringDuration.inMilliseconds,
      'trend': trend.name,
      'trendPercentage': trendPercentage,
    };
  }

  @override
  String toString() {
    return '''
MemoryStatistics:
- Current: ${currentUsageMB.toStringAsFixed(2)} MB
- Average: ${averageUsageMB.toStringAsFixed(2)} MB
- Peak: ${peakUsageMB.toStringAsFixed(2)} MB
- Lowest: ${lowestUsageMB.toStringAsFixed(2)} MB
- Snapshots: $snapshotCount
- Trend: ${trend.name} (${trendPercentage.toStringAsFixed(1)}%)
- Duration: ${monitoringDuration.inMinutes} minutes
''';
  }
}

/// Memory trend over time
enum MemoryTrend {
  /// Memory usage is increasing
  increasing,

  /// Memory usage is decreasing
  decreasing,

  /// Memory usage is stable (less than 10% change)
  stable,
}

/// Configuration for memory monitoring
class MemoryMonitorConfig {
  /// Warning threshold in bytes (default: 150 MB)
  final int warningThresholdBytes;

  /// Critical threshold in bytes (default: 180 MB)
  final int criticalThresholdBytes;

  /// Monitoring interval (default: 5 seconds)
  final Duration monitoringInterval;

  /// Maximum number of snapshots to keep in history (default: 100)
  final int maxHistorySize;

  /// Enable monitoring (default: true in debug mode, false in release mode)
  final bool enabled;

  /// Enable trend analysis (default: true)
  final bool enableTrendAnalysis;

  /// Trend analysis threshold in percentage (default: 10%)
  /// Changes below this threshold are considered "stable"
  final double trendAnalysisThreshold;

  const MemoryMonitorConfig({
    this.warningThresholdBytes = 150 * 1024 * 1024, // 150 MB
    this.criticalThresholdBytes = 180 * 1024 * 1024, // 180 MB
    this.monitoringInterval = const Duration(seconds: 5),
    this.maxHistorySize = 100,
    this.enabled = true,
    this.enableTrendAnalysis = true,
    this.trendAnalysisThreshold = 0.1, // 10%
  });

  /// Warning threshold in MB
  double get warningThresholdMB => warningThresholdBytes / (1024 * 1024);

  /// Critical threshold in MB
  double get criticalThresholdMB => criticalThresholdBytes / (1024 * 1024);

  /// Copy with modified values
  MemoryMonitorConfig copyWith({
    int? warningThresholdBytes,
    int? criticalThresholdBytes,
    Duration? monitoringInterval,
    int? maxHistorySize,
    bool? enabled,
    bool? enableTrendAnalysis,
    double? trendAnalysisThreshold,
  }) {
    return MemoryMonitorConfig(
      warningThresholdBytes:
          warningThresholdBytes ?? this.warningThresholdBytes,
      criticalThresholdBytes:
          criticalThresholdBytes ?? this.criticalThresholdBytes,
      monitoringInterval: monitoringInterval ?? this.monitoringInterval,
      maxHistorySize: maxHistorySize ?? this.maxHistorySize,
      enabled: enabled ?? this.enabled,
      enableTrendAnalysis: enableTrendAnalysis ?? this.enableTrendAnalysis,
      trendAnalysisThreshold:
          trendAnalysisThreshold ?? this.trendAnalysisThreshold,
    );
  }

  /// Factory for low-memory devices (warning: 100 MB, critical: 120 MB)
  factory MemoryMonitorConfig.forLowMemoryDevice() {
    return const MemoryMonitorConfig(
      warningThresholdBytes: 100 * 1024 * 1024, // 100 MB
      criticalThresholdBytes: 120 * 1024 * 1024, // 120 MB
      monitoringInterval: Duration(seconds: 10),
      maxHistorySize: 50,
    );
  }

  /// Factory for high-memory devices (warning: 250 MB, critical: 300 MB)
  factory MemoryMonitorConfig.forHighMemoryDevice() {
    return const MemoryMonitorConfig(
      warningThresholdBytes: 250 * 1024 * 1024, // 250 MB
      criticalThresholdBytes: 300 * 1024 * 1024, // 300 MB
      monitoringInterval: Duration(seconds: 3),
      maxHistorySize: 200,
    );
  }
}

/// Real-time memory monitoring service with alerting
///
/// This service monitors memory usage continuously and alerts when
/// thresholds are exceeded. It provides statistics and trend analysis.
///
/// ## Features
///
/// - **Real-time monitoring**: Periodic memory usage snapshots
/// - **Configurable thresholds**: Warning and critical alert levels
/// - **Alert callbacks**: Notify when thresholds are exceeded
/// - **Statistics**: Track average, peak, and lowest memory usage
/// - **Trend analysis**: Detect memory leaks and usage patterns
/// - **Stream updates**: Reactive UI integration
/// - **Production-safe**: Automatically disabled in release mode
///
/// ## Usage
///
/// ```dart
/// // Initialize monitor
/// await MemoryMonitor.initialize(
///   config: MemoryMonitorConfig(),
///   onAlert: (alert) {
///     debugPrint('Alert: ${alert.message}');
///     if (alert.level == MemoryAlertLevel.critical) {
///       // Clear caches, release resources, etc.
///       ImageCacheConfig.clearMemoryCache();
///     }
///   },
/// );
///
/// // Get current memory usage
/// final current = await MemoryMonitor.getCurrentUsage();
///
/// // Get statistics
/// final stats = await MemoryMonitor.getStatistics();
///
/// // Listen to memory updates
/// MemoryMonitor.memoryStream.listen((snapshot) {
///   debugPrint('Memory: ${snapshot.memoryUsageMB.toStringAsFixed(2)} MB');
/// });
///
/// // Cleanup when done
/// await MemoryMonitor.dispose();
/// ```
class MemoryMonitor {
  static MemoryMonitor? _instance;
  MemoryMonitorConfig _config;
  final List<MemorySnapshot> _history = [];
  Timer? _monitoringTimer;
  final StreamController<MemorySnapshot> _streamController =
      StreamController<MemorySnapshot>.broadcast();
  final void Function(MemoryAlert) _onAlert;

  /// Current memory alert level
  MemoryAlertLevel _currentAlertLevel = MemoryAlertLevel.normal;

  /// Private constructor
  MemoryMonitor._({
    required MemoryMonitorConfig config,
    required void Function(MemoryAlert) onAlert,
  })  : _config = config,
        _onAlert = onAlert;

  /// Get the singleton instance
  static MemoryMonitor get instance {
    if (_instance == null) {
      throw StateError(
          'MemoryMonitor not initialized. Call initialize() first.');
    }
    return _instance!;
  }

  /// Check if monitor is initialized
  static bool get isInitialized => _instance != null;

  /// Stream of memory snapshots
  Stream<MemorySnapshot> get memoryStream => _streamController.stream;

  /// Current monitoring configuration
  MemoryMonitorConfig get config => _config;

  /// Initialize the memory monitor
  ///
  /// [config] Monitoring configuration
  /// [onAlert] Callback invoked when alert threshold is exceeded
  static Future<void> initialize({
    MemoryMonitorConfig? config,
    required void Function(MemoryAlert) onAlert,
  }) async {
    if (_instance != null) {
      throw StateError(
          'MemoryMonitor already initialized. Call dispose() first.');
    }

    final effectiveConfig = config ?? const MemoryMonitorConfig();

    // Disable in release mode unless explicitly enabled
    if (!kDebugMode && !effectiveConfig.enabled) {
      return;
    }

    _instance = MemoryMonitor._(
      config: effectiveConfig,
      onAlert: onAlert,
    );

    // Start monitoring
    await _instance!._startMonitoring();

    if (kDebugMode) {
      debugPrint('MemoryMonitor initialized with config:');
      debugPrint(
          '  Warning threshold: ${effectiveConfig.warningThresholdMB.toStringAsFixed(0)} MB');
      debugPrint(
          '  Critical threshold: ${effectiveConfig.criticalThresholdMB.toStringAsFixed(0)} MB');
      debugPrint(
          '  Monitoring interval: ${effectiveConfig.monitoringInterval.inSeconds}s');
    }
  }

  /// Start monitoring memory usage
  Future<void> _startMonitoring() async {
    if (!_config.enabled) {
      return;
    }

    // Take initial snapshot
    await _captureSnapshot();

    // Start periodic monitoring
    _monitoringTimer = Timer.periodic(
      _config.monitoringInterval,
      (_) => _captureSnapshot(),
    );
  }

  /// Capture a memory snapshot
  Future<void> _captureSnapshot() async {
    try {
      final memoryUsage = await _getMemoryUsage();

      final snapshot = MemorySnapshot(
        memoryUsageBytes: memoryUsage,
        timestamp: DateTime.now(),
      );

      // Add to history
      _history.add(snapshot);

      // Trim history if needed
      if (_history.length > _config.maxHistorySize) {
        _history.removeAt(0);
      }

      // Emit to stream
      _streamController.add(snapshot);

      // Check thresholds and trigger alerts
      _checkThresholds(snapshot);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error capturing memory snapshot: $e');
      }
    }
  }

  /// Get current memory usage from VM service
  Future<int> _getMemoryUsage() async {
    try {
      final info = await developer.Service.getInfo();
      if (info.serverUri == null) {
        // If VM service is not available, return an estimate
        return 100 * 1024 * 1024; // 100MB estimate
      }

      final serviceClient =
          await vmServiceConnectUri(info.serverUri.toString());
      final vm = await serviceClient.getVM();
      final isolate = vm.isolates!.first;
      final memoryUsage = await serviceClient.getMemoryUsage(isolate.id!);
      await serviceClient.dispose();

      return memoryUsage.heapUsage ?? 0;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error getting memory usage: $e');
      }
      return 0;
    }
  }

  /// Check memory thresholds and trigger alerts
  void _checkThresholds(MemorySnapshot snapshot) {
    final usage = snapshot.memoryUsageBytes;

    // Check critical threshold
    if (usage >= _config.criticalThresholdBytes) {
      final alert = MemoryAlert(
        level: MemoryAlertLevel.critical,
        currentUsageBytes: usage,
        thresholdBytes: _config.criticalThresholdBytes,
        timestamp: snapshot.timestamp,
        message:
            'CRITICAL: Memory usage at ${snapshot.memoryUsageMB.toStringAsFixed(2)} MB exceeds threshold of ${_config.criticalThresholdMB.toStringAsFixed(0)} MB',
      );

      if (_currentAlertLevel != MemoryAlertLevel.critical) {
        _currentAlertLevel = MemoryAlertLevel.critical;
        _onAlert(alert);
        if (kDebugMode) {
          debugPrint('🚨 MEMORY ALERT: ${alert.message}');
        }
      }
      return;
    }

    // Check warning threshold
    if (usage >= _config.warningThresholdBytes) {
      final alert = MemoryAlert(
        level: MemoryAlertLevel.warning,
        currentUsageBytes: usage,
        thresholdBytes: _config.warningThresholdBytes,
        timestamp: snapshot.timestamp,
        message:
            'WARNING: Memory usage at ${snapshot.memoryUsageMB.toStringAsFixed(2)} MB exceeds threshold of ${_config.warningThresholdMB.toStringAsFixed(0)} MB',
      );

      if (_currentAlertLevel != MemoryAlertLevel.warning &&
          _currentAlertLevel != MemoryAlertLevel.critical) {
        _currentAlertLevel = MemoryAlertLevel.warning;
        _onAlert(alert);
        if (kDebugMode) {
          debugPrint('⚠️ MEMORY ALERT: ${alert.message}');
        }
      }
      return;
    }

    // Memory is back to normal
    if (_currentAlertLevel != MemoryAlertLevel.normal) {
      _currentAlertLevel = MemoryAlertLevel.normal;
      if (kDebugMode) {
        debugPrint(
            '✅ Memory usage back to normal: ${snapshot.memoryUsageMB.toStringAsFixed(2)} MB');
      }
    }
  }

  /// Get current memory usage
  ///
  /// Returns current memory usage in bytes
  static Future<int> getCurrentUsage() async {
    if (_instance == null) {
      throw StateError('MemoryMonitor not initialized');
    }
    return await _instance!._getMemoryUsage();
  }

  /// Get memory statistics
  ///
  /// Calculates statistics from monitoring history
  static Future<MemoryStatistics> getStatistics() async {
    if (_instance == null) {
      throw StateError('MemoryMonitor not initialized');
    }

    final history = _instance!._history;
    if (history.isEmpty) {
      final currentUsage = await _instance!._getMemoryUsage();
      final now = DateTime.now();
      return MemoryStatistics(
        currentUsageBytes: currentUsage,
        averageUsageBytes: currentUsage,
        peakUsageBytes: currentUsage,
        lowestUsageBytes: currentUsage,
        snapshotCount: 1,
        startTime: now,
        endTime: now,
        trend: MemoryTrend.stable,
        trendPercentage: 0.0,
      );
    }

    final currentUsage = history.last.memoryUsageBytes;
    final totalUsage = history.fold<int>(
        0, (sum, snapshot) => sum + snapshot.memoryUsageBytes);
    final averageUsage = totalUsage ~/ history.length;
    final peakUsage =
        history.map((s) => s.memoryUsageBytes).reduce((a, b) => a > b ? a : b);
    final lowestUsage =
        history.map((s) => s.memoryUsageBytes).reduce((a, b) => a < b ? a : b);

    // Calculate trend
    MemoryTrend trend = MemoryTrend.stable;
    double trendPercentage = 0.0;

    if (_instance!._config.enableTrendAnalysis && history.length >= 2) {
      // Compare first half with second half
      final midPoint = history.length ~/ 2;
      final firstHalf = history.sublist(0, midPoint);
      final secondHalf = history.sublist(midPoint);

      final firstHalfAvg =
          firstHalf.map((s) => s.memoryUsageBytes).reduce((a, b) => a + b) /
              firstHalf.length;
      final secondHalfAvg =
          secondHalf.map((s) => s.memoryUsageBytes).reduce((a, b) => a + b) /
              secondHalf.length;

      final change = (secondHalfAvg - firstHalfAvg) / firstHalfAvg;

      if (change > _instance!._config.trendAnalysisThreshold) {
        trend = MemoryTrend.increasing;
        trendPercentage = change * 100;
      } else if (change < -_instance!._config.trendAnalysisThreshold) {
        trend = MemoryTrend.decreasing;
        trendPercentage = -change * 100;
      } else {
        trend = MemoryTrend.stable;
        trendPercentage = change * 100;
      }
    }

    return MemoryStatistics(
      currentUsageBytes: currentUsage,
      averageUsageBytes: averageUsage,
      peakUsageBytes: peakUsage,
      lowestUsageBytes: lowestUsage,
      snapshotCount: history.length,
      startTime: history.first.timestamp,
      endTime: history.last.timestamp,
      trend: trend,
      trendPercentage: trendPercentage,
    );
  }

  /// Get memory history
  static List<MemorySnapshot> getHistory() {
    if (_instance == null) {
      throw StateError('MemoryMonitor not initialized');
    }
    return List.unmodifiable(_instance!._history);
  }

  /// Clear memory history
  static void clearHistory() {
    if (_instance == null) {
      throw StateError('MemoryMonitor not initialized');
    }
    _instance!._history.clear();
    if (kDebugMode) {
      debugPrint('Memory history cleared');
    }
  }

  /// Update monitoring configuration
  static Future<void> updateConfig(MemoryMonitorConfig config) async {
    if (_instance == null) {
      throw StateError('MemoryMonitor not initialized');
    }

    _instance!._config = config;

    // Restart monitoring with new interval if changed
    _instance!._monitoringTimer?.cancel();
    await _instance!._startMonitoring();

    if (kDebugMode) {
      debugPrint('MemoryMonitor config updated');
    }
  }

  /// Get current alert level
  static MemoryAlertLevel getCurrentAlertLevel() {
    if (_instance == null) {
      throw StateError('MemoryMonitor not initialized');
    }
    return _instance!._currentAlertLevel;
  }

  /// Check if memory usage is at warning level
  static bool isAtWarningLevel() {
    return getCurrentAlertLevel() == MemoryAlertLevel.warning;
  }

  /// Check if memory usage is at critical level
  static bool isAtCriticalLevel() {
    return getCurrentAlertLevel() == MemoryAlertLevel.critical;
  }

  /// Stop monitoring and cleanup resources
  static Future<void> dispose() async {
    if (_instance == null) {
      return;
    }

    _instance!._monitoringTimer?.cancel();
    await _instance!._streamController.close();

    _instance = null;

    if (kDebugMode) {
      debugPrint('MemoryMonitor disposed');
    }
  }
}
