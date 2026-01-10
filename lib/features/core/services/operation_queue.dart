import 'dart:async';
import 'dart:collection';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../providers/connectivity_provider.dart';
import '../../auth/domain/services/token_manager.dart';
import 'operation_storage_service.dart';
import 'retry_strategy.dart';
// Import operation types for deserialization
import '../../travel/domain/models/trip_planning_operation.dart';
import '../../travel/domain/models/travel_note_operation.dart';
import '../../travel/domain/models/location_update_operation.dart';

part 'operation_queue.g.dart';

/// Abstract interface for operations that can be queued for later execution.
///
/// Operations in the queue are executed based on priority, network connectivity,
/// and authentication status. Failed operations are retried with exponential
/// backoff up to [maxRetries] attempts.
///
/// ## Thread Safety
/// All queue operations are thread-safe. The queue processes operations sequentially
/// on a timer, ensuring no concurrent execution of the same operation.
///
/// ## Creating Custom Operations
/// To create a custom operation:
/// ```dart
/// class MyCustomOperation implements QueueableOperation {
///   @override
///   String get id => 'my_op_${DateTime.now().millisecondsSinceEpoch}';
///
///   @override
///   String get type => 'my_custom';
///
///   @override
///   int get priority => OperationPriority.normal.value;
///
///   @override
///   bool get requiresNetwork => true;
///
///   @override
///   DateTime? get createdAt => DateTime.now();
///
///   @override
///   DateTime? get lastAttempt => null;
///
///   @override
///   int get attemptCount => 0;
///
///   @override
///   String? get lastError => null;
///
///   @override
///   int get maxRetries => 3;
///
///   @override
///   String? get deduplicationKey => null;
///
///   @override
///   Future<void> execute() async {
///     // Your operation logic here
///   }
///
///   @override
///   Map<String, dynamic> toJson() => {
///     'id': id,
///     'type': type,
///     // ... other fields
///   };
/// }
/// ```
///
/// See [OperationQueue] for queue management operations.
abstract class QueueableOperation {
  /// Unique identifier for the operation.
  ///
  /// Must be unique across all operations. Typically generated using
  /// `uuid` or timestamp-based approaches.
  String get id;

  /// Type identifier for the operation (e.g., 'trip_planning', 'travel_note').
  ///
  /// Used for serialization/deserialization and grouping similar operations.
  /// Must match one of the known types in [OperationQueue._deserializeOperation].
  String get type;

  /// Priority value for this operation.
  ///
  /// Higher values indicate higher priority. Standard values are defined in
  /// [OperationPriority]:
  /// - Critical: 1000 (SOS/emergency operations)
  /// - High: 100 (authentication, payments)
  /// - Normal: 10 (trip updates, travel notes)
  /// - Low: 1 (location updates, analytics)
  ///
  /// Priority can be adjusted dynamically using aging mechanism to prevent
  /// starvation of low-priority operations.
  int get priority;

  /// Whether this operation requires an active network connection to execute.
  ///
  /// Operations that require network will only be processed when:
  /// - Device is online (see [ConnectivityNotifier])
  /// - User has valid authentication tokens
  ///
  /// Operations without network requirements still need valid auth tokens.
  bool get requiresNetwork;

  /// Timestamp when the operation was created.
  ///
  /// Used for aging mechanism - operations waiting longer than
  /// 5 minutes get a priority boost to prevent starvation.
  /// Should be set to `DateTime.now()` in operation constructors.
  DateTime? get createdAt;

  /// Timestamp of the last execution attempt.
  ///
  /// Updated after each attempt (successful or failed). Used to calculate
  /// exponential backoff delays for retry logic. Null for unattempted operations.
  DateTime? get lastAttempt;

  /// Number of times this operation has been attempted.
  ///
  /// Increments after each execution attempt (including failures). Operations
  /// exceeding [maxRetries] are moved to the failed queue for manual intervention.
  int get attemptCount;

  /// Error message from the last failed attempt, if any.
  ///
  /// Contains error details from the most recent failed execution.
  /// Used for debugging and displaying error messages in the UI.
  /// Cleared when operation is reset for retry.
  String? get lastError;

  /// Maximum number of retry attempts allowed.
  ///
  /// After this many failed attempts, the operation is moved to the failed
  /// operations queue. Typical value is 3, but can be adjusted per operation type.
  /// Operation will be attempted `maxRetries + 1` times total (initial + retries).
  int get maxRetries;

