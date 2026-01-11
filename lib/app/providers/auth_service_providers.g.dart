// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_service_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provider for AuthLocalDataSource
///
/// Handles local storage of auth data using SecureStorage and SharedPreferences.

@ProviderFor(authLocalDataSource)
const authLocalDataSourceProvider = AuthLocalDataSourceProvider._();

/// Provider for AuthLocalDataSource
///
/// Handles local storage of auth data using SecureStorage and SharedPreferences.

final class AuthLocalDataSourceProvider extends $FunctionalProvider<
    AuthLocalDataSource,
    AuthLocalDataSource,
    AuthLocalDataSource> with $Provider<AuthLocalDataSource> {
  /// Provider for AuthLocalDataSource
  ///
  /// Handles local storage of auth data using SecureStorage and SharedPreferences.
  const AuthLocalDataSourceProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'authLocalDataSourceProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$authLocalDataSourceHash();

  @$internal
  @override
  $ProviderElement<AuthLocalDataSource> $createElement(
          $ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AuthLocalDataSource create(Ref ref) {
    return authLocalDataSource(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AuthLocalDataSource value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AuthLocalDataSource>(value),
    );
  }
}

String _$authLocalDataSourceHash() =>
    r'3ce364c8e6eeb048f53e2fce26963fee03455998';

/// Provider for AuthRemoteDataSource
///
/// In production, uses Supabase Auth (new, recommended) or AWS Cognito (legacy).
/// In tests, this can be overridden with the mock implementation.
///
/// The auth provider is selected based on AppConfig.useSupabaseAuth:
/// - true: Uses SupabaseAuthRemoteDataSourceImpl
/// - false: Uses AuthRemoteDataSourceImpl (AWS Cognito)

@ProviderFor(authRemoteDataSource)
const authRemoteDataSourceProvider = AuthRemoteDataSourceProvider._();

/// Provider for AuthRemoteDataSource
///
/// In production, uses Supabase Auth (new, recommended) or AWS Cognito (legacy).
/// In tests, this can be overridden with the mock implementation.
///
/// The auth provider is selected based on AppConfig.useSupabaseAuth:
/// - true: Uses SupabaseAuthRemoteDataSourceImpl
/// - false: Uses AuthRemoteDataSourceImpl (AWS Cognito)

final class AuthRemoteDataSourceProvider extends $FunctionalProvider<
    AuthRemoteDataSource,
    AuthRemoteDataSource,
    AuthRemoteDataSource> with $Provider<AuthRemoteDataSource> {
  /// Provider for AuthRemoteDataSource
  ///
  /// In production, uses Supabase Auth (new, recommended) or AWS Cognito (legacy).
  /// In tests, this can be overridden with the mock implementation.
  ///
  /// The auth provider is selected based on AppConfig.useSupabaseAuth:
  /// - true: Uses SupabaseAuthRemoteDataSourceImpl
  /// - false: Uses AuthRemoteDataSourceImpl (AWS Cognito)
  const AuthRemoteDataSourceProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'authRemoteDataSourceProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$authRemoteDataSourceHash();

  @$internal
  @override
  $ProviderElement<AuthRemoteDataSource> $createElement(
          $ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AuthRemoteDataSource create(Ref ref) {
    return authRemoteDataSource(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AuthRemoteDataSource value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AuthRemoteDataSource>(value),
    );
  }
}

String _$authRemoteDataSourceHash() =>
    r'ad511c0375da5ae6e7394768c5a275c275504fcc';

/// Mock provider for AuthRemoteDataSource
///
/// Used for testing. Override authRemoteDataSourceProvider with this in tests.

@ProviderFor(mockAuthRemoteDataSource)
const mockAuthRemoteDataSourceProvider = MockAuthRemoteDataSourceProvider._();

/// Mock provider for AuthRemoteDataSource
///
/// Used for testing. Override authRemoteDataSourceProvider with this in tests.

final class MockAuthRemoteDataSourceProvider extends $FunctionalProvider<
    AuthRemoteDataSource,
    AuthRemoteDataSource,
    AuthRemoteDataSource> with $Provider<AuthRemoteDataSource> {
  /// Mock provider for AuthRemoteDataSource
  ///
  /// Used for testing. Override authRemoteDataSourceProvider with this in tests.
  const MockAuthRemoteDataSourceProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'mockAuthRemoteDataSourceProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$mockAuthRemoteDataSourceHash();

  @$internal
  @override
  $ProviderElement<AuthRemoteDataSource> $createElement(
          $ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AuthRemoteDataSource create(Ref ref) {
    return mockAuthRemoteDataSource(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AuthRemoteDataSource value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AuthRemoteDataSource>(value),
    );
  }
}

String _$mockAuthRemoteDataSourceHash() =>
    r'07dd4369224d6176e39a0376e5799f28da9a69a2';

/// Provider for AuthRepository
///
/// Coordinates between remote and local data sources with security management.

@ProviderFor(authRepository)
const authRepositoryProvider = AuthRepositoryProvider._();

/// Provider for AuthRepository
///
/// Coordinates between remote and local data sources with security management.

final class AuthRepositoryProvider
    extends $FunctionalProvider<AuthRepository, AuthRepository, AuthRepository>
    with $Provider<AuthRepository> {
  /// Provider for AuthRepository
  ///
  /// Coordinates between remote and local data sources with security management.
  const AuthRepositoryProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'authRepositoryProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$authRepositoryHash();

  @$internal
  @override
  $ProviderElement<AuthRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AuthRepository create(Ref ref) {
    return authRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AuthRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AuthRepository>(value),
    );
  }
}

String _$authRepositoryHash() => r'6199cad95f340b31cc46ff5d534f9f9c0da89346';

/// Provider for GetCurrentUser use case

@ProviderFor(getCurrentUserUseCase)
const getCurrentUserUseCaseProvider = GetCurrentUserUseCaseProvider._();

/// Provider for GetCurrentUser use case

final class GetCurrentUserUseCaseProvider
    extends $FunctionalProvider<GetCurrentUser, GetCurrentUser, GetCurrentUser>
    with $Provider<GetCurrentUser> {
  /// Provider for GetCurrentUser use case
  const GetCurrentUserUseCaseProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'getCurrentUserUseCaseProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$getCurrentUserUseCaseHash();

  @$internal
  @override
  $ProviderElement<GetCurrentUser> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  GetCurrentUser create(Ref ref) {
    return getCurrentUserUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GetCurrentUser value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GetCurrentUser>(value),
    );
  }
}

String _$getCurrentUserUseCaseHash() =>
    r'2f4dcbf34ff8a88e1b6e88df18ad8bab9e2584b5';

/// Provider for IsSignedIn use case

@ProviderFor(isSignedInUseCase)
const isSignedInUseCaseProvider = IsSignedInUseCaseProvider._();

/// Provider for IsSignedIn use case

final class IsSignedInUseCaseProvider
    extends $FunctionalProvider<IsSignedIn, IsSignedIn, IsSignedIn>
    with $Provider<IsSignedIn> {
  /// Provider for IsSignedIn use case
  const IsSignedInUseCaseProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'isSignedInUseCaseProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$isSignedInUseCaseHash();

  @$internal
  @override
  $ProviderElement<IsSignedIn> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  IsSignedIn create(Ref ref) {
    return isSignedInUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(IsSignedIn value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<IsSignedIn>(value),
    );
  }
}

String _$isSignedInUseCaseHash() => r'402f91ef15c335033a4c951087127d68dad70c17';

/// Provider for LoginUseCase

@ProviderFor(loginUseCase)
const loginUseCaseProvider = LoginUseCaseProvider._();

/// Provider for LoginUseCase

final class LoginUseCaseProvider
    extends $FunctionalProvider<LoginUseCase, LoginUseCase, LoginUseCase>
    with $Provider<LoginUseCase> {
  /// Provider for LoginUseCase
  const LoginUseCaseProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'loginUseCaseProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$loginUseCaseHash();

  @$internal
  @override
  $ProviderElement<LoginUseCase> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  LoginUseCase create(Ref ref) {
    return loginUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(LoginUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<LoginUseCase>(value),
    );
  }
}

String _$loginUseCaseHash() => r'c1d38f2bd23500953dbb22d11f783dc5875793bf';

/// Provider for SignUp use case

@ProviderFor(signUpUseCase)
const signUpUseCaseProvider = SignUpUseCaseProvider._();

/// Provider for SignUp use case

final class SignUpUseCaseProvider
    extends $FunctionalProvider<SignUp, SignUp, SignUp> with $Provider<SignUp> {
  /// Provider for SignUp use case
  const SignUpUseCaseProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'signUpUseCaseProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$signUpUseCaseHash();

  @$internal
  @override
  $ProviderElement<SignUp> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  SignUp create(Ref ref) {
    return signUpUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SignUp value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SignUp>(value),
    );
  }
}

