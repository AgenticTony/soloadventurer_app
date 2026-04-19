// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'test_profile_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provider that returns profile data from the current Supabase auth session.
///
/// On first build, it reads user metadata from the auth session.
/// Falls back to placeholder values if no session exists.

@ProviderFor(testProfile)
const testProfileProvider = TestProfileProvider._();

/// Provider that returns profile data from the current Supabase auth session.
///
/// On first build, it reads user metadata from the auth session.
/// Falls back to placeholder values if no session exists.

final class TestProfileProvider
    extends $FunctionalProvider<ProfileState, ProfileState, ProfileState>
    with $Provider<ProfileState> {
  /// Provider that returns profile data from the current Supabase auth session.
  ///
  /// On first build, it reads user metadata from the auth session.
  /// Falls back to placeholder values if no session exists.
  const TestProfileProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'testProfileProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$testProfileHash();

  @$internal
  @override
  $ProviderElement<ProfileState> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  ProfileState create(Ref ref) {
    return testProfile(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ProfileState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ProfileState>(value),
    );
  }
}

String _$testProfileHash() => r'4efc52069b759e1bbbd2da7dce01dd3cdd18fac7';
