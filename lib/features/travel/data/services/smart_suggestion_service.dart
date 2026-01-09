import 'package:soloadventurer/core/services/places_service.dart';
import 'package:soloadventurer/core/services/weather_service.dart';
import 'package:soloadventurer/features/onboarding/domain/entities/date_range.dart';
import 'package:soloadventurer/features/onboarding/domain/entities/destination.dart';
import 'package:soloadventurer/features/travel/domain/models/activity_suggestion.dart';
import 'package:soloadventurer/features/travel/domain/models/itinerary_item.dart';
import 'package:soloadventurer/features/travel/domain/models/place_activity.dart';

/// Service for generating smart activity suggestions
///
/// Suggests activities based on:
/// - User interests and preferences
/// - Current weather conditions
/// - Location and proximity
/// - User ratings and popularity
///
/// Example:
/// dart
/// final service = SmartSuggestionService(
///   placesService: ref.read(placesServiceProvider),
///   weatherService: ref.read(weatherServiceProvider),
/// );
///
/// final suggestions = await service.getSuggestions(
///   destination: paris,
///   date: DateTime(2024, 6, 15),
///   interests: {TravelInterest.art, TravelInterest.history},
/// );
///
class SmartSuggestionService {
  final PlacesService _placesService;
  final WeatherService _weatherService;

  /// Creates a new [SmartSuggestionService]
  ///
  /// All dependencies are injected via constructor parameters.
  SmartSuggestionService({
    required PlacesService placesService,
    required WeatherService weatherService,
  })  : _placesService = placesService,
        _weatherService = weatherService;

  /// Gets activity suggestions for a specific date and location
  ///
  /// The [destination] parameter is the location to search.
  /// The [date] parameter is the date of the activity.
  /// The [interests] parameter filters by user interests.
  /// The [afterItem] parameter optionally specifies the previous item (for proximity).
  ///
  /// Returns a list of activity suggestions sorted by relevance.
  Future<List<ActivitySuggestion>> getSuggestions({
    required Destination destination,
    required DateTime date,
    required Set<TravelInterest> interests,
    ItineraryItem? afterItem,
  }) async {
    final suggestions = <ActivitySuggestion>[];

    // 1. Get weather for the date
    bool hasRain = false;
    bool isHot = false;
    bool isCold = false;

    try {
      final weatherResult = await _weatherService.getForecast(
        destination,
        DateRange(start: date, end: date.add(const Duration(days: 1))),
      );

      if (weatherResult.isNotEmpty) {
        final weather = weatherResult.first;
        hasRain = weather.isRainy;
        isHot = weather.temperatureMax > 30.0;
        isCold = weather.temperatureMax < 10.0;
      }
    } catch (e) {
      // Continue without weather data
    }

    // 2. Find activities matching interests
    for (final interest in interests) {
      try {
        final activities = await _placesService.findActivities(
          destination: destination,
          interest: interest,
          date: date,
          isIndoor: hasRain ? true : null,
        );

        for (final activity in activities) {
          final suggestion = ActivitySuggestion(
            activity: activity,
            reason: _generateReason(interest, hasRain, isHot, isCold, activity),
            score: _calculateRelevanceScore(
              activity,
              interests,
              hasRain,
              isHot,
              isCold,
            ),
          );
          suggestions.add(suggestion);
        }
      } catch (e) {
        // Continue on error
      }
    }

    // 3. Sort by relevance score (highest first)
    suggestions.sort((a, b) => b.score.compareTo(a.score));

    // 4. Return top suggestions
    return suggestions.take(10).toList();
  }

  /// Generates a human-readable reason for the suggestion
  String _generateReason(
    TravelInterest interest,
    bool hasRain,
    bool isHot,
    bool isCold,
    PlaceActivity activity,
  ) {
    final reasons = <String>[];

    // Interest match
    reasons.add('Matches your interest in ${interest.label}');

    // Weather-based reasons
    if (hasRain && activity.isIndoor) {
      reasons.add('Indoor activity (rain expected)');
    } else if (!hasRain && !activity.isIndoor && _isOutdoorActivity(activity)) {
      reasons.add('Great for the weather');
    }

    if (isHot && activity.isIndoor) {
      reasons.add('Air-conditioned space (hot day)');
    } else if (isCold &&
        (activity.isIndoor || activity.category == 'restaurant')) {
      reasons.add('Indoor warmth (cold day)');
    }

    // Quality indicators
    if (activity.isHighlyRated) {
      reasons.add('Highly rated');
    }

    if (activity.isPopular) {
      reasons.add('Popular with travelers');
    }

    return reasons.join(' • ');
  }

  /// Calculates a relevance score for an activity (0-1)
  double _calculateRelevanceScore(
    PlaceActivity activity,
    Set<TravelInterest> interests,
    bool hasRain,
    bool isHot,
    bool isCold,
  ) {
    double score = 0.0;

    // Interest match (30%)
    if (interests.any((i) => _matchesInterest(activity, i))) {
      score += 0.3;
    }

    // Weather appropriateness (20%)
    if (hasRain) {
      if (activity.isIndoor) {
        score += 0.2;
      } else {
        score -= 0.1; // Penalty for outdoor activities in rain
      }
    } else {
      if (!activity.isIndoor && _isOutdoorActivity(activity)) {
        score += 0.2;
      } else if (!activity.isIndoor) {
        score += 0.1;
      }
    }

    // Temperature considerations (15%)
    if (isHot && activity.isIndoor) {
      score += 0.15;
    } else if (isCold && activity.isIndoor) {
      score += 0.15;
    }

    // User rating (20%)
    score += (activity.rating / 5.0) * 0.2;

    // Popularity (15%)
    score += (activity.reviewCount / 1000.0).clamp(0.0, 0.15) * 0.15;

    return score.clamp(0.0, 1.0);
  }

  /// Checks if an activity matches a travel interest
  bool _matchesInterest(PlaceActivity activity, TravelInterest interest) {
    final category = activity.category.toLowerCase();

    return switch (interest) {
      TravelInterest.art => category.contains('art') ||
          category.contains('museum') ||
          category.contains('gallery'),
      TravelInterest.food => category.contains('restaurant') ||
          category.contains('food') ||
          category.contains('cafe'),
      TravelInterest.history => category.contains('historical') ||
          category.contains('monument') ||
          category.contains('heritage'),
      TravelInterest.nature => category.contains('park') ||
          category.contains('nature') ||
          category.contains('garden'),
      TravelInterest.adventure => category.contains('adventure') ||
          category.contains('sport') ||
          category.contains('hike'),
      TravelInterest.relaxation => category.contains('spa') ||
          category.contains('wellness') ||
          category.contains('beach'),
      TravelInterest.shopping => category.contains('shopping') ||
          category.contains('market') ||
          category.contains('mall'),
      TravelInterest.nightlife => category.contains('bar') ||
          category.contains('club') ||
          category.contains('nightlife'),
      TravelInterest.music => category.contains('music') ||
          category.contains('concert') ||
          category.contains('venue'),
      TravelInterest.architecture => category.contains('architecture') ||
          category.contains('building') ||
          category.contains('cathedral'),
    };
  }

  /// Checks if an activity is outdoor
  bool _isOutdoorActivity(PlaceActivity activity) {
    return !activity.isIndoor;
  }
}
