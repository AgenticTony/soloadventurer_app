// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'operation_storage_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
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

@ProviderFor(OperationStorageService)
const operationStorageServiceProvider = OperationStorageServiceProvider._();

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
final class OperationStorageServiceProvider
    extends $AsyncNotifierProvider<OperationStorageService, void> {
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
  const OperationStorageServiceProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'operationStorageServiceProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$operationStorageServiceHash();

  @$internal
  @override
  OperationStorageService create() => OperationStorageService();
}

String _$operationStorageServiceHash() =>
    r'a06ca5e2590975586217238c9affb143241cdd4b';

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

abstract class _$OperationStorageService extends $AsyncNotifier<void> {
  FutureOr<void> build();
  @$mustCallSuper
  @override
  void runBuild() {
    build();
    final ref = this.ref as $Ref<AsyncValue<void>, void>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<AsyncValue<void>, void>,
        AsyncValue<void>,
        Object?,
        Object?>;
    element.handleValue(ref, null);
  }
}
