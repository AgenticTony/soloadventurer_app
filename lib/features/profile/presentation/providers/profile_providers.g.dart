// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Riverpod 3.0 Migration Notes:
/// - Repository and use case providers converted to @riverpod
/// - ProfileNavigationNotifier migrated from StateNotifier to Notifier
/// - Profile entity imported with alias to avoid conflicts

@ProviderFor(profileRepository)
final profileRepositoryProvider = ProfileRepositoryProvider._();

/// Riverpod 3.0 Migration Notes:
/// - Repository and use case providers converted to @riverpod
/// - ProfileNavigationNotifier migrated from StateNotifier to Notifier
/// - Profile entity imported with alias to avoid conflicts

final class ProfileRepositoryProvider extends $FunctionalProvider<
    ProfileRepository,
    ProfileRepository,
    ProfileRepository> with $Provider<ProfileRepository> {
  /// Riverpod 3.0 Migration Notes:
  /// - Repository and use case providers converted to @riverpod
  /// - ProfileNavigationNotifier migrated from StateNotifier to Notifier
  /// - Profile entity imported with alias to avoid conflicts
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

String _$profileRepositoryHash() => r'f08e1d61df7f839b31491869430a3cdca5afb06e';

@ProviderFor(getCurrentProfileUseCase)
final getCurrentProfileUseCaseProvider = GetCurrentProfileUseCaseProvider._();

final class GetCurrentProfileUseCaseProvider extends $FunctionalProvider<
    GetCurrentProfileUseCase,
    GetCurrentProfileUseCase,
    GetCurrentProfileUseCase> with $Provider<GetCurrentProfileUseCase> {
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
    r'5075f969d48893d39ec0b466a9577179353e5491';

@ProviderFor(updateProfileUseCase)
final updateProfileUseCaseProvider = UpdateProfileUseCaseProvider._();

final class UpdateProfileUseCaseProvider extends $FunctionalProvider<
    UpdateProfileUseCase,
    UpdateProfileUseCase,
    UpdateProfileUseCase> with $Provider<UpdateProfileUseCase> {
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
    r'463ad3491acffdf79b7ea55b3c4bc170e3aeec1f';

@ProviderFor(manageAvatarUseCase)
final manageAvatarUseCaseProvider = ManageAvatarUseCaseProvider._();

final class ManageAvatarUseCaseProvider extends $FunctionalProvider<
    ManageAvatarUseCase,
    ManageAvatarUseCase,
    ManageAvatarUseCase> with $Provider<ManageAvatarUseCase> {
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
    r'ecd6996d6cf1b85d41560db1a2ec5f9275918468';

@ProviderFor(deleteProfileUseCase)
final deleteProfileUseCaseProvider = DeleteProfileUseCaseProvider._();

final class DeleteProfileUseCaseProvider extends $FunctionalProvider<
    DeleteProfileUseCase,
    DeleteProfileUseCase,
    DeleteProfileUseCase> with $Provider<DeleteProfileUseCase> {
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
    r'387b660bb112bd6c7b99aa58db7c073fbcf8912d';

@ProviderFor(createProfileUseCase)
final createProfileUseCaseProvider = CreateProfileUseCaseProvider._();

final class CreateProfileUseCaseProvider extends $FunctionalProvider<
    CreateProfileUseCase,
    CreateProfileUseCase,
    CreateProfileUseCase> with $Provider<CreateProfileUseCase> {
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
    r'b0c1c2aff19f9445c50d7112f7ec9a2b11e17d0e';

@ProviderFor(ProfileDomain)
final profileDomainProvider = ProfileDomainFamily._();

final class ProfileDomainProvider
    extends $NotifierProvider<ProfileDomain, ProfileDomainState> {
  ProfileDomainProvider._(
      {required ProfileDomainFamily super.from, required String super.argument})
      : super(
          retry: null,
          name: r'profileDomainProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$profileDomainHash();

  @override
  String toString() {
    return r'profileDomainProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  ProfileDomain create() => ProfileDomain();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ProfileDomainState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ProfileDomainState>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is ProfileDomainProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$profileDomainHash() => r'4fbeaa16b5d8c34b08ea1f9377b929797a818f5f';

final class ProfileDomainFamily extends $Family
    with
        $ClassFamilyOverride<ProfileDomain, ProfileDomainState,
            ProfileDomainState, ProfileDomainState, String> {
  ProfileDomainFamily._()
      : super(
          retry: null,
          name: r'profileDomainProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: true,
        );

  ProfileDomainProvider call(
    String id,
  ) =>
      ProfileDomainProvider._(argument: id, from: this);

  @override
  String toString() => r'profileDomainProvider';
}

abstract class _$ProfileDomain extends $Notifier<ProfileDomainState> {
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

@ProviderFor(ProfileNavigationHistory)
final profileNavigationHistoryProvider = ProfileNavigationHistoryProvider._();

final class ProfileNavigationHistoryProvider extends $NotifierProvider<
    ProfileNavigationHistory, ProfileNavigationState> {
  ProfileNavigationHistoryProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'profileNavigationHistoryProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$profileNavigationHistoryHash();

  @$internal
  @override
  ProfileNavigationHistory create() => ProfileNavigationHistory();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ProfileNavigationState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ProfileNavigationState>(value),
    );
  }
}

String _$profileNavigationHistoryHash() =>
    r'04858809b252c44e3a25dbb2035dc547e646dcd0';

abstract class _$ProfileNavigationHistory
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
