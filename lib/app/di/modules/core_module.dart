import 'package:get_it/get_it.dart';
import 'package:soloadventurer/core/storage/secure_storage.dart';
import 'package:soloadventurer/core/storage/secure_storage_adapter.dart';
import 'package:soloadventurer/features/core/infrastructure/api/dio_api_service.dart';

/// Register core module dependencies
void registerCoreModule(GetIt getIt, {bool isTest = false}) {
  // Register DioApiService first as it's a core dependency
  // This must be registered before modules that depend on it (e.g., OfflineModule)
  getIt.registerLazySingleton<DioApiService>(
    () => DioApiService(),
  );

  // Register SecureStorage wrapper
  getIt.registerLazySingleton<SecureStorage>(
    () => SecureStorage(),
  );

  // Register SecurityManagerAdapter as a bridge between GetIt and Riverpod
  // Note: The adapter must be initialized with the actual SecurityManager
  // from Riverpod during app bootstrap (see bootstrap.dart)
  getIt.registerLazySingleton<SecurityManagerAdapter>(
    () => SecurityManagerAdapter(),
  );
}
