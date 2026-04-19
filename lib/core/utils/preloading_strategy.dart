import 'package:flutter/material.dart';

/// Strategy for determining when to preload the next page
enum PreloadStrategy {
  /// Fixed distance from end (simple, predictable)
  /// Preloads when user is within [threshold] pixels from end
  fixedDistance,

  /// Velocity-based (adaptive)
  /// Preloads based on scroll velocity - faster scroll = earlier preload
  velocityBased,

  /// Predictive (smartest)
  /// Uses scroll velocity and direction to predict when user will reach end
  predictive,

  /// Aggressive (loads as early as possible)
  /// Preloads 2-3 pages ahead for smooth experience
  aggressive,

  /// Conservative (loads only when necessary)
  /// Preloads only when very close to end (100px threshold)
  conservative,
}

/// Configuration for preloading behavior
class PreloadConfig {
  /// The preloading strategy to use
  final PreloadStrategy strategy;

  /// Fixed distance threshold (for fixedDistance strategy)
  /// Default: 500px
  final double fixedThreshold;

  /// Velocity threshold for triggering preload (for velocity-based strategies)
  /// When scrolling faster than this (px/s), preload earlier
  /// Default: 1000 px/s
  final double velocityThreshold;

  /// Multiplier for velocity-based preload distance
  /// Higher = preload earlier when scrolling fast
  /// Default: 0.5 (preload threshold = baseThreshold + velocity * multiplier)
  final double velocityMultiplier;

  /// Number of pages to preload ahead (for aggressive strategy)
  /// Default: 2
  final int preloadAheadCount;

  /// Minimum time between preloads (ms)
  /// Prevents excessive preloading during rapid scrolling
  /// Default: 500ms
  final int minPreloadInterval;

  /// Whether to enable adaptive threshold adjustment
  /// If true, adjusts threshold based on page load times
  /// Default: true
  final bool enableAdaptiveThreshold;

  /// Adaptive threshold factor (0.0 - 2.0)
  /// Multiplier applied to threshold based on performance
  /// 1.0 = normal, < 1.0 = load earlier, > 1.0 = load later
  final double adaptiveFactor;

  const PreloadConfig({
    this.strategy = PreloadStrategy.predictive,
    this.fixedThreshold = 500.0,
    this.velocityThreshold = 1000.0,
    this.velocityMultiplier = 0.5,
    this.preloadAheadCount = 2,
    this.minPreloadInterval = 500,
    this.enableAdaptiveThreshold = true,
    this.adaptiveFactor = 1.0,
  });

  /// Default configuration for most use cases
  static const defaultConfig = PreloadConfig(
    strategy: PreloadStrategy.predictive,
  );

  /// Aggressive configuration for smooth scrolling on fast networks
  static const aggressiveConfig = PreloadConfig(
    strategy: PreloadStrategy.aggressive,
    fixedThreshold: 800.0,
    preloadAheadCount: 3,
    minPreloadInterval: 300,
  );

  /// Conservative configuration for slow networks or data limits
  static const conservativeConfig = PreloadConfig(
    strategy: PreloadStrategy.conservative,
    fixedThreshold: 200.0,
    preloadAheadCount: 1,
    minPreloadInterval: 1000,
  );

  /// Creates a copy with modified fields
  PreloadConfig copyWith({
    PreloadStrategy? strategy,
    double? fixedThreshold,
    double? velocityThreshold,
    double? velocityMultiplier,
    int? preloadAheadCount,
    int? minPreloadInterval,
    bool? enableAdaptiveThreshold,
    double? adaptiveFactor,
  }) {
    return PreloadConfig(
      strategy: strategy ?? this.strategy,
      fixedThreshold: fixedThreshold ?? this.fixedThreshold,
      velocityThreshold: velocityThreshold ?? this.velocityThreshold,
      velocityMultiplier: velocityMultiplier ?? this.velocityMultiplier,
      preloadAheadCount: preloadAheadCount ?? this.preloadAheadCount,
      minPreloadInterval: minPreloadInterval ?? this.minPreloadInterval,
      enableAdaptiveThreshold:
          enableAdaptiveThreshold ?? this.enableAdaptiveThreshold,
      adaptiveFactor: adaptiveFactor ?? this.adaptiveFactor,
    );
  }
}

/// Metrics for tracking preload performance
class PreloadMetrics {
  /// Number of successful preloads
  final int successfulPreloads;

