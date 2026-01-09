import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import 'package:soloadventurer/core/services/location_service.dart';
import 'package:soloadventurer/core/services/places_service.dart';
import 'package:soloadventurer/core/services/weather_service.dart';
import 'package:soloadventurer/features/onboarding/domain/entities/date_range.dart';
import 'package:soloadventurer/features/travel/domain/models/itinerary.dart';
import 'package:soloadventurer/features/travel/domain/models/itinerary_item.dart';
import 'package:soloadventurer/features/travel/domain/models/place_activity.dart';
import 'package:soloadventurer/features/travel/domain/models/optimization_suggestion.dart';

/// Service for generating itinerary optimization suggestions
///
/// Analyzes itineraries and suggests improvements based on:
/// - Weather forecasts
/// - Geographic proximity of activities
/// - Peak hours at popular attractions
/// - Travel time between locations
///
/// Example:
/// ```dart
/// final optimizer = ItineraryOptimizer(
///   weatherService: ref.read(weatherServiceProvider),
///   locationService: ref.read(locationServiceProvider),
///   placesService: ref.read(placesServiceProvider),
/// );
///
/// final suggestions = await optimizer.generateOptimizations(itinerary);
/// for (final suggestion in suggestions) {
///   print('${suggestion.title}: ${suggestion.benefitDescription}');
/// }
/// ```
class ItineraryOptimizer {
  final WeatherService _weatherService;
  final LocationService _locationService;
  final PlacesService _placesService;
  final Uuid _uuid = const Uuid();

  /// Creates a new [ItineraryOptimizer]
  ///
  /// All dependencies are injected via constructor parameters.
  ItineraryOptimizer({
    required WeatherService weatherService,
    required LocationService locationService,
    required PlacesService placesService,
  })  : _weatherService = weatherService,
        _locationService = locationService,
        _placesService = placesService;

  /// Generates optimization suggestions for an itinerary
  ///
  /// The [itinerary] parameter is the itinerary to analyze.
  ///
  /// Returns a list of optimization suggestions sorted by priority.
  Future<List<OptimizationSuggestion>> generateOptimizations(
    Itinerary itinerary,
  ) async {
    final suggestions = <OptimizationSuggestion>[];

    // 1. Weather-based optimizations
    final weatherSuggestions = await _checkWeatherOptimizations(itinerary);
    suggestions.addAll(weatherSuggestions);

    // 2. Geographic clustering (group nearby activities)
    final geoSuggestions = await _checkGeographicOptimizations(itinerary);
    suggestions.addAll(geoSuggestions);

    // 3. Timing optimizations (avoid peak hours)
    final timingSuggestions = await _checkTimingOptimizations(itinerary);
    suggestions.addAll(timingSuggestions);

    // 4. Travel time minimization
    final travelSuggestions = await _checkTravelTimeOptimizations(itinerary);
    suggestions.addAll(travelSuggestions);

    // Sort by priority (highest first)
    suggestions.sort((a, b) => b.priority.compareTo(a.priority));

    return suggestions;
  }

  /// Checks for weather-based optimizations
  ///
  /// Suggests indoor alternatives when rain is expected.
  Future<List<OptimizationSuggestion>> _checkWeatherOptimizations(
    Itinerary itinerary,
  ) async {
    final suggestions = <OptimizationSuggestion>[];

    try {
      // Get weather for each day
      for (var day = 1; day <= itinerary.numberOfDays; day++) {
        final items = itinerary.getItemsForDay(day);
        if (items.isEmpty) continue;

        // Calculate the date for this day
        final dayDate = itinerary.dateRange.start.add(Duration(days: day - 1));

        // Get weather forecast
        final forecasts = await _weatherService.getForecast(
          itinerary.destination,
          DateRange(start: dayDate, end: dayDate.add(const Duration(days: 1))),
        );

        if (forecasts.isEmpty) continue;

        final weather = forecasts.first;
        final hasRain = weather.isRainy;

        if (hasRain) {
          // Find outdoor activities
          final outdoorActivities = items.where((item) {
            return switch (item) {
              ItineraryItemActivity(:final name) => _isOutdoorActivityFromName(name),
              _ => false,
            };
          }).toList();

          if (outdoorActivities.isNotEmpty) {
            suggestions.add(OptimizationSuggestion(
              id: _uuid.v4(),
              type: OptimizationType.accountForWeather,
              title: 'Rain expected on ${_formatDate(dayDate)}',
              description: '${outdoorActivities.length} outdoor activit${outdoorActivities.length == 1 ? 'y' : 'ies'} affected. '
                          'Consider indoor alternatives.',
              affectedItems: outdoorActivities,
              suggestedOrder: [],
              reasoning: 'Weather forecast shows precipitation. '
                         'Indoor activities recommended.',
            ));
          }
        }
      }
    } catch (e, stackTrace) {
      debugPrint('ItineraryOptimizer: Weather optimization failed: $e');
      debugPrint('StackTrace: $stackTrace');
    }

    return suggestions;
  }

