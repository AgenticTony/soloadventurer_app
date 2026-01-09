import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:soloadventurer/core/providers/core_providers.dart' show apiClientProvider, itineraryDaoProvider;
import 'package:soloadventurer/core/services/location_service.dart';
import 'package:soloadventurer/core/services/location_service_impl.dart';
import 'package:soloadventurer/core/services/weather_service.dart';
import 'package:soloadventurer/features/onboarding/domain/entities/destination.dart';
import 'package:soloadventurer/features/onboarding/domain/entities/date_range.dart';
import 'package:soloadventurer/features/travel/domain/models/weather_forecast.dart';
import 'package:soloadventurer/features/recommendations/data/datasources/itinerary_local_data_source.dart';
import 'package:soloadventurer/features/recommendations/data/datasources/itinerary_local_data_source_impl.dart';
import 'package:soloadventurer/features/recommendations/data/datasources/places_remote_data_source.dart';
import 'package:soloadventurer/features/recommendations/data/datasources/places_remote_data_source_impl.dart';
import 'package:soloadventurer/features/recommendations/data/datasources/recommendation_local_data_source.dart';
import 'package:soloadventurer/features/recommendations/data/repositories/itinerary_repository_impl.dart';
import 'package:soloadventurer/features/recommendations/data/repositories/places_repository_impl.dart';
import 'package:soloadventurer/features/recommendations/data/repositories/recommendation_repository_impl.dart';
import 'package:soloadventurer/features/recommendations/data/services/personalized_recommendation_service.dart';
import 'package:soloadventurer/features/recommendations/domain/repositories/itinerary_repository.dart';
import 'package:soloadventurer/features/recommendations/domain/repositories/places_repository.dart';
import 'package:soloadventurer/features/recommendations/domain/repositories/recommendation_repository.dart';
import 'package:soloadventurer/features/recommendations/domain/services/recommendation_service.dart';
import 'package:soloadventurer/features/recommendations/domain/usecases/add_recommendation_to_itinerary.dart';
import 'package:soloadventurer/features/recommendations/domain/usecases/dismiss_recommendation.dart';
import 'package:soloadventurer/features/recommendations/domain/usecases/get_personalized_recommendations.dart';
import 'package:soloadventurer/features/recommendations/domain/usecases/get_recommendations_for_date.dart';
import 'package:soloadventurer/features/recommendations/domain/usecases/provide_recommendation_feedback.dart';
import 'package:soloadventurer/features/recommendations/domain/usecases/save_recommendation.dart';

part 'recommendation_providers.g.dart';

/// Provider for places remote data source
///
/// Uses PlacesRemoteDataSourceImpl with ApiClient for real API calls.
/// In production, Google Places API integration should be completed.
@riverpod
PlacesRemoteDataSource placesRemoteDataSource(Ref ref) {
  final apiClient = ref.watch(apiClientProvider);
  return PlacesRemoteDataSourceImpl(apiClient);
}

/// Provider for places repository
@riverpod
PlacesRepository placesRepository(Ref ref) {
  final dataSource = ref.watch(placesRemoteDataSourceProvider);
  return PlacesRepositoryImpl(dataSource);
}

/// Provider for recommendation local data source
@riverpod
RecommendationLocalDataSource recommendationLocalDataSource(Ref ref) {
  return RecommendationLocalDataSourceImpl();
}

/// Provider for recommendation repository
@riverpod
RecommendationRepository recommendationRepository(Ref ref) {
  final dataSource = ref.watch(recommendationLocalDataSourceProvider);
  return RecommendationRepositoryImpl(dataSource);
}

/// Provider for itinerary local data source
///
/// Uses ItineraryLocalDataSourceImpl with ItineraryDao for real database operations.
@riverpod
ItineraryLocalDataSource itineraryLocalDataSource(Ref ref) {
  final itineraryDao = ref.watch(itineraryDaoProvider);
  return ItineraryLocalDataSourceImpl(itineraryDao);
}

/// Provider for itinerary repository
@riverpod
ItineraryRepository itineraryRepository(Ref ref) {
  final dataSource = ref.watch(itineraryLocalDataSourceProvider);
  return ItineraryRepositoryImpl(dataSource);
}

/// Provider for recommendation service
@riverpod
RecommendationService recommendationService(Ref ref) {
  final placesRepo = ref.watch(placesRepositoryProvider);
  final weatherService = ref.watch(weatherServiceProvider);
  final itineraryRepo = ref.watch(itineraryRepositoryProvider);
  final locationService = ref.watch(locationServiceProvider);

  return PersonalizedRecommendationService(
    placesRepo: placesRepo,
    weatherService: weatherService,
    itineraryRepo: itineraryRepo,
    locationService: locationService,
  );
}

/// Provider for GetPersonalizedRecommendations use case
@riverpod
GetPersonalizedRecommendations getPersonalizedRecommendations(Ref ref) {
  final service = ref.watch(recommendationServiceProvider);
  return GetPersonalizedRecommendations(service);
}

/// Provider for GetRecommendationsForDate use case
@riverpod
GetRecommendationsForDate getRecommendationsForDate(Ref ref) {
  final service = ref.watch(recommendationServiceProvider);
  return GetRecommendationsForDate(service);
}

/// Provider for AddRecommendationToItinerary use case
@riverpod
AddRecommendationToItinerary addRecommendationToItinerary(Ref ref) {
  final itineraryRepo = ref.watch(itineraryRepositoryProvider);
  return AddRecommendationToItinerary(itineraryRepo);
}

/// Provider for SaveRecommendation use case
///
/// Note: This provider requires manual invocation with userId parameter
/// due to limitations of @riverpod code generation with complex types.
///
/// Usage:
/// ```dart
/// final useCase = ref.read(saveRecommendationProvider);
/// final result = await useCase(userId, recommendation);
/// ```
final saveRecommendationProvider = Provider<SaveRecommendation>((ref) {
  final repository = ref.watch(recommendationRepositoryProvider);
  return SaveRecommendation(repository);
});

/// Provider for DismissRecommendation use case
///
/// Note: This provider requires manual invocation with userId parameter
/// due to limitations of @riverpod code generation with complex types.
///
/// Usage:
/// ```dart
/// final useCase = ref.read(dismissRecommendationProvider);
/// final result = await useCase(userId, recommendationId);
/// ```
final dismissRecommendationProvider = Provider<DismissRecommendation>((ref) {
  final repository = ref.watch(recommendationRepositoryProvider);
  return DismissRecommendation(repository);
});

/// Provider for ProvideRecommendationFeedback use case
@riverpod
ProvideRecommendationFeedback provideRecommendationFeedback(Ref ref) {
  final repository = ref.watch(recommendationRepositoryProvider);
  return ProvideRecommendationFeedback(repository);
}

/// Provider for weather service - uses stub implementation
/// TODO: Implement actual weather service integration
@riverpod
WeatherService weatherService(Ref ref) {
  // Stub implementation - returns empty forecasts
  return _StubWeatherService();
}

/// Stub implementation of WeatherService for development
class _StubWeatherService implements WeatherService {
  @override
  Future<List<WeatherForecast>> getForecast(
    Destination destination,
    DateRange dateRange,
  ) async {
    return [];
  }

  @override
  Future<WeatherForecast> getCurrentWeather(Destination destination) async {
    throw UnimplementedError('WeatherService not yet implemented. Use mock data for now.');
  }

  @override
  Future<bool> isWeatherAvailable(Destination destination) async {
    return false;
  }
}

/// Provider for location service - uses implementation from core services
@riverpod
LocationService locationService(Ref ref) {
  return ref.watch(locationServiceImplProvider);
}
