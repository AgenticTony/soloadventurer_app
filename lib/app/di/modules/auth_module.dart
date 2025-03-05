import 'package:flutter_secure_storage/flutter_secure_storage.dart';
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
import 'package:soloadventurer/core/config/cognito_config.dart';

/// Register all auth feature dependencies
void registerAuthModule(GetIt getIt, {bool isTest = false}) {
  // Register data sources
  getIt.registerLazySingleton<AuthLocalDataSource>(
    () => AuthLocalDataSourceImpl(
      getIt<SecurityManager>(),
    ),
  );

  getIt.registerLazySingleton<AuthRemoteDataSource>(
    () => isTest
        ? MockAuthRemoteDataSource(getIt<ApiClient>())
        : AuthRemoteDataSourceImpl(
            userPool: CognitoConfig.userPool,
          ),
  );

  // Register repository
  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      remoteDataSource: getIt<AuthRemoteDataSource>(),
      localDataSource: getIt<AuthLocalDataSource>(),
      securityManager: getIt<SecurityManager>(),
    ),
  );

  // Register use cases
  getIt.registerFactory(() => GetCurrentUser(getIt<AuthRepository>()));
  getIt.registerFactory(() => IsSignedIn(getIt<AuthRepository>()));
  getIt.registerFactory(() => LoginUseCase(getIt<AuthRepository>()));
  getIt.registerFactory(() => SignUp(getIt<AuthRepository>()));
  getIt.registerFactory(() => SignOut(getIt<AuthRepository>()));
  getIt.registerFactory(() => VerifyEmail(getIt<AuthRepository>()));
  getIt.registerFactory(() => ResendVerificationEmail(getIt<AuthRepository>()));
}
