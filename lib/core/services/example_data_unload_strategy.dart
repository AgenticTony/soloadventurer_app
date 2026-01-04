import 'package:flutter/material.dart';
import 'package:soloadventurer/core/services/data_unload_strategy.dart';
import 'package:soloadventurer/core/services/memory_monitor.dart';

/// Example 1: Basic Registration and Tracking
///
/// Demonstrates how to register data entries and track visibility.
class Example1BasicRegistration extends StatelessWidget {
  const Example1BasicRegistration({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Example 1: Basic Registration')),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            // Register a trip data entry
            DataUnloadStrategy.register(
              DataEntry(
                id: 'trip_123',
                dataType: 'trip',
                priority: DataPriority.high,
                estimatedSizeBytes: 5 * 1024 * 1024, // 5 MB
                unloadCallback: () async {
                  // Clear trip data when unloaded
                  debugPrint('Unloading trip_123');
                },
                metadata: {'title': 'Europe Adventure'},
              ),
            );

            // Mark as visible
            DataUnloadStrategy.markVisible('trip_123');

            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Registered trip_123')),
            );
          },
          child: const Text('Register Trip Data'),
        ),
      ),
    );
  }
}

/// Example 2: Priority-Based Unloading
///
/// Shows how different priority levels affect unload order.
class Example2PriorityBasedUnloading extends StatefulWidget {
  const Example2PriorityBasedUnloading({super.key});

  @override
  State<Example2PriorityBasedUnloading> createState() =>
      _Example2PriorityBasedUnloadingState();
}

