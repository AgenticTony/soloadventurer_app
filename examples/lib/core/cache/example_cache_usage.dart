import 'cache_manager.dart';
import 'memory_cache.dart';
import 'disk_cache.dart';

/// Example demonstrating how to use the multi-layer cache system
///
/// This file shows common patterns for using the cache manager
/// with different data types and strategies.
class CacheUsageExample {
  /// Example 1: Basic cache usage with network fallback
  ///
  /// Shows the simplest way to use the cache manager with automatic
  /// fallback through memory → disk → network.
  static Future<void> basicUsageExample() async {
    // Create cache manager
    final cacheManager = CacheManager<String, String>(
      config: const CacheManagerConfig(
        memoryConfig: MemoryCacheConfig(maxSize: 100),
        diskConfig: DiskCacheConfig(maxCacheSize: 50 * 1024 * 1024),
      ),
    );

    // Initialize
    await cacheManager.initialize();

    // Get data with network fallback
    final result = await cacheManager.get(
      'user_123',
      networkFetcher: (key) async {
        // Simulate network fetch
        return await fetchFromNetwork(key);
      },
    );

    if (result.isHit) {
      print('Data found in: ${result.source}');
      print('Value: ${result.value}');
    } else {
      print('Data not available');
    }

    // Cleanup
    await cacheManager.dispose();
  }

  /// Example 2: Prefetching for better performance
  ///
  /// Shows how to warm up the cache before displaying data.
  static Future<void> prefetchExample() async {
    final cacheManager = CacheManager<String, String>();

    await cacheManager.initialize();

    // Prefetch multiple keys
    await cacheManager.prefetch(
      ['user_1', 'user_2', 'user_3', 'user_4', 'user_5'],
      (key) async {
        return await fetchFromNetwork(key);
      },
    );

    // Now all data is cached and will load instantly
    for (final key in ['user_1', 'user_2', 'user_3', 'user_4', 'user_5']) {
      final result = await cacheManager.get(
        key,
        networkFetcher: (k) async => await fetchFromNetwork(k),
      );
      print('$key: ${result.source}'); // Should print "memory"
    }

    await cacheManager.dispose();
  }

  /// Example 3: Using different cache strategies
  ///
  /// Shows how to use different cache strategies for different scenarios.
  static Future<void> strategyExample() async {
    final cacheManager = CacheManager<String, String>();

    await cacheManager.initialize();

    // Force refresh from network (ignore cache)
    final freshData = await cacheManager.get(
      'user_123',
      networkFetcher: (key) async => await fetchFromNetwork(key),
      strategy: CacheStrategy.forceRefresh,
    );

    // Cache only (no network request)
    final cachedData = await cacheManager.get(
      'user_123',
      networkFetcher: (key) async => await fetchFromNetwork(key),
      strategy: CacheStrategy.cacheOnly,
    );

    if (cachedData.isMiss) {
      print('Data not in cache');
    }

    await cacheManager.dispose();
  }

  /// Example 4: Using TTL for time-based expiration
  ///
  /// Shows how to use time-to-live for automatic cache expiration.
  static Future<void> ttlExample() async {
    final cacheManager = CacheManager<String, String>();

    await cacheManager.initialize();

    // Cache for 5 minutes
    await cacheManager.put(
      'temp_data',
      'value',
      memoryTtl: const Duration(minutes: 5),
      diskTtl: const Duration(hours: 24),
    );

    // Data will be available for 5 minutes in memory
    final result = await cacheManager.get(
      'temp_data',
      networkFetcher: (key) async => await fetchFromNetwork(key),
    );

    await cacheManager.dispose();
  }

  /// Example 5: Cache invalidation
  ///
  /// Shows how to invalidate cache entries when data changes.
  static Future<void> invalidationExample() async {
    final cacheManager = CacheManager<String, String>();

    await cacheManager.initialize();

    // Invalidate specific key
    await cacheManager.invalidate('user_123');

    // Invalidate multiple keys
    await cacheManager.invalidateMultiple(['user_1', 'user_2', 'user_3']);

    // Invalidate using predicate
    await cacheManager.invalidateWhere((key) => key.startsWith('temp_'));

    // Clear all caches
    await cacheManager.clearAll();

    // Clear only memory cache (keep disk cache)
    cacheManager.clearMemory();

    // Clear only disk cache (keep memory cache)
    await cacheManager.clearDisk();

    await cacheManager.dispose();
  }

