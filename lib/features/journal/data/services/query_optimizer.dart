import 'dart:async';

/// Query result with metadata
class QueryResult<T> {
  final T? data;
  final String? error;
  final int durationMs;
  final bool fromCache;

  const QueryResult({
    this.data,
    this.error,
    required this.durationMs,
    required this.fromCache,
  });

  bool get isSuccess => data != null && error == null;
  bool get isError => error != null;
  bool get isCached => fromCache;
}

/// Cache entry with expiration
class CacheEntry<T> {
  final T data;
  final DateTime createdAt;
  final DateTime? expiresAt;
  final int accessCount;

  const CacheEntry({
    required this.data,
    required this.createdAt,
    this.expiresAt,
    this.accessCount = 0,
  });

  bool get isExpired {
    if (expiresAt == null) return false;
    return DateTime.now().isAfter(expiresAt!);
  }

  CacheEntry<T> copyWith({
    T? data,
    DateTime? createdAt,
    DateTime? expiresAt,
    int? accessCount,
  }) {
    return CacheEntry(
      data: data ?? this.data,
      createdAt: createdAt ?? this.createdAt,
      expiresAt: expiresAt ?? this.expiresAt,
      accessCount: accessCount ?? this.accessCount,
    );
  }

  CacheEntry<T> incrementAccess() {
    return copyWith(accessCount: accessCount + 1);
  }
}

/// Cache configuration
class CacheConfig {
  /// Default TTL for cache entries (default: 5 minutes)
  final Duration defaultTtl;

  /// Maximum cache size (default: 100 entries)
  final int maxSize;

  /// Enable cache statistics
  final bool enableStats;

  /// Cleanup interval (default: 10 minutes)
  final Duration cleanupInterval;

  const CacheConfig({
    this.defaultTtl = const Duration(minutes: 5),
    this.maxSize = 100,
    this.enableStats = true,
    this.cleanupInterval = const Duration(minutes: 10),
  });

  /// Predefined configurations
  static const forLists = CacheConfig(
    defaultTtl: Duration(minutes: 2),
    maxSize: 50,
  );

  static const forDetails = CacheConfig(
    defaultTtl: Duration(minutes: 10),
    maxSize: 30,
  );

  static const forMetadata = CacheConfig(
    defaultTtl: Duration(minutes: 30),
    maxSize: 100,
  );
}

/// Cache statistics
class CacheStats {
  final int totalHits;
  final int totalMisses;
  final int totalSets;
  final int totalEvictions;
  final int currentSize;
  final DateTime lastCleanup;

  const CacheStats({
    this.totalHits = 0,
    this.totalMisses = 0,
    this.totalSets = 0,
    this.totalEvictions = 0,
    this.currentSize = 0,
    required this.lastCleanup,
  });

  double get hitRate =>
      totalHits + totalMisses > 0 ? totalHits / (totalHits + totalMisses) : 0.0;

  int get totalRequests => totalHits + totalMisses;

  CacheStats copyWith({
    int? totalHits,
    int? totalMisses,
    int? totalSets,
    int? totalEvictions,
    int? currentSize,
    DateTime? lastCleanup,
  }) {
    return CacheStats(
      totalHits: totalHits ?? this.totalHits,
      totalMisses: totalMisses ?? this.totalMisses,
      totalSets: totalSets ?? this.totalSets,
      totalEvictions: totalEvictions ?? this.totalEvictions,
      currentSize: currentSize ?? this.currentSize,
      lastCleanup: lastCleanup ?? this.lastCleanup,
    );
  }

  @override
  String toString() {
    return 'CacheStats(hits: $totalHits, misses: $totalMisses, hitRate: ${(hitRate * 100).toStringAsFixed(1)}%, size: $currentSize)';
  }
}

/// Generic query cache with TTL and size limits
class QueryCache<T> {
  final CacheConfig config;
  final Map<String, CacheEntry<T>> _cache = {};
  CacheStats _stats = CacheStats(lastCleanup: DateTime.now());
  Timer? _cleanupTimer;

