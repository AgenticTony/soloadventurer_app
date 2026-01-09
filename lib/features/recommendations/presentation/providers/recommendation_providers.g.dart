// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recommendation_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$placesRemoteDataSourceHash() =>
    r'c522f18fdd15de93f1535fa2d544488dea8fa5fb';

/// Provider for places remote data source
///
/// Uses PlacesRemoteDataSourceImpl with ApiClient for real API calls.
/// In production, Google Places API integration should be completed.
///
/// Copied from [placesRemoteDataSource].
@ProviderFor(placesRemoteDataSource)
final placesRemoteDataSourceProvider =
    AutoDisposeProvider<PlacesRemoteDataSource>.internal(
  placesRemoteDataSource,
  name: r'placesRemoteDataSourceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$placesRemoteDataSourceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef PlacesRemoteDataSourceRef
    = AutoDisposeProviderRef<PlacesRemoteDataSource>;
String _$placesRepositoryHash() => r'f43f194ce08c16a9807bbb2cc0739c63ef41e186';

/// Provider for places repository
///
/// Copied from [placesRepository].
@ProviderFor(placesRepository)
final placesRepositoryProvider = AutoDisposeProvider<PlacesRepository>.internal(
  placesRepository,
  name: r'placesRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$placesRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef PlacesRepositoryRef = AutoDisposeProviderRef<PlacesRepository>;
String _$recommendationLocalDataSourceHash() =>
    r'98f145db5d11785b78da806b5914d4c93e6d5ebe';

/// Provider for recommendation local data source
///
/// Copied from [recommendationLocalDataSource].
@ProviderFor(recommendationLocalDataSource)
final recommendationLocalDataSourceProvider =
    AutoDisposeProvider<RecommendationLocalDataSource>.internal(
  recommendationLocalDataSource,
  name: r'recommendationLocalDataSourceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$recommendationLocalDataSourceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef RecommendationLocalDataSourceRef
    = AutoDisposeProviderRef<RecommendationLocalDataSource>;
String _$recommendationRepositoryHash() =>
    r'78088bcb4b9e57412ae4568c6dd3057f2f003943';

/// Provider for recommendation repository
///
/// Copied from [recommendationRepository].
@ProviderFor(recommendationRepository)
final recommendationRepositoryProvider =
    AutoDisposeProvider<RecommendationRepository>.internal(
  recommendationRepository,
  name: r'recommendationRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$recommendationRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef RecommendationRepositoryRef
    = AutoDisposeProviderRef<RecommendationRepository>;
String _$itineraryLocalDataSourceHash() =>
    r'1d4ab71725bc49094cdafad73a3fd33dc4321d4a';

/// Provider for itinerary local data source
///
/// Uses ItineraryLocalDataSourceImpl with ItineraryDao for real database operations.
///
/// Copied from [itineraryLocalDataSource].
@ProviderFor(itineraryLocalDataSource)
final itineraryLocalDataSourceProvider =
    AutoDisposeProvider<ItineraryLocalDataSource>.internal(
  itineraryLocalDataSource,
  name: r'itineraryLocalDataSourceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$itineraryLocalDataSourceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ItineraryLocalDataSourceRef
    = AutoDisposeProviderRef<ItineraryLocalDataSource>;
String _$itineraryRepositoryHash() =>
    r'4272c0dd8809f4261ac5cca29bb82e8da1133afd';

/// Provider for itinerary repository
///
/// Copied from [itineraryRepository].
@ProviderFor(itineraryRepository)
final itineraryRepositoryProvider =
    AutoDisposeProvider<ItineraryRepository>.internal(
  itineraryRepository,
  name: r'itineraryRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$itineraryRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ItineraryRepositoryRef = AutoDisposeProviderRef<ItineraryRepository>;
String _$recommendationServiceHash() =>
    r'2bb4fe459cb9637767929df1fd91e4377b2eff82';

/// Provider for recommendation service
///
/// Copied from [recommendationService].
@ProviderFor(recommendationService)
final recommendationServiceProvider =
    AutoDisposeProvider<RecommendationService>.internal(
  recommendationService,
  name: r'recommendationServiceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$recommendationServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef RecommendationServiceRef
    = AutoDisposeProviderRef<RecommendationService>;
String _$getPersonalizedRecommendationsHash() =>
    r'5d18d31b541130a450ea61760ee35906a77e2dcb';

/// Provider for GetPersonalizedRecommendations use case
///
/// Copied from [getPersonalizedRecommendations].
@ProviderFor(getPersonalizedRecommendations)
final getPersonalizedRecommendationsProvider =
    AutoDisposeProvider<GetPersonalizedRecommendations>.internal(
  getPersonalizedRecommendations,
  name: r'getPersonalizedRecommendationsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$getPersonalizedRecommendationsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef GetPersonalizedRecommendationsRef
    = AutoDisposeProviderRef<GetPersonalizedRecommendations>;
String _$getRecommendationsForDateHash() =>
    r'bfe02de7b7d204c07f110e5a39a43d08ec80c0d5';

/// Provider for GetRecommendationsForDate use case
///
/// Copied from [getRecommendationsForDate].
@ProviderFor(getRecommendationsForDate)
final getRecommendationsForDateProvider =
    AutoDisposeProvider<GetRecommendationsForDate>.internal(
  getRecommendationsForDate,
  name: r'getRecommendationsForDateProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$getRecommendationsForDateHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef GetRecommendationsForDateRef
    = AutoDisposeProviderRef<GetRecommendationsForDate>;
String _$addRecommendationToItineraryHash() =>
    r'9dfcbcb1b649055edfd4518ea32e287326daebd2';

/// Provider for AddRecommendationToItinerary use case
///
/// Copied from [addRecommendationToItinerary].
@ProviderFor(addRecommendationToItinerary)
final addRecommendationToItineraryProvider =
    AutoDisposeProvider<AddRecommendationToItinerary>.internal(
  addRecommendationToItinerary,
  name: r'addRecommendationToItineraryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$addRecommendationToItineraryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AddRecommendationToItineraryRef
    = AutoDisposeProviderRef<AddRecommendationToItinerary>;
String _$provideRecommendationFeedbackHash() =>
    r'a279f57603d2eb6ca7688eef1089538e543d2860';

/// Provider for ProvideRecommendationFeedback use case
///
/// Copied from [provideRecommendationFeedback].
@ProviderFor(provideRecommendationFeedback)
final provideRecommendationFeedbackProvider =
    AutoDisposeProvider<ProvideRecommendationFeedback>.internal(
  provideRecommendationFeedback,
  name: r'provideRecommendationFeedbackProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$provideRecommendationFeedbackHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ProvideRecommendationFeedbackRef
    = AutoDisposeProviderRef<ProvideRecommendationFeedback>;
String _$weatherServiceHash() => r'a869ce7c09091bbc9a31d86d8d962c9d5603b49b';

/// Provider for weather service - uses stub implementation
/// TODO: Implement actual weather service integration
///
/// Copied from [weatherService].
@ProviderFor(weatherService)
final weatherServiceProvider = AutoDisposeProvider<WeatherService>.internal(
  weatherService,
  name: r'weatherServiceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$weatherServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef WeatherServiceRef = AutoDisposeProviderRef<WeatherService>;
String _$locationServiceHash() => r'd536a0768eac411321902a2124108ea5d57c837e';

/// Provider for location service - uses implementation from core services
///
/// Copied from [locationService].
@ProviderFor(locationService)
final locationServiceProvider = AutoDisposeProvider<LocationService>.internal(
  locationService,
  name: r'locationServiceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$locationServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef LocationServiceRef = AutoDisposeProviderRef<LocationService>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
