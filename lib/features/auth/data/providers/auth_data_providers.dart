import 'package:amazon_cognito_identity_dart_2/cognito.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:soloadventurer/core/config/cognito_config.dart';
import 'package:soloadventurer/core/security/security_manager.dart';
import 'package:soloadventurer/core/storage/secure_storage.dart';
import 'package:soloadventurer/features/auth/data/datasources/auth_local_data_source.dart';
import 'package:soloadventurer/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:soloadventurer/features/auth/domain/services/token_manager.dart';
import 'package:soloadventurer/features/auth/domain/services/token_blacklist_manager.dart';

/// Provider for SecureStorage
final secureStorageProvider = Provider<SecureStorage>((ref) {
  return SecureStorage();
});

/// Provider for SecurityManager
final securityManagerProvider = Provider<SecurityManager>((ref) {
  final storage = ref.watch(secureStorageProvider);
  return SecurityManagerImpl(storage: storage);
});

/// Provider for SharedPreferences
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('SharedPreferences provider must be overridden');
});

/// Provider for CognitoUserPool
final cognitoUserPoolProvider = Provider<CognitoUserPool>((ref) {
  return CognitoUserPool(
    CognitoConfig.userPoolId,
    CognitoConfig.clientId,
  );
});

/// Provider for HTTP Client
final httpClientProvider = Provider<http.Client>((ref) {
  return http.Client();
});

/// Override for AuthLocalDataSource provider
final authLocalDataSourceProvider = Provider<AuthLocalDataSource>((ref) {
  final securityManager = ref.watch(securityManagerProvider);
  final sharedPreferences = ref.watch(sharedPreferencesProvider);
  return AuthLocalDataSourceImpl(securityManager, sharedPreferences);
});

/// Override for AuthRemoteDataSource provider
final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  final userPool = ref.watch(cognitoUserPoolProvider);
  final client = ref.watch(httpClientProvider);

  return AuthRemoteDataSourceImpl(
    userPool: userPool,
    clientSecret: CognitoConfig.clientSecret,
    client: client,
    baseUrl: CognitoConfig.baseUrl,
  );
});

/// Provider for TokenBlacklistManager
final tokenBlacklistManagerProvider = Provider<TokenBlacklistManager>((ref) {
  return TokenBlacklistManager();
});
