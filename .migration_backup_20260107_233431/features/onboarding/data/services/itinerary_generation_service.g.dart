// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'itinerary_generation_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provider for the itinerary generation service implementation

@ProviderFor(itineraryGenerationService)
final itineraryGenerationServiceProvider =
    ItineraryGenerationServiceProvider._();

/// Provider for the itinerary generation service implementation

final class ItineraryGenerationServiceProvider extends $FunctionalProvider<
    ItineraryGenerationService,
    ItineraryGenerationService,
    ItineraryGenerationService> with $Provider<ItineraryGenerationService> {
  /// Provider for the itinerary generation service implementation
  ItineraryGenerationServiceProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'itineraryGenerationServiceProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$itineraryGenerationServiceHash();

  @$internal
  @override
  $ProviderElement<ItineraryGenerationService> $createElement(
          $ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  ItineraryGenerationService create(Ref ref) {
    return itineraryGenerationService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ItineraryGenerationService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ItineraryGenerationService>(value),
    );
  }
}

String _$itineraryGenerationServiceHash() =>
    r'f641ecf6b2275c21c9e403234491cdff7b6083a1';
