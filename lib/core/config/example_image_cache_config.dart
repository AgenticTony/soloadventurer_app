import 'package:flutter/material.dart';
import 'package:soloadventurer/core/config/image_cache_config.dart';
import 'package:soloadventurer/core/widgets/lazy_load_image.dart';

/// Examples demonstrating the usage of ImageCacheConfig for optimizing
/// image caching in Flutter applications.
///
/// This file contains practical examples for:
/// - Initializing image cache configuration
/// - Managing cache (clearing, monitoring)
/// - Using memory cache dimensions
/// - Device-specific configuration
/// - Cache statistics and debugging
///
/// To run these examples, create a Flutter app and navigate to
/// the example screens using the provided routes.

/// Main example app with navigation to all examples
class ImageCacheConfigExamples extends StatelessWidget {
  const ImageCacheConfigExamples({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Image Cache Config Examples',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const ExampleHomeScreen(),
      routes: {
        '/basic_initialization': (_) => const BasicInitializationExample(),
        '/cache_management': (_) => const CacheManagementExample(),
        '/cache_statistics': (_) => const CacheStatisticsExample(),
        '/device_specific': (_) => const DeviceSpecificConfigExample(),
        '/memory_dimensions': (_) => const MemoryDimensionsExample(),
        '/integration': (_) => const IntegrationExample(),
      },
    );
  }
}

/// Home screen with list of examples
class ExampleHomeScreen extends StatelessWidget {
  const ExampleHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ImageCacheConfig Examples'),
      ),
      body: ListView(
        children: [
          _ExampleTile(
            title: 'Basic Initialization',
            description: 'Initialize cache with default settings',
            route: '/basic_initialization',
          ),
          _ExampleTile(
            title: 'Cache Management',
            description: 'Clear memory and disk caches',
            route: '/cache_management',
          ),
          _ExampleTile(
            title: 'Cache Statistics',
            description: 'Monitor cache usage and statistics',
            route: '/cache_statistics',
          ),
          _ExampleTile(
            title: 'Device-Specific Config',
            description: 'Configure cache based on device capabilities',
            route: '/device_specific',
          ),
          _ExampleTile(
            title: 'Memory Dimensions',
            description: 'Calculate optimal cache dimensions',
            route: '/memory_dimensions',
          ),
          _ExampleTile(
            title: 'Integration Example',
            description: 'Complete integration with LazyLoadImage',
            route: '/integration',
          ),
        ],
      ),
    );
  }
}

class _ExampleTile extends StatelessWidget {
  final String title;
  final String description;
  final String route;

  const _ExampleTile({
    required this.title,
    required this.description,
    required this.route,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(title),
      subtitle: Text(description),
      trailing: const Icon(Icons.arrow_forward),
      onTap: () => Navigator.pushNamed(context, route),
    );
  }
}

/// Example 1: Basic Initialization
///
/// Demonstrates how to initialize the image cache with default settings
/// in your app's bootstrap process.
class BasicInitializationExample extends StatefulWidget {
  const BasicInitializationExample({super.key});

  @override
  State<BasicInitializationExample> createState() =>
      _BasicInitializationExampleState();
}

