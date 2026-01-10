import 'dart:convert';
import 'dart:developer' as developer;
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/models/sync_operation.dart';
import '../../domain/services/sync_queue_persistence.dart';

/// Implementation of [SyncQueuePersistence] using SharedPreferences
///
/// Stores operations as JSON strings with the following keys:
/// - 'sync_queue_operations': List of operation IDs in order
/// - 'sync_queue_op_<id>': Individual operation data
class SharedPrefsSyncQueuePersistence implements SyncQueuePersistence {
  final SharedPreferences _prefs;

  // Storage keys
  static const String _operationsListKey = 'sync_queue_operations';
  static const String _operationPrefix = 'sync_queue_op_';

  /// Creates a new [SharedPrefsSyncQueuePersistence] instance
  SharedPrefsSyncQueuePersistence(this._prefs);

  @override
  Future<SyncQueuePersistenceResult> saveQueue(
      List<SyncOperation> queue) async {
    try {
      // Clear existing queue data
      await clearQueue();

      if (queue.isEmpty) {
        return SyncQueuePersistenceResult.success(operationCount: 0);
      }

      // Save each operation
      final operationIds = <String>[];
      for (final operation in queue) {
        final operationKey = '$_operationPrefix${operation.id}';
        final operationJson = jsonEncode(operation.toJson());

        await _prefs.setString(operationKey, operationJson);
        operationIds.add(operation.id);
      }

      // Save the list of operation IDs (maintains order)
      await _prefs.setStringList(_operationsListKey, operationIds);

      developer.log(
        'SyncQueuePersistence: Saved ${operationIds.length} operations',
        name: 'sync.persistence',
      );

      return SyncQueuePersistenceResult.success(
        operationCount: operationIds.length,
      );
    } catch (e, stackTrace) {
      developer.log(
        'SyncQueuePersistence: Error saving queue',
        name: 'sync.persistence',
        error: e,
        stackTrace: stackTrace,
      );

      return SyncQueuePersistenceResult.failure(
        'Failed to save queue: ${e.toString()}',
      );
    }
  }

  @override
  Future<List<SyncOperation>> loadQueue() async {
    try {
      // Get the list of operation IDs
      final operationIds = _prefs.getStringList(_operationsListKey);
      if (operationIds == null || operationIds.isEmpty) {
        developer.log(
          'SyncQueuePersistence: No persisted operations found',
          name: 'sync.persistence',
        );
        return [];
      }

      // Load each operation
      final operations = <SyncOperation>[];
      final corruptedIds = <String>[];

      for (final operationId in operationIds) {
        try {
          final operationKey = '$_operationPrefix$operationId';
          final operationJson = _prefs.getString(operationKey);

          if (operationJson == null) {
            developer.log(
              'SyncQueuePersistence: Missing operation data for $operationId',
              name: 'sync.persistence',
              level: 900, // WARNING level
            );
            corruptedIds.add(operationId);
            continue;
          }

          final operationMap =
              jsonDecode(operationJson) as Map<String, dynamic>;
          final operation = SyncOperation.fromJson(operationMap);
          operations.add(operation);
        } catch (e, stackTrace) {
          developer.log(
            'SyncQueuePersistence: Error loading operation $operationId',
            name: 'sync.persistence',
            error: e,
            stackTrace: stackTrace,
            level: 1000, // ERROR level
          );
          corruptedIds.add(operationId);
        }
      }

      // Clean up corrupted entries
      if (corruptedIds.isNotEmpty) {
        await _cleanupCorruptedEntries(corruptedIds);
      }

      developer.log(
        'SyncQueuePersistence: Loaded ${operations.length} operations '
        '(${corruptedIds.length} corrupted entries cleaned up)',
        name: 'sync.persistence',
      );

      return operations;
    } catch (e, stackTrace) {
      developer.log(
        'SyncQueuePersistence: Fatal error loading queue',
        name: 'sync.persistence',
        error: e,
        stackTrace: stackTrace,
        level: 1000, // ERROR level
      );

      // On fatal error, attempt to clear corrupted data
      try {
        await clearQueue();
      } catch (_) {
        // Ignore cleanup errors
      }

      return [];
    }
  }

  @override
  Future<SyncQueuePersistenceResult> clearQueue() async {
    try {
      // Get all operation IDs
      final operationIds = _prefs.getStringList(_operationsListKey);
      if (operationIds != null) {
        // Remove each operation
        for (final operationId in operationIds) {
          await _prefs.remove('$_operationPrefix$operationId');
        }
      }

      // Clear the operations list
      await _prefs.remove(_operationsListKey);

      developer.log(
        'SyncQueuePersistence: Cleared all queue data',
        name: 'sync.persistence',
      );

      return SyncQueuePersistenceResult.success();
    } catch (e, stackTrace) {
      developer.log(
        'SyncQueuePersistence: Error clearing queue',
        name: 'sync.persistence',
        error: e,
        stackTrace: stackTrace,
      );

      return SyncQueuePersistenceResult.failure(
        'Failed to clear queue: ${e.toString()}',
      );
    }
  }

  @override
  Future<bool> removeOperation(String operationId) async {
    try {
      // Get the list of operation IDs
      final operationIds = _prefs.getStringList(_operationsListKey);
      if (operationIds == null || !operationIds.contains(operationId)) {
        return false;
      }

      // Remove the operation data
      await _prefs.remove('$_operationPrefix$operationId');

      // Update the operations list
      operationIds.remove(operationId);
      await _prefs.setStringList(_operationsListKey, operationIds);

      developer.log(
        'SyncQueuePersistence: Removed operation $operationId',
        name: 'sync.persistence',
      );

      return true;
    } catch (e, stackTrace) {
      developer.log(
        'SyncQueuePersistence: Error removing operation $operationId',
        name: 'sync.persistence',
        error: e,
        stackTrace: stackTrace,
      );

      return false;
    }
  }

  @override
  Future<bool> hasPersistedOperations() async {
    try {
      final operationIds = _prefs.getStringList(_operationsListKey);
      return operationIds != null && operationIds.isNotEmpty;
    } catch (e, stackTrace) {
      developer.log(
        'SyncQueuePersistence: Error checking for persisted operations',
        name: 'sync.persistence',
        error: e,
        stackTrace: stackTrace,
      );

      return false;
    }
  }

  @override
  Future<int> getOperationCount() async {
    try {
      final operationIds = _prefs.getStringList(_operationsListKey);
      return operationIds?.length ?? 0;
    } catch (e, stackTrace) {
      developer.log(
        'SyncQueuePersistence: Error getting operation count',
        name: 'sync.persistence',
        error: e,
        stackTrace: stackTrace,
      );

      return 0;
    }
  }

  /// Clean up corrupted entries from storage
  Future<void> _cleanupCorruptedEntries(List<String> corruptedIds) async {
    try {
      // Remove corrupted operation data
      for (final operationId in corruptedIds) {
        await _prefs.remove('$_operationPrefix$operationId');
      }

      // Get and update the operations list
      final operationIds = _prefs.getStringList(_operationsListKey);
      if (operationIds != null) {
        final updatedIds =
            operationIds.where((id) => !corruptedIds.contains(id)).toList();
        await _prefs.setStringList(_operationsListKey, updatedIds);
      }

      developer.log(
        'SyncQueuePersistence: Cleaned up ${corruptedIds.length} corrupted entries',
        name: 'sync.persistence',
        level: 900, // WARNING level
      );
    } catch (e, stackTrace) {
      developer.log(
        'SyncQueuePersistence: Error cleaning up corrupted entries',
        name: 'sync.persistence',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }
}
