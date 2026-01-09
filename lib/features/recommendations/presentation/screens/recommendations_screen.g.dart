// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recommendations_screen.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$recommendationsForItineraryHash() =>
    r'd188d51bdecdf0851b8129809db37685531926a2';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

/// Provider for recommendations for a specific itinerary
///
/// Copied from [recommendationsForItinerary].
@ProviderFor(recommendationsForItinerary)
const recommendationsForItineraryProvider = RecommendationsForItineraryFamily();

/// Provider for recommendations for a specific itinerary
///
/// Copied from [recommendationsForItinerary].
class RecommendationsForItineraryFamily
    extends Family<AsyncValue<List<PersonalizedRecommendation>>> {
  /// Provider for recommendations for a specific itinerary
  ///
  /// Copied from [recommendationsForItinerary].
  const RecommendationsForItineraryFamily();

  /// Provider for recommendations for a specific itinerary
  ///
  /// Copied from [recommendationsForItinerary].
  RecommendationsForItineraryProvider call(
    String itineraryId,
  ) {
    return RecommendationsForItineraryProvider(
      itineraryId,
    );
  }

  @override
  RecommendationsForItineraryProvider getProviderOverride(
    covariant RecommendationsForItineraryProvider provider,
  ) {
    return call(
      provider.itineraryId,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'recommendationsForItineraryProvider';
}

/// Provider for recommendations for a specific itinerary
///
/// Copied from [recommendationsForItinerary].
class RecommendationsForItineraryProvider
    extends AutoDisposeFutureProvider<List<PersonalizedRecommendation>> {
  /// Provider for recommendations for a specific itinerary
  ///
  /// Copied from [recommendationsForItinerary].
  RecommendationsForItineraryProvider(
    String itineraryId,
  ) : this._internal(
          (ref) => recommendationsForItinerary(
            ref as RecommendationsForItineraryRef,
            itineraryId,
          ),
          from: recommendationsForItineraryProvider,
          name: r'recommendationsForItineraryProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$recommendationsForItineraryHash,
          dependencies: RecommendationsForItineraryFamily._dependencies,
          allTransitiveDependencies:
              RecommendationsForItineraryFamily._allTransitiveDependencies,
          itineraryId: itineraryId,
        );

  RecommendationsForItineraryProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.itineraryId,
  }) : super.internal();

  final String itineraryId;

  @override
  Override overrideWith(
    FutureOr<List<PersonalizedRecommendation>> Function(
            RecommendationsForItineraryRef provider)
        create,
  ) {
    return ProviderOverride(
      origin: this,
      override: RecommendationsForItineraryProvider._internal(
        (ref) => create(ref as RecommendationsForItineraryRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        itineraryId: itineraryId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<PersonalizedRecommendation>>
      createElement() {
    return _RecommendationsForItineraryProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is RecommendationsForItineraryProvider &&
        other.itineraryId == itineraryId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, itineraryId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin RecommendationsForItineraryRef
    on AutoDisposeFutureProviderRef<List<PersonalizedRecommendation>> {
  /// The parameter `itineraryId` of this provider.
  String get itineraryId;
}

class _RecommendationsForItineraryProviderElement
    extends AutoDisposeFutureProviderElement<List<PersonalizedRecommendation>>
    with RecommendationsForItineraryRef {
  _RecommendationsForItineraryProviderElement(super.provider);

  @override
  String get itineraryId =>
      (origin as RecommendationsForItineraryProvider).itineraryId;
}

String _$itineraryHash() => r'a7e19284f3eee684643f28fc4b9e356bc9c5ba93';

/// Provider for getting an itinerary
///
/// Copied from [itinerary].
@ProviderFor(itinerary)
const itineraryProvider = ItineraryFamily();

/// Provider for getting an itinerary
///
/// Copied from [itinerary].
class ItineraryFamily extends Family<AsyncValue<Itinerary>> {
  /// Provider for getting an itinerary
  ///
  /// Copied from [itinerary].
  const ItineraryFamily();

  /// Provider for getting an itinerary
  ///
  /// Copied from [itinerary].
  ItineraryProvider call(
    String itineraryId,
  ) {
    return ItineraryProvider(
      itineraryId,
    );
  }

  @override
  ItineraryProvider getProviderOverride(
    covariant ItineraryProvider provider,
  ) {
    return call(
      provider.itineraryId,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'itineraryProvider';
}

/// Provider for getting an itinerary
///
/// Copied from [itinerary].
class ItineraryProvider extends AutoDisposeFutureProvider<Itinerary> {
  /// Provider for getting an itinerary
  ///
  /// Copied from [itinerary].
  ItineraryProvider(
    String itineraryId,
  ) : this._internal(
          (ref) => itinerary(
            ref as ItineraryRef,
            itineraryId,
          ),
          from: itineraryProvider,
          name: r'itineraryProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$itineraryHash,
          dependencies: ItineraryFamily._dependencies,
          allTransitiveDependencies: ItineraryFamily._allTransitiveDependencies,
          itineraryId: itineraryId,
        );

  ItineraryProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.itineraryId,
  }) : super.internal();

  final String itineraryId;

  @override
  Override overrideWith(
    FutureOr<Itinerary> Function(ItineraryRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: ItineraryProvider._internal(
        (ref) => create(ref as ItineraryRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        itineraryId: itineraryId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<Itinerary> createElement() {
    return _ItineraryProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ItineraryProvider && other.itineraryId == itineraryId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, itineraryId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin ItineraryRef on AutoDisposeFutureProviderRef<Itinerary> {
  /// The parameter `itineraryId` of this provider.
  String get itineraryId;
}

class _ItineraryProviderElement
    extends AutoDisposeFutureProviderElement<Itinerary> with ItineraryRef {
  _ItineraryProviderElement(super.provider);

  @override
  String get itineraryId => (origin as ItineraryProvider).itineraryId;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
