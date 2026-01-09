import 'dart:convert';

/// Cache statistics for tracking cache performance
///
/// Tracks metrics like hit rate, miss rate, eviction counts, and memory usage
/// to help optimize cache performance and identify potential issues.
///
/// ## Example
///
/// ```dart
/// final stats = CacheStats<String>();
///
/// // Record operations
/// stats.recordHit();
/// stats.recordMiss();
/// stats.recordEviction();
///
/// // Get metrics
/// final hitRate = stats.hitRate; // 0.5 (50%)
/// final missRate = stats.missRate; // 0.5 (50%)
/// ```
class CacheStats {
  /// Number of cache hits (data found in cache)
  int _hitCount = 0;

  /// Number of cache misses (data not found in cache)
  int _missCount = 0;

  /// Number of items evicted from cache
  int _evictionCount = 0;

  /// Number of items currently in cache
  int _currentSize = 0;

  /// Peak cache size (maximum number of items ever in cache)
  int _peakSize = 0;

  /// Total number of items added to cache
  int _totalAdditions = 0;

  /// Total number of items removed from cache (explicit removals, not evictions)
  int _totalRemovals = 0;

  /// Timestamp when stats were created
  final DateTime _createdAt;

  /// Timestamp of last operation
  DateTime? _lastOperationAt;

  /// Creates a new CacheStats instance
  CacheStats() : _createdAt = DateTime.now();

  /// Number of cache hits
  int get hitCount => _hitCount;

  /// Number of cache misses
  int get missCount => _missCount;

  /// Total number of cache requests (hits + misses)
  int get totalRequests => _hitCount + _missCount;

  /// Number of cache evictions
  int get evictionCount => _evictionCount;

  /// Current cache size (number of items)
  int get currentSize => _currentSize;

  /// Peak cache size
  int get peakSize => _peakSize;

  /// Total items added to cache
  int get totalAdditions => _totalAdditions;

  /// Total items removed from cache
  int get totalRemovals => _totalRemovals;

  /// Cache hit rate (0.0 to 1.0)
  ///
  /// Returns 0.0 if no requests have been made
  double get hitRate {
    if (totalRequests == 0) return 0.0;
    return _hitCount / totalRequests;
  }

  /// Cache miss rate (0.0 to 1.0)
  ///
  /// Returns 0.0 if no requests have been made
  double get missRate {
    if (totalRequests == 0) return 0.0;
    return _missCount / totalRequests;
  }

  /// Hit rate as percentage (0-100)
  double get hitRatePercent => hitRate * 100;

  /// Miss rate as percentage (0-100)
  double get missRatePercent => missRate * 100;

  /// When stats were created
  DateTime get createdAt => _createdAt;

  /// Last operation timestamp
  DateTime? get lastOperationAt => _lastOperationAt;

  /// Records a cache hit
  void recordHit() {
    _hitCount++;
    _lastOperationAt = DateTime.now();
  }

  /// Records a cache miss
  void recordMiss() {
    _missCount++;
    _lastOperationAt = DateTime.now();
  }

  /// Records an item addition
  void recordAddition() {
    _totalAdditions++;
    _currentSize++;
    if (_currentSize > _peakSize) {
      _peakSize = _currentSize;
    }
    _lastOperationAt = DateTime.now();
  }

  /// Records an item removal
  void recordRemoval() {
    _totalRemovals++;
    if (_currentSize > 0) {
      _currentSize--;
    }
    _lastOperationAt = DateTime.now();
  }

  /// Records a cache eviction
  void recordEviction() {
    _evictionCount++;
    if (_currentSize > 0) {
      _currentSize--;
    }
    _lastOperationAt = DateTime.now();
  }

  /// Resets all statistics except creation timestamp
  void reset() {
    _hitCount = 0;
    _missCount = 0;
    _evictionCount = 0;
    _currentSize = 0;
    _peakSize = 0;
    _totalAdditions = 0;
    _totalRemovals = 0;
    _lastOperationAt = DateTime.now();
  }

  /// Converts stats to JSON for serialization
  Map<String, dynamic> toJson() {
    return {
      'hitCount': _hitCount,
      'missCount': _missCount,
      'totalRequests': totalRequests,
      'evictionCount': _evictionCount,
      'currentSize': _currentSize,
      'peakSize': _peakSize,
      'totalAdditions': _totalAdditions,
      'totalRemovals': _totalRemovals,
      'hitRate': hitRate,
      'missRate': missRate,
      'hitRatePercent': hitRatePercent,
      'missRatePercent': missRatePercent,
      'createdAt': _createdAt.toIso8601String(),
      'lastOperationAt': _lastOperationAt?.toIso8601String(),
    };
  }

