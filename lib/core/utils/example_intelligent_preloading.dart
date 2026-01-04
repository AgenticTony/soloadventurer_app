import 'package:flutter/material.dart';
import 'package:solodventurer_app/core/models/paginated_data.dart';
import 'package:solodventurer_app/core/utils/preloading_strategy.dart';
import 'package:solodventurer_app/core/widgets/infinite_scroll_list_view.dart';

/// Example 1: Basic intelligent preloading with default configuration
class Example1BasicIntelligentPreloading extends StatelessWidget {
  final List<String> _items = List.generate(100, (i) => 'Item ${i + 1}');

  Future<PaginatedData<String>> _mockFetchData(String? cursor) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final startIndex = cursor == null ? 0 : int.parse(cursor);
    final endIndex = (startIndex + 20).clamp(0, _items.length);
    final items = _items.sublist(startIndex, endIndex);

    return PaginatedData(
      items: items,
      pageInfo: PageInfo(
        currentPage: startIndex ~/ 20,
        itemsPerPage: 20,
        totalItems: _items.length,
        totalPages: (_items.length / 20).ceil(),
        hasNextPage: endIndex < _items.length,
        hasPreviousPage: startIndex > 0,
        nextCursor: endIndex < _items.length ? endIndex.toString() : null,
        previousCursor: startIndex > 0 ? startIndex.toString() : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Example 1: Basic Intelligent Preloading'),
      ),
      body: InfiniteScrollListView<String>.withIntelligentPreloading(
        fetchData: _mockFetchData,
        itemBuilder: (context, item) => ListTile(
          title: Text(item),
          leading: const CircleAvatar(child: Icon(Icons.list)),
        ),
        separatorBuilder: (context, index) => const Divider(height: 1),
        preloadConfig: PreloadConfig.defaultConfig,
      ),
    );
  }
}

/// Example 2: Aggressive preloading for fast networks
class Example2AggressivePreloading extends StatelessWidget {
  final List<String> _items = List.generate(100, (i) => 'Item ${i + 1}');

  Future<PaginatedData<String>> _mockFetchData(String? cursor) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final startIndex = cursor == null ? 0 : int.parse(cursor);
    final endIndex = (startIndex + 20).clamp(0, _items.length);
    final items = _items.sublist(startIndex, endIndex);

    return PaginatedData(
      items: items,
      pageInfo: PageInfo(
        currentPage: startIndex ~/ 20,
        itemsPerPage: 20,
        totalItems: _items.length,
        totalPages: (_items.length / 20).ceil(),
        hasNextPage: endIndex < _items.length,
        hasPreviousPage: startIndex > 0,
        nextCursor: endIndex < _items.length ? endIndex.toString() : null,
        previousCursor: startIndex > 0 ? startIndex.toString() : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Example 2: Aggressive Preloading'),
      ),
      body: InfiniteScrollListView<String>.withIntelligentPreloading(
        fetchData: _mockFetchData,
        itemBuilder: (context, item) => Card(
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: ListTile(
            title: Text(item),
            trailing: const Icon(Icons.arrow_forward),
          ),
        ),
        preloadConfig: PreloadConfig.aggressiveConfig,
      ),
    );
  }
}

/// Example 3: Conservative preloading for slow networks
class Example3ConservativePreloading extends StatelessWidget {
  final List<String> _items = List.generate(100, (i) => 'Item ${i + 1}');

