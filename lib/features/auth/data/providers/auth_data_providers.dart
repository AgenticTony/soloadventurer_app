import 'package:amazon_cognito_identity_dart_2/cognito.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soloadventurer/core/config/cognito_config.dart';
import 'package:soloadventurer/core/security/security_manager.dart';
import 'package:soloadventurer/core/storage/secure_storage.dart';
import 'package:soloadventurer/features/auth/data/datasources/auth_local_data_source.dart';
import 'package:soloadventurer/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:soloadventurer/features/auth/domain/services/token_manager.dart';

/// Provider for SecureStorage
final secureStorageProvider = Provider<SecureStorage>((ref) {
  return SecureStorage();
});

/// Provider for SecurityManager
final securityManagerProvider = Provider<SecurityManager>((ref) {
  final storage = ref.watch(secureStorageProvider);
  return SecurityManagerImpl(storage: storage);
});

/// Provider for CognitoUserPool
final cognitoUserPoolProvider = Provider<CognitoUserPool>((ref) {
  return CognitoUserPool(
    CognitoConfig.userPoolId,
    CognitoConfig.clientId,
  );
});

/// Override for AuthLocalDataSource provider
final authLocalDataSourceProvider = Provider<AuthLocalDataSource>((ref) {
  final securityManager = ref.watch(securityManagerProvider);
  return AuthLocalDataSourceImpl(securityManager);
});

/// Override for AuthRemoteDataSource provider
final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  final userPool = ref.watch(cognitoUserPoolProvider);
  return AuthRemoteDataSourceImpl(userPool: userPool);
});
