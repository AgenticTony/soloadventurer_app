import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:soloadventurer/core/api/client/api_client.dart';
import 'package:soloadventurer/core/storage/secure_storage.dart';
import 'package:soloadventurer/core/security/security_manager.dart';
import 'package:soloadventurer/core/api/interceptors/auth_interceptor.dart';
import 'package:soloadventurer/core/api/interceptors/error_interceptor.dart';
import 'package:soloadventurer/core/monitoring/performance/network_monitor.dart';
import 'package:soloadventurer/features/auth/data/datasources/auth_local_data_source.dart';
import 'package:soloadventurer/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:soloadventurer/features/auth/data/datasources/mock_auth_remote_data_source.dart';
import 'package:soloadventurer/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:soloadventurer/features/auth/domain/repositories/auth_repository.dart';
import 'package:soloadventurer/features/auth/domain/usecases/get_current_user_use_case.dart';
import 'package:soloadventurer/features/auth/domain/usecases/login_use_case.dart';
import 'package:soloadventurer/features/auth/domain/usecases/logout_use_case.dart';
import 'package:soloadventurer/features/auth/domain/usecases/register_use_case.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
    // Initialize mock implementations
    final authInterceptor = AuthInterceptor();
    final errorInterceptor = ErrorInterceptor();
    final networkMonitor = NetworkMonitor();

    apiClient = ApiClient(
      baseUrl: TestConfig.apiBaseUrl,
      authInterceptor: authInterceptor,
      errorInterceptor: errorInterceptor,
      networkMonitor: networkMonitor,
    );

    secureStorage = SecureStorage();
    securityManager = SecurityManager();

    // Initialize SharedPreferences for testing
    SharedPreferences.setMockInitialValues({});
    final sharedPreferences = await SharedPreferences.getInstance();

    // Clear any existing auth data
    await secureStorage.delete(TestConfig.authTokenKey);
    await secureStorage.delete(TestConfig.refreshTokenKey);
    await secureStorage.delete(TestConfig.userDataKey);

    // Set up data sources
    authLocalDataSource =
        AuthLocalDataSourceImpl(securityManager, sharedPreferences);
    authRemoteDataSource = MockAuthRemoteDataSource(apiClient);

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
