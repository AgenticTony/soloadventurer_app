import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soloadventurer/utils/performance_monitoring.dart';
import 'package:soloadventurer/utils/performance_metrics.dart';
import 'package:soloadventurer/core/monitoring/monitoring_service.dart';

/// Example screen demonstrating performance monitoring
class PerformanceExampleScreen extends ConsumerStatefulWidget {
  const PerformanceExampleScreen({super.key});

  @override
  ConsumerState<PerformanceExampleScreen> createState() =>
      _PerformanceExampleScreenState();
}

class _PerformanceExampleScreenState
    extends ConsumerState<PerformanceExampleScreen> {
  final List<String> _items = [];
  bool _isLoading = false;
  String _lastOperationTime = '';
  String _performanceReport = '';

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  /// Load initial data with performance tracking
  Future<void> _loadInitialData() async {
    await PerformanceMonitoring.measureUiOperation(
      operationName: 'initial_data_load',
      operation: () async {
        setState(() {
          _isLoading = true;
        });

        // Simulate network delay
        await Future.delayed(const Duration(milliseconds: 800));

        // Generate items
        final newItems = List.generate(
            20,
            (index) =>
                'Item ${index + 1} - ${DateTime.now().millisecondsSinceEpoch}');

        setState(() {
          _items.addAll(newItems);
          _isLoading = false;
        });
      },
      threshold: PerformanceThresholds.listRendering,
    );
  }

  /// Load more data with performance tracking
  Future<void> _loadMoreData() async {
    final duration = await PerformanceMonitoring.measureNetworkOperation(
      operationName: 'load_more_data',
      operation: () async {
        setState(() {
          _isLoading = true;
        });

        // Simulate network delay
        await Future.delayed(const Duration(milliseconds: 1200));

        // Generate more items
        final currentCount = _items.length;
        final newItems = List.generate(
            10,
            (index) =>
                'Item ${currentCount + index + 1} - ${DateTime.now().millisecondsSinceEpoch}');

        setState(() {
          _items.addAll(newItems);
          _isLoading = false;
        });

        return const Duration(
            milliseconds: 1200); // Return a Duration instead of int
      },
      threshold: PerformanceThresholds.apiCall,
    );

    setState(() {
      _lastOperationTime = '${duration.inMilliseconds}ms';
    });
  }

  /// Simulate a slow operation that will breach the threshold
  Future<void> _simulateSlowOperation() async {
    final duration = await PerformanceMonitoring.measureNetworkOperation(
      operationName: 'slow_operation',
      operation: () async {
        setState(() {
          _isLoading = true;
        });

        // Simulate a very slow operation
        await Future.delayed(const Duration(milliseconds: 2500));

        setState(() {
          _isLoading = false;
        });

        return const Duration(
            milliseconds: 2500); // Return a Duration instead of bool
      },
      threshold: PerformanceThresholds.apiCall, // This will be breached
    );

    setState(() {
      _lastOperationTime = '${duration.inMilliseconds}ms (Slow!)';
    });
  }

  /// Generate a performance report
  void _generateReport() {
    final report = PerformanceMonitoring.generatePerformanceReport();
    setState(() {
      _performanceReport = report;
    });
  }

  /// Test direct CloudWatch integration
  Future<void> _testCloudWatchIntegration() async {
    setState(() {
      _isLoading = true;
      _lastOperationTime = 'Sending test metric to CloudWatch...';
    });

    try {
      await PerformanceMonitoring.measureNetworkOperation(
        operationName: 'cloudwatch_test',
        operation: () async {
          // Simulate some work
          await Future.delayed(const Duration(milliseconds: 500));
          return const Duration(milliseconds: 500);
        },
        threshold: const Duration(milliseconds: 1000),
      );

      setState(() {
        _lastOperationTime = 'Test metric sent to CloudWatch!';
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Test metric sent to CloudWatch successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      setState(() {
        _lastOperationTime = 'Error: ${e.toString()}';
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error sending metric: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Performance Monitoring'),
        actions: [
          IconButton(
            icon: const Icon(Icons.assessment),
            onPressed: _generateReport,
            tooltip: 'Generate Performance Report',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Last operation: $_lastOperationTime',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            ElevatedButton(
                              onPressed: _loadMoreData,
                              child: const Text('Load More'),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton(
                              onPressed: _simulateSlowOperation,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.orange,
                              ),
                              child: const Text('Slow Operation'),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton(
                              onPressed: _testCloudWatchIntegration,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.purple,
                              ),
                              child: const Text('Test CloudWatch'),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                if (_performanceReport.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Container(
                      padding: const EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: Text(_performanceReport),
                    ),
                  ),
                Expanded(
                  child: PerformanceMetrics.measureSyncFunction(
                    'build_list_view',
                    () => ListView.builder(
                      itemCount: _items.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          title: Text(_items[index]),
                          leading: const Icon(Icons.article),
                          trailing: const Icon(Icons.arrow_forward_ios),
                          onTap: () {
                            // Measure the tap response time
                            PerformanceMetrics.measureFunction(
                              'item_tap_response',
                              () async {
                                await Future.delayed(
                                    const Duration(milliseconds: 100));
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Tapped on ${_items[index]}'),
                                    duration: const Duration(seconds: 1),
                                  ),
                                );
                              },
                              category: MetricCategory.ui,
                            );
                          },
                        );
                      },
                    ),
                    category: MetricCategory.ui,
                  ),
                ),
              ],
            ),
    );
  }
}
