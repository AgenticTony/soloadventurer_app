// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'location_sharing_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Notifier for managing location sharing state
/// Handles starting, stopping, and monitoring location shares
///
/// Riverpod 3.0 Compliant:
/// - Uses @riverpod annotation with code generation
/// - Uses Notifier base class instead of StateNotifier
/// - Dependencies accessed via ref.watch() in methods

@ProviderFor(LocationSharing)
final locationSharingProvider = LocationSharingProvider._();

/// Notifier for managing location sharing state
/// Handles starting, stopping, and monitoring location shares
///
/// Riverpod 3.0 Compliant:
/// - Uses @riverpod annotation with code generation
/// - Uses Notifier base class instead of StateNotifier
/// - Dependencies accessed via ref.watch() in methods
final class LocationSharingProvider
    extends $NotifierProvider<LocationSharing, LocationSharingState> {
  /// Notifier for managing location sharing state
  /// Handles starting, stopping, and monitoring location shares
  ///
  /// Riverpod 3.0 Compliant:
  /// - Uses @riverpod annotation with code generation
  /// - Uses Notifier base class instead of StateNotifier
  /// - Dependencies accessed via ref.watch() in methods
  LocationSharingProvider._()
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

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(LocationSharingState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<LocationSharingState>(value),
    );
  }
}

String _$locationSharingHash() => r'0e92bf9fc5bbebe57f315fa07fee65b1c522505a';

/// Notifier for managing location sharing state
/// Handles starting, stopping, and monitoring location shares
///
/// Riverpod 3.0 Compliant:
/// - Uses @riverpod annotation with code generation
/// - Uses Notifier base class instead of StateNotifier
/// - Dependencies accessed via ref.watch() in methods

abstract class _$LocationSharing extends $Notifier<LocationSharingState> {
  LocationSharingState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<LocationSharingState, LocationSharingState>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<LocationSharingState, LocationSharingState>,
        LocationSharingState,
        Object?,
        Object?>;
    element.handleCreate(ref, build);
  }
}