  /// Checks for geographic clustering opportunities
  ///
  /// Suggests grouping nearby activities to reduce travel time.
  Future<List<OptimizationSuggestion>> _checkGeographicOptimizations(
    Itinerary itinerary,
  ) async {
    final suggestions = <OptimizationSuggestion>[];

    try {
      for (var day = 1; day <= itinerary.numberOfDays; day++) {
        final items = itinerary.getItemsForDay(day);
        if (items.length < 2) continue;

        // Group activities by proximity
        final clusters = await _groupActivitiesByProximity(items);

        for (final cluster in clusters) {
          if (cluster.length > 1) {
            // Calculate time saved by doing these together
            final timeSaved = _estimateTimeSavedByClustering(cluster);

            suggestions.add(OptimizationSuggestion(
              id: _uuid.v4(),
              type: OptimizationType.groupNearbyLocations,
              title: 'Group nearby activities',
              description: 'These ${cluster.length} activities are within '
                          'walking distance of each other.',
              affectedItems: cluster,
              suggestedOrder: cluster,
              reasoning: 'Reducing travel time between locations.',
              timeSaved: timeSaved,
            ));
          }
        }
      }
    } catch (e, stackTrace) {
      debugPrint('ItineraryOptimizer: Geographic optimization failed: $e');
      debugPrint('StackTrace: $stackTrace');
    }

    return suggestions;
  }

  /// Checks for timing optimizations
  ///
  /// Suggests avoiding peak hours at popular attractions.
  Future<List<OptimizationSuggestion>> _checkTimingOptimizations(
    Itinerary itinerary,
  ) async {
    final suggestions = <OptimizationSuggestion>[];

    try {
      for (final item in itinerary.items) {
        if (item case ItineraryItemActivity(:final name, :final time)) {
          // Check if it's a popular attraction that might have peak hours
          final peakInfo = await _placesService.getPeakHours(
            name,
            itinerary.destination,
          );

          final currentTime = time.hour;

          // Check if current time is in peak hours
          if (peakInfo.hours.contains(currentTime)) {
            final suggestedTime = _suggestBetterTime(peakInfo, item);

            suggestions.add(OptimizationSuggestion(
              id: _uuid.v4(),
              type: OptimizationType.avoidPeakHours,
              title: 'Avoid crowds at $name',
              description: 'Current time ($currentTime:00) is peak hours. '
                          'Consider visiting at ${suggestedTime.hour}:00.',
              affectedItems: [item],
              suggestedOrder: [],
              reasoning: 'Peak hours: ${peakInfo.hours.join(', ')}.',
              timeSaved: const Duration(minutes: 30), // Time saved waiting in line
            ));
          }
        }
      }
    } catch (e, stackTrace) {
      debugPrint('ItineraryOptimizer: Timing optimization failed: $e');
      debugPrint('StackTrace: $stackTrace');
    }

    return suggestions;
  }

  /// Checks for travel time optimization opportunities
  ///
  /// Suggests reordering to minimize travel between locations.
  Future<List<OptimizationSuggestion>> _checkTravelTimeOptimizations(
    Itinerary itinerary,
  ) async {
    final suggestions = <OptimizationSuggestion>[];

    try {
      for (var day = 1; day <= itinerary.numberOfDays; day++) {
        final items = itinerary.getItemsForDay(day);
        if (items.length < 2) continue;

        // Get items with locations
        final itemsWithLocations = <ItineraryItem, _LocationData>{};
        for (final item in items) {
          final location = await _extractLocation(item);
          if (location != null) {
            itemsWithLocations[item] = location;
          }
        }

        if (itemsWithLocations.length < 2) continue;

        // Calculate total travel time for current order
        final currentTravelTime = _calculateTotalTravelTime(
          itemsWithLocations.keys.toList(),
          itemsWithLocations,
        );

        // Try a simple optimization: sort by location
        final sortedByLocation = itemsWithLocations.entries.toList()
          ..sort((a, b) => a.value.latitude.compareTo(b.value.latitude));

        final optimizedTravelTime = _calculateTotalTravelTime(
          sortedByLocation.map((e) => e.key).toList(),
          Map.fromEntries(sortedByLocation),
        );

        // If optimization saves significant time (15+ minutes)
        if ((currentTravelTime - optimizedTravelTime).inMinutes >= 15) {
          suggestions.add(OptimizationSuggestion(
            id: _uuid.v4(),
            type: OptimizationType.reduceTravelTime,
            title: 'Reduce travel time on day $day',
            description: 'Reordering activities can save '
                        '${(currentTravelTime - optimizedTravelTime).inMinutes} minutes of travel.',
            affectedItems: itemsWithLocations.keys.toList(),
            suggestedOrder: sortedByLocation.map((e) => e.key).toList(),
            reasoning: 'Optimizing route between locations.',
            timeSaved: currentTravelTime - optimizedTravelTime,
          ));
        }
      }
    } catch (e, stackTrace) {
      debugPrint('ItineraryOptimizer: Travel time optimization failed: $e');
      debugPrint('StackTrace: $stackTrace');
    }

    return suggestions;
  }

