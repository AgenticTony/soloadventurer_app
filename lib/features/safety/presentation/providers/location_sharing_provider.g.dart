// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'location_sharing_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// AsyncNotifier for managing location sharing state.
///
/// Riverpod 3.0 Compliant:
/// - Uses @riverpod annotation with code generation
/// - AsyncNotifier with AsyncValue handles loading/error
/// - State no longer has isLoading/error fields

@ProviderFor(LocationSharing)
const locationSharingProvider = LocationSharingProvider._();

/// AsyncNotifier for managing location sharing state.
///
/// Riverpod 3.0 Compliant:
/// - Uses @riverpod annotation with code generation
/// - AsyncNotifier with AsyncValue handles loading/error
/// - State no longer has isLoading/error fields
final class LocationSharingProvider
    extends $AsyncNotifierProvider<LocationSharing, LocationSharingState> {
  /// AsyncNotifier for managing location sharing state.
  ///
  /// Riverpod 3.0 Compliant:
  /// - Uses @riverpod annotation with code generation
  /// - AsyncNotifier with AsyncValue handles loading/error
  /// - State no longer has isLoading/error fields
  const LocationSharingProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'locationSharingProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$locationSharingHash();

  @$internal
  @override
  LocationSharing create() => LocationSharing();
}

String _$locationSharingHash() => r'db06cafbfa7188a2423dc0deca4845d7b32aa6aa';

/// AsyncNotifier for managing location sharing state.
///
/// Riverpod 3.0 Compliant:
/// - Uses @riverpod annotation with code generation
/// - AsyncNotifier with AsyncValue handles loading/error
/// - State no longer has isLoading/error fields

abstract class _$LocationSharing extends $AsyncNotifier<LocationSharingState> {
  FutureOr<LocationSharingState> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref
        as $Ref<AsyncValue<LocationSharingState>, LocationSharingState>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<AsyncValue<LocationSharingState>, LocationSharingState>,
        AsyncValue<LocationSharingState>,
        Object?,
        Object?>;
    element.handleValue(ref, created);
  }
}