  Future<PaginatedData<String>> _mockFetchData(String? cursor) async {
    await Future.delayed(const Duration(milliseconds: 1500));
    final startIndex = cursor == null ? 0 : int.parse(cursor);
    final endIndex = (startIndex + 20).clamp(0, _items.length);
    final items = _items.sublist(startIndex, endIndex);

    return PaginatedData(
      items: items,
      pageInfo: PageInfo(
        currentPage: startIndex ~/ 20,
        itemsPerPage: 20,
        totalItems: _items.length,
        totalPages: (_items.length / 20).ceil(),
        hasNextPage: endIndex < _items.length,
        hasPreviousPage: startIndex > 0,
        nextCursor: endIndex < _items.length ? endIndex.toString() : null,
        previousCursor: startIndex > 0 ? startIndex.toString() : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Example 3: Conservative Preloading'),
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: Colors.orange.shade100,
            child: const Text(
              'Simulating slow network (1.5s load time)\n'
              'Using conservative strategy to minimize requests',
              style: TextStyle(fontSize: 12),
            ),
          ),
          Expanded(
            child: InfiniteScrollListView<String>.withIntelligentPreloading(
              fetchData: _mockFetchData,
              itemBuilder: (context, item) => ListTile(
                title: Text(item),
                subtitle: const Text('Loading from slow network...'),
              ),
              separatorBuilder: (context, index) => const Divider(height: 1),
              preloadConfig: PreloadConfig.conservativeConfig,
            ),
          ),
        ],
      ),
    );
  }
}

/// Example 4: Custom preloading configuration
class Example4CustomPreloading extends StatelessWidget {
  final List<String> _items = List.generate(100, (i) => 'Item ${i + 1}');

  Future<PaginatedData<String>> _mockFetchData(String? cursor) async {
    await Future.delayed(const Duration(milliseconds: 600));
    final startIndex = cursor == null ? 0 : int.parse(cursor);
    final endIndex = (startIndex + 20).clamp(0, _items.length);
    final items = _items.sublist(startIndex, endIndex);

    return PaginatedData(
      items: items,
      pageInfo: PageInfo(
        currentPage: startIndex ~/ 20,
        itemsPerPage: 20,
        totalItems: _items.length,
        totalPages: (_items.length / 20).ceil(),
        hasNextPage: endIndex < _items.length,
        hasPreviousPage: startIndex > 0,
        nextCursor: endIndex < _items.length ? endIndex.toString() : null,
        previousCursor: startIndex > 0 ? startIndex.toString() : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Example 4: Custom Configuration'),
      ),
      body: InfiniteScrollListView<String>.withIntelligentPreloading(
        fetchData: _mockFetchData,
        itemBuilder: (context, item) => Card(
          margin: const EdgeInsets.all(8),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              item,
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ),
        preloadConfig: PreloadConfig(
          strategy: PreloadStrategy.predictive,
          fixedThreshold: 600.0,
          velocityThreshold: 1200.0,
          velocityMultiplier: 0.6,
          enableAdaptiveThreshold: true,
          minPreloadInterval: 400,
        ),
      ),
    );
  }
}

/// Example 5: Monitoring preload metrics
class Example5MonitoringMetrics extends StatefulWidget {
  @override
  _Example5MonitoringMetricsState createState() =>
      _Example5MonitoringMetricsState();
}

