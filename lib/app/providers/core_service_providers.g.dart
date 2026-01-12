// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'core_service_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provider for FlutterSecureStorage
///
/// Keeps a single instance alive for the app lifetime.

@ProviderFor(flutterSecureStorage)
const flutterSecureStorageProvider = FlutterSecureStorageProvider._();

/// Provider for FlutterSecureStorage
///
/// Keeps a single instance alive for the app lifetime.

final class FlutterSecureStorageProvider extends $FunctionalProvider<
    FlutterSecureStorage,
    FlutterSecureStorage,
    FlutterSecureStorage> with $Provider<FlutterSecureStorage> {
  /// Provider for FlutterSecureStorage
  ///
  /// Keeps a single instance alive for the app lifetime.
  const FlutterSecureStorageProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'flutterSecureStorageProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$flutterSecureStorageHash();

  @$internal
  @override
  $ProviderElement<FlutterSecureStorage> $createElement(
          $ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  FlutterSecureStorage create(Ref ref) {
    return flutterSecureStorage(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(FlutterSecureStorage value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<FlutterSecureStorage>(value),
    );
  }
}

String _$flutterSecureStorageHash() =>
    r'74fc6ea2bb3b1f668a5f3e4f549614146c526484';

/// Provider for SecureStorage wrapper
///
/// Provides a type-safe wrapper around FlutterSecureStorage.

@ProviderFor(secureStorage)
const secureStorageProvider = SecureStorageProvider._();

/// Provider for SecureStorage wrapper
///
/// Provides a type-safe wrapper around FlutterSecureStorage.

final class SecureStorageProvider
    extends $FunctionalProvider<SecureStorage, SecureStorage, SecureStorage>
    with $Provider<SecureStorage> {
  /// Provider for SecureStorage wrapper
  ///
  /// Provides a type-safe wrapper around FlutterSecureStorage.
  const SecureStorageProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'secureStorageProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$secureStorageHash();

  @$internal
  @override
  $ProviderElement<SecureStorage> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  SecureStorage create(Ref ref) {
    return secureStorage(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SecureStorage value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SecureStorage>(value),
    );
  }
}

String _$secureStorageHash() => r'5c9908c0046ad0e39469ee7acbb5540397b36693';

/// Provider for AppConfig
///
/// Provides access to application configuration.

@ProviderFor(appConfig)
const appConfigProvider = AppConfigProvider._();

/// Provider for AppConfig
///
/// Provides access to application configuration.

final class AppConfigProvider
    extends $FunctionalProvider<AppConfig, AppConfig, AppConfig>
    with $Provider<AppConfig> {
  /// Provider for AppConfig
  ///
  /// Provides access to application configuration.
  const AppConfigProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'appConfigProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$appConfigHash();

  @$internal
  @override
  $ProviderElement<AppConfig> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AppConfig create(Ref ref) {
    return appConfig(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AppConfig value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AppConfig>(value),
    );
  }
}

String _$appConfigHash() => r'6989be971ffe295fb8fd413a9b6dfe4377d3e6f5';

/// Provider for SharedPreferences
///
/// Must be initialized in bootstrap before use.
/// This provider is overridden with the actual instance in bootstrap.dart.

@ProviderFor(sharedPreferences)
const sharedPreferencesProvider = SharedPreferencesProvider._();

/// Provider for SharedPreferences
///
/// Must be initialized in bootstrap before use.
/// This provider is overridden with the actual instance in bootstrap.dart.

final class SharedPreferencesProvider extends $FunctionalProvider<
    SharedPreferences,
    SharedPreferences,
    SharedPreferences> with $Provider<SharedPreferences> {
  /// Provider for SharedPreferences
  ///
  /// Must be initialized in bootstrap before use.
  /// This provider is overridden with the actual instance in bootstrap.dart.
  const SharedPreferencesProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'sharedPreferencesProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$sharedPreferencesHash();

  @$internal
  @override
  $ProviderElement<SharedPreferences> $createElement(
          $ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  SharedPreferences create(Ref ref) {
    return sharedPreferences(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SharedPreferences value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SharedPreferences>(value),
    );
  }
}

String _$sharedPreferencesHash() => r'14dd3863ff829056bf2edaa3e9041d73490ea87d';

/// Provider for Connectivity plugin
///
/// Monitors network connectivity state changes.

@ProviderFor(connectivity)
const connectivityProvider = ConnectivityProvider._();

/// Provider for Connectivity plugin
///
/// Monitors network connectivity state changes.

final class ConnectivityProvider
    extends $FunctionalProvider<Connectivity, Connectivity, Connectivity>
    with $Provider<Connectivity> {
  /// Provider for Connectivity plugin
  ///
  /// Monitors network connectivity state changes.
  const ConnectivityProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'connectivityProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$connectivityHash();

  @$internal
  @override
  $ProviderElement<Connectivity> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  Connectivity create(Ref ref) {
    return connectivity(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Connectivity value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Connectivity>(value),
    );
  }
}

String _$connectivityHash() => r'15246627d0ae599bcd01382c80d3d25b9e9b4e18';

/// Provider for DatabaseService
///
/// Manages the local SQLite database lifecycle and provides access to database instances.

@ProviderFor(databaseService)
const databaseServiceProvider = DatabaseServiceProvider._();

/// Provider for DatabaseService
///
/// Manages the local SQLite database lifecycle and provides access to database instances.

final class DatabaseServiceProvider extends $FunctionalProvider<DatabaseService,
    DatabaseService, DatabaseService> with $Provider<DatabaseService> {
  /// Provider for DatabaseService
  ///
  /// Manages the local SQLite database lifecycle and provides access to database instances.
  const DatabaseServiceProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'databaseServiceProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$databaseServiceHash();

  @$internal
  @override
  $ProviderElement<DatabaseService> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  DatabaseService create(Ref ref) {
    return databaseService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DatabaseService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DatabaseService>(value),
    );
  }
}

String _$databaseServiceHash() => r'323927c4138725be4427216964fece6d70043b46';

/// Provider for API Base URL
///
/// Provides the base URL for API requests from AppConfig.

@ProviderFor(apiBaseUrl)
const apiBaseUrlProvider = ApiBaseUrlProvider._();

/// Provider for API Base URL
///
/// Provides the base URL for API requests from AppConfig.

final class ApiBaseUrlProvider
    extends $FunctionalProvider<String, String, String> with $Provider<String> {
  /// Provider for API Base URL
  ///
  /// Provides the base URL for API requests from AppConfig.
  const ApiBaseUrlProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'apiBaseUrlProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$apiBaseUrlHash();

  @$internal
  @override
  $ProviderElement<String> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  String create(Ref ref) {
    return apiBaseUrl(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String>(value),
    );
  }
}

String _$apiBaseUrlHash() => r'77dc5bba93004c423575357f387ca93805600f69';
