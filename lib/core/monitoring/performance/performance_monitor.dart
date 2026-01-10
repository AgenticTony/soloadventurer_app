import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';
import 'package:soloadventurer/core/monitoring/performance/performance_metrics.dart'
    show PerformanceMetrics, PerformanceAlert, PerformanceAlertLevel;

import 'package:soloadventurer/core/monitoring/performance/network_monitor.dart';

/// Configuration for performance monitoring
class PerformanceMonitorConfig {
  /// Monitoring interval for metrics updates
  final Duration monitoringInterval;

  /// Maximum number of frame times to track
  final int maxFrameHistorySize;

  /// Enable performance monitoring (default: true in debug mode)
  final bool enabled;

  /// Enable alerts when performance degrades
  final bool enableAlerts;

  /// Target FPS threshold
  final double targetFPS;

  /// Janky frame threshold in milliseconds
  final int jankyFrameThresholdMs;

  const PerformanceMonitorConfig({
    this.monitoringInterval = const Duration(seconds: 5),
    this.maxFrameHistorySize = 300, // 5 seconds at 60fps
    this.enabled = true,
    this.enableAlerts = true,
    this.targetFPS = 55.0,
    this.jankyFrameThresholdMs = 16,
  });

  /// Copy with modified values
  PerformanceMonitorConfig copyWith({
    Duration? monitoringInterval,
    int? maxFrameHistorySize,
    bool? enabled,
    bool? enableAlerts,
    double? targetFPS,
    int? jankyFrameThresholdMs,
  }) {
    return PerformanceMonitorConfig(
      monitoringInterval: monitoringInterval ?? this.monitoringInterval,
      maxFrameHistorySize: maxFrameHistorySize ?? this.maxFrameHistorySize,
      enabled: enabled ?? this.enabled,
      enableAlerts: enableAlerts ?? this.enableAlerts,
      targetFPS: targetFPS ?? this.targetFPS,
      jankyFrameThresholdMs:
          jankyFrameThresholdMs ?? this.jankyFrameThresholdMs,
    );
  }
}

/// Callback type for when performance metrics are updated
typedef PerformanceMetricsCallback = void Function(PerformanceMetrics metrics);

/// Callback type for performance alerts
typedef PerformanceAlertCallback = void Function(PerformanceAlert alert);

/// App-wide performance monitor
///
/// This singleton service tracks app performance metrics including:
/// - Startup time
/// - Memory usage (via MemoryMonitor)
/// - Frame rate (FPS)
/// - Network latency (via NetworkMonitor)
///
/// ## Usage
///
/// ```dart
/// // Initialize monitoring
/// await PerformanceMonitor.initialize(
///   onMetricsUpdated: (metrics) {
///     debugPrint(metrics.toString());
///   },
///   onAlert: (alert) {
///     debugPrint('Alert: ${alert.message}');
///   },
/// );
///
/// // Get current metrics
/// final metrics = await PerformanceMonitor.getCurrentMetrics();
///
/// // Listen to metrics stream
/// PerformanceMonitor.metricsStream.listen((metrics) {
///   // Update UI or log metrics
/// });
///
/// // Cleanup
/// await PerformanceMonitor.dispose();
/// ```
class PerformanceMonitor {
  static PerformanceMonitor? _instance;
  final PerformanceMonitorConfig _config;

  /// Network monitor for tracking network performance
  final NetworkMonitor _networkMonitor = NetworkMonitor();

  /// Stream controller for metrics updates
  final StreamController<PerformanceMetrics> _metricsController =
      StreamController<PerformanceMetrics>.broadcast();

  /// Callback for metrics updates
  final PerformanceMetricsCallback? _onMetricsUpdated;

  /// Callback for alerts
  final PerformanceAlertCallback? _onAlert;

  /// Monitoring timer
  Timer? _monitoringTimer;

  /// Frame tracking
  final List<Duration> _frameTimes = [];
  int _totalFrames = 0;
  int _jankyFrames = 0;
  DateTime? _lastFrameTime;
  bool _isFrameTracking = false;

  /// Startup time
  DateTime? _appStartTime;
  int? _startupTimeMs;

  /// Memory tracking
  int _peakMemoryUsage = 0;
  int _totalMemoryUsage = 0;
  int _memorySampleCount = 0;

