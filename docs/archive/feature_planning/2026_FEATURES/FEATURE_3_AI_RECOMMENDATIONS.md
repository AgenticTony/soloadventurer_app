# Feature 3: AI-Personalized Recommendations

**Phase:** Phase 1 - Smart Engagement & Personalization
**Time:** 2-3 weeks
**Dependencies:** Feature 1 (Onboarding), Feature 2 (Itinerary Planner)
**Priority:** ⚡ Critical

---

## Overview

**The Core Value:** Deliver genuinely helpful, context-aware suggestions that feel like a knowledgeable local friend — not algorithmic manipulation.

**Why This Works:**
- Recommendations based on trip context (destination, dates, interests, weather)
- Time-based suggestions ("For May 14: Jazz night at 8 PM")
- Local tips that add value ("Canal cruise - best at sunset")
- One-tap to add to itinerary
- Transparent reasoning (explain WHY this was recommended)

**Success Metric:** 30%+ of recommendations added to itinerary; users tap "See more recommendations"

---

## UI Wireframes

### Recommendations Home Screen

```
+------------------------------------------------+
|  ✨ Recommendations                             |
|  ←                                             |
+------------------------------------------------+
|                                                |
|  For your Paris trip (May 11-18)               |
|  Based on: Food, Culture, Art                  |
|                                                |
|  🌆 Right Now (Suggested for Today)            |
|  ┌──────────────────────────────────────────┐  |
|  │ 🎨 Musée d'Orsay                          │  │
|  │    Left Bank masterpieces                 │  │
|  │    ⭐ 4.8 (12,340 reviews)                │  │
|  │    💡 Best visited: Morning (less crowds)│  │
|  │    📍 1.2 km from your hotel             │  │
|  │    [Add to Itinerary] [Details]           │  │
|  └──────────────────────────────────────────┘  |
|                                                |
|  🗓️ For Tomorrow (May 12)                      |
|  ┌──────────────────────────────────────────┐  |
|  │ 🎭 Jazz Night at Duc des Lombards         │  │
|  │    Live jazz every Tuesday                │  │
|  │    ⏰ 8:00 PM start                       │  │
|  │    ⚠️ Limited spots - book ahead          │  │
|  │    [Add to Itinerary] [Details]           │  │
|  └──────────────────────────────────────────┘  |
|                                                |
|  🌧️ Indoor Options (Rain expected Wednesday)  |
|  ┌──────────────────────────────────────────┐  |
|  │ ☕ Café de Flore                          │  │
|  │    Historic literary café                 │  │
|  │    Perfect for rainy afternoon            │  │
|  │    [Add to Itinerary] [Details]           │  │
|  └──────────────────────────────────────────┘  |
|                                                |
|  [See More Recommendations →]                  |
+------------------------------------------------+
```

### Recommendation Detail Modal

```
+------------------------------------------------+
|  ← Musée d'Orsay                  [Save] [Share]|
+------------------------------------------------+
|                                                |
|  [Photo Gallery - Swipe to view]               |
|                                                |
|  🎨 World-Class Impressionist Art              |
|                                                |
|  ⭐ 4.8 (12,340 reviews)  🏛️ Museum            |
|                                                |
|  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━      |
|                                                |
|  💡 Why we recommended this:                   |
|  • Matches your interest in Art                |
|  • Indoor activity (good for any weather)      |
|  • Near your hotel (easy to get to)            |
|  • Open tomorrow 9:30 AM - 6:00 PM              |
|                                                |
|  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━      |
|                                                |
|  📝 About                                      |
|  Home to Van Gogh's Starry Night, Monet's      |
|  Water Lilies, and the world's largest         |
|  collection of Impressionist works.            |
|                                                |
|  ⏰ Suggested Time: 2-3 hours                  |
|  🎫 Book tickets: €16 (skip-the-line €20)      |
|  📍 1.2 km from hotel • 15 min walk            |
|                                                |
|  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━      |
|                                                |
|  👤 Tips from locals:                          |
|  "Go early morning (9:30 AM) or late evening   |
|   (after 5 PM) to avoid crowds" - Marie, local  |
|                                                |
|  "Don't miss the clock room on the 5th floor"  |
|   - Jean, frequent visitor                     |
|                                                |
|  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━      |
|                                                |
|  📅 Availability:                              |
|   • Tomorrow (May 12): Open 9:30 AM - 6:00 PM  |
|  • Wednesday (May 13): Open 9:30 AM - 9:45 PM  |
|  • Thursday (May 14): Open 9:30 AM - 6:00 PM   |
|                                                |
|  [Add to Itinerary]                            |
|  [View on Map] [Get Directions]                |
+------------------------------------------------+
```

### Recommendations Filter/Sort

```
+------------------------------------------------+
|  Filter & Sort                          [Reset] |
+------------------------------------------------+
|                                                |
|  Sort by:                                      |
|  ◉ Best Match for You                          |
|  ○ Highest Rated                              |
|  ○ Closest to Your Hotel                       |
|  ○ Least Crowded (right now)                   |
|                                                |
|  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━      |
|                                                |
|  Categories (Your Interests):                  |
|  ☑ Food & Cuisine (24)                         |
|  ☑ Culture & History (18)                      |
|  ☑ Art & Museums (15)                          |
|  ☐ Adventure & Outdoors (12)                   |
|  ☐ Wellness & Relaxation (8)                   |
|                                                |
|  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━      |
|                                                |
|  Price Range:                                  |
|  ◉ Any                                         |
|  ○ Free                                        |
|  ○ Under €20                                   |
|  ○ €20 - €50                                   |
|  ○ €50+                                        |
|                                                |
|  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━      |
|                                                |
|  Weather Preference:                           |
|  ◉ Any (Smart recommendations based on weather)|
|  ☐ Indoor Only                                |
|  ☐ Outdoor Preferably                          |
|                                                |
|  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━      |
|                                                |
|  Distance from Your Hotel:                     |
|  ◉ Any                                        |
|  ○ Walking (<1 km)                             |
|  ○ Short Trip (<5 km)                          |
|  ○ Any Distance                                |
|                                                |
|  [Apply Filters]              [Show 54 results] |
+------------------------------------------------+
```

