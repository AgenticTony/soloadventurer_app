// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Repository provider
///
/// Uses Riverpod providers to inject offline-aware dependencies

@ProviderFor(profileRepository)
final profileRepositoryProvider = ProfileRepositoryProvider._();

/// Repository provider
///
/// Uses Riverpod providers to inject offline-aware dependencies

final class ProfileRepositoryProvider extends $FunctionalProvider<
    ProfileRepository,
    ProfileRepository,
    ProfileRepository> with $Provider<ProfileRepository> {
  /// Repository provider
  ///
  /// Uses Riverpod providers to inject offline-aware dependencies
  ProfileRepositoryProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'profileRepositoryProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$profileRepositoryHash();

  @$internal
  @override
  $ProviderElement<ProfileRepository> $createElement(
          $ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  ProfileRepository create(Ref ref) {
    return profileRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ProfileRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ProfileRepository>(value),
    );
  }
}

String _$profileRepositoryHash() => r'b7d7b65657d9d63cb15ce5723a027b840fbc8bdf';

/// Get current profile use case provider

@ProviderFor(getCurrentProfileUseCase)
final getCurrentProfileUseCaseProvider = GetCurrentProfileUseCaseProvider._();

/// Get current profile use case provider

final class GetCurrentProfileUseCaseProvider extends $FunctionalProvider<
    GetCurrentProfileUseCase,
    GetCurrentProfileUseCase,
    GetCurrentProfileUseCase> with $Provider<GetCurrentProfileUseCase> {
  /// Get current profile use case provider
  GetCurrentProfileUseCaseProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'getCurrentProfileUseCaseProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$getCurrentProfileUseCaseHash();

  @$internal
  @override
  $ProviderElement<GetCurrentProfileUseCase> $createElement(
          $ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  GetCurrentProfileUseCase create(Ref ref) {
    return getCurrentProfileUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GetCurrentProfileUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GetCurrentProfileUseCase>(value),
    );
  }
}

String _$getCurrentProfileUseCaseHash() =>
    r'c278ec1e08bd6067d0a80999ec10d555b7cbc42c';

/// Update profile use case provider

@ProviderFor(updateProfileUseCase)
final updateProfileUseCaseProvider = UpdateProfileUseCaseProvider._();

/// Update profile use case provider

final class UpdateProfileUseCaseProvider extends $FunctionalProvider<
    UpdateProfileUseCase,
    UpdateProfileUseCase,
    UpdateProfileUseCase> with $Provider<UpdateProfileUseCase> {
  /// Update profile use case provider
  UpdateProfileUseCaseProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'updateProfileUseCaseProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$updateProfileUseCaseHash();

  @$internal
  @override
  $ProviderElement<UpdateProfileUseCase> $createElement(
          $ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  UpdateProfileUseCase create(Ref ref) {
    return updateProfileUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(UpdateProfileUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<UpdateProfileUseCase>(value),
    );
  }
}

String _$updateProfileUseCaseHash() =>
    r'96d5490a2bfd8bfdbbd0f4e15e495d18105b5037';

/// Manage avatar use case provider

@ProviderFor(manageAvatarUseCase)
final manageAvatarUseCaseProvider = ManageAvatarUseCaseProvider._();

/// Manage avatar use case provider

final class ManageAvatarUseCaseProvider extends $FunctionalProvider<
    ManageAvatarUseCase,
    ManageAvatarUseCase,
    ManageAvatarUseCase> with $Provider<ManageAvatarUseCase> {
  /// Manage avatar use case provider
  ManageAvatarUseCaseProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'manageAvatarUseCaseProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$manageAvatarUseCaseHash();

  @$internal
  @override
  $ProviderElement<ManageAvatarUseCase> $createElement(
          $ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  ManageAvatarUseCase create(Ref ref) {
    return manageAvatarUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ManageAvatarUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ManageAvatarUseCase>(value),
    );
  }
}

String _$manageAvatarUseCaseHash() =>
    r'90f89db89a9a9793f678def444bfe5759d720530';

/// Delete profile use case provider

@ProviderFor(deleteProfileUseCase)
final deleteProfileUseCaseProvider = DeleteProfileUseCaseProvider._();

/// Delete profile use case provider

final class DeleteProfileUseCaseProvider extends $FunctionalProvider<
    DeleteProfileUseCase,
    DeleteProfileUseCase,
    DeleteProfileUseCase> with $Provider<DeleteProfileUseCase> {
  /// Delete profile use case provider
  DeleteProfileUseCaseProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'deleteProfileUseCaseProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$deleteProfileUseCaseHash();

  @$internal
  @override
  $ProviderElement<DeleteProfileUseCase> $createElement(
          $ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  DeleteProfileUseCase create(Ref ref) {
    return deleteProfileUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DeleteProfileUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DeleteProfileUseCase>(value),
    );
  }
}

String _$deleteProfileUseCaseHash() =>
    r'6328011646c6f6abc387742b185021efab955463';

/// Create profile use case provider

@ProviderFor(createProfileUseCase)
final createProfileUseCaseProvider = CreateProfileUseCaseProvider._();

/// Create profile use case provider

final class CreateProfileUseCaseProvider extends $FunctionalProvider<
    CreateProfileUseCase,
    CreateProfileUseCase,
    CreateProfileUseCase> with $Provider<CreateProfileUseCase> {
  /// Create profile use case provider
  CreateProfileUseCaseProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'createProfileUseCaseProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$createProfileUseCaseHash();

  @$internal
  @override
  $ProviderElement<CreateProfileUseCase> $createElement(
          $ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  CreateProfileUseCase create(Ref ref) {
    return createProfileUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CreateProfileUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CreateProfileUseCase>(value),
    );
  }
}

String _$createProfileUseCaseHash() =>
    r'60fc46f88493bd9fac34a8df3a5d4a5bbcace68d';

/// Domain state provider - handles core business logic

@ProviderFor(ProfileDomainNotifier)
final profileDomainProvider = ProfileDomainNotifierFamily._();

/// Domain state provider - handles core business logic
final class ProfileDomainNotifierProvider
    extends $NotifierProvider<ProfileDomainNotifier, ProfileDomainState> {
  /// Domain state provider - handles core business logic
  ProfileDomainNotifierProvider._(
      {required ProfileDomainNotifierFamily super.from,
      required String super.argument})
      : super(
          retry: null,
          name: r'profileDomainProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$profileDomainNotifierHash();

  @override
  String toString() {
    return r'profileDomainProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  ProfileDomainNotifier create() => ProfileDomainNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ProfileDomainState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ProfileDomainState>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is ProfileDomainNotifierProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$profileDomainNotifierHash() =>
    r'b98cb4f0020b5ca203db3718ce4dff7f32e8528c';

/// Domain state provider - handles core business logic

final class ProfileDomainNotifierFamily extends $Family
    with
        $ClassFamilyOverride<ProfileDomainNotifier, ProfileDomainState,
            ProfileDomainState, ProfileDomainState, String> {
  ProfileDomainNotifierFamily._()
      : super(
          retry: null,
          name: r'profileDomainProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: true,
        );

  /// Domain state provider - handles core business logic

  ProfileDomainNotifierProvider call(
    String id,
  ) =>
      ProfileDomainNotifierProvider._(argument: id, from: this);

  @override
  String toString() => r'profileDomainProvider';
}

/// Domain state provider - handles core business logic

abstract class _$ProfileDomainNotifier extends $Notifier<ProfileDomainState> {
  late final _$args = ref.$arg as String;
  String get id => _$args;

  ProfileDomainState build(
    String id,
  );
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<ProfileDomainState, ProfileDomainState>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<ProfileDomainState, ProfileDomainState>,
        ProfileDomainState,
        Object?,
        Object?>;
    element.handleCreate(
        ref,
        () => build(
              _$args,
            ));
  }
}

/// Notifier for profile navigation history

@ProviderFor(ProfileNavigationNotifier)
final profileNavigationProvider = ProfileNavigationNotifierProvider._();

/// Notifier for profile navigation history
final class ProfileNavigationNotifierProvider extends $NotifierProvider<
    ProfileNavigationNotifier, ProfileNavigationState> {
  /// Notifier for profile navigation history
  ProfileNavigationNotifierProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'profileNavigationProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$profileNavigationNotifierHash();

  @$internal
  @override
  ProfileNavigationNotifier create() => ProfileNavigationNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ProfileNavigationState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ProfileNavigationState>(value),
    );
  }
}

String _$profileNavigationNotifierHash() =>
    r'c717355d7ad7a80ae060313466bcba5233fb3fcd';

/// Notifier for profile navigation history

abstract class _$ProfileNavigationNotifier
    extends $Notifier<ProfileNavigationState> {
  ProfileNavigationState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref as $Ref<ProfileNavigationState, ProfileNavigationState>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<ProfileNavigationState, ProfileNavigationState>,
        ProfileNavigationState,
        Object?,
        Object?>;
    element.handleCreate(ref, build);
  }
}

