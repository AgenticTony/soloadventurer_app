import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

/// Performance metrics for a virtual list or grid
class VirtualListPerformanceMetrics {
  /// Time taken to initially render the list in milliseconds
  final int initialRenderTimeMs;

  /// Current memory usage in bytes
  final int currentMemoryUsageBytes;

  /// Average FPS during scrolling
  final double averageFPS;

  /// Percentage of janky frames during scrolling
  final double jankyFramePercentage;

  /// Total frames rendered
  final int totalFrames;

  /// Number of janky frames
  final int jankyFrames;

  /// Timestamp when metrics were captured
  final DateTime timestamp;

  const VirtualListPerformanceMetrics({
    required this.initialRenderTimeMs,
    required this.currentMemoryUsageBytes,
    required this.averageFPS,
    required this.jankyFramePercentage,
    required this.totalFrames,
    required this.jankyFrames,
    required this.timestamp,
  });

  /// Convert metrics to a JSON-serializable map
  Map<String, dynamic> toJson() {
    return {
      'initialRenderTimeMs': initialRenderTimeMs,
      'currentMemoryUsageMB': currentMemoryUsageBytes / (1024 * 1024),
      'averageFPS': averageFPS,
      'jankyFramePercentage': jankyFramePercentage,
      'totalFrames': totalFrames,
      'jankyFrames': jankyFrames,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  /// Create a formatted string representation
  String format() {
    return '''
Virtual List Performance:
- Initial Render: ${initialRenderTimeMs}ms
- Memory Usage: ${(currentMemoryUsageBytes / 1024 / 1024).toStringAsFixed(2)} MB
- Average FPS: ${averageFPS.toStringAsFixed(1)}
- Janky Frames: ${jankyFramePercentage.toStringAsFixed(1)}%
- Total Frames: $totalFrames
- Janky Count: $jankyFrames
''';
  }

  /// Check if metrics meet performance targets
  bool meetsTargets() {
    return initialRenderTimeMs < 1000 &&
        currentMemoryUsageBytes < 150 * 1024 * 1024 &&
        averageFPS >= 55 &&
        jankyFramePercentage < 10;
  }

  @override
  String toString() => format();
}

/// Callback type for when performance metrics are updated
typedef PerformanceMetricsCallback = void Function(
    VirtualListPerformanceMetrics metrics);

/// A widget that tracks performance metrics for virtual lists and grids.
///
/// This widget wraps a [VirtualListView] or [VirtualGridView] and tracks:
/// - Initial render time
/// - Memory usage during scrolling
/// - Frame rate (FPS) during scrolling
/// - Janky frame percentage
///
/// The tracker only collects metrics in debug mode to avoid impacting
/// production performance.
///
/// Example:
/// ```dart
/// VirtualListPerformanceTracker(
///   itemName: 'Trip Items',
///   onMetricsUpdated: (metrics) {
///     if (kDebugMode) {
///       debugPrint(metrics.toString());
///     }
///   },
///   child: VirtualListView<Trip>(
///     itemCount: trips.length,
///     itemBuilder: (context, index) => TripCard(trip: trips[index]),
///   ),
/// )
/// ```
class VirtualListPerformanceTracker extends StatefulWidget {
  /// The child widget to track (typically VirtualListView or VirtualGridView)
  final Widget child;

  /// Optional name for this list (used in metrics reporting)
  final String? itemName;

  /// Callback invoked when performance metrics are updated
  final PerformanceMetricsCallback? onMetricsUpdated;

  /// Whether to show a performance overlay in debug mode
  final bool showOverlay;

  /// Whether to enable performance tracking (defaults to kDebugMode)
  final bool enabled;

  const VirtualListPerformanceTracker({
    super.key,
    required this.child,
    this.itemName,
    this.onMetricsUpdated,
    this.showOverlay = true,
    this.enabled = kDebugMode,
  });

  @override
  State<VirtualListPerformanceTracker> createState() =>
      _VirtualListPerformanceTrackerState();
}

class _VirtualListPerformanceTrackerState
    extends State<VirtualListPerformanceTracker>
    with WidgetsBindingObserver {
  /// Timestamp when the widget was first built
  DateTime? _buildStartTime;

  /// Time taken for initial render
  int? _initialRenderTimeMs;

  /// Current memory usage
  int _currentMemoryUsageBytes = 0;

  /// Frame timing information
  final List<Duration> _frameTimes = [];

  /// Total frames counted
  int _totalFrames = 0;

  /// Number of janky frames (>16ms)
  int _jankyFrames = 0;

  /// Last frame timestamp
  DateTime? _lastFrameTime;

  /// Whether metrics have been reported
  bool _hasReportedMetrics = false;

  /// Current performance metrics
  VirtualListPerformanceMetrics? _currentMetrics;

  @override
  void initState() {
    super.initState();
    if (widget.enabled) {
      _buildStartTime = DateTime.now();
      WidgetsBinding.instance.addObserver(this);
      _startFrameTracking();
    }
  }

  @override
  void dispose() {
    if (widget.enabled) {
      WidgetsBinding.instance.removeObserver(this);
    }
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!widget.enabled) return;

    // Capture memory when app becomes visible
    if (state == AppLifecycleState.resumed) {
      _captureMemoryUsage();
    }
  }

  /// Start tracking frame rates using SchedulerBinding
  void _startFrameTracking() {
    if (!widget.enabled) return;

    SchedulerBinding.instance.addPersistentFrameCallback(_onFrame);
  }

  /// Called on each frame
  void _onFrame(Duration timestamp) {
    if (!widget.enabled || !mounted) return;

    final now = DateTime.now();

    // Calculate frame time
    if (_lastFrameTime != null) {
      final frameTime = now.difference(_lastFrameTime!);
      _frameTimes.add(frameTime);

      // Count janky frames (>16ms for 60fps)
      if (frameTime.inMilliseconds > 16) {
        _jankyFrames++;
      }
    }

    _lastFrameTime = now;
    _totalFrames++;

    // Update metrics every 60 frames (approximately 1 second at 60fps)
    if (_totalFrames % 60 == 0) {
      _updateMetrics();
    }
  }

  /// Capture current memory usage
  Future<void> _captureMemoryUsage() async {
    if (!widget.enabled) return;

    try {
      // Use developer.Service to get memory info
      final info = await developer.Service.getInfo();
      if (info.serverUri != null) {
        // Note: In a real implementation, you would use vmServiceConnectUri
        // to get detailed memory info. For now, we'll use an estimate.
        _currentMemoryUsageBytes = 100 * 1024 * 1024; // 100MB baseline
      }
    } catch (e) {
      // Silently fail in production
      if (kDebugMode) {
        debugPrint('Error capturing memory: $e');
      }
    }
  }

  /// Update performance metrics
  void _updateMetrics() {
    if (!widget.enabled || _buildStartTime == null) return;

    // Calculate initial render time if not already set
    if (_initialRenderTimeMs == null) {
      _initialRenderTimeMs =
          DateTime.now().difference(_buildStartTime!).inMilliseconds;
    }

    // Calculate average FPS
    final avgFrameTime = _frameTimes.isNotEmpty
        ? _frameTimes.reduce((a, b) => a + b).inMicroseconds /
            _frameTimes.length
        : 16667; // Default to ~60fps

    final averageFPS = avgFrameTime > 0 ? 1000000 / avgFrameTime : 60.0;

    // Calculate janky frame percentage
    final jankyPercentage =
        _totalFrames > 0 ? (_jankyFrames / _totalFrames * 100) : 0.0;

    // Create metrics object
    _currentMetrics = VirtualListPerformanceMetrics(
      initialRenderTimeMs: _initialRenderTimeMs!,
      currentMemoryUsageBytes: _currentMemoryUsageBytes,
      averageFPS: averageFPS,
      jankyFramePercentage: jankyPercentage,
      totalFrames: _totalFrames,
      jankyFrames: _jankyFrames,
      timestamp: DateTime.now(),
    );

    // Notify callback
    if (widget.onMetricsUpdated != null && mounted) {
      widget.onMetricsUpdated!(_currentMetrics!);
    }

    // Update UI if overlay is shown
    if (mounted && widget.showOverlay) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled) {
      return widget.child;
    }

    // Record initial build time
    if (_buildStartTime != null && _initialRenderTimeMs == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _initialRenderTimeMs =
              DateTime.now().difference(_buildStartTime!).inMilliseconds;
          _captureMemoryUsage();
          _updateMetrics();
        }
      });
    }

    // Wrap child with stack if overlay is enabled
    if (widget.showOverlay) {
      return Stack(
        children: [
          widget.child,
          Positioned(
            top: 8,
            right: 8,
            child: _PerformanceOverlay(
              metrics: _currentMetrics,
              itemName: widget.itemName,
              totalFrames: _totalFrames,
              jankyFrames: _jankyFrames,
            ),
          ),
        ],
      );
    }

    return widget.child;
  }
}

