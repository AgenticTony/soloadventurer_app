// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'core_service_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$flutterSecureStorageHash() =>
    r'74fc6ea2bb3b1f668a5f3e4f549614146c526484';

/// Provider for FlutterSecureStorage
///
/// Keeps a single instance alive for the app lifetime.
///
/// Copied from [flutterSecureStorage].
@ProviderFor(flutterSecureStorage)
final flutterSecureStorageProvider = Provider<FlutterSecureStorage>.internal(
  flutterSecureStorage,
  name: r'flutterSecureStorageProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$flutterSecureStorageHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef FlutterSecureStorageRef = ProviderRef<FlutterSecureStorage>;
String _$secureStorageHash() => r'5c9908c0046ad0e39469ee7acbb5540397b36693';

/// Provider for SecureStorage wrapper
///
/// Provides a type-safe wrapper around FlutterSecureStorage.
///
/// Copied from [secureStorage].
@ProviderFor(secureStorage)
final secureStorageProvider = Provider<SecureStorage>.internal(
  secureStorage,
  name: r'secureStorageProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$secureStorageHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef SecureStorageRef = ProviderRef<SecureStorage>;
String _$appConfigHash() => r'6989be971ffe295fb8fd413a9b6dfe4377d3e6f5';

/// Provider for AppConfig
///
/// Provides access to application configuration including AWS Cognito settings.
///
/// Copied from [appConfig].
@ProviderFor(appConfig)
final appConfigProvider = Provider<AppConfig>.internal(
  appConfig,
  name: r'appConfigProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$appConfigHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AppConfigRef = ProviderRef<AppConfig>;
String _$sharedPreferencesHash() => r'14dd3863ff829056bf2edaa3e9041d73490ea87d';

/// Provider for SharedPreferences
///
/// Must be initialized in bootstrap before use.
/// This provider is overridden with the actual instance in bootstrap.dart.
///
/// Copied from [sharedPreferences].
@ProviderFor(sharedPreferences)
final sharedPreferencesProvider = Provider<SharedPreferences>.internal(
  sharedPreferences,
  name: r'sharedPreferencesProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$sharedPreferencesHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef SharedPreferencesRef = ProviderRef<SharedPreferences>;
String _$connectivityHash() => r'15246627d0ae599bcd01382c80d3d25b9e9b4e18';

/// Provider for Connectivity plugin
///
/// Monitors network connectivity state changes.
///
/// Copied from [connectivity].
@ProviderFor(connectivity)
final connectivityProvider = Provider<Connectivity>.internal(
  connectivity,
  name: r'connectivityProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$connectivityHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ConnectivityRef = ProviderRef<Connectivity>;
String _$databaseServiceHash() => r'323927c4138725be4427216964fece6d70043b46';

/// Provider for DatabaseService
///
/// Manages the local SQLite database lifecycle and provides access to database instances.
///
/// Copied from [databaseService].
@ProviderFor(databaseService)
final databaseServiceProvider = Provider<DatabaseService>.internal(
  databaseService,
  name: r'databaseServiceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$databaseServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef DatabaseServiceRef = ProviderRef<DatabaseService>;
String _$cognitoUserPoolIdHash() => r'21772e7f1ed3dbe6a1aa124d87de8bfc4ea5217f';

/// Provider for Cognito User Pool ID
///
/// Provides the AWS Cognito user pool ID from AppConfig.
///
/// Copied from [cognitoUserPoolId].
@ProviderFor(cognitoUserPoolId)
final cognitoUserPoolIdProvider = Provider<String>.internal(
  cognitoUserPoolId,
  name: r'cognitoUserPoolIdProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$cognitoUserPoolIdHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CognitoUserPoolIdRef = ProviderRef<String>;
String _$cognitoClientIdHash() => r'fac71643cdb3479be60b3d7424d75f1304179b93';

/// Provider for Cognito Client ID
///
/// Provides the AWS Cognito client ID from AppConfig.
///
/// Copied from [cognitoClientId].
@ProviderFor(cognitoClientId)
final cognitoClientIdProvider = Provider<String>.internal(
  cognitoClientId,
  name: r'cognitoClientIdProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$cognitoClientIdHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CognitoClientIdRef = ProviderRef<String>;
String _$apiBaseUrlHash() => r'77dc5bba93004c423575357f387ca93805600f69';

/// Provider for API Base URL
///
/// Provides the base URL for API requests from AppConfig.
///
/// Copied from [apiBaseUrl].
@ProviderFor(apiBaseUrl)
final apiBaseUrlProvider = Provider<String>.internal(
  apiBaseUrl,
  name: r'apiBaseUrlProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$apiBaseUrlHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ApiBaseUrlRef = ProviderRef<String>;
String _$cognitoUserPoolHash() => r'7a7c3e87513e89af33281fbda1560bf7ea131bfd';

/// Provider for Cognito User Pool
///
/// Provides the AWS Cognito User Pool instance from AppConfig.
///
/// Copied from [cognitoUserPool].
@ProviderFor(cognitoUserPool)
final cognitoUserPoolProvider = Provider<CognitoUserPool>.internal(
  cognitoUserPool,
  name: r'cognitoUserPoolProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$cognitoUserPoolHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CognitoUserPoolRef = ProviderRef<CognitoUserPool>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
