import 'dart:async';

import '../cache/cache_manager.dart';
import '../cache/cache_stats.dart';

/// Configuration for query optimization behavior
class QueryOptimizerConfig {
  /// Default TTL for cached query results
  final Duration defaultCacheTtl;

  /// Maximum number of cached queries
  final int maxCacheSize;

  /// Whether to enable automatic query deduplication
  final bool enableDeduplication;

  /// Whether to enable selective field loading
  final bool enableFieldSelection;

  /// Whether to track statistics
  final bool trackStatistics;

  const QueryOptimizerConfig({
    this.defaultCacheTtl = const Duration(minutes: 5),
    this.maxCacheSize = 100,
    this.enableDeduplication = true,
    this.enableFieldSelection = true,
    this.trackStatistics = true,
  });

  /// Default configuration
  static const defaultConfig = QueryOptimizerConfig();

  /// Aggressive caching (longer TTL, larger cache)
  static const aggressiveCaching = QueryOptimizerConfig(
    defaultCacheTtl: Duration(minutes: 15),
    maxCacheSize: 200,
  );

  /// Minimal caching (shorter TTL, smaller cache)
  static const minimalCaching = QueryOptimizerConfig(
    defaultCacheTtl: Duration(minutes: 1),
    maxCacheSize: 50,
  );
}

/// Statistics about query optimization
class QueryOptimizerStats {
  /// Total number of queries optimized
  final int totalQueries;

  /// Number of cache hits
  final int cacheHits;

  /// Number of cache misses
  final int cacheMisses;

  /// Number of deduplicated queries
  final int deduplicatedQueries;

  /// Number of queries with selective field loading
  final int selectiveFieldQueries;

  /// Cache hit rate (0.0 to 1.0)
  double get cacheHitRate => totalQueries > 0 ? cacheHits / totalQueries : 0.0;

  /// Cache miss rate (0.0 to 1.0)
  double get cacheMissRate =>
      totalQueries > 0 ? cacheMisses / totalQueries : 0.0;

  const QueryOptimizerStats({
    required this.totalQueries,
    required this.cacheHits,
    required this.cacheMisses,
    this.deduplicatedQueries = 0,
    this.selectiveFieldQueries = 0,
  });

  @override
  String toString() {
    return 'QueryOptimizerStats('
        'total: $totalQueries, '
        'hits: $cacheHits, '
        'misses: $cacheMisses, '
        'hitRate: ${(cacheHitRate * 100).toStringAsFixed(1)}%, '
        'deduplicated: $deduplicatedQueries, '
        'selectiveFields: $selectiveFieldQueries)';
  }
}

/// Result of an optimized query
class OptimizedQueryResult<T> {
  /// The query result data
  final T data;

  /// Whether the result came from cache
  final bool fromCache;

  /// Whether this query was deduplicated (combined with another)
  final bool wasDeduplicated;

  /// Whether selective field loading was used
  final bool usedSelectiveFields;

  /// Fields that were loaded (if selective)
  final List<String>? loadedFields;

  /// Time taken to execute the query
  final Duration executionTime;

  const OptimizedQueryResult({
    required this.data,
    this.fromCache = false,
    this.wasDeduplicated = false,
    this.usedSelectiveFields = false,
    this.loadedFields,
    required this.executionTime,
  });

  /// Create a cache hit result
  factory OptimizedQueryResult.cacheHit({
    required T data,
    required Duration executionTime,
  }) {
    return OptimizedQueryResult(
      data: data,
      fromCache: true,
      executionTime: executionTime,
    );
  }

  /// Create a fresh query result
  factory OptimizedQueryResult.fresh({
    required T data,
    required Duration executionTime,
    bool usedSelectiveFields = false,
    List<String>? loadedFields,
  }) {
    return OptimizedQueryResult(
      data: data,
      fromCache: false,
      usedSelectiveFields: usedSelectiveFields,
      loadedFields: loadedFields,
      executionTime: executionTime,
    );
  }

  @override
  String toString() {
    return 'OptimizedQueryResult('
        'fromCache: $fromCache, '
        'deduplicated: $wasDeduplicated, '
        'selectiveFields: $usedSelectiveFields, '
        'time: ${executionTime.inMilliseconds}ms)';
  }
}

/// Field selector for query optimization
///
/// Allows specifying exactly which fields to load from a data source,
/// reducing data transfer and improving performance.
class FieldSelector {
  /// Selected field names
  final List<String> fields;

  /// Whether to exclude these fields instead of include them
  final bool excludeMode;

  const FieldSelector({
    required this.fields,
    this.excludeMode = false,
  });

  /// Create a selector that includes only the specified fields
  factory FieldSelector.include(List<String> fields) {
    return FieldSelector(fields: fields, excludeMode: false);
  }

  /// Create a selector that excludes the specified fields
  factory FieldSelector.exclude(List<String> fields) {
    return FieldSelector(fields: fields, excludeMode: true);
  }

