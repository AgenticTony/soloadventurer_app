// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'location_service_impl.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provider for LocationServiceImpl

@ProviderFor(locationServiceImpl)
const locationServiceImplProvider = LocationServiceImplProvider._();

/// Provider for LocationServiceImpl

final class LocationServiceImplProvider extends $FunctionalProvider<
    LocationService,
    LocationService,
    LocationService> with $Provider<LocationService> {
  /// Provider for LocationServiceImpl
  const LocationServiceImplProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'locationServiceImplProvider',
          isAutoDispose: true,
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
    r'bde99dc9ade45e54e20ab03249926a28f189ad37';

/// Provider override for LocationService interface

@ProviderFor(locationServiceOverride)
const locationServiceOverrideProvider = LocationServiceOverrideProvider._();

/// Provider override for LocationService interface

final class LocationServiceOverrideProvider extends $FunctionalProvider<
    LocationService,
    LocationService,
    LocationService> with $Provider<LocationService> {
  /// Provider override for LocationService interface
  const LocationServiceOverrideProvider._()
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
