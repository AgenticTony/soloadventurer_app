// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_service_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$authLocalDataSourceHash() =>
    r'3ce364c8e6eeb048f53e2fce26963fee03455998';

/// Provider for AuthLocalDataSource
///
/// Handles local storage of auth data using SecureStorage and SharedPreferences.
///
/// Copied from [authLocalDataSource].
@ProviderFor(authLocalDataSource)
final authLocalDataSourceProvider = Provider<AuthLocalDataSource>.internal(
  authLocalDataSource,
  name: r'authLocalDataSourceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$authLocalDataSourceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AuthLocalDataSourceRef = ProviderRef<AuthLocalDataSource>;
String _$authRemoteDataSourceHash() =>
    r'7a5133a8ee90af602656a66ab6bc9e8db07ba463';

/// Provider for AuthRemoteDataSource
///
/// In production, uses the real AWS Cognito implementation.
/// In tests, this can be overridden with the mock implementation.
///
/// Copied from [authRemoteDataSource].
@ProviderFor(authRemoteDataSource)
final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>.internal(
  authRemoteDataSource,
  name: r'authRemoteDataSourceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$authRemoteDataSourceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AuthRemoteDataSourceRef = ProviderRef<AuthRemoteDataSource>;
String _$mockAuthRemoteDataSourceHash() =>
    r'07dd4369224d6176e39a0376e5799f28da9a69a2';

/// Mock provider for AuthRemoteDataSource
///
/// Used for testing. Override authRemoteDataSourceProvider with this in tests.
///
/// Copied from [mockAuthRemoteDataSource].
@ProviderFor(mockAuthRemoteDataSource)
final mockAuthRemoteDataSourceProvider =
    Provider<AuthRemoteDataSource>.internal(
  mockAuthRemoteDataSource,
  name: r'mockAuthRemoteDataSourceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$mockAuthRemoteDataSourceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef MockAuthRemoteDataSourceRef = ProviderRef<AuthRemoteDataSource>;
String _$authRepositoryHash() => r'6199cad95f340b31cc46ff5d534f9f9c0da89346';

/// Provider for AuthRepository
///
/// Coordinates between remote and local data sources with security management.
///
/// Copied from [authRepository].
@ProviderFor(authRepository)
final authRepositoryProvider = Provider<AuthRepository>.internal(
  authRepository,
  name: r'authRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$authRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AuthRepositoryRef = ProviderRef<AuthRepository>;
String _$getCurrentUserUseCaseHash() =>
    r'2f4dcbf34ff8a88e1b6e88df18ad8bab9e2584b5';

/// Provider for GetCurrentUser use case
///
/// Copied from [getCurrentUserUseCase].
@ProviderFor(getCurrentUserUseCase)
final getCurrentUserUseCaseProvider = Provider<GetCurrentUser>.internal(
  getCurrentUserUseCase,
  name: r'getCurrentUserUseCaseProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$getCurrentUserUseCaseHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef GetCurrentUserUseCaseRef = ProviderRef<GetCurrentUser>;
String _$isSignedInUseCaseHash() => r'402f91ef15c335033a4c951087127d68dad70c17';

/// Provider for IsSignedIn use case
///
/// Copied from [isSignedInUseCase].
@ProviderFor(isSignedInUseCase)
final isSignedInUseCaseProvider = Provider<IsSignedIn>.internal(
  isSignedInUseCase,
  name: r'isSignedInUseCaseProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$isSignedInUseCaseHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef IsSignedInUseCaseRef = ProviderRef<IsSignedIn>;
String _$loginUseCaseHash() => r'c1d38f2bd23500953dbb22d11f783dc5875793bf';

/// Provider for LoginUseCase
///
/// Copied from [loginUseCase].
@ProviderFor(loginUseCase)
final loginUseCaseProvider = Provider<LoginUseCase>.internal(
  loginUseCase,
  name: r'loginUseCaseProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$loginUseCaseHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef LoginUseCaseRef = ProviderRef<LoginUseCase>;
String _$signUpUseCaseHash() => r'9cc757dacc0e5a3ee89002cbb3f853973bad3573';

/// Provider for SignUp use case
///
/// Copied from [signUpUseCase].
@ProviderFor(signUpUseCase)
final signUpUseCaseProvider = Provider<SignUp>.internal(
  signUpUseCase,
  name: r'signUpUseCaseProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$signUpUseCaseHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef SignUpUseCaseRef = ProviderRef<SignUp>;
String _$signOutUseCaseHash() => r'6a32a9a05051b79329e66fa6ef97edb2e4789e0d';

/// Provider for SignOut use case
///
/// Copied from [signOutUseCase].
@ProviderFor(signOutUseCase)
final signOutUseCaseProvider = Provider<SignOut>.internal(
  signOutUseCase,
  name: r'signOutUseCaseProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$signOutUseCaseHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef SignOutUseCaseRef = ProviderRef<SignOut>;
String _$verifyEmailUseCaseHash() =>
    r'4ab723b86689d87ed338a1c0941d2d6d138183b3';

/// Provider for VerifyEmail use case
///
/// Copied from [verifyEmailUseCase].
@ProviderFor(verifyEmailUseCase)
final verifyEmailUseCaseProvider = Provider<VerifyEmail>.internal(
  verifyEmailUseCase,
  name: r'verifyEmailUseCaseProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$verifyEmailUseCaseHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef VerifyEmailUseCaseRef = ProviderRef<VerifyEmail>;
String _$resendVerificationEmailUseCaseHash() =>
    r'c9c7522d9e31b2637a22f25fe328cce69758bb88';

/// Provider for ResendVerificationEmail use case
///
/// Copied from [resendVerificationEmailUseCase].
@ProviderFor(resendVerificationEmailUseCase)
final resendVerificationEmailUseCaseProvider =
    Provider<resend.ResendVerificationEmail>.internal(
  resendVerificationEmailUseCase,
  name: r'resendVerificationEmailUseCaseProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$resendVerificationEmailUseCaseHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ResendVerificationEmailUseCaseRef
    = ProviderRef<resend.ResendVerificationEmail>;
String _$forgotPasswordUseCaseHash() =>
    r'eda142d3d1d9bcfc0c91b05ffee687567894f659';

/// Provider for ForgotPassword use case
///
/// Copied from [forgotPasswordUseCase].
@ProviderFor(forgotPasswordUseCase)
final forgotPasswordUseCaseProvider = Provider<ForgotPassword>.internal(
  forgotPasswordUseCase,
  name: r'forgotPasswordUseCaseProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$forgotPasswordUseCaseHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ForgotPasswordUseCaseRef = ProviderRef<ForgotPassword>;
String _$confirmPasswordResetUseCaseHash() =>
    r'ffeb7b08a28d59c5e16ea07728a967a8e75b9f10';

/// Provider for ConfirmPasswordReset use case
///
/// Copied from [confirmPasswordResetUseCase].
@ProviderFor(confirmPasswordResetUseCase)
final confirmPasswordResetUseCaseProvider =
    Provider<ConfirmPasswordReset>.internal(
  confirmPasswordResetUseCase,
  name: r'confirmPasswordResetUseCaseProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$confirmPasswordResetUseCaseHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ConfirmPasswordResetUseCaseRef = ProviderRef<ConfirmPasswordReset>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
