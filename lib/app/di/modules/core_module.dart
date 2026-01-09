import 'package:get_it/get_it.dart';
import 'package:soloadventurer/core/storage/secure_storage.dart';

/// Register core module dependencies
void registerCoreModule(GetIt getIt, {bool isTest = false}) {
  // Register core services
  getIt.registerLazySingleton<SecureStorage>(
    () => SecureStorage(),
  );

  // SecurityManager is now a Riverpod provider, not registered in GetIt
  // Use ProviderContainer to access it instead
}
