import 'package:get_it/get_it.dart';
import 'package:soloadventurer/core/api/client/api_client.dart';
import 'package:soloadventurer/core/storage/secure_storage.dart';
import 'package:soloadventurer/core/storage/secure_storage_adapter.dart';
import 'package:soloadventurer/features/auth/data/datasources/auth_local_data_source.dart';
import 'package:soloadventurer/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:soloadventurer/features/auth/data/datasources/auth_remote_data_source_impl.dart';
import 'package:soloadventurer/features/auth/data/datasources/mock_auth_remote_data_source.dart';
import 'package:soloadventurer/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:soloadventurer/features/auth/domain/repositories/auth_repository.dart';
import 'package:soloadventurer/features/auth/domain/usecases/get_current_user.dart';
import 'package:soloadventurer/features/auth/domain/usecases/is_signed_in.dart';
import 'package:soloadventurer/features/auth/domain/usecases/login.dart';
import 'package:soloadventurer/features/auth/domain/usecases/sign_out.dart';
import 'package:soloadventurer/features/auth/domain/usecases/sign_up.dart';
import 'package:soloadventurer/features/auth/domain/usecases/verify_email.dart';
import 'package:soloadventurer/features/auth/domain/usecases/resend_verification_email.dart';
import 'package:soloadventurer/features/auth/domain/usecases/forgot_password.dart';
import 'package:soloadventurer/features/auth/domain/usecases/confirm_password_reset.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:soloadventurer/features/auth/infrastructure/services/token_expiration_tracker.dart';
import 'package:soloadventurer/features/auth/infrastructure/services/token_refresh_scheduler.dart';
import 'package:soloadventurer/features/auth/infrastructure/services/token_refresh_service.dart';
import 'package:soloadventurer/features/auth/infrastructure/services/refresh_queue_manager.dart';
import 'package:soloadventurer/features/auth/infrastructure/services/persistent_session_manager.dart';
import 'package:flutter/foundation.dart';

/// Register all auth feature dependencies
void registerAuthModule(GetIt getIt, {bool isTest = false}) {
  // Debug logging
  debugPrint('========================================');
  debugPrint('AuthModule: Registering auth dependencies');
  debugPrint('AuthModule: Using Supabase Auth');
  debugPrint('AuthModule: isTest = $isTest');
  debugPrint('========================================');

  // Register data sources
  getIt.registerLazySingleton<AuthLocalDataSource>(
    () => AuthLocalDataSourceImpl(
      getIt<SecureStorage>(),
      getIt<SharedPreferences>(),
    ),
  );

  getIt.registerLazySingleton<AuthRemoteDataSource>(
    () => isTest
        ? MockAuthRemoteDataSource(getIt<ApiClient>())
        : SupabaseAuthRemoteDataSourceImpl(),
  );

  debugPrint('AuthModule: Registered ${getIt<AuthRemoteDataSource>().runtimeType}');

  // Register repository
  // Note: RefreshQueueManager is not injected here to break circular dependency.
  // The repository will use GetIt to access it when needed via lazy resolution.
  // SecurityManagerAdapter provides all SecurityManager methods, so we cast it to dynamic
  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      remoteDataSource: getIt<AuthRemoteDataSource>(),
      localDataSource: getIt<AuthLocalDataSource>(),
      securityManager: getIt<SecurityManagerAdapter>() as dynamic,
      refreshQueueManager: null, // Will be accessed via GetIt when needed
    ),
  );

  // Register token refresh infrastructure services
  // Note: These are registered in a specific order to break circular dependencies:
  // 1. AuthRepository (without RefreshQueueManager)
  // 2. TokenRefreshService (depends on AuthRepository)
  // 3. RefreshQueueManager (depends on TokenRefreshService)
  // 4. TokenExpirationTracker (depends on TokenRefreshService)
  // 5. TokenRefreshScheduler (depends on TokenExpirationTracker)

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

  getIt.registerLazySingleton<TokenExpirationTracker>(
    () => TokenExpirationTracker(
      refreshService: getIt<TokenRefreshService>(),
    ),
  );

  getIt.registerLazySingleton<TokenRefreshScheduler>(
    () => TokenRefreshScheduler(
      expirationTracker: getIt<TokenExpirationTracker>(),
    ),
  );

  getIt.registerLazySingleton<PersistentSessionManager>(
    () => PersistentSessionManager(
      localDataSource: getIt<AuthLocalDataSource>(),
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
