import 'dart:async';
import 'package:flutter/foundation.dart';

/// Type of batch operation
enum BatchOperationType {
  /// Insert new records
  insert,

  /// Update existing records
  update,

  /// Delete records
  delete,

  /// Upsert (insert or update if exists)
  upsert,
}

/// Result of a batch operation
class BatchOperationResult {
  /// Number of successful operations
  final int successCount;

  /// Number of failed operations
  final int failureCount;

  /// Total number of operations
  int get totalCount => successCount + failureCount;

  /// Success rate (0.0 to 1.0)
  double get successRate => totalCount > 0 ? successCount / totalCount : 0.0;

  /// Errors from failed operations
  final List<BatchError> errors;

  /// Whether all operations succeeded
  bool get isSuccessful => failureCount == 0;

  /// Whether all operations failed
  bool get isCompleteFailure => successCount == 0 && totalCount > 0;

  const BatchOperationResult({
    required this.successCount,
    required this.failureCount,
    this.errors = const [],
  });

  /// Create a successful result
  factory BatchOperationResult.success({required int count}) {
    return BatchOperationResult(
      successCount: count,
      failureCount: 0,
    );
  }

  /// Create a failed result
  factory BatchOperationResult.failure({
    required int successCount,
    required List<BatchError> errors,
  }) {
    return BatchOperationResult(
      successCount: successCount,
      failureCount: errors.length,
      errors: errors,
    );
  }

  @override
  String toString() {
    return 'BatchOperationResult('
        'success: $successCount, '
        'failed: $failureCount, '
        'successRate: ${(successRate * 100).toStringAsFixed(1)}%, '
        'errors: ${errors.length})';
  }
}

/// Error from a batch operation
class BatchError {
  /// Index of the item in the batch
  final int index;

  /// Error message
  final String message;

  /// Optional error details
  final dynamic details;

  /// The data that failed
  final Map<String, dynamic>? data;

  const BatchError({
    required this.index,
    required this.message,
    this.details,
    this.data,
  });

  @override
  String toString() {
    return 'BatchError(index: $index, message: $message)';
  }
}

/// Configuration for batch query operations
class BatchQueryConfig {
  /// Maximum number of items to process in a single batch
  final int batchSize;

  /// Maximum number of concurrent operations
  final int maxConcurrency;

  /// Whether to stop on first error
  final bool stopOnError;

  /// Delay between batches (to avoid rate limiting)
  final Duration batchDelay;

  /// Retry count for failed operations
  final int retryCount;

  /// Delay between retries
  final Duration retryDelay;

  const BatchQueryConfig({
    this.batchSize = 50,
    this.maxConcurrency = 5,
    this.stopOnError = false,
    this.batchDelay = Duration.zero,
    this.retryCount = 0,
    this.retryDelay = const Duration(milliseconds: 100),
  });

  /// Default configuration
  static const defaultConfig = BatchQueryConfig();

  /// Small batches (for quick operations)
  static const smallBatches = BatchQueryConfig(
    batchSize: 10,
  );

  /// Large batches (for bulk imports)
  static const largeBatches = BatchQueryConfig(
    batchSize: 100,
    batchDelay: Duration(milliseconds: 50),
  );

  /// Conservative (with rate limiting protection)
  static const conservative = BatchQueryConfig(
    batchSize: 25,
    maxConcurrency = 2,
    batchDelay: Duration(milliseconds: 200),
    retryCount: 2,
  );
}

/// Statistics for batch operations
class BatchQueryStats {
  /// Total number of batches processed
  final int totalBatches;

  /// Total number of items processed
  final int totalItems;

  /// Total time spent processing
  final Duration totalTime;

  /// Average time per batch
  Duration get averageBatchTime => totalBatches > 0
      ? Duration(
          microseconds: (totalTime.inMicroseconds / totalBatches).round())
      : Duration.zero;

  /// Average time per item
  Duration get averageItemTime => totalItems > 0
      ? Duration(microseconds: (totalTime.inMicroseconds / totalItems).round())
      : Duration.zero;

  /// Items processed per second
  double get itemsPerSecond => totalTime.inMicroseconds > 0
      ? (totalItems / totalTime.inMicroseconds) * 1000000
      : 0.0;

  const BatchQueryStats({
    required this.totalBatches,
    required this.totalItems,
    required this.totalTime,
  });

  @override
  String toString() {
    return 'BatchQueryStats('
        'batches: $totalBatches, '
        'items: $totalItems, '
        'totalTime: ${totalTime.inMilliseconds}ms, '
        'avgBatchTime: ${averageBatchTime.inMilliseconds}ms, '
        'items/sec: ${itemsPerSecond.toStringAsFixed(1)})';
  }
}

/// A single batch operation
class _BatchOperation<T> {
  /// The data to process
  final T data;

  /// Index in the overall batch
  final int index;

  /// Retry count
  int retryCount = 0;

  _BatchOperation({
    required this.data,
    required this.index,
  });
}

