import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:soloadventurer/app/config/env.dart';
import 'package:soloadventurer/app/di/modules/auth_module.dart';
import 'package:soloadventurer/core/api/client/api_client.dart';
import 'package:soloadventurer/core/api/client/mock_api_client.dart';
import 'package:soloadventurer/core/api/interceptors/auth_interceptor.dart';
import 'package:soloadventurer/core/api/interceptors/error_interceptor.dart';
import 'package:soloadventurer/core/monitoring/performance/network_monitor.dart';
import 'package:soloadventurer/features/auth/domain/usecases/get_current_user.dart';
import 'package:soloadventurer/features/auth/domain/usecases/is_signed_in.dart';
import 'package:soloadventurer/features/auth/domain/usecases/login.dart';
import 'package:soloadventurer/features/auth/domain/usecases/sign_out.dart';
import 'package:soloadventurer/features/auth/domain/usecases/sign_up.dart';
import 'package:soloadventurer/features/auth/presentation/providers/auth_notifier.dart';

/// Global GetIt instance for dependency injection
final GetIt getIt = GetIt.instance;

/// Initialize the service locator with all dependencies
Future<void> setupServiceLocator({bool isTest = false}) async {
  // Set test mode
  _isTestMode = isTest;

  // Register singletons that don't depend on other services
  await _registerIndependentServices();

  // Register services that depend on other services
  await _registerDependentServices();

  // Register feature modules
  await _registerFeatureModules();

  // Register test overrides if in test mode
  if (isTest) {
    await _registerTestOverrides();
  }
}

/// Register services that don't depend on other services
Future<void> _registerIndependentServices() async {
  // Register environment configuration
  getIt.registerSingleton<Env>(Env());

  // Register monitoring services
  getIt.registerSingleton<NetworkMonitor>(NetworkMonitor());

  // Register interceptors
  getIt.registerSingleton<ErrorInterceptor>(ErrorInterceptor());
  getIt.registerSingleton<AuthInterceptor>(AuthInterceptor());

  // Register secure storage
  getIt.registerSingleton<FlutterSecureStorage>(
    isTestMode
        ? const FlutterSecureStorage(
            aOptions: AndroidOptions(encryptedSharedPreferences: true),
            iOptions:
                IOSOptions(accessibility: KeychainAccessibility.first_unlock),
          )
        : const FlutterSecureStorage(),
  );
}

/// Register services that depend on other services
Future<void> _registerDependentServices() async {
  // Register API client (depends on interceptors and network monitor)
  getIt.registerSingleton<ApiClient>(
    ApiClient(
      baseUrl: getIt<Env>().apiBaseUrl,
      authInterceptor: getIt<AuthInterceptor>(),
      errorInterceptor: getIt<ErrorInterceptor>(),
      networkMonitor: getIt<NetworkMonitor>(),
    ),
  );
}

/// Register all feature modules
Future<void> _registerFeatureModules() async {
  // Register auth feature module
  registerAuthModule(getIt);
}

/// Register test overrides for dependencies
Future<void> _registerTestOverrides() async {
  // Override secure storage with in-memory implementation for tests
  if (getIt.isRegistered<FlutterSecureStorage>()) {
    getIt.unregister<FlutterSecureStorage>();
  }
  getIt.registerSingleton<FlutterSecureStorage>(
    const FlutterSecureStorage(
      aOptions: AndroidOptions(encryptedSharedPreferences: true),
      iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
    ),
  );

  // Override API client with mock implementation for tests
  if (getIt.isRegistered<ApiClient>()) {
    getIt.unregister<ApiClient>();
  }
  getIt.registerSingleton<ApiClient>(MockApiClient());
}

/// Reset all registered dependencies (useful for testing)
Future<void> resetServiceLocator() async {
  await getIt.reset();
}

/// Flag to indicate if we're in test mode
bool _isTestMode = false;

/// Getter for test mode flag
bool get isTestMode => _isTestMode;
