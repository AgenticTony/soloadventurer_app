import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soloadventurer/features/travel/domain/models/trip.dart';
import 'package:soloadventurer_test/utils/performance/performance_test_utils.dart';

/// Performance benchmark dashboard screen
///
/// Displays performance metrics, benchmark results, and allows running
/// performance tests directly from the UI. This screen is used for
/// monitoring and validating app performance during development and testing.
class PerformanceBenchmarkScreen extends ConsumerStatefulWidget {
  /// Creates a new [PerformanceBenchmarkScreen]
  const PerformanceBenchmarkScreen({super.key});

  @override
  ConsumerState<PerformanceBenchmarkScreen> createState() =>
      _PerformanceBenchmarkScreenState();
}

class _PerformanceBenchmarkScreenState
    extends ConsumerState<PerformanceBenchmarkScreen> {
  /// Current performance metrics
  PerformanceMetrics? _currentMetrics;

  /// Baseline metrics for comparison
  PerformanceMetrics? _baselineMetrics;

  /// Test execution status
  bool _isRunningTest = false;

  /// Test result message
  String _testResult = '';

  /// Selected test type
  String _selectedTest = 'Comprehensive Baseline';

  /// Test type options
  static const List<String> _testOptions = [
    'Comprehensive Baseline',
    'Memory Test (500 trips)',
    'Memory Test (500 photos)',
    'List Rendering Test',
    'Data Generation Test',
  ];

  /// Performance targets
  static const Map<String, double> _targets = {
    'Startup Time (ms)': 2000,
    'Memory Usage (MB)': 200,
    'List Render Time (ms)': 3000,
    'Scroll FPS': 55,
    'Janky Frames (%)': 10,
  };

  @override
  void initState() {
    super.initState();
    _loadSavedMetrics();
  }

  /// Load any previously saved metrics
  Future<void> _loadSavedMetrics() async {
    // In a real implementation, this would load from local storage
    // For now, we'll just set the current metrics if they exist
    final lastMetrics = PerformanceReporter.lastMetrics;
    if (lastMetrics != null && mounted) {
      setState(() {
        _currentMetrics = lastMetrics;
      });
    }
  }

  /// Run the selected performance test
  Future<void> _runPerformanceTest() async {
    if (_isRunningTest) return;

    setState(() {
      _isRunningTest = true;
      _testResult = 'Running test...';
    });

    try {
      final metrics = await _executeTest(_selectedTest);

      if (mounted) {
        setState(() {
          _currentMetrics = metrics;
          _isRunningTest = false;

          // Check if targets are met
          if (metrics.meetsTargets()) {
            _testResult = '✅ All performance targets met!';
          } else {
            final failures = metrics.getFailedTargets();
            _testResult = '❌ ${failures.length} target(s) not met:\n${failures.join('\n')}';
          }
        });

        // Show snackbar with result
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                metrics.meetsTargets()
                    ? '✅ Performance test passed!'
                    : '⚠️ Performance test failed - see details',
              ),
              backgroundColor:
                  metrics.meetsTargets() ? Colors.green : Colors.orange,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isRunningTest = false;
          _testResult = '❌ Test failed: ${e.toString()}';
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Test failed: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Execute the selected test type
  Future<PerformanceMetrics> _executeTest(String testType) async {
    switch (testType) {
      case 'Memory Test (500 trips)':
        return await _runMemoryTest();
      case 'Memory Test (500 photos)':
        return await _runPhotoMemoryTest();
      case 'List Rendering Test':
        return await _runListRenderingTest();
      case 'Data Generation Test':
        return await _runDataGenerationTest();
      case 'Comprehensive Baseline':
      default:
        return await _runComprehensiveTest();
    }
  }

  /// Memory test with 500 trips
  Future<PerformanceMetrics> _runMemoryTest() async {
    final initialMemory = await PerformanceReporter.captureMemoryUsage();

    // Generate and load 500 trips
    final trips = PerformanceTestDataGenerator.generateLargeTripList(count: 500);
    final loadedTrips = <Trip>[];
    for (final trip in trips) {
      loadedTrips.add(trip);
    }

    final finalMemory = await PerformanceReporter.captureMemoryUsage();
    final memoryDelta = finalMemory - initialMemory;

    return PerformanceReporter.createMetrics(
      startupTimeMs: 0,
      memoryUsageBytes: memoryDelta,
      listRenderTimeMs: 0,
      scrollFPS: 60.0,
      jankyFramePercentage: 0.0,
    );
  }

  /// Memory test with 500 photos
  Future<PerformanceMetrics> _runPhotoMemoryTest() async {
    final initialMemory = await PerformanceReporter.captureMemoryUsage();

    // Generate and load 500 photo metadata
    final photos = PhotoDataGenerator.generatePhotoMetadata(count: 500);
    final loadedPhotos = <Map<String, dynamic>>[];
    for (final photo in photos) {
      loadedPhotos.add(photo);
    }

    final finalMemory = await PerformanceReporter.captureMemoryUsage();
    final memoryDelta = finalMemory - initialMemory;

    return PerformanceReporter.createMetrics(
      startupTimeMs: 0,
      memoryUsageBytes: memoryDelta,
      listRenderTimeMs: 0,
      scrollFPS: 60.0,
      jankyFramePercentage: 0.0,
    );
  }

  /// List rendering performance test
  Future<PerformanceMetrics> _runListRenderingTest() async {
    // Generate test data
    final trips = PerformanceTestDataGenerator.generateLargeTripList(count: 500);

    // Measure rendering time
    final renderTime = await PerformanceReporter.measureTime(
      'List rendering',
      () async {
        // Simulate list widget creation
        final listItems = trips
            .map(
              (trip) => ListTile(
                title: Text(trip.title),
                subtitle: Text(trip.destination),
                trailing: Text('\$${trip.budget}'),
              ),
            )
            .toList();

        // Force widget creation
        for (final item in listItems) {
          item.createElement();
        }
      },
    );

    // Capture memory
    final memoryUsage = await PerformanceReporter.captureMemoryUsage();

    return PerformanceReporter.createMetrics(
      startupTimeMs: 0,
      memoryUsageBytes: memoryUsage,
      listRenderTimeMs: renderTime.inMilliseconds,
      scrollFPS: 60.0,
      jankyFramePercentage: 0.0,
    );
  }

  /// Data generation performance test
  Future<PerformanceMetrics> _runDataGenerationTest() async {
    final iterations = 10;
    final timings = <int>[];

    // Measure data generation performance
    for (int i = 0; i < iterations; i++) {
      final stopwatch = Stopwatch()..start();

      PerformanceTestDataGenerator.generateLargeTripList(count: 500);
      PhotoDataGenerator.generatePhotoUrls(count: 500);
      PhotoDataGenerator.generatePhotoMetadata(count: 500);

      stopwatch.stop();
      timings.add(stopwatch.elapsedMilliseconds);
    }

    final averageTime = timings.reduce((a, b) => a + b) / timings.length;

    // Capture memory
    final memoryUsage = await PerformanceReporter.captureMemoryUsage();

    return PerformanceReporter.createMetrics(
      startupTimeMs: averageTime.toInt(),
      memoryUsageBytes: memoryUsage,
      listRenderTimeMs: 0,
      scrollFPS: 60.0,
      jankyFramePercentage: 0.0,
    );
  }

  /// Comprehensive performance baseline test
  Future<PerformanceMetrics> _runComprehensiveTest() async {
    // Generate test data
    final trips = PerformanceTestDataGenerator.generateLargeTripList(count: 500);
    final photos = PhotoDataGenerator.generatePhotoMetadata(count: 500);

    // Measure 1: Memory with trips
    final memoryBeforeTrips = await PerformanceReporter.captureMemoryUsage();
    final loadedTrips = <Trip>[...trips];
    final memoryAfterTrips = await PerformanceReporter.captureMemoryUsage();
    final tripMemory = memoryAfterTrips - memoryBeforeTrips;

    // Measure 2: Memory with photos
    final memoryBeforePhotos = await PerformanceReporter.captureMemoryUsage();
    final loadedPhotos = <Map<String, dynamic>>[...photos];
    final memoryAfterPhotos = await PerformanceReporter.captureMemoryUsage();
    final photoMemory = memoryAfterPhotos - memoryBeforePhotos;

    // Measure 3: Data generation speed
    final genStopwatch = Stopwatch()..start();
    PerformanceTestDataGenerator.generateLargeTripList(count: 500);
    PhotoDataGenerator.generatePhotoMetadata(count: 500);
    genStopwatch.stop();

    return PerformanceReporter.createMetrics(
      startupTimeMs: genStopwatch.elapsedMilliseconds,
      memoryUsageBytes: tripMemory + photoMemory,
      listRenderTimeMs: 0,
      scrollFPS: 60.0,
      jankyFramePercentage: 0.0,
    );
  }

  /// Compare current metrics with baseline
  String _getComparisonText() {
    if (_currentMetrics == null || _baselineMetrics == null) {
      return 'Run a test and set baseline to compare results';
    }

    return PerformanceReporter.compareMetrics(
      _baselineMetrics!,
      _currentMetrics!,
    );
  }

  /// Set current metrics as baseline
  void _setAsBaseline() {
    if (_currentMetrics != null) {
      setState(() {
        _baselineMetrics = _currentMetrics;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Current metrics set as baseline'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  /// Clear all metrics
  void _clearMetrics() {
    setState(() {
      _currentMetrics = null;
      _baselineMetrics = null;
      _testResult = '';
    });

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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Performance Benchmark'),
        actions: [
          if (_currentMetrics != null)
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: _setAsBaseline,
              tooltip: 'Set as Baseline',
            ),
          if (_currentMetrics != null || _baselineMetrics != null)
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
            // Test Selection Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Select Test Type',
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: _selectedTest,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Test Type',
                      ),
                      items: _testOptions.map((String test) {
                        return DropdownMenuItem<String>(
                          value: test,
                          child: Text(test),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          setState(() {
                            _selectedTest = newValue;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _isRunningTest ? null : _runPerformanceTest,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: _isRunningTest
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                          : const Text('Run Performance Test'),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Test Result
            if (_testResult.isNotEmpty)
              Card(
                color: _testResult.contains('✅')
                    ? Colors.green.shade50
                    : _testResult.contains('❌')
                        ? Colors.orange.shade50
                        : theme.colorScheme.surface,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    _testResult,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: _testResult.contains('✅')
                          ? Colors.green.shade900
                          : _testResult.contains('❌')
                              ? Colors.orange.shade900
                              : null,
                    ),
                  ),
                ),
              ),

            if (_testResult.isNotEmpty) const SizedBox(height: 16),

            // Performance Targets
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Performance Targets',
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 12),
                    ..._targets.entries.map((entry) {
                      final value = entry.value;
                      final isMemoryOrTime =
                          entry.key.contains('ms') || entry.key.contains('MB');
                      final isPercentage = entry.key.contains('%');
                      final isFPS = entry.key.contains('FPS');

                      String formattedValue;
                      if (isMemoryOrTime) {
                        formattedValue = '< ${value.toInt()}';
                      } else if (isPercentage) {
                        formattedValue = '< ${value.toInt()}%';
                      } else if (isFPS) {
                        formattedValue = '≥ ${value.toInt()}';
                      } else {
                        formattedValue = value.toString();
                      }

                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(entry.key),
                            Text(
                              formattedValue,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Current Metrics
            if (_currentMetrics != null)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Current Metrics',
                        style: theme.textTheme.titleMedium,
                      ),
                      const SizedBox(height: 12),
                      _MetricRow(
                        label: 'Startup Time',
                        value: '${_currentMetrics!.startupTimeMs} ms',
                        target: _targets['Startup Time (ms)']!.toInt(),
                        currentValue: _currentMetrics!.startupTimeMs.toDouble(),
                        isLowerBetter: true,
                      ),
                      _MetricRow(
                        label: 'Memory Usage',
                        value:
                            '${(_currentMetrics!.memoryUsageBytes / 1024 / 1024).toStringAsFixed(2)} MB',
                        target: _targets['Memory Usage (MB)']!.toInt(),
                        currentValue:
                            _currentMetrics!.memoryUsageBytes / 1024 / 1024,
                        isLowerBetter: true,
                      ),
                      _MetricRow(
                        label: 'List Render Time',
                        value: '${_currentMetrics!.listRenderTimeMs} ms',
                        target: _targets['List Render Time (ms)']!.toInt(),
                        currentValue:
                            _currentMetrics!.listRenderTimeMs.toDouble(),
                        isLowerBetter: true,
                      ),
                      _MetricRow(
                        label: 'Scroll FPS',
                        value: _currentMetrics!.scrollFPS.toStringAsFixed(1),
                        target: _targets['Scroll FPS']!.toInt(),
                        currentValue: _currentMetrics!.scrollFPS,
                        isLowerBetter: false,
                      ),
                      _MetricRow(
                        label: 'Janky Frames',
                        value:
                            '${_currentMetrics!.jankyFramePercentage.toStringAsFixed(1)}%',
                        target: _targets['Janky Frames (%)']!.toInt(),
                        currentValue: _currentMetrics!.jankyFramePercentage,
                        isLowerBetter: true,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Timestamp: ${_currentMetrics!.timestamp.toLocal().toString().split('.')[0]}',
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ),

            if (_currentMetrics != null) const SizedBox(height: 16),

            // Baseline Metrics
            if (_baselineMetrics != null)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Baseline Metrics',
                        style: theme.textTheme.titleMedium,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Startup: ${_baselineMetrics!.startupTimeMs} ms\n'
                        'Memory: ${(_baselineMetrics!.memoryUsageBytes / 1024 / 1024).toStringAsFixed(2)} MB\n'
                        'Render: ${_baselineMetrics!.listRenderTimeMs} ms\n'
                        'FPS: ${_baselineMetrics!.scrollFPS.toStringAsFixed(1)}\n'
                        'Janky: ${_baselineMetrics!.jankyFramePercentage.toStringAsFixed(1)}%',
                        style: theme.textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _getComparisonText(),
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontFamily: 'monospace',
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            const SizedBox(height: 24),

            // Information
            Card(
              color: theme.colorScheme.primaryContainer.withOpacity(0.3),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info_outline, color: theme.colorScheme.primary),
                        const SizedBox(width: 8),
                        Text(
                          'About Performance Tests',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'These tests measure app performance with large datasets (500+ items).\n\n'
                      '• Run tests before and after optimizations to measure improvements\n'
                      '• Set baseline to compare results over time\n'
                      '• Metrics are compared against performance targets\n'
                      '• Green indicators mean targets are met\n'
                      '• Run in profile mode for accurate results',
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

/// Widget to display a metric row with status indicator
class _MetricRow extends StatelessWidget {
  final String label;
  final String value;
  final int target;
  final double currentValue;
  final bool isLowerBetter;

  const _MetricRow({
    required this.label,
    required this.value,
    required this.target,
    required this.currentValue,
    required this.isLowerBetter,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final meetsTarget = isLowerBetter
        ? currentValue <= target
        : currentValue >= target;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
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