String _$signUpUseCaseHash() => r'9cc757dacc0e5a3ee89002cbb3f853973bad3573';

/// Provider for SignOut use case

@ProviderFor(signOutUseCase)
const signOutUseCaseProvider = SignOutUseCaseProvider._();

/// Provider for SignOut use case

final class SignOutUseCaseProvider
    extends $FunctionalProvider<SignOut, SignOut, SignOut>
    with $Provider<SignOut> {
  /// Provider for SignOut use case
  const SignOutUseCaseProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'signOutUseCaseProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$signOutUseCaseHash();

  @$internal
  @override
  $ProviderElement<SignOut> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  SignOut create(Ref ref) {
    return signOutUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SignOut value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SignOut>(value),
    );
  }
}

String _$signOutUseCaseHash() => r'6a32a9a05051b79329e66fa6ef97edb2e4789e0d';

/// Provider for VerifyEmail use case

@ProviderFor(verifyEmailUseCase)
const verifyEmailUseCaseProvider = VerifyEmailUseCaseProvider._();

/// Provider for VerifyEmail use case

final class VerifyEmailUseCaseProvider
    extends $FunctionalProvider<VerifyEmail, VerifyEmail, VerifyEmail>
    with $Provider<VerifyEmail> {
  /// Provider for VerifyEmail use case
  const VerifyEmailUseCaseProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'verifyEmailUseCaseProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$verifyEmailUseCaseHash();

  @$internal
  @override
  $ProviderElement<VerifyEmail> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  VerifyEmail create(Ref ref) {
    return verifyEmailUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(VerifyEmail value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<VerifyEmail>(value),
    );
  }
}

