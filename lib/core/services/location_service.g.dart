// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'location_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provider for the location service implementation
///
/// This provider returns the actual implementation from location_service_impl.dart.
/// The locationServiceOverrideProvider handles the proper instantiation and disposal.

@ProviderFor(locationService)
const locationServiceProvider = LocationServiceProvider._();

/// Provider for the location service implementation
///
/// This provider returns the actual implementation from location_service_impl.dart.
/// The locationServiceOverrideProvider handles the proper instantiation and disposal.

final class LocationServiceProvider extends $FunctionalProvider<LocationService,
    LocationService, LocationService> with $Provider<LocationService> {
  /// Provider for the location service implementation
  ///
  /// This provider returns the actual implementation from location_service_impl.dart.
  /// The locationServiceOverrideProvider handles the proper instantiation and disposal.
  const LocationServiceProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'locationServiceProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$locationServiceHash();

  @$internal
  @override
  $ProviderElement<LocationService> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  LocationService create(Ref ref) {
    return locationService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(LocationService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<LocationService>(value),
    );
  }
}

String _$locationServiceHash() => r'bbc0fea5c5c76cdfb4d184396d5583049e291838';