### "Why Recommended" Explanation

```
+------------------------------------------------+
|  💡 Why We Recommended This                    |
+------------------------------------------------+
|                                                |
|  Musée d'Orsay scored 92/100 for you because:  |
|                                                |
|  ✓ Interest Match (40 pts)                     |
|    You love Art & Museums                      |
|                                                |
|  ✓ Weather Fit (25 pts)                        |
|    Indoor (great for any weather)              |
|                                                |
|  ✓ Location Convenience (15 pts)               |
|    1.2 km from your hotel                      |
|                                                |
|  ✓ Quality (12 pts)                            |
|    ⭐ 4.8 rating from 12,340 reviews            |
|                                                |
|  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━      |
|                                                |
|  Other factors considered:                     |
|  • Not currently in your itinerary             |
|  • Open during your trip dates                 |
|  • Fits your time availability                 |
|  • Popular with solo travelers                 |
|                                                |
|  [Not Interested]  [See Similar Options]       |
+------------------------------------------------+
```

---

## Architecture

### Domain Layer

```dart
// lib/features/recommendations/domain/entities/recommendation.dart
@freezed
class Recommendation with _$Recommendation {
  const factory Recommendation({
    required String id,
    required PlaceActivity activity,
    required RecommendationMetadata metadata,
    required String reasoning,
    required double relevanceScore,
    @Default(RecommendationSource.personalized) RecommendationSource source,
    @Default(false) bool isSaved,
    @Default(false) bool isAddedToItinerary,
  }) = _Recommendation;

  const Recommendation._();
}

@freezed
class RecommendationMetadata with _$RecommendationMetadata {
  const factory RecommendationMetadata({
    required Set<TravelInterest> matchedInterests,
    required DateTime suggestedDate,
    required TimeOfDay suggestedTime,
    required DistanceFromHotel distance,
    required WeatherContext weather,
    required CrowdLevel crowdLevel,
    required Money? estimatedCost,
    @Default(Duration.zero) Duration estimatedDuration,
    String? bookingUrl,
    @Default(false) bool requiresAdvanceBooking,
    @Default(false) bool isIndoor,
  }) = _RecommendationMetadata;
}

enum RecommendationSource {
  personalized,  // AI-generated based on user profile
  collaborative, // "Travelers like you also enjoyed"
  trending,      // Popular right now at destination
  local,         // Local tips/expert curated
  contextual,    // Based on current location/time
}

enum DistanceFromHotel {
  walking,   // <1 km
  shortTrip, // 1-5 km
  mediumTrip,// 5-15 km
  far,       // >15 km
}

enum WeatherContext {
  anyWeather,   // Works in any weather
  indoor,       // Indoor activity
  outdoor,      // Best in good weather
  weatherDependent, // Better in specific weather
}

enum CrowdLevel {
  low,      // Not crowded
  medium,   // Moderate crowds
  high,     // Expect crowds
  peak,     // Very crowded
}

// lib/features/recommendations/domain/entities/recommendation_request.dart
@freezed
class RecommendationRequest with _$RecommendationRequest {
  const factory RecommendationRequest({
    required String itineraryId,
    required Destination destination,
    required DateRange tripDates,
    required Set<TravelInterest> interests,
    GeoPoint? hotelLocation,
    BudgetRange? budget,
    Set<RecommendationCategory>? categories,
    Set<WeatherContext>? weatherPreference,
    DistanceFromHotel? maxDistance,
    @Default(20) int limit,
    @Default(false) bool excludeItineraryItems,
  }) = _RecommendationRequest;
}

enum RecommendationCategory {
  food,
  attraction,
  activity,
  entertainment,
  shopping,
  wellness,
  culture,
  adventure,
}

// lib/features/recommendations/domain/usecases/
class GetPersonalizedRecommendations {
  final RecommendationService _service;

  GetPersonalizedRecommendations(this._service);

  Future<Either<Failure, List<Recommendation>>> call(
    RecommendationRequest request,
  ) async {
    return await _service.getPersonalizedRecommendations(request);
  }
}

class GetRecommendationsForDate {
  final RecommendationService _service;

  GetRecommendationsForDate(this._service);

  Future<Either<Failure, List<Recommendation>>> call({
    required RecommendationRequest request,
    required DateTime specificDate,
  }) async {
    return await _service.getRecommendationsForDate(
      request,
      specificDate,
    );
  }
}

class SaveRecommendation {
  final RecommendationRepository _repository;

  SaveRecommendation(this._repository);

  Future<Either<Failure, Recommendation>> call(
    Recommendation recommendation,
  ) async {
    return await _repository.saveRecommendation(recommendation);
  }
}

class DismissRecommendation {
  final RecommendationRepository _repository;

  DismissRecommendation(this._repository);

  Future<Either<Failure, Unit>> call(String recommendationId) async {
    return await _repository.dismissRecommendation(recommendationId);
  }
}

class AddRecommendationToItinerary {
  final ItineraryRepository _itineraryRepo;

  AddRecommendationToItinerary(this._itineraryRepo);

  Future<Either<Failure, ItineraryItem>> call({
    required String itineraryId,
    required Recommendation recommendation,
    required DateTime scheduledAt,
  }) async {
    final item = _convertToItineraryItem(recommendation, scheduledAt);
    return await _itineraryRepo.addItem(itineraryId, item);
  }

  ItineraryItem _convertToItineraryItem(
    Recommendation recommendation,
    DateTime scheduledAt,
  ) {
    return ItineraryItem.activity(
      id: uuid.v4(),
      scheduledAt: scheduledAt,
      type: _mapActivityType(recommendation.activity.category),
      name: recommendation.activity.name,
      description: recommendation.activity.description,
      estimatedDuration: recommendation.metadata.estimatedDuration,
      bookingUrl: recommendation.metadata.bookingUrl,
      cost: recommendation.metadata.estimatedCost,
      tags: recommendation.activity.tags.toList(),
      location: recommendation.activity.location,
      requiresAdvanceBooking: recommendation.metadata.requiresAdvanceBooking,
    );
  }

  ActivityType _mapActivityType(RecommendationCategory category) {
    switch (category) {
      case RecommendationCategory.attraction:
      case RecommendationCategory.culture:
        return ActivityType.attraction;
      case RecommendationCategory.activity:
      case RecommendationCategory.adventure:
        return ActivityType.outdoor;
      case RecommendationCategory.entertainment:
        return ActivityType.entertainment;
      case RecommendationCategory.wellness:
        return ActivityType.wellness;
      case RecommendationCategory.shopping:
        return ActivityType.shopping;
      case RecommendationCategory.food:
        return ActivityType.attraction; // Food as activity, not meal
    }
  }
}

class ProvideRecommendationFeedback {
  final RecommendationRepository _repository;

  ProvideRecommendationFeedback(this._repository);

  Future<Either<Failure, Unit>> call({
    required String recommendationId,
    required RecommendationFeedback feedback,
  }) async {
    return await _repository.recordFeedback(
      recommendationId,
      feedback,
    );
  }
}

enum RecommendationFeedback {
  helpful,
  notHelpful,
  notInterested,
  alreadyDone,
  inaccurate,
}
```

