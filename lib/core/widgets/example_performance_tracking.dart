import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:soloadventurer/core/widgets/widgets.dart';

/// Example 1: Basic performance tracking with overlay
///
/// This example shows the simplest way to add performance tracking
/// to a VirtualListView with a visual overlay showing metrics.
class ExampleBasicPerformanceTracking extends StatelessWidget {
  final List<String> items = List.generate(500, (i) => 'Item $i');

  ExampleBasicPerformanceTracking({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Basic Performance Tracking')),
      body: VirtualListPerformanceTracker(
        itemName: 'Items List',
        showOverlay: true, // Show performance overlay in debug mode
        child: VirtualListView<String>(
          itemCount: items.length,
          itemBuilder: (context, index) => ListTile(
            title: Text(items[index]),
            leading: CircleAvatar(child: Text('$index')),
          ),
        ),
      ),
    );
  }
}

/// Example 2: Performance tracking with custom callbacks
///
/// This example demonstrates how to use the onMetricsUpdated callback
/// to log performance data or send it to analytics.
class ExamplePerformanceWithCallbacks extends StatelessWidget {
  final List<String> items = List.generate(500, (i) => 'Item $i');

  ExamplePerformanceWithCallbacks({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Performance with Callbacks')),
      body: VirtualListPerformanceTracker(
        itemName: 'Items List',
        showOverlay: true,
        onMetricsUpdated: (metrics) {
          // Log performance metrics
          if (kDebugMode) {
            debugPrint('=== Performance Metrics ===');
            debugPrint('Initial Render: ${metrics.initialRenderTimeMs}ms');
            debugPrint(
                'Memory: ${(metrics.currentMemoryUsageBytes / 1024 / 1024).toStringAsFixed(2)} MB');
            debugPrint('Average FPS: ${metrics.averageFPS.toStringAsFixed(1)}');
            debugPrint(
                'Janky Frames: ${metrics.jankyFramePercentage.toStringAsFixed(1)}%');

            // Check if targets are met
            if (metrics.meetsTargets()) {
              debugPrint('✅ All targets met!');
            } else {
              debugPrint('❌ Some targets not met');
            }
          }
        },
        child: VirtualListView<String>(
          itemCount: items.length,
          itemBuilder: (context, index) => Card(
            child: ListTile(
              title: Text(items[index]),
              subtitle: Text('This is item number $index'),
            ),
          ),
        ),
      ),
    );
  }
}

/// Example 3: Performance tracking for VirtualGridView
///
/// This example shows performance tracking with a grid layout,
/// which is useful for photo galleries or card grids.
class ExampleGridPerformanceTracking extends StatelessWidget {
  final List<String> photos = List.generate(500, (i) => 'Photo $i');

