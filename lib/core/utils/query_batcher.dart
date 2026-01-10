import 'dart:async';
import 'package:flutter/foundation.dart';

/// Result of a batched query operation
class BatchResult<T> {
  /// The result of the query
  final T? data;

  /// Whether the query was successful
  final bool success;

  /// Error message if the query failed
  final String? error;

  /// The key that identifies this query
  final String key;

  /// Timestamp when the query completed
  final DateTime timestamp;

  /// Duration of the query execution
  final Duration duration;

  const BatchResult({
    this.data,
    required this.success,
    this.error,
    required this.key,
    required this.timestamp,
    required this.duration,
  });

  /// Create a successful result
  factory BatchResult.success({
    required String key,
    required T data,
    required Duration duration,
  }) {
    return BatchResult<T>(
      data: data,
      success: true,
      key: key,
      timestamp: DateTime.now(),
      duration: duration,
    );
  }

  /// Create a failed result
  factory BatchResult.failure({
    required String key,
    required String error,
  }) {
    return BatchResult<T>(
      data: null,
      success: false,
      error: error,
      key: key,
      timestamp: DateTime.now(),
      duration: Duration.zero,
    );
  }

  @override
  String toString() {
    return 'BatchResult('
        'key: $key, '
        'success: $success, '
        'data: ${data != null ? 'present' : 'null'}, '
        'error: $error, '
        'duration: ${duration.inMilliseconds}ms)';
  }
}

/// A single query in a batch operation
class _BatchQuery<T> {
  /// Unique key for this query
  final String key;

  /// The query function to execute
  final Future<T> Function() query;

  /// Optional priority (lower number = higher priority)
  final int priority;

  /// Completer for the query result
  final Completer<BatchResult<T>> completer;

  _BatchQuery({
    required this.key,
    required this.query,
    this.priority = 0,
  }) : completer = Completer<BatchResult<T>>();
}

/// Configuration for query batching behavior
class BatchConfig {
  /// Maximum number of queries to batch together
  final int maxBatchSize;

  /// Maximum time to wait before executing a partial batch
  final Duration maxWaitTime;

  /// Whether to execute queries in parallel (true) or sequentially (false)
  final bool parallel;

  /// Maximum number of concurrent queries (only used if parallel is true)
  final int maxConcurrency;

  /// Whether to deduplicate queries with the same key
  final bool deduplicate;

  const BatchConfig({
    this.maxBatchSize = 10,
    this.maxWaitTime = const Duration(milliseconds: 100),
    this.parallel = true,
    this.maxConcurrency = 5,
    this.deduplicate = true,
  });

  /// Default configuration for typical use cases
  static const defaultConfig = BatchConfig();

  /// Aggressive batching (larger batches, longer wait)
  static const aggressive = BatchConfig(
    maxBatchSize: 20,
    maxWaitTime: Duration(milliseconds: 200),
  );

  /// Immediate execution (small batches, short wait)
  static const immediate = BatchConfig(
    maxBatchSize: 5,
    maxWaitTime: Duration(milliseconds: 50),
  );

  /// Sequential execution (no parallelism)
  static const sequential = BatchConfig(
    parallel: false,
  );
}

/// Statistics about batch execution
class BatchStatistics {
  /// Total number of batches executed
  final int totalBatches;

  /// Total number of queries executed
  final int totalQueries;

  /// Number of successful queries
  final int successfulQueries;

  /// Number of failed queries
  final int failedQueries;

  /// Average batch size
  final double averageBatchSize;

  /// Total time spent executing batches
  final Duration totalExecutionTime;

  /// Average batch execution time
  final Duration averageBatchTime;

  /// Number of deduplicated queries
  final int deduplicatedQueries;

  const BatchStatistics({
    required this.totalBatches,
    required this.totalQueries,
    required this.successfulQueries,
    required this.failedQueries,
    required this.averageBatchSize,
    required this.totalExecutionTime,
    required this.averageBatchTime,
    this.deduplicatedQueries = 0,
  });

  /// Success rate (0.0 to 1.0)
  double get successRate =>
      totalQueries > 0 ? successfulQueries / totalQueries : 0.0;