/// Builder for executing batch database operations
///
/// This utility helps execute large batch operations (inserts, updates, deletes)
/// efficiently by:
/// - Splitting large batches into manageable chunks
/// - Executing operations in parallel with concurrency limits
/// - Handling errors gracefully
/// - Providing retry logic
/// - Avoiding rate limiting with delays
///
/// Example usage:
/// ```dart
/// final builder = BatchQueryBuilder<Map<String, dynamic>>();
///
/// // Batch insert activities
/// final result = await builder.insert(
///   items: activitiesToInsert,
///   tableName: 'activities',
///   operation: (data) => supabase.from('activities').insert(data),
/// );
///
/// print('Inserted ${result.successCount} activities');
/// ```
class BatchQueryBuilder<T> {
  /// Configuration for this builder
  final BatchQueryConfig config;

  /// Whether debug logging is enabled
  final bool debug;

  /// Statistics tracking
  int _totalBatches = 0;
  int _totalItems = 0;
  Duration _totalTime = Duration.zero;

  /// Optional progress callback
  final void Function(int processed, int total)? onProgress;

  BatchQueryBuilder({
    this.config = BatchQueryConfig.defaultConfig,
    this.debug = false,
    this.onProgress,
  });

  /// Execute a batch of insert operations
  ///
  /// Parameters:
  /// - [items]: List of items to insert
  /// - [tableName]: Name of the table (for logging)
  /// - [operation]: Function that performs a single insert
  ///
  /// Returns the result of the batch operation
  Future<BatchOperationResult> insert({
    required List<T> items,
    required String? tableName,
    required Future<void> Function(T data) operation,
  }) async {
    return _executeBatch(
      items: items,
      operationType: BatchOperationType.insert,
      tableName: tableName,
      operation: operation,
    );
  }

  /// Execute a batch of update operations
  ///
  /// Parameters:
  /// - [items]: List of items to update
  /// - [tableName]: Name of the table (for logging)
  /// - [operation]: Function that performs a single update
  ///
  /// Returns the result of the batch operation
  Future<BatchOperationResult> update({
    required List<T> items,
    required String? tableName,
    required Future<void> Function(T data) operation,
  }) async {
    return _executeBatch(
      items: items,
      operationType: BatchOperationType.update,
      tableName: tableName,
      operation: operation,
    );
  }

  /// Execute a batch of delete operations
  ///
  /// Parameters:
  /// - [items]: List of items to delete
  /// - [tableName]: Name of the table (for logging)
  /// - [operation]: Function that performs a single delete
  ///
  /// Returns the result of the batch operation
  Future<BatchOperationResult> delete({
    required List<T> items,
    required String? tableName,
    required Future<void> Function(T data) operation,
  }) async {
    return _executeBatch(
      items: items,
      operationType: BatchOperationType.delete,
      tableName: tableName,
      operation: operation,
    );
  }

  /// Execute a batch of upsert operations
  ///
  /// Parameters:
  /// - [items]: List of items to upsert
  /// - [tableName]: Name of the table (for logging)
  /// - [operation]: Function that performs a single upsert
  ///
  /// Returns the result of the batch operation
  Future<BatchOperationResult> upsert({
    required List<T> items,
    required String? tableName,
    required Future<void> Function(T data) operation,
  }) async {
    return _executeBatch(
      items: items,
      operationType: BatchOperationType.upsert,
      tableName: tableName,
      operation: operation,
    );
  }

  /// Execute a custom batch operation
  ///
  /// Parameters:
  /// - [items]: List of items to process
  /// - [operation]: Function that processes a single item
  /// - [operationName]: Name of the operation (for logging)
  ///
  /// Returns the result of the batch operation
  Future<BatchOperationResult> executeCustom({
    required List<T> items,
    required Future<void> Function(T data) operation,
    String? operationName,
  }) async {
    return _executeBatch(
      items: items,
      operationType: BatchOperationType.insert,
      tableName: operationName,
      operation: operation,
    );
  }

  /// Internal method to execute a batch
  Future<BatchOperationResult> _executeBatch({
    required List<T> items,
    required BatchOperationType operationType,
    required String? tableName,
    required Future<void> Function(T data) operation,
  }) async {
    if (items.isEmpty) {
      if (debug) {
        debugPrint('[BatchQueryBuilder] No items to process');
      }
      return const BatchOperationResult(successCount: 0, failureCount: 0);
    }

    final stopwatch = Stopwatch()..start();

    if (debug) {
      debugPrint('[BatchQueryBuilder] Starting ${operationType.name} '
          'on ${tableName ?? 'unknown'}: ${items.length} items');
    }

    int successCount = 0;
    int failureCount = 0;
    final errors = <BatchError>[];
    int processedCount = 0;

    // Split into batches
    final batches = _splitIntoBatches(items);

    for (final batch in batches) {
      final batchResults = await _processBatch(
        batch: batch,
        operation: operation,
      );

      successCount += batchResults['success'] as int;
      failureCount += batchResults['failed'] as int;
      errors.addAll(batchResults['errors'] as List<BatchError>);

      processedCount += batch.length;
      onProgress?.call(processedCount, items.length);

      // Stop if configured and there are failures
      if (config.stopOnError && errors.isNotEmpty) {
        if (debug) {
          debugPrint('[BatchQueryBuilder] Stopping due to errors');
        }
        break;
      }

      // Delay between batches
      if (batch != batches.last && config.batchDelay > Duration.zero) {
        await Future.delayed(config.batchDelay);
      }
    }

    stopwatch.stop();

    // Update statistics
    _totalBatches += batches.length;
    _totalItems += items.length;
    _totalTime += stopwatch.elapsed;

    if (debug) {
      debugPrint('[BatchQueryBuilder] Completed ${operationType.name}: '
          'success: $successCount, failed: $failureCount, '
          'time: ${stopwatch.elapsedMilliseconds}ms');
    }

    if (errors.isEmpty) {
      return BatchOperationResult.success(count: successCount);
    } else {
      return BatchOperationResult.failure(
        successCount: successCount,
        errors: errors,
      );
    }
  }