  /// Optional deduplication key to prevent duplicate operations.
  ///
  /// If two operations have the same non-null deduplication key, the newer one
  /// will replace the older one in the queue. This prevents redundant operations
  /// from accumulating (e.g., multiple rapid updates to the same trip).
  ///
  /// Return `null` to disable deduplication for this operation type. Each
  /// operation should document its deduplication strategy.
  ///
  /// ## Examples
  /// - Trip update: `'trip_$tripId'` - deduplicates updates to same trip
  /// - Travel note: `null` - each note is unique, no deduplication
  /// - Location update: `null` - time-series data, no deduplication
  String? get deduplicationKey;

  /// Execute the operation's logic.
  ///
  /// Called by the queue when conditions are met (online, auth, not in backoff).
  /// Should throw an exception on failure to trigger retry logic.
  /// Implementations should be idempotent when possible.
  ///
  /// ## Error Handling
  /// Throw any exception to indicate failure. The exception message will be
  /// stored in [lastError] for debugging and UI display.
  ///
  /// ## Example
  /// ```dart
  /// @override
  /// Future<void> execute() async {
  ///   final api = ref.read(apiServiceProvider);
  ///   try {
  ///     await api.updateTrip(tripId, data);
  ///   } catch (e) {
  ///     throw Exception('Failed to update trip: $e');
  ///   }
  /// }
  /// ```
  Future<void> execute();

  /// Convert operation to JSON for persistence.
  ///
  /// Must include all fields needed to deserialize the operation later,
  /// including metadata fields (id, type, createdAt, attemptCount, etc.).
  /// The JSON must be compatible with the factory constructor in your
  /// operation class (e.g., `MyOperation.fromJson`).
  ///
  /// ## Required Fields
  /// - `id`: Unique identifier
  /// - `type`: Operation type string
  /// - All operation-specific data fields
  /// - `createdAt`: Creation timestamp
  /// - `lastAttempt`: Last attempt timestamp (nullable)
  /// - `attemptCount`: Number of attempts
  /// - `lastError`: Last error message (nullable)
  /// - `maxRetries`: Maximum retry limit
  ///
  /// ## Example
  /// ```dart
  /// @override
  /// Map<String, dynamic> toJson() => {
  ///   'id': id,
  ///   'type': type,
  ///   'tripId': tripId,
  ///   'createdAt': createdAt?.toIso8601String(),
  ///   'lastAttempt': lastAttempt?.toIso8601String(),
  ///   'attemptCount': attemptCount,
  ///   'lastError': lastError,
  ///   'maxRetries': maxRetries,
  ///   // ... other fields
  /// };
  /// ```
  Map<String, dynamic> toJson();

  /// Creates a copy of this operation with updated attempt metadata.
  ///
  /// This is used by the operation queue to track retry attempts.
  /// Implementations should return a new instance with the provided
  /// metadata fields updated.
  ///
  /// ## Parameters
  /// - [lastAttempt]: Timestamp of the most recent execution attempt
  /// - [attemptCount]: Total number of execution attempts (incremented)
  /// - [lastError]: Error message from the most recent failed attempt
  ///
  /// ## Example
  /// ```dart
  /// @override
  /// QueueableOperation withAttemptMetadata({
  ///   DateTime? lastAttempt,
  /// int? attemptCount,
  /// String? lastError,
  /// }) {
  ///   return MyOperation(
  ///     id: id,
  ///     type: type,
  ///     // ... other fields unchanged
  ///     lastAttempt: lastAttempt ?? this.lastAttempt,
  ///     attemptCount: attemptCount ?? this.attemptCount,
  ///     lastError: lastError ?? this.lastError,
  ///   );
  /// }
  /// ```
  QueueableOperation withAttemptMetadata({
    DateTime? lastAttempt,
    int? attemptCount,
    String? lastError,
  });

  /// Resets attempt metadata for retrying a failed operation.
  ///
  /// This is used when moving a failed operation back to the pending queue.
  /// Implementations should return a new instance with attempt metadata
  /// reset to initial values.
  ///
  /// ## Example
  /// ```dart
  /// @override
  /// QueueableOperation resetForRetry() {
  ///   return MyOperation(
  ///     id: id,
  ///     type: type,
  ///     // ... other fields unchanged
  ///     lastAttempt: null,
  ///     attemptCount: 0,
  ///     lastError: null,
  ///   );
  /// }
  /// ```
  QueueableOperation resetForRetry();
}