### Data Layer - Services

```dart
// lib/features/recommendations/data/services/personalized_recommendation_service.dart
class PersonalizedRecommendationService implements RecommendationService {
  final PlacesRepository _placesRepo;
  final WeatherService _weatherService;
  final UserProfileService _userProfileService;
  final ItineraryRepository _itineraryRepo;
  final LocationService _locationService;

  PersonalizedRecommendationService({
    required PlacesRepository placesRepo,
    required WeatherService weatherService,
    required UserProfileService userProfileService,
    required ItineraryRepository itineraryRepo,
    required LocationService locationService,
  })  : _placesRepo = placesRepo,
        _weatherService = weatherService,
        _userProfileService = userProfileService,
        _itineraryRepo = itineraryRepo,
        _locationService = locationService;

  @override
  Future<Either<Failure, List<Recommendation>>> getPersonalizedRecommendations(
    RecommendationRequest request,
  ) async {
    final recommendations = <Recommendation>[];

    // 1. Get user's existing itinerary (to avoid duplicates)
    final existingItemIds = <String>{};
    if (request.excludeItineraryItems) {
      final itineraryResult = await _itineraryRepo.getItinerary(request.itineraryId);
      itineraryResult.fold(
        (failure) => null,
        (itinerary) {
          existingItemIds.addAll(
            itinerary.items.map((i) => i.whenOrNull(
              activity: (a) => a.name.toLowerCase(),
              restaurant: (r) => r.name.toLowerCase(),
            ) ?? ''),
          );
        },
      );
    }

    // 2. Get weather forecast for trip dates
    final weatherByDate = <DateTime, List<WeatherForecast>>{};
    for (int i = 0; i < request.tripDates.duration.inDays; i++) {
      final date = request.tripDates.start.add(Duration(days: i));
      final weatherResult = await _weatherService.getForecast(
        request.destination,
        DateRange(start: date, end: date.add(Duration(days: 1))),
      );
      weatherResult.fold(
        (failure) => null,
        (forecasts) => weatherByDate[date] = forecasts,
      );
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

            // Only include high-relevance recommendations
            if (score >= 60) {
              final bestDate = await _findBestDate(
                place: place,
                request: request,
                weatherByDate: weatherByDate,
              );

              recommendations.add(_createRecommendation(
                place: place,
                score: score,
                request: request,
                bestDate: bestDate,
                weather: weatherByDate[bestDate]?.first,
                distance: request.hotelLocation != null
                    ? await _locationService.calculateDistance(
                        request.hotelLocation!,
                        place.location ?? GeoPoint(0, 0),
                      )
                    : null,
              ));
            }
          }
        },
      );
    }

    // 4. Sort by relevance score and limit
    recommendations.sort((a, b) => b.relevanceScore.compareTo(a.relevanceScore));

    return right(recommendations.take(request.limit).toList());
  }

  @override
  Future<Either<Failure, List<Recommendation>>> getRecommendationsForDate(
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

  Future<double> _calculateRelevanceScore({
    required PlaceActivity place,
    required RecommendationRequest request,
    required Map<DateTime, List<WeatherForecast>> weatherByDate,
  }) async {
    double score = 0.0;

    // 1. Interest Match (40 points)
    final matchedInterests = request.interests.where((interest) =>
      place.category == _interestToCategory(interest)
    ).toList();

    if (matchedInterests.isNotEmpty) {
      score += 40.0;
    }

    // 2. Weather Fit (25 points)
    final hasBadWeather = weatherByDate.values.any((forecasts) =>
      forecasts.any((w) => w.precipitation > 0.5 || w.temperature > 35)
    );

    if (place.isIndoor && hasBadWeather) {
      score += 25.0;
    } else if (place.isOutdoor && !hasBadWeather) {
      score += 25.0;
    } else if (!place.isIndoor && !hasBadWeather) {
      score += 15.0; // Partial credit
    }

    // 3. User Ratings (15 points)
    score += (place.rating / 5.0) * 15.0;

    // 4. Proximity (10 points)
    if (request.hotelLocation != null && place.location != null) {
      final distance = await _locationService.calculateDistance(
        request.hotelLocation!,
        place.location!,
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
    if (place.isOpenDuring(request.tripDates)) {
      score += 5.0;
    }

    return score;
  }

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
        if (w.precipitation < 0.2 && w.temperature >= 15 && w.temperature <= 28) {
          dateScore += 50;
        }
      }

      // Prefer indoor activities during bad weather
      if (place.isIndoor) {
        final w = weather.first;
        if (w.precipitation > 0.5 || w.temperature > 30 || w.temperature < 10) {
          dateScore += 50;
        }
      }

      // Avoid peak days (optional - could add day_of_week preference)
      if (date.weekday >= 1 && date.weekday <= 5) {
        dateScore += 10; // Prefer weekdays
      }

      if (dateScore > bestScore) {
        bestScore = dateScore;
        bestDate = date;
      }
    }

    return bestDate ?? request.tripDates.start;
  }

  Recommendation _createRecommendation({
    required PlaceActivity place,
    required double score,
    required RecommendationRequest request,
    required DateTime bestDate,
    required WeatherForecast? weather,
    required Distance? distance,
  }) {
    final distanceEnum = distance != null
        ? _distanceToEnum(distance.inKilometers)
        : null;

    final crowdLevel = _estimateCrowdLevel(place, bestDate);

    final reasoning = _generateReasoning(
      place: place,
      request: request,
      weather: weather,
      distance: distance,
    );

    return Recommendation(
      id: uuid.v4(),
      activity: place,
      metadata: RecommendationMetadata(
        matchedInterests: request.interests
            .where((i) => place.category == _interestToCategory(i))
            .toSet(),
        suggestedDate: bestDate,
        suggestedTime: _suggestTime(place, crowdLevel),
        distance: distanceEnum ?? DistanceFromHotel.mediumTrip,
        weather: _weatherToContext(weather),
        crowdLevel: crowdLevel,
        estimatedCost: place.cost,
        estimatedDuration: place.estimatedDuration ?? Duration(hours: 2),
        bookingUrl: place.bookingUrl,
        requiresAdvanceBooking: place.requiresBooking,
        isIndoor: place.isIndoor,
      ),
      reasoning: reasoning,
      relevanceScore: score,
      source: RecommendationSource.personalized,
    );
  }

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
      if (place.isIndoor && weather.precipitation > 0.5) {
        reasons.add('Indoor activity (rain expected)');
      } else if (place.isOutdoor && weather.precipitation < 0.2) {
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

  DistanceFromHotel _distanceToEnum(double km) {
    if (km < 1) return DistanceFromHotel.walking;
    if (km < 5) return DistanceFromHotel.shortTrip;
    if (km < 15) return DistanceFromHotel.mediumTrip;
    return DistanceFromHotel.far;
  }

  WeatherContext _weatherToContext(WeatherForecast? weather) {
    if (weather == null) return WeatherContext.anyWeather;
    if (weather.precipitation > 0.5) return WeatherContext.indoor;
    return WeatherContext.outdoor;
  }

  CrowdLevel _estimateCrowdLevel(PlaceActivity place, DateTime date) {
    // Simple heuristic - could be enhanced with real data
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

  TimeOfDay _suggestTime(PlaceActivity place, CrowdLevel crowdLevel) {
    // For crowded places, suggest early morning or late afternoon
    if (crowdLevel == CrowdLevel.high || crowdLevel == CrowdLevel.peak) {
      return TimeOfDay(hour: 9, minute: 0);
    }

    // Default morning
    return TimeOfDay(hour: 10, minute: 0);
  }

  RecommendationCategory _interestToCategory(TravelInterest interest) {
    switch (interest) {
      case TravelInterest.food:
        return RecommendationCategory.food;
      case TravelInterest.culture:
      case TravelInterest.art:
        return RecommendationCategory.culture;
      case TravelInterest.adventure:
        return RecommendationCategory.adventure;
      case TravelInterest.wellness:
        return RecommendationCategory.wellness;
      default:
        return RecommendationCategory.attraction;
    }
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
           date1.month == date2.month &&
           date1.day == date2.day;
  }
}

// lib/features/recommendations/data/services/collaborative_filtering_service.dart
class CollaborativeFilteringService {
  final UserBehaviorRepository _behaviorRepo;
  final PlacesRepository _placesRepo;

  CollaborativeFilteringService({
    required UserBehaviorRepository behaviorRepo,
    required PlacesRepository placesRepo,
  })  : _behaviorRepo = behaviorRepo,
        _placesRepo = placesRepo;

  Future<List<PlaceActivity>> findSimilarUsersRecommendations({
    required String userId,
    required Destination destination,
    required int limit,
  }) async {
    // 1. Find users with similar preferences
    final similarUsers = await _findSimilarUsers(userId, destination);

    // 2. Get places they liked at this destination
    final likedPlaces = <PlaceActivity>[];
    for (final similarUser in similarUsers) {
      final userLikes = await _behaviorRepo.getUserLikes(
        similarUser.id,
        destination,
      );
      likedPlaces.addAll(userLikes);
    }

    // 3. Rank by frequency and rating
    final placeScores = <String, int>{};
    for (final place in likedPlaces) {
      placeScores[place.id] = (placeScores[place.id] ?? 0) + 1;
    }

    // 4. Return top places
    final sortedPlaces = likedPlaces.toList()
      ..sort((a, b) {
        final scoreA = placeScores[a.id] ?? 0;
        final scoreB = placeScores[b.id] ?? 0;
        return scoreB.compareTo(scoreA);
      });

    return sortedPlaces.take(limit).toList();
  }

  Future<List<UserProfile>> _findSimilarUsers(
    String userId,
    Destination destination,
  ) async {
    final currentUser = await _behaviorRepo.getUserProfile(userId);

    // Simple similarity: users with overlapping interests at same destination
    final allUsersAtDestination = await _behaviorRepo.getUsersAtDestination(destination);

    final similar = <UserProfile>[];
    for (final user in allUsersAtDestination) {
      if (user.id == userId) continue;

      final overlap = _calculateInterestOverlap(
        currentUser.interests,
        user.interests,
      );

      if (overlap >= 0.3) {
        // At least 30% interest overlap
        similar.add(user);
      }
    }

    return similar;
  }

  double _calculateInterestOverlap(
    Set<TravelInterest> user1,
    Set<TravelInterest> user2,
  ) {
    if (user1.isEmpty || user2.isEmpty) return 0.0;

    final intersection = user1.intersection(user2).length;
    final union = user1.union(user2).length;

    return intersection / union;
  }
}
```