  /// Groups activities by geographic proximity
  ///
  /// Returns clusters of nearby activities (within 500m).
  Future<List<List<ItineraryItem>>> _groupActivitiesByProximity(
    List<ItineraryItem> items,
  ) async {
    final itemsWithLocations = <ItineraryItem, _LocationData>{};

    // Get locations for all items
    for (final item in items) {
      final location = await _extractLocation(item);
      if (location != null) {
        itemsWithLocations[item] = location;
      }
    }

    // Simple clustering: group items within 500m of each other
    final clusters = <List<ItineraryItem>>[];
    final processed = <ItineraryItem>{};

    for (final entry in itemsWithLocations.entries) {
      if (processed.contains(entry.key)) continue;

      final cluster = <ItineraryItem>[entry.key];
      processed.add(entry.key);

      for (final other in itemsWithLocations.entries) {
        if (processed.contains(other.key)) continue;

        final distance = _locationService.distanceBetween(
          entry.value.latitude,
          entry.value.longitude,
          other.value.latitude,
          other.value.longitude,
        );

        if (distance < 500) {
          cluster.add(other.key);
          processed.add(other.key);
        }
      }

      if (cluster.length > 1) {
        clusters.add(cluster);
      }
    }

    return clusters;
  }

  /// Estimates time saved by clustering activities
  Duration _estimateTimeSavedByClustering(List<ItineraryItem> cluster) {
    // Estimate 10-15 minutes saved per group by reducing travel
    return Duration(minutes: (cluster.length - 1) * 15);
  }

  /// Suggests a better time to visit an attraction
  DateTime _suggestBetterTime(PeakHours peak, ItineraryItem activity) {
    final current = switch (activity) {
      ItineraryItemActivity(:final time) => time,
      ItineraryItemLunch(:final time) => time,
      ItineraryItemDinner(:final time) => time,
      ItineraryItemHotelCheckIn(:final time) => time,
      ItineraryItemHotelCheckOut(:final time) => time,
      ItineraryItemFlightArrival(:final time) => time,
      ItineraryItemFlightDeparture(:final time) => time,
    };

    // Suggest 2 hours before or after peak
    if (current.hour > 12) {
      return current.subtract(const Duration(hours: 2));
    } else {
      return current.add(const Duration(hours: 2));
    }
  }

  /// Extracts location data from an itinerary item
  Future<_LocationData?> _extractLocation(ItineraryItem item) async {
    // TODO: Implement geocoding to convert location string to coordinates
    // For now, return null for all items since we don't have coordinate data
    return null;
  }

  /// Calculates total travel time between items
  Duration _calculateTotalTravelTime(
    List<ItineraryItem> items,
    Map<ItineraryItem, _LocationData> locations,
  ) {
    if (items.length < 2) return Duration.zero;

    var totalDistance = 0.0;
    for (var i = 0; i < items.length - 1; i++) {
      final current = locations[items[i]];
      final next = locations[items[i + 1]];
      if (current != null && next != null) {
        totalDistance += _locationService.distanceBetween(
          current.latitude,
          current.longitude,
          next.latitude,
          next.longitude,
        );
      }
    }

    // Estimate 10 minutes per km (walking/transit mix)
    return Duration(minutes: (totalDistance / 1.0 * 10).round());
  }

  /// Checks if an activity is likely outdoor based on its name
  bool _isOutdoorActivityFromName(String activityName) {
    final lowerName = activityName.toLowerCase();
    final outdoorKeywords = [
      'park',
      'garden',
      'hike',
      'hiking',
      'beach',
      'outdoor',
      'tour',
      'street',
      'market',
    ];

    return outdoorKeywords.any((keyword) => lowerName.contains(keyword));
  }

  /// Formats a date for display
  String _formatDate(DateTime date) {
    return '${date.month}/${date.day}';
  }
}

/// Internal class for storing location data
class _LocationData {
  final double latitude;
  final double longitude;

  _LocationData({required this.latitude, required this.longitude});
}
