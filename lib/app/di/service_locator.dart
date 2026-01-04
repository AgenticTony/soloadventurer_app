import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:soloadventurer/features/core/config/app_config.dart';
import 'package:soloadventurer/app/di/modules/auth_module.dart';
import 'package:soloadventurer/app/di/modules/core_module.dart';
import 'package:soloadventurer/app/di/modules/offline_module.dart';
import 'package:soloadventurer/features/core/infrastructure/api/api_service.dart';
import 'package:soloadventurer/features/core/infrastructure/api/dio_api_service.dart';

/// Global GetIt instance for dependency injection
final GetIt getIt = GetIt.instance;

/// Flag to indicate if we're in test mode
bool _isTestMode = false;

/// Initialize the service locator with all dependencies
Future<void> setupServiceLocator({bool isTest = false}) async {
  // Set test mode
  _isTestMode = isTest;

  // Register core module
  registerCoreModule(getIt, isTest: isTest);

  // Register singletons that don't depend on other services
  await _registerIndependentServices();

  // Register API client first
  await _registerApiClient();

  // Register services that depend on other services
  await _registerDependentServices();

  // Register feature modules
  await _registerFeatureModules();
}

/// Register services that don't depend on other services
Future<void> _registerIndependentServices() async {
  // Register secure storage
  getIt.registerLazySingleton<FlutterSecureStorage>(
    () => const FlutterSecureStorage(),
  );

  // Register app configuration
  getIt.registerLazySingleton(() => AppConfig());
}

/// Register API client and related services
Future<void> _registerApiClient() async {
  // Register API service
  getIt.registerLazySingleton<ApiService>(
    () => DioApiService(),
  );
}

/// Register services that depend on other services
Future<void> _registerDependentServices() async {
  // Register monitoring service
  getIt.registerLazySingleton(
    () => AppConfig.awsConfig.userPool,
  );
}

/// Register all feature modules
Future<void> _registerFeatureModules() async {
  // Register auth feature module
  registerAuthModule(getIt, isTest: _isTestMode);

  // Register offline/sync feature module
  registerOfflineModule(getIt, isTest: _isTestMode);
}

/// Reset all registered dependencies (useful for testing)
Future<void> resetServiceLocator() async {
  await getIt.reset();
}

/// Getter for test mode flag
bool get isTestMode => _isTestMode;