  ExampleGridPerformanceTracking({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Grid Performance Tracking')),
      body: VirtualListPerformanceTracker(
        itemName: 'Photo Gallery',
        showOverlay: true,
        onMetricsUpdated: (metrics) {
          // Monitor grid-specific performance
          if (kDebugMode && !metrics.meetsTargets()) {
            debugPrint('⚠️ Grid performance below target');
            debugPrint(
                '  FPS: ${metrics.averageFPS.toStringAsFixed(1)} (target: ≥55)');
            debugPrint(
                '  Memory: ${(metrics.currentMemoryUsageBytes / 1024 / 1024).toStringAsFixed(1)} MB (target: <150)');
          }
        },
        child: VirtualGridView<String>(
          itemCount: photos.length,
          crossAxisCount: 3,
          childAspectRatio: 1.0,
          mainAxisSpacing: 4,
          crossAxisSpacing: 4,
          itemBuilder: (context, index) => Card(
            child: GridTile(
              header: GridTileBar(
                title: Text('Photo $index'),
                backgroundColor: Colors.black54,
              ),
              child: Container(
                color: Colors.grey[300],
                child: Center(
                  child: Icon(Icons.photo, size: 48, color: Colors.grey[700]),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Example 4: Disabled performance tracking
///
/// This example shows how to disable performance tracking when needed.
/// Note: Tracking is automatically disabled in release builds.
class ExampleDisabledPerformanceTracking extends StatelessWidget {
  final List<String> items = List.generate(500, (i) => 'Item $i');

  ExampleDisabledPerformanceTracking({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Disabled Performance Tracking')),
      body: VirtualListPerformanceTracker(
        enabled: false, // Explicitly disable tracking
        child: VirtualListView<String>(
          itemCount: items.length,
          itemBuilder: (context, index) => ListTile(title: Text(items[index])),
        ),
      ),
    );
  }
}

/// Example 5: Performance tracking without overlay
///
/// This example demonstrates silent performance tracking without
/// the visual overlay, useful for production monitoring.
class ExampleSilentPerformanceTracking extends StatefulWidget {
  final List<String> items = List.generate(500, (i) => 'Item $i');

  ExampleSilentPerformanceTracking({super.key});

  @override
  State<ExampleSilentPerformanceTracking> createState() =>
      _ExampleSilentPerformanceTrackingState();
}

class _ExampleSilentPerformanceTrackingState
    extends State<ExampleSilentPerformanceTracking> {
  VirtualListPerformanceMetrics? _latestMetrics;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Silent Performance Tracking'),
        actions: [
          IconButton(
            icon: const Icon(Icons.analytics),
            onPressed: () => _showMetricsDialog(context),
          ),
        ],
      ),
      body: VirtualListPerformanceTracker(
        itemName: 'Items List',
        showOverlay: false, // No overlay
        onMetricsUpdated: (metrics) {
          // Store metrics for later display
          setState(() {
            _latestMetrics = metrics;
          });
        },
        child: VirtualListView<String>(
          itemCount: widget.items.length,
          itemBuilder: (context, index) => ListTile(
            title: Text(widget.items[index]),
            trailing: const Icon(Icons.chevron_right),
          ),
        ),
      ),
    );
  }

  void _showMetricsDialog(BuildContext context) {
    if (_latestMetrics == null) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Performance Metrics'),
          content:
              const Text('No metrics available yet. Scroll the list first.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Performance Metrics'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Initial Render: ${_latestMetrics!.initialRenderTimeMs}ms'),
              Text(
                  'Memory: ${(_latestMetrics!.currentMemoryUsageBytes / 1024 / 1024).toStringAsFixed(2)} MB'),
              Text(
                  'Average FPS: ${_latestMetrics!.averageFPS.toStringAsFixed(1)}'),
              Text(
                  'Janky Frames: ${_latestMetrics!.jankyFramePercentage.toStringAsFixed(1)}%'),
              Text('Total Frames: ${_latestMetrics!.totalFrames}'),
              const SizedBox(height: 16),
              Text(
                _latestMetrics!.meetsTargets()
                    ? '✅ All targets met!'
                    : '❌ Some targets not met',
                style: TextStyle(
                  color: _latestMetrics!.meetsTargets()
                      ? Colors.green
                      : Colors.orange,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}

/// Example 6: Combined scroll and render performance tracking
///
/// This example demonstrates using both VirtualListPerformanceTracker
/// and ScrollPerformanceTrackerWidget for comprehensive monitoring.
class ExampleCombinedPerformanceTracking extends StatelessWidget {
  final List<String> items = List.generate(500, (i) => 'Item $i');

  ExampleCombinedPerformanceTracking({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Combined Performance Tracking')),
      body: VirtualListPerformanceTracker(
        itemName: 'Items List',
        showOverlay: true,
        onMetricsUpdated: (metrics) {
          // Track render performance
          if (kDebugMode) {
            debugPrint('Render FPS: ${metrics.averageFPS.toStringAsFixed(1)}');
          }
        },
        child: ScrollPerformanceTrackerWidget(
          minScrollDurationMs: 500,
          onScrollComplete: (details) {
            // Track scroll performance
            if (kDebugMode) {
              debugPrint('=== Scroll Performance ===');
              debugPrint('Duration: ${details.scrollDurationMs}ms');
              debugPrint(
                  'Distance: ${details.pixelsScrolled.toStringAsFixed(0)}px');
              debugPrint(
                  'Avg Velocity: ${details.averageVelocity.toStringAsFixed(0)}px/s');
              debugPrint(
                  'Peak Velocity: ${details.peakVelocity.toStringAsFixed(0)}px/s');
              debugPrint(
                  'Scroll FPS: ${details.averageFPS.toStringAsFixed(1)}');
            }
          },
          child: VirtualListView<String>(
            itemCount: items.length,
            itemBuilder: (context, index) => Card(
              margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: ListTile(
                title: Text(items[index]),
                subtitle: const Text('Scroll to see performance metrics'),
                leading: const Icon(Icons.speed),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Example 7: Performance tracking with states
///
/// This example shows how to track performance across different
/// states (loading, error, empty).
class ExamplePerformanceWithStates extends StatefulWidget {
  const ExamplePerformanceWithStates({super.key});

  @override
  State<ExamplePerformanceWithStates> createState() =>
      _ExamplePerformanceWithStatesState();
}

class _ExamplePerformanceWithStatesState
    extends State<ExamplePerformanceWithStates> {
  bool _isLoading = true;
  bool _hasError = false;
  List<String> _items = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    await Future.delayed(const Duration(seconds: 1));

    setState(() {
      _isLoading = false;
      _items = List.generate(500, (i) => 'Loaded Item $i');
    });
  }

  void _simulateError() {
    setState(() {
      _isLoading = false;
      _hasError = true;
      _items = [];
    });
  }

  void _clearData() {
    setState(() {
      _isLoading = false;
      _hasError = false;
      _items = [];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Performance with States'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
          ),
          IconButton(
            icon: const Icon(Icons.error),
            onPressed: _simulateError,
          ),
          IconButton(
            icon: const Icon(Icons.clear),
            onPressed: _clearData,
          ),
        ],
      ),
      body: VirtualListPerformanceTracker(
        itemName: 'Stateful List',
        showOverlay: true,
        child: VirtualListView<String>(
          itemCount: _items.length,
          isLoading: _isLoading,
          hasError: _hasError,
          loadingWidget: const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Loading items...'),
              ],
            ),
          ),
          errorWidget: const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 48, color: Colors.red),
                SizedBox(height: 16),
                Text('Error loading items'),
              ],
            ),
          ),
          emptyWidget: const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.inbox, size: 48, color: Colors.grey),
                SizedBox(height: 16),
                Text('No items'),
              ],
            ),
          ),
          itemBuilder: (context, index) => ListTile(
            title: Text(_items[index]),
            subtitle: const Text('Item with state tracking'),
          ),
        ),
      ),
    );
  }
}

/// Example 8: Performance comparison widget
///
/// This example shows how to compare performance between different
/// list configurations.
class ExamplePerformanceComparison extends StatelessWidget {
  const ExamplePerformanceComparison({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Performance Comparison')),
      body: ListView(
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Compare performance between different list configurations:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          _PerformanceTestCard(
            title: 'Simple List',
            description: 'Basic text items',
            itemCount: 500,
            builder: (context, index) => Text('Simple Item $index'),
          ),
          _PerformanceTestCard(
            title: 'Complex List',
            description: 'Cards with images and text',
            itemCount: 500,
            builder: (context, index) => Card(
              child: ListTile(
                leading: const CircleAvatar(child: Icon(Icons.person)),
                title: Text('Complex Item $index'),
                subtitle: const Text('With subtitle and icon'),
                trailing: const Icon(Icons.more_vert),
              ),
            ),
          ),
          _PerformanceTestCard(
            title: 'Dense List',
            description: 'Compact items with dense layout',
            itemCount: 500,
            builder: (context, index) => ListTile(
              dense: true,
              title: Text('Dense Item $index'),
            ),
          ),
        ],
      ),
    );
  }
}

class _PerformanceTestCard extends StatelessWidget {
  final String title;
  final String description;
  final int itemCount;
  final Widget Function(BuildContext, int) builder;

  const _PerformanceTestCard({
    required this.title,
    required this.description,
    required this.itemCount,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            title: Text(title,
                style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(description),
          ),
          const Divider(height: 1),
          SizedBox(
            height: 200,
            child: VirtualListPerformanceTracker(
              itemName: title,
              showOverlay: true,
              child: VirtualListView<int>(
                itemCount: itemCount,
                itemBuilder: builder,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