String _$verifyEmailUseCaseHash() =>
    r'4ab723b86689d87ed338a1c0941d2d6d138183b3';

/// Provider for ResendVerificationEmail use case

@ProviderFor(resendVerificationEmailUseCase)
const resendVerificationEmailUseCaseProvider =
    ResendVerificationEmailUseCaseProvider._();

/// Provider for ResendVerificationEmail use case

final class ResendVerificationEmailUseCaseProvider extends $FunctionalProvider<
        resend.ResendVerificationEmail,
        resend.ResendVerificationEmail,
        resend.ResendVerificationEmail>
    with $Provider<resend.ResendVerificationEmail> {
  /// Provider for ResendVerificationEmail use case
  const ResendVerificationEmailUseCaseProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'resendVerificationEmailUseCaseProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$resendVerificationEmailUseCaseHash();

  @$internal
  @override
  $ProviderElement<resend.ResendVerificationEmail> $createElement(
          $ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  resend.ResendVerificationEmail create(Ref ref) {
    return resendVerificationEmailUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(resend.ResendVerificationEmail value) {
    return $ProviderOverride(
      origin: this,
      providerOverride:
          $SyncValueProvider<resend.ResendVerificationEmail>(value),
    );
  }
}

String _$resendVerificationEmailUseCaseHash() =>
    r'c9c7522d9e31b2637a22f25fe328cce69758bb88';

/// Provider for ForgotPassword use case

@ProviderFor(forgotPasswordUseCase)
const forgotPasswordUseCaseProvider = ForgotPasswordUseCaseProvider._();

/// Provider for ForgotPassword use case

final class ForgotPasswordUseCaseProvider
    extends $FunctionalProvider<ForgotPassword, ForgotPassword, ForgotPassword>
    with $Provider<ForgotPassword> {
  /// Provider for ForgotPassword use case
  const ForgotPasswordUseCaseProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'forgotPasswordUseCaseProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$forgotPasswordUseCaseHash();

  @$internal
  @override
  $ProviderElement<ForgotPassword> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  ForgotPassword create(Ref ref) {
    return forgotPasswordUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ForgotPassword value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ForgotPassword>(value),
    );
  }
}

String _$forgotPasswordUseCaseHash() =>
    r'eda142d3d1d9bcfc0c91b05ffee687567894f659';

/// Provider for ConfirmPasswordReset use case

@ProviderFor(confirmPasswordResetUseCase)
const confirmPasswordResetUseCaseProvider =
    ConfirmPasswordResetUseCaseProvider._();

/// Provider for ConfirmPasswordReset use case

final class ConfirmPasswordResetUseCaseProvider extends $FunctionalProvider<
    ConfirmPasswordReset,
    ConfirmPasswordReset,
    ConfirmPasswordReset> with $Provider<ConfirmPasswordReset> {
  /// Provider for ConfirmPasswordReset use case
  const ConfirmPasswordResetUseCaseProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'confirmPasswordResetUseCaseProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$confirmPasswordResetUseCaseHash();

  @$internal
  @override
  $ProviderElement<ConfirmPasswordReset> $createElement(
          $ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  ConfirmPasswordReset create(Ref ref) {
    return confirmPasswordResetUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ConfirmPasswordReset value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ConfirmPasswordReset>(value),
    );
  }
}

String _$confirmPasswordResetUseCaseHash() =>
    r'ffeb7b08a28d59c5e16ea07728a967a8e75b9f10';