  QueryCache(this.config) {
    if (config.enableStats) {
      _startCleanupTimer();
    }
  }

  /// Get value from cache
  CacheEntry<T>? get(String key) {
    final entry = _cache[key];

    if (entry == null) {
      _stats = _stats.copyWith(totalMisses: _stats.totalMisses + 1);
      return null;
    }

    if (entry.isExpired) {
      _cache.remove(key);
      _stats = _stats.copyWith(
        totalMisses: _stats.totalMisses + 1,
        totalEvictions: _stats.totalEvictions + 1,
      );
      return null;
    }

    // Update access count
    _cache[key] = entry.incrementAccess();
    _stats = _stats.copyWith(totalHits: _stats.totalHits + 1);

    return entry;
  }

  /// Set value in cache
  void set(String key, T data, {Duration? ttl}) {
    // Enforce max size by evicting least recently used if needed
    if (_cache.length >= config.maxSize && !_cache.containsKey(key)) {
      _evictLRU();
    }

    final entry = CacheEntry(
      data: data,
      createdAt: DateTime.now(),
      expiresAt: ttl != null
          ? DateTime.now().add(ttl)
          : DateTime.now().add(config.defaultTtl),
    );

    _cache[key] = entry;
    _stats = _stats.copyWith(
      totalSets: _stats.totalSets + 1,
      currentSize: _cache.length,
    );
  }

  /// Remove specific key from cache
  void remove(String key) {
    _cache.remove(key);
    _stats = _stats.copyWith(currentSize: _cache.length);
  }

  /// Clear all cache
  void clear() {
    _cache.clear();
    _stats = _stats.copyWith(currentSize: 0);
  }

  /// Get current statistics
  CacheStats get stats => _stats;

  /// Evict least recently used entry
  void _evictLRU() {
    if (_cache.isEmpty) return;

    String? lruKey;
    DateTime? oldestAccess;

    for (final entry in _cache.entries) {
      if (oldestAccess == null ||
          entry.value.createdAt.isBefore(oldestAccess)) {
        oldestAccess = entry.value.createdAt;
        lruKey = entry.key;
      }
    }

    if (lruKey != null) {
      _cache.remove(lruKey);
      _stats = _stats.copyWith(
        totalEvictions: _stats.totalEvictions + 1,
        currentSize: _cache.length,
      );
    }
  }

  /// Clean up expired entries
  void cleanup() {
    final now = DateTime.now();
    final expiredKeys = <String>[];

    for (final entry in _cache.entries) {
      if (entry.value.isExpired) {
        expiredKeys.add(entry.key);
      }
    }

    for (final key in expiredKeys) {
      _cache.remove(key);
    }

    if (expiredKeys.isNotEmpty) {
      _stats = _stats.copyWith(
        totalEvictions: _stats.totalEvictions + expiredKeys.length,
        currentSize: _cache.length,
        lastCleanup: now,
      );
    }
  }

  /// Start automatic cleanup timer
  void _startCleanupTimer() {
    _cleanupTimer?.cancel();
    _cleanupTimer = Timer.periodic(config.cleanupInterval, (_) {
      cleanup();
    });
  }

  /// Dispose resources
  void dispose() {
    _cleanupTimer?.cancel();
  }
}

/// Query field selection for optimization
class QueryFields {
  final Set<String> fields;

  const QueryFields(this.fields);

  /// Common field selections
  static const forList = QueryFields({
    'id',
    'title',
    'entry_date',
    'created_at',
    'is_favorite',
    'thumbnail_url',
  });

  static const forDetail = QueryFields({
    'id',
    'title',
    'content',
    'entry_date',
    'location',
    'mood',
    'is_favorite',
    'created_at',
    'updated_at',
  });

