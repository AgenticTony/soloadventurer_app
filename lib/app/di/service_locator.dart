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

  // Register API client first
  await _registerApiClient();

  // Register services that depend on other services
  await _registerDependentServices();

  // Register feature modules
  await _registerFeatureModules();
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
    _isTestMode
        ? const FlutterSecureStorage(
            aOptions: AndroidOptions(encryptedSharedPreferences: true),
            iOptions:
                IOSOptions(accessibility: KeychainAccessibility.first_unlock),
          )
        : const FlutterSecureStorage(),
  );
}

/// Register API client
Future<void> _registerApiClient() async {
  // Register API client (depends on interceptors and network monitor)
  getIt.registerSingleton<ApiClient>(
    ApiClient(
      baseUrl: getIt<Env>().apiBaseUrl,
      authInterceptor: getIt<AuthInterceptor>(),
      errorInterceptor: getIt<ErrorInterceptor>(),
      networkMonitor: getIt<NetworkMonitor>(),
    ),
  );

  // Register API service interface
  getIt.registerSingleton<ApiService>(
    _isTestMode
        ? MockApiClient(
            baseUrl: getIt<Env>().apiBaseUrl,
            authInterceptor: getIt<AuthInterceptor>(),
            errorInterceptor: getIt<ErrorInterceptor>(),
            networkMonitor: getIt<NetworkMonitor>(),
          )
        : getIt<ApiClient>(),
  );
}

/// Register services that depend on other services
Future<void> _registerDependentServices() async {
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

/// Reset all registered dependencies (useful for testing)
Future<void> resetServiceLocator() async {
  await getIt.reset();
}

/// Getter for test mode flag
bool get isTestMode => _isTestMode;
