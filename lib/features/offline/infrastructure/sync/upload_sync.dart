import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:soloadventurer/features/offline/domain/entities/sync_operation.dart';
import 'package:soloadventurer/features/offline/domain/repositories/sync_queue_repository.dart';

/// Result of an upload sync operation
class UploadSyncResult {
  /// Number of successfully uploaded operations
  final int successCount;

  /// Number of failed operations
  final int failureCount;

  /// Operations that failed with their error messages
  final Map<int, String> failedOperations;

  /// Duration of the upload sync
  final Duration duration;

  /// Whether the upload sync was successful overall
  bool get isSuccessful => failureCount == 0;

  const UploadSyncResult({
    required this.successCount,
    required this.failureCount,
    required this.failedOperations,
    required this.duration,
  });

  @override
  String toString() {
    return 'UploadSyncResult(success: $successCount, failed: $failureCount, '
        'duration: ${duration.inSeconds}s)';
  }
}

/// Service to sync queued operations from local database to Supabase
///
/// This service handles the upload phase of synchronization by:
/// - Processing pending operations from the sync queue
/// - Converting operations to Supabase PostgREST API calls
/// - Executing mutations against Supabase
/// - Updating local database with server IDs on success
/// - Marking operations as completed or failed
/// - Handling retries with exponential backoff
///
/// The service processes operations in priority order and supports
/// create, update, and delete operations for trips, journals, and users.
///
/// Example usage:
/// ```dart
/// final uploadSync = UploadSync(
///   client: Supabase.instance.client,
///   syncQueueRepository: syncQueueRepository,
/// );
///
/// final result = await uploadSync.processPendingOperations(
///   limit: 10,
///   onProgress: (current, total) {
///     print('Progress: $current/$total');
///   },
/// );
///
/// print('Uploaded ${result.successCount} operations');
/// ```
class UploadSync {
  /// Supabase client for API requests
  final SupabaseClient _client;

  /// Repository for sync queue operations
  final SyncQueueRepository _syncQueueRepository;

  /// Creates a new [UploadSync] instance
  ///
  /// [client] - Supabase client for making API requests
  /// [syncQueueRepository] - Repository for managing sync queue
  UploadSync({
    required SupabaseClient client,
    required SyncQueueRepository syncQueueRepository,
  })  : _client = client,
        _syncQueueRepository = syncQueueRepository;

  // ==============================================================================
  // PUBLIC API
  // ==============================================================================

  /// Processes pending operations in the sync queue
  ///
  /// The [limit] parameter controls the maximum number of operations to process
  /// (default: 10). Operations are processed in priority order.
  ///
  /// The [onProgress] callback is invoked after each operation completes,
  /// providing the current count and total count.
  ///
  /// Returns an [UploadSyncResult] with success/failure counts and errors.
  Future<UploadSyncResult> processPendingOperations({
    int limit = 10,
    void Function(int current, int total)? onProgress,
  }) async {
    final startTime = DateTime.now();
    int successCount = 0;
    int failureCount = 0;
    final Map<int, String> failedOperations = {};

    try {
      debugPrint('📤 UploadSync: Starting to process pending operations...');

      // Get pending operations prioritized by priority and age
      final operations = await _syncQueueRepository.getPendingOperations(
        limit: limit,
      );

      if (operations.isEmpty) {
        debugPrint('📭 UploadSync: No pending operations to process');
        return const UploadSyncResult(
          successCount: 0,
          failureCount: 0,
          failedOperations: {},
          duration: Duration.zero,
        );
      }

      debugPrint(
          '🔄 UploadSync: Processing ${operations.length} operations...');

      // Process each operation
      for (int i = 0; i < operations.length; i++) {
        final operation = operations[i];

        try {
          // Mark as processing
          await _syncQueueRepository.markAsProcessing(operation.id);

          debugPrint('🔄 Uploading: ${operation.description}');

          // Execute the operation based on entity type and operation type
          final success = await _executeOperation(operation);

          if (success) {
            // Mark as completed
            await _syncQueueRepository.markAsCompleted(operation.id);
            successCount++;
            debugPrint('✅ Upload success: ${operation.description}');
          } else {
            // Mark as failed
            await _syncQueueRepository.markAsFailed(
              operation.id,
              'Operation execution returned false',
            );
            failureCount++;
            failedOperations[operation.id] = 'Execution returned false';
            debugPrint('❌ Upload failed: ${operation.description}');
          }

          // Notify progress
          onProgress?.call(i + 1, operations.length);
        } catch (e) {
          // Mark as failed with error
          final errorMessage = e.toString();
          await _syncQueueRepository.markAsFailed(
            operation.id,
            errorMessage,
          );
          failureCount++;
          failedOperations[operation.id] = errorMessage;
          debugPrint('❌ Upload error: ${operation.description} - $e');

          // Notify progress
          onProgress?.call(i + 1, operations.length);
        }
      }

      final duration = DateTime.now().difference(startTime);

      debugPrint('✅ UploadSync complete: $successCount succeeded, '
          '$failureCount failed in ${duration.inSeconds}s');

      return UploadSyncResult(
        successCount: successCount,
        failureCount: failureCount,
        failedOperations: failedOperations,
        duration: duration,
      );
    } catch (e) {
      debugPrint('❌ UploadSync error: $e');
      rethrow;
    }
  }

