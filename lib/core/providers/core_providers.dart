import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../network/api_client.dart';
import '../storage/secure_storage.dart';

final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient(
      baseUrl:
          'https://api.soloadventurer.com'); // Replace with your actual API URL
});

final secureStorageProvider = Provider<SecureStorage>((ref) {
  return SecureStorage();
});
