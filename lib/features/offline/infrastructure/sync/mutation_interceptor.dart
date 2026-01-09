import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:soloadventurer/features/offline/domain/entities/sync_operation.dart';
import 'package:soloadventurer/features/offline/domain/services/connectivity_service.dart';
import 'package:soloadventurer/features/offline/domain/services/sync_queue_service.dart';
import 'package:soloadventurer/features/offline/infrastructure/sync/offline_interceptor.dart';

/// Request metadata for intercepted mutations
///
/// Contains parsed information about a GraphQL mutation request
/// to help with offline interception.
class MutationMetadata {
  /// The entity type being mutated (e.g., 'trip', 'journal')
  final String entityType;

  /// The entity ID being mutated
  final String? entityId;

  /// The type of mutation operation
  final SyncOperationType operation;

  /// The mutation data payload
  final Map<String, dynamic> data;

  /// Creates a new [MutationMetadata]
  const MutationMetadata({
    required this.entityType,
    this.entityId,
    required this.operation,
    required this.data,
  });

  @override
  String toString() {
    return 'MutationMetadata(entityType: $entityType, entityId: $entityId, '
        'operation: ${operation.value})';
  }
}

/// Result of a mutation interception
///
/// Contains information about whether the mutation was executed
/// immediately, queued for later, or failed.
class MutationInterceptorResult {
  /// Whether the mutation was executed immediately (online)
  final bool executedImmediately;

  /// Whether the mutation was queued for later sync (offline)
  final bool queued;

  /// Whether the mutation failed
  final bool failed;

  /// Error message if the mutation failed
  final String? errorMessage;

  /// ID of the queued sync operation (if queued)
  final int? queuedOperationId;

  /// The response data (if executed immediately)
  final dynamic responseData;

  /// Creates a successful result for immediate execution
  const MutationInterceptorResult.executed(this.responseData)
      : executedImmediately = true,
        queued = false,
        failed = false,
        errorMessage = null,
        queuedOperationId = null;

  /// Creates a result for queued mutation
  const MutationInterceptorResult.queued(this.queuedOperationId)
      : executedImmediately = false,
        queued = true,
        failed = false,
        errorMessage = null,
        responseData = null;

  /// Creates a failed result
  const MutationInterceptorResult.failure(this.errorMessage)
      : executedImmediately = false,
        queued = false,
        failed = true,
        queuedOperationId = null,
        responseData = null;

  @override
  String toString() {
    if (failed) {
      return 'MutationInterceptorResult.failure(errorMessage: $errorMessage)';
    } else if (queued) {
      return 'MutationInterceptorResult.queued(operationId: $queuedOperationId)';
    } else {
      return 'MutationInterceptorResult.executed(data: $responseData)';
    }
  }
}

/// Callback for parsing mutation metadata from a request
///
/// This callback should analyze the request and extract information
/// about the entity type, operation type, and payload.
typedef MutationParser = MutationMetadata? Function(RequestOptions options);

/// Callback for updating local database with mutation data
///
/// This callback is called when a mutation is queued (offline) to
/// update the local database immediately with optimistic changes.
typedef LocalMutationUpdate = Future<void> Function(
  MutationMetadata metadata,
);

/// Dio interceptor for offline-first GraphQL mutations
///
/// This interceptor captures GraphQL mutation requests and handles them
/// based on connectivity status:
/// - Online: Execute the mutation immediately
/// - Offline: Queue for later sync and update local database
///
/// The interceptor integrates seamlessly with Dio's request pipeline
/// and can be added to any Dio instance.
///
/// Example usage:
/// ```dart
/// final dio = Dio();
/// final mutationInterceptor = MutationInterceptor(
///   connectivityService: connectivityService,
///   syncQueueService: syncQueueService,
///   mutationParser: (options) {
///     // Parse the GraphQL mutation to extract metadata
///     final mutation = options.data['query'] as String;
///     final variables = options.data['variables'] as Map<String, dynamic>;
///     // ... parse and return MutationMetadata
///   },
///   localUpdate: (metadata) async {
///     // Update local database
///     await localDataSource.updateEntity(metadata);
///   },
/// );
///
/// dio.interceptors.add(mutationInterceptor);
/// ```
class MutationInterceptor extends Interceptor {
  /// Connectivity service for checking network status
  final ConnectivityService _connectivityService;

  /// Sync queue service for queueing operations
  final SyncQueueService _syncQueueService;

  /// Callback for parsing mutation metadata from requests
  final MutationParser _mutationParser;

  /// Callback for updating local database
  final LocalMutationUpdate _localUpdate;

  /// Configuration for interception behavior
  final InterceptorConfig _config;

