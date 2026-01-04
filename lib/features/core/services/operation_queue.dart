import 'dart:async';
import 'dart:collection';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../providers/connectivity_provider.dart';
import '../../auth/domain/services/token_manager.dart';
import 'operation_storage_service.dart';
import 'retry_strategy.dart';
import '../../travel/domain/models/trip_planning_operation.dart';
import '../../travel/domain/models/travel_note_operation.dart';
import '../../travel/domain/models/location_update_operation.dart';

part 'operation_queue.g.dart';

/// Represents an operation that can be queued for later execution
abstract class QueueableOperation {
  /// Unique identifier for the operation
  String get id;

  /// Type of operation for grouping and processing
  String get type;

  /// Priority of the operation (higher number = higher priority)
  int get priority;

  /// Whether this operation requires an active network connection
  bool get requiresNetwork;

  /// Timestamp when the operation was created
  DateTime? get createdAt;

  /// Timestamp of the last execution attempt
  DateTime? get lastAttempt;

  /// Number of times this operation has been attempted
  int get attemptCount;

  /// Error message from the last failed attempt (if any)
  String? get lastError;

  /// Maximum number of retry attempts allowed
  int get maxRetries;

  /// Optional deduplication key to prevent duplicate operations
  /// If two operations have the same deduplication key, the newer one
  /// will replace the older one in the queue. Return null to disable
  /// deduplication for this operation type.
  String? get deduplicationKey;

  /// Execute the operation
  Future<void> execute();

  /// Convert operation to JSON for persistence
  Map<String, dynamic> toJson();
}

@riverpod
class OperationQueue extends _$OperationQueue {
  final Queue<QueueableOperation> _pendingOperations = Queue();
  final List<QueueableOperation> _failedOperations = [];
  Timer? _processingTimer;
  bool _isProcessing = false;

  /// Retry strategy for calculating backoff delays
  final RetryStrategy retryStrategy = const ExponentialBackoffStrategy(
    baseDelay: Duration(seconds: 1),
    maxDelay: Duration(minutes: 5),
    jitterFactor: 0.1,
  );

  /// Track consecutive operations processed per priority level for round-robin
  final Map<int, int> _consecutiveProcessedByPriority = {};

  /// Maximum consecutive operations to process per priority level
  static const int _maxConsecutivePerPriority = 3;

  /// Age threshold after which low-priority operations get a priority boost
  static const Duration _agingBoostThreshold = Duration(minutes: 5);

  /// Priority boost amount for operations that have been waiting too long
  static const int _agingBoostAmount = 20;

  @override
  Future<void> build() async {
    // Watch connectivity and token state
    ref.watch(connectivityNotifierProvider);
    ref.watch(tokenManagerProvider);

    // Initialize storage service and load saved queue
    await _loadQueue();

    // Setup periodic processing
    _setupProcessing();

    // Clean up on dispose
    ref.onDispose(() {
      _processingTimer?.cancel();
    });
  }

  void _setupProcessing() {
    _processingTimer?.cancel();
    _processingTimer = Timer.periodic(
      const Duration(seconds: 30),
      (_) => processQueue(),
    );
  }

  /// Add an operation to the queue
  Future<void> addOperation(QueueableOperation operation) async {
    // Check for duplicate operations if this operation has a deduplication key
    final duplicate = _findDuplicate(operation);
    if (duplicate != null) {
      debugPrint('OperationQueue: Found duplicate operation ${duplicate.id}, replacing with ${operation.id}');
      _replaceOperation(duplicate, operation);
    } else {
      _pendingOperations.add(operation);
    }

    await _persistQueue();

    // Try to process immediately if conditions are right
    if (_canProcess(operation)) {
      processQueue();
    }
  }

