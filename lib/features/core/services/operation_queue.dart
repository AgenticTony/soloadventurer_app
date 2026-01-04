import 'dart:async';
import 'dart:collection';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../providers/connectivity_provider.dart';
import '../../auth/domain/services/token_manager.dart';
import 'operation_storage_service.dart';
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

      for (final operation in operations) {
        if (!_canProcess(operation)) continue;

        // Create updated operation with attempt metadata
        final updatedOperation = _updateAttemptMetadata(operation, null);

        try {
          await operation.execute();
          operationsToRemove.add(operation);
        } catch (e, stackTrace) {
          debugPrint('Failed to execute operation ${operation.id}: $e');
          debugPrint('Stack trace: $stackTrace');

          // Update operation with error information
          final failedOperation = _updateAttemptMetadata(operation, e.toString());

          // Replace the operation with the updated one
          operationsToRemove.add(operation);
          operationsToAdd.add(failedOperation);
        }
      }

      // Update the queue
      for (final op in operationsToRemove) {
        _pendingOperations.remove(op);
      }
      for (final op in operationsToAdd) {
        _pendingOperations.add(op);
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

    if (operation.requiresNetwork) {
      return isOnline && tokenManager.canPerformOnlineOperations;
    }

    return tokenManager.hasValidTokens;
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
