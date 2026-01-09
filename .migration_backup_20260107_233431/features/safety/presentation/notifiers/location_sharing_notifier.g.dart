// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'location_sharing_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Notifier for managing location sharing state
/// Handles starting, stopping, and monitoring location shares

@ProviderFor(LocationSharingNotifier)
final locationSharingProvider = LocationSharingNotifierProvider._();

/// Notifier for managing location sharing state
/// Handles starting, stopping, and monitoring location shares
final class LocationSharingNotifierProvider extends $NotifierProvider<
    LocationSharingNotifier, AsyncValue<LocationSharingData>> {
  /// Notifier for managing location sharing state
  /// Handles starting, stopping, and monitoring location shares
  LocationSharingNotifierProvider._()
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
  String debugGetCreateSourceHash() => _$locationSharingNotifierHash();

  @$internal
  @override
  LocationSharingNotifier create() => LocationSharingNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<LocationSharingData> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride:
          $SyncValueProvider<AsyncValue<LocationSharingData>>(value),
    );
  }
}

String _$locationSharingNotifierHash() =>
    r'2302cf21ddeaef67f2b2f170bed371414dc9fc04';

/// Notifier for managing location sharing state
/// Handles starting, stopping, and monitoring location shares

abstract class _$LocationSharingNotifier
    extends $Notifier<AsyncValue<LocationSharingData>> {
  AsyncValue<LocationSharingData> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<LocationSharingData>,
        AsyncValue<LocationSharingData>>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<AsyncValue<LocationSharingData>,
            AsyncValue<LocationSharingData>>,
        AsyncValue<LocationSharingData>,
        Object?,
        Object?>;
    element.handleCreate(ref, build);
  }
}