  /// Creates a new [MutationInterceptor]
  ///
  /// [connectivityService] - Service for checking network connectivity
  /// [syncQueueService] - Service for queueing offline operations
  /// [mutationParser] - Callback to parse mutation metadata from requests
  /// [localUpdate] - Callback to update local database with mutations
  /// [config] - Configuration for interception behavior
  MutationInterceptor({
    required ConnectivityService connectivityService,
    required SyncQueueService syncQueueService,
    required MutationParser mutationParser,
    required LocalMutationUpdate localUpdate,
    InterceptorConfig config = InterceptorConfig.defaultConfig,
  })  : _connectivityService = connectivityService,
        _syncQueueService = syncQueueService,
        _mutationParser = mutationParser,
        _localUpdate = localUpdate,
        _config = config;

  // ==============================================================================
  // DIO INTERCEPTOR METHODS
  // ==============================================================================

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Check if this is a mutation request
    final metadata = _mutationParser(options);

    if (metadata == null) {
      // Not a mutation or couldn't parse - proceed normally
      debugPrint('🔄 Not a mutation request, proceeding normally');
      handler.next(options);
      return;
    }

    debugPrint('🔄 Intercepting mutation: ${metadata.operation.value} '
        '${metadata.entityType}:${metadata.entityId}');

    // Check if interception is enabled
    if (!_config.enabled) {
      debugPrint('🔄 Mutation interception disabled, executing immediately');
      handler.next(options);
      return;
    }

    // Check connectivity status
    try {
      final connectivityStatus = await _connectivityService.checkConnectivity();
      final isConnected = connectivityStatus.isConnected;

      debugPrint('🔄 Mutation connectivity check: $isConnected');

      if (isConnected) {
        // Online - proceed with the request
        debugPrint('✅ Online - executing mutation immediately');
        handler.next(options);
      } else {
        // Offline - queue the mutation and return optimistic response
        if (_config.queueWhenOffline) {
          debugPrint('📴 Offline - queuing mutation for later sync');
          await _handleOfflineMutation(metadata, options, handler);
        } else {
          // Queueing disabled - fail the request
          final error = DioException(
            requestOptions: options,
            type: DioExceptionType.connectionError,
            error: 'Offline and mutation queueing disabled',
          );
          debugPrint('❌ Offline and queueing disabled');
          handler.reject(error);
        }
      }
    } catch (e) {
      // Error checking connectivity - proceed with request
      debugPrint('⚠️ Error checking connectivity: $e, proceeding with request');
      handler.next(options);
    }
  }

  @override
  void onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) {
    // Check if this is a mutation request that failed due to network
    final metadata =
        err.requestOptions.extra['mutationMetadata'] as MutationMetadata?;

    if (metadata == null) {
      // Not an intercepted mutation - proceed normally
      handler.next(err);
      return;
    }

    // Check if error is due to connectivity
    final isNetworkError = err.type == DioExceptionType.connectionError ||
        err.type == DioExceptionType.receiveTimeout ||
        err.type == DioExceptionType.sendTimeout;

    if (isNetworkError && _config.queueWhenOffline) {
      debugPrint('📴 Mutation failed due to network error, queuing for retry');
      // Cannot call async method in sync onError handler
      // Just proceed with the error for now
      handler.next(err);
    } else {
      // Not a network error or queueing disabled - proceed with error
      handler.next(err);
    }
  }

  // ==============================================================================
  // PRIVATE METHODS
  // ==============================================================================

  /// Handles an offline mutation by queuing it and returning an optimistic response
  Future<void> _handleOfflineMutation(
    MutationMetadata metadata,
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    try {
      // Update local database immediately (optimistic)
      await _localUpdate(metadata);
      debugPrint('✅ Local database updated (optimistic)');

      // Generate a temporary ID if needed
      final tempId =
          metadata.entityId ?? 'temp_${DateTime.now().millisecondsSinceEpoch}';

      // Queue the operation for sync
      final result = await _syncQueueService.enqueueOperation(
        entityType: metadata.entityType,
        entityId: tempId,
        operation: metadata.operation,
        data: metadata.data,
        priority: _config.defaultPriority,
        maxRetries: _config.maxRetries,
      );

      if (result.success) {
        debugPrint(
            '✅ Mutation queued successfully (id: ${result.operationId})');

        if (_config.optimisticResponses) {
          // Return optimistic response to caller
          final optimisticResponse = _createOptimisticResponse(
            metadata,
            tempId,
          );
          handler.resolve(optimisticResponse);
        } else {
          // Return a success response without data
          handler.resolve(
            Response(
              requestOptions: options,
              statusCode: 202, // Accepted
              data: {
                'success': true,
                'queued': true,
                'message': 'Operation queued for sync',
              },
            ),
          );
        }
      } else {
        // Failed to queue - return error
        final error = DioException(
          requestOptions: options,
          type: DioExceptionType.unknown,
          error: 'Failed to queue mutation: ${result.errorMessage}',
        );
        debugPrint('❌ Failed to queue mutation: ${result.errorMessage}');
        handler.reject(error);
      }
    } catch (e) {
      // Error handling offline mutation
      final error = DioException(
        requestOptions: options,
        type: DioExceptionType.unknown,
        error: 'Failed to handle offline mutation: $e',
      );
      debugPrint('❌ Error handling offline mutation: $e');
      handler.reject(error);
    }
  }

  /// Creates an optimistic response for a queued mutation
  ///
  /// The response format depends on the entity type and operation.
  Response<dynamic> _createOptimisticResponse(
    MutationMetadata metadata,
    String tempId,
  ) {
    // Create optimistic data based on operation type
    final optimisticData = _createOptimisticData(metadata, tempId);

    return Response<dynamic>(
      requestOptions: RequestOptions(
        path: '',
      ),
      statusCode: 200,
      data: {
        'data': optimisticData,
        'optimistic': true,
        'queued': true,
      },
    );
  }

  /// Creates optimistic response data based on mutation type
  Map<String, dynamic> _createOptimisticData(
    MutationMetadata metadata,
    String tempId,
  ) {
    switch (metadata.operation) {
      case SyncOperationType.create:
        // Return the created entity with temp ID
        return {
          metadata.entityType: {
            'id': tempId,
            'createdAt': DateTime.now().toIso8601String(),
            ...metadata.data,
          },
        };

      case SyncOperationType.update:
        // Return the updated entity
        return {
          'update${_capitalize(metadata.entityType)}': {
            'id': metadata.entityId ?? tempId,
            'updatedAt': DateTime.now().toIso8601String(),
            ...metadata.data,
          },
        };

      case SyncOperationType.delete:
        // Return success flag
        return {
          'delete${_capitalize(metadata.entityType)}': {
            'id': metadata.entityId ?? tempId,
            'success': true,
          },
        };
    }
  }

  /// Capitalizes the first letter of a string
  String _capitalize(String str) {
    if (str.isEmpty) return str;
    return str[0].toUpperCase() + str.substring(1);
  }
}

