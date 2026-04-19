// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recommendation_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provider for places remote data source
///
/// Uses PlacesRemoteDataSourceImpl with ApiClient for real API calls.
/// In production, Google Places API integration should be completed.

@ProviderFor(placesRemoteDataSource)
const placesRemoteDataSourceProvider = PlacesRemoteDataSourceProvider._();

/// Provider for places remote data source
///
/// Uses PlacesRemoteDataSourceImpl with ApiClient for real API calls.
/// In production, Google Places API integration should be completed.

final class PlacesRemoteDataSourceProvider extends $FunctionalProvider<
    PlacesRemoteDataSource,
    PlacesRemoteDataSource,
    PlacesRemoteDataSource> with $Provider<PlacesRemoteDataSource> {
  /// Provider for places remote data source
  ///
  /// Uses PlacesRemoteDataSourceImpl with ApiClient for real API calls.
  /// In production, Google Places API integration should be completed.
  const PlacesRemoteDataSourceProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'placesRemoteDataSourceProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$placesRemoteDataSourceHash();

  @$internal
  @override
  $ProviderElement<PlacesRemoteDataSource> $createElement(
          $ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  PlacesRemoteDataSource create(Ref ref) {
    return placesRemoteDataSource(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PlacesRemoteDataSource value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PlacesRemoteDataSource>(value),
    );
  }
}

String _$placesRemoteDataSourceHash() =>
    r'f5f53eca9660a02d400a4b23aba56066078f479f';

/// Provider for places repository

@ProviderFor(placesRepository)
const placesRepositoryProvider = PlacesRepositoryProvider._();

/// Provider for places repository

final class PlacesRepositoryProvider extends $FunctionalProvider<
    PlacesRepository,
    PlacesRepository,
    PlacesRepository> with $Provider<PlacesRepository> {
  /// Provider for places repository
  const PlacesRepositoryProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'placesRepositoryProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$placesRepositoryHash();

  @$internal
  @override
  $ProviderElement<PlacesRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  PlacesRepository create(Ref ref) {
    return placesRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PlacesRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PlacesRepository>(value),
    );
  }
}

String _$placesRepositoryHash() => r'f43f194ce08c16a9807bbb2cc0739c63ef41e186';

/// Provider for recommendation local data source

@ProviderFor(recommendationLocalDataSource)
const recommendationLocalDataSourceProvider =
    RecommendationLocalDataSourceProvider._();

/// Provider for recommendation local data source

