import 'dart:async';
import 'dart:collection';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../providers/connectivity_provider.dart';
import '../../auth/domain/services/token_manager.dart';

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

  /// Execute the operation
  Future<void> execute();

  /// Convert operation to JSON for persistence
  Map<String, dynamic> toJson();
}

@riverpod
class OperationQueue extends _$OperationQueue {
  final Queue<QueueableOperation> _pendingOperations = Queue();
  Timer? _processingTimer;
  bool _isProcessing = false;

  @override
  Future<void> build() async {
    // Watch connectivity and token state
    ref.watch(connectivityNotifierProvider);
    ref.watch(tokenManagerProvider);

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

      for (final operation in operations) {
        if (!_canProcess(operation)) continue;

        try {
          await operation.execute();
          _pendingOperations.remove(operation);
        } catch (e) {
          debugPrint('Failed to execute operation ${operation.id}: $e');
          // Leave operation in queue for retry
        }
      }

      await _persistQueue();
    } finally {
      _isProcessing = false;
    }
  }

  bool _canProcess(QueueableOperation operation) {
    final tokenManager = ref.read(tokenManagerProvider);
    final isOnline = ref.read(connectivityNotifierProvider);

    if (operation.requiresNetwork) {
      return isOnline && tokenManager.canPerformOnlineOperations;
    }

    return tokenManager.hasValidTokens;
  }

  Future<void> _persistQueue() async {
    // TODO: Implement queue persistence
    // This would save the queue to local storage for recovery after app restart
  }
}
