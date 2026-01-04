// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'operation_storage_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$operationStorageServiceHash() =>
    r'27641b634df34d6630ac2ad464bb28ae1991978f';

/// Service for persisting and retrieving queued operations.
///
/// Handles serialization, deserialization, and storage of operations using
/// a combination of shared_preferences (for general data) and flutter_secure_storage
/// (for sensitive data).
///
/// ## Storage Strategy
/// - **Pending operations**: Stored in shared_preferences
/// - **Failed operations**: Stored in shared_preferences
/// - **Sensitive data**: Stored in flutter_secure_storage (encrypted)
/// - **Version tracking**: Handles future schema migrations
///
/// ## Thread Safety
/// All public methods are thread-safe and can be called from any isolate.
/// Storage operations are atomic at the key level.
///
/// ## Error Handling
/// - Invalid/corrupted operations are skipped with a warning
/// - Storage failures return false but don't throw exceptions
/// - All errors are logged for debugging
///
/// ## Usage Example
/// ```dart
/// final storageService = ref.read(operationStorageServiceProvider.notifier);
///
/// // Save operations
/// await storageService.savePendingOperations(operations);
///
/// // Load operations
/// final result = await storageService.loadOperations();
/// for (final opData in result.pendingOperations) {
///   final operation = MyOperation.fromJson(opData);
/// }
///
/// // Get storage stats
/// final stats = await storageService.getStorageStats();
/// print('Total size: ${stats['totalSizeBytes']} bytes');
/// ```
///
/// Copied from [OperationStorageService].
@ProviderFor(OperationStorageService)
final operationStorageServiceProvider =
    AutoDisposeAsyncNotifierProvider<OperationStorageService, void>.internal(
  OperationStorageService.new,
  name: r'operationStorageServiceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$operationStorageServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$OperationStorageService = AutoDisposeAsyncNotifier<void>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