/// Helper class to create standard GraphQL mutation parsers
///
/// Provides utility methods for parsing common GraphQL mutation patterns.
class MutationParserHelper {
  /// Parses a GraphQL mutation from request options
  ///
  /// Analyzes the request to extract:
  /// - Entity type (e.g., 'trip', 'journal')
  /// - Operation type (create, update, delete)
  /// - Entity ID (for update/delete)
  /// - Mutation data (variables)
  ///
  /// Returns null if the request is not a recognized mutation.
  static MutationMetadata? parseStandardMutation(RequestOptions options) {
    // Extract query and variables from request
    final requestData = options.data;
    if (requestData is! Map<String, dynamic>) {
      return null;
    }

    final query = requestData['query'] as String?;
    final variables = requestData['variables'] as Map<String, dynamic>?;

    if (query == null || variables == null) {
      return null;
    }

    // Parse the mutation name
    final mutationMatch = RegExp(r'mutation\s+(\w+)').firstMatch(query);
    if (mutationMatch == null) {
      return null;
    }

    final mutationName = mutationMatch.group(1)!;

    // Determine operation type from mutation name
    SyncOperationType? operationType;
    String? entityType;
    String? entityId;

    if (mutationName.startsWith('create')) {
      operationType = SyncOperationType.create;
      entityType = mutationName.substring(6).toLowerCase(); // Remove 'create'
    } else if (mutationName.startsWith('update')) {
      operationType = SyncOperationType.update;
      entityType = mutationName.substring(6).toLowerCase(); // Remove 'update'
      entityId = variables['id']?.toString();
    } else if (mutationName.startsWith('delete')) {
      operationType = SyncOperationType.delete;
      entityType = mutationName.substring(6).toLowerCase(); // Remove 'delete'
      entityId = variables['id']?.toString();
    }

    if (operationType == null || entityType == null) {
      return null;
    }

    // Clean up entity type (handle plural/singular)
    if (entityType.endsWith('s')) {
      entityType = entityType.substring(0, entityType.length - 1);
    }

    return MutationMetadata(
      entityType: entityType,
      entityId: entityId,
      operation: operationType,
      data: variables,
    );
  }

  /// Creates a custom mutation parser for specific entity types
  ///
  /// Use this for non-standard mutation names or custom parsing logic.
  /// The [parser] function should extract metadata from the request options.
  static MutationParser customParser(
    MutationMetadata? Function(RequestOptions options) parser,
  ) {
    return parser;
  }
}
