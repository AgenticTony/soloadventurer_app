import 'dart:collection';
import 'cache_stats.dart';

/// Configuration for memory cache
class MemoryCacheConfig {
  /// Maximum number of items to store in cache
  final int maxSize;

  /// Enable cache statistics tracking
  final bool trackStats;

  /// Default time-to-live for cache entries (null = no expiration)
  final Duration? defaultTtl;

  const MemoryCacheConfig({
    this.maxSize = 100,
    this.trackStats = true,
    this.defaultTtl,
  });

  /// Copy with modified values
  MemoryCacheConfig copyWith({
    int? maxSize,
    bool? trackStats,
    Duration? defaultTtl,
  }) {
    return MemoryCacheConfig(
      maxSize: maxSize ?? this.maxSize,
      trackStats: trackStats ?? this.trackStats,
      defaultTtl: defaultTtl ?? this.defaultTtl,
    );
  }
}

/// Cache entry with expiration support
class _CacheEntry<V> {
  final V value;
  final DateTime createdAt;
  final DateTime? expiresAt;

  _CacheEntry({
    required this.value,
    required this.createdAt,
    this.expiresAt,
  });

  /// Check if entry has expired
  bool get isExpired {
    if (expiresAt == null) return false;
    return DateTime.now().isAfter(expiresAt!);
  }

  /// Get age of entry
  Duration get age => DateTime.now().difference(createdAt);

  /// Get time until expiration
  Duration? get timeToExpiration {
    if (expiresAt == null) return null;
    return expiresAt!.difference(DateTime.now());
  }
}

/// In-memory LRU (Least Recently Used) cache
///
/// Provides fast access to cached data with automatic eviction of least recently
/// used items when the cache reaches its maximum size. Supports time-based
/// expiration and comprehensive statistics tracking.
///
/// ## Features
///
/// - **LRU Eviction**: Automatically removes least recently used items when full
/// - **TTL Support**: Optional time-to-live for automatic expiration
/// - **Statistics**: Track hit rate, miss rate, and evictions
/// - **Type Safe**: Generic implementation for any value type
///
/// ## Example
///
/// ```dart
/// final cache = MemoryCache<String, Activity>(
///   config: MemoryCacheConfig(maxSize: 100),
/// );
///
/// // Add to cache
/// await cache.put('activity_123', activity);
///
/// // Get from cache
/// final activity = await cache.get('activity_123');
///
/// // Get with TTL
/// await cache.put('temp_data', data, ttl: Duration(minutes: 5));
///
/// // Get statistics
/// final hitRate = cache.stats.hitRate;
/// ```
class MemoryCache<K, V> {
  /// Cache configuration
  final MemoryCacheConfig config;

  /// Cache statistics
  final CacheStats stats;

  /// Internal storage using LinkedHashMap for LRU tracking
  final LinkedHashMap<K, _CacheEntry<V>> _storage = LinkedHashMap();

  /// Creates a new memory cache
  MemoryCache({
    MemoryCacheConfig? config,
  })  : config = config ?? const MemoryCacheConfig(),
        stats = CacheStats();

  /// Current number of items in cache
  int get size => _storage.length;

  /// Maximum cache size
  int get maxSize => config.maxSize;

  /// Check if cache is empty
  bool get isEmpty => _storage.isEmpty;

  /// Check if cache is full
  bool get isFull => _storage.length >= config.maxSize;

  /// Get all keys currently in cache
  List<K> get keys => _storage.keys.toList();

  /// Get a value from cache by key
  ///
  /// Returns null if:
  /// - Key doesn't exist
  /// - Entry has expired
  V? get(K key) {
    final entry = _storage[key];

    // Key not found
    if (entry == null) {
      if (config.trackStats) {
        stats.recordMiss();
      }
      return null;
    }

    // Entry expired
    if (entry.isExpired) {
      _storage.remove(key);
      if (config.trackStats) {
        stats.recordMiss();
        stats.recordRemoval();
      }
      return null;
    }

    // Cache hit - move to end (most recently used)
    _storage.remove(key);
    _storage[key] = entry;

    if (config.trackStats) {
      stats.recordHit();
    }

    return entry.value;
  }

