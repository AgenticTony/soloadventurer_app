// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Riverpod 3.0 Migration Notes:
/// - Converted from StateNotifier<ProfileDomainState> to Notifier<ProfileDomainState>
/// - Dependencies injected via ref.watch() in build() method
/// - build() returns ProfileDomainState not AsyncValue
/// - Constructor auto-load moved to build() method

@ProviderFor(ProfileDomain)
const profileDomainProvider = ProfileDomainProvider._();

/// Riverpod 3.0 Migration Notes:
/// - Converted from StateNotifier<ProfileDomainState> to Notifier<ProfileDomainState>
/// - Dependencies injected via ref.watch() in build() method
/// - build() returns ProfileDomainState not AsyncValue
/// - Constructor auto-load moved to build() method
final class ProfileDomainProvider
    extends $NotifierProvider<ProfileDomain, ProfileDomainState> {
  /// Riverpod 3.0 Migration Notes:
  /// - Converted from StateNotifier<ProfileDomainState> to Notifier<ProfileDomainState>
  /// - Dependencies injected via ref.watch() in build() method
  /// - build() returns ProfileDomainState not AsyncValue
  /// - Constructor auto-load moved to build() method
  const ProfileDomainProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'profileDomainProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$profileDomainHash();

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
}

String _$profileDomainHash() => r'8dc024b2992ec425dc1b5a266522512f06f515f4';

/// Riverpod 3.0 Migration Notes:
/// - Converted from StateNotifier<ProfileDomainState> to Notifier<ProfileDomainState>
/// - Dependencies injected via ref.watch() in build() method
/// - build() returns ProfileDomainState not AsyncValue
/// - Constructor auto-load moved to build() method

abstract class _$ProfileDomain extends $Notifier<ProfileDomainState> {
  ProfileDomainState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<ProfileDomainState, ProfileDomainState>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<ProfileDomainState, ProfileDomainState>,
        ProfileDomainState,
        Object?,
        Object?>;
    element.handleValue(ref, created);
  }
}
