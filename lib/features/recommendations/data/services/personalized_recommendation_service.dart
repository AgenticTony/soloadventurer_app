import 'package:fpdart/fpdart.dart';
import 'package:uuid/uuid.dart';
import 'package:soloadventurer/core/failures/failures.dart';
import 'package:soloadventurer/core/services/location_service.dart';
import 'package:soloadventurer/core/services/weather_service.dart';
import 'package:soloadventurer/features/onboarding/domain/entities/date_range.dart';
import 'package:soloadventurer/features/onboarding/domain/entities/destination.dart';
import 'package:soloadventurer/features/onboarding/domain/entities/travel_interest.dart';
import 'package:soloadventurer/features/recommendations/domain/entities/place_activity.dart';
import 'package:soloadventurer/features/recommendations/domain/entities/recommendation.dart';
import 'package:soloadventurer/features/recommendations/domain/entities/recommendation_request.dart';
import 'package:soloadventurer/features/recommendations/domain/repositories/places_repository.dart';
import 'package:soloadventurer/features/recommendations/domain/repositories/itinerary_repository.dart';
import 'package:soloadventurer/features/recommendations/domain/services/recommendation_service.dart';
import 'package:soloadventurer/features/travel/domain/models/weather_forecast.dart';

/// Implementation of personalized recommendation service
///
/// Generates recommendations using a scoring algorithm that considers:
/// - Interest matching (40 pts)
/// - Weather fit (25 pts)
/// - User ratings (15 pts)
/// - Proximity (10 pts)
/// - Solo traveler popularity (5 pts)
/// - Availability (5 pts)
class PersonalizedRecommendationService implements RecommendationService {
  final PlacesRepository _placesRepo;
  final WeatherService _weatherService;
  final ItineraryRepository _itineraryRepo;
  final LocationService _locationService;

  PersonalizedRecommendationService({
    required PlacesRepository placesRepo,
    required WeatherService weatherService,
    required ItineraryRepository itineraryRepo,
    required LocationService locationService,
  })  : _placesRepo = placesRepo,
        _weatherService = weatherService,
        _itineraryRepo = itineraryRepo,
        _locationService = locationService;

  @override
  Future<Either<Failure, List<PersonalizedRecommendation>>>
      getPersonalizedRecommendations(
    RecommendationRequest request,
  ) async {
    final recommendations = <PersonalizedRecommendation>[];

    // 1. Get user's existing itinerary (to avoid duplicates)
    final existingItemIds = <String>{};
    if (request.excludeItineraryItems) {
      final itineraryResult =
          await _itineraryRepo.getItinerary(request.itineraryId);
      itineraryResult.fold(
        (failure) => null,
        (itinerary) {
          existingItemIds.addAll(
            itinerary.items.map((i) =>
                i.whenOrNull(
                  activity: (a) => a.name.toLowerCase(),
                  lunch: (l) => l.name.toLowerCase(),
                  dinner: (d) => d.name.toLowerCase(),
                ) ??
                ''),
          );
        },
      );
    }

    // 2. Get weather forecast for trip dates
    final weatherByDate = <DateTime, List<WeatherForecast>>{};
    for (int i = 0; i < request.tripDates.duration.inDays; i++) {
      final date = request.tripDates.start.add(Duration(days: i));
      try {
        final forecasts = await _weatherService.getForecast(
          request.destination,
          DateRange(start: date, end: date.add(const Duration(days: 1))),
        );
        if (forecasts.isNotEmpty) {
          weatherByDate[date] = forecasts;
        }
      } catch (_) {
        // Continue without weather data for this date
      }
    }

    // 3. Get places matching interests
    for (final interest in request.interests) {
      final placesResult = await _placesRepo.findPlacesByInterest(
        destination: request.destination,
        interest: interest,
        categories: request.categories,
      );

      await placesResult.fold(
        (failure) async => null,
        (places) async {
          for (final place in places) {
            // Skip if already in itinerary
            if (existingItemIds.contains(place.name.toLowerCase())) {
              continue;
            }

            // Calculate relevance score
            final score = await _calculateRelevanceScore(
              place: place,
              request: request,
              weatherByDate: weatherByDate,
            );

            // Only include high-relevance recommendations (score >= 60)
            if (score >= 60) {
              final bestDate = await _findBestDate(
                place: place,
                request: request,
                weatherByDate: weatherByDate,
              );

              final weather = weatherByDate[bestDate]?.first;
              final distance = request.hotelLocation != null
                  ? _calculateDistance(
                      request.hotelLocation!,
                      place.latitude ?? 0,
                      place.longitude ?? 0,
                    )
                  : null;

              recommendations.add(_createRecommendation(
                place: place,
                score: score,
                request: request,
                bestDate: bestDate,
                weather: weather,
                distance: distance,
              ));
            }
          }
        },
      );
    }

    // 4. Sort by relevance score and limit
    recommendations
        .sort((a, b) => b.relevanceScore.compareTo(a.relevanceScore));

    return right(recommendations.take(request.limit).toList());
  }

