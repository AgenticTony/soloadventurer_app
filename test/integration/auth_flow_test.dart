import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:soloadventurer/app/app.dart';
import 'package:soloadventurer/core/network/api_client.dart';
import 'package:soloadventurer/core/storage/secure_storage.dart';
import 'package:soloadventurer/core/security/security_manager.dart';
import 'package:soloadventurer/features/auth/data/datasources/auth_local_data_source.dart';
import 'package:soloadventurer/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:soloadventurer/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:soloadventurer/features/auth/domain/repositories/auth_repository.dart';
import 'package:soloadventurer/features/auth/domain/usecases/get_current_user_use_case.dart';
import 'package:soloadventurer/features/auth/domain/usecases/login_use_case.dart';
import 'package:soloadventurer/features/auth/domain/usecases/logout_use_case.dart';
import 'package:soloadventurer/features/auth/domain/usecases/register_use_case.dart';

import '../test_config.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late ApiClient apiClient;
  late SecureStorage secureStorage;
  late SecurityManager securityManager;
  late AuthLocalDataSource authLocalDataSource;
  late AuthRemoteDataSource authRemoteDataSource;
  late AuthRepository authRepository;
  late LoginUseCase loginUseCase;
  late RegisterUseCase registerUseCase;
  late LogoutUseCase logoutUseCase;
  late GetCurrentUserUseCase getCurrentUserUseCase;

  setUp(() async {
    // Initialize real implementations
    apiClient = ApiClient(baseUrl: TestConfig.apiBaseUrl);
    secureStorage = SecureStorage();
    securityManager = SecurityManagerImpl(storage: secureStorage);

    // Clear any existing auth data
    await secureStorage.delete(TestConfig.authTokenKey);
    await secureStorage.delete(TestConfig.refreshTokenKey);
    await secureStorage.delete(TestConfig.userDataKey);

    // Set up data sources
    authLocalDataSource =
        AuthLocalDataSourceImpl(securityManager, secureStorage);
    authRemoteDataSource = AuthRemoteDataSourceImpl(apiClient: apiClient);

    // Set up repository
    authRepository = AuthRepositoryImpl(
      remoteDataSource: authRemoteDataSource,
      localDataSource: authLocalDataSource,
      securityManager: securityManager,
    );

    // Set up use cases
    loginUseCase = LoginUseCase(authRepository);
    registerUseCase = RegisterUseCase(authRepository);
    logoutUseCase = LogoutUseCase(authRepository);
    getCurrentUserUseCase = GetCurrentUserUseCase(authRepository);
  });

  // ... rest of the test file ...
}