/// A persistent priority queue for managing offline-capable operations.
///
/// The queue handles execution, retry logic, deduplication, and persistence of
/// operations across app restarts. Operations are processed based on priority,
/// network connectivity, and authentication status.
///
/// ## Features
/// - **Priority-based processing**: Critical operations execute first
/// - **Exponential backoff retry**: Failed operations retry with increasing delays
/// - **Deduplication**: Prevents redundant operations from accumulating
/// - **Persistence**: Survives app restarts and device reboots
/// - **Aging mechanism**: Low-priority operations get priority boost over time
/// - **Round-robin**: Ensures fair processing across priority levels
///
/// ## Thread Safety
/// All public methods are thread-safe. The queue processes operations
/// sequentially on a 30-second timer, preventing concurrent execution.
///
/// ## Usage Example
/// ```dart
/// final queue = ref.read(operationQueueProvider.notifier);
///
/// // Add an operation to the queue
/// await queue.addOperation(myOperation);
///
/// // Get pending operations
/// final pending = queue.getPendingOperations();
///
/// // Retry a failed operation
/// await queue.retryOperation(operationId);
///
/// // Clear all failed operations
/// await queue.clearFailedOperations();
/// ```
///
/// See [QueueableOperation] for creating custom operations.
@riverpod
class OperationQueue extends _$OperationQueue {
  final Queue<QueueableOperation> _pendingOperations = Queue();
  final List<QueueableOperation> _failedOperations = [];
  Timer? _processingTimer;
  bool _isProcessing = false;

  /// Retry strategy for calculating backoff delays.
  ///
  /// Uses exponential backoff with jitter:
  /// - Base delay: 1 second
  /// - Max delay: 5 minutes
  /// - Jitter: 10% (prevents thundering herd)
  ///
  /// Retry delays: 1s → 2s → 4s → 8s → 16s → ... → 5m max
  late final RetryStrategy retryStrategy;

  /// Track consecutive operations processed per priority level for round-robin.
  ///
  /// Ensures fair processing across all priority levels by limiting
  /// consecutive operations of the same priority.
  final Map<int, int> _consecutiveProcessedByPriority = {};

  /// Maximum consecutive operations to process per priority level.
  ///
  /// After 3 consecutive operations of the same priority, the queue skips
  /// to the next priority level to prevent starvation. Critical operations
  /// (priority >= 1000) are exempt from this limit.
  static const int _maxConsecutivePerPriority = 3;

  /// Age threshold after which low-priority operations get a priority boost.
  ///
  /// Operations waiting longer than 5 minutes receive a +20 priority boost
  /// to ensure they eventually get processed.
  static const Duration _agingBoostThreshold = Duration(minutes: 5);

  /// Priority boost amount for operations that have been waiting too long.
  ///
  /// Added to the base priority of operations exceeding the aging threshold.
  static const int _agingBoostAmount = 20;

