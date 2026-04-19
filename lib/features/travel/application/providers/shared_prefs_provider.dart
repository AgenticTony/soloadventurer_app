import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soloadventurer/app/providers/core_service_providers.dart' show sharedPreferencesProvider;
import '../../domain/repositories/travel_operation_repository.dart';
import '../../infrastructure/repositories/shared_prefs_travel_operation_repository.dart';

/// Provider for TravelOperationRepository using SharedPreferences
final travelOperationRepositoryProvider =
    Provider<TravelOperationRepository>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return SharedPrefsTravelOperationRepository(prefs);
});