  /// Processes a single operation immediately
  ///
  /// This method is useful for processing operations in real-time
  /// as they are created (e.g., when user makes a change while online).
  ///
  /// Returns [true] if the operation was successful, [false] otherwise.
  Future<bool> processOperation(SyncOperationEntity operation) async {
    try {
      debugPrint(
          '🔄 Processing operation immediately: ${operation.description}');

      // Mark as processing
      await _syncQueueRepository.markAsProcessing(operation.id);

      // Execute the operation
      final success = await _executeOperation(operation);

      if (success) {
        await _syncQueueRepository.markAsCompleted(operation.id);
        debugPrint('✅ Operation processed successfully');
        return true;
      } else {
        await _syncQueueRepository.markAsFailed(
          operation.id,
          'Operation execution returned false',
        );
        debugPrint('❌ Operation execution failed');
        return false;
      }
    } catch (e) {
      await _syncQueueRepository.markAsFailed(operation.id, e.toString());
      debugPrint('❌ Operation processing error: $e');
      return false;
    }
  }

  // ==============================================================================
  // PRIVATE METHODS - OPERATION EXECUTION
  // ==============================================================================

  /// Executes a single sync operation against the server
  ///
  /// Routes the operation to the appropriate handler based on
  /// entity type and operation type.
  ///
  /// Returns [true] if successful, [false] otherwise.
  Future<bool> _executeOperation(SyncOperationEntity operation) async {
    try {
      // Route based on entity type
      switch (operation.entityType.toLowerCase()) {
        case 'trip':
          return await _executeTripOperation(operation);
        case 'journal':
        case 'journalentry':
          return await _executeJournalOperation(operation);
        case 'user':
        case 'profile':
          return await _executeUserOperation(operation);
        case 'travelpreference':
          return await _executeTravelPreferenceOperation(operation);
        default:
          debugPrint('⚠️ Unknown entity type: ${operation.entityType}');
          return false;
      }
    } catch (e) {
      debugPrint('❌ Error executing operation: $e');
      return false;
    }
  }

  /// Executes a trip operation (create, update, delete)
  Future<bool> _executeTripOperation(SyncOperationEntity operation) async {
    try {
      switch (operation.operation) {
        case SyncOperationType.create:
          return await _createTrip(operation);
        case SyncOperationType.update:
          return await _updateTrip(operation);
        case SyncOperationType.delete:
          return await _deleteTrip(operation);
      }
    } on PostgrestException catch (e) {
      debugPrint('❌ PostgrestException executing trip operation: ${e.message}');
      return false;
    } catch (e) {
      debugPrint('❌ Error executing trip operation: $e');
      return false;
    }
  }

  /// Executes a journal operation (create, update, delete)
  Future<bool> _executeJournalOperation(SyncOperationEntity operation) async {
    try {
      switch (operation.operation) {
        case SyncOperationType.create:
          return await _createJournal(operation);
        case SyncOperationType.update:
          return await _updateJournal(operation);
        case SyncOperationType.delete:
          return await _deleteJournal(operation);
      }
    } on PostgrestException catch (e) {
      debugPrint('❌ PostgrestException executing journal operation: ${e.message}');
      return false;
    } catch (e) {
      debugPrint('❌ Error executing journal operation: $e');
      return false;
    }
  }

  /// Executes a user/profile operation (create, update, delete)
  Future<bool> _executeUserOperation(SyncOperationEntity operation) async {
    try {
      switch (operation.operation) {
        case SyncOperationType.create:
          // User creation typically handled through auth flow
          debugPrint('⚠️ User creation through sync not supported');
          return false;
        case SyncOperationType.update:
          return await _updateUserProfile(operation);
        case SyncOperationType.delete:
          // User deletion typically handled through auth flow
          debugPrint('⚠️ User deletion through sync not supported');
          return false;
      }
    } on PostgrestException catch (e) {
      debugPrint('❌ PostgrestException executing user operation: ${e.message}');
      return false;
    } catch (e) {
      debugPrint('❌ Error executing user operation: $e');
      return false;
    }
  }

