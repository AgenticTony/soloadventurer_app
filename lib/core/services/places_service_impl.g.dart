// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'places_service_impl.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provider for PlacesServiceImpl.

@ProviderFor(placesServiceImpl)
const placesServiceImplProvider = PlacesServiceImplProvider._();

/// Provider for PlacesServiceImpl.

final class PlacesServiceImplProvider
    extends $FunctionalProvider<PlacesService, PlacesService, PlacesService>
    with $Provider<PlacesService> {
  /// Provider for PlacesServiceImpl.
  const PlacesServiceImplProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'placesServiceImplProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$placesServiceImplHash();

  @$internal
  @override
  $ProviderElement<PlacesService> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  PlacesService create(Ref ref) {
    return placesServiceImpl(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PlacesService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PlacesService>(value),
    );
  }
}

String _$placesServiceImplHash() => r'6fcb043dee53e5a18d8a34e79016ef2d09f4f074';

/// Provider override for PlacesService interface.

@ProviderFor(placesServiceOverride)
const placesServiceOverrideProvider = PlacesServiceOverrideProvider._();

/// Provider override for PlacesService interface.

final class PlacesServiceOverrideProvider
    extends $FunctionalProvider<PlacesService, PlacesService, PlacesService>
    with $Provider<PlacesService> {
  /// Provider override for PlacesService interface.
  const PlacesServiceOverrideProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'placesServiceOverrideProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$placesServiceOverrideHash();

  @$internal
  @override
  $ProviderElement<PlacesService> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  PlacesService create(Ref ref) {
    return placesServiceOverride(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PlacesService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PlacesService>(value),
    );
  }
}

String _$placesServiceOverrideHash() =>
    r'5def1bd46207caec0bd5b12de7dc25752aea3b31';