  @override
  String toString() {
    return 'BatchStatistics('
        'batches: $totalBatches, '
        'queries: $totalQueries, '
        'success: $successfulQueries, '
        'failed: $failedQueries, '
        'successRate: ${(successRate * 100).toStringAsFixed(1)}%, '
        'avgBatchSize: ${averageBatchSize.toStringAsFixed(1)}, '
        'totalTime: ${totalExecutionTime.inMilliseconds}ms, '
        'avgTime: ${averageBatchTime.inMilliseconds}ms, '
        'deduplicated: $deduplicatedQueries)';
  }
}

/// A utility class for batching multiple queries together
///
/// Query batching improves performance by:
/// - Reducing the number of round-trips to data sources
/// - Allowing parallel execution of independent queries
/// - Optimizing resource usage
/// - Providing better error handling
///
/// Example usage:
/// ```dart
/// final batcher = QueryBatcher(config: BatchConfig.aggressive);
///
/// // Add queries to the batch
/// final tripsFuture = batcher.add(
///   key: 'trips',
///   query: () => repository.getTrips(userId: 'user123'),
/// );
///
/// final activitiesFuture = batcher.add(
///   key: 'activities',
///   query: () => repository.getActivities(userId: 'user123'),
/// );
///
/// // Execute all queries in the batch
/// final results = await batcher.execute();
///
/// final trips = results['trips']?.data as List<Trip>;
/// final activities = results['activities']?.data as List<Activity>;
/// ```
class QueryBatcher {
  /// Queries waiting to be executed
  final List<_BatchQuery> _pendingQueries = [];

  /// Currently executing queries
  final Set<String> _executingKeys = {};

  /// Configuration for batching behavior
  final BatchConfig config;

  /// Timer for auto-executing partial batches
  Timer? _batchTimer;

  /// Whether the batcher has been disposed
  bool _disposed = false;

  /// Statistics tracking
  int _totalBatches = 0;
  int _totalQueries = 0;
  int _successfulQueries = 0;
  int _failedQueries = 0;
  Duration _totalExecutionTime = Duration.zero;
  int _deduplicatedQueries = 0;

  /// Whether to log debug messages
  final bool debug;

  /// Optional callback when a batch is executed
  final void Function(BatchStatistics)? onBatchExecuted;

  QueryBatcher({
    this.config = BatchConfig.defaultConfig,
    this.debug = false,
    this.onBatchExecuted,
  });

  /// Add a query to the batch
  ///
  /// Parameters:
  /// - [key]: Unique identifier for this query
  /// - [query]: The async function to execute
  /// - [priority]: Optional priority (lower number = higher priority)
  ///
  /// Returns a Future that completes with the query result
  ///
  /// Example:
  /// ```dart
  /// final result = await batcher.add(
  ///   key: 'user-trips',
  ///   query: () => tripRepository.getTrips(userId: 'user123'),
  /// );
  /// ```
  Future<BatchResult<T>> add<T>({
    required String key,
    required Future<T> Function() query,
    int priority = 0,
  }) {
    if (_disposed) {
      throw StateError('QueryBatcher has been disposed');
    }

    // Check for duplicate keys if deduplication is enabled
    if (config.deduplicate) {
      final existing = _pendingQueries.cast<_BatchQuery?>().firstWhere(
            (q) => q?.key == key,
            orElse: () => null,
          );

      if (existing != null) {
        _deduplicatedQueries++;
        if (debug) {
          debugPrint('[QueryBatcher] Duplicate query key: "$key" '
              '(deduplicated, total: $_deduplicatedQueries)');
        }
        return existing.completer.future as Future<BatchResult<T>>;
      }
    }

    final batchQuery = _BatchQuery<T>(
      key: key,
      query: query,
      priority: priority,
    );

    _pendingQueries.add(batchQuery);
    _totalQueries++;

    if (debug) {
      debugPrint('[QueryBatcher] Added query: "$key" '
          '(pending: ${_pendingQueries.length})');
    }

    // Auto-execute if batch is full
    if (_pendingQueries.length >= config.maxBatchSize) {
      if (debug) {
        debugPrint('[QueryBatcher] Batch full (${config.maxBatchSize}), '
            'executing immediately');
      }
      _scheduleExecution();
    } else {
      // Set timer for auto-execution of partial batches
      _resetBatchTimer();
    }

    return batchQuery.completer.future;
  }

