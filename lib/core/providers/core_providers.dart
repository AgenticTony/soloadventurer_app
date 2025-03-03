import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../network/api_client.dart';
import '../storage/secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient(
      baseUrl:
          'https://api.soloadventurer.com'); // Replace with your actual API URL
});

final secureStorageProvider = Provider<SecureStorage>((ref) {
  return SecureStorage();
});

final sharedPreferencesProvider =
    FutureProvider<SharedPreferences>((ref) async {
  return await SharedPreferences.getInstance();
});