/// Selector for profile loading state

@ProviderFor(profileLoading)
final profileLoadingProvider = ProfileLoadingFamily._();

/// Selector for profile loading state

final class ProfileLoadingProvider extends $FunctionalProvider<bool, bool, bool>
    with $Provider<bool> {
  /// Selector for profile loading state
  ProfileLoadingProvider._(
      {required ProfileLoadingFamily super.from,
      required String super.argument})
      : super(
          retry: null,
          name: r'profileLoadingProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$profileLoadingHash();

  @override
  String toString() {
    return r'profileLoadingProvider'
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
    return profileLoading(
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
    return other is ProfileLoadingProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$profileLoadingHash() => r'41413d69018c9507dfb15bd6419abbf8cb28f854';

/// Selector for profile loading state

final class ProfileLoadingFamily extends $Family
    with $FunctionalFamilyOverride<bool, String> {
  ProfileLoadingFamily._()
      : super(
          retry: null,
          name: r'profileLoadingProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: true,
        );

  /// Selector for profile loading state

  ProfileLoadingProvider call(
    String id,
  ) =>
      ProfileLoadingProvider._(argument: id, from: this);

  @override
  String toString() => r'profileLoadingProvider';
}

/// Selector for profile error

@ProviderFor(profileError)
final profileErrorProvider = ProfileErrorFamily._();

/// Selector for profile error

final class ProfileErrorProvider
    extends $FunctionalProvider<String?, String?, String?>
    with $Provider<String?> {
  /// Selector for profile error
  ProfileErrorProvider._(
      {required ProfileErrorFamily super.from, required String super.argument})
      : super(
          retry: null,
          name: r'profileErrorProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$profileErrorHash();

  @override
  String toString() {
    return r'profileErrorProvider'
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
    return profileError(
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
    return other is ProfileErrorProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$profileErrorHash() => r'48d50a371e26faeae5744d8879996865f1a6c73e';

/// Selector for profile error

final class ProfileErrorFamily extends $Family
    with $FunctionalFamilyOverride<String?, String> {
  ProfileErrorFamily._()
      : super(
          retry: null,
          name: r'profileErrorProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: true,
        );

  /// Selector for profile error

  ProfileErrorProvider call(
    String id,
  ) =>
      ProfileErrorProvider._(argument: id, from: this);

  @override
  String toString() => r'profileErrorProvider';
}