  /// Process all operations in the queue that can be executed
  Future<void> processQueue() async {
    if (_isProcessing) return;
    _isProcessing = true;

    try {
      final tokenManager = ref.read(tokenManagerProvider);
      final isOnline = ref.read(connectivityNotifierProvider);

      // Process operations in effective priority order (with aging boost)
      final operations = _pendingOperations.toList()
        ..sort((a, b) {
          final priorityA = _getEffectivePriority(a);
          final priorityB = _getEffectivePriority(b);
          return priorityB.compareTo(priorityA); // Higher priority first
        });

      final operationsToRemove = <QueueableOperation>[];
      final operationsToAdd = <QueueableOperation>[];
      final operationsToFail = <QueueableOperation>[];

      for (final operation in operations) {
        // Skip operations that cannot be processed (offline, auth, or in backoff)
        if (!_canProcess(operation)) continue;

        // Skip if round-robin limit reached for this priority level
        if (_shouldSkipDueToRoundRobin(operation)) continue;

        // Check if operation has exceeded max retries
        if (!_shouldRetry(operation)) {
          debugPrint('Operation ${operation.id} exceeded max retries (${operation.maxRetries}), moving to failed queue');
          operationsToFail.add(operation);
          operationsToRemove.add(operation);
          continue;
        }

        try {
          await operation.execute();
          operationsToRemove.add(operation);

          // Update consecutive counter for successful processing
          final effectivePriority = _getEffectivePriority(operation);
          _consecutiveProcessedByPriority[effectivePriority] =
              (_consecutiveProcessedByPriority[effectivePriority] ?? 0) + 1;
        } catch (e, stackTrace) {
          debugPrint('Failed to execute operation ${operation.id}: $e');
          debugPrint('Stack trace: $stackTrace');

          // Update operation with error information and increment attempt count
          final failedOperation = _updateAttemptMetadata(operation, e.toString());

          // Check if this was the last retry attempt
          if (failedOperation.attemptCount >= failedOperation.maxRetries) {
            debugPrint('Operation ${operation.id} reached max retries, moving to failed queue');
            operationsToFail.add(failedOperation);
            operationsToRemove.add(operation);
          } else {
            // Replace the operation with the updated one for retry later
            operationsToRemove.add(operation);
            operationsToAdd.add(failedOperation);
          }

          // Reset round-robin counters on failure to allow retry in next cycle
          _resetRoundRobinCounters();
        }
      }

      // Update the queue
      for (final op in operationsToRemove) {
        _pendingOperations.remove(op);
      }
      for (final op in operationsToAdd) {
        _pendingOperations.add(op);
      }
      for (final op in operationsToFail) {
        _failedOperations.add(op);
      }

      await _persistQueue();

      // Reset round-robin counters at the end of each processing cycle
      _resetRoundRobinCounters();
    } finally {
      _isProcessing = false;
    }
  }

  /// Update operation metadata with attempt information
  QueueableOperation _updateAttemptMetadata(
    QueueableOperation operation,
    String? error,
  ) {
    // Use type checking and copyWith to update metadata
    if (operation is TripPlanningOperation) {
      return operation.copyWith(
        lastAttempt: DateTime.now(),
        attemptCount: operation.attemptCount + 1,
        lastError: error,
      );
    } else if (operation is TravelNoteOperation) {
      return operation.copyWith(
        lastAttempt: DateTime.now(),
        attemptCount: operation.attemptCount + 1,
        lastError: error,
      );
    } else if (operation is LocationUpdateOperation) {
      return operation.copyWith(
        lastAttempt: DateTime.now(),
        attemptCount: operation.attemptCount + 1,
        lastError: error,
      );
    }

    // Fallback: return operation as-is if type is unknown
    return operation;
  }

  bool _canProcess(QueueableOperation operation) {
    final tokenManager = ref.read(tokenManagerProvider);
    final isOnline = ref.read(connectivityNotifierProvider);

    // Check network and token requirements
    if (operation.requiresNetwork) {
      if (!isOnline || !tokenManager.canPerformOnlineOperations) {
        return false;
      }
    } else if (!tokenManager.hasValidTokens) {
      return false;
    }

    // Check if operation is in backoff period (has been attempted before and needs to wait)
    if (_isInBackoffPeriod(operation)) {
      return false;
    }

    return true;
  }

  /// Check if an operation should be retried based on attempt count
  bool _shouldRetry(QueueableOperation operation) {
    // Always retry if attempts haven't exceeded max
    return operation.attemptCount < operation.maxRetries;
  }

  /// Check if an operation is currently in its backoff period
  ///
  /// Returns true if the operation was attempted recently and the calculated
  /// backoff delay hasn't elapsed yet
  bool _isInBackoffPeriod(QueueableOperation operation) {
    // No backoff for first attempt
    if (operation.lastAttempt == null || operation.attemptCount == 0) {
      return false;
    }

    // Calculate expected backoff duration based on attempt count
    final backoffDelay = retryStrategy.calculateDelay(operation.attemptCount);

    // Calculate when this operation can be retried
    final retryTime = operation.lastAttempt!.add(backoffDelay);

    // Check if current time is past the retry time
    final now = DateTime.now();
    final inBackoff = now.isBefore(retryTime);

    if (inBackoff) {
      final timeUntilRetry = retryTime.difference(now);
      debugPrint(
        'Operation ${operation.id} is in backoff period. '
        'Can retry in ${timeUntilRetry.inSeconds}s'
      );
    }

    return inBackoff;
  }

