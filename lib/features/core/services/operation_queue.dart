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
    _pendingOperations.add(operation);
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

      // Process operations in priority order
      final operations = _pendingOperations.toList()
        ..sort((a, b) => b.priority.compareTo(a.priority));

      final operationsToRemove = <QueueableOperation>[];
      final operationsToAdd = <QueueableOperation>[];
      final operationsToFail = <QueueableOperation>[];

      for (final operation in operations) {
        // Skip operations that cannot be processed (offline, auth, or in backoff)
        if (!_canProcess(operation)) continue;

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
}