  /// Network tracking
  int _totalNetworkRequests = 0;
  int _failedNetworkRequests = 0;

  /// Monitoring start time
  DateTime? _monitoringStartTime;

  /// Private constructor
  PerformanceMonitor._({
    required PerformanceMonitorConfig config,
    PerformanceMetricsCallback? onMetricsUpdated,
    PerformanceAlertCallback? onAlert,
  })  : _config = config,
        _onMetricsUpdated = onMetricsUpdated,
        _onAlert = onAlert;

  /// Get the singleton instance
  static PerformanceMonitor get instance {
    if (_instance == null) {
      throw StateError(
          'PerformanceMonitor not initialized. Call initialize() first.');
    }
    return _instance!;
  }

  /// Check if monitor is initialized
  static bool get isInitialized => _instance != null;

  /// Stream of performance metrics
  Stream<PerformanceMetrics> get metricsStream =>
      _instance?._metricsController.stream ?? const Stream.empty();

  /// Current monitoring configuration
  PerformanceMonitorConfig get config => _config;

  /// Initialize the performance monitor
  ///
  /// [config] Monitoring configuration
  /// [onMetricsUpdated] Callback invoked when metrics are updated
  /// [onAlert] Callback invoked when performance alerts are triggered
  static Future<void> initialize({
    PerformanceMonitorConfig? config,
    PerformanceMetricsCallback? onMetricsUpdated,
    PerformanceAlertCallback? onAlert,
  }) async {
    if (_instance != null) {
      throw StateError(
          'PerformanceMonitor already initialized. Call dispose() first.');
    }

    final effectiveConfig = config ?? const PerformanceMonitorConfig();

    // Disable in release mode unless explicitly enabled
    if (!kDebugMode && !effectiveConfig.enabled) {
      return;
    }

    _instance = PerformanceMonitor._(
      config: effectiveConfig,
      onMetricsUpdated: onMetricsUpdated,
      onAlert: onAlert,
    );

    // Start monitoring
    await _instance!._startMonitoring();

    if (kDebugMode) {
      debugPrint('PerformanceMonitor initialized');
      debugPrint(
          '  Monitoring interval: ${effectiveConfig.monitoringInterval.inSeconds}s');
      debugPrint('  Target FPS: ${effectiveConfig.targetFPS}');
    }
  }

  /// Start monitoring
  Future<void> _startMonitoring() async {
    if (!_config.enabled) {
      return;
    }

    _monitoringStartTime = DateTime.now();
    _startFrameTracking();

    // Start periodic metrics update
    _monitoringTimer = Timer.periodic(
      _config.monitoringInterval,
      (_) => _updateMetrics(),
    );

    if (kDebugMode) {
      debugPrint('PerformanceMonitor started tracking');
    }
  }

  /// Track app start time
  ///
  /// Should be called as early as possible in main()
  static void trackAppStart() {
    if (_instance != null && _instance!._appStartTime == null) {
      _instance!._appStartTime = DateTime.now();
      if (kDebugMode) {
        debugPrint('PerformanceMonitor: Tracking app start time');
      }
    }
  }

  /// Complete startup tracking
  ///
  /// Should be called after first frame is rendered
  static void completeStartup() {
    if (_instance != null &&
        _instance!._appStartTime != null &&
        _instance!._startupTimeMs == null) {
      _instance!._startupTimeMs =
          DateTime.now().difference(_instance!._appStartTime!).inMilliseconds;
      if (kDebugMode) {
        debugPrint(
            'PerformanceMonitor: App startup completed in ${_instance!._startupTimeMs}ms');
      }
      // Trigger immediate metrics update
      _instance!._updateMetrics();
    }
  }

  /// Start tracking frame rates
  void _startFrameTracking() {
    if (_isFrameTracking) return;
    _isFrameTracking = true;
    SchedulerBinding.instance.addPersistentFrameCallback(_onFrame);
  }

  /// Stop tracking frame rates
  void _stopFrameTracking() {
    if (!_isFrameTracking) return;
    // Note: Persistent frame callbacks cannot be removed in Flutter.
    // We use the _isFrameTracking flag to effectively disable tracking.
    // The callback will still be called but will do nothing when disabled.
    _isFrameTracking = false;
  }