  /// Number of failed preloads
  final int failedPreloads;

  /// Average page load time (ms)
  final double averageLoadTime;

  /// Total preloaded pages
  final int totalPreloadedPages;

  /// Cache hit rate (0.0 - 1.0)
  final double cacheHitRate;

  /// Last preload time
  final DateTime? lastPreloadTime;

  /// Whether preloading is performing well
  bool get isPerformingWell =>
      cacheHitRate > 0.7 && averageLoadTime < 1000 && failedPreloads == 0;

  const PreloadMetrics({
    this.successfulPreloads = 0,
    this.failedPreloads = 0,
    this.averageLoadTime = 0.0,
    this.totalPreloadedPages = 0,
    this.cacheHitRate = 0.0,
    this.lastPreloadTime,
  });

  /// Creates a copy with modified fields
  PreloadMetrics copyWith({
    int? successfulPreloads,
    int? failedPreloads,
    double? averageLoadTime,
    int? totalPreloadedPages,
    double? cacheHitRate,
    DateTime? lastPreloadTime,
  }) {
    return PreloadMetrics(
      successfulPreloads: successfulPreloads ?? this.successfulPreloads,
      failedPreloads: failedPreloads ?? this.failedPreloads,
      averageLoadTime: averageLoadTime ?? this.averageLoadTime,
      totalPreloadedPages: totalPreloadedPages ?? this.totalPreloadedPages,
      cacheHitRate: cacheHitRate ?? this.cacheHitRate,
      lastPreloadTime: lastPreloadTime ?? this.lastPreloadTime,
    );
  }

  @override
  String toString() {
    return 'PreloadMetrics('
        'successful: $successfulPreloads, '
        'failed: $failedPreloads, '
        'avgLoadTime: ${averageLoadTime.toStringAsFixed(0)}ms, '
        'cacheHitRate: ${(cacheHitRate * 100).toStringAsFixed(0)}%, '
        'performingWell: $isPerformingWell)';
  }
}

/// Intelligent preloading manager for pagination
class PreloadingManager {
  /// Configuration for preloading behavior
  final PreloadConfig config;

  /// Current preload metrics
  PreloadMetrics _metrics = const PreloadMetrics();

  /// Last preload timestamp
  DateTime? _lastPreloadTime;

  /// Scroll velocity tracking
  double _currentVelocity = 0.0;

  /// Velocity samples for smoothing
  final List<double> _velocitySamples = [];

  /// Maximum number of velocity samples to keep
  static const _maxVelocitySamples = 5;

  /// Page load time samples for adaptive threshold
  final List<int> _loadTimeSamples = [];

  /// Maximum number of load time samples to keep
  static const _maxLoadTimeSamples = 10;

  PreloadingManager({this.config = PreloadConfig.defaultConfig});

  /// Gets current preload metrics
  PreloadMetrics get metrics => _metrics;

  /// Updates the current scroll velocity
  void updateVelocity(double velocity) {
    _velocitySamples.add(velocity);
    if (_velocitySamples.length > _maxVelocitySamples) {
      _velocitySamples.removeAt(0);
    }

    // Calculate average velocity (smoothed)
    _currentVelocity =
        _velocitySamples.reduce((a, b) => a + b) / _velocitySamples.length;
  }

  /// Records a successful page load
  void recordSuccessfulLoad(int loadTimeMs) {
    _loadTimeSamples.add(loadTimeMs);
    if (_loadTimeSamples.length > _maxLoadTimeSamples) {
      _loadTimeSamples.removeAt(0);
    }

    final avgLoadTime = _loadTimeSamples.isEmpty
        ? 0.0
        : _loadTimeSamples.reduce((a, b) => a + b) / _loadTimeSamples.length;

    _metrics = _metrics.copyWith(
      successfulPreloads: _metrics.successfulPreloads + 1,
      totalPreloadedPages: _metrics.totalPreloadedPages + 1,
      averageLoadTime: avgLoadTime,
      lastPreloadTime: DateTime.now(),
    );
  }

  /// Records a failed page load
  void recordFailedLoad() {
    _metrics = _metrics.copyWith(
      failedPreloads: _metrics.failedPreloads + 1,
    );
  }