### Presentation Layer

```dart
// lib/features/recommendations/presentation/screens/recommendations_screen.dart
class RecommendationsScreen extends ConsumerStatefulWidget {
  final String itineraryId;

  const RecommendationsScreen({
    required this.itineraryId,
    super.key,
  });

  @override
  ConsumerState<RecommendationsScreen> createState() =>
      _RecommendationsScreenState();
}

class _RecommendationsScreenState
    extends ConsumerState<RecommendationsScreen> {
  RecommendationFilter _filter = RecommendationFilter.defaultFilter();
  bool _showFilters = false;

  @override
  void initState() {
    super.initState();
    // Load recommendations immediately
    Future.microtask(() =>
      ref.invalidate(recommendationsProvider(widget.itineraryId))
    );
  }

  @override
  Widget build(BuildContext context) {
    final recommendationsAsync = ref.watch(
      recommendationsProvider(widget.itineraryId),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text('✨ Recommendations'),
        actions: [
          IconButton(
            icon: Icon(_showFilters ? Icons.filter_list_off : Icons.filter_list),
            onPressed: () {
              setState(() => _showFilters = !_showFilters);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          if (_showFilters) _buildFilterPanel(),

          // Context header
          _buildContextHeader(),

          // Recommendations list
          Expanded(
            child: recommendationsAsync.when(
              data: (recommendations) {
                if (recommendations.isEmpty) {
                  return _buildEmptyState();
                }
                return _buildRecommendationsList(recommendations);
              },
              loading: () => Center(child: CircularProgressIndicator()),
              error: (error, stack) => ErrorWidget(error),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContextHeader() {
    final itineraryAsync = ref.watch(itineraryProvider(widget.itineraryId));

    return Container(
      padding: EdgeInsets.all(16),
      color: Theme.of(context).colorScheme.surfaceVariant,
      child: itineraryAsync.when(
        data: (itinerary) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'For your ${itinerary.destination.name} trip',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            SizedBox(height: 4),
            Text(
              '${_formatDateRange(itinerary.dateRange)} • '
              '${itinerary.getInterestsDisplay()}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[700],
                  ),
            ),
          ],
        ),
        loading: () => Container(),
        error: (_, __) => Container(),
      ),
    );
  }

  Widget _buildFilterPanel() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          bottom: BorderSide(color: Theme.of(context).dividerColor),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Filter & Sort',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              TextButton(
                onPressed: () {
                  setState(() => _filter = RecommendationFilter.defaultFilter());
                },
                child: Text('Reset'),
              ),
            ],
          ),
          SizedBox(height: 12),

          // Sort options
          SegmentedButton<RecommendationSort>(
            segments: [
              ButtonSegment(
                value: RecommendationSort.bestMatch,
                label: Text('Best Match'),
              ),
              ButtonSegment(
                value: RecommendationSort.highestRated,
                label: Text('Top Rated'),
              ),
              ButtonSegment(
                value: RecommendationSort.closest,
                label: Text('Closest'),
              ),
            ],
            selected: {_filter.sort},
            onSelectionChanged: (set) {
              setState(() => _filter = _filter.copyWith(sort: set.first));
            },
          ),
          SizedBox(height: 16),

          // Interest filters
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: TravelInterest.values.map((interest) {
              final isSelected = _filter.interests.contains(interest);
              return FilterChip(
                label: Text('${interest.emoji} ${interest.label}'),
                selected: isSelected,
                onSelected: (selected) {
                  final updated = Set<TravelInterest>.from(_filter.interests);
                  if (selected) {
                    updated.add(interest);
                  } else {
                    updated.remove(interest);
                  }
                  setState(() => _filter = _filter.copyWith(interests: updated));
                },
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendationsList(List<Recommendation> recommendations) {
    final filtered = _filter.apply(recommendations);

    if (filtered.isEmpty) {
      return _buildNoResultsState();
    }

    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        final recommendation = filtered[index];
        return RecommendationCard(
          recommendation: recommendation,
          onTap: () => _showRecommendationDetail(context, recommendation),
          onAdd: () => _addToItinerary(context, recommendation),
          onSave: () => _saveRecommendation(context, recommendation),
          onDismiss: () => _dismissRecommendation(context, recommendation),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.lightbulb_outline, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'No recommendations yet',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          SizedBox(height: 8),
          Text(
            'Complete your onboarding to get personalized suggestions',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildNoResultsState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'No matches for your filters',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          SizedBox(height: 8),
          Text(
            'Try adjusting your filter criteria',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
        ],
      ),
    );
  }

  void _showRecommendationDetail(
    BuildContext context,
    Recommendation recommendation,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => RecommendationDetailSheet(
        recommendation: recommendation,
        itineraryId: widget.itineraryId,
        onAdd: () => _addToItinerary(context, recommendation),
      ),
    );
  }

  Future<void> _addToItinerary(
    BuildContext context,
    Recommendation recommendation,
  ) async {
    // Show date picker
    final scheduledAt = await showModalBottomSheet<DateTime>(
      context: context,
      builder: (context) => ScheduleRecommendationSheet(
        recommendation: recommendation,
      ),
    );

    if (scheduledAt == null) return;

    final result = await ref.read(
      addRecommendationToItineraryProvider(
        itineraryId: widget.itineraryId,
        recommendation: recommendation,
        scheduledAt: scheduledAt,
      ).future,
    );

    result.fold(
      (failure) => _showError(context, failure),
      (_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Added to your itinerary!')),
        );
        ref.invalidate(itineraryProvider(widget.itineraryId));
      },
    );
  }

  Future<void> _saveRecommendation(
    BuildContext context,
    Recommendation recommendation,
  ) async {
    final result = await ref.read(
      saveRecommendationProvider(recommendation).future,
    );

    result.fold(
      (failure) => _showError(context, failure),
      (_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Saved for later')),
        );
      },
    );
  }

  Future<void> _dismissRecommendation(
    BuildContext context,
    Recommendation recommendation,
  ) async {
    final result = await ref.read(
      dismissRecommendationProvider(recommendation.id).future,
    );

    result.fold(
      (failure) => _showError(context, failure),
      (_) {
        ref.invalidate(recommendationsProvider(widget.itineraryId));
      },
    );
  }

  void _showError(BuildContext context, Failure failure) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(failure.toString())),
    );
  }

  String _formatDateRange(DateRange range) {
    return '${DateFormat.MMMd().format(range.start)} - '
           '${DateFormat.MMMd().format(range.end)}';
  }
}

// lib/features/recommendations/presentation/widgets/recommendation_card.dart
class RecommendationCard extends StatelessWidget {
  final Recommendation recommendation;
  final VoidCallback onTap;
  final VoidCallback onAdd;
  final VoidCallback onSave;
  final VoidCallback onDismiss;

  const RecommendationCard({
    required this.recommendation,
    required this.onTap,
    required this.onAdd,
    required this.onSave,
    required this.onDismiss,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(bottom: 12),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            if (recommendation.activity.images.isNotEmpty)
              CachedNetworkImage(
                imageUrl: recommendation.activity.images.first,
                height: 180,
                width: double.infinity,
                fit: BoxFit.cover,
                placeholder: (_, __) => Container(
                  height: 180,
                  color: Colors.grey[200],
                  child: Center(child: CircularProgressIndicator()),
                ),
                errorWidget: (_, __, ___) => Container(
                  height: 180,
                  color: Colors.grey[200],
                  child: Icon(Icons.broken_image, size: 48),
                ),
              ),

            // Content
            Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title and rating
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          recommendation.activity.name,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: _getScoreColor(recommendation.relevanceScore),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${recommendation.relevanceScore.toInt()}% match',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),

                  // Rating and reviews
                  Row(
                    children: [
                      Icon(Icons.star, color: Colors.amber, size: 16),
                      SizedBox(width: 4),
                      Text(
                        recommendation.activity.rating.toStringAsFixed(1),
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      SizedBox(width: 8),
                      Text(
                        '(${_formatCount(recommendation.activity.reviewCount)} reviews)',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey[600],
                            ),
                      ),
                      Spacer(),
                      if (recommendation.metadata.requiresAdvanceBooking)
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.orange[100],
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'Book ahead',
                            style: TextStyle(
                              color: Colors.orange[800],
                              fontSize: 11,
                            ),
                          ),
                        ),
                    ],
                  ),
                  SizedBox(height: 12),

                  // Reasoning
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceVariant,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.lightbulb_outline, size: 20),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            recommendation.reasoning,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 12),

                  // Metadata chips
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildMetadataChip(
                        context,
                        Icons.calendar_today,
                        DateFormat.MMMd().format(recommendation.metadata.suggestedDate),
                      ),
                      _buildMetadataChip(
                        context,
                        _getDistanceIcon(recommendation.metadata.distance),
                        _getDistanceText(recommendation.metadata.distance),
                      ),
                      _buildMetadataChip(
                        context,
                        _getWeatherIcon(recommendation.metadata.weather),
                        _getWeatherText(recommendation.metadata.weather),
                      ),
                      if (recommendation.metadata.estimatedDuration != Duration.zero)
                        _buildMetadataChip(
                          context,
                          Icons.schedule,
                          _formatDuration(recommendation.metadata.estimatedDuration),
                        ),
                    ],
                  ),

                  // Actions
                  SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: onAdd,
                          icon: Icon(Icons.add),
                          label: Text('Add to Itinerary'),
                        ),
                      ),
                      SizedBox(width: 8),
                      IconButton.outlined(
                        onPressed: onSave,
                        icon: Icon(Icons.bookmark_outline),
                      ),
                      IconButton.outlined(
                        onPressed: onDismiss,
                        icon: Icon(Icons.close),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetadataChip(BuildContext context, IconData icon, String text) {
    return Chip(
      avatar: Icon(icon, size: 16),
      label: Text(text),
      visualDensity: VisualDensity.compact,
    );
  }

  Color _getScoreColor(double score) {
    if (score >= 80) return Colors.green;
    if (score >= 60) return Colors.blue;
    if (score >= 40) return Colors.orange;
    return Colors.grey;
  }

  IconData _getDistanceIcon(DistanceFromHotel distance) {
    switch (distance) {
      case DistanceFromHotel.walking:
        return Icons.directions_walk;
      case DistanceFromHotel.shortTrip:
        return Icons.directions_transit;
      case DistanceFromHotel.mediumTrip:
        return Icons.directions_car;
      case DistanceFromHotel.far:
        return Icons.flight;
    }
  }

  String _getDistanceText(DistanceFromHotel distance) {
    switch (distance) {
      case DistanceFromHotel.walking:
        return 'Walking distance';
      case DistanceFromHotel.shortTrip:
        return 'Short trip';
      case DistanceFromHotel.mediumTrip:
        return 'Medium trip';
      case DistanceFromHotel.far:
        return 'Far';
    }
  }

  IconData _getWeatherIcon(WeatherContext weather) {
    switch (weather) {
      case WeatherContext.indoor:
        return Icons.home;
      case WeatherContext.outdoor:
        return Icons.wb_sunny;
      case WeatherContext.anyWeather:
        return Icons.cloud;
      case WeatherContext.weatherDependent:
        return Icons.cloud_queue;
    }
  }

  String _getWeatherText(WeatherContext weather) {
    switch (weather) {
      case WeatherContext.indoor:
        return 'Indoor';
      case WeatherContext.outdoor:
        return 'Outdoor';
      case WeatherContext.anyWeather:
        return 'Any weather';
      case WeatherContext.weatherDependent:
        return 'Weather dependent';
    }
  }

  String _formatCount(int count) {
    if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}k';
    }
    return count.toString();
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;

    if (hours > 0 && minutes > 0) {
      return '${hours}h ${minutes}m';
    } else if (hours > 0) {
      return '${hours}h';
    } else {
      return '${minutes}m';
    }
  }
}

// lib/features/recommendations/presentation/widgets/recommendation_detail_sheet.dart
class RecommendationDetailSheet extends StatelessWidget {
  final Recommendation recommendation;
  final String itineraryId;
  final VoidCallback onAdd;

  const RecommendationDetailSheet({
    required this.recommendation,
    required this.itineraryId,
    required this.onAdd,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: CustomScrollView(
            controller: scrollController,
            slivers: [
              // Header
              SliverAppBar(
                expandedHeight: 250,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(recommendation.activity.name),
                  background: recommendation.activity.images.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: recommendation.activity.images.first,
                          fit: BoxFit.cover,
                        )
                      : Container(
                          color: Theme.of(context).colorScheme.primaryContainer,
                          child: Icon(Icons.attractions, size: 64),
                        ),
                ),
                actions: [
                  IconButton(
                    icon: Icon(Icons.bookmark_outline),
                    onPressed: () {
                      // Save for later
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.share),
                    onPressed: () {
                      // Share
                    },
                  ),
                ],
              ),

              // Content
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Quick stats
                      _buildQuickStats(context),
                      SizedBox(height: 16),

                      // Why recommended section
                      _buildWhyRecommendedSection(context),
                      SizedBox(height: 16),

                      // About section
                      _buildAboutSection(context),
                      SizedBox(height: 16),

                      // Local tips
                      _buildLocalTipsSection(context),
                      SizedBox(height: 16),

                      // Availability
                      _buildAvailabilitySection(context),
                      SizedBox(height: 24),

                      // Action buttons
                      _buildActionButtons(context),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildQuickStats(BuildContext context) {
    return Row(
      children: [
        Icon(Icons.star, color: Colors.amber),
        SizedBox(width: 4),
        Text(
          recommendation.activity.rating.toStringAsFixed(1),
          style: Theme.of(context).textTheme.titleMedium,
        ),
        SizedBox(width: 16),
        Icon(Icons.place_outlined),
        SizedBox(width: 4),
        Text(
          _getDistanceText(recommendation.metadata.distance),
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        SizedBox(width: 16),
        Icon(Icons.schedule),
        SizedBox(width: 4),
        Text(
          _formatDuration(recommendation.metadata.estimatedDuration),
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }

  Widget _buildWhyRecommendedSection(BuildContext context) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.lightbulb, color: Colors.amber),
                SizedBox(width: 8),
                Text(
                  'Why we recommended this',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            SizedBox(height: 12),
            Text(recommendation.reasoning),
            SizedBox(height: 12),

            // Score breakdown
            RecommendationScoreBreakdown(
              score: recommendation.relevanceScore,
              metadata: recommendation.metadata,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAboutSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'About',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        SizedBox(height: 8),
        Text(
          recommendation.activity.description,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }

  Widget _buildLocalTipsSection(BuildContext context) {
    final tips = recommendation.activity.localTips;

    if (tips.isEmpty) {
      return SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.forum, color: Colors.blue),
            SizedBox(width: 8),
            Text(
              'Tips from locals',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
        ),
        SizedBox(height: 12),
        ...tips.map((tip) => Padding(
          padding: EdgeInsets.only(bottom: 8),
          child: Card(
            child: Padding(
              padding: EdgeInsets.all(12),
              child: Text('"$tip"'),
            ),
          ),
        )),
      ],
    );
  }

  Widget _buildAvailabilitySection(BuildContext context) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Availability',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            SizedBox(height: 12),
            // Show next 3 days
            for (int i = 0; i < 3; i++)
              ListTile(
                leading: Icon(Icons.event),
                title: Text(
                  DateFormat.EEEE().format(
                    recommendation.metadata.suggestedDate.add(Duration(days: i)),
                  ),
                ),
                subtitle: Text('Open 9:30 AM - 6:00 PM'),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FilledButton.icon(
          onPressed: onAdd,
          icon: Icon(Icons.add),
          label: Text('Add to Itinerary'),
          style: FilledButton.styleFrom(
            padding: EdgeInsets.symmetric(vertical: 16),
          ),
        ),
        SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: () {
            // View on map
          },
          icon: Icon(Icons.map),
          label: Text('View on Map'),
        ),
      ],
    );
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;

    if (hours > 0 && minutes > 0) {
      return '${hours}h ${minutes}m';
    } else if (hours > 0) {
      return '${hours}h';
    } else {
      return '${minutes}m';
    }
  }

  String _getDistanceText(DistanceFromHotel distance) {
    switch (distance) {
      case DistanceFromHotel.walking:
        return 'Walking distance';
      case DistanceFromHotel.shortTrip:
        return 'Short trip';
      case DistanceFromHotel.mediumTrip:
        return 'Medium trip';
      case DistanceFromHotel.far:
        return 'Far';
    }
  }
}

// lib/features/recommendations/presentation/widgets/recommendation_score_breakdown.dart
class RecommendationScoreBreakdown extends StatelessWidget {
  final double score;
  final RecommendationMetadata metadata;

  const RecommendationScoreBreakdown({
    required this.score,
    required this.metadata,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Score: ${score.toInt()}/100',
          style: Theme.of(context).textTheme.titleSmall,
        ),
        SizedBox(height: 8),
        _buildScoreBar(
          context,
          'Interest Match',
          40,
          metadata.matchedInterests.isNotEmpty ? 40 : 0,
          Colors.blue,
        ),
        _buildScoreBar(
          context,
          'Weather Fit',
          25,
          _calculateWeatherScore(),
          Colors.green,
        ),
        _buildScoreBar(
          context,
          'User Rating',
          15,
          12, // Assuming good rating
          Colors.amber,
        ),
        _buildScoreBar(
          context,
          'Proximity',
          10,
          _calculateProximityScore(),
          Colors.purple,
        ),
      ],
    );
  }

  Widget _buildScoreBar(
    BuildContext context,
    String label,
    double maxScore,
    double actualScore,
    Color color,
  ) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              Text(
                '+${actualScore.toInt()} pts',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: color,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
          SizedBox(height: 4),
          LinearProgressIndicator(
            value: actualScore / maxScore,
            backgroundColor: color.withOpacity(0.2),
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ],
      ),
    );
  }

  double _calculateWeatherScore() {
    // Simplified - would be calculated from actual weather data
    return metadata.weather == WeatherContext.indoor ? 25 : 15;
  }

  double _calculateProximityScore() {
    switch (metadata.distance) {
      case DistanceFromHotel.walking:
        return 10;
      case DistanceFromHotel.shortTrip:
        return 7;
      case DistanceFromHotel.mediumTrip:
        return 4;
      case DistanceFromHotel.far:
        return 0;
    }
  }
}
```