  /// Execute all pending queries
  ///
  /// Returns a map of query keys to their results
  Future<Map<String, BatchResult>> execute() async {
    if (_disposed) {
      throw StateError('QueryBatcher has been disposed');
    }

    // Cancel timer if active
    _batchTimer?.cancel();
    _batchTimer = null;

    if (_pendingQueries.isEmpty) {
      if (debug) {
        debugPrint('[QueryBatcher] No queries to execute');
      }
      return {};
    }

    final stopwatch = Stopwatch()..start();

    // Sort by priority if needed
    if (_pendingQueries.any((q) => q.priority != 0)) {
      _pendingQueries.sort((a, b) => a.priority.compareTo(b.priority));
      if (debug) {
        debugPrint(
            '[QueryBatcher] Sorted ${_pendingQueries.length} queries by priority');
      }
    }

    // Execute queries
    final results =
        config.parallel ? await _executeParallel() : await _executeSequential();

    stopwatch.stop();

    // Update statistics
    _totalBatches++;
    _totalExecutionTime += stopwatch.elapsed;

    // Generate statistics
    final stats = BatchStatistics(
      totalBatches: _totalBatches,
      totalQueries: _totalQueries,
      successfulQueries: _successfulQueries,
      failedQueries: _failedQueries,
      averageBatchSize: _totalBatches > 0 ? _totalQueries / _totalBatches : 0,
      totalExecutionTime: _totalExecutionTime,
      averageBatchTime: _totalBatches > 0
          ? Duration(
              microseconds:
                  (_totalExecutionTime.inMicroseconds / _totalBatches).round())
          : Duration.zero,
      deduplicatedQueries: _deduplicatedQueries,
    );

    if (debug) {
      debugPrint(
          '[QueryBatcher] Batch executed in ${stopwatch.elapsedMilliseconds}ms: $stats');
    }

    // Notify callback
    onBatchExecuted?.call(stats);

    return results;
  }

  /// Execute queries in parallel
  Future<Map<String, BatchResult>> _executeParallel() async {
    final results = <String, BatchResult>{};
    final queriesToExecute = List<_BatchQuery>.from(_pendingQueries);
    _pendingQueries.clear();

    // Execute with concurrency limit
    for (final query in queriesToExecute) {
      _executingKeys.add(query.key);
    }

    final futures = queriesToExecute.map((query) async {
      final stopwatch = Stopwatch()..start();

      try {
        final data = await query.query();
        stopwatch.stop();

        final result = BatchResult.success(
          key: query.key,
          data: data,
          duration: stopwatch.elapsed,
        );

        _successfulQueries++;

        if (debug) {
          debugPrint('[QueryBatcher] Query "$query.key" succeeded in '
              '${stopwatch.elapsedMilliseconds}ms');
        }

        return result;
      } catch (error, stackTrace) {
        stopwatch.stop();
        _failedQueries++;

        final errorMessage = error.toString();
        if (debug) {
          debugPrint('[QueryBatcher] Query "$query.key" failed: $errorMessage');
          debugPrint(stackTrace.toString());
        }

        return BatchResult.failure(
          key: query.key,
          error: errorMessage,
        );
      } finally {
        _executingKeys.remove(query.key);
      }
    });

    // Wait for all queries (with concurrency limit)
    if (config.maxConcurrency > 0 && config.maxConcurrency < futures.length) {
      // Execute in chunks
      for (int i = 0; i < futures.length; i += config.maxConcurrency) {
        final end = (i + config.maxConcurrency < futures.length)
            ? i + config.maxConcurrency
            : futures.length;
        final chunk = futures.skip(i).take(end - i);
        final chunkResults = await Future.wait(chunk);
        for (final result in chunkResults) {
          results[result.key] = result;
        }
      }
    } else {
      // Execute all at once
      final allResults = await Future.wait(futures);
      for (final result in allResults) {
        results[result.key] = result;
      }
    }

    // Complete all completors
    for (final query in queriesToExecute) {
      if (!query.completer.isCompleted) {
        query.completer.complete(results[query.key]);
      }
    }

    return results;
  }

