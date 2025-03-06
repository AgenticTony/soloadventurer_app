import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:soloadventurer/app/config/env.dart';
import 'package:soloadventurer/app/di/modules/auth_module.dart';
import 'package:soloadventurer/app/di/modules/core_module.dart';
import 'package:soloadventurer/core/api/client/api_client.dart';
import 'package:soloadventurer/core/api/client/mock_api_client.dart';
import 'package:soloadventurer/core/api/interceptors/auth_interceptor.dart';
import 'package:soloadventurer/core/api/interceptors/error_interceptor.dart';
import 'package:soloadventurer/core/monitoring/performance/network_monitor.dart';
import 'package:soloadventurer/services/monitoring/monitoring_service.dart';
import 'package:soloadventurer/services/monitoring/aws_cloudwatch_monitoring.dart';
import 'package:soloadventurer/core/api/api_service.dart';

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
  getIt.registerSingleton<ApiService>(
    ApiClient(
      baseUrl: getIt<Env>().apiBaseUrl,
      authInterceptor: getIt<AuthInterceptor>(),
      errorInterceptor: getIt<ErrorInterceptor>(),
      networkMonitor: getIt<NetworkMonitor>(),
    ),
  );

  // Register monitoring service (depends on API client)
  getIt.registerSingleton<MonitoringService>(
    AwsCloudWatchMonitoring(getIt<ApiService>()),
  );
}

/// Register all feature modules
Future<void> _registerFeatureModules() async {
  // Register auth feature module
  registerAuthModule(getIt, isTest: _isTestMode);
}

/// Register test overrides for dependencies
Future<void> _registerTestOverrides() async {
  // Override API client with mock in test mode
  getIt.registerSingleton<ApiService>(
    MockApiClient(
      baseUrl: getIt<Env>().apiBaseUrl,
      authInterceptor: getIt<AuthInterceptor>(),
      errorInterceptor: getIt<ErrorInterceptor>(),
      networkMonitor: getIt<NetworkMonitor>(),
    ),
  );
}

/// Reset all registered dependencies (useful for testing)
Future<void> resetServiceLocator() async {
  await getIt.reset();
}

/// Getter for test mode flag
bool get isTestMode => _isTestMode;