  /// Calculate the effective priority of an operation with aging boost
  ///
  /// This prevents starvation by gradually increasing the priority of operations
  /// that have been waiting in the queue for a long time. Low-priority operations
  /// that exceed the aging threshold get a priority boost to ensure they eventually
  /// get processed.
  int _getEffectivePriority(QueueableOperation operation) {
    final basePriority = operation.priority;

    // Check if operation has a creation timestamp
    final createdAt = operation.createdAt;
    if (createdAt == null) {
      // No timestamp, return base priority
      return basePriority;
    }

    // Calculate how long the operation has been waiting
    final now = DateTime.now();
    final age = now.difference(createdAt);

    // If operation has been waiting longer than the threshold, apply priority boost
    if (age > _agingBoostThreshold) {
      final boostedPriority = basePriority + _agingBoostAmount;

      // Log the priority boost for debugging
      if (boostedPriority > basePriority) {
        final ageMinutes = age.inMinutes;
        debugPrint(
          'Operation ${operation.id} has been waiting ${ageMinutes}min, '
          'boosting priority from $basePriority to $boostedPriority'
        );
      }

      return boostedPriority;
    }

    // Return base priority if no aging boost needed
    return basePriority;
  }

  /// Check if we should skip processing this operation due to round-robin limits
  ///
  /// This prevents the queue from processing too many consecutive operations
  /// of the same priority level, which ensures fair processing across all
  /// priority levels and prevents high-priority floods from starving lower
  /// priority operations completely.
  bool _shouldSkipDueToRoundRobin(QueueableOperation operation) {
    final effectivePriority = _getEffectivePriority(operation);
    final consecutiveCount = _consecutiveProcessedByPriority[effectivePriority] ?? 0;

    // Always process critical operations immediately (no round-robin limit)
    if (effectivePriority >= 1000) {
      return false;
    }

    // Skip if we've already processed too many operations of this priority level
    if (consecutiveCount >= _maxConsecutivePerPriority) {
      debugPrint(
        'Skipping operation ${operation.id} (priority $effectivePriority) - '
        'already processed $consecutiveCount consecutive operations of this priority'
      );
      return true;
    }

    return false;
  }

  /// Reset the round-robin counters when an operation fails to process
  ///
  /// This ensures that a failed operation doesn't count toward the consecutive
  /// limit, preventing the round-robin from being too aggressive.
  void _resetRoundRobinCounters() {
    _consecutiveProcessedByPriority.clear();
  }

  /// Find a duplicate operation in the pending queue based on deduplication key
  ///
  /// Returns the duplicate operation if found, or null if no duplicate exists
  /// or if the operation doesn't have a deduplication key
  QueueableOperation? _findDuplicate(QueueableOperation operation) {
    final dedupKey = operation.deduplicationKey;
    if (dedupKey == null) {
      // No deduplication key for this operation type
      return null;
    }

    try {
      return _pendingOperations.cast<QueueableOperation?>().firstWhere(
        (op) => op?.deduplicationKey == dedupKey && op?.id != operation.id,
        orElse: () => null,
      );
    } catch (e) {
      // If there's any error searching, just return null (no duplicate found)
      debugPrint('OperationQueue: Error searching for duplicate: $e');
      return null;
    }
  }

  /// Replace an existing operation with a newer version
  ///
  /// Removes the old operation from the queue and adds the new one.
  /// This is used when a duplicate operation is detected.
  void _replaceOperation(
    QueueableOperation oldOperation,
    QueueableOperation newOperation,
  ) {
    _pendingOperations.remove(oldOperation);
    _pendingOperations.add(newOperation);

    debugPrint(
      'OperationQueue: Replaced operation ${oldOperation.id} with ${newOperation.id} '
      '(deduplication key: ${newOperation.deduplicationKey})'
    );
  }

  /// Load saved queue from storage on initialization
  Future<void> _loadQueue() async {
    try {
      final storageService = ref.read(operationStorageServiceProvider);
      final result = await storageService.loadOperations();

      // Restore pending operations
      for (final opData in result.pendingOperations) {
        try {
          final operation = _deserializeOperation(opData);
          if (operation != null) {
            _pendingOperations.add(operation);
          }
        } catch (e, stackTrace) {
          debugPrint('Failed to deserialize pending operation: $e');
          debugPrint('Stack trace: $stackTrace');
        }
      }

      // Restore failed operations
      for (final opData in result.failedOperations) {
        try {
          final operation = _deserializeOperation(opData);
          if (operation != null) {
            _failedOperations.add(operation);
          }
        } catch (e, stackTrace) {
          debugPrint('Failed to deserialize failed operation: $e');
          debugPrint('Stack trace: $stackTrace');
        }
      }

      if (result.hadCorruptedData) {
        debugPrint('OperationQueue: Warning - some operations were corrupted and skipped');
      }

      debugPrint('OperationQueue: Loaded ${_pendingOperations.length} pending and ${_failedOperations.length} failed operations');
    } catch (e, stackTrace) {
      debugPrint('OperationQueue: Error loading queue from storage: $e');
      debugPrint('Stack trace: $stackTrace');
      // Continue with empty queue if loading fails
    }
  }

