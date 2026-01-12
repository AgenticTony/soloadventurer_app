import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter/foundation.dart';
import 'package:soloadventurer/core/security/security_manager.dart';
import 'package:soloadventurer/core/storage/secure_storage_adapter.dart';
import 'package:soloadventurer/features/auth/data/datasources/auth_local_data_source.dart';
import 'package:soloadventurer/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:soloadventurer/features/auth/data/datasources/auth_remote_data_source_impl.dart';
import 'package:soloadventurer/features/auth/data/datasources/mock_auth_remote_data_source.dart';
import 'package:soloadventurer/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:soloadventurer/features/auth/domain/repositories/auth_repository.dart';
import 'package:soloadventurer/features/auth/domain/usecases/confirm_password_reset.dart';
import 'package:soloadventurer/features/auth/domain/usecases/forgot_password.dart';
import 'package:soloadventurer/features/auth/domain/usecases/get_current_user.dart';
import 'package:soloadventurer/features/auth/domain/usecases/is_signed_in.dart';
import 'package:soloadventurer/features/auth/domain/usecases/login.dart';
import 'package:soloadventurer/features/auth/domain/usecases/resend_verification_email.dart'
    as resend;
import 'package:soloadventurer/features/auth/domain/usecases/sign_out.dart';
import 'package:soloadventurer/features/auth/domain/usecases/sign_up.dart';
import 'package:soloadventurer/features/auth/domain/usecases/verify_email.dart';
import 'package:soloadventurer/app/providers/core_service_providers.dart';
import 'package:soloadventurer/core/providers/api_providers.dart';

part 'auth_service_providers.g.dart';

// ============================================================================
// Auth Data Sources
// ============================================================================

/// Provider for AuthLocalDataSource
///
/// Handles local storage of auth data using SecureStorage and SharedPreferences.
@Riverpod(keepAlive: true)
AuthLocalDataSource authLocalDataSource(Ref ref) {
  final secureStorage = ref.watch(secureStorageProvider);
  final sharedPreferences = ref.watch(sharedPreferencesProvider);
  return AuthLocalDataSourceImpl(secureStorage, sharedPreferences);
}

/// Provider for AuthRemoteDataSource
///
/// Uses Supabase Auth for authentication.
/// In tests, this can be overridden with the mock implementation.
@Riverpod(keepAlive: true)
AuthRemoteDataSource authRemoteDataSource(Ref ref) {
  debugPrint('auth_service_providers: Initializing SupabaseAuthRemoteDataSource');
  return SupabaseAuthRemoteDataSourceImpl();
}

/// Mock provider for AuthRemoteDataSource
///
/// Used for testing. Override authRemoteDataSourceProvider with this in tests.
@Riverpod(keepAlive: true)
AuthRemoteDataSource mockAuthRemoteDataSource(Ref ref) {
  final apiClient = ref.watch(apiClientProviderFull);
  return MockAuthRemoteDataSource(apiClient);
}

// ============================================================================
// Auth Repository
// ============================================================================

/// Provider for AuthRepository
///
/// Coordinates between remote and local data sources with security management.
@Riverpod(keepAlive: true)
AuthRepository authRepository(Ref ref) {
  final remoteDataSource = ref.watch(authRemoteDataSourceProvider);
  final localDataSource = ref.watch(authLocalDataSourceProvider);
  final securityManager = ref.watch(securityManagerProvider);

  // Create SecurityManagerAdapter to bridge Riverpod's SecurityManager
  // with the GetIt-based AuthRepository
  SecurityManagerAdapter.setSecurityManager(securityManager);
  final adapter = SecurityManagerAdapter();

  return AuthRepositoryImpl(
    remoteDataSource: remoteDataSource,
    localDataSource: localDataSource,
    securityManager: adapter,
  );
}

// ============================================================================
// Auth Use Cases
// ============================================================================

/// Provider for GetCurrentUser use case
@Riverpod(keepAlive: true)
GetCurrentUser getCurrentUserUseCase(Ref ref) {
  final repository = ref.watch(authRepositoryProvider);
  return GetCurrentUser(repository);
}

/// Provider for IsSignedIn use case
@Riverpod(keepAlive: true)
IsSignedIn isSignedInUseCase(Ref ref) {
  final repository = ref.watch(authRepositoryProvider);
  return IsSignedIn(repository);
}

/// Provider for LoginUseCase
@Riverpod(keepAlive: true)
LoginUseCase loginUseCase(Ref ref) {
  final repository = ref.watch(authRepositoryProvider);
  return LoginUseCase(repository);
}

/// Provider for SignUp use case
@Riverpod(keepAlive: true)
SignUp signUpUseCase(Ref ref) {
  final repository = ref.watch(authRepositoryProvider);
  return SignUp(repository);
}

/// Provider for SignOut use case
@Riverpod(keepAlive: true)
SignOut signOutUseCase(Ref ref) {
  final repository = ref.watch(authRepositoryProvider);
  return SignOut(repository);
}

/// Provider for VerifyEmail use case
@Riverpod(keepAlive: true)
VerifyEmail verifyEmailUseCase(Ref ref) {
  final repository = ref.watch(authRepositoryProvider);
  return VerifyEmail(repository);
}

/// Provider for ResendVerificationEmail use case
@Riverpod(keepAlive: true)
resend.ResendVerificationEmail resendVerificationEmailUseCase(Ref ref) {
  final repository = ref.watch(authRepositoryProvider);
  return resend.ResendVerificationEmail(repository);
}

/// Provider for ForgotPassword use case
@Riverpod(keepAlive: true)
ForgotPassword forgotPasswordUseCase(Ref ref) {
  final repository = ref.watch(authRepositoryProvider);
  return ForgotPassword(repository);
}

/// Provider for ConfirmPasswordReset use case
@Riverpod(keepAlive: true)
ConfirmPasswordReset confirmPasswordResetUseCase(Ref ref) {
  final repository = ref.watch(authRepositoryProvider);
  return ConfirmPasswordReset(repository);
}
