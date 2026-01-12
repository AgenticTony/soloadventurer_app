import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:soloadventurer/features/core/config/app_config.dart';
import 'package:soloadventurer/app/di/modules/auth_module.dart';
import 'package:soloadventurer/app/di/modules/core_module.dart';
import 'package:soloadventurer/app/di/modules/offline_module.dart';
import 'package:soloadventurer/app/di/modules/travel_module.dart';

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

  // Register SharedPreferences (async initialization)
  // This is registered here for GetIt-based services that need it
  final sharedPreferences = await SharedPreferences.getInstance();
  getIt.registerLazySingleton<SharedPreferences>(
    () => sharedPreferences,
  );
}

/// Register services that depend on other services
Future<void> _registerDependentServices() async {
  // No dependent services to register
}

/// Register all feature modules
Future<void> _registerFeatureModules() async {
  // Register auth feature module
  registerAuthModule(getIt, isTest: _isTestMode);

  // Register offline/sync feature module
  registerOfflineModule(getIt, isTest: _isTestMode);

  // Register travel feature module
  registerTravelModule(getIt, isTest: _isTestMode);
}

/// Reset all registered dependencies (useful for testing)
Future<void> resetServiceLocator() async {
  await getIt.reset();
}

/// Getter for test mode flag
bool get isTestMode => _isTestMode;
