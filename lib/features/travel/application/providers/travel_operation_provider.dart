import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/repositories/travel_operation_repository.dart';
import '../../domain/models/base_travel_operation.dart';

part 'travel_operation_provider.g.dart';

/// Riverpod 3.0 Migration Notes:
/// - Converted from StateNotifier to @riverpod Notifier
/// - Dependencies injected via ref.watch() in build() method
/// - Keeps AsyncValue<void> state pattern (synchronous Notifier with AsyncValue state)
/// - Initialization logic moved from constructor to build() method
///
/// Provider for the travel operation repository
@riverpod
TravelOperationRepository travelOperationRepository(TravelOperationRepositoryRef ref) {
  throw UnimplementedError(
      'Repository must be initialized with SharedPreferences');
}

/// Provider for pending operations
///
/// Riverpod 3.0: Uses @riverpod annotation for FutureProvider
@riverpod
Future<List<BaseTravelOperation>> pendingOperations(PendingOperationsRef ref) async {
  final repository = ref.watch(travelOperationRepositoryProvider);
  return repository.getPendingOperations();
}

/// Provider for managing travel operation state
///
/// Riverpod 3.0: Uses @riverpod annotation with Notifier pattern.
/// Keeps AsyncValue<void> state for tracking operation status.
///
/// Usage:
/// ```dart
/// final operationState = ref.watch(travelOperationNotifierProvider);
/// final operationNotifier = ref.read(travelOperationNotifierProvider.notifier);
///
/// // Add operation
/// await operationNotifier.addOperation(operation);
///
/// // Process operation
/// await operationNotifier.processOperation(operationId);
/// ```
@riverpod
class TravelOperation extends _$TravelOperation {
  /// Initialize the notifier with dependencies
  ///
  /// Riverpod 3.0: build() replaces constructor for initialization
  @override
  AsyncValue<void> build() {
    // Get dependencies via ref.watch()
    final repository = ref.watch(travelOperationRepositoryProvider);

    // Return initial state
    return const AsyncValue.data(null);
  }

  /// Add a travel operation
  ///
  /// The [operation] parameter is the operation to add.
  ///
  /// Throws an exception if adding fails.
  Future<void> addOperation(BaseTravelOperation operation) async {
    // Get repository
    final repository = ref.read(travelOperationRepositoryProvider);

    // Set loading state
    state = const AsyncValue.loading();

    try {
      await repository.saveOperation(operation);
      state = const AsyncValue.data(null);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// Process a travel operation
  ///
  /// The [operationId] parameter is the ID of the operation to process.
  ///
  /// Throws an exception if processing fails.
  Future<void> processOperation(String operationId) async {
    // Get repository
    final repository = ref.read(travelOperationRepositoryProvider);

    // Set loading state
    state = const AsyncValue.loading();

    try {
      await repository.deleteOperation(operationId);
      state = const AsyncValue.data(null);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// Get operations for a specific trip
  ///
  /// The [tripId] parameter is the ID of the trip.
  /// Returns a list of travel operations for the trip.
  Future<List<BaseTravelOperation>> getOperationsForTrip(String tripId) async {
    final repository = ref.read(travelOperationRepositoryProvider);
    return repository.getOperationsForTrip(tripId);
  }

  /// Get operations by type
  ///
  /// The [type] parameter is the operation type to filter by.
  /// Returns a list of travel operations matching the type.
  Future<List<BaseTravelOperation>> getOperationsByType(String type) async {
    final repository = ref.read(travelOperationRepositoryProvider);
    return repository.getOperationsByType(type);
  }
}
