import 'package:flutter/foundation.dart';
import 'memory_aware_cache_manager.dart';

/// Example demonstrating how to use the memory-aware cache manager
///
/// This file shows common patterns for using the memory-aware cache manager
/// with automatic memory pressure detection and dynamic cache resizing.
class MemoryAwareCacheExample {
  /// Example 1: Basic usage with default configuration
  ///
  /// Shows the simplest way to use the memory-aware cache manager
  /// with automatic memory pressure detection.
  static Future<void> basicUsageExample() async {
    // Create memory-aware cache manager with default config (200 MB baseline)
    final cacheManager = MemoryAwareCacheManager<String, String>();

    // Initialize (starts memory monitoring)
    await cacheManager.initialize();

    // Use like regular cache manager
    final result = await cacheManager.get(
      'user_123',
      networkFetcher: (key) async {
        // Simulate network fetch
        return await fetchFromNetwork(key);
      },
    );

    if (result.isHit) {
      if (kDebugMode) {
        debugPrint('Data found in: ${result.source}');
        debugPrint('Value: ${result.value}');
      }
    }

    // Get memory-aware statistics
    final stats = cacheManager.getMemoryAwareStats();
    if (kDebugMode) {
      debugPrint(stats.format());
    }

    // Cleanup
    await cacheManager.dispose();
  }

  /// Example 2: Custom memory pressure thresholds
  ///
  /// Shows how to configure custom memory pressure thresholds
  /// for different use cases.
  static Future<void> customThresholdsExample() async {
    // Create cache manager with custom configuration
    final cacheManager = MemoryAwareCacheManager<String, String>(
      config: MemoryAwareCacheConfig(
        // Lower baseline for memory-constrained devices
        baselineMemoryBytes: 150 * 1024 * 1024, // 150 MB

        // Check memory more frequently
        monitoringInterval: const Duration(seconds: 3),

        // Custom cache sizes for each pressure level
        maxCacheSizeAtNoPressure: 200,
        maxCacheSizeAtLowPressure: 150,
        maxCacheSizeAtMediumPressure: 75,
        maxCacheSizeAtHighPressure: 30,
        maxCacheSizeAtCriticalPressure: 10,

        // Enable automatic resizing and cleanup
        autoResize: true,
        autoCleanupExpired: true,
      ),
    );

    await cacheManager.initialize();

    // Cache will automatically resize based on memory pressure
    for (var i = 0; i < 250; i++) {
      await cacheManager.put('item_$i', 'data_$i');
    }

    // Get current memory pressure
    final pressure = await cacheManager.checkMemoryPressure();
    if (kDebugMode) {
      debugPrint('Current memory pressure: ${pressure.name}');
    }

    await cacheManager.dispose();
  }

  /// Example 3: Listening to memory pressure changes
  ///
  /// Shows how to subscribe to memory pressure changes
  /// and react to them in your app.
  static Future<void> pressureListenerExample() async {
    final cacheManager = MemoryAwareCacheManager<String, String>();

    await cacheManager.initialize();

    // Subscribe to memory pressure changes
    final subscription = cacheManager.pressureStream.listen((pressure) {
      if (kDebugMode) {
        debugPrint('Memory pressure changed to: ${pressure.name}');

        // React to different pressure levels
        switch (pressure) {
          case MemoryPressure.none:
            debugPrint('Memory is healthy - full cache available');
            break;
          case MemoryPressure.low:
            debugPrint('Memory pressure low - reducing cache size');
            break;
          case MemoryPressure.medium:
            debugPrint('Memory pressure medium - consider freeing resources');
            break;
          case MemoryPressure.high:
            debugPrint('Memory pressure HIGH - aggressively reducing cache');
            break;
          case MemoryPressure.critical:
            debugPrint('CRITICAL memory pressure - minimal cache only');
            // Show warning to user
            break;
        }
      }
    });

    // Use cache normally - pressure changes will be emitted automatically
    await cacheManager.put('key', 'value');

    // Cancel subscription when done
    await subscription.cancel();
    await cacheManager.dispose();
  }

  /// Example 4: Manual memory pressure checks
  ///
  /// Shows how to manually check memory pressure on demand
  /// instead of relying on automatic monitoring.
  static Future<void> manualPressureCheckExample() async {
    final cacheManager = MemoryAwareCacheManager<String, String>(
      config: MemoryAwareCacheConfig(
        // Disable automatic monitoring
        autoResize: false,
      ),
    );

    await cacheManager.initialize();

    // Check memory pressure manually when needed
    final pressure = await cacheManager.checkMemoryPressure();
    if (kDebugMode) {
      debugPrint('Current pressure: ${pressure.name}');
    }

    // Get memory usage as percentage
    final usagePercentage = await cacheManager.getMemoryUsagePercentage();
    if (kDebugMode) {
      debugPrint('Memory usage: ${usagePercentage.toStringAsFixed(1)}%');
    }

    // Manually trigger cache size adjustment if needed
    if (pressure != MemoryPressure.none) {
      await cacheManager.forceAdjustCacheSize();
    }

    await cacheManager.dispose();
  }