---

## Providers

```dart
// lib/features/recommendations/presentation/providers/recommendation_providers.dart
@riverpod
RecommendationService recommendationService(RecommendationServiceRef ref) {
  return PersonalizedRecommendationService(
    placesRepo: ref.watch(placesRepositoryProvider),
    weatherService: ref.watch(weatherServiceProvider),
    userProfileService: ref.watch(userProfileServiceProvider),
    itineraryRepo: ref.watch(itineraryRepositoryProvider),
    locationService: ref.watch(locationServiceProvider),
  );
}

@riverpod
Future<List<Recommendation>> recommendations(
  RecommendationsRef ref,
  String itineraryId,
) async {
  final itinerary = await ref.watch(itineraryProvider(itineraryId).future);

  final request = RecommendationRequest(
    itineraryId: itineraryId,
    destination: itinerary.destination,
    tripDates: itinerary.dateRange,
    interests: [], // Get from user profile
    hotelLocation: null, // Get from accommodation
    limit: 20,
    excludeItineraryItems: true,
  );

  final service = ref.watch(recommendationServiceProvider);
  final result = await service.getPersonalizedRecommendations(request);

  return result.fold(
    (failure) => throw failure,
    (recommendations) => recommendations,
  );
}

@riverpod
GetPersonalizedRecommendations getPersonalizedRecommendations(
  GetPersonalizedRecommendationsRef ref,
) {
  return GetPersonalizedRecommendations(
    ref.watch(recommendationServiceProvider),
  );
}

@riverpod
AddRecommendationToItinerary addRecommendationToItinerary(
  AddRecommendationToItineraryRef ref,
) {
  return AddRecommendationToItinerary(
    ref.watch(itineraryRepositoryProvider),
  );
}

@riverpod
SaveRecommendation saveRecommendation(SaveRecommendationRef ref) {
  return SaveRecommendation(
    ref.watch(recommendationRepositoryProvider),
  );
}

@riverpod
DismissRecommendation dismissRecommendation(DismissRecommendationRef ref) {
  return DismissRecommendation(
    ref.watch(recommendationRepositoryProvider),
  );
}
```