  @override
  Future<Either<Failure, List<PersonalizedRecommendation>>>
      getRecommendationsForDate(
    RecommendationRequest request,
    DateTime specificDate,
  ) async {
    // Get general recommendations, then filter for specific date
    final allRecommendations = await getPersonalizedRecommendations(request);

    return allRecommendations.fold(
      (failure) => left(failure),
      (recommendations) {
        final dateSpecific = recommendations.where((r) {
          return _isSameDay(r.metadata.suggestedDate, specificDate);
        }).toList();

        return right(dateSpecific);
      },
    );
  }

  @override
  Future<Either<Failure, List<PersonalizedRecommendation>>>
      getCollaborativeRecommendations({
    required String userId,
    required String destination,
    required int limit,
  }) async {
    // Placeholder for collaborative filtering
    // In production, this would query a recommendation engine
    return right([]);
  }

  @override
  Future<Either<Failure, List<PersonalizedRecommendation>>>
      getTrendingRecommendations({
    required String destination,
    required int limit,
  }) async {
    // Placeholder for trending recommendations
    // In production, this would query analytics/popularity data
    return right([]);
  }

  /// Calculates the relevance score for a place (0-100)
  Future<double> _calculateRelevanceScore({
    required PlaceActivity place,
    required RecommendationRequest request,
    required Map<DateTime, List<WeatherForecast>> weatherByDate,
  }) async {
    double score = 0.0;

    // 1. Interest Match (40 points)
    final matchedInterests = request.interests
        .where((interest) => place.category == _interestToCategory(interest))
        .toList();

    if (matchedInterests.isNotEmpty) {
      score += 40.0;
    }

    // 2. Weather Fit (25 points)
    final hasGoodWeather = weatherByDate.values
        .any((forecasts) => forecasts.any((w) => w.isGoodForOutdoors));

    if (place.isIndoor) {
      score += 25.0; // Indoor always works
    } else if (place.isOutdoor && hasGoodWeather) {
      score += 25.0;
    } else if (!place.isIndoor && hasGoodWeather) {
      score += 15.0; // Partial credit
    }

    // 3. User Ratings (15 points)
    score += (place.rating / 5.0) * 15.0;

    // 4. Proximity (10 points)
    if (request.hotelLocation != null &&
        place.latitude != null &&
        place.longitude != null) {
      final distance = _calculateDistance(
        request.hotelLocation!,
        place.latitude!,
        place.longitude!,
      );

      if (distance.inKilometers < 1) {
        score += 10.0;
      } else if (distance.inKilometers < 5) {
        score += 7.0;
      } else if (distance.inKilometers < 15) {
        score += 4.0;
      }
    }

    // 5. Popularity with Solo Travelers (5 points)
    if (place.tags.contains('solo_friendly')) {
      score += 5.0;
    }

    // 6. Availability During Trip (5 points)
    if (place.isOpenDuring(DateTimeRange(
      start: request.tripDates.start,
      end: request.tripDates.end,
    ))) {
      score += 5.0;
    }

    return score;
  }

  /// Finds the best date for an activity during the trip
  Future<DateTime> _findBestDate({
    required PlaceActivity place,
    required RecommendationRequest request,
    required Map<DateTime, List<WeatherForecast>> weatherByDate,
  }) async {
    DateTime? bestDate;
    double bestScore = -1;

    for (int i = 0; i < request.tripDates.duration.inDays; i++) {
      final date = request.tripDates.start.add(Duration(days: i));
      final weather = weatherByDate[date];

      if (weather == null || weather.isEmpty) continue;

      double dateScore = 0;

      // Prefer good weather for outdoor activities
      if (place.isOutdoor) {
        final w = weather.first;
        if (w.isGoodForOutdoors) {
          dateScore += 50;
        }
      }

      // Prefer indoor activities during bad weather
      if (place.isIndoor) {
        final w = weather.first;
        if (w.isRainy) {
          dateScore += 50;
        }
      }

      // Prefer weekdays
      if (date.weekday >= 1 && date.weekday <= 5) {
        dateScore += 10;
      }

      if (dateScore > bestScore) {
        bestScore = dateScore;
        bestDate = date;
      }
    }

    return bestDate ?? request.tripDates.start;
  }

