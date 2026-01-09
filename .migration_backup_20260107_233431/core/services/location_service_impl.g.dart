// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'location_service_impl.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provider for LocationServiceImpl

@ProviderFor(locationServiceImpl)
final locationServiceImplProvider = LocationServiceImplProvider._();

/// Provider for LocationServiceImpl

final class LocationServiceImplProvider extends $FunctionalProvider<
    LocationService,
    LocationService,
    LocationService> with $Provider<LocationService> {
  /// Provider for LocationServiceImpl
  LocationServiceImplProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'locationServiceImplProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$locationServiceImplHash();

  @$internal
  @override
  $ProviderElement<LocationService> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  LocationService create(Ref ref) {
    return locationServiceImpl(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(LocationService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<LocationService>(value),
    );
  }
}

String _$locationServiceImplHash() =>
    r'07bd46c4a08b3f81b50670adfa37b86a8c1890b1';

/// Provider override for LocationService interface

@ProviderFor(locationServiceOverride)
final locationServiceOverrideProvider = LocationServiceOverrideProvider._();

/// Provider override for LocationService interface

final class LocationServiceOverrideProvider extends $FunctionalProvider<
    LocationService,
    LocationService,
    LocationService> with $Provider<LocationService> {
  /// Provider override for LocationService interface
  LocationServiceOverrideProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'locationServiceOverrideProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$locationServiceOverrideHash();

  @$internal
  @override
  $ProviderElement<LocationService> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  LocationService create(Ref ref) {
    return locationServiceOverride(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(LocationService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<LocationService>(value),
    );
  }
}

String _$locationServiceOverrideHash() =>
    r'7605a9afd45500a615e8ff39dd13bca14b32e9ea';