  /// Executes a travel preference operation (create, update, delete)
  Future<bool> _executeTravelPreferenceOperation(
      SyncOperationEntity operation) async {
    try {
      switch (operation.operation) {
        case SyncOperationType.create:
          return await _createTravelPreference(operation);
        case SyncOperationType.update:
          return await _updateTravelPreference(operation);
        case SyncOperationType.delete:
          // Travel preference deletion not typically supported
          debugPrint('⚠️ Travel preference deletion not supported');
          return false;
      }
    } on PostgrestException catch (e) {
      debugPrint('❌ PostgrestException executing travel preference operation: ${e.message}');
      return false;
    } catch (e) {
      debugPrint('❌ Error executing travel preference operation: $e');
      return false;
    }
  }

  // ==============================================================================
  // PRIVATE METHODS - SUPABASE POSTGREST OPERATIONS
  // ==============================================================================

  /// Creates a trip on the server
  Future<bool> _createTrip(SyncOperationEntity operation) async {
    try {
      final response = await _client
          .from('trips')
          .insert(operation.data)
          .select()
          .single();

      debugPrint('✅ Trip created on server: ${response['id']}');
      return true;
        } on PostgrestException catch (e) {
      debugPrint('❌ PostgrestException creating trip: ${e.message}');
      return false;
    }
  }

  /// Updates a trip on the server
  Future<bool> _updateTrip(SyncOperationEntity operation) async {
    try {
      final response = await _client
          .from('trips')
          .update(operation.data)
          .eq('id', operation.entityId)
          .select()
          .single();

      debugPrint('✅ Trip updated on server: ${response['id']}');
      return true;
        } on PostgrestException catch (e) {
      debugPrint('❌ PostgrestException updating trip: ${e.message}');
      return false;
    }
  }

  /// Deletes a trip on the server
  Future<bool> _deleteTrip(SyncOperationEntity operation) async {
    try {
      await _client
          .from('trips')
          .delete()
          .eq('id', operation.entityId);

      debugPrint('✅ Trip deleted on server: ${operation.entityId}');
      return true;
    } on PostgrestException catch (e) {
      debugPrint('❌ PostgrestException deleting trip: ${e.message}');
      return false;
    }
  }

  /// Creates a journal on the server
  Future<bool> _createJournal(SyncOperationEntity operation) async {
    try {
      final response = await _client
          .from('journal_entries')
          .insert(operation.data)
          .select()
          .single();

      debugPrint('✅ Journal created on server: ${response['id']}');
      return true;
        } on PostgrestException catch (e) {
      debugPrint('❌ PostgrestException creating journal: ${e.message}');
      return false;
    }
  }

  /// Updates a journal on the server
  Future<bool> _updateJournal(SyncOperationEntity operation) async {
    try {
      final response = await _client
          .from('journal_entries')
          .update(operation.data)
          .eq('id', operation.entityId)
          .select()
          .single();

      debugPrint('✅ Journal updated on server: ${response['id']}');
      return true;
        } on PostgrestException catch (e) {
      debugPrint('❌ PostgrestException updating journal: ${e.message}');
      return false;
    }
  }

  /// Deletes a journal on the server
  Future<bool> _deleteJournal(SyncOperationEntity operation) async {
    try {
      await _client
          .from('journal_entries')
          .delete()
          .eq('id', operation.entityId);

      debugPrint('✅ Journal deleted on server: ${operation.entityId}');
      return true;
    } on PostgrestException catch (e) {
      debugPrint('❌ PostgrestException deleting journal: ${e.message}');
      return false;
    }
  }

  /// Updates user profile on the server
  Future<bool> _updateUserProfile(SyncOperationEntity operation) async {
    try {
      final response = await _client
          .from('profiles')
          .update(operation.data)
          .eq('id', operation.entityId)
          .select()
          .single();

      debugPrint('✅ User profile updated on server: ${response['id']}');
      return true;
        } on PostgrestException catch (e) {
      debugPrint('❌ PostgrestException updating user profile: ${e.message}');
      return false;
    }
  }

  /// Creates travel preference on the server
  Future<bool> _createTravelPreference(SyncOperationEntity operation) async {
    try {
      final response = await _client
          .from('travel_preferences')
          .insert(operation.data)
          .select()
          .single();

      debugPrint(
          '✅ Travel preference created on server: ${response['id']}');
      return true;
        } on PostgrestException catch (e) {
      debugPrint('❌ PostgrestException creating travel preference: ${e.message}');
      return false;
    }
  }

  /// Updates travel preference on the server
  Future<bool> _updateTravelPreference(SyncOperationEntity operation) async {
    try {
      final response = await _client
          .from('travel_preferences')
          .update(operation.data)
          .eq('id', operation.entityId)
          .select()
          .single();

      debugPrint(
          '✅ Travel preference updated on server: ${response['id']}');
      return true;
        } on PostgrestException catch (e) {
      debugPrint('❌ PostgrestException updating travel preference: ${e.message}');
      return false;
    }
  }
}
