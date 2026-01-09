// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'test_profile_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Test profile provider that returns mock data

@ProviderFor(testProfile)
final testProfileProvider = TestProfileProvider._();

/// Test profile provider that returns mock data

final class TestProfileProvider
    extends $FunctionalProvider<ProfileState, ProfileState, ProfileState>
    with $Provider<ProfileState> {
  /// Test profile provider that returns mock data
  TestProfileProvider._()
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

String _$testProfileHash() => r'ea97928bda15be57c5a699ab472018923fa0b27a';