  /// Creates a PersonalizedRecommendation from components
  PersonalizedRecommendation _createRecommendation({
    required PlaceActivity place,
    required double score,
    required RecommendationRequest request,
    required DateTime bestDate,
    required WeatherForecast? weather,
    required Distance? distance,
  }) {
    final distanceEnum = distance != null
        ? _distanceToEnum(distance.inKilometers)
        : DistanceFromHotel.mediumTrip;

    final crowdLevel = _estimateCrowdLevel(place, bestDate);

    final reasoning = _generateReasoning(
      place: place,
      request: request,
      weather: weather,
      distance: distance,
    );

    final matchedInterests = request.interests
        .where((i) => place.category == _interestToCategory(i))
        .toSet();

    return PersonalizedRecommendation(
      id: const Uuid().v4(),
      activity: place,
      metadata: RecommendationMetadata(
        matchedInterests: matchedInterests,
        suggestedDate: bestDate,
        suggestedTime: _suggestTime(place, crowdLevel),
        distance: distanceEnum,
        weather: _weatherToContext(weather),
        crowdLevel: crowdLevel,
        estimatedCost: place.cost != null
            ? Money(
                amount: place.cost!,
                currency: _getCurrency(request.destination))
            : null,
        estimatedDuration: place.estimatedDuration ?? const Duration(hours: 2),
        bookingUrl: place.bookingUrl,
        requiresAdvanceBooking: place.requiresBooking,
        isIndoor: place.isIndoor,
      ),
      reasoning: reasoning,
      relevanceScore: score,
      source: RecommendationSource.personalized,
    );
  }

  /// Generates human-readable reasoning for a recommendation
  String _generateReasoning({
    required PlaceActivity place,
    required RecommendationRequest request,
    required WeatherForecast? weather,
    required Distance? distance,
  }) {
    final reasons = <String>[];

    // Interest match
    final matchedInterest = request.interests.firstWhere(
      (i) => place.category == _interestToCategory(i),
      orElse: () => TravelInterest.photography,
    );
    reasons.add('Matches your interest in ${matchedInterest.label}');

    // Weather
    if (weather != null) {
      if (place.isIndoor && weather.isRainy) {
        reasons.add('Indoor activity (rain expected)');
      } else if (place.isOutdoor && weather.isGoodForOutdoors) {
        reasons.add('Great weather for outdoor activity');
      }
    }

    // Distance
    if (distance != null) {
      if (distance.inKilometers < 1) {
        reasons.add('Walking distance from your hotel');
      } else if (distance.inKilometers < 5) {
        reasons.add('Short trip from your hotel');
      }
    }

    // Quality
    if (place.rating >= 4.5) {
      reasons.add('Highly rated (${place.rating}⭐)');
    }

    return reasons.join(' • ');
  }

  /// Maps distance in km to enum
  DistanceFromHotel _distanceToEnum(double km) {
    if (km < 1) return DistanceFromHotel.walking;
    if (km < 5) return DistanceFromHotel.shortTrip;
    if (km < 15) return DistanceFromHotel.mediumTrip;
    return DistanceFromHotel.far;
  }

  /// Maps weather to context enum
  WeatherContext _weatherToContext(WeatherForecast? weather) {
    if (weather == null) return WeatherContext.anyWeather;
    if (weather.isRainy) return WeatherContext.indoor;
    return WeatherContext.outdoor;
  }

  /// Estimates crowd level for a place on a date
  CrowdLevel _estimateCrowdLevel(PlaceActivity place, DateTime date) {
    final isWeekend = date.weekday == 6 || date.weekday == 7;
    final isSummer = date.month >= 6 && date.month <= 8;

    if (place.isMajorTouristAttraction && (isWeekend || isSummer)) {
      return CrowdLevel.high;
    } else if (isWeekend) {
      return CrowdLevel.medium;
    } else {
      return CrowdLevel.low;
    }
  }

  /// Suggests best time to visit
  TimeOfDay _suggestTime(PlaceActivity place, CrowdLevel crowdLevel) {
    // For crowded places, suggest early morning
    if (crowdLevel == CrowdLevel.high || crowdLevel == CrowdLevel.peak) {
      return const TimeOfDay(hour: 9);
    }

    // Default morning
    return const TimeOfDay(hour: 10);
  }

  /// Maps TravelInterest to RecommendationCategory
  RecommendationCategory _interestToCategory(TravelInterest interest) {
    switch (interest) {
      case TravelInterest.food:
        return RecommendationCategory.food;
      case TravelInterest.culture:
      case TravelInterest.art:
        return RecommendationCategory.culture;
      case TravelInterest.adventure:
      case TravelInterest.nature:
        return RecommendationCategory.adventure;
      case TravelInterest.wellness:
        return RecommendationCategory.wellness;
      case TravelInterest.shopping:
        return RecommendationCategory.shopping;
      case TravelInterest.nightlife:
        return RecommendationCategory.entertainment;
      default:
        return RecommendationCategory.attraction;
    }
  }

  /// Checks if two dates are the same day
  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  /// Calculates distance between two points
  Distance _calculateDistance(
    HotelLocation from,
    double toLat,
    double toLng,
  ) {
    final meters = _locationService.distanceBetween(
      from.latitude,
      from.longitude,
      toLat,
      toLng,
    );
    return Distance(inMeters: meters);
  }

  /// Gets currency code for destination
  String _getCurrency(Destination destination) {
    // Simple mapping - in production would use country code
    if (destination.name.toLowerCase().contains('paris') ||
        destination.name.toLowerCase().contains('france')) {
      return 'EUR';
    }
    return 'USD';
  }
}

/// Helper class for distance calculations
class Distance {
  final double inMeters;

  const Distance({required this.inMeters});

  double get inKilometers => inMeters / 1000;
}