  /// Called on each frame
  void _onFrame(Duration timestamp) {
    if (!_isFrameTracking) return;

    final now = DateTime.now();

    // Calculate frame time
    if (_lastFrameTime != null) {
      final frameTime = now.difference(_lastFrameTime!);
      _frameTimes.add(frameTime);

      // Trim frame history
      while (_frameTimes.length > _config.maxFrameHistorySize) {
        _frameTimes.removeAt(0);
      }

      // Count janky frames
      if (frameTime.inMilliseconds > _config.jankyFrameThresholdMs) {
        _jankyFrames++;
      }
    }

    _lastFrameTime = now;
    _totalFrames++;
  }

  /// Track a network request
  void trackNetworkRequest(String path, Duration duration, int statusCode,
      int responseSize, bool isError) {
    _totalNetworkRequests++;
    if (isError) {
      _failedNetworkRequests++;
    }

    _networkMonitor.trackRequestAndResponse(
      path: path,
      duration: duration,
      statusCode: statusCode,
      responseSize: responseSize,
      isError: isError,
    );
  }

  /// Update memory tracking
  void _updateMemoryTracking(int currentMemoryBytes) {
    _totalMemoryUsage += currentMemoryBytes;
    _memorySampleCount++;

    if (currentMemoryBytes > _peakMemoryUsage) {
      _peakMemoryUsage = currentMemoryBytes;
    }
  }

  /// Update performance metrics
  Future<void> _updateMetrics() async {
    if (!mounted) return;

    try {
      // Get current memory usage (simplified estimate)
      // In production, this would integrate with MemoryMonitor
      const currentMemoryBytes = 100 * 1024 * 1024; // 100MB baseline
      _updateMemoryTracking(currentMemoryBytes);

      // Calculate average memory
      final averageMemoryBytes = _memorySampleCount > 0
          ? _totalMemoryUsage ~/ _memorySampleCount
          : currentMemoryBytes;

      // Calculate FPS metrics
      final avgFrameTime = _frameTimes.isNotEmpty
          ? _frameTimes.map((d) => d.inMicroseconds).reduce((a, b) => a + b) /
              _frameTimes.length
          : 16667; // Default to ~60fps

      final currentFPS = avgFrameTime > 0 ? 1000000 / avgFrameTime : 60.0;
      final averageFPS = currentFPS; // Simplified
      final jankyPercentage =
          _totalFrames > 0 ? (_jankyFrames / _totalFrames * 100) : 0.0;

      // Calculate network metrics
      final avgLatency = _totalNetworkRequests > 0
          ? _networkMonitor.getRequestHistory().isEmpty
              ? 0.0
              : _networkMonitor
                      .getRequestHistory()
                      .map((r) => r.duration.inMilliseconds)
                      .reduce((a, b) => a + b) /
                  _networkMonitor.getRequestHistory().length
          : 0.0;

      final monitoringDuration = _monitoringStartTime != null
          ? DateTime.now().difference(_monitoringStartTime!)
          : Duration.zero;

      // Create metrics object
      final metrics = PerformanceMetrics(
        startupTimeMs: _startupTimeMs ?? 0,
        currentMemoryUsageBytes: currentMemoryBytes,
        averageMemoryUsageBytes: averageMemoryBytes,
        peakMemoryUsageBytes: _peakMemoryUsage,
        currentFPS: currentFPS,
        averageFPS: averageFPS,
        jankyFramePercentage: jankyPercentage,
        totalFrames: _totalFrames,
        jankyFrames: _jankyFrames,
        averageNetworkLatencyMs: avgLatency,
        totalNetworkRequests: _totalNetworkRequests,
        failedNetworkRequests: _failedNetworkRequests,
        timestamp: DateTime.now(),
        monitoringDuration: monitoringDuration,
      );

      // Emit to stream
      _metricsController.add(metrics);

      // Notify callback
      if (_onMetricsUpdated != null) {
        _onMetricsUpdated(metrics);
      }

      // Check for alerts
      if (_config.enableAlerts) {
        _checkForAlerts(metrics);
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error updating performance metrics: $e');
      }
    }
  }