  static const forCard = QueryFields({
    'id',
    'title',
    'entry_date',
    'location',
    'thumbnail_url',
    'is_favorite',
  });

  static const forMetadata = QueryFields({
    'id',
    'name',
    'created_at',
  });

  /// Custom field selection
  factory QueryFields.custom(List<String> fields) {
    return QueryFields(fields.toSet());
  }

  /// Convert to comma-separated string for Supabase
  String toSelectString() {
    return fields.join(',');
  }

  /// Check if field is included
  bool contains(String field) => fields.contains(field);
}

/// Optimized query executor with caching and field selection
class QueryOptimizer {
  final QueryCache<dynamic> cache;
  final bool enableLogging;
  int _queryCount = 0;
  int _totalQueryTime = 0;

  QueryOptimizer({
    CacheConfig? cacheConfig,
    this.enableLogging = false,
  }) : cache = QueryCache<dynamic>(cacheConfig ?? CacheConfig.forLists);

  /// Execute query with caching
  Future<QueryResult<T>> execute<T>(
    String queryKey,
    Future<T> Function() fetcher, {
    Duration? ttl,
    QueryFields? fields,
    bool forceRefresh = false,
  }) async {
    final stopwatch = Stopwatch()..start();

    try {
      // Check cache first
      if (!forceRefresh) {
        final cached = cache.get(queryKey);
        if (cached != null) {
          stopwatch.stop();
          if (enableLogging) {
            _logQuery(queryKey, stopwatch.elapsedMilliseconds, true, true);
          }
          return QueryResult(
            data: cached.data as T,
            durationMs: stopwatch.elapsedMilliseconds,
            fromCache: true,
          );
        }
      }

      // Fetch fresh data
      final data = await fetcher();
      stopwatch.stop();

      // Cache the result
      cache.set(queryKey, data, ttl: ttl);

      if (enableLogging) {
        _logQuery(queryKey, stopwatch.elapsedMilliseconds, true, false);
      }

      return QueryResult(
        data: data,
        durationMs: stopwatch.elapsedMilliseconds,
        fromCache: false,
      );
    } catch (e) {
      stopwatch.stop();
      if (enableLogging) {
        _logQuery(queryKey, stopwatch.elapsedMilliseconds, false, false);
      }

      return QueryResult(
        error: e.toString(),
        durationMs: stopwatch.elapsedMilliseconds,
        fromCache: false,
      );
    }
  }

  /// Batch execute multiple queries
  Future<List<QueryResult<T>>> executeBatch<T>(
    List<Map<String, dynamic>> queries,
  ) async {
    final results = <QueryResult<T>>[];

    for (final query in queries) {
      final result = await execute<T>(
        query['key'] as String,
        query['fetcher'] as Future<T> Function(),
        ttl: query['ttl'] as Duration?,
        fields: query['fields'] as QueryFields?,
      );
      results.add(result);
    }

    return results;
  }

  /// Invalidate cache entry
  void invalidate(String queryKey) {
    cache.remove(queryKey);
  }

  /// Invalidate multiple cache entries
  void invalidateMultiple(List<String> queryKeys) {
    for (final key in queryKeys) {
      cache.remove(key);
    }
  }

  /// Clear all cache
  void clearCache() {
    cache.clear();
  }

  /// Get cache statistics
  CacheStats getStats() => cache.stats;

  /// Get query statistics
  Map<String, dynamic> getQueryStats() {
    return {
      'totalQueries': _queryCount,
      'averageQueryTime': _queryCount > 0
          ? '${(_totalQueryTime / _queryCount).toStringAsFixed(2)}ms'
          : 'N/A',
      'cacheStats': cache.stats.toString(),
    };
  }

  void _logQuery(String key, int durationMs, bool success, bool fromCache) {
    _queryCount++;
    _totalQueryTime += durationMs;

    fromCache ? ' [CACHE]' : '';

  }

  /// Dispose resources
  void dispose() {
    cache.dispose();
  }
}
