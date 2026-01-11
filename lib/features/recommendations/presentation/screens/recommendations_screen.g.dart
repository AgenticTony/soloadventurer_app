// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recommendations_screen.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provider for recommendations for a specific itinerary

@ProviderFor(recommendationsForItinerary)
const recommendationsForItineraryProvider =
    RecommendationsForItineraryFamily._();

/// Provider for recommendations for a specific itinerary

final class RecommendationsForItineraryProvider extends $FunctionalProvider<
        AsyncValue<List<PersonalizedRecommendation>>,
        List<PersonalizedRecommendation>,
        FutureOr<List<PersonalizedRecommendation>>>
    with
        $FutureModifier<List<PersonalizedRecommendation>>,
        $FutureProvider<List<PersonalizedRecommendation>> {
  /// Provider for recommendations for a specific itinerary
  const RecommendationsForItineraryProvider._(
      {required RecommendationsForItineraryFamily super.from,
      required String super.argument})
      : super(
          retry: null,
          name: r'recommendationsForItineraryProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$recommendationsForItineraryHash();

  @override
  String toString() {
    return r'recommendationsForItineraryProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<PersonalizedRecommendation>> $createElement(
          $ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<List<PersonalizedRecommendation>> create(Ref ref) {
    final argument = this.argument as String;
    return recommendationsForItinerary(
      ref,
      argument,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is RecommendationsForItineraryProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$recommendationsForItineraryHash() =>
    r'd188d51bdecdf0851b8129809db37685531926a2';

/// Provider for recommendations for a specific itinerary

final class RecommendationsForItineraryFamily extends $Family
    with
        $FunctionalFamilyOverride<FutureOr<List<PersonalizedRecommendation>>,
            String> {
  const RecommendationsForItineraryFamily._()
      : super(
          retry: null,
          name: r'recommendationsForItineraryProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: true,
        );

  /// Provider for recommendations for a specific itinerary

  RecommendationsForItineraryProvider call(
    String itineraryId,
  ) =>
      RecommendationsForItineraryProvider._(argument: itineraryId, from: this);

  @override
  String toString() => r'recommendationsForItineraryProvider';
}

/// Provider for getting an itinerary

@ProviderFor(itinerary)
const itineraryProvider = ItineraryFamily._();

/// Provider for getting an itinerary

final class ItineraryProvider extends $FunctionalProvider<AsyncValue<Itinerary>,
        Itinerary, FutureOr<Itinerary>>
    with $FutureModifier<Itinerary>, $FutureProvider<Itinerary> {
  /// Provider for getting an itinerary
  const ItineraryProvider._(
      {required ItineraryFamily super.from, required String super.argument})
      : super(
          retry: null,
          name: r'itineraryProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$itineraryHash();

  @override
  String toString() {
    return r'itineraryProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<Itinerary> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<Itinerary> create(Ref ref) {
    final argument = this.argument as String;
    return itinerary(
      ref,
      argument,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is ItineraryProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$itineraryHash() => r'a7e19284f3eee684643f28fc4b9e356bc9c5ba93';

/// Provider for getting an itinerary

final class ItineraryFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<Itinerary>, String> {
  const ItineraryFamily._()
      : super(
          retry: null,
          name: r'itineraryProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: true,
        );

  /// Provider for getting an itinerary

  ItineraryProvider call(
    String itineraryId,
  ) =>
      ItineraryProvider._(argument: itineraryId, from: this);

  @override
  String toString() => r'itineraryProvider';
}