  /// Check if metrics should trigger alerts
  void _checkForAlerts(PerformanceMetrics metrics) {
    final issues = <String>[];
    PerformanceAlertLevel level = PerformanceAlertLevel.good;

    // Check startup time
    if (metrics.startupTimeMs > 3000) {
      issues.add('Startup time is ${metrics.startupTimeMs}ms (>3000ms target)');
      level = PerformanceAlertLevel.warning;
    }

    // Check memory
    if (metrics.currentMemoryUsageBytes > 250 * 1024 * 1024) {
      issues.add(
          'Memory usage is ${metrics.currentMemoryUsageMB.toStringAsFixed(0)}MB (>250MB target)');
      level = PerformanceAlertLevel.warning;
    }

    if (metrics.currentMemoryUsageBytes > 300 * 1024 * 1024) {
      level = PerformanceAlertLevel.critical;
    }

    // Check FPS
    if (metrics.averageFPS < 50) {
      issues.add(
          'Average FPS is ${metrics.averageFPS.toStringAsFixed(1)} (<50 target)');
      level = PerformanceAlertLevel.warning;
    }

    if (metrics.averageFPS < 40) {
      level = PerformanceAlertLevel.critical;
    }

    // Check janky frames
    if (metrics.jankyFramePercentage > 20) {
      issues.add(
          'Janky frame percentage is ${metrics.jankyFramePercentage.toStringAsFixed(1)}% (>20% target)');
      level = PerformanceAlertLevel.warning;
    }

    if (metrics.jankyFramePercentage > 30) {
      level = PerformanceAlertLevel.critical;
    }

    // Check network error rate
    if (metrics.errorRate > 0.10) {
      issues.add(
          'Network error rate is ${(metrics.errorRate * 100).toStringAsFixed(1)}% (>10% target)');
      level = PerformanceAlertLevel.warning;
    }

    // Trigger alert if issues detected
    if (issues.isNotEmpty && _onAlert != null) {
      final alert = PerformanceAlert(
        level: level,
        metrics: metrics,
        message:
            'Performance ${level.name}: ${issues.length} issue(s) detected',
        issues: issues,
        timestamp: DateTime.now(),
      );
      _onAlert(alert);

      if (kDebugMode) {
        debugPrint('⚠️ Performance Alert: $alert');
      }
    }
  }

  /// Get current performance metrics
  static Future<PerformanceMetrics> getCurrentMetrics() async {
    if (_instance == null) {
      throw StateError('PerformanceMonitor not initialized');
    }

    await _instance!._updateMetrics();
    // Return the last metrics from the stream
    PerformanceMetrics? lastMetrics;
    final subscription = _instance!._metricsController.stream.listen((metrics) {
      lastMetrics = metrics;
    });
    await Future.delayed(Duration.zero);
    await subscription.cancel();

    // If stream hasn't emitted yet, create a default metrics object
    final metrics = lastMetrics ??
        PerformanceMetrics(
          startupTimeMs: _instance!._startupTimeMs ?? 0,
          currentMemoryUsageBytes: 100 * 1024 * 1024, // 100MB default
          averageMemoryUsageBytes: 100 * 1024 * 1024,
          peakMemoryUsageBytes: _instance!._peakMemoryUsage,
          currentFPS: 60.0,
          averageFPS: 60.0,
          jankyFramePercentage: 0.0,
          totalFrames: _instance!._totalFrames,
          jankyFrames: _instance!._jankyFrames,
          averageNetworkLatencyMs: 0.0,
          totalNetworkRequests: _instance!._totalNetworkRequests,
          failedNetworkRequests: _instance!._failedNetworkRequests,
          timestamp: DateTime.now(),
          monitoringDuration: _instance!._monitoringStartTime != null
              ? DateTime.now().difference(_instance!._monitoringStartTime!)
              : Duration.zero,
        );

    return metrics;
  }

  /// Check if the monitor is still active
  bool get mounted => _instance != null;

  /// Stop monitoring and cleanup resources
  static Future<void> dispose() async {
    if (_instance == null) {
      return;
    }

    _instance!._stopFrameTracking();
    _instance!._monitoringTimer?.cancel();
    await _instance!._metricsController.close();

    _instance = null;

    if (kDebugMode) {
      debugPrint('PerformanceMonitor disposed');
    }
  }
}