class _Example5MonitoringMetricsState
    extends State<Example5MonitoringMetrics> {
  final List<String> _items = List.generate(100, (i) => 'Item ${i + 1}');
  PreloadMetrics? _metrics;

  Future<PaginatedData<String>> _mockFetchData(String? cursor) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final startIndex = cursor == null ? 0 : int.parse(cursor);
    final endIndex = (startIndex + 20).clamp(0, _items.length);
    final items = _items.sublist(startIndex, endIndex);

    return PaginatedData(
      items: items,
      pageInfo: PageInfo(
        currentPage: startIndex ~/ 20,
        itemsPerPage: 20,
        totalItems: _items.length,
        totalPages: (_items.length / 20).ceil(),
        hasNextPage: endIndex < _items.length,
        hasPreviousPage: startIndex > 0,
        nextCursor: endIndex < _items.length ? endIndex.toString() : null,
        previousCursor: startIndex > 0 ? startIndex.toString() : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Example 5: Monitoring Metrics'),
      ),
      body: Column(
        children: [
          if (_metrics != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              color: Colors.blue.shade50,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Preload Metrics',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '✅ Successful: ${_metrics!.successfulPreloads}',
                    style: const TextStyle(fontSize: 12),
                  ),
                  Text(
                    '❌ Failed: ${_metrics!.failedPreloads}',
                    style: const TextStyle(fontSize: 12),
                  ),
                  Text(
                    '⏱️ Avg Load Time: ${_metrics!.averageLoadTime.toStringAsFixed(0)}ms',
                    style: const TextStyle(fontSize: 12),
                  ),
                  Text(
                    '📊 Cache Hit Rate: ${( _metrics!.cacheHitRate * 100).toStringAsFixed(0)}%',
                    style: const TextStyle(fontSize: 12),
                  ),
                  Text(
                    '🎯 Performing Well: ${_metrics!.isPerformingWell ? "Yes" : "No"}',
                    style: TextStyle(
                      fontSize: 12,
                      color: _metrics!.isPerformingWell
                          ? Colors.green
                          : Colors.orange,
                    ),
                  ),
                ],
              ),
            ),
          Expanded(
            child: InfiniteScrollListView<String>.withIntelligentPreloading(
              fetchData: _mockFetchData,
              itemBuilder: (context, item) => ListTile(
                title: Text(item),
                trailing: const Icon(Icons.arrow_forward),
              ),
              separatorBuilder: (context, index) => const Divider(height: 1),
              preloadConfig: PreloadConfig.defaultConfig,
              onPreloadMetricsUpdated: (metrics) {
                setState(() {
                  _metrics = metrics;
                });
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// Example 6: Comparing strategies
class Example6ComparingStrategies extends StatefulWidget {
  @override
  _Example6ComparingStrategiesState createState() =>
      _Example6ComparingStrategiesState();
}

class _Example6ComparingStrategiesState
    extends State<Example6ComparingStrategies> {
  PreloadStrategy _selectedStrategy = PreloadStrategy.predictive;

  final List<String> _items = List.generate(100, (i) => 'Item ${i + 1}');

  Future<PaginatedData<String>> _mockFetchData(String? cursor) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final startIndex = cursor == null ? 0 : int.parse(cursor);
    final endIndex = (startIndex + 20).clamp(0, _items.length);
    final items = _items.sublist(startIndex, endIndex);

    return PaginatedData(
      items: items,
      pageInfo: PageInfo(
        currentPage: startIndex ~/ 20,
        itemsPerPage: 20,
        totalItems: _items.length,
        totalPages: (_items.length / 20).ceil(),
        hasNextPage: endIndex < _items.length,
        hasPreviousPage: startIndex > 0,
        nextCursor: endIndex < _items.length ? endIndex.toString() : null,
        previousCursor: startIndex > 0 ? startIndex.toString() : null,
      ),
    );
  }

  PreloadConfig _getConfigForStrategy(PreloadStrategy strategy) {
    switch (strategy) {
      case PreloadStrategy.fixedDistance:
        return const PreloadConfig(strategy: PreloadStrategy.fixedDistance);
      case PreloadStrategy.velocityBased:
        return const PreloadConfig(strategy: PreloadStrategy.velocityBased);
      case PreloadStrategy.predictive:
        return const PreloadConfig(strategy: PreloadStrategy.predictive);
      case PreloadStrategy.aggressive:
        return PreloadConfig.aggressiveConfig;
      case PreloadStrategy.conservative:
        return PreloadConfig.conservativeConfig;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Example 6: Comparing Strategies'),
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: Colors.purple.shade50,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Select Preloading Strategy:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: PreloadStrategy.values.map((strategy) {
                    final isSelected = strategy == _selectedStrategy;
                    return ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            isSelected ? Colors.purple : Colors.grey[300],
                        foregroundColor:
                            isSelected ? Colors.white : Colors.black87,
                      ),
                      onPressed: () {
                        setState(() {
                          _selectedStrategy = strategy;
                        });
                      },
                      child: Text(
                        strategy.toString().split('.').last,
                        style: const TextStyle(fontSize: 12),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          Expanded(
            child: InfiniteScrollListView<String>(
              key: ValueKey(_selectedStrategy),
              fetchData: _mockFetchData,
              itemBuilder: (context, item) => ListTile(
                title: Text(item),
                subtitle: Text(
                  'Strategy: ${_selectedStrategy.toString().split('.').last}',
                  style: const TextStyle(fontSize: 10),
                ),
              ),
              separatorBuilder: (context, index) => const Divider(height: 1),
              preloadConfig: _getConfigForStrategy(_selectedStrategy),
            ),
          ),
        ],
      ),
    );
  }
}

/// Example 7: Velocity-based preloading visualization
class Example7VelocityBased extends StatefulWidget {
  @override
  _Example7VelocityBasedState createState() => _Example7VelocityBasedState();
}

class _Example7VelocityBasedState extends State<Example7VelocityBased> {
  final List<String> _items = List.generate(100, (i) => 'Item ${i + 1}');
  double _currentVelocity = 0.0;
  double _threshold = 500.0;

  Future<PaginatedData<String>> _mockFetchData(String? cursor) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final startIndex = cursor == null ? 0 : int.parse(cursor);
    final endIndex = (startIndex + 20).clamp(0, _items.length);
    final items = _items.sublist(startIndex, endIndex);

    return PaginatedData(
      items: items,
      pageInfo: PageInfo(
        currentPage: startIndex ~/ 20,
        itemsPerPage: 20,
        totalItems: _items.length,
        totalPages: (_items.length / 20).ceil(),
        hasNextPage: endIndex < _items.length,
        hasPreviousPage: startIndex > 0,
        nextCursor: endIndex < _items.length ? endIndex.toString() : null,
        previousCursor: startIndex > 0 ? startIndex.toString() : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Example 7: Velocity-Based Preloading'),
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: Colors.teal.shade50,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Velocity-Based Preloading',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Scroll Velocity: ${_currentVelocity.toStringAsFixed(0)} px/s',
                  style: const TextStyle(fontSize: 12),
                ),
                Text(
                  'Preload Threshold: ${_threshold.toStringAsFixed(0)} px',
                  style: const TextStyle(fontSize: 12),
                ),
                const SizedBox(height: 8),
                const Text(
                  '💡 Scroll faster to see the threshold increase!',
                  style: TextStyle(fontSize: 11, fontStyle: FontStyle.italic),
                ),
              ],
            ),
          ),
          Expanded(
            child: NotificationListener<ScrollNotification>(
              onNotification: (notification) {
                if (notification is ScrollUpdateNotification) {
                  setState(() {
                    _currentVelocity =
                        notification.metrics.pixels != 0 ? 500.0 : 0.0;
                    _threshold = 500.0 + (_currentVelocity * 0.5);
                  });
                }
                return false;
              },
              child: InfiniteScrollListView<String>.withIntelligentPreloading(
                fetchData: _mockFetchData,
                itemBuilder: (context, item) => ListTile(
                  title: Text(item),
                  trailing: const Icon(Icons.arrow_forward),
                ),
                separatorBuilder: (context, index) => const Divider(height: 1),
                preloadConfig: PreloadConfig(
                  strategy: PreloadStrategy.velocityBased,
                  velocityThreshold: 1000.0,
                  velocityMultiplier: 0.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Example 8: Adaptive preloading with performance tracking
class Example8AdaptivePreloading extends StatefulWidget {
  @override
  _Example8AdaptivePreloadingState createState() =>
      _Example8AdaptivePreloadingState();
}

class _Example8AdaptivePreloadingState extends State<Example8AdaptivePreloading> {
  final List<String> _items = List.generate(100, (i) => 'Item ${i + 1}');
  PreloadMetrics? _metrics;
  int _currentLoadTime = 500;

  Future<PaginatedData<String>> _mockFetchData(String? cursor) async {
    await Future.delayed(Duration(milliseconds: _currentLoadTime));
    final startIndex = cursor == null ? 0 : int.parse(cursor);
    final endIndex = (startIndex + 20).clamp(0, _items.length);
    final items = _items.sublist(startIndex, endIndex);

    return PaginatedData(
      items: items,
      pageInfo: PageInfo(
        currentPage: startIndex ~/ 20,
        itemsPerPage: 20,
        totalItems: _items.length,
        totalPages: (_items.length / 20).ceil(),
        hasNextPage: endIndex < _items.length,
        hasPreviousPage: startIndex > 0,
        nextCursor: endIndex < _items.length ? endIndex.toString() : null,
        previousCursor: startIndex > 0 ? startIndex.toString() : null,
      ),
    );
  }

  void _simulateSlowNetwork() {
    setState(() {
      _currentLoadTime = 2000;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Simulating slow network (2s load time)'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _simulateFastNetwork() {
    setState(() {
      _currentLoadTime = 300;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Simulating fast network (300ms load time)'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Example 8: Adaptive Preloading'),
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: Colors.indigo.shade50,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Adaptive Preloading Demo',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    ElevatedButton(
                      onPressed: _simulateSlowNetwork,
                      child: const Text('Slow Network'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: _simulateFastNetwork,
                      child: const Text('Fast Network'),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                if (_metrics != null) ...[
                  Text(
                    'Load Time: ${_currentLoadTime}ms',
                    style: const TextStyle(fontSize: 12),
                  ),
                  Text(
                    'Avg Load Time: ${_metrics!.averageLoadTime.toStringAsFixed(0)}ms',
                    style: const TextStyle(fontSize: 12),
                  ),
                  Text(
                    'Adaptive Factor: ${_metrics!.averageLoadTime > 1000 ? "0.7 (preload earlier)" : "1.3 (preload later)"}',
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ],
            ),
          ),
          Expanded(
            child: InfiniteScrollListView<String>.withIntelligentPreloading(
              fetchData: _mockFetchData,
              itemBuilder: (context, item) => ListTile(
                title: Text(item),
                subtitle: Text('Load time: $_currentLoadTime ms'),
              ),
              separatorBuilder: (context, index) => const Divider(height: 1),
              preloadConfig: PreloadConfig(
                strategy: PreloadStrategy.predictive,
                enableAdaptiveThreshold: true,
              ),
              onPreloadMetricsUpdated: (metrics) {
                setState(() {
                  _metrics = metrics;
                });
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// Main example app with navigation
class IntelligentPreloadingExamples extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Intelligent Preloading Examples'),
      ),
      body: ListView(
        children: [
          _ExampleTile(
            title: 'Example 1: Basic Intelligent Preloading',
            subtitle: 'Default configuration with predictive strategy',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const Example1BasicIntelligentPreloading(),
              ),
            ),
          ),
          _ExampleTile(
            title: 'Example 2: Aggressive Preloading',
            subtitle: 'Fast network optimization (preloads 3 pages ahead)',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const Example2AggressivePreloading(),
              ),
            ),
          ),
          _ExampleTile(
            title: 'Example 3: Conservative Preloading',
            subtitle: 'Slow network optimization (minimizes requests)',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const Example3ConservativePreloading(),
              ),
            ),
          ),
          _ExampleTile(
            title: 'Example 4: Custom Configuration',
            subtitle: 'Custom predictive settings',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const Example4CustomPreloading(),
              ),
            ),
          ),
          _ExampleTile(
            title: 'Example 5: Monitoring Metrics',
            subtitle: 'Track preload performance',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const Example5MonitoringMetrics(),
              ),
            ),
          ),
          _ExampleTile(
            title: 'Example 6: Comparing Strategies',
            subtitle: 'Interactive strategy comparison',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const Example6ComparingStrategies(),
              ),
            ),
          ),
          _ExampleTile(
            title: 'Example 7: Velocity-Based Visualization',
            subtitle: 'See velocity in action',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const Example7VelocityBased(),
              ),
            ),
          ),
          _ExampleTile(
            title: 'Example 8: Adaptive Preloading',
            subtitle: 'Automatic adjustment based on performance',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const Example8AdaptivePreloading(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ExampleTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ExampleTile({
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward),
        onTap: onTap,
      ),
    );
  }
}
