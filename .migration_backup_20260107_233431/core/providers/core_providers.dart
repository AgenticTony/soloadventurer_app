import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../api/client/api_client.dart';
import 'package:shared_preferences/shared_preferences.dart';

final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient(
      baseUrl:
          'https://api.soloadventurer.com'); // Replace with your actual API URL
});

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError(
      'SharedPreferences must be initialized in bootstrap');
});

/// Provider for ItineraryDao
///
/// Re-export of itineraryDaoProvider from app/providers/offline_service_providers.dart
/// The itineraryDaoProvider is now defined in app/providers/offline_service_providers.dart
final itineraryDaoProvider = itineraryDaoProvider;