  @override
  Future<void> build() async {
    // Initialize retry strategy
    retryStrategy = ExponentialBackoffStrategy(
      baseDelay: const Duration(seconds: 1),
      maxDelay: const Duration(minutes: 5),
      jitterFactor: 0.1,
    );

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

  /// Adds an operation to the queue for later execution.
  ///
  /// The operation will be processed when conditions are met:
  /// - Network connectivity is available (if [operation.requiresNetwork])
  /// - User has valid authentication tokens
  /// - Operation is not in backoff period (for retries)
  ///
  /// ## Deduplication
  /// If the operation has a non-null [deduplicationKey], any existing
  /// operation with the same key will be replaced with the new one.
  ///
  /// ## Persistence
  /// The operation is immediately persisted to storage after being added.
  ///
  /// ## Processing
  /// If the operation can be processed immediately, [processQueue] is called.
  /// Otherwise, it will be processed on the next 30-second cycle.
  ///
  /// ## Example
  /// ```dart
  /// final operation = TripPlanningOperation.update(tripId, data);
  /// await queue.addOperation(operation);
  /// ```
  ///
  /// ## Error Handling
  /// Errors during persistence are logged but don't prevent the operation
  /// from being added to the in-memory queue.
  ///
  /// See [QueueableOperation.deduplicationKey] for deduplication behavior.
  Future<void> addOperation(QueueableOperation operation) async {
    // Check for duplicate operations if this operation has a deduplication key
    final duplicate = _findDuplicate(operation);
    if (duplicate != null) {
      debugPrint(
          'OperationQueue: Found duplicate operation ${duplicate.id}, replacing with ${operation.id}');
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

  /// Processes all operations in the queue that can be executed.
  ///
  /// Called automatically every 30 seconds by the timer, but can also be
  /// triggered manually (e.g., when connectivity is restored).
  ///
  /// ## Processing Logic
  /// 1. Sorts operations by effective priority (with aging boost)
  /// 2. Skips operations that can't be processed (offline, auth, backoff)
  /// 3. Enforces round-robin limits (max 3 consecutive per priority)
  /// 4. Executes operations sequentially
  /// 5. Updates attempt metadata on failure
  /// 6. Moves operations to failed queue after max retries
  /// 7. Persists queue state after processing
  ///
  /// ## Retry Behavior
  /// - Failed operations retry with exponential backoff
  /// - Operations in backoff period are skipped
  /// - Operations exceeding [maxRetries] move to failed queue
  ///
  /// ## Error Handling
  /// - Individual operation failures are logged and don't stop processing
  /// - Persistence errors are logged but don't stop the queue
  /// - Queue state is always consistent, even if errors occur
  ///
  /// ## Threading
  /// Only one processing cycle runs at a time. Concurrent calls return immediately.
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
          debugPrint(
              'Operation ${operation.id} exceeded max retries (${operation.maxRetries}), moving to failed queue');
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
          final failedOperation =
              _updateAttemptMetadata(operation, e.toString());

          // Check if this was the last retry attempt
          if (failedOperation.attemptCount >= failedOperation.maxRetries) {
            debugPrint(
                'Operation ${operation.id} reached max retries, moving to failed queue');
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
    return operation.withAttemptMetadata(
      lastAttempt: DateTime.now(),
      attemptCount: operation.attemptCount + 1,
      lastError: error,
    );
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
      debugPrint('Operation ${operation.id} is in backoff period. '
          'Can retry in ${timeUntilRetry.inSeconds}s');
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
            'boosting priority from $basePriority to $boostedPriority');
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
    final consecutiveCount =
        _consecutiveProcessedByPriority[effectivePriority] ?? 0;

    // Always process critical operations immediately (no round-robin limit)
    if (effectivePriority >= 1000) {
      return false;
    }

    // Skip if we've already processed too many operations of this priority level
    if (consecutiveCount >= _maxConsecutivePerPriority) {
      debugPrint(
          'Skipping operation ${operation.id} (priority $effectivePriority) - '
          'already processed $consecutiveCount consecutive operations of this priority');
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
        '(deduplication key: ${newOperation.deduplicationKey})');
  }

  /// Load saved queue from storage on initialization
  Future<void> _loadQueue() async {
    try {
      final storageService = ref.read(operationStorageServiceProvider.notifier);
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
        debugPrint(
            'OperationQueue: Warning - some operations were corrupted and skipped');
      }

      debugPrint(
          'OperationQueue: Loaded ${_pendingOperations.length} pending and ${_failedOperations.length} failed operations');
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
      final storageService = ref.read(operationStorageServiceProvider.notifier);

      // Save pending operations
      final pendingSuccess = await storageService.savePendingOperations(
        _pendingOperations.toList(),
      );

      // Save failed operations
      final failedSuccess = await storageService.saveFailedOperations(
        _failedOperations,
      );

      if (!pendingSuccess || !failedSuccess) {
        debugPrint(
            'OperationQueue: Warning - some operations failed to persist');
      }
    } catch (e, stackTrace) {
      debugPrint('OperationQueue: Error persisting queue: $e');
      debugPrint('Stack trace: $stackTrace');
      // Continue even if persistence fails - operations are still in memory
    }
  }

  /// Returns an unmodifiable list of all pending operations.
  ///
  /// The list is sorted by effective priority (including aging boosts).
  /// Returns an empty list if no operations are pending.
  ///
  /// ## Usage
  /// ```dart
  /// final pending = queue.getPendingOperations();
  /// for (final operation in pending) {
  ///   print('${operation.id}: ${operation.type}');
  /// }
  /// ```
  ///
  /// ## Thread Safety
  /// Returns a snapshot of the queue at the time of the call.
  /// The list won't change even if the queue is modified later.
  List<QueueableOperation> getPendingOperations() {
    return List.unmodifiable(_pendingOperations);
  }

  /// Returns an unmodifiable list of all failed operations.
  ///
  /// Failed operations have exceeded their [maxRetries] limit and
  /// require manual intervention (retry or remove).
  ///
  /// ## Usage
  /// ```dart
  /// final failed = queue.getFailedOperations();
  /// for (final operation in failed) {
  ///   print('${operation.id}: ${operation.lastError}');
  /// }
  /// ```
  ///
  /// ## Thread Safety
  /// Returns a snapshot of the failed queue at the time of the call.
  List<QueueableOperation> getFailedOperations() {
    return List.unmodifiable(_failedOperations);
  }

  /// Whether the queue is currently processing operations.
  ///
  /// Returns `true` if a processing cycle is in progress, `false` otherwise.
  /// The queue processes operations every 30 seconds or when triggered manually.
  ///
  /// ## Usage
  /// ```dart
  /// if (queue.isProcessing) {
  ///   print('Queue is processing...');
  /// }
  /// ```
  bool get isProcessing => _isProcessing;

  /// Retries a specific failed operation by moving it back to the pending queue.
  ///
  /// The operation's attempt metadata (attemptCount, lastAttempt, lastError)
  /// is reset, giving it a fresh start with no backoff period.
  ///
  /// ## Parameters
  /// - [id]: The unique identifier of the operation to retry
  ///
  /// ## Behavior
  /// - Removes operation from failed queue
  /// - Resets attempt metadata to initial state
  /// - Adds operation back to pending queue
  /// - Persists changes to storage
  /// - Triggers immediate processing if conditions are met
  ///
  /// ## Example
  /// ```dart
  /// await queue.retryOperation('op_1234567890');
  /// ```
  ///
  /// ## Error Handling
  /// If the operation ID is not found in the failed queue, this method
  /// logs a debug message and returns without error.
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

    debugPrint(
        'OperationQueue: Operation ${operation.id} moved back to pending queue');
  }

