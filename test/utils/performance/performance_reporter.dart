import 'dart:collection';

/// Reports and tracks performance metrics during testing.
///
/// Usage:
/// ```dart
/// final reporter = PerformanceReporter();
/// reporter.startTimer('database_query');
/// // ... perform operation
/// reporter.stopTimer('database_query');
/// reporter.printReport();
/// ```
class PerformanceReporter {
  final List<PerformanceMetric> _metrics = [];
  final Map<String, Stopwatch> _activeTimers = {};
  final String? name;

  PerformanceReporter({this.name});

  /// Record a metric with a name and value
  void recordMetric(String metricName, double value, {String? unit}) {
    _metrics.add(PerformanceMetric(
      name: metricName,
      value: value,
      unit: unit,
      timestamp: DateTime.now(),
    ));
  }

  /// Record a duration metric
  void recordDuration(String metricName, Duration duration) {
    recordMetric(metricName, duration.inMicroseconds.toDouble(), unit: 'μs');
  }

  /// Start a named timer
  void startTimer(String timerName) {
    _activeTimers[timerName] = Stopwatch()..start();
  }

  /// Stop a named timer and record the duration
  Duration? stopTimer(String timerName) {
    final timer = _activeTimers.remove(timerName);
    if (timer != null) {
      timer.stop();
      recordDuration(timerName, timer.elapsed);
      return timer.elapsed;
    }
    return null;
  }

  /// Measure execution time of an async function
  Future<T> measureAsync<T>(String metricName, Future<T> Function() fn) async {
    final stopwatch = Stopwatch()..start();
    try {
      return await fn();
    } finally {
      stopwatch.stop();
      recordDuration(metricName, stopwatch.elapsed);
    }
  }

  /// Measure execution time of a sync function
  T measureSync<T>(String metricName, T Function() fn) {
    final stopwatch = Stopwatch()..start();
    try {
      return fn();
    } finally {
      stopwatch.stop();
      recordDuration(metricName, stopwatch.elapsed);
    }
  }

  /// Print a formatted report of all metrics
  void printReport() {
    final title =
        name != null ? 'PERFORMANCE REPORT: $name' : 'PERFORMANCE REPORT';

    // Using stderr to avoid lint warnings in tests
    // ignore: avoid_print
    print('');
    // ignore: avoid_print
    print('═' * 60);
    // ignore: avoid_print
    print('  $title');
    // ignore: avoid_print
    print('═' * 60);

    if (_metrics.isEmpty) {
      // ignore: avoid_print
      print('  No metrics recorded.');
      // ignore: avoid_print
      print('═' * 60);
      return;
    }

    // Group metrics by name
    final grouped = <String, List<double>>{};
    for (final metric in _metrics) {
      grouped.putIfAbsent(metric.name, () => []).add(metric.value);
    }

    for (final entry in grouped.entries) {
      final values = entry.value;
      final avg = values.reduce((a, b) => a + b) / values.length;
      final min = values.reduce((a, b) => a < b ? a : b);
      final max = values.reduce((a, b) => a > b ? a : b);
      final unit = _metrics.firstWhere((m) => m.name == entry.key).unit ?? '';

      // ignore: avoid_print
      print('');
      // ignore: avoid_print
      print('  📊 ${entry.key}');
      // ignore: avoid_print
      print('     Count: ${values.length}');
      // ignore: avoid_print
      print('     Avg:   ${avg.toStringAsFixed(2)} $unit');
      // ignore: avoid_print
      print('     Min:   ${min.toStringAsFixed(2)} $unit');
      // ignore: avoid_print
      print('     Max:   ${max.toStringAsFixed(2)} $unit');
    }

    // ignore: avoid_print
    print('');
    // ignore: avoid_print
    print('═' * 60);
  }

  /// Get all recorded metrics (read-only)
  List<PerformanceMetric> get metrics => UnmodifiableListView(_metrics);

  /// Get metric statistics for a specific metric name
  PerformanceStats? getStats(String metricName) {
    final values = _metrics
        .where((m) => m.name == metricName)
        .map((m) => m.value)
        .toList();

    if (values.isEmpty) return null;

    final avg = values.reduce((a, b) => a + b) / values.length;
    final min = values.reduce((a, b) => a < b ? a : b);
    final max = values.reduce((a, b) => a > b ? a : b);

    return PerformanceStats(
      name: metricName,
      count: values.length,
      average: avg,
      min: min,
      max: max,
    );
  }

  /// Clear all recorded metrics and timers
  void clear() {
    _metrics.clear();
    _activeTimers.clear();
  }

  /// Export metrics as JSON-compatible list
  List<Map<String, dynamic>> toJson() {
    return _metrics.map((m) => m.toJson()).toList();
  }
}

/// Represents a single performance metric
class PerformanceMetric {
  final String name;
  final double value;
  final String? unit;
  final DateTime timestamp;

  PerformanceMetric({
    required this.name,
    required this.value,
    this.unit,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  Map<String, dynamic> toJson() => {
        'name': name,
        'value': value,
        'unit': unit,
        'timestamp': timestamp.toIso8601String(),
      };

  @override
  String toString() => '$name: $value ${unit ?? ''}';
}

/// Statistics for a metric
class PerformanceStats {
  final String name;
  final int count;
  final double average;
  final double min;
  final double max;

  PerformanceStats({
    required this.name,
    required this.count,
    required this.average,
    required this.min,
    required this.max,
  });
}
