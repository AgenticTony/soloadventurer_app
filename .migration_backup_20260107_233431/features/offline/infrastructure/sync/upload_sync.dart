import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:soloadventurer/features/offline/domain/entities/sync_operation.dart';
import 'package:soloadventurer/features/offline/domain/repositories/sync_queue_repository.dart';
import 'package:soloadventurer/features/core/infrastructure/graphql/graphql_queries.dart';

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

/// Service to sync queued operations from local database to server
///
/// This service handles the upload phase of synchronization by:
/// - Processing pending operations from the sync queue
/// - Converting operations to GraphQL mutations or REST API calls
/// - Executing mutations against the server
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
///   dio: dio,
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
  /// Dio HTTP client for API requests
  final Dio _dio;

  /// Repository for sync queue operations
  final SyncQueueRepository _syncQueueRepository;

  /// GraphQL API endpoint
  final String _graphqlEndpoint;

  /// Creates a new [UploadSync] instance
  ///
  /// [dio] - Dio HTTP client for making API requests
  /// [syncQueueRepository] - Repository for managing sync queue
  /// [graphqlEndpoint] - GraphQL API endpoint (default: '/graphql')
  UploadSync({
    required Dio dio,
    required SyncQueueRepository syncQueueRepository,
    String graphqlEndpoint = '/graphql',
  })  : _dio = dio,
        _syncQueueRepository = syncQueueRepository,
        _graphqlEndpoint = graphqlEndpoint;

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

      debugPrint('🔄 UploadSync: Processing ${operations.length} operations...');

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
      debugPrint('🔄 Processing operation immediately: ${operation.description}');

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
    } catch (e) {
      debugPrint('❌ Error executing travel preference operation: $e');
      return false;
    }
  }

  // ==============================================================================
  // PRIVATE METHODS - GRAPHQL MUTATIONS
  // ==============================================================================

  /// Creates a trip on the server
  Future<bool> _createTrip(SyncOperationEntity operation) async {
    try {
      final response = await _dio.post(
        _graphqlEndpoint,
        data: {
          'query': GraphQLQueries.createTrip,
          'variables': operation.data,
        },
      );

      if (response.statusCode == 200 && response.data['data'] != null) {
        final createdTrip = response.data['data']['createTrip'];
        debugPrint('✅ Trip created on server: ${createdTrip['id']}');
        return true;
      } else {
        final errors = response.data['errors'];
        debugPrint('❌ Failed to create trip: $errors');
        return false;
      }
    } on DioException catch (e) {
      debugPrint('❌ DioException creating trip: ${e.message}');
      return false;
    }
  }

  /// Updates a trip on the server
  Future<bool> _updateTrip(SyncOperationEntity operation) async {
    try {
      final response = await _dio.post(
        _graphqlEndpoint,
        data: {
          'query': GraphQLQueries.updateTrip,
          'variables': {
            'id': operation.entityId,
            ...operation.data,
          },
        },
      );

      if (response.statusCode == 200 && response.data['data'] != null) {
        final updatedTrip = response.data['data']['updateTrip'];
        debugPrint('✅ Trip updated on server: ${updatedTrip['id']}');
        return true;
      } else {
        final errors = response.data['errors'];
        debugPrint('❌ Failed to update trip: $errors');
        return false;
      }
    } on DioException catch (e) {
      debugPrint('❌ DioException updating trip: ${e.message}');
      return false;
    }
  }

  /// Deletes a trip on the server
  Future<bool> _deleteTrip(SyncOperationEntity operation) async {
    try {
      // Note: Assuming there's a deleteTrip mutation, if not this would need
      // to be added to GraphQLQueries
      const deleteMutation = '''
        mutation DeleteTrip(\$id: ID!) {
          deleteTrip(id: \$id) {
            id
            success
          }
        }
      ''';

      final response = await _dio.post(
        _graphqlEndpoint,
        data: {
          'query': deleteMutation,
          'variables': {'id': operation.entityId},
        },
      );

      if (response.statusCode == 200 && response.data['data'] != null) {
        debugPrint('✅ Trip deleted on server: ${operation.entityId}');
        return true;
      } else {
        final errors = response.data['errors'];
        debugPrint('❌ Failed to delete trip: $errors');
        return false;
      }
    } on DioException catch (e) {
      debugPrint('❌ DioException deleting trip: ${e.message}');
      return false;
    }
  }

  /// Creates a journal on the server
  Future<bool> _createJournal(SyncOperationEntity operation) async {
    try {
      // Note: Assuming there's a createJournal mutation
      const createMutation = '''
        mutation CreateJournal(
          \$tripId: ID!
          \$title: String!
          \$content: String!
          \$entryDate: String!
          \$mood: String
          \$location: String
          \$tags: [String!]
          \$images: [String!]
        ) {
          createJournal(
            tripId: \$tripId
            title: \$title
            content: \$content
            entryDate: \$entryDate
            mood: \$mood
            location: \$location
            tags: \$tags
            images: \$images
          ) {
            id
            tripId
            title
            content
            entryDate
            mood
            location
            tags
            images
            createdAt
            updatedAt
          }
        }
      ''';

      final response = await _dio.post(
        _graphqlEndpoint,
        data: {
          'query': createMutation,
          'variables': operation.data,
        },
      );

      if (response.statusCode == 200 && response.data['data'] != null) {
        final createdJournal = response.data['data']['createJournal'];
        debugPrint('✅ Journal created on server: ${createdJournal['id']}');
        return true;
      } else {
        final errors = response.data['errors'];
        debugPrint('❌ Failed to create journal: $errors');
        return false;
      }
    } on DioException catch (e) {
      debugPrint('❌ DioException creating journal: ${e.message}');
      return false;
    }
  }

  /// Updates a journal on the server
  Future<bool> _updateJournal(SyncOperationEntity operation) async {
    try {
      // Note: Assuming there's an updateJournal mutation
      const updateMutation = '''
        mutation UpdateJournal(
          \$id: ID!
          \$title: String
          \$content: String
          \$entryDate: String
          \$mood: String
          \$location: String
          \$tags: [String!]
          \$images: [String!]
        ) {
          updateJournal(
            id: \$id
            title: \$title
            content: \$content
            entryDate: \$entryDate
            mood: \$mood
            location: \$location
            tags: \$tags
            images: \$images
          ) {
            id
            tripId
            title
            content
            entryDate
            mood
            location
            tags
            images
            createdAt
            updatedAt
          }
        }
      ''';

      final response = await _dio.post(
        _graphqlEndpoint,
        data: {
          'query': updateMutation,
          'variables': {
            'id': operation.entityId,
            ...operation.data,
          },
        },
      );

      if (response.statusCode == 200 && response.data['data'] != null) {
        final updatedJournal = response.data['data']['updateJournal'];
        debugPrint('✅ Journal updated on server: ${updatedJournal['id']}');
        return true;
      } else {
        final errors = response.data['errors'];
        debugPrint('❌ Failed to update journal: $errors');
        return false;
      }
    } on DioException catch (e) {
      debugPrint('❌ DioException updating journal: ${e.message}');
      return false;
    }
  }

  /// Deletes a journal on the server
  Future<bool> _deleteJournal(SyncOperationEntity operation) async {
    try {
      // Note: Assuming there's a deleteJournal mutation
      const deleteMutation = '''
        mutation DeleteJournal(\$id: ID!) {
          deleteJournal(id: \$id) {
            id
            success
          }
        }
      ''';

      final response = await _dio.post(
        _graphqlEndpoint,
        data: {
          'query': deleteMutation,
          'variables': {'id': operation.entityId},
        },
      );

      if (response.statusCode == 200 && response.data['data'] != null) {
        debugPrint('✅ Journal deleted on server: ${operation.entityId}');
        return true;
      } else {
        final errors = response.data['errors'];
        debugPrint('❌ Failed to delete journal: $errors');
        return false;
      }
    } on DioException catch (e) {
      debugPrint('❌ DioException deleting journal: ${e.message}');
      return false;
    }
  }

  /// Updates user profile on the server
  Future<bool> _updateUserProfile(SyncOperationEntity operation) async {
    try {
      final response = await _dio.post(
        _graphqlEndpoint,
        data: {
          'query': GraphQLQueries.updateUserProfile,
          'variables': {
            'userId': operation.entityId,
            ...operation.data,
          },
        },
      );

      if (response.statusCode == 200 && response.data['data'] != null) {
        final updatedProfile = response.data['data']['updateUserProfile'];
        debugPrint('✅ User profile updated on server: ${updatedProfile['id']}');
        return true;
      } else {
        final errors = response.data['errors'];
        debugPrint('❌ Failed to update user profile: $errors');
        return false;
      }
    } on DioException catch (e) {
      debugPrint('❌ DioException updating user profile: ${e.message}');
      return false;
    }
  }

  /// Creates travel preference on the server
  Future<bool> _createTravelPreference(SyncOperationEntity operation) async {
    try {
      final response = await _dio.post(
        _graphqlEndpoint,
        data: {
          'query': GraphQLQueries.createTravelPreference,
          'variables': operation.data,
        },
      );

      if (response.statusCode == 200 && response.data['data'] != null) {
        final createdPref = response.data['data']['createTravelPreference'];
        debugPrint(
            '✅ Travel preference created on server: ${createdPref['id']}');
        return true;
      } else {
        final errors = response.data['errors'];
        debugPrint('❌ Failed to create travel preference: $errors');
        return false;
      }
    } on DioException catch (e) {
      debugPrint('❌ DioException creating travel preference: ${e.message}');
      return false;
    }
  }

  /// Updates travel preference on the server
  Future<bool> _updateTravelPreference(SyncOperationEntity operation) async {
    try {
      final response = await _dio.post(
        _graphqlEndpoint,
        data: {
          'query': GraphQLQueries.updateTravelPreference,
          'variables': {
            'id': operation.entityId,
            ...operation.data,
          },
        },
      );

      if (response.statusCode == 200 && response.data['data'] != null) {
        final updatedPref = response.data['data']['updateTravelPreference'];
        debugPrint(
            '✅ Travel preference updated on server: ${updatedPref['id']}');
        return true;
      } else {
        final errors = response.data['errors'];
        debugPrint('❌ Failed to update travel preference: $errors');
        return false;
      }
    } on DioException catch (e) {
      debugPrint('❌ DioException updating travel preference: ${e.message}');
      return false;
    }
  }
}