---

## Testing Checklist

### Unit Tests
- [ ] Recommendation entity validation
- [ ] RecommendationMetadata enum values
- [ ] PersonalizedRecommendationService scoring
- [ ] Weather-based recommendation filtering
- [ ] Distance calculations
- [ ] Interest matching logic
- [ ] Collaborative filtering user similarity

### Widget Tests
- [ ] RecommendationsScreen renders correctly
- [ ] RecommendationCard displays all metadata
- [ ] Filter panel updates recommendations
- [ ] Score breakdown visualizes correctly
- [ ] Add to itinerary button works

### Integration Tests
- [ ] Complete recommendations flow (load → filter → add)
- [ ] Weather-based suggestions update correctly
- [ ] Distance calculations affect ordering
- [ ] Feedback recording improves future recommendations

---

## Success Metrics

| Metric | Target | How to Measure |
|--------|--------|----------------|
| Add rate | 30%+ | Recommendations added / recommendations shown |
| Tap-through rate | 50%+ | Details viewed / recommendations shown |
| Feedback rate | 20%+ | Helpful/not helpful responses / total |
| Repeat usage | 40%+ | Users who return to recommendations within trip |
| Relevance score | 70+ avg | Average relevance score of shown recommendations |

---

## Dependencies for Next Features

**Enables:**
- Feature 6: Purpose-Driven Community (users can share recommendations)
- Feature 9: Meaningful Progress Tracking (recommendations accepted)

---

## Sources

- [Recommendation System Algorithms](https://en.wikipedia.org/wiki/Recommender_system)
- [Collaborative Filtering](https://en.wikipedia.org/wiki/Collaborative_filtering)
- [Content-Based Filtering](https://en.wikipedia.org/wiki/Content-based_filtering)