  /// Example 6: Monitoring cache performance
  ///
  /// Shows how to track cache statistics to optimize performance.
  static Future<void> statisticsExample() async {
    final cacheManager = CacheManager<String, String>();

    await cacheManager.initialize();

    // Perform some operations
    await cacheManager.get(
      'user_123',
      networkFetcher: (key) async => await fetchFromNetwork(key),
    );

    // Get combined statistics
    final stats = cacheManager.getStats();
    print(
        'Overall hit rate: ${(stats.overallHitRate * 100).toStringAsFixed(1)}%');
    print(
        'Memory cache: ${(stats.memoryCacheHitPercent * 100).toStringAsFixed(1)}%');
    print(
        'Disk cache: ${(stats.diskCacheHitPercent * 100).toStringAsFixed(1)}%');
    print(
        'Network: ${(stats.networkRequestPercent * 100).toStringAsFixed(1)}%');

    // Get individual layer statistics
    final memoryStats = cacheManager.getMemoryStats();
    print(
        'Memory hit rate: ${(memoryStats.hitRate * 100).toStringAsFixed(1)}%');
    print('Memory evictions: ${memoryStats.evictionCount}');

    final diskStats = cacheManager.getDiskStats();
    print('Disk hit rate: ${(diskStats.hitRate * 100).toStringAsFixed(1)}%');
    print('Disk size: ${diskStats.currentSize} bytes');

    // Reset statistics
    cacheManager.resetStats();

    await cacheManager.dispose();
  }

  /// Example 7: Using getOrPut for lazy loading
  ///
  /// Shows how to use getOrPut for convenient cache-aside pattern.
  static Future<void> getOrPutExample() async {
    final cacheManager = CacheManager<String, String>();

    await cacheManager.initialize();

    // Get or load with one line of code
    final value = await cacheManager.getOrPut(
      'user_123',
      (key) async {
        // This function only runs if key is not in cache
        return await fetchFromNetwork(key);
      },
      memoryTtl: const Duration(minutes: 5),
    );

    print('Value: $value');

    await cacheManager.dispose();
  }

  /// Example 8: Maintenance and cleanup
  ///
  /// Shows how to perform regular cache maintenance.
  static Future<void> maintenanceExample() async {
    final cacheManager = CacheManager<String, String>();

    await cacheManager.initialize();

    // Cleanup expired entries
    await cacheManager.cleanupExpired();

    // Get cache size information
    final diskStats = cacheManager.getDiskStats();
    print('Current disk cache size: ${diskStats.currentSize} bytes');
    print('Peak disk cache size: ${diskStats.peakSize} bytes');

    // Clear caches if needed
    if (diskStats.currentSize > 100 * 1024 * 1024) {
      // Clear if over 100 MB
      await cacheManager.clearDisk();
    }

    await cacheManager.dispose();
  }

  /// Mock network fetch function for demonstration
  static Future<String> fetchFromNetwork(String key) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));
    return 'Data for $key';
  }
}

/// Example: Activity-specific cache manager
///
/// Shows how to create a typed cache manager for specific data types.
class ActivityCacheManager {
  late final CacheManager<String, Map<String, dynamic>> _manager;

  ActivityCacheManager() {
    _manager = CacheManager<String, Map<String, dynamic>>(
      config: const CacheManagerConfig(
        memoryConfig: MemoryCacheConfig(
          maxSize: 100,
          defaultTtl: Duration(minutes: 5),
        ),
        diskConfig: DiskCacheConfig(
          maxCacheSize: 50 * 1024 * 1024,
          defaultTtl: Duration(hours: 24),
        ),
      ),
    );
  }

  Future<void> initialize() async {
    await _manager.initialize();
  }

  Future<Map<String, dynamic>?> getActivity(String activityId) async {
    final result = await _manager.get(
      activityId,
      networkFetcher: (id) async {
        // Simulate API call
        return await _fetchActivityFromApi(id);
      },
    );

    return result.value;
  }

  Future<void> cacheActivity(String activityId, Map<String, dynamic> activity) {
    return _manager.putJson(
      activityId,
      activity,
      memoryTtl: const Duration(minutes: 5),
      diskTtl: const Duration(hours: 24),
    );
  }

  Future<void> invalidateActivity(String activityId) {
    return _manager.invalidate(activityId);
  }

  Future<void> dispose() {
    return _manager.dispose();
  }

  Future<Map<String, dynamic>> _fetchActivityFromApi(String id) async {
    // Mock implementation
    await Future.delayed(const Duration(milliseconds: 300));
    return {
      'id': id,
      'name': 'Activity $id',
      'description': 'Sample activity',
    };
  }
}
