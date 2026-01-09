// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recommendation_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provider for the recommendation service implementation

@ProviderFor(recommendationService)
final recommendationServiceProvider = RecommendationServiceProvider._();

/// Provider for the recommendation service implementation

final class RecommendationServiceProvider extends $FunctionalProvider<
    RecommendationService,
    RecommendationService,
    RecommendationService> with $Provider<RecommendationService> {
  /// Provider for the recommendation service implementation
  RecommendationServiceProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'recommendationServiceProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$recommendationServiceHash();

  @$internal
  @override
  $ProviderElement<RecommendationService> $createElement(
          $ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  RecommendationService create(Ref ref) {
    return recommendationService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(RecommendationService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<RecommendationService>(value),
    );
  }
}

String _$recommendationServiceHash() =>
    r'200c425fb239899d8aa06cf4605a89c3afb3f383';