  /// Select all fields (no filtering)
  static const all = FieldSelector(fields: []);

  /// Common field selections for activities
  static FieldSelector get activityMetadata => FieldSelector.include([
    'id',
    'title',
    'category',
    'startDateTime',
    'isCompleted',
  ]);

  /// Common field selections for trips
  static FieldSelector get tripMetadata => FieldSelector.include([
    'id',
    'title',
    'destination',
    'startDate',
    'endDate',
    'status',
  ]);

  /// Common field selections for photos
  static FieldSelector get photoMetadata => FieldSelector.include([
    'id',
    'url',
    'thumbnailUrl',
    'caption',
    'takenAt',
  ]);

  /// Check if a field should be included
  bool shouldInclude(String field) {
    if (fields.isEmpty) return true; // No filtering
    return excludeMode ? !fields.contains(field) : fields.contains(field);
  }

  /// Filter a map to only include selected fields
  Map<String, dynamic> filterMap(Map<String, dynamic> data) {
    if (fields.isEmpty) return data; // No filtering

    final filtered = <String, dynamic>{};
    for (final entry in data.entries) {
      if (shouldInclude(entry.key)) {
        filtered[entry.key] = entry.value;
      }
    }
    return filtered;
  }

  /// Get the field list for API queries
  List<String> get selectedFields => fields;

  @override
  String toString() {
    final mode = excludeMode ? 'exclude' : 'include';
    return 'FieldSelector($mode: ${fields.join(', ')})';
  }
}

/// Query optimizer for improving database query performance
///
/// This utility provides three key optimizations:
/// 1. **Selective Field Loading**: Load only the fields you need
/// 2. **Query Deduplication**: Avoid executing duplicate queries
/// 3. **Query Result Caching**: Cache results to avoid repeated queries
///
/// Example usage:
/// ```dart
/// final optimizer = QueryOptimizer();
///
/// // Using selective field loading
/// final result = await optimizer.execute(
///   key: 'activities',
///   query: () => repository.getActivities(tripId: 'trip123'),
///   fields: FieldSelector.activityMetadata,
/// );
///
/// // With caching
/// final result = await optimizer.execute(
///   key: 'user-trips',
///   query: () => repository.getTrips(userId: 'user123'),
///   ttl: Duration(minutes: 10),
/// );
///
/// // Get statistics
/// print(optimizer.stats);
/// ```
class QueryOptimizer {
  /// Configuration for this optimizer
  final QueryOptimizerConfig config;

  /// Cache manager for storing query results
  final CacheManager? _cacheManager;

  /// Currently executing queries (for deduplication)
  final Map<String, Future> _pendingQueries = {};

  /// Statistics tracking
  int _totalQueries = 0;
  int _cacheHits = 0;
  int _cacheMisses = 0;
  int _deduplicatedQueries = 0;
  int _selectiveFieldQueries = 0;

  /// Whether debug logging is enabled
  final bool debug;

  /// Creates a new query optimizer
  ///
  /// If [cacheManager] is not provided, a default one will be created.
  QueryOptimizer({
    this.config = QueryOptimizerConfig.defaultConfig,
    CacheManager? cacheManager,
    this.debug = false,
  }) : _cacheManager = cacheManager {
    if (debug) {
    }
  }

  /// Execute an optimized query
  ///
  /// Parameters:
  /// - [key]: Unique key for this query (used for caching and deduplication)
  /// - [query]: The query function to execute
  /// - [fields]: Optional field selector for selective loading
  /// - [ttl]: Optional TTL for caching (overrides default)
  /// - [strategy]: Cache strategy to use
  ///
  /// Returns an optimized query result with metadata
  Future<OptimizedQueryResult<T>> execute<T>({
    required String key,
    required Future<T> Function() query,
    FieldSelector? fields,
    Duration? ttl,
    CacheStrategy strategy = CacheStrategy.prioritized,
  }) async {
    final stopwatch = Stopwatch()..start();
    _totalQueries++;

    final usedFieldSelection = fields != null &&
        config.enableFieldSelection &&
        fields.fields.isNotEmpty;

    if (usedFieldSelection) {
      _selectiveFieldQueries++;
    }

    if (debug) {
    }

    // Check cache first
    if (_cacheManager != null) {
      final cacheResult = await _cacheManager.get(
        key,
        networkFetcher: (_) => throw Exception('Cache miss'),
        strategy: CacheStrategy.cacheOnly,
      );

      if (cacheResult.isHit) {
        stopwatch.stop();
        _cacheHits++;

        if (debug) {
        }

        return OptimizedQueryResult.cacheHit(
          data: cacheResult.value!,
          executionTime: stopwatch.elapsed,
        );
      } else {
        _cacheMisses++;
      }
    }

    // Check for deduplication
    if (config.enableDeduplication && _pendingQueries.containsKey(key)) {
      _deduplicatedQueries++;

      if (debug) {
      }

      try {
        final data = await _pendingQueries[key] as T;
        stopwatch.stop();

        return OptimizedQueryResult(
          data: data,
          fromCache: false,
          wasDeduplicated: true,
          usedSelectiveFields: usedFieldSelection,
          loadedFields: fields?.selectedFields,
          executionTime: stopwatch.elapsed,
        );
      } catch (error) {
        // If deduplicated query failed, execute fresh
        if (debug) {
        }
      }
    }

    // Execute the query
    final queryFuture = query();
    _pendingQueries[key] = queryFuture;

    try {
      final data = await queryFuture;
      stopwatch.stop();

      // Apply field selection if needed
      final filteredData = usedFieldSelection && data is List
          ? _applyFieldSelection(data, fields)
          : data;

      // Cache the result
      if (_cacheManager != null) {
        await _cacheManager.put(
          key,
          filteredData as T,
          memoryTtl: ttl ?? config.defaultCacheTtl,
        );
      }

      if (debug) {
      }

      return OptimizedQueryResult.fresh(
        data: filteredData as T,
        executionTime: stopwatch.elapsed,
        usedSelectiveFields: usedFieldSelection,
        loadedFields: fields?.selectedFields,
      );
    } finally {
      _pendingQueries.remove(key);
    }
  }

