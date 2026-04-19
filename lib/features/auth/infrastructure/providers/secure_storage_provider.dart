import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:soloadventurer/features/auth/infrastructure/security/secure_token_storage.dart';
import 'package:soloadventurer/features/core/infrastructure/providers/core_providers.dart';

/// Provider for FlutterSecureStorage with secure options
final secureStorageProvider = Provider<FlutterSecureStorage>((ref) {
  // Configure with secure options
  const secureStorageOptions = AndroidOptions(
    resetOnError: true,
  );

  return const FlutterSecureStorage(
    aOptions: secureStorageOptions,
    mOptions: MacOsOptions(usesDataProtectionKeychain: false),
  );
});

/// Provider for SecureTokenStorage
final secureTokenStorageProvider = Provider<SecureTokenStorage>((ref) {
  final secureStorage = ref.watch(secureStorageProvider);
  final loggingService = ref.watch(loggingServiceProvider);

  return SecureTokenStorage(
    secureStorage: secureStorage,
    logger: loggingService,
  );
});

/// Provider for initializing SecureTokenStorage
/// This should be called during app startup
final initializeSecureStorageProvider = FutureProvider<void>((ref) async {
  final secureTokenStorage = ref.watch(secureTokenStorageProvider);
  await secureTokenStorage.initialize();
});