  /// Creates stats from JSON
  factory CacheStats.fromJson(Map<String, dynamic> json) {
    final stats = CacheStats();
    stats._hitCount = json['hitCount'] as int? ?? 0;
    stats._missCount = json['missCount'] as int? ?? 0;
    stats._evictionCount = json['evictionCount'] as int? ?? 0;
    stats._currentSize = json['currentSize'] as int? ?? 0;
    stats._peakSize = json['peakSize'] as int? ?? 0;
    stats._totalAdditions = json['totalAdditions'] as int? ?? 0;
    stats._totalRemovals = json['totalRemovals'] as int? ?? 0;
    if (json['lastOperationAt'] != null) {
      stats._lastOperationAt = DateTime.parse(json['lastOperationAt'] as String);
    }
    return stats;
  }

  @override
  String toString() {
    return 'CacheStats('
        'hits: $_hitCount, '
        'misses: $_missCount, '
        'hitRate: ${(hitRatePercent).toStringAsFixed(1)}%, '
        'evictions: $_evictionCount, '
        'size: $_currentSize/$_peakSize)';
  }
}

/// Combined statistics for multi-layer cache system
///
/// Aggregates statistics from memory cache, disk cache, and network requests
/// to provide a comprehensive view of cache performance across all layers.
class CombinedCacheStats {
  /// Memory cache statistics
  final CacheStats memoryStats;

  /// Disk cache statistics
  final CacheStats diskStats;

  /// Network request count
  int networkRequestCount = 0;

  /// Creates combined cache stats
  CombinedCacheStats({
    required this.memoryStats,
    required this.diskStats,
    this.networkRequestCount = 0,
  });

  /// Total cache hits across all layers
  int get totalHits => memoryStats.hitCount + diskStats.hitCount;

  /// Total cache misses across all layers
  int get totalMisses => memoryStats.missCount + diskStats.missCount;

  /// Overall hit rate across all cache layers
  double get overallHitRate {
    final total = totalHits + totalMisses;
    if (total == 0) return 0.0;
    return totalHits / total;
  }

  /// Percentage of requests served from memory cache
  double get memoryCacheHitPercent {
    final total = totalHits + totalMisses + networkRequestCount;
    if (total == 0) return 0.0;
    return memoryStats.hitCount / total;
  }

  /// Percentage of requests served from disk cache
  double get diskCacheHitPercent {
    final total = totalHits + totalMisses + networkRequestCount;
    if (total == 0) return 0.0;
    return diskStats.hitCount / total;
  }

  /// Percentage of requests that went to network
  double get networkRequestPercent {
    final total = totalHits + totalMisses + networkRequestCount;
    if (total == 0) return 0.0;
    return networkRequestCount / total;
  }

  /// Converts combined stats to JSON
  Map<String, dynamic> toJson() {
    return {
      'memoryStats': memoryStats.toJson(),
      'diskStats': diskStats.toJson(),
      'networkRequestCount': networkRequestCount,
      'totalHits': totalHits,
      'totalMisses': totalMisses,
      'overallHitRate': overallHitRate,
      'memoryCacheHitPercent': memoryCacheHitPercent,
      'diskCacheHitPercent': diskCacheHitPercent,
      'networkRequestPercent': networkRequestPercent,
    };
  }

  /// Creates combined stats from JSON
  factory CombinedCacheStats.fromJson(Map<String, dynamic> json) {
    return CombinedCacheStats(
      memoryStats: CacheStats.fromJson(
          json['memoryStats'] as Map<String, dynamic>? ?? {}),
      diskStats:
          CacheStats.fromJson(json['diskStats'] as Map<String, dynamic>? ?? {}),
      networkRequestCount: json['networkRequestCount'] as int? ?? 0,
    );
  }

  @override
  String toString() {
    return 'CombinedCacheStats('
        'overallHitRate: ${(overallHitRate * 100).toStringAsFixed(1)}%, '
        'memory: ${(memoryCacheHitPercent * 100).toStringAsFixed(1)}%, '
        'disk: ${(diskCacheHitPercent * 100).toStringAsFixed(1)}%, '
        'network: ${(networkRequestPercent * 100).toStringAsFixed(1)}%)';
  }
}
