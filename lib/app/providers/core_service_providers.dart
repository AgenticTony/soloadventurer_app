import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:soloadventurer/core/storage/secure_storage.dart';
import 'package:soloadventurer/features/core/config/app_config.dart';
import 'package:soloadventurer/features/offline/infrastructure/database/database_service.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

part 'core_service_providers.g.dart';

/// Provider for FlutterSecureStorage
///
/// Keeps a single instance alive for the app lifetime.
@Riverpod(keepAlive: true)
FlutterSecureStorage flutterSecureStorage(Ref ref) {
  return const FlutterSecureStorage(
    mOptions: MacOsOptions(usesDataProtectionKeychain: false),
  );
}

/// Provider for SecureStorage wrapper
///
/// Provides a type-safe wrapper around FlutterSecureStorage.
@Riverpod(keepAlive: true)
SecureStorage secureStorage(Ref ref) {
  return SecureStorage();
}

/// Provider for AppConfig
///
/// Provides access to application configuration.
@Riverpod(keepAlive: true)
AppConfig appConfig(Ref ref) {
  return AppConfig();
}

/// Provider for SharedPreferences
///
/// Must be initialized in bootstrap before use.
/// This provider is overridden with the actual instance in bootstrap.dart.
@Riverpod(keepAlive: true)
SharedPreferences sharedPreferences(Ref ref) {
  throw UnimplementedError(
    'SharedPreferences must be initialized in bootstrap and provided via override',
  );
}

/// Provider for Connectivity plugin
///
/// Monitors network connectivity state changes.
@Riverpod(keepAlive: true)
Connectivity connectivity(Ref ref) {
  return Connectivity();
}

/// Provider for DatabaseService
///
/// Manages the local SQLite database lifecycle and provides access to database instances.
@Riverpod(keepAlive: true)
DatabaseService databaseService(Ref ref) {
  return DatabaseService();
}

/// Provider for API Base URL
///
/// Provides the base URL for API requests from AppConfig.
@Riverpod(keepAlive: true)
String apiBaseUrl(Ref ref) {
  return AppConfig.apiBaseUrl;
}
