import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../storage/secure_storage.dart';

// NOTE: The ApiClient provider has moved to api_providers.dart
// (apiClientProviderFull). This file now only contains providers
// that don't belong in api_providers.dart.

final secureStorageProvider = Provider<SecureStorage>((ref) {
  return SecureStorage();
});
