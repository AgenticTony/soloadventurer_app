// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_profile_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provider for the API service

@ProviderFor(apiService)
final apiServiceProvider = ApiServiceProvider._();

/// Provider for the API service

final class ApiServiceProvider
    extends $FunctionalProvider<ApiService, ApiService, ApiService>
    with $Provider<ApiService> {
  /// Provider for the API service
  ApiServiceProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'apiServiceProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$apiServiceHash();

  @$internal
  @override
  $ProviderElement<ApiService> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  ApiService create(Ref ref) {
    return apiService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ApiService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ApiService>(value),
    );
  }
}

String _$apiServiceHash() => r'4d37feced34f30e0e517f3507d3623c9b8146175';

/// Provider for user repository

@ProviderFor(userRepository)
final userRepositoryProvider = UserRepositoryProvider._();

/// Provider for user repository

final class UserRepositoryProvider
    extends $FunctionalProvider<UserRepository, UserRepository, UserRepository>
    with $Provider<UserRepository> {
  /// Provider for user repository
  UserRepositoryProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'userRepositoryProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$userRepositoryHash();

  @$internal
  @override
  $ProviderElement<UserRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  UserRepository create(Ref ref) {
    return userRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(UserRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<UserRepository>(value),
    );
  }
}

String _$userRepositoryHash() => r'0541c53cce52e1ffee13197770e4009c4aa45627';

/// Provider for fetching user profile (using @riverpod syntax)

@ProviderFor(fetchUserProfile)
final fetchUserProfileProvider = FetchUserProfileFamily._();

/// Provider for fetching user profile (using @riverpod syntax)

final class FetchUserProfileProvider
    extends $FunctionalProvider<AsyncValue<User>, User, FutureOr<User>>
    with $FutureModifier<User>, $FutureProvider<User> {
  /// Provider for fetching user profile (using @riverpod syntax)
  FetchUserProfileProvider._(
      {required FetchUserProfileFamily super.from,
      required String super.argument})
      : super(
          retry: null,
          name: r'fetchUserProfileProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$fetchUserProfileHash();

  @override
  String toString() {
    return r'fetchUserProfileProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<User> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<User> create(Ref ref) {
    final argument = this.argument as String;
    return fetchUserProfile(
      ref,
      argument,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is FetchUserProfileProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$fetchUserProfileHash() => r'a3f2c527059b3324b64e20c9124104e0de0670ba';

/// Provider for fetching user profile (using @riverpod syntax)

final class FetchUserProfileFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<User>, String> {
  FetchUserProfileFamily._()
      : super(
          retry: null,
          name: r'fetchUserProfileProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: true,
        );

  /// Provider for fetching user profile (using @riverpod syntax)

  FetchUserProfileProvider call(
    String userId,
  ) =>
      FetchUserProfileProvider._(argument: userId, from: this);

  @override
  String toString() => r'fetchUserProfileProvider';
}

/// Provider for current user profile (using @riverpod syntax)

@ProviderFor(currentUserProfile)
final currentUserProfileProvider = CurrentUserProfileProvider._();

/// Provider for current user profile (using @riverpod syntax)

final class CurrentUserProfileProvider
    extends $FunctionalProvider<AsyncValue<User?>, User?, FutureOr<User?>>
    with $FutureModifier<User?>, $FutureProvider<User?> {
  /// Provider for current user profile (using @riverpod syntax)
  CurrentUserProfileProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'currentUserProfileProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$currentUserProfileHash();

  @$internal
  @override
  $FutureProviderElement<User?> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<User?> create(Ref ref) {
    return currentUserProfile(ref);
  }
}

String _$currentUserProfileHash() =>
    r'84d4c7312ef4e73b7a031872f69ec88698d8ee83';

/// Auth state provider (simplified for this example)

@ProviderFor(authState)
final authStateProvider = AuthStateProvider._();

/// Auth state provider (simplified for this example)

final class AuthStateProvider
    extends $FunctionalProvider<AuthState, AuthState, AuthState>
    with $Provider<AuthState> {
  /// Auth state provider (simplified for this example)
  AuthStateProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'authStateProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$authStateHash();

  @$internal
  @override
  $ProviderElement<AuthState> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AuthState create(Ref ref) {
    return authState(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AuthState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AuthState>(value),
    );
  }
}

String _$authStateHash() => r'ee3797ba876ac4c87271015e20390e1cc9bd1a0a';

/// Notifier for updating user profile (migrated to @riverpod)

@ProviderFor(UserProfileNotifier)
final userProfileProvider = UserProfileNotifierFamily._();

/// Notifier for updating user profile (migrated to @riverpod)
final class UserProfileNotifierProvider
    extends $NotifierProvider<UserProfileNotifier, AsyncValue<User?>> {
  /// Notifier for updating user profile (migrated to @riverpod)
  UserProfileNotifierProvider._(
      {required UserProfileNotifierFamily super.from,
      required String super.argument})
      : super(
          retry: null,
          name: r'userProfileProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$userProfileNotifierHash();

  @override
  String toString() {
    return r'userProfileProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  UserProfileNotifier create() => UserProfileNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<User?> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<User?>>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is UserProfileNotifierProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$userProfileNotifierHash() =>
    r'159128dc657b4bdcc445dc11b075a8bc98bd797f';

/// Notifier for updating user profile (migrated to @riverpod)

final class UserProfileNotifierFamily extends $Family
    with
        $ClassFamilyOverride<UserProfileNotifier, AsyncValue<User?>,
            AsyncValue<User?>, AsyncValue<User?>, String> {
  UserProfileNotifierFamily._()
      : super(
          retry: null,
          name: r'userProfileProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: true,
        );

  /// Notifier for updating user profile (migrated to @riverpod)

  UserProfileNotifierProvider call(
    String userId,
  ) =>
      UserProfileNotifierProvider._(argument: userId, from: this);

  @override
  String toString() => r'userProfileProvider';
}

/// Notifier for updating user profile (migrated to @riverpod)

abstract class _$UserProfileNotifier extends $Notifier<AsyncValue<User?>> {
  late final _$args = ref.$arg as String;
  String get userId => _$args;

  AsyncValue<User?> build(
    String userId,
  );
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<User?>, AsyncValue<User?>>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<AsyncValue<User?>, AsyncValue<User?>>,
        AsyncValue<User?>,
        Object?,
        Object?>;
    element.handleCreate(
        ref,
        () => build(
              _$args,
            ));
  }
}
