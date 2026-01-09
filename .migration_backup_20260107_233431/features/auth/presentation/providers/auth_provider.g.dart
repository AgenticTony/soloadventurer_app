// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provider for the auth repository (kept for DI compatibility)

@ProviderFor(authRepository)
final authRepositoryProvider = AuthRepositoryProvider._();

/// Provider for the auth repository (kept for DI compatibility)

final class AuthRepositoryProvider
    extends $FunctionalProvider<AuthRepository, AuthRepository, AuthRepository>
    with $Provider<AuthRepository> {
  /// Provider for the auth repository (kept for DI compatibility)
  AuthRepositoryProvider._()
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

String _$authRepositoryHash() => r'a369938742c2ee6c8b0acae78bc799e15e6870f6';

/// Provider for the logging service (kept for DI compatibility)

@ProviderFor(loggingService)
final loggingServiceProvider = LoggingServiceProvider._();

/// Provider for the logging service (kept for DI compatibility)

final class LoggingServiceProvider
    extends $FunctionalProvider<LoggingService, LoggingService, LoggingService>
    with $Provider<LoggingService> {
  /// Provider for the logging service (kept for DI compatibility)
  LoggingServiceProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'loggingServiceProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$loggingServiceHash();

  @$internal
  @override
  $ProviderElement<LoggingService> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  LoggingService create(Ref ref) {
    return loggingService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(LoggingService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<LoggingService>(value),
    );
  }
}

String _$loggingServiceHash() => r'e883efc015d2d552d599996ecfc6cf0c720f775e';

/// Auth notifier that manages the authentication state

@ProviderFor(AuthNotifier)
final authProvider = AuthNotifierProvider._();

/// Auth notifier that manages the authentication state
final class AuthNotifierProvider
    extends $NotifierProvider<AuthNotifier, AsyncValue<AuthState>> {
  /// Auth notifier that manages the authentication state
  AuthNotifierProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'authProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$authNotifierHash();

  @$internal
  @override
  AuthNotifier create() => AuthNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<AuthState> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<AuthState>>(value),
    );
  }
}

String _$authNotifierHash() => r'5fabcdb0b82304406a2c7f6cd419659c92a68ebc';

/// Auth notifier that manages the authentication state

abstract class _$AuthNotifier extends $Notifier<AsyncValue<AuthState>> {
  AsyncValue<AuthState> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<AuthState>, AsyncValue<AuthState>>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<AsyncValue<AuthState>, AsyncValue<AuthState>>,
        AsyncValue<AuthState>,
        Object?,
        Object?>;
    element.handleCreate(ref, build);
  }
}
