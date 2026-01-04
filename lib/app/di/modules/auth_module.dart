import 'package:get_it/get_it.dart';
import 'package:soloadventurer/core/api/client/api_client.dart';
import 'package:soloadventurer/core/security/security_manager.dart';
import 'package:soloadventurer/features/auth/data/datasources/auth_local_data_source.dart';
import 'package:soloadventurer/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:soloadventurer/features/auth/data/datasources/mock_auth_remote_data_source.dart';
import 'package:soloadventurer/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:soloadventurer/features/auth/domain/repositories/auth_repository.dart';
import 'package:soloadventurer/features/auth/domain/usecases/get_current_user.dart';
import 'package:soloadventurer/features/auth/domain/usecases/is_signed_in.dart';
import 'package:soloadventurer/features/auth/domain/usecases/login.dart';
import 'package:soloadventurer/features/auth/domain/usecases/sign_out.dart';
import 'package:soloadventurer/features/auth/domain/usecases/sign_up.dart';
import 'package:soloadventurer/features/auth/domain/usecases/verify_email.dart';
import 'package:soloadventurer/features/auth/domain/usecases/forgot_password.dart';
import 'package:soloadventurer/features/auth/domain/usecases/confirm_password_reset.dart';
import 'package:soloadventurer/features/core/config/app_config.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:soloadventurer/features/auth/infrastructure/services/token_expiration_tracker.dart';
import 'package:soloadventurer/features/auth/infrastructure/services/token_refresh_scheduler.dart';
import 'package:soloadventurer/features/auth/infrastructure/services/token_refresh_service.dart';
import 'package:soloadventurer/features/auth/infrastructure/services/refresh_queue_manager.dart';

/// Register all auth feature dependencies
void registerAuthModule(GetIt getIt, {bool isTest = false}) {
  // Register data sources
  getIt.registerLazySingleton<AuthLocalDataSource>(
    () => AuthLocalDataSourceImpl(
      getIt<SecurityManager>(),
      getIt<SharedPreferences>(),
    ),
  );

  getIt.registerLazySingleton<AuthRemoteDataSource>(
    () => isTest
        ? MockAuthRemoteDataSource(getIt<ApiClient>())
        : AuthRemoteDataSourceImpl(
            userPool: AppConfig.awsConfig.userPool,
            clientSecret: AppConfig.awsConfig.clientId, // Using clientId as fallback
            client: getIt<http.Client>(),
            baseUrl: AppConfig.apiBaseUrl,
          ),
  );

  // Register repository
  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      remoteDataSource: getIt<AuthRemoteDataSource>(),
      localDataSource: getIt<AuthLocalDataSource>(),
      securityManager: getIt<SecurityManager>(),
      refreshQueueManager: getIt<RefreshQueueManager>(),
    ),
  );

  // Register token refresh infrastructure services
  getIt.registerLazySingleton<TokenExpirationTracker>(
    () => TokenExpirationTracker(
      refreshService: getIt<TokenRefreshService>(),
    ),
  );

  getIt.registerLazySingleton<TokenRefreshService>(
    () => TokenRefreshService(
      authRepository: getIt<AuthRepository>(),
    ),
  );

  getIt.registerLazySingleton<RefreshQueueManager>(
    () => RefreshQueueManager(
      refreshService: getIt<TokenRefreshService>(),
    ),
  );

  getIt.registerLazySingleton<TokenRefreshScheduler>(
    () => TokenRefreshScheduler(
      expirationTracker: getIt<TokenExpirationTracker>(),
    ),
  );

  // Register use cases
  getIt.registerLazySingleton(() => GetCurrentUser(getIt()));
  getIt.registerLazySingleton(() => IsSignedIn(getIt()));
  getIt.registerLazySingleton(() => LoginUseCase(getIt()));
  getIt.registerLazySingleton(() => SignUp(getIt()));
  getIt.registerLazySingleton(() => SignOut(getIt()));
  getIt.registerLazySingleton(() => VerifyEmail(getIt()));
  getIt.registerLazySingleton(() => ResendVerificationEmail(getIt()));
  getIt.registerLazySingleton(() => ForgotPassword(getIt()));
  getIt.registerLazySingleton(() => ConfirmPasswordReset(getIt()));
}
