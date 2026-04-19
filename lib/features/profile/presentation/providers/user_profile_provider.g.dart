// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_profile_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Riverpod 3.0 Migration Notes:
/// - Converted from `StateNotifier<AsyncValue<User?>>` to `AsyncNotifier<User?>`
/// - Dependencies injected via ref.watch() in build() method
/// - Family provider with userId parameter in build()
/// - AutoDispose enabled via @Riverpod annotation
/// - build() returns `Future<User?>` not AsyncValue
/// - State is automatically `AsyncValue<User?>` when consumed
/// Provider for the API service

@ProviderFor(apiService)
const apiServiceProvider = ApiServiceProvider._();

/// Riverpod 3.0 Migration Notes:
/// - Converted from `StateNotifier<AsyncValue<User?>>` to `AsyncNotifier<User?>`
/// - Dependencies injected via ref.watch() in build() method
/// - Family provider with userId parameter in build()
/// - AutoDispose enabled via @Riverpod annotation
/// - build() returns `Future<User?>` not AsyncValue
/// - State is automatically `AsyncValue<User?>` when consumed
/// Provider for the API service

final class ApiServiceProvider
    extends $FunctionalProvider<ApiService, ApiService, ApiService>
    with $Provider<ApiService> {
  /// Riverpod 3.0 Migration Notes:
  /// - Converted from `StateNotifier<AsyncValue<User?>>` to `AsyncNotifier<User?>`
  /// - Dependencies injected via ref.watch() in build() method
  /// - Family provider with userId parameter in build()
  /// - AutoDispose enabled via @Riverpod annotation
  /// - build() returns `Future<User?>` not AsyncValue
  /// - State is automatically `AsyncValue<User?>` when consumed
  /// Provider for the API service
  const ApiServiceProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'apiServiceProvider',
          isAutoDispose: true,
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

String _$apiServiceHash() => r'9097e8469243290aea60ba3d86bfe8333c22d995';

/// Provider for user repository

@ProviderFor(userRepository)
const userRepositoryProvider = UserRepositoryProvider._();

/// Provider for user repository

final class UserRepositoryProvider
    extends $FunctionalProvider<UserRepository, UserRepository, UserRepository>
    with $Provider<UserRepository> {
  /// Provider for user repository
  const UserRepositoryProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'userRepositoryProvider',
          isAutoDispose: true,
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

String _$userRepositoryHash() => r'728063be6de078c53370398d20f4215f6b3575b6';

/// Notifier for updating user profile
///
/// Riverpod 3.0: Uses @riverpod annotation with AsyncNotifier pattern.
/// Family provider with userId parameter.
/// Auto-dispose behavior enabled.

@ProviderFor(UserProfile)
const userProfileProvider = UserProfileFamily._();

/// Notifier for updating user profile
///
/// Riverpod 3.0: Uses @riverpod annotation with AsyncNotifier pattern.
/// Family provider with userId parameter.
/// Auto-dispose behavior enabled.
final class UserProfileProvider
    extends $AsyncNotifierProvider<UserProfile, User?> {
  /// Notifier for updating user profile
  ///
  /// Riverpod 3.0: Uses @riverpod annotation with AsyncNotifier pattern.
  /// Family provider with userId parameter.
  /// Auto-dispose behavior enabled.
  const UserProfileProvider._(
      {required UserProfileFamily super.from, required String super.argument})
      : super(
          retry: null,
          name: r'userProfileProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$userProfileHash();

  @override
  String toString() {
    return r'userProfileProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  UserProfile create() => UserProfile();

  @override
  bool operator ==(Object other) {
    return other is UserProfileProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$userProfileHash() => r'cd2a639d6fb079da577356ebd6ceab753a411301';

/// Notifier for updating user profile
///
/// Riverpod 3.0: Uses @riverpod annotation with AsyncNotifier pattern.
/// Family provider with userId parameter.
/// Auto-dispose behavior enabled.

final class UserProfileFamily extends $Family
    with
        $ClassFamilyOverride<UserProfile, AsyncValue<User?>, User?,
            FutureOr<User?>, String> {
  const UserProfileFamily._()
      : super(
          retry: null,
          name: r'userProfileProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: true,
        );

  /// Notifier for updating user profile
  ///
  /// Riverpod 3.0: Uses @riverpod annotation with AsyncNotifier pattern.
  /// Family provider with userId parameter.
  /// Auto-dispose behavior enabled.

  UserProfileProvider call(
    String userId,
  ) =>
      UserProfileProvider._(argument: userId, from: this);

  @override
  String toString() => r'userProfileProvider';
}

/// Notifier for updating user profile
///
/// Riverpod 3.0: Uses @riverpod annotation with AsyncNotifier pattern.
/// Family provider with userId parameter.
/// Auto-dispose behavior enabled.

abstract class _$UserProfile extends $AsyncNotifier<User?> {
  late final _$args = ref.$arg as String;
  String get userId => _$args;

  FutureOr<User?> build(
    String userId,
  );
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build(
      _$args,
    );
    final ref = this.ref as $Ref<AsyncValue<User?>, User?>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<AsyncValue<User?>, User?>,
        AsyncValue<User?>,
        Object?,
        Object?>;
    element.handleValue(ref, created);
  }
}

/// Selector provider for user profile loading state

@ProviderFor(userProfileLoading)
const userProfileLoadingProvider = UserProfileLoadingFamily._();

/// Selector provider for user profile loading state

final class UserProfileLoadingProvider
    extends $FunctionalProvider<bool, bool, bool> with $Provider<bool> {
  /// Selector provider for user profile loading state
  const UserProfileLoadingProvider._(
      {required UserProfileLoadingFamily super.from,
      required String super.argument})
      : super(
          retry: null,
          name: r'userProfileLoadingProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$userProfileLoadingHash();

  @override
  String toString() {
    return r'userProfileLoadingProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  bool create(Ref ref) {
    final argument = this.argument as String;
    return userProfileLoading(
      ref,
      argument,
    );
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is UserProfileLoadingProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$userProfileLoadingHash() =>
    r'c577c3bb2ff070cafa9294ea4c9411900a41331a';

/// Selector provider for user profile loading state

final class UserProfileLoadingFamily extends $Family
    with $FunctionalFamilyOverride<bool, String> {
  const UserProfileLoadingFamily._()
      : super(
          retry: null,
          name: r'userProfileLoadingProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: true,
        );

  /// Selector provider for user profile loading state

  UserProfileLoadingProvider call(
    String userId,
  ) =>
      UserProfileLoadingProvider._(argument: userId, from: this);

  @override
  String toString() => r'userProfileLoadingProvider';
}

/// Selector provider for user profile error state

@ProviderFor(userProfileError)
const userProfileErrorProvider = UserProfileErrorFamily._();

/// Selector provider for user profile error state

final class UserProfileErrorProvider
    extends $FunctionalProvider<String?, String?, String?>
    with $Provider<String?> {
  /// Selector provider for user profile error state
  const UserProfileErrorProvider._(
      {required UserProfileErrorFamily super.from,
      required String super.argument})
      : super(
          retry: null,
          name: r'userProfileErrorProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$userProfileErrorHash();

  @override
  String toString() {
    return r'userProfileErrorProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<String?> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  String? create(Ref ref) {
    final argument = this.argument as String;
    return userProfileError(
      ref,
      argument,
    );
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String?>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is UserProfileErrorProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$userProfileErrorHash() => r'8036ade535fb87555770c6ba80ecb2cb0826facf';

/// Selector provider for user profile error state

final class UserProfileErrorFamily extends $Family
    with $FunctionalFamilyOverride<String?, String> {
  const UserProfileErrorFamily._()
      : super(
          retry: null,
          name: r'userProfileErrorProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: true,
        );

  /// Selector provider for user profile error state

  UserProfileErrorProvider call(
    String userId,
  ) =>
      UserProfileErrorProvider._(argument: userId, from: this);

  @override
  String toString() => r'userProfileErrorProvider';
}
