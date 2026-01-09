// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'places_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provider for the places service implementation

@ProviderFor(placesService)
final placesServiceProvider = PlacesServiceProvider._();

/// Provider for the places service implementation

final class PlacesServiceProvider
    extends $FunctionalProvider<PlacesService, PlacesService, PlacesService>
    with $Provider<PlacesService> {
  /// Provider for the places service implementation
  PlacesServiceProvider._()
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

String _$placesServiceHash() => r'fe40138fd41f49ffb8500012076726377eed273c';