final class RecommendationLocalDataSourceProvider extends $FunctionalProvider<
        RecommendationLocalDataSource,
        RecommendationLocalDataSource,
        RecommendationLocalDataSource>
    with $Provider<RecommendationLocalDataSource> {
  /// Provider for recommendation local data source
  const RecommendationLocalDataSourceProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'recommendationLocalDataSourceProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$recommendationLocalDataSourceHash();

  @$internal
  @override
  $ProviderElement<RecommendationLocalDataSource> $createElement(
          $ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  RecommendationLocalDataSource create(Ref ref) {
    return recommendationLocalDataSource(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(RecommendationLocalDataSource value) {
    return $ProviderOverride(
      origin: this,
      providerOverride:
          $SyncValueProvider<RecommendationLocalDataSource>(value),
    );
  }
}

String _$recommendationLocalDataSourceHash() =>
    r'98f145db5d11785b78da806b5914d4c93e6d5ebe';

/// Provider for recommendation repository

@ProviderFor(recommendationRepository)
const recommendationRepositoryProvider = RecommendationRepositoryProvider._();

/// Provider for recommendation repository

final class RecommendationRepositoryProvider extends $FunctionalProvider<
    RecommendationRepository,
    RecommendationRepository,
    RecommendationRepository> with $Provider<RecommendationRepository> {
  /// Provider for recommendation repository
  const RecommendationRepositoryProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'recommendationRepositoryProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$recommendationRepositoryHash();

  @$internal
  @override
  $ProviderElement<RecommendationRepository> $createElement(
          $ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  RecommendationRepository create(Ref ref) {
    return recommendationRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(RecommendationRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<RecommendationRepository>(value),
    );
  }
}

String _$recommendationRepositoryHash() =>
    r'78088bcb4b9e57412ae4568c6dd3057f2f003943';

/// Provider for itinerary local data source
///
/// Uses ItineraryLocalDataSourceImpl with ItineraryDao for real database operations.

@ProviderFor(itineraryLocalDataSource)
const itineraryLocalDataSourceProvider = ItineraryLocalDataSourceProvider._();

/// Provider for itinerary local data source
///
/// Uses ItineraryLocalDataSourceImpl with ItineraryDao for real database operations.

final class ItineraryLocalDataSourceProvider extends $FunctionalProvider<
    ItineraryLocalDataSource,
    ItineraryLocalDataSource,
    ItineraryLocalDataSource> with $Provider<ItineraryLocalDataSource> {
  /// Provider for itinerary local data source
  ///
  /// Uses ItineraryLocalDataSourceImpl with ItineraryDao for real database operations.
  const ItineraryLocalDataSourceProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'itineraryLocalDataSourceProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$itineraryLocalDataSourceHash();

  @$internal
  @override
  $ProviderElement<ItineraryLocalDataSource> $createElement(
          $ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  ItineraryLocalDataSource create(Ref ref) {
    return itineraryLocalDataSource(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ItineraryLocalDataSource value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ItineraryLocalDataSource>(value),
    );
  }
}

String _$itineraryLocalDataSourceHash() =>
    r'1d4ab71725bc49094cdafad73a3fd33dc4321d4a';

/// Provider for itinerary repository

@ProviderFor(itineraryRepository)
const itineraryRepositoryProvider = ItineraryRepositoryProvider._();

/// Provider for itinerary repository

final class ItineraryRepositoryProvider extends $FunctionalProvider<
    ItineraryRepository,
    ItineraryRepository,
    ItineraryRepository> with $Provider<ItineraryRepository> {
  /// Provider for itinerary repository
  const ItineraryRepositoryProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'itineraryRepositoryProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$itineraryRepositoryHash();

  @$internal
  @override
  $ProviderElement<ItineraryRepository> $createElement(
          $ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  ItineraryRepository create(Ref ref) {
    return itineraryRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ItineraryRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ItineraryRepository>(value),
    );
  }
}

String _$itineraryRepositoryHash() =>
    r'4272c0dd8809f4261ac5cca29bb82e8da1133afd';

/// Provider for recommendation service

@ProviderFor(recommendationService)
const recommendationServiceProvider = RecommendationServiceProvider._();

/// Provider for recommendation service

final class RecommendationServiceProvider extends $FunctionalProvider<
    RecommendationService,
    RecommendationService,
    RecommendationService> with $Provider<RecommendationService> {
  /// Provider for recommendation service
  const RecommendationServiceProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'recommendationServiceProvider',
          isAutoDispose: true,
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
    r'2bb4fe459cb9637767929df1fd91e4377b2eff82';

/// Provider for GetPersonalizedRecommendations use case

@ProviderFor(getPersonalizedRecommendations)
const getPersonalizedRecommendationsProvider =
    GetPersonalizedRecommendationsProvider._();

/// Provider for GetPersonalizedRecommendations use case

final class GetPersonalizedRecommendationsProvider extends $FunctionalProvider<
        GetPersonalizedRecommendations,
        GetPersonalizedRecommendations,
        GetPersonalizedRecommendations>
    with $Provider<GetPersonalizedRecommendations> {
  /// Provider for GetPersonalizedRecommendations use case
  const GetPersonalizedRecommendationsProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'getPersonalizedRecommendationsProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$getPersonalizedRecommendationsHash();

  @$internal
  @override
  $ProviderElement<GetPersonalizedRecommendations> $createElement(
          $ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  GetPersonalizedRecommendations create(Ref ref) {
    return getPersonalizedRecommendations(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GetPersonalizedRecommendations value) {
    return $ProviderOverride(
      origin: this,
      providerOverride:
          $SyncValueProvider<GetPersonalizedRecommendations>(value),
    );
  }
}

String _$getPersonalizedRecommendationsHash() =>
    r'5d18d31b541130a450ea61760ee35906a77e2dcb';

/// Provider for GetRecommendationsForDate use case

@ProviderFor(getRecommendationsForDate)
const getRecommendationsForDateProvider = GetRecommendationsForDateProvider._();

/// Provider for GetRecommendationsForDate use case

final class GetRecommendationsForDateProvider extends $FunctionalProvider<
    GetRecommendationsForDate,
    GetRecommendationsForDate,
    GetRecommendationsForDate> with $Provider<GetRecommendationsForDate> {
  /// Provider for GetRecommendationsForDate use case
  const GetRecommendationsForDateProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'getRecommendationsForDateProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$getRecommendationsForDateHash();

  @$internal
  @override
  $ProviderElement<GetRecommendationsForDate> $createElement(
          $ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  GetRecommendationsForDate create(Ref ref) {
    return getRecommendationsForDate(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GetRecommendationsForDate value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GetRecommendationsForDate>(value),
    );
  }
}

String _$getRecommendationsForDateHash() =>
    r'bfe02de7b7d204c07f110e5a39a43d08ec80c0d5';

/// Provider for AddRecommendationToItinerary use case

@ProviderFor(addRecommendationToItinerary)
const addRecommendationToItineraryProvider =
    AddRecommendationToItineraryProvider._();

/// Provider for AddRecommendationToItinerary use case

final class AddRecommendationToItineraryProvider extends $FunctionalProvider<
    AddRecommendationToItinerary,
    AddRecommendationToItinerary,
    AddRecommendationToItinerary> with $Provider<AddRecommendationToItinerary> {
  /// Provider for AddRecommendationToItinerary use case
  const AddRecommendationToItineraryProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'addRecommendationToItineraryProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$addRecommendationToItineraryHash();

  @$internal
  @override
  $ProviderElement<AddRecommendationToItinerary> $createElement(
          $ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AddRecommendationToItinerary create(Ref ref) {
    return addRecommendationToItinerary(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AddRecommendationToItinerary value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AddRecommendationToItinerary>(value),
    );
  }
}

String _$addRecommendationToItineraryHash() =>
    r'9dfcbcb1b649055edfd4518ea32e287326daebd2';

/// Provider for ProvideRecommendationFeedback use case

@ProviderFor(provideRecommendationFeedback)
const provideRecommendationFeedbackProvider =
    ProvideRecommendationFeedbackProvider._();

/// Provider for ProvideRecommendationFeedback use case

final class ProvideRecommendationFeedbackProvider extends $FunctionalProvider<
        ProvideRecommendationFeedback,
        ProvideRecommendationFeedback,
        ProvideRecommendationFeedback>
    with $Provider<ProvideRecommendationFeedback> {
  /// Provider for ProvideRecommendationFeedback use case
  const ProvideRecommendationFeedbackProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'provideRecommendationFeedbackProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$provideRecommendationFeedbackHash();

  @$internal
  @override
  $ProviderElement<ProvideRecommendationFeedback> $createElement(
          $ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  ProvideRecommendationFeedback create(Ref ref) {
    return provideRecommendationFeedback(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ProvideRecommendationFeedback value) {
    return $ProviderOverride(
      origin: this,
      providerOverride:
          $SyncValueProvider<ProvideRecommendationFeedback>(value),
    );
  }
}

String _$provideRecommendationFeedbackHash() =>
    r'a279f57603d2eb6ca7688eef1089538e543d2860';

/// Provider for weather service - uses stub implementation
/// TODO: Implement actual weather service integration

@ProviderFor(weatherService)
const weatherServiceProvider = WeatherServiceProvider._();

/// Provider for weather service - uses stub implementation
/// TODO: Implement actual weather service integration

final class WeatherServiceProvider
    extends $FunctionalProvider<WeatherService, WeatherService, WeatherService>
    with $Provider<WeatherService> {
  /// Provider for weather service - uses stub implementation
  /// TODO: Implement actual weather service integration
  const WeatherServiceProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'weatherServiceProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$weatherServiceHash();

  @$internal
  @override
  $ProviderElement<WeatherService> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  WeatherService create(Ref ref) {
    return weatherService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(WeatherService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<WeatherService>(value),
    );
  }
}

String _$weatherServiceHash() => r'a869ce7c09091bbc9a31d86d8d962c9d5603b49b';

/// Provider for location service - uses implementation from core services

@ProviderFor(locationService)
const locationServiceProvider = LocationServiceProvider._();

/// Provider for location service - uses implementation from core services

final class LocationServiceProvider extends $FunctionalProvider<LocationService,
    LocationService, LocationService> with $Provider<LocationService> {
  /// Provider for location service - uses implementation from core services
  const LocationServiceProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'locationServiceProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$locationServiceHash();

  @$internal
  @override
  $ProviderElement<LocationService> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  LocationService create(Ref ref) {
    return locationService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(LocationService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<LocationService>(value),
    );
  }
}

String _$locationServiceHash() => r'd536a0768eac411321902a2124108ea5d57c837e';
