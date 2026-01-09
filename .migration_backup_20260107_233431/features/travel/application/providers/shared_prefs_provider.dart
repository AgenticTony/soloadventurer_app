import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/repositories/travel_operation_repository.dart';
import '../../domain/models/base_travel_operation.dart';
import '../../infrastructure/repositories/shared_prefs_travel_operation_repository.dart';

part 'shared_prefs_provider.g.dart';

/// Provider for SharedPreferences instance
@riverpod
SharedPreferences sharedPreferences(Ref ref) {
  throw UnimplementedError(
      'SharedPreferences must be initialized at app startup');
}

/// Override this provider during app initialization with:
/// ```dart
/// final prefs = await SharedPreferences.getInstance();
/// ProviderContainer(
///   overrides: [
///     sharedPreferencesProvider.overrideWithValue(prefs),
///   ],
///   child: MyApp(),
/// );
/// ```

/// Provider for travel operation repository
@riverpod
TravelOperationRepository travelOperationRepository(Ref ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return SharedPrefsTravelOperationRepository(prefs);
}

/// Provider for pending operations
@riverpod
Future<List<BaseTravelOperation>> pendingOperations(Ref ref) async {
  final repository = ref.watch(travelOperationRepositoryProvider);
  return repository.getPendingOperations();
}

/// Notifier for managing travel operations
@riverpod
class TravelOperationNotifier extends _$TravelOperationNotifier {
  @override
  AsyncValue<void> build() => const AsyncValue.data(null);

  Future<void> addOperation(BaseTravelOperation operation) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(travelOperationRepositoryProvider);
      await repository.saveOperation(operation);
    });
  }

  Future<void> processOperation(String operationId) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(travelOperationRepositoryProvider);
      await repository.deleteOperation(operationId);
    });
  }

  Future<List<BaseTravelOperation>> getOperationsForTrip(String tripId) async {
    final repository = ref.read(travelOperationRepositoryProvider);
    return repository.getOperationsForTrip(tripId);
  }

  Future<List<BaseTravelOperation>> getOperationsByType(String type) async {
    final repository = ref.read(travelOperationRepositoryProvider);
    return repository.getOperationsByType(type);
  }
}