  /// Put a value in cache
  ///
  /// If key already exists, it will be updated and moved to most recently used.
  /// If cache is full, the least recently used item will be evicted.
  Future<void> put(K key, V value, {Duration? ttl}) async {
    final expiration = ttl ?? config.defaultTtl;
    final now = DateTime.now();

    // Create new entry
    final entry = _CacheEntry(
      value: value,
      createdAt: now,
      expiresAt: expiration != null ? now.add(expiration) : null,
    );

    // Check if key already exists
    final exists = _storage.containsKey(key);

    // If cache is full and key doesn't exist, evict LRU item
    if (!exists && isFull) {
      await _evictLRU();
    }

    // Remove existing key if present (will be re-added at end)
    if (exists) {
      _storage.remove(key);
    }

    // Add entry (goes to end = most recently used)
    _storage[key] = entry;

    if (config.trackStats) {
      if (!exists) {
        stats.recordAddition();
      }
    }
  }

  /// Put multiple values in cache
  Future<void> putAll(Map<K, V> items, {Duration? ttl}) async {
    for (final entry in items.entries) {
      await put(entry.key, entry.value, ttl: ttl);
    }
  }

  /// Check if key exists in cache and is not expired
  bool containsKey(K key) {
    final entry = _storage[key];
    if (entry == null) return false;
    if (entry.isExpired) {
      _storage.remove(key);
      if (config.trackStats) {
        stats.recordRemoval();
      }
      return false;
    }
    return true;
  }

  /// Remove a specific key from cache
  V? remove(K key) {
    final entry = _storage.remove(key);
    if (entry != null && config.trackStats) {
      stats.recordRemoval();
    }
    return entry?.value;
  }

  /// Clear all items from cache
  void clear() {
    final count = _storage.length;
    _storage.clear();
    if (config.trackStats && count > 0) {
      for (var i = 0; i < count; i++) {
        stats.recordRemoval();
      }
    }
  }

  /// Remove all expired entries from cache
  Future<void> cleanupExpired() async {
    final expiredKeys = <K>[];

    for (final entry in _storage.entries) {
      if (entry.value.isExpired) {
        expiredKeys.add(entry.key);
      }
    }

    for (final key in expiredKeys) {
      _storage.remove(key);
      if (config.trackStats) {
        stats.recordRemoval();
      }
    }
  }

  /// Get multiple values from cache
  Map<K, V> getMultiple(Iterable<K> keys) {
    final result = <K, V>{};

    for (final key in keys) {
      final value = get(key);
      if (value != null) {
        result[key] = value;
      }
    }

    return result;
  }

  /// Get value or compute if not in cache
  ///
  /// If key is not in cache, calls [loader] to get the value,
  /// stores it in cache, and returns it.
  Future<V> getOrPut(K key, Future<V> Function() loader,
      {Duration? ttl}) async {
    final value = get(key);
    if (value != null) {
      return value;
    }

    // Load and cache the value
    final loadedValue = await loader();
    await put(key, loadedValue, ttl: ttl);
    return loadedValue;
  }

  /// Evict least recently used item
  Future<void> _evictLRU() async {
    if (_storage.isEmpty) return;

    // Get first key (least recently used)
    final firstKey = _storage.keys.first;
    _storage.remove(firstKey);

    if (config.trackStats) {
      stats.recordEviction();
    }
  }

  /// Get cache statistics
  CacheStats getStats() => stats;

  /// Reset statistics
  void resetStats() {
    stats.reset();
  }

  /// Get approximate memory usage in bytes
  ///
  /// Note: This is an approximation based on the number of entries
  /// and assumes an average entry size. For precise measurement,
  /// use a memory profiler.
  int getApproximateMemoryUsage() {
    // Rough estimate: 100 bytes per entry overhead + 8 bytes per reference
    const bytesPerEntry = 100;
    return _storage.length * bytesPerEntry;
  }

  @override
  String toString() {
    return 'MemoryCache(size: ${_storage.length}/$maxSize, stats: $stats)';
  }
}
