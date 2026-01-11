import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soloadventurer/core/widgets/virtual_list_performance_tracker.dart';

/// Provider for performance metrics collection
///
/// This provider manages the collection of performance metrics from
/// multiple virtual lists throughout the app.
final performanceMetricsProvider =
    StateProvider<List<VirtualListPerformanceMetrics>>((ref) => []);

/// Provider for global metrics state
final globalMetricsProvider =
    StateProvider<GlobalPerformanceMetrics?>((ref) => null);

/// Global performance metrics aggregated from all tracked lists
class GlobalPerformanceMetrics {
  /// Average FPS across all lists
  final double averageFPS;

  /// Average janky frame percentage across all lists
  final double averageJankyPercentage;

  /// Total memory usage across all lists
  final int totalMemoryUsage;

  /// Number of tracked lists
  final int trackedListCount;

  /// Timestamp when metrics were captured
  final DateTime timestamp;

  const GlobalPerformanceMetrics({
    required this.averageFPS,
    required this.averageJankyPercentage,
    required this.totalMemoryUsage,
    required this.trackedListCount,
    required this.timestamp,
  });

  /// Create global metrics from a list of individual metrics
  factory GlobalPerformanceMetrics.fromMetrics(
      List<VirtualListPerformanceMetrics> metrics) {
    if (metrics.isEmpty) {
      return GlobalPerformanceMetrics(
        averageFPS: 60.0,
        averageJankyPercentage: 0.0,
        totalMemoryUsage: 0,
        trackedListCount: 0,
        timestamp: DateTime.now(),
      );
    }

    final avgFPS = metrics.map((m) => m.averageFPS).reduce((a, b) => a + b) /
        metrics.length;
    final avgJanky =
        metrics.map((m) => m.jankyFramePercentage).reduce((a, b) => a + b) /
            metrics.length;
    final totalMemory = metrics.map((m) => m.currentMemoryUsageBytes).fold(
          0,
          (sum, bytes) => sum + bytes,
        );

    return GlobalPerformanceMetrics(
      averageFPS: avgFPS,
      averageJankyPercentage: avgJanky,
      totalMemoryUsage: totalMemory,
      trackedListCount: metrics.length,
      timestamp: DateTime.now(),
    );
  }

  /// Check if global metrics meet targets
  bool meetsTargets() {
    return averageFPS >= 55 &&
        averageJankyPercentage < 10 &&
        totalMemoryUsage < 200 * 1024 * 1024; // 200MB for all lists
  }

  @override
  String toString() {
    return '''
Global Performance Metrics:
- Average FPS: ${averageFPS.toStringAsFixed(1)}
- Average Janky: ${averageJankyPercentage.toStringAsFixed(1)}%
- Total Memory: ${(totalMemoryUsage / 1024 / 1024).toStringAsFixed(2)} MB
- Tracked Lists: $trackededListCount
- Timestamp: $timestamp
''';
  }
}

/// Performance dashboard screen for monitoring app performance in real-time
///
/// This screen displays performance metrics from all virtual lists in the app,
/// providing a centralized view of performance during development. It shows:
/// - Individual metrics for each tracked list
/// - Aggregated global metrics
/// - Performance target indicators
/// - Real-time updates
///
/// Only available in debug mode.
class PerformanceDashboardScreen extends ConsumerStatefulWidget {
  /// Creates a new [PerformanceDashboardScreen]
  const PerformanceDashboardScreen({super.key});

  /// Route name for navigation
  static const String routeName = '/performance/dashboard';

  @override
  ConsumerState<PerformanceDashboardScreen> createState() =>
      _PerformanceDashboardScreenState();
}