  /// Calculates the preload threshold based on strategy and current conditions
  double calculateThreshold() {
    double baseThreshold = config.fixedThreshold;

    switch (config.strategy) {
      case PreloadStrategy.fixedDistance:
        return baseThreshold;

      case PreloadStrategy.velocityBased:
        // Increase threshold when scrolling fast
        final velocityBonus = _currentVelocity > config.velocityThreshold
            ? _currentVelocity * config.velocityMultiplier
            : 0.0;
        return baseThreshold + velocityBonus;

      case PreloadStrategy.predictive:
        // Predict time to reach end
        // If scrolling fast, preload much earlier
        final velocityMultiplier = _currentVelocity / config.velocityThreshold;
        final predictiveBonus = _currentVelocity *
            config.velocityMultiplier *
            (1.0 + velocityMultiplier);
        return baseThreshold + predictiveBonus;

      case PreloadStrategy.aggressive:
        // Always preload early
        return baseThreshold * 1.5;

      case PreloadStrategy.conservative:
        // Only preload when very close
        return baseThreshold * 0.4;
    }
  }

  /// Calculates the adaptive threshold based on performance
  double calculateAdaptiveThreshold() {
    if (!config.enableAdaptiveThreshold) {
      return calculateThreshold();
    }

    final baseThreshold = calculateThreshold();

    // Adjust based on performance
    double factor = config.adaptiveFactor;

    if (_metrics.averageLoadTime > 2000) {
      // Slow loads - preload earlier
      factor = 0.7;
    } else if (_metrics.averageLoadTime < 500) {
      // Fast loads - can preload later
      factor = 1.3;
    }

    if (_metrics.failedPreloads > 2) {
      // Many failures - be conservative
      factor *= 0.8;
    }

    return baseThreshold * factor;
  }

  /// Checks if enough time has passed since last preload
  bool get canPreload {
    if (_lastPreloadTime == null) return true;

    final elapsed = DateTime.now().difference(_lastPreloadTime!).inMilliseconds;
    return elapsed >= config.minPreloadInterval;
  }

  /// Determines if preloading should be triggered
  bool shouldPreload(double maxScroll, double currentScroll) {
    final threshold = calculateAdaptiveThreshold();
    final distanceFromEnd = maxScroll - currentScroll;

    // Check if we're within threshold
    if (distanceFromEnd > threshold) return false;

    // Check minimum interval
    if (!canPreload) return false;

    return true;
  }

  /// Gets the number of pages to preload ahead
  int get preloadAheadCount {
    if (config.strategy == PreloadStrategy.aggressive) {
      return config.preloadAheadCount;
    }
    return 1;
  }

  /// Resets metrics (e.g., on refresh)
  void reset() {
    _metrics = const PreloadMetrics();
    _lastPreloadTime = null;
    _currentVelocity = 0.0;
    _velocitySamples.clear();
    _loadTimeSamples.clear();
  }

  /// Updates the last preload time
  void markPreloadTriggered() {
    _lastPreloadTime = DateTime.now();
  }
}

/// Extension for easier integration with ScrollController
extension PreloadingScrollController on ScrollController {
  /// Calculates current scroll velocity
  double get velocity {
    if (!hasClients) return 0.0;
    // activityVelocity doesn't exist in newer Flutter versions
    // Return 0 for now or calculate manually
    return 0.0;
  }

  /// Gets the distance from end of scroll
  double distanceFromEnd({double threshold = 0.0}) {
    if (!hasClients) return double.infinity;
    return position.maxScrollExtent - position.pixels - threshold;
  }
}

/// Widget that tracks scroll velocity and provides it to descendants
class ScrollVelocityTracker extends StatefulWidget {
  final Widget child;
  final VoidCallback? onVelocityChanged;

  const ScrollVelocityTracker({
    super.key,
    required this.child,
    this.onVelocityChanged,
  });

  @override
  State<ScrollVelocityTracker> createState() => _ScrollVelocityTrackerState();
}

class _ScrollVelocityTrackerState extends State<ScrollVelocityTracker> {
  double _lastPosition = 0.0;
  DateTime? _lastTimestamp;

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (notification is ScrollUpdateNotification) {
          final now = DateTime.now();
          final position = notification.metrics.pixels;

          if (_lastTimestamp != null) {
            final timeDiff =
                now.difference(_lastTimestamp!).inMicroseconds / 1000000;
            if (timeDiff > 0) {
              (position - _lastPosition) / timeDiff;
              widget.onVelocityChanged?.call();
            }
          }

          _lastPosition = position;
          _lastTimestamp = now;
        }
        return false;
      },
      child: widget.child,
    );
  }
}