  /// Example 5: Monitoring cache statistics
  ///
  /// Shows how to monitor and track cache statistics
  /// including memory pressure changes and evictions.
  static Future<void> statisticsExample() async {
    final cacheManager = MemoryAwareCacheManager<String, String>();

    await cacheManager.initialize();

    // Add some items to cache
    for (var i = 0; i < 100; i++) {
      await cacheManager.put('item_$i', 'data_$i');
    }

    // Get combined cache statistics
    final stats = cacheManager.getStats();
    if (kDebugMode) {
      debugPrint('Combined stats: ${stats.toString()}');
    }

    // Get memory cache statistics
    final memoryStats = cacheManager.getMemoryStats();
    if (kDebugMode) {
      debugPrint('Memory cache hit rate: ${(memoryStats.hitRate * 100).toStringAsFixed(1)}%');
      debugPrint('Memory cache size: ${memoryStats.currentSize}/${memoryStats.maxSize}');
    }

    // Get memory-aware statistics
    final memoryAwareStats = cacheManager.getMemoryAwareStats();
    if (kDebugMode) {
      debugPrint('Total memory adjustments: ${memoryAwareStats.totalAdjustments}');
      debugPrint('Total items evicted: ${memoryAwareStats.totalItemsEvicted}');
      debugPrint('Current pressure: ${memoryAwareStats.currentPressure.name}');
    }

    await cacheManager.dispose();
  }

  /// Example 6: Integration with image caching
  ///
  /// Shows how to use memory-aware cache manager for image caching
  /// with automatic memory management.
  static Future<void> imageCachingExample() async {
    // Create memory-aware cache for images
    final imageCache = MemoryAwareCacheManager<String, List<int>>(
      config: MemoryAwareCacheConfig(
        // Higher baseline for image-heavy apps
        baselineMemoryBytes: 300 * 1024 * 1024, // 300 MB

        // Larger cache sizes for images
        maxCacheSizeAtNoPressure: 200,
        maxCacheSizeAtLowPressure: 150,
        maxCacheSizeAtMediumPressure: 100,
        maxCacheSizeAtHighPressure: 50,
        maxCacheSizeAtCriticalPressure: 20,

        // Check memory every 5 seconds
        monitoringInterval: const Duration(seconds: 5),
      ),
    );

    await imageCache.initialize();

    // Cache an image
    final imageBytes = await fetchImageBytes('photo_123.jpg');
    await imageCache.put('photo_123.jpg', imageBytes);

    // Retrieve image (with memory-efficient automatic resizing)
    final result = await imageCache.get(
      'photo_123.jpg',
      networkFetcher: (key) async {
        return await fetchImageBytes(key);
      },
    );

    if (result.isHit && kDebugMode) {
      debugPrint('Image found in: ${result.source}');
      debugPrint('Image size: ${result.value!.length} bytes');
    }

    // Monitor pressure changes
    imageCache.pressureStream.listen((pressure) {
      if (pressure == MemoryPressure.critical) {
        // Consider showing UI warning
        if (kDebugMode) {
          debugPrint('WARNING: Critical memory pressure - image cache reduced');
        }
      }
    });

    await imageCache.dispose();
  }

  /// Example 7: Prefetching with memory awareness
  ///
  /// Shows how to prefetch data while respecting memory constraints.
  static Future<void> prefetchingExample() async {
    final cacheManager = MemoryAwareCacheManager<String, String>();

    await cacheManager.initialize();

    // Check memory pressure before prefetching
    final pressure = await cacheManager.checkMemoryPressure();

    // Only prefetch if memory is healthy
    if (pressure == MemoryPressure.none || pressure == MemoryPressure.low) {
      // Prefetch next 20 items
      final keysToPrefetch = List.generate(20, (i) => 'item_${i}');

      await cacheManager.prefetch(
        keysToPrefetch,
        networkFetcher: (key) async {
          return await fetchFromNetwork(key);
        },
      );

      if (kDebugMode) {
        debugPrint('Prefetched ${keysToPrefetch.length} items');
      }
    } else {
      if (kDebugMode) {
        debugPrint('Skipping prefetch due to memory pressure: ${pressure.name}');
      }
    }

    await cacheManager.dispose();
  }

  /// Example 8: Force cache adjustment on demand
  ///
  /// Shows how to manually trigger cache size adjustment
  /// for proactive memory management.
  static Future<void> forceAdjustmentExample() async {
    final cacheManager = MemoryAwareCacheManager<String, String>(
      config: MemoryAwareCacheConfig(
        // Disable automatic resizing
        autoResize: false,
      ),
    );

    await cacheManager.initialize();

    // Fill cache with data
    for (var i = 0; i < 200; i++) {
      await cacheManager.put('item_$i', 'data_$i');
    }

    // Manually trigger memory pressure check and adjustment
    // Useful before memory-intensive operations
    await cacheManager.forceAdjustCacheSize();

    if (kDebugMode) {
      final stats = cacheManager.getMemoryAwareStats();
      debugPrint('After force adjustment:');
      debugPrint('  Pressure: ${stats.currentPressure.name}');
      debugPrint('  Items evicted: ${stats.totalItemsEvicted}');
    }

    await cacheManager.dispose();
  }

  /// Helper: Simulate network fetch
  static Future<String> fetchFromNetwork(String key) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 100));
    return 'data_for_$key';
  }

  /// Helper: Simulate image byte fetch
  static Future<List<int>> fetchImageBytes(String key) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 200));
    // Return dummy image data
    return List.generate(1024, (i) => i % 256);
  }
}