class _PerformanceDashboardScreenState
    extends ConsumerState<PerformanceDashboardScreen> {
  /// Whether to show individual metrics or just summary
  bool _showDetails = true;

  /// Whether metrics are being updated
  bool _isUpdating = false;

  @override
  void initState() {
    super.initState();
    _updateGlobalMetrics();
  }

  /// Update global metrics from collected individual metrics
  void _updateGlobalMetrics() {
    final metrics = ref.read(performanceMetricsProvider);
    if (metrics.isNotEmpty) {
      final global = GlobalPerformanceMetrics.fromMetrics(metrics);
      ref.read(globalMetricsProvider.notifier).state = global;
    }
  }

  /// Clear all collected metrics
  void _clearMetrics() {
    ref.read(performanceMetricsProvider.notifier).state = [];
    ref.read(globalMetricsProvider.notifier).state = null;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Metrics cleared'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final metrics = ref.watch(performanceMetricsProvider);
    final globalMetrics = ref.watch(globalMetricsProvider);

    // Auto-update global metrics when individual metrics change
    if (_isUpdating == false) {
      _isUpdating = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _updateGlobalMetrics();
        _isUpdating = false;
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Performance Dashboard'),
        actions: [
          IconButton(
            icon: Icon(_showDetails ? Icons.view_list : Icons.dashboard),
            onPressed: () {
              setState(() {
                _showDetails = !_showDetails;
              });
            },
            tooltip: _showDetails ? 'Show Summary' : 'Show Details',
          ),
          if (metrics.isNotEmpty || globalMetrics != null)
            IconButton(
              icon: const Icon(Icons.clear),
              onPressed: _clearMetrics,
              tooltip: 'Clear Metrics',
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Debug Mode Notice
            Card(
              color: kDebugMode
                  ? theme.colorScheme.primaryContainer.withValues(alpha:0.3)
                  : theme.colorScheme.errorContainer.withValues(alpha:0.3),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(
                      kDebugMode ? Icons.info_outline : Icons.warning,
                      color: kDebugMode
                          ? theme.colorScheme.primary
                          : theme.colorScheme.error,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        kDebugMode
                            ? 'Performance tracking is enabled in debug mode. Metrics update in real-time as you interact with lists.'
                            : 'Performance tracking is disabled in release mode. Switch to debug mode to see metrics.',
                        style: theme.textTheme.bodySmall,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Global Metrics Summary
            if (globalMetrics != null)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.speed,
                            color: globalMetrics.meetsTargets()
                                ? Colors.green
                                : Colors.orange,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Global Performance',
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: globalMetrics.meetsTargets()
                                  ? Colors.green
                                  : Colors.orange,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Spacer(),
                          Icon(
                            globalMetrics.meetsTargets()
                                ? Icons.check_circle
                                : Icons.warning,
                            color: globalMetrics.meetsTargets()
                                ? Colors.green
                                : Colors.orange,
                          ),
                        ],
                      ),
                      const Divider(height: 24),
                      _GlobalMetricRow(
                        label: 'Average FPS',
                        value: globalMetrics.averageFPS.toStringAsFixed(1),
                        target: '≥ 55',
                        meetsTarget: globalMetrics.averageFPS >= 55,
                        isLowerBetter: false,
                      ),
                      _GlobalMetricRow(
                        label: 'Avg Janky Frames',
                        value:
                            '${globalMetrics.averageJankyPercentage.toStringAsFixed(1)}%',
                        target: '< 10%',
                        meetsTarget: globalMetrics.averageJankyPercentage < 10,
                        isLowerBetter: true,
                      ),
                      _GlobalMetricRow(
                        label: 'Total Memory',
                        value:
                            '${(globalMetrics.totalMemoryUsage / 1024 / 1024).toStringAsFixed(2)} MB',
                        target: '< 200 MB',
                        meetsTarget:
                            globalMetrics.totalMemoryUsage < 200 * 1024 * 1024,
                        isLowerBetter: true,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Tracked Lists: ${globalMetrics.trackedListCount}',
                        style: theme.textTheme.bodySmall,
                      ),
                      Text(
                        'Updated: ${globalMetrics.timestamp.toLocal().toString().split('.')[0]}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            if (globalMetrics != null) const SizedBox(height: 16),

            // Individual Metrics (when details are enabled)
            if (_showDetails && metrics.isNotEmpty) ...[
              Text(
                'Individual List Metrics',
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: 12),
              ...metrics.asMap().entries.map((entry) {
                final index = entry.key;
                final metric = entry.value;
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              'List ${index + 1}',
                              style: theme.textTheme.labelLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Spacer(),
                            Icon(
                              metric.meetsTargets()
                                  ? Icons.check_circle
                                  : Icons.warning,
                              color: metric.meetsTargets()
                                  ? Colors.green
                                  : Colors.orange,
                              size: 20,
                            ),
                          ],
                        ),
                        const Divider(height: 16),
                        _CompactMetricRow(
                          label: 'FPS',
                          value: metric.averageFPS.toStringAsFixed(1),
                          isGood: metric.averageFPS >= 55,
                        ),
                        _CompactMetricRow(
                          label: 'Janky',
                          value:
                              '${metric.jankyFramePercentage.toStringAsFixed(1)}%',
                          isGood: metric.jankyFramePercentage < 10,
                        ),
                        _CompactMetricRow(
                          label: 'Render',
                          value: '${metric.initialRenderTimeMs}ms',
                          isGood: metric.initialRenderTimeMs < 1000,
                        ),
                        _CompactMetricRow(
                          label: 'Memory',
                          value:
                              '${(metric.currentMemoryUsageBytes / 1024 / 1024).toStringAsFixed(1)}MB',
                          isGood: metric.currentMemoryUsageBytes <
                              150 * 1024 * 1024,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Frames: ${metric.totalFrames} (${metric.jankyFrames} janky)',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ],

            if (metrics.isEmpty)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: 48,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No metrics collected yet',
                        style: theme.textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Navigate to screens with virtual lists to start tracking performance.',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),

            const SizedBox(height: 24),

            // Information Card
            Card(
              color: theme.colorScheme.primaryContainer.withValues(alpha:0.3),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.help_outline,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'About Performance Metrics',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'This dashboard shows real-time performance metrics from virtual lists throughout the app.\n\n'
                      '• FPS: Frames per second during scrolling (target: ≥55)\n'
                      '• Janky: Percentage of slow frames (target: <10%)\n'
                      '• Render: Initial list render time in ms (target: <1000ms)\n'
                      '• Memory: Memory usage for the list (target: <150MB per list)\n\n'
                      'Green indicators mean targets are met, orange indicates performance issues.\n'
                      'Tap the overlay on lists to see more details.',
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Widget for displaying a global metric row with target comparison
class _GlobalMetricRow extends StatelessWidget {
  final String label;
  final String value;
  final String target;
  final bool meetsTarget;
  final bool isLowerBetter;

  const _GlobalMetricRow({
    required this.label,
    required this.value,
    required this.target,
    required this.meetsTarget,
    required this.isLowerBetter,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: theme.textTheme.bodyMedium,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: meetsTarget ? Colors.green : Colors.orange,
              ),
              textAlign: TextAlign.right,
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 50,
            child: Text(
              target,
              style: theme.textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.right,
            ),
          ),
          const SizedBox(width: 8),
          Icon(
            meetsTarget ? Icons.check_circle : Icons.warning,
            color: meetsTarget ? Colors.green : Colors.orange,
            size: 20,
          ),
        ],
      ),
    );
  }
}

/// Compact metric row for individual list metrics
class _CompactMetricRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isGood;

  const _CompactMetricRow({
    required this.label,
    required this.value,
    required this.isGood,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 12),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: isGood ? Colors.green : Colors.orange,
            ),
          ),
        ],
      ),
    );
  }
}