  /// Execute queries sequentially
  Future<Map<String, BatchResult>> _executeSequential() async {
    final results = <String, BatchResult>{};
    final queriesToExecute = List<_BatchQuery>.from(_pendingQueries);
    _pendingQueries.clear();

    for (final query in queriesToExecute) {
      _executingKeys.add(query.key);

      final stopwatch = Stopwatch()..start();

      try {
        final data = await query.query();
        stopwatch.stop();

        final result = BatchResult.success(
          key: query.key,
          data: data,
          duration: stopwatch.elapsed,
        );

        results[query.key] = result;
        _successfulQueries++;

        if (debug) {
          debugPrint('[QueryBatcher] Query "$query.key" succeeded in '
              '${stopwatch.elapsedMilliseconds}ms');
        }
      } catch (error, stackTrace) {
        stopwatch.stop();
        _failedQueries++;

        final errorMessage = error.toString();
        if (debug) {
          debugPrint('[QueryBatcher] Query "$query.key" failed: $errorMessage');
          debugPrint(stackTrace.toString());
        }

        results[query.key] = BatchResult.failure(
          key: query.key,
          error: errorMessage,
        );
      } finally {
        _executingKeys.remove(query.key);
      }

      // Complete the completer
      if (!query.completer.isCompleted) {
        query.completer.complete(results[query.key]);
      }
    }

    return results;
  }

  /// Reset the batch timer
  void _resetBatchTimer() {
    _batchTimer?.cancel();
    _batchTimer = Timer(config.maxWaitTime, () {
      if (_pendingQueries.isNotEmpty) {
        if (debug) {
          debugPrint('[QueryBatcher] Max wait time reached, '
              'executing ${_pendingQueries.length} pending queries');
        }
        execute();
      }
    });
  }

  /// Schedule execution (for immediate execution when batch is full)
  void _scheduleExecution() {
    _batchTimer?.cancel();
    _batchTimer = Timer(Duration.zero, () => execute());
  }

  /// Cancel all pending queries
  ///
  /// Returns the number of queries that were cancelled
  int cancelPending() {
    final count = _pendingQueries.length;
    for (final query in _pendingQueries) {
      if (!query.completer.isCompleted) {
        query.completer.completeError(
          StateError('Query cancelled'),
        );
      }
    }
    _pendingQueries.clear();
    _batchTimer?.cancel();
    _batchTimer = null;

    if (debug && count > 0) {
      debugPrint('[QueryBatcher] Cancelled $count pending queries');
    }

    return count;
  }

  /// Get the number of pending queries
  int get pendingCount => _pendingQueries.length;

  /// Get the number of currently executing queries
  int get executingCount => _executingKeys.length;

  /// Get current statistics
  BatchStatistics get statistics {
    return BatchStatistics(
      totalBatches: _totalBatches,
      totalQueries: _totalQueries,
      successfulQueries: _successfulQueries,
      failedQueries: _failedQueries,
      averageBatchSize: _totalBatches > 0 ? _totalQueries / _totalBatches : 0,
      totalExecutionTime: _totalExecutionTime,
      averageBatchTime: _totalBatches > 0
          ? Duration(
              microseconds:
                  (_totalExecutionTime.inMicroseconds / _totalBatches).round())
          : Duration.zero,
      deduplicatedQueries: _deduplicatedQueries,
    );
  }

  /// Clear statistics (reset counters)
  void clearStatistics() {
    _totalBatches = 0;
    _totalQueries = 0;
    _successfulQueries = 0;
    _failedQueries = 0;
    _totalExecutionTime = Duration.zero;
    _deduplicatedQueries = 0;

    if (debug) {
      debugPrint('[QueryBatcher] Statistics cleared');
    }
  }

  /// Dispose the batcher (cleanup resources)
  ///
  /// This will cancel any pending queries and prevent new queries from being added
  void dispose() {
    if (_disposed) return;

    cancelPending();
    _disposed = true;

    if (debug) {
      debugPrint('[QueryBatcher] Disposed');
    }
  }

  @override
  String toString() {
    return 'QueryBatcher('
        'pending: $pendingCount, '
        'executing: $executingCount, '
        'config: $config, '
        'stats: $statistics)';
  }
}
