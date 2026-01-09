import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';

/// Detailed scroll performance metrics
class ScrollPerformanceDetails {
  /// Scroll duration in milliseconds
  final int scrollDurationMs;

  /// Total pixels scrolled
  final double pixelsScrolled;

  /// Average scroll velocity in pixels/second
  final double averageVelocity;

  /// Peak scroll velocity in pixels/second
  final double peakVelocity;

  /// Number of frames during scroll
  final int totalFrames;

  /// Number of janky frames (>16ms)
  final int jankyFrames;

  /// Average FPS during scroll
  final double averageFPS;

  /// Percentage of janky frames
  final double jankyFramePercentage;

  /// Timestamp when metrics were captured
  final DateTime timestamp;

  const ScrollPerformanceDetails({
    required this.scrollDurationMs,
    required this.pixelsScrolled,
    required this.averageVelocity,
    required this.peakVelocity,
    required this.totalFrames,
    required this.jankyFrames,
    required this.averageFPS,
    required this.jankyFramePercentage,
    required this.timestamp,
  });

  /// Convert metrics to JSON
  Map<String, dynamic> toJson() {
    return {
      'scrollDurationMs': scrollDurationMs,
      'pixelsScrolled': pixelsScrolled,
      'averageVelocity': averageVelocity,
      'peakVelocity': peakVelocity,
      'totalFrames': totalFrames,
      'jankyFrames': jankyFrames,
      'averageFPS': averageFPS,
      'jankyFramePercentage': jankyFramePercentage,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  /// Format metrics for display
  String format() {
    return '''
Scroll Performance:
- Duration: ${scrollDurationMs}ms
- Distance: ${pixelsScrolled.toStringAsFixed(0)}px
- Avg Velocity: ${averageVelocity.toStringAsFixed(0)}px/s
- Peak Velocity: ${peakVelocity.toStringAsFixed(0)}px/s
- Avg FPS: ${averageFPS.toStringAsFixed(1)}
- Janky Frames: ${jankyFramePercentage.toStringAsFixed(1)}%
''';
  }

  @override
  String toString() => format();
}

/// A utility class for tracking scroll performance
class ScrollPerformanceTracker {
  /// Timer for scroll tracking
  Timer? _scrollTimer;

  /// Frame tracker
  final _FrameTracker _frameTracker = _FrameTracker();

  /// Scroll position tracking
  double _startScrollPosition = 0;
  double _endScrollPosition = 0;
  double _peakVelocity = 0;

  /// Scroll start time
  DateTime? _scrollStartTime;

  /// Last scroll notification time
  DateTime? _lastScrollTime;

  /// Last scroll position
  double? _lastScrollPosition;

  /// Whether currently tracking a scroll
  bool _isTracking = false;

  /// Minimum scroll duration to track (ms)
  final int minScrollDurationMs;

  /// Maximum idle time before considering scroll ended (ms)
  final int maxIdleTimeMs;

  /// Callback when scroll performance is captured
  final Function(ScrollPerformanceDetails)? onScrollComplete;

  ScrollPerformanceTracker({
    this.minScrollDurationMs = 500,
    this.maxIdleTimeMs = 100,
    this.onScrollComplete,
  });

  /// Handle scroll notification
  void handleScrollNotification(ScrollNotification notification) {
    if (!kDebugMode) return;

    if (notification is ScrollStartNotification) {
      _onScrollStart(notification.metrics);
    } else if (notification is ScrollUpdateNotification) {
      _onScrollUpdate(notification.metrics);
    } else if (notification is ScrollEndNotification) {
      _onScrollEnd();
    }
  }

  /// Called when scrolling starts
  void _onScrollStart(ScrollMetrics metrics) {
    if (_isTracking) return;

    _isTracking = true;
    _scrollStartTime = DateTime.now();
    _startScrollPosition = metrics.pixels;
    _lastScrollPosition = metrics.pixels;
    _lastScrollTime = _scrollStartTime;
    _peakVelocity = 0;

    _frameTracker.start();

    // Start idle timer
    _startIdleTimer();
  }

  /// Called when scroll updates
  void _onScrollUpdate(ScrollMetrics metrics) {
    if (!_isTracking) return;

    final now = DateTime.now();
    final timeDelta = now.difference(_lastScrollTime!).inMilliseconds;
    final positionDelta = (metrics.pixels - _lastScrollPosition!).abs();

    // Calculate instantaneous velocity
    if (timeDelta > 0) {
      final velocity = (positionDelta / timeDelta) * 1000; // px/s
      if (velocity > _peakVelocity) {
        _peakVelocity = velocity;
      }
    }

    _lastScrollPosition = metrics.pixels;
    _lastScrollTime = now;
    _endScrollPosition = metrics.pixels;

    // Reset idle timer
    _scrollTimer?.cancel();
    _startIdleTimer();
  }

  /// Start the idle timer
  void _startIdleTimer() {
    _scrollTimer?.cancel();
    _scrollTimer = Timer(Duration(milliseconds: maxIdleTimeMs), () {
      _onScrollEnd();
    });
  }

  /// Called when scrolling ends
  void _onScrollEnd() {
    if (!_isTracking) return;

    _scrollTimer?.cancel();
    _frameTracker.stop();

    final scrollEndTime = DateTime.now();
    final scrollDuration = scrollEndTime.difference(_scrollStartTime!);

    // Only report if scroll duration exceeds minimum
    if (scrollDuration.inMilliseconds >= minScrollDurationMs) {
      final pixelsScrolled = (_endScrollPosition - _startScrollPosition).abs();
      final avgVelocity = pixelsScrolled / (scrollDuration.inMilliseconds / 1000);

      final frameMetrics = _frameTracker.metrics;

      final details = ScrollPerformanceDetails(
        scrollDurationMs: scrollDuration.inMilliseconds,
        pixelsScrolled: pixelsScrolled,
        averageVelocity: avgVelocity,
        peakVelocity: _peakVelocity,
        totalFrames: frameMetrics.totalFrames,
        jankyFrames: frameMetrics.jankyFrames,
        averageFPS: frameMetrics.averageFPS,
        jankyFramePercentage: frameMetrics.jankyFramePercentage,
        timestamp: DateTime.now(),
      );

      if (onScrollComplete != null) {
        onScrollComplete!(details);
      }

      if (kDebugMode) {
        debugPrint('Scroll Performance: ${details.format()}');
      }
    }

    _reset();
  }

  /// Reset tracking state
  void _reset() {
    _isTracking = false;
    _scrollStartTime = null;
    _lastScrollTime = null;
    _lastScrollPosition = null;
    _startScrollPosition = 0;
    _endScrollPosition = 0;
    _peakVelocity = 0;
    _scrollTimer?.cancel();
    _frameTracker.reset();
  }

  /// Dispose the tracker
  void dispose() {
    _scrollTimer?.cancel();
    _frameTracker.dispose();
  }
}

/// Frame tracking utility
class _FrameTracker {
  final List<Duration> _frameTimes = [];
  int _totalFrames = 0;
  int _jankyFrames = 0;
  DateTime? _lastFrameTime;
  bool _isTracking = false;

  void start() {
    _frameTimes.clear();
    _totalFrames = 0;
    _jankyFrames = 0;
    _lastFrameTime = DateTime.now();
    _isTracking = true;

    SchedulerBinding.instance.addPersistentFrameCallback(_onFrame);
  }

  void _onFrame(Duration timestamp) {
    if (!_isTracking) return;

    final now = DateTime.now();
    if (_lastFrameTime != null) {
      final frameTime = now.difference(_lastFrameTime!);
      _frameTimes.add(frameTime);

      if (frameTime.inMilliseconds > 16) {
        _jankyFrames++;
      }
    }

    _lastFrameTime = now;
    _totalFrames++;
  }

  void stop() {
    _isTracking = false;
    SchedulerBinding.instance.removePersistentFrameCallback(_onFrame);
  }

  void reset() {
    _frameTimes.clear();
    _totalFrames = 0;
    _jankyFrames = 0;
    _lastFrameTime = null;
  }

  void dispose() {
    stop();
  }

  _FrameMetrics get metrics {
    final avgFrameTime = _frameTimes.isNotEmpty
        ? _frameTimes
            .map((d) => d.inMicroseconds)
            .reduce((a, b) => a + b) / _frameTimes.length
        : 16667;

    final avgFPS = avgFrameTime > 0 ? 1000000 / avgFrameTime : 60.0;
    final jankyPercentage = _totalFrames > 0 ? (_jankyFrames / _totalFrames * 100) : 0.0;

    return _FrameMetrics(
      totalFrames: _totalFrames,
      jankyFrames: _jankyFrames,
      averageFPS: avgFPS,
      jankyFramePercentage: jankyPercentage,
    );
  }
}

/// Frame metrics
class _FrameMetrics {
  final int totalFrames;
  final int jankyFrames;
  final double averageFPS;
  final double jankyFramePercentage;

  _FrameMetrics({
    required this.totalFrames,
    required this.jankyFrames,
    required this.averageFPS,
    required this.jankyFramePercentage,
  });
}

/// A widget that tracks scroll performance
class ScrollPerformanceTrackerWidget extends StatefulWidget {
  final Widget child;
  final Function(ScrollPerformanceDetails)? onScrollComplete;
  final int minScrollDurationMs;
  final int maxIdleTimeMs;
  final bool enabled;

  const ScrollPerformanceTrackerWidget({
    super.key,
    required this.child,
    this.onScrollComplete,
    this.minScrollDurationMs = 500,
    this.maxIdleTimeMs = 100,
    this.enabled = kDebugMode,
  });

  @override
  State<ScrollPerformanceTrackerWidget> createState() =>
      _ScrollPerformanceTrackerWidgetState();
}

class _ScrollPerformanceTrackerWidgetState
    extends State<ScrollPerformanceTrackerWidget> {
  late ScrollPerformanceTracker _tracker;

  @override
  void initState() {
    super.initState();
    _tracker = ScrollPerformanceTracker(
      minScrollDurationMs: widget.minScrollDurationMs,
      maxIdleTimeMs: widget.maxIdleTimeMs,
      onScrollComplete: widget.onScrollComplete,
    );
  }

  @override
  void dispose() {
    _tracker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled) {
      return widget.child;
    }

    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        _tracker.handleScrollNotification(notification);
        return false;
      },
      child: widget.child,
    );
  }
}