  /// Split items into batches based on configuration
  List<List<_BatchOperation<T>>> _splitIntoBatches(List<T> items) {
    final batches = <List<_BatchOperation<T>>>[];

    for (int i = 0; i < items.length; i += config.batchSize) {
      final end = (i + config.batchSize < items.length)
          ? i + config.batchSize
          : items.length;

      final batchItems = items
          .skip(i)
          .take(end - i)
          .toList()
          .asMap()
          .entries
          .map((entry) => _BatchOperation(
                data: entry.value,
                index: i + entry.key,
              ))
          .toList();

      batches.add(batchItems);
    }

    return batches;
  }

  /// Process a single batch
  Future<Map<String, dynamic>> _processBatch({
    required List<_BatchOperation<T>> batch,
    required Future<void> Function(T data) operation,
  }) async {
    int successCount = 0;
    int failureCount = 0;
    final errors = <BatchError>[];

    if (config.maxConcurrency <= 1) {
      // Sequential processing
      for (final item in batch) {
        final result = await _processItem(
          item: item,
          operation: operation,
        );

        if (result.success) {
          successCount++;
        } else {
          failureCount++;
          if (result.error != null) {
            errors.add(result.error!);
          }
        }
      }
    } else {
      // Parallel processing with concurrency limit
      final results = await _processBatchParallel(
        batch: batch,
        operation: operation,
      );

      successCount = results['success'] as int;
      failureCount = results['failed'] as int;
      errors = results['errors'] as List<BatchError>;
    }

    return {
      'success': successCount,
      'failed': failureCount,
      'errors': errors,
    };
  }

  /// Process a batch in parallel with concurrency limit
  Future<Map<String, dynamic>> _processBatchParallel({
    required List<_BatchOperation<T>> batch,
    required Future<void> Function(T data) operation,
  }) async {
    int successCount = 0;
    int failureCount = 0;
    final errors = <BatchError>[];

    // Process in chunks based on maxConcurrency
    for (int i = 0; i < batch.length; i += config.maxConcurrency) {
      final end = (i + config.maxConcurrency < batch.length)
          ? i + config.maxConcurrency
          : batch.length;

      final chunk = batch.skip(i).take(end - i);

      final results = await Future.wait(
        chunk.map((item) => _processItem(item: item, operation: operation)),
      );

      for (final result in results) {
        if (result.success) {
          successCount++;
        } else {
          failureCount++;
          if (result.error != null) {
            errors.add(result.error!);
          }
        }
      }
    }

    return {
      'success': successCount,
      'failed': failureCount,
      'errors': errors,
    };
  }

  /// Process a single item with retry logic
  Future<(bool success, BatchError? error)> _processItem({
    required _BatchOperation<T> item,
    required Future<void> Function(T data) operation,
  }) async {
    for (int attempt = 0; attempt <= config.retryCount; attempt++) {
      try {
        await operation(item.data);
        return (success: true, error: null);
      } catch (error, stackTrace) {
        if (attempt < config.retryCount) {
          // Retry after delay
          if (config.retryDelay > Duration.zero) {
            await Future.delayed(config.retryDelay);
          }
          if (debug) {
            debugPrint('[BatchQueryBuilder] Retry ${attempt + 1} '
                'for item ${item.index}: $error');
          }
        } else {
          // All retries exhausted
          if (debug) {
            debugPrint(
                '[BatchQueryBuilder] Failed at item ${item.index}: $error');
            if (kDebugMode) {
              debugPrint(stackTrace.toString());
            }
          }

          final batchError = BatchError(
            index: item.index,
            message: error.toString(),
            data: item.data is Map<String, dynamic>
                ? item.data as Map<String, dynamic>
                : null,
          );

          return (success: false, error: batchError);
        }
      }
    }

    return (success: false, error: null);
  }

  /// Get current statistics
  BatchQueryStats get stats {
    return BatchQueryStats(
      totalBatches: _totalBatches,
      totalItems: _totalItems,
      totalTime: _totalTime,
    );
  }

  /// Reset statistics
  void resetStats() {
    _totalBatches = 0;
    _totalItems = 0;
    _totalTime = Duration.zero;

    if (debug) {
      debugPrint('[BatchQueryBuilder] Statistics reset');
    }
  }
}
