// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'places_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provider for the places service implementation
///
/// This provider returns the actual implementation from places_service_impl.dart.
/// The placesServiceOverrideProvider handles the proper instantiation.

@ProviderFor(placesService)
const placesServiceProvider = PlacesServiceProvider._();

/// Provider for the places service implementation
///
/// This provider returns the actual implementation from places_service_impl.dart.
/// The placesServiceOverrideProvider handles the proper instantiation.

final class PlacesServiceProvider
    extends $FunctionalProvider<PlacesService, PlacesService, PlacesService>
    with $Provider<PlacesService> {
  /// Provider for the places service implementation
  ///
  /// This provider returns the actual implementation from places_service_impl.dart.
  /// The placesServiceOverrideProvider handles the proper instantiation.
  const PlacesServiceProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'placesServiceProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$placesServiceHash();

  @$internal
  @override
  $ProviderElement<PlacesService> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  PlacesService create(Ref ref) {
    return placesService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PlacesService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PlacesService>(value),
    );
  }
}

String _$placesServiceHash() => r'f9e71183bc6441e97f4ed5cf6a06ed4837c1b29f';