class _Example2PriorityBasedUnloadingState
    extends State<Example2PriorityBasedUnloading> {
  String _status = 'No unload performed yet';

  Future<void> _registerEntries() async {
    // Register entries with different priorities
    final entries = [
      DataEntry(
        id: 'critical_trip',
        dataType: 'trip',
        priority: DataPriority.critical,
        estimatedSizeBytes: 10 * 1024 * 1024,
        unloadCallback: () => debugPrint('Unloading critical_trip'),
      ),
      DataEntry(
        id: 'high_priority_trip',
        dataType: 'trip',
        priority: DataPriority.high,
        estimatedSizeBytes: 5 * 1024 * 1024,
        unloadCallback: () => debugPrint('Unloading high_priority_trip'),
      ),
      DataEntry(
        id: 'normal_trip',
        dataType: 'trip',
        priority: DataPriority.normal,
        estimatedSizeBytes: 3 * 1024 * 1024,
        unloadCallback: () => debugPrint('Unloading normal_trip'),
      ),
      DataEntry(
        id: 'low_priority_trip',
        dataType: 'trip',
        priority: DataPriority.low,
        estimatedSizeBytes: 2 * 1024 * 1024,
        unloadCallback: () => debugPrint('Unloading low_priority_trip'),
      ),
    ];

    for (final entry in entries) {
      DataUnloadStrategy.register(entry);
    }

    setState(() {
      _status = 'Registered 4 entries with different priorities';
    });
  }

  Future<void> _performUnload() async {
    final result = await DataUnloadStrategy.unloadOffScreenData(
      targetFreeBytes: 5 * 1024 * 1024, // 5 MB
      maxPriority: DataPriority.normal, // Don't unload critical
    );

    setState(() {
      _status = '''
Unloaded: ${result.entriesUnloaded} entries
Memory freed: ${result.memoryFreedMB.toStringAsFixed(2)} MB
Duration: ${result.duration.inMilliseconds}ms
Failed: ${result.failedUnloads}
''';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Example 2: Priority-Based Unloading')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_status, textAlign: TextAlign.center),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _registerEntries,
              child: const Text('Register Entries'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _performUnload,
              child: const Text('Perform Unload'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Example 3: Visibility-Based Unloading
///
/// Demonstrates how visibility tracking affects unload decisions.
class Example3VisibilityBasedUnloading extends StatefulWidget {
  const Example3VisibilityBasedUnloading({super.key});

  @override
  State<Example3VisibilityBasedUnloading> createState() =>
      _Example3VisibilityBasedUnloadingState();
}

class _Example3VisibilityBasedUnloadingState
    extends State<Example3VisibilityBasedUnloading> {
  bool _isVisible = false;
  String _status = 'Entry is off-screen';

  @override
  void initState() {
    super.initState();
    _registerEntry();
  }

  void _registerEntry() {
    DataUnloadStrategy.register(
      DataEntry(
        id: 'visible_trip',
        dataType: 'trip',
        priority: DataPriority.normal,
        estimatedSizeBytes: 5 * 1024 * 1024,
        isVisible: _isVisible,
        unloadCallback: () async {
          debugPrint('Unloading visible_trip');
        },
      ),
    );
  }

  void _toggleVisibility() {
    setState(() {
      _isVisible = !_isVisible;
      if (_isVisible) {
        DataUnloadStrategy.markVisible('visible_trip');
        _status = 'Entry is visible (protected)';
      } else {
        DataUnloadStrategy.markOffScreen('visible_trip');
        _status = 'Entry is off-screen (can be unloaded)';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Example 3: Visibility-Based Unloading')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_status),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _toggleVisibility,
              child: Text(_isVisible ? 'Mark Off-Screen' : 'Mark Visible'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Example 4: Manual Unload Operations
///
/// Shows how to manually trigger unloads with different parameters.
class Example4ManualUnload extends StatefulWidget {
  const Example4ManualUnload({super.key});

  @override
  State<Example4ManualUnload> createState() => _Example4ManualUnloadState();
}

class _Example4ManualUnloadState extends State<Example4ManualUnload> {
  String _result = 'No unload performed';

  Future<void> _unloadConservative() async {
    final result = await DataUnloadStrategy.unloadOffScreenData(
      targetFreeBytes: 10 * 1024 * 1024, // 10 MB
      onlyOffScreen: true,
      maxPriority: DataPriority.low, // Only unload low priority
    );

    setState(() {
      _result = '''
Conservative Unload:
- Unloaded: ${result.entriesUnloaded}
- Freed: ${result.memoryFreedMB.toStringAsFixed(2)} MB
- Duration: ${result.duration.inMilliseconds}ms
''';
    });
  }

  Future<void> _unloadAggressive() async {
    final result = await DataUnloadStrategy.unloadOffScreenData(
      targetFreeBytes: 50 * 1024 * 1024, // 50 MB
      onlyOffScreen: false, // Unload visible too
      maxPriority: DataPriority.normal, // Unload normal priority
    );

    setState(() {
      _result = '''
Aggressive Unload:
- Unloaded: ${result.entriesUnloaded}
- Freed: ${result.memoryFreedMB.toStringAsFixed(2)} MB
- Duration: ${result.duration.inMilliseconds}ms
''';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Example 4: Manual Unload')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_result, textAlign: TextAlign.center),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _unloadConservative,
              child: const Text('Conservative Unload (10 MB)'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _unloadAggressive,
              child: const Text('Aggressive Unload (50 MB)'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Example 5: Statistics and Monitoring
///
/// Shows how to monitor unload statistics and history.
class Example5StatisticsMonitoring extends StatefulWidget {
  const Example5StatisticsMonitoring({super.key});

  @override
  State<Example5StatisticsMonitoring> createState() =>
      _Example5StatisticsMonitoringState();
}

class _Example5StatisticsMonitoringState extends State<Example5StatisticsMonitoring> {
  String _stats = 'No statistics yet';

  void _loadStatistics() {
    final stats = DataUnloadStrategy.getStatistics();
    final entryCount = DataUnloadStrategy.instance.entries.length;

    setState(() {
      _stats = '''
Unload Statistics:
- Total unloads: ${stats.totalUnloads}
- Total entries: ${stats.totalEntriesUnloaded}
- Total freed: ${stats.totalMemoryFreedMB.toStringAsFixed(2)} MB
- Avg freed: ${stats.averageMemoryFreedMB.toStringAsFixed(2)} MB
- Failed: ${stats.totalFailedUnloads}
- Avg duration: ${stats.averageDuration.inMilliseconds}ms
- Last unload: ${stats.lastUnloadTime ?? 'Never'}
- Tracked entries: $entryCount
''';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Example 5: Statistics')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_stats, textAlign: TextAlign.center),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _loadStatistics,
              child: const Text('Load Statistics'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Example 6: Integration with Virtual Lists
///
/// Shows how to integrate data unload with virtual scrolling lists.
class Example6VirtualListIntegration extends StatefulWidget {
  const Example6VirtualListIntegration({super.key});

  @override
  State<Example6VirtualListIntegration> createState() =>
      _Example6VirtualListIntegrationState();
}

class _Example6VirtualListIntegrationState
    extends State<Example6VirtualListIntegration> {
  final List<String> _tripIds = List.generate(100, (i) => 'trip_$i');

  @override
  void initState() {
    super.initState();
    _registerAllTrips();
  }

  void _registerAllTrips() {
    for (final tripId in _tripIds) {
      DataUnloadStrategy.register(
        DataEntry(
          id: tripId,
          dataType: 'trip',
          priority: DataPriority.normal,
          estimatedSizeBytes: 1024 * 1024, // 1 MB per trip
          unloadCallback: () async {
            debugPrint('Unloading $tripId');
          },
        ),
      );
    }
  }

  void _onTripVisible(String tripId) {
    DataUnloadStrategy.markVisible(tripId);
    DataUnloadStrategy.updateAccessTime(tripId);
  }

  void _onTripOffScreen(String tripId) {
    DataUnloadStrategy.markOffScreen(tripId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Example 6: Virtual List Integration')),
      body: ListView.builder(
        itemCount: _tripIds.length,
        itemBuilder: (context, index) {
          final tripId = _tripIds[index];
          return ListTile(
            title: Text('Trip ${index + 1}'),
            subtitle: Text(tripId),
            onTap: () {
              _onTripVisible(tripId);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Marked $tripId as visible')),
              );
            },
            onLongPress: () {
              _onTripOffScreen(tripId);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Marked $tripId as off-screen')),
              );
            },
          );
        },
      ),
    );
  }
}

/// Example 7: Integration with Photo Galleries
///
/// Demonstrates data unload for photo gallery with many images.
class Example7PhotoGalleryIntegration extends StatefulWidget {
  const Example7PhotoGalleryIntegration({super.key});

  @override
  State<Example7PhotoGalleryIntegration> createState() =>
      _Example7PhotoGalleryIntegrationState();
}

class _Example7PhotoGalleryIntegrationState
    extends State<Example7PhotoGalleryIntegration> {
  final List<String> _photoIds = List.generate(100, (i) => 'photo_$i');

  @override
  void initState() {
    super.initState();
    _registerPhotoGallery();
  }

  void _registerPhotoGallery() {
    // Register entire gallery as one entry
    DataUnloadStrategy.register(
      DataEntry(
        id: 'gallery_trip_123',
        dataType: 'photo_gallery',
        priority: DataPriority.high,
        estimatedSizeBytes: 50 * 1024 * 1024, // 50 MB for gallery
        unloadCallback: () async {
          debugPrint('Unloading photo gallery');
          // Here you would clear the gallery from memory
        },
      ),
    );
  }

  void _markGalleryVisible() {
    DataUnloadStrategy.markVisible('gallery_trip_123');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Gallery marked as visible')),
    );
  }

  void _markGalleryOffScreen() {
    DataUnloadStrategy.markOffScreen('gallery_trip_123');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Gallery marked as off-screen')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Example 7: Photo Gallery')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: _markGalleryVisible,
                  child: const Text('Mark Visible'),
                ),
                ElevatedButton(
                  onPressed: _markGalleryOffScreen,
                  child: const Text('Mark Off-Screen'),
                ),
              ],
            ),
          ),
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
              ),
              itemCount: _photoIds.length,
              itemBuilder: (context, index) {
                return Container(
                  color: Colors.primaries[index % Colors.primaries.length],
                  child: Center(
                    child: Text(
                      'Photo ${index + 1}',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// Example 8: Advanced Configuration
///
/// Shows how to configure the data unload strategy for different scenarios.
class Example8AdvancedConfiguration extends StatefulWidget {
  const Example8AdvancedConfiguration({super.key});

  @override
  State<Example8AdvancedConfiguration> createState() =>
      _Example8AdvancedConfigurationState();
}

class _Example8AdvancedConfigurationState
    extends State<Example8AdvancedConfiguration> {
  String _currentConfig = 'Default';

  void _applyLowMemoryConfig() {
    DataUnloadStrategy.updateConfig(
      const DataUnloadConfig(
        autoUnloadOnWarning: true,
        autoUnloadOnCritical: true,
        targetFreePercentageWarning: 0.2, // More aggressive
        targetFreePercentageCritical: 0.5, // Very aggressive
        maxUnloadDuration: Duration(milliseconds: 50), // Quick
      ),
    );

    setState(() {
      _currentConfig = 'Low Memory Device';
    });
  }

  void _applyHighMemoryConfig() {
    DataUnloadStrategy.updateConfig(
      const DataUnloadConfig(
        autoUnloadOnWarning: false, // Don't unload at warning
        autoUnloadOnCritical: true,
        targetFreePercentageWarning: 0.05, // Conservative
        targetFreePercentageCritical: 0.2, // Moderate
        maxUnloadDuration: Duration(milliseconds: 200), // More time
      ),
    );

    setState(() {
      _currentConfig = 'High Memory Device';
    });
  }

  void _applyDefaultConfig() {
    DataUnloadStrategy.updateConfig(
      const DataUnloadConfig(),
    );

    setState(() {
      _currentConfig = 'Default';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Example 8: Advanced Configuration')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Current Config: $_currentConfig'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _applyDefaultConfig,
              child: const Text('Default Config'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _applyLowMemoryConfig,
              child: const Text('Low Memory Device'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _applyHighMemoryConfig,
              child: const Text('High Memory Device'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Main example app with navigation to all examples
class DataUnloadStrategyExamples extends StatelessWidget {
  const DataUnloadStrategyExamples({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Data Unload Strategy Examples',
      home: const ExamplesHome(),
      routes: {
        '/example1': (context) => const Example1BasicRegistration(),
        '/example2': (context) => const Example2PriorityBasedUnloading(),
        '/example3': (context) => const Example3VisibilityBasedUnloading(),
        '/example4': (context) => const Example4ManualUnload(),
        '/example5': (context) => const Example5StatisticsMonitoring(),
        '/example6': (context) => const Example6VirtualListIntegration(),
        '/example7': (context) => const Example7PhotoGalleryIntegration(),
        '/example8': (context) => const Example8AdvancedConfiguration(),
      },
    );
  }
}

class ExamplesHome extends StatelessWidget {
  const ExamplesHome({super.key});

  @override
  Widget build(BuildContext context) {
    final examples = [
      ('Example 1: Basic Registration', '/example1'),
      ('Example 2: Priority-Based Unloading', '/example2'),
      ('Example 3: Visibility-Based Unloading', '/example3'),
      ('Example 4: Manual Unload Operations', '/example4'),
      ('Example 5: Statistics and Monitoring', '/example5'),
      ('Example 6: Virtual List Integration', '/example6'),
      ('Example 7: Photo Gallery Integration', '/example7'),
      ('Example 8: Advanced Configuration', '/example8'),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Data Unload Strategy Examples'),
      ),
      body: ListView.builder(
        itemCount: examples.length,
        itemBuilder: (context, index) {
          final (title, route) = examples[index];
          return ListTile(
            title: Text(title),
            trailing: const Icon(Icons.arrow_forward),
            onTap: () => Navigator.pushNamed(context, route),
          );
        },
      ),
    );
  }
}