class _BasicInitializationExampleState
    extends State<BasicInitializationExample> {
  bool _initialized = false;
  String _status = 'Not initialized';

  @override
  void initState() {
    super.initState();
    _initializeCache();
  }

  Future<void> _initializeCache() async {
    try {
      // Initialize with default settings
      await ImageCacheConfig.initialize();

      setState(() {
        _initialized = true;
        _status = 'Initialized successfully!\n\n'
            'Settings:\n'
            '• Memory Cache: 150 MB\n'
            '• Disk Cache: 500 MB\n'
            '• Max Images: 200';
      });
    } catch (e) {
      setState(() {
        _status = 'Initialization failed: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Basic Initialization'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _initialized ? Icons.check_circle : Icons.hourglass_empty,
              size: 64,
              color: _initialized ? Colors.green : Colors.orange,
            ),
            const SizedBox(height: 24),
            Text(
              _status,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 24),
            const Text(
              'Add this to your bootstrap.dart:\n\n'
              'await ImageCacheConfig.initialize();',
              style: TextStyle(fontFamily: 'monospace'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Example 2: Cache Management
///
/// Demonstrates how to clear memory and disk caches.
class CacheManagementExample extends StatefulWidget {
  const CacheManagementExample({super.key});

  @override
  State<CacheManagementExample> createState() =>
      _CacheManagementExampleState();
}

class _CacheManagementExampleState extends State<CacheManagementExample> {
  bool _clearing = false;
  String _status = 'Ready to clear caches';

  Future<void> _clearMemoryCache() async {
    setState(() {
      _clearing = true;
      _status = 'Clearing memory cache...';
    });

    try {
      await ImageCacheConfig.clearMemoryCache();
      setState(() {
        _status = 'Memory cache cleared!';
      });
    } catch (e) {
      setState(() {
        _status = 'Error: $e';
      });
    } finally {
      setState(() {
        _clearing = false;
      });
    }
  }

  Future<void> _clearDiskCache() async {
    setState(() {
      _clearing = true;
      _status = 'Clearing disk cache...';
    });

    try {
      await ImageCacheConfig.clearDiskCache();
      setState(() {
        _status = 'Disk cache cleared!';
      });
    } catch (e) {
      setState(() {
        _status = 'Error: $e';
      });
    } finally {
      setState(() {
        _clearing = false;
      });
    }
  }

  Future<void> _clearAllCaches() async {
    setState(() {
      _clearing = true;
      _status = 'Clearing all caches...';
    });

    try {
      await ImageCacheConfig.clearAllCaches();
      setState(() {
        _status = 'All caches cleared!';
      });
    } catch (e) {
      setState(() {
        _status = 'Error: $e';
      });
    } finally {
      setState(() {
        _clearing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cache Management'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _status,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _clearing ? null : _clearMemoryCache,
              child: const Text('Clear Memory Cache'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _clearing ? null : _clearDiskCache,
              child: const Text('Clear Disk Cache'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _clearing ? null : _clearAllCaches,
              child: const Text('Clear All Caches'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Example 3: Cache Statistics
///
/// Demonstrates how to retrieve and display cache statistics.
class CacheStatisticsExample extends StatefulWidget {
  const CacheStatisticsExample({super.key});

  @override
  State<CacheStatisticsExample> createState() =>
      _CacheStatisticsExampleState();
}

class _CacheStatisticsExampleState extends State<CacheStatisticsExample> {
  ImageCacheStats? _stats;
  bool _loading = false;

  Future<void> _loadStats() async {
    setState(() {
      _loading = true;
    });

    try {
      final stats = await ImageCacheConfig.getCacheStats();
      setState(() {
        _stats = stats;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cache Statistics'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loading ? null : _loadStats,
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _stats == null
              ? const Center(child: Text('Failed to load statistics'))
              : ListView(
                  padding: const EdgeInsets.all(16.0),
                  children: [
                    _StatCard(
                      title: 'Memory Cache Size',
                      value: _stats!.formattedMemoryCacheSize,
                      icon: Icons.memory,
                    ),
                    _StatCard(
                      title: 'Cached Images',
                      value: '${_stats!.memoryCacheCount}',
                      icon: Icons.image,
                    ),
                    _StatCard(
                      title: 'Avg Memory per Image',
                      value: _formatBytes(_stats!.averageMemoryPerImage.toInt()),
                      icon: Icons.calculate,
                    ),
                    _StatCard(
                      title: 'Disk Cache Size',
                      value: _stats!.formattedDiskCacheSize,
                      icon: Icons.storage,
                    ),
                    _StatCard(
                      title: 'Initialized',
                      value: _stats!.isInitialized ? 'Yes' : 'No',
                      icon: Icons.check_circle,
                    ),
                  ],
                ),
    );
  }

  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        subtitle: Text(
          value,
          style: Theme.of(context).textTheme.headlineSmall,
        ),
      ),
    );
  }
}

/// Example 4: Device-Specific Configuration
///
/// Demonstrates how to configure cache settings based on device capabilities.
class DeviceSpecificConfigExample extends StatefulWidget {
  const DeviceSpecificConfigExample({super.key});

  @override
  State<DeviceSpecificConfigExample> createState() =>
      _DeviceSpecificConfigExampleState();
}

class _DeviceSpecificConfigExampleState
    extends State<DeviceSpecificConfigExample> {
  String _selectedDevice = 'mid_range';
  String _status = 'Select a device type to configure cache';

  final Map<String, Map<String, dynamic>> _deviceConfigs = {
    'low_end': {
      'name': 'Low-End Device',
      'memory': 50 * 1024 * 1024, // 50 MB
      'disk': 200 * 1024 * 1024, // 200 MB
      'images': 50,
    },
    'mid_range': {
      'name': 'Mid-Range Device',
      'memory': 150 * 1024 * 1024, // 150 MB
      'disk': 500 * 1024 * 1024, // 500 MB
      'images': 200,
    },
    'high_end': {
      'name': 'High-End Device',
      'memory': 300 * 1024 * 1024, // 300 MB
      'disk': 1024 * 1024 * 1024, // 1 GB
      'images': 500,
    },
  };

  Future<void> _configureForDevice(String deviceType) async {
    final config = _deviceConfigs[deviceType]!;
    setState(() {
      _status = 'Configuring for ${config['name']}...';
    });

    try {
      await ImageCacheConfig.initialize(
        maxMemoryCacheBytes: config['memory'] as int,
        maxDiskCacheBytes: config['disk'] as int,
        maxMemoryCacheImages: config['images'] as int,
      );

      setState(() {
        _status = 'Configured for ${config['name']}!\n\n'
            '• Memory: ${_formatBytes(config['memory'] as int)}\n'
            '• Disk: ${_formatBytes(config['disk'] as int)}\n'
            '• Images: ${config['images']}';
      });
    } catch (e) {
      setState(() {
        _status = 'Error: $e';
      });
    }
  }

  String _formatBytes(int bytes) {
    if (bytes < 1024 * 1024) return '${bytes ~/ (1024)} MB';
    return '${bytes ~/ (1024 * 1024)} MB';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Device-Specific Config'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            DropdownButtonFormField<String>(
              value: _selectedDevice,
              decoration: const InputDecoration(
                labelText: 'Device Type',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(
                  value: 'low_end',
                  child: Text('Low-End Device (< 2GB RAM)'),
                ),
                DropdownMenuItem(
                  value: 'mid_range',
                  child: Text('Mid-Range Device (2-4GB RAM)'),
                ),
                DropdownMenuItem(
                  value: 'high_end',
                  child: Text('High-End Device (> 4GB RAM)'),
                ),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedDevice = value;
                  });
                }
              },
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => _configureForDevice(_selectedDevice),
              child: const Text('Apply Configuration'),
            ),
            const SizedBox(height: 24),
            Text(
              _status,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
        ),
      ),
    );
  }
}

/// Example 5: Memory Dimensions
///
/// Demonstrates how to calculate optimal memory cache dimensions.
class MemoryDimensionsExample extends StatelessWidget {
  const MemoryDimensionsExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Memory Dimensions'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          const Text(
            'Memory cache dimensions reduce memory usage by caching images '
            'at a resolution slightly higher than the display size.',
            style: TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 24),
          _DimensionCard(
            title: 'Thumbnail (48x48)',
            displaySize: 48.0,
          ),
          _DimensionCard(
            title: 'Photo Grid (100x100)',
            displaySize: 100.0,
          ),
          _DimensionCard(
            title: 'Card Image (200x300)',
            displayWidth: 300.0,
            displayHeight: 200.0,
          ),
          _DimensionCard(
            title: 'Full Width (screen width x 200)',
            displayWidth: MediaQuery.of(context).size.width,
            displayHeight: 200.0,
          ),
        ],
      ),
    );
  }
}

class _DimensionCard extends StatelessWidget {
  final String title;
  final double? displaySize;
  final double? displayWidth;
  final double? displayHeight;

  const _DimensionCard({
    required this.title,
    this.displaySize,
    this.displayWidth,
    this.displayHeight,
  });

  @override
  Widget build(BuildContext context) {
    final width = displayWidth ?? displaySize ?? 100.0;
    final height = displayHeight ?? displaySize ?? 100.0;

    final dimensions = ImageCacheConfig.getMemoryCacheDimensions(
      width,
      height,
      pixelRatio: MediaQuery.of(context).devicePixelRatio,
    );

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text('Display: ${width.toInt()}x${height.toInt()}'),
            Text('Cache: ${dimensions.width}x${dimensions.height}'),
            Text(
              'Memory saved: ~${_calculateSavings(width, height, dimensions.width, dimensions.height)}',
              style: TextStyle(color: Colors.green[700]),
            ),
          ],
        ),
      ),
    );
  }

  String _calculateSavings(double displayW, double displayH, int cacheW, int cacheH) {
    final displayPixels = displayW * displayH;
    final fullResPixels = displayW * displayH * 4 * 4; // 4x for typical device pixel ratio
    final cachePixels = (cacheW * cacheH).toDouble();
    final savings = 1 - (cachePixels / fullResPixels);
    return '${(savings * 100).toStringAsFixed(0)}%';
  }
}

/// Example 6: Integration with LazyLoadImage
///
/// Demonstrates complete integration with LazyLoadImage widget.
class IntegrationExample extends StatelessWidget {
  const IntegrationExample({super.key});

  static const sampleImages = [
    'https://picsum.photos/200/200?random=1',
    'https://picsum.photos/200/200?random=2',
    'https://picsum.photos/200/200?random=3',
    'https://picsum.photos/200/200?random=4',
    'https://picsum.photos/200/200?random=5',
    'https://picsum.photos/200/200?random=6',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Integration Example'),
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(8.0),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 8.0,
          mainAxisSpacing: 8.0,
        ),
        itemCount: sampleImages.length,
        itemBuilder: (context, index) {
          return LazyLoadImage.photo(
            key: ValueKey(index),
            imageUrl: sampleImages[index],
            size: 150.0,
          );
        },
      ),
    );
  }
}