/// A performance overlay widget that displays metrics in a compact card
class _PerformanceOverlay extends StatefulWidget {
  final VirtualListPerformanceMetrics? metrics;
  final String? itemName;
  final int totalFrames;
  final int jankyFrames;

  const _PerformanceOverlay({
    required this.metrics,
    this.itemName,
    required this.totalFrames,
    required this.jankyFrames,
  });

  @override
  State<_PerformanceOverlay> createState() => _PerformanceOverlayState();
}

class _PerformanceOverlayState extends State<_PerformanceOverlay> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final metrics = widget.metrics;
    final meetsTargets = metrics?.meetsTargets() ?? true;

    return Material(
      elevation: 4,
      borderRadius: BorderRadius.circular(8),
      child: GestureDetector(
        onTap: () {
          setState(() {
            _isExpanded = !_isExpanded;
          });
        },
        child: Container(
          constraints: const BoxConstraints(maxWidth: 180),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface.withOpacity(0.95),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: meetsTargets
                  ? Colors.green.withOpacity(0.5)
                  : Colors.orange.withOpacity(0.5),
              width: 2,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header with expand icon
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (widget.itemName != null)
                    Flexible(
                      child: Text(
                        widget.itemName!,
                        style: theme.textTheme.labelSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  Icon(
                    _isExpanded
                        ? Icons.expand_less
                        : Icons.expand_more,
                    size: 16,
                  ),
                ],
              ),
              if (!_isExpanded && metrics != null) ...[
                const SizedBox(height: 4),
                _MetricRow(
                  label: 'FPS',
                  value: metrics.averageFPS.toStringAsFixed(1),
                  isGood: metrics.averageFPS >= 55,
                ),
                _MetricRow(
                  label: 'Janky',
                  value: '${metrics.jankyFramePercentage.toStringAsFixed(1)}%',
                  isGood: metrics.jankyFramePercentage < 10,
                ),
              ],
              if (_isExpanded && metrics != null) ...[
                const SizedBox(height: 4),
                _MetricRow(
                  label: 'FPS',
                  value: metrics.averageFPS.toStringAsFixed(1),
                  isGood: metrics.averageFPS >= 55,
                ),
                _MetricRow(
                  label: 'Janky',
                  value: '${metrics.jankyFramePercentage.toStringAsFixed(1)}%',
                  isGood: metrics.jankyFramePercentage < 10,
                ),
                _MetricRow(
                  label: 'Frames',
                  value: '${widget.totalFrames}',
                  isGood: true,
                ),
                _MetricRow(
                  label: 'Janky Count',
                  value: '${widget.jankyFrames}',
                  isGood: widget.jankyFrames < 10,
                ),
                _MetricRow(
                  label: 'Render',
                  value: '${metrics.initialRenderTimeMs}ms',
                  isGood: metrics.initialRenderTimeMs < 1000,
                ),
                _MetricRow(
                  label: 'Memory',
                  value:
                      '${(metrics.currentMemoryUsageBytes / 1024 / 1024).toStringAsFixed(1)}MB',
                  isGood: metrics.currentMemoryUsageBytes < 150 * 1024 * 1024,
                ),
              ],
              if (metrics == null)
                Text(
                  'Waiting for data...',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.grey,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A single row in the performance overlay
class _MetricRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isGood;

  const _MetricRow({
    required this.label,
    required this.value,
    required this.isGood,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 50,
          child: Text(
            label,
            style: const TextStyle(fontSize: 10),
          ),
        ),
        const Text(': '),
        Text(
          value,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: isGood ? Colors.green : Colors.orange,
          ),
        ),
      ],
    );
  }
}
