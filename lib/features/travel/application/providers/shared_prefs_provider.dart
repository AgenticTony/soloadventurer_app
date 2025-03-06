import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/repositories/travel_operation_repository.dart';
import '../../infrastructure/repositories/shared_prefs_travel_operation_repository.dart';

/// Provider for SharedPreferences instance
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError(
      'SharedPreferences must be initialized at app startup');
});

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
final travelOperationRepositoryProvider =
    Provider<TravelOperationRepository>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return SharedPrefsTravelOperationRepository(prefs);
});
