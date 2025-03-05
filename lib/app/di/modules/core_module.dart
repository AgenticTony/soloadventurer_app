import 'package:get_it/get_it.dart';
import 'package:soloadventurer/core/security/security_manager.dart';
import 'package:soloadventurer/core/storage/secure_storage.dart';

/// Register core module dependencies
void registerCoreModule(GetIt getIt, {bool isTest = false}) {
  // Register core services
  getIt.registerLazySingleton<SecureStorage>(
    () => SecureStorage(),
  );

  getIt.registerLazySingleton<SecurityManager>(
    () => SecurityManagerImpl(
      storage: getIt<SecureStorage>(),
      isTest: isTest,
    ),
  );
}