  /// Retries all failed operations by moving them back to the pending queue.
  ///
  /// All operations in the failed queue have their attempt metadata reset
  /// and are moved back to the pending queue for immediate processing.
  ///
  /// ## Behavior
  /// - Clears the entire failed queue
  /// - Resets attempt metadata for all operations
  /// - Adds all operations back to pending queue
  /// - Persists changes to storage
  ///
  /// ## Example
  /// ```dart
  /// final failedCount = queue.getFailedOperations().length;
  /// if (failedCount > 0) {
  ///   await queue.retryAllFailed();
  ///   print('Retried $failedCount operations');
  /// }
  /// ```
  ///
  /// ## Use Cases
  /// - User wants to retry all failed operations after connectivity is restored
  /// - User believes the issue causing failures has been resolved
  Future<void> retryAllFailed() async {
    debugPrint(
        'OperationQueue: Retrying all ${_failedOperations.length} failed operations');

    final operationsToRetry = List<QueueableOperation>.from(_failedOperations);

    // Clear failed queue
    _failedOperations.clear();

    // Reset metadata and add back to pending queue
    for (final operation in operationsToRetry) {
      final resetOperation = _resetAttemptMetadata(operation);
      await addOperation(resetOperation);
    }

    debugPrint(
        'OperationQueue: Moved ${operationsToRetry.length} operations back to pending queue');
  }

  /// Clears all failed operations from the queue.
  ///
  /// Removes all operations from the failed queue permanently. This is a
  /// destructive action that cannot be undone.
  ///
  /// ## Behavior
  /// - Removes all operations from failed queue
  /// - Persists changes to storage
  /// - Does not affect pending operations
  ///
  /// ## Example
  /// ```dart
  /// await queue.clearFailedOperations();
  /// ```
  ///
  /// ## Use Cases
  /// - User wants to dismiss all failed operations
  /// - Operations are no longer relevant
  /// - User has manually handled the operations elsewhere
  Future<void> clearFailedOperations() async {
    debugPrint(
        'OperationQueue: Clearing all ${_failedOperations.length} failed operations');

    final count = _failedOperations.length;
    _failedOperations.clear();

    await _persistQueue();

    debugPrint('OperationQueue: Cleared $count failed operations');
  }

  /// Removes a specific failed operation from the queue by ID.
  ///
  /// Permanently removes a single failed operation from the failed queue.
  /// This is a destructive action that cannot be undone.
  ///
  /// ## Parameters
  /// - [id]: The unique identifier of the operation to remove
  ///
  /// ## Behavior
  /// - Removes operation from failed queue
  /// - Persists changes to storage
  ///
  /// ## Example
  /// ```dart
  /// await queue.removeFailedOperation('op_1234567890');
  /// ```
  ///
  /// ## Error Handling
  /// If the operation ID is not found, this method logs a debug message
  /// and returns without error.
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
    return operation.resetForRetry();
  }
}