  /// Execute multiple queries in parallel with optimization
  ///
  /// This is more efficient than executing queries individually as it:
  /// - Handles all queries in parallel
  /// - Shares deduplication across all queries
  /// - Aggregates statistics
  Future<Map<String, OptimizedQueryResult<T>>> executeBatch<T>({
    required Map<String, Future<T> Function()> queries,
    Map<String, FieldSelector>? fieldsMap,
    Duration? ttl,
  }) async {
    if (debug) {
    }

    final futures = queries.entries.map((entry) async {
      final result = await execute<T>(
        key: entry.key,
        query: entry.value,
        fields: fieldsMap?[entry.key],
        ttl: ttl,
      );
      return MapEntry(entry.key, result);
    });

    final results = await Future.wait(futures);
    return Map.fromEntries(results);
  }

  /// Apply field selection to a list of results
  dynamic _applyFieldSelection(dynamic data, FieldSelector fields) {
    if (data is List && data.isNotEmpty) {
      // Assume list of maps
      if (data.first is Map<String, dynamic>) {
        return data
            .map((item) => fields.filterMap(item as Map<String, dynamic>))
            .toList();
      }
    }
    return data;
  }

  /// Invalidate cached query results
  ///
  /// Parameters:
  /// - [key]: Specific key to invalidate, or null to invalidate all
  Future<void> invalidate({String? key}) async {
    if (_cacheManager == null) return;

    if (key != null) {
      await _cacheManager.invalidate(key);
      if (debug) {
      }
    } else {
      await _cacheManager.clearAll();
      if (debug) {
      }
    }
  }

  /// Invalidate multiple cache entries matching a predicate
  Future<void> invalidateWhere(bool Function(String key) predicate) async {
    if (_cacheManager == null) return;

    // Note: This requires cache manager to support predicate-based deletion
    // For now, we'll just log it
    if (debug) {
    }
  }

  /// Preload data into the cache
  ///
  /// Useful for warming up the cache with data that will be needed soon
  Future<void> preload<T>({
    required String key,
    required Future<T> Function() query,
    Duration? ttl,
  }) async {
    if (debug) {
    }

    try {
      await execute<T>(
        key: key,
        query: query,
        ttl: ttl,
      );
      if (debug) {
      }
    } catch (error) {
      if (debug) {
      }
    }
  }

  /// Get current statistics
  QueryOptimizerStats get stats {
    return QueryOptimizerStats(
      totalQueries: _totalQueries,
      cacheHits: _cacheHits,
      cacheMisses: _cacheMisses,
      deduplicatedQueries: _deduplicatedQueries,
      selectiveFieldQueries: _selectiveFieldQueries,
    );
  }

  /// Get combined cache statistics (if cache manager is available)
  CombinedCacheStats? get cacheStats {
    return _cacheManager?.getStats();
  }

  /// Reset statistics
  void resetStats() {
    _totalQueries = 0;
    _cacheHits = 0;
    _cacheMisses = 0;
    _deduplicatedQueries = 0;
    _selectiveFieldQueries = 0;

    if (debug) {
    }
  }

  /// Clear all cached data
  Future<void> clearCache() async {
    await invalidate();
    if (debug) {
    }
  }

  /// Dispose the optimizer and release resources
  void dispose() {
    _pendingQueries.clear();
    if (debug) {
    }
  }

  @override
  String toString() {
    return 'QueryOptimizer('
        'queries: $_totalQueries, '
        'hitRate: ${(stats.cacheHitRate * 100).toStringAsFixed(1)}%, '
        'deduplicated: $_deduplicatedQueries, '
        'selectiveFields: $_selectiveFieldQueries)';
  }
}
