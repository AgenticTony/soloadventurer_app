import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/repositories/travel_operation_repository.dart';
import '../../domain/models/base_travel_operation.dart';

final travelOperationRepositoryProvider =
    Provider<TravelOperationRepository>((ref) {
  throw UnimplementedError(
      'Repository must be initialized with SharedPreferences');
});

final pendingOperationsProvider =
    FutureProvider<List<BaseTravelOperation>>((ref) async {
  final repository = ref.watch(travelOperationRepositoryProvider);
  return repository.getPendingOperations();
});

class TravelOperationNotifier extends StateNotifier<AsyncValue<void>> {
  final TravelOperationRepository _repository;

  TravelOperationNotifier(this._repository)
      : super(const AsyncValue.data(null));

  Future<void> addOperation(BaseTravelOperation operation) async {
    state = const AsyncValue.loading();
    try {
      await _repository.saveOperation(operation);
      state = const AsyncValue.data(null);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> processOperation(String operationId) async {
    state = const AsyncValue.loading();
    try {
      await _repository.deleteOperation(operationId);
      state = const AsyncValue.data(null);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<List<BaseTravelOperation>> getOperationsForTrip(String tripId) async {
    return _repository.getOperationsForTrip(tripId);
  }

  Future<List<BaseTravelOperation>> getOperationsByType(String type) async {
    return _repository.getOperationsByType(type);
  }
}

final travelOperationNotifierProvider =
    StateNotifierProvider<TravelOperationNotifier, AsyncValue<void>>((ref) {
  final repository = ref.watch(travelOperationRepositoryProvider);
  return TravelOperationNotifier(repository);
});