  /// Deserialize operation from JSON based on type
  QueueableOperation? _deserializeOperation(Map<String, dynamic> data) {
    try {
      final type = data['type'] as String?;

      if (type == null) {
        debugPrint('OperationQueue: Missing type in operation data');
        return null;
      }

      // Dispatch to appropriate factory based on type
      switch (type) {
        case 'trip_planning':
          return TripPlanningOperation.fromJson(data);
        case 'travel_note':
          return TravelNoteOperation.fromJson(data);
        case 'location_update':
          return LocationUpdateOperation.fromJson(data);
        default:
          debugPrint('OperationQueue: Unknown operation type: $type');
          return null;
      }
    } catch (e, stackTrace) {
      debugPrint('OperationQueue: Error deserializing operation: $e');
      debugPrint('Stack trace: $stackTrace');
      return null;
    }
  }

  /// Persist current queue state to storage
  Future<void> _persistQueue() async {
    try {
      final storageService = ref.read(operationStorageServiceProvider);

      // Save pending operations
      final pendingSuccess = await storageService.savePendingOperations(
        _pendingOperations.toList(),
      );

      // Save failed operations
      final failedSuccess = await storageService.saveFailedOperations(
        _failedOperations,
      );

      if (!pendingSuccess || !failedSuccess) {
        debugPrint('OperationQueue: Warning - some operations failed to persist');
      }
    } catch (e, stackTrace) {
      debugPrint('OperationQueue: Error persisting queue: $e');
      debugPrint('Stack trace: $stackTrace');
      // Continue even if persistence fails - operations are still in memory
    }
  }

  /// Get list of failed operations
  List<QueueableOperation> getFailedOperations() {
    return List.unmodifiable(_failedOperations);
  }

  /// Retry a specific failed operation by ID
  Future<void> retryOperation(String id) async {
    final operation = _failedOperations.cast<QueueableOperation?>().firstWhere(
      (op) => op?.id == id,
      orElse: () => null,
    );

    if (operation == null) {
      debugPrint('OperationQueue: Failed operation with id $id not found');
      return;
    }

    debugPrint('OperationQueue: Retrying failed operation ${operation.id}');

    // Remove from failed queue
    _failedOperations.remove(operation);

    // Reset metadata for retry
    final resetOperation = _resetAttemptMetadata(operation);

    // Add back to pending queue
    await addOperation(resetOperation);

    debugPrint('OperationQueue: Operation ${operation.id} moved back to pending queue');
  }

  /// Retry all failed operations
  Future<void> retryAllFailed() async {
    debugPrint('OperationQueue: Retrying all ${_failedOperations.length} failed operations');

    final operationsToRetry = List<QueueableOperation>.from(_failedOperations);

    // Clear failed queue
    _failedOperations.clear();

    // Reset metadata and add back to pending queue
    for (final operation in operationsToRetry) {
      final resetOperation = _resetAttemptMetadata(operation);
      await addOperation(resetOperation);
    }

    debugPrint('OperationQueue: Moved ${operationsToRetry.length} operations back to pending queue');
  }

  /// Clear all failed operations
  Future<void> clearFailedOperations() async {
    debugPrint('OperationQueue: Clearing all ${_failedOperations.length} failed operations');

    final count = _failedOperations.length;
    _failedOperations.clear();

    await _persistQueue();

    debugPrint('OperationQueue: Cleared $count failed operations');
  }

  /// Remove a specific failed operation by ID
  Future<void> removeFailedOperation(String id) async {
    final operation = _failedOperations.cast<QueueableOperation?>().firstWhere(
      (op) => op?.id == id,
      orElse: () => null,
    );

    if (operation == null) {
      debugPrint('OperationQueue: Failed operation with id $id not found');
      return;
    }

    debugPrint('OperationQueue: Removing failed operation ${operation.id}');

    _failedOperations.remove(operation);

    await _persistQueue();

    debugPrint('OperationQueue: Removed failed operation ${operation.id}');
  }

  /// Reset attempt metadata for retrying a failed operation
  QueueableOperation _resetAttemptMetadata(QueueableOperation operation) {
    // Use type checking and copyWith to reset metadata
    if (operation is TripPlanningOperation) {
      return operation.copyWith(
        lastAttempt: null,
        attemptCount: 0,
        lastError: null,
      );
    } else if (operation is TravelNoteOperation) {
      return operation.copyWith(
        lastAttempt: null,
        attemptCount: 0,
        lastError: null,
      );
    } else if (operation is LocationUpdateOperation) {
      return operation.copyWith(
        lastAttempt: null,
        attemptCount: 0,
        lastError: null,
      );
    }

    // Fallback: return operation as-is if type is unknown
    return operation;
  }
}
