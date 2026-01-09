# Feature 2: Smart Adaptive Itinerary Planner

**Phase:** Phase 0 - Core Value First
**Time:** 2-3 weeks
**Dependencies:** Feature 1 (Instant Value Onboarding)
**Priority:** ⚡ Critical

---

## Overview

**The Core Value:** Users can drag, drop, and customize their trip itinerary with intelligent suggestions and auto-optimizations. This is the feature they return to repeatedly to refine their plans.

**Why This Works:**
- Transform passive "wishlist" into active "trip builder"
- Drag & drop creates ownership and investment
- Smart suggestions reduce planning friction
- Real-time updates (weather, delays) build trust
- This becomes the daily-use feature during trip planning

**Success Metric:** Users spend 10+ minutes per session editing itinerary; 60%+ return to edit within 24 hours

---

## UI Wireframes

### Main Itinerary Screen

```
+------------------------------------------------+
| ← Paris Trip 2026            [Share] [⋮]       |
+------------------------------------------------+
|                                                |
|  May 11 - May 18, 2026                          |
|  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━      |
|  Progress: 60% complete                        |
|                                                |
|  [📅 Calendar] [🗺️ Map] [📋 List]              |
|                                                |
+------------------------------------------------+
|  📅 May 11 (Arrival Day)                       |
|  ┌──────────────────────────────────────────┐  |
|  │ 11:45  ✈️ Land at CDG Airport            │  |
|  │        Terminal 2E, Gate K42              │  |
|  └──────────────────────────────────────────┘  |
|  ┌──────────────────────────────────────────┐  |
|  │ 14:00  🏨 Check into Hotel Le Marais      │  │
|  │        12 Rue de Rivoli, Paris            │  |
|  │        [View on Map] [Contact]            │  |
|  └──────────────────────────────────────────┘  |
|  ┌──────────────────────────────────────────┐  |
|  │ 19:00  🍽️ Dinner: Le Comptoir du 7ème     │  │
|  │        Left Bank bistro, local favorite   │  |
|  │        [Add Note] [Remove] [Edit Time]    │  |
|  └──────────────────────────────────────────┘  |
|                                                |
|  [Drag to reorder items]                       |
|                                                |
|  [+ Add Item] [🤖 AI Suggestions]              |
+------------------------------------------------+
|  📅 May 12 (First Full Day)                    |
|  ⚠️ Rain expected - indoor activities suggested|
|  ┌──────────────────────────────────────────┐  |
|  │ 09:00  🥐 Breakfast: Du Pain et des Idées │  |
|  │        Highly-rated bakery in Marais      │  |
|  └──────────────────────────────────────────┘  |
|  ┌──────────────────────────────────────────┐  |
|  │ 10:30  🏛️ Louvre Museum                   │  │
|  │        ⚠️ Book tickets in advance!        │  |
|  │        [Book Now] [Add to Calendar]       │  |
|  │        Estimated: 3-4 hours               │  |
|  └──────────────────────────────────────────┘  |
|                                                |
|  [+ Add Item] [🤖 AI Suggestions]              |
+------------------------------------------------+
```

### Add Item Modal

```
+------------------------------------------------+
|  Add to Itinerary                              |
+------------------------------------------------+
|                                                |
|  What type of item?                            |
|  ┌────┐ ┌────┐ ┌────┐ ┌────┐                  |
|  │✈️  │ │🏨  │ │🍽️  │ │🎭  │                  |
+│Flight│ │Hotel│ │Food│ │Event│                  |
|  └────┘ └────┘ └────┘ └────┘                  |
|  ┌────┐ ┌────┐ ┌────┐ ┌────┐                  |
|  │🚗  │ │🏛️  │ │🥾  │ │🛍️  │                  |
|  │Transport│Attraction│Activity│Shopping│       |
|  └────┘ └────┘ └────┘ └────┘                  |
|                                                |
|  ────────── OR ──────────                      |
|                                                |
|  [Search]                                      |
|  Search for places, activities, restaurants    |
|  ____________________________________________  |
|                                                |
+------------------------------------------------+
|          [Cancel]        [Next]                |
+------------------------------------------------+
```

### AI Suggestions Bottom Sheet

```
+------------------------------------------------+
|  🤖 Smart Suggestions for May 12               |
|  ← Swipe down to close                         |
+------------------------------------------------|
|                                                |
|  Based on your interests (Art, Culture)        |
|  and rainy weather forecast:                   |
|                                                |
|  ┌──────────────────────────────────────────┐  |
|  │ 🎨 Musée d'Orsay                          │  │
|  │    Indoor masterpiece collection           │  │
|  │    Best time: Morning (less crowded)       │  │
|  │    [Add] [Details]                         │  │
|  └──────────────────────────────────────────┘  |
|                                                |
|  ┌──────────────────────────────────────────┐  |
|  │ ☕ Café de Flore                           │  │
|  │    Historic literary café (indoor seating)│  │
|  │    Perfect for rainy afternoon            │  │
|  │    [Add] [Details]                         │  │
|  └──────────────────────────────────────────┘  |
|                                                |
|  ┌──────────────────────────────────────────┐  |
|  │ 🎭 Opéra Garnier Tour                     │  │
|  │    Behind-the-scenes opera house visit    │  │
|  │    Guided tours available                 │  │
|  │    [Add] [Details]                         │  │
|  └──────────────────────────────────────────┘  |
|                                                |
|  [🔄 Refresh] [See All Suggestions]            |
+------------------------------------------------+
```

### Reorder Mode

```
+------------------------------------------------+
|  ← Reorder Items                    [Done]     |
+------------------------------------------------+
|                                                |
|  Drag items to reorder. Auto-optimization      |
|  will suggest better timing.                   |
|                                                |
|  ═══════════════════════════════════════════   |
|  ⠿ 11:45  ✈️ Land at CDG Airport            │
|  ═══════════════════════════════════════════   |
|  ⠿ 14:00  🏨 Check into Hotel Le Marais      │
|  ═══════════════════════════════════════════   |
|  ⠿ 16:30  🚇 Metro to City Center            │
|  ═══════════════════════════════════════════   |
|  ⠿ 19:00  🍽️ Dinner: Le Comptoir du 7ème     │
|  ═══════════════════════════════════════════   |
|                                                |
|  💡 Tip: Moving dinner to 20:00 gives you      |
|     more time to check in and freshen up       |
|                                                |
|  [Apply Optimization]                          |
+------------------------------------------------+
```

---

## Architecture

### Domain Layer

```dart
// lib/features/itinerary/domain/entities/itinerary.dart
@freezed
class Itinerary with _$Itinerary {
  const factory Itinerary({
    required String id,
    required String name,
    required Destination destination,
    required DateRange dateRange,
    required List<ItineraryItem> items,
    @Default(false) bool isStarter,
    required DateTime createdAt,
    @Default(ItineraryStatus.planning) ItineraryStatus status,
    String? notes,
  }) = _Itinerary;

  const Itinerary._();

  // Computed properties
  int get totalDays => dateRange.duration.inDays;

  List<ItineraryItem> getItemsForDate(DateTime date) {
    return items.where((item) {
      return item.scheduledAt.year == date.year &&
             item.scheduledAt.month == date.month &&
             item.scheduledAt.day == date.day;
    }).toList()
      ..sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt));
  }

  double get completionPercentage {
    if (items.isEmpty) return 0.0;
    final completedCount = items.where((i) => i.isCompleted).length;
    return (completedCount / items.length) * 100;
  }

  List<DateTime> get uniqueDates {
    final dates = items.map((i) => DateTime(
      i.scheduledAt.year,
      i.scheduledAt.month,
      i.scheduledAt.day,
    )).toSet().toList();
    dates.sort();
    return dates;
  }
}

enum ItineraryStatus {
  planning,
  confirmed,
  inProgress,
  completed,
  cancelled,
}

// lib/features/itinerary/domain/entities/itinerary_item.dart
@freezed
class ItineraryItem with _$ItineraryItem {
  const factory ItineraryItem.flight({
    required String id,
    required DateTime scheduledAt,
    required String flightNumber,
    required String airline,
    required String airportCode,
    String? gate,
    String? terminal,
    @Default(false) bool isArrival,
    String? notes,
    @Default(false) bool isCompleted,
  }) = ItineraryItemFlight;

  const factory ItineraryItem.accommodation({
    required String id,
    required DateTime scheduledAt,
    required AccommodationType type,
    required String name,
    required String address,
    String? contactPhone,
    String? confirmationNumber,
    String? notes,
    @Default(false) bool isCompleted,
    GeoPoint? location,
  }) = ItineraryItemAccommodation;

  const factory ItineraryItem.activity({
    required String id,
    required DateTime scheduledAt,
    required ActivityType type,
    required String name,
    required String description,
    @Default(Duration(hours: 2)) Duration estimatedDuration,
    String? bookingUrl,
    String? confirmationNumber,
    Money? cost,
    List<String>? tags,
    String? notes,
    @Default(false) bool isCompleted,
    GeoPoint? location,
    @Default(false) bool requiresAdvanceBooking,
  }) = ItineraryItemActivity;

  const factory ItineraryItem.restaurant({
    required String id,
    required DateTime scheduledAt,
    required RestaurantType mealType, // breakfast, lunch, dinner, snack
    required String name,
    required String cuisine,
    String? address,
    String? reservationConfirmation,
    Money? estimatedCost,
    String? notes,
    @Default(false) bool isCompleted,
    GeoPoint? location,
  }) = ItineraryItemRestaurant;

  const factory ItineraryItem.transport({
    required String id,
    required DateTime scheduledAt,
    required TransportType type,
    required String description,
    String? serviceNumber,
    String? platform,
    Money? cost,
    String? notes,
    @Default(false) bool isCompleted,
    GeoPoint? from,
    GeoPoint? to,
  }) = ItineraryItemTransport;

  const ItineraryItem._();

  DateTime get scheduledAt => when(
    flight: (i) => i.scheduledAt,
    accommodation: (i) => i.scheduledAt,
    activity: (i) => i.scheduledAt,
    restaurant: (i) => i.scheduledAt,
    transport: (i) => i.scheduledAt,
  );

  bool get isCompleted => when(
    flight: (i) => i.isCompleted,
    accommodation: (i) => i.isCompleted,
    activity: (i) => i.isCompleted,
    restaurant: (i) => i.isCompleted,
    transport: (i) => i.isCompleted,
  );
}

enum AccommodationType { checkIn, checkOut }
enum ActivityType { attraction, museum, tour, outdoor, shopping, entertainment, wellness }
enum RestaurantType { breakfast, lunch, dinner, snack, drinks }
enum TransportType { flight, train, bus, metro, taxi, rentalCar, rideshare, walking, cycling }

// lib/features/itinerary/domain/entities/optimization_suggestion.dart
@freezed
class OptimizationSuggestion with _$OptimizationSuggestion {
  const factory OptimizationSuggestion({
    required String id,
    required OptimizationType type,
    required String title,
    required String description,
    required List<ItineraryItem> affectedItems,
    required List<ItineraryItem> suggestedOrder,
    String? reasoning,
    @Default(Duration.zero) Duration timeSaved,
    Money? costSaved,
  }) = _OptimizationSuggestion;
}

enum OptimizationType {
  reorderForEfficiency,
  groupNearbyLocations,
  avoidPeakHours,
  accountForWeather,
  reduceTravelTime,
}

// lib/features/itinerary/domain/usecases/
class AddItineraryItem {
  final ItineraryRepository _repository;

  AddItineraryItem(this._repository);

  Future<Either<Failure, Itinerary>> call({
    required String itineraryId,
    required ItineraryItem item,
  }) async {
    return await _repository.addItem(itineraryId, item);
  }
}

class UpdateItineraryItem {
  final ItineraryRepository _repository;

  UpdateItineraryItem(this._repository);

  Future<Either<Failure, Itinerary>> call({
    required String itineraryId,
    required ItineraryItem item,
  }) async {
    return await _repository.updateItem(itineraryId, item);
  }
}

class RemoveItineraryItem {
  final ItineraryRepository _repository;

  RemoveItineraryItem(this._repository);

  Future<Either<Failure, Itinerary>> call({
    required String itineraryId,
    required String itemId,
  }) async {
    return await _repository.removeItem(itineraryId, itemId);
  }
}

class ReorderItineraryItems {
  final ItineraryRepository _repository;

  ReorderItineraryItems(this._repository);

  Future<Either<Failure, Itinerary>> call({
    required String itineraryId,
    required List<String> itemIdsInNewOrder,
  }) async {
    return await _repository.reorderItems(itineraryId, itemIdsInNewOrder);
  }
}

class OptimizeItinerary {
  final ItineraryOptimizer _optimizer;

  OptimizeItinerary(this._optimizer);

  Future<Either<Failure, List<OptimizationSuggestion>>> call(
    Itinerary itinerary,
  ) async {
    return await _optimizer.generateOptimizations(itinerary);
  }
}

class GetItineraryForDate {
  final ItineraryRepository _repository;

  GetItineraryForDate(this._repository);

  Future<Either<Failure, List<ItineraryItem>>> call({
    required String itineraryId,
    required DateTime date,
  }) async {
    final result = await _repository.getItinerary(itineraryId);
    return result.fold(
      (failure) => left(failure),
      (itinerary) => right(itinerary.getItemsForDate(date)),
    );
  }
}
```

### Data Layer - Services

```dart
// lib/features/itinerary/data/services/itinerary_optimizer.dart
class ItineraryOptimizer {
  final WeatherService _weatherService;
  final LocationService _locationService;
  final PlacesService _placesService;

  ItineraryOptimizer({
    required WeatherService weatherService,
    required LocationService locationService,
    required PlacesService placesService,
  })  : _weatherService = weatherService,
        _locationService = locationService,
        _placesService = placesService;

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

    return suggestions;
  }

  Future<List<OptimizationSuggestion>> _checkWeatherOptimizations(
    Itinerary itinerary,
  ) async {
    final suggestions = <OptimizationSuggestion>[];

    for (final date in itinerary.uniqueDates) {
      final items = itinerary.getItemsForDate(date);
      final weather = await _weatherService.getForecast(
        itinerary.destination,
        DateRange(start: date, end: date.add(Duration(days: 1))),
      );

      if (weather.isLeft()) continue;

      final weatherData = weather.getOrElse(() => []);
      final hasRain = weatherData.any((w) => w.precipitation > 0.5);

      if (hasRain) {
        // Find outdoor activities and suggest alternatives
        final outdoorActivities = items.where((item) {
          return item.maybeWhen(
            activity: (activity) =>
                activity.type == ActivityType.outdoor,
            orElse: () => false,
          );
        }).toList();

        if (outdoorActivities.isNotEmpty) {
          // Find indoor alternatives
          final indoorAlternatives = await _placesService.findIndoorAlternatives(
            destination: itinerary.destination,
            interests: [], // Could be passed from user profile
            date: date,
          );

          if (indoorAlternatives.isNotEmpty) {
            suggestions.add(OptimizationSuggestion(
              id: uuid.v4(),
              type: OptimizationType.accountForWeather,
              title: 'Rain expected on ${_formatDate(date)}',
              description: '${outdoorActivities.length} outdoor activity(ies) affected. '
                          'Consider indoor alternatives.',
              affectedItems: outdoorActivities,
              suggestedOrder: [],
              reasoning: 'Weather forecast shows precipitation. '
                         'Indoor activities recommended.',
            ));
          }
        }
      }
    }

    return suggestions;
  }

  Future<List<OptimizationSuggestion>> _checkGeographicOptimizations(
    Itinerary itinerary,
  ) async {
    final suggestions = <OptimizationSuggestion>[];

    for (final date in itinerary.uniqueDates) {
      final items = itinerary.getItemsForDate(date);

      // Group activities by proximity
      final clusters = await _groupActivitiesByProximity(items);

      for (final cluster in clusters) {
        if (cluster.length > 1) {
          // Calculate time saved by doing these together
          final timeSaved = _estimateTimeSavedByClustering(cluster);

          suggestions.add(OptimizationSuggestion(
            id: uuid.v4(),
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

    return suggestions;
  }

  Future<List<OptimizationSuggestion>> _checkTimingOptimizations(
    Itinerary itinerary,
  ) async {
    final suggestions = <OptimizationSuggestion>[];

    for (final item in itinerary.items) {
      await item.maybeWhen(
        activity: (activity) async {
          // Check if it's a popular attraction
          final peakInfo = await _placesService.getPeakHours(
            activity.name,
            itinerary.destination,
          );

          if (peakInfo.isRight()) {
            final peak = peakInfo.getOrElse(() => PeakHours.empty);
            final currentTime = activity.scheduledAt.hour;

            if (peak.hours.contains(currentTime)) {
              // Suggest different time
              final suggestedTime = _suggestBetterTime(peak, activity);

              suggestions.add(OptimizationSuggestion(
                id: uuid.v4(),
                type: OptimizationType.avoidPeakHours,
                title: 'Avoid crowds at ${activity.name}',
                description: 'Current time (${currentTime}:00) is peak hours. '
                            'Consider visiting at ${suggestedTime.hour}:00.',
                affectedItems: [item],
                suggestedOrder: [],
                reasoning: 'Peak hours: ${peak.hours.join(', ')}',
              ));
            }
          }
        },
        orElse: () {},
      );
    }

    return suggestions;
  }

  Future<List<List<ItineraryItem>>> _groupActivitiesByProximity(
    List<ItineraryItem> items,
  ) async {
    // Get locations for all items
    final itemsWithLocations = <ItineraryItem, GeoPoint>{};

    for (final item in items) {
      final location = await item.maybeWhen(
        activity: (activity) async => activity.location,
        restaurant: (restaurant) async => restaurant.location,
        orElse: () => null,
      );

      if (location != null) {
        itemsWithLocations[item] = location;
      }
    }

    // Simple clustering: group items within 500m of each other
    final clusters = <List<ItineraryItem>>[];
    final processed = <ItineraryItem>{};

    for (final entry in itemsWithLocations.entries) {
      if (processed.contains(entry.key)) continue;

      final cluster = [entry.key];
      processed.add(entry.key);

      for (final other in itemsWithLocations.entries) {
        if (processed.contains(other.key)) continue;

        final distance = _locationService.calculateDistance(
          entry.value,
          other.value,
        );

        if (distance.inMeters < 500) {
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

  Duration _estimateTimeSavedByClustering(List<ItineraryItem> cluster) {
    // Estimate 15-30 minutes saved per group by reducing travel
    return Duration(minutes: (cluster.length - 1) * 20);
  }

  DateTime _suggestBetterTime(PeakHours peak, ItineraryItem activity) {
    final current = activity.scheduledAt;

    // Suggest 2 hours before or after peak
    if (current.hour > 12) {
      return current.subtract(Duration(hours: 2));
    } else {
      return current.add(Duration(hours: 2));
    }
  }

  String _formatDate(DateTime date) {
    return '${date.month}/${date.day}';
  }

  Future<List<OptimizationSuggestion>> _checkTravelTimeOptimizations(
    Itinerary itinerary,
  ) async {
    // Implementation for travel time optimization
    return [];
  }
}

// lib/features/itinerary/data/services/smart_suggestion_service.dart
class SmartSuggestionService {
  final PlacesService _placesService;
  final WeatherService _weatherService;
  final UserProfileService _userProfileService;

  SmartSuggestionService({
    required PlacesService placesService,
    required WeatherService weatherService,
    required UserProfileService userProfileService,
  })  : _placesService = placesService,
        _weatherService = weatherService,
        _userProfileService = userProfileService;

  Future<List<ActivitySuggestion>> getSuggestions({
    required Destination destination,
    required DateTime date,
    required Set<TravelInterest> interests,
    ItineraryItem? afterItem, // Suggest after this item
  }) async {
    final suggestions = <ActivitySuggestion>[];

    // 1. Get weather for the date
    final weatherResult = await _weatherService.getForecast(
      destination,
      DateRange(start: date, end: date.add(Duration(days: 1))),
    );

    final weather = weatherResult.getOrElse(() => []);
    final hasRain = weather.any((w) => w.precipitation > 0.5);

    // 2. Find activities matching interests
    for (final interest in interests) {
      final activities = await _placesService.findActivities(
        destination: destination,
        interest: interest,
        date: date,
        isIndoor: hasRain,
      );

      for (final activity in activities) {
        suggestions.add(ActivitySuggestion(
          activity: activity,
          reason: _generateReason(interest, hasRain, weather),
          score: _calculateRelevanceScore(activity, interests, weather),
        ));
      }
    }

    // 3. Sort by relevance score
    suggestions.sort((a, b) => b.score.compareTo(a.score));

    // 4. Return top suggestions
    return suggestions.take(10).toList();
  }

  String _generateReason(
    TravelInterest interest,
    bool hasRain,
    List<WeatherForecast> weather,
  ) {
    final reasons = <String>[];

    reasons.add('Matches your interest in ${interest.label}');

    if (hasRain) {
      reasons.add('Indoor activity (rain expected)');
    }

    if (weather.isNotEmpty) {
      final temp = weather.first.temperature;
      if (temp > 30) {
        reasons.add('Air-conditioned space (hot day)');
      } else if (temp < 10) {
        reasons.add('Indoor warmth (cold day)');
      }
    }

    return reasons.join(' • ');
  }

  double _calculateRelevanceScore(
    PlaceActivity activity,
    Set<TravelInterest> interests,
    List<WeatherForecast> weather,
  ) {
    double score = 0.0;

    // Interest match (40%)
    if (interests.any((i) => activity.category == i)) {
      score += 40.0;
    }

    // Weather appropriateness (30%)
    if (weather.isNotEmpty) {
      final hasRain = weather.any((w) => w.precipitation > 0.5);
      if (hasRain && activity.isIndoor) {
        score += 30.0;
      } else if (!hasRain && activity.isOutdoor) {
        score += 30.0;
      }
    }

    // User rating (20%)
    score += (activity.rating / 5.0) * 20.0;

    // Popularity (10%)
    score += (activity.reviewCount / 10000).clamp(0.0, 1.0) * 10.0;

    return score;
  }
}

@freezed
class ActivitySuggestion with _$ActivitySuggestion {
  const factory ActivitySuggestion({
    required PlaceActivity activity,
    required String reason,
    required double score,
  }) = _ActivitySuggestion;
}
```

### Presentation Layer

```dart
// lib/features/itinerary/presentation/screens/itinerary_screen.dart
class ItineraryScreen extends ConsumerStatefulWidget {
  final String itineraryId;

  const ItineraryScreen({required this.itineraryId, super.key});

  @override
  ConsumerState<ItineraryScreen> createState() => _ItineraryScreenState();
}

class _ItineraryScreenState extends ConsumerState<ItineraryScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final itineraryAsync = ref.watch(itineraryProvider(widget.itineraryId));

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(),
        title: Text('Paris Trip 2026'),
        actions: [
          IconButton(
            icon: Icon(Icons.share),
            onPressed: () => _shareItinerary(context),
          ),
          PopupMenuButton<String>(
            onSelected: (value) => _handleMenuAction(context, value),
            itemBuilder: (context) => [
              PopupMenuItem(value: 'duplicate', child: Text('Duplicate Trip')),
              PopupMenuItem(value: 'export', child: Text('Export PDF')),
              PopupMenuItem(value: 'settings', child: Text('Trip Settings')),
            ],
          ),
        ],
      ),
      body: itineraryAsync.when(
        data: (itinerary) => _buildItinerary(context, itinerary),
        loading: () => Center(child: CircularProgressIndicator()),
        error: (error, stack) => ErrorWidget(error),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddItemModal(context),
        icon: Icon(Icons.add),
        label: Text('Add Item'),
      ),
    );
  }

  Widget _buildItinerary(BuildContext context, Itinerary itinerary) {
    return Column(
      children: [
        // Header with dates and progress
        _buildHeader(context, itinerary),

        // View tabs (Calendar, Map, List)
        _buildViewTabs(context, itinerary),

        // Content
        Expanded(
          child: DefaultTabController(
            length: 3,
            child: TabBarView(
              children: [
                _buildListView(context, itinerary),
                _buildMapView(context, itinerary),
                _buildCalendarView(context, itinerary),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context, Itinerary itinerary) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).dividerColor,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${_formatDateRange(itinerary.dateRange)}',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          SizedBox(height: 8),
          LinearProgressIndicator(
            value: itinerary.completionPercentage / 100,
          ),
          SizedBox(height: 4),
          Text(
            'Progress: ${itinerary.completionPercentage.toInt()}% complete',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildViewTabs(BuildContext context, Itinerary itinerary) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
      ),
      child: TabBar(
        tabs: [
          Tab(text: '📅 List', icon: Icon(Icons.list)),
          Tab(text: '🗺️ Map', icon: Icon(Icons.map)),
          Tab(text: '📋 Calendar', icon: Icon(Icons.calendar_month)),
        ],
      ),
    );
  }

  Widget _buildListView(BuildContext context, Itinerary itinerary) {
    final dates = itinerary.uniqueDates;

    return ListView.builder(
      controller: _scrollController,
      padding: EdgeInsets.all(16),
      itemCount: dates.length,
      itemBuilder: (context, index) {
        final date = dates[index];
        final items = itinerary.getItemsForDate(date);

        return DayExpansionTile(
          date: date,
          items: items,
          destination: itinerary.destination,
          onTapItem: (item) => _showItemDetails(context, item),
          onToggleComplete: (item) => _toggleItemComplete(context, item),
          onEditItem: (item) => _editItem(context, item),
          onDeleteItem: (item) => _deleteItem(context, item),
        );
      },
    );
  }

  Widget _buildMapView(BuildContext context, Itinerary itinerary) {
    return ItineraryMapView(
      itinerary: itinerary,
      onTapItem: (item) => _showItemDetails(context, item),
    );
  }

  Widget _buildCalendarView(BuildContext context, Itinerary itinerary) {
    return ItineraryCalendarView(
      itinerary: itinerary,
      onTapDate: (date) {
        final items = itinerary.getItemsForDate(date);
        _showDayItems(context, date, items);
      },
    );
  }

  void _showAddItemModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => AddItineraryItemModal(
        itineraryId: widget.itineraryId,
        onItemAdded: () {
          ref.invalidate(itineraryProvider(widget.itineraryId));
        },
      ),
    );
  }

  void _showItemDetails(BuildContext context, ItineraryItem item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => ItineraryItemDetailSheet(item: item),
    );
  }

  Future<void> _toggleItemComplete(
    BuildContext context,
    ItineraryItem item,
  ) async {
    final updatedItem = item.map(
      flight: (i) => i.copyWith(isCompleted: !i.isCompleted),
      accommodation: (i) => i.copyWith(isCompleted: !i.isCompleted),
      activity: (i) => i.copyWith(isCompleted: !i.isCompleted),
      restaurant: (i) => i.copyWith(isCompleted: !i.isCompleted),
      transport: (i) => i.copyWith(isCompleted: !i.isCompleted),
    );

    final result = await ref.read(
      updateItineraryItemProvider(
        itineraryId: widget.itineraryId,
        item: updatedItem,
      ).future,
    );

    result.fold(
      (failure) => _showError(context, failure),
      (_) => ref.invalidate(itineraryProvider(widget.itineraryId)),
    );
  }

  void _editItem(BuildContext context, ItineraryItem item) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditItineraryItemScreen(
          itineraryId: widget.itineraryId,
          item: item,
        ),
      ),
    );
  }

  Future<void> _deleteItem(
    BuildContext context,
    ItineraryItem item,
  ) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Item?'),
        content: Text('This will remove "${item.getName()}" from your itinerary.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    final result = await ref.read(
      removeItineraryItemProvider(
        itineraryId: widget.itineraryId,
        itemId: item.getId(),
      ).future,
    );

    result.fold(
      (failure) => _showError(context, failure),
      (_) => ref.invalidate(itineraryProvider(widget.itineraryId)),
    );
  }

  void _handleMenuAction(BuildContext context, String action) {
    switch (action) {
      case 'duplicate':
        // Handle duplicate
        break;
      case 'export':
        // Handle export
        break;
      case 'settings':
        // Handle settings
        break;
    }
  }

  void _showError(BuildContext context, Failure failure) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(failure.toString())),
    );
  }

  String _formatDateRange(DateRange range) {
    return '${_formatDate(range.start)} - ${_formatDate(range.end)}';
  }

  String _formatDate(DateTime date) {
    return '${DateFormat.MMMd().format(date)}';
  }
}

// lib/features/itinerary/presentation/widgets/day_expansion_tile.dart
class DayExpansionTile extends StatefulWidget {
  final DateTime date;
  final List<ItineraryItem> items;
  final Destination destination;
  final void Function(ItineraryItem) onTapItem;
  final void Function(ItineraryItem) onToggleComplete;
  final void Function(ItineraryItem) onEditItem;
  final void Function(ItineraryItem) onDeleteItem;

  const DayExpansionTile({
    required this.date,
    required this.items,
    required this.destination,
    required this.onTapItem,
    required this.onToggleComplete,
    required this.onEditItem,
    required this.onDeleteItem,
    super.key,
  });

  @override
  State<DayExpansionTile> createState() => _DayExpansionTileState();
}

class _DayExpansionTileState extends State<DayExpansionTile> {
  bool _isExpanded = true;
  bool _isReordering = false;

  @override
  Widget build(BuildContext context) {
    final weatherAsync = ref.watch(weatherProvider(
      widget.destination,
      DateRange(start: widget.date, end: widget.date.add(Duration(days: 1))),
    ));

    return Card(
      margin: EdgeInsets.only(bottom: 12),
      child: Column(
        children: [
          // Header
          ListTile(
            leading: Text(
              '${widget.date.day}',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            title: Text(
              DateFormat.EEEE().format(widget.date),
              style: Theme.of(context).textTheme.titleMedium,
            ),
            subtitle: weatherAsync.when(
              data: (weather) {
                if (weather.isEmpty) return Text('Weather not available');
                final w = weather.first;
                final hasRain = w.precipitation > 0.5;
                return Text(
                  '${w.temperature.toStringAsFixed(0)}°C'
                  '${hasRain ? ' • Rain expected' : ''}',
                  style: TextStyle(
                    color: hasRain ? Colors.orange : null,
                  ),
                );
              },
              loading: () => Text('Loading weather...'),
              error: (_, __) => Text('Weather unavailable'),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (!_isReordering)
                  IconButton(
                    icon: Icon(Icons.more_vert),
                    onPressed: () => _showDayMenu(context),
                  ),
                IconButton(
                  icon: Icon(_isExpanded ? Icons.expand_less : Icons.expand_more),
                  onPressed: () {
                    setState(() => _isExpanded = !_isExpanded);
                  },
                ),
              ],
            ),
          ),

          // Items
          if (_isExpanded)
            _isReordering
                ? _buildReorderableList()
                : _buildItemList(),
        ],
      ),
    );
  }

  Widget _buildItemList() {
    if (widget.items.isEmpty) {
      return Padding(
        padding: EdgeInsets.all(16),
        child: Text(
          'No activities planned',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
        ),
      );
    }

    return ReorderableListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: widget.items.length,
      onReorder: (oldIndex, newIndex) {
        // Handle reorder
      },
      itemBuilder: (context, index) {
        final item = widget.items[index];
        return ItineraryItemTile(
          key: ValueKey(item.getId()),
          item: item,
          onTap: () => widget.onTapItem(item),
          onToggleComplete: () => widget.onToggleComplete(item),
          onEdit: () => widget.onEditItem(item),
          onDelete: () => widget.onDeleteItem(item),
        );
      },
    );
  }

  Widget _buildReorderableList() {
    return Container(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          Text('Drag items to reorder'),
          // Reorderable list implementation
        ],
      ),
    );
  }

  void _showDayMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.psychology),
              title: Text('Get AI Suggestions'),
              onTap: () {
                Navigator.pop(context);
                _showAISuggestions(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.swap_vert),
              title: Text('Reorder Items'),
              onTap: () {
                Navigator.pop(context);
                setState(() => _isReordering = true);
              },
            ),
            ListTile(
              leading: Icon(Icons.content_copy),
              title: Text('Duplicate Day'),
              onTap: () {
                Navigator.pop(context);
                // Handle duplicate
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showAISuggestions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => AISuggestionsSheet(
        date: widget.date,
        destination: widget.destination,
        itineraryId: '', // Pass from parent
      ),
    );
  }
}

// lib/features/itinerary/presentation/widgets/itinerary_item_tile.dart
class ItineraryItemTile extends StatelessWidget {
  final ItineraryItem item;
  final VoidCallback onTap;
  final VoidCallback onToggleComplete;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const ItineraryItemTile({
    required this.item,
    required this.onTap,
    required this.onToggleComplete,
    required this.onEdit,
    required this.onDelete,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: Border(
            left: BorderSide(
              color: item.isCompleted ? Colors.green : Colors.grey[300]!,
              width: 4,
            ),
          ),
        ),
        child: Row(
          children: [
            // Icon based on type
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: _getIconColor().withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(_getIcon(), color: _getIconColor()),
            ),
            SizedBox(width: 12),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _getTitle(),
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          decoration: item.isCompleted
                              ? TextDecoration.lineThrough
                              : null,
                        ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    _getSubtitle(),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                ],
              ),
            ),

            // Time
            Text(
              _formatTime(item.scheduledAt),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
            SizedBox(width: 8),

            // Actions
            PopupMenuButton<String>(
              onSelected: (value) {
                switch (value) {
                  case 'complete':
                    onToggleComplete();
                    break;
                  case 'edit':
                    onEdit();
                    break;
                  case 'delete':
                    onDelete();
                    break;
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'complete',
                  child: Text(item.isCompleted ? 'Mark Incomplete' : 'Complete'),
                ),
                PopupMenuItem(value: 'edit', child: Text('Edit')),
                PopupMenuItem(value: 'delete', child: Text('Delete')),
              ],
            ),
          ],
        ),
      ),
    );
  }

  IconData _getIcon() {
    return item.map(
      flight: (_) => Icons.flight,
      accommodation: (_) => Icons.hotel,
      activity: (_) => Icons.attractions,
      restaurant: (_) => Icons.restaurant,
      transport: (_) => Icons.directions_transit,
    );
  }

  Color _getIconColor() {
    return item.map(
      flight: (_) => Colors.blue,
      accommodation: (_) => Colors.purple,
      activity: (_) => Colors.orange,
      restaurant: (_) => Colors.red,
      transport: (_) => Colors.green,
    );
  }

  String _getTitle() {
    return item.map(
      flight: (i) => '${i.airline} ${i.flightNumber}',
      accommodation: (i) => i.name,
      activity: (i) => i.name,
      restaurant: (i) => i.name,
      transport: (i) => i.description,
    );
  }

  String _getSubtitle() {
    return item.map(
      flight: (i) => '${i.airportCode}${i.terminal != null ? ' • Terminal ${i.terminal}' : ''}',
      accommodation: (i) => i.address,
      activity: (i) => i.description,
      restaurant: (i) => '${i.cuisine} • ${i.mealType.name}',
      transport: (i) => i.notes ?? '',
    );
  }

  String _formatTime(DateTime time) {
    return DateFormat.Hm().format(time);
  }
}

// lib/features/itinerary/presentation/screens/add_itinerary_item_modal.dart
class AddItineraryItemModal extends ConsumerStatefulWidget {
  final String itineraryId;
  final VoidCallback onItemAdded;

  const AddItineraryItemModal({
    required this.itineraryId,
    required this.onItemAdded,
    super.key,
  });

  @override
  ConsumerState<AddItineraryItemModal> createState() =>
      _AddItineraryItemModalState();
}

class _AddItineraryItemModalState extends ConsumerState<AddItineraryItemModal> {
  ItemType? _selectedType;

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Handle
              Center(
                child: Container(
                  margin: EdgeInsets.symmetric(vertical: 12),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // Title
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  children: [
                    Text(
                      'Add to Itinerary',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    Spacer(),
                    IconButton(
                      icon: Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),

              // Content
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (_selectedType == null) ...[
                        Text(
                          'What type of item?',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        SizedBox(height: 16),
                        _buildItemTypeGrid(),
                      ] else
                        _buildItemTypeForm(),
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

  Widget _buildItemTypeGrid() {
    final types = [
      (ItemType.flight, '✈️', 'Flight'),
      (ItemType.hotel, '🏨', 'Hotel'),
      (ItemType.food, '🍽️', 'Food'),
      (ItemType.event, '🎭', 'Event'),
      (ItemType.transport, '🚗', 'Transport'),
      (ItemType.attraction, '🏛️', 'Attraction'),
      (ItemType.activity, '🥾', 'Activity'),
      (ItemType.shopping, '🛍️', 'Shopping'),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        childAspectRatio: 1,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: types.length,
      itemBuilder: (context, index) {
        final (type, emoji, label) = types[index];
        return InkWell(
          onTap: () => setState(() => _selectedType = type),
          child: Card(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  emoji,
                  style: TextStyle(fontSize: 32),
                ),
                SizedBox(height: 4),
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildItemTypeForm() {
    switch (_selectedType!) {
      case ItemType.activity:
        return ActivityItemForm(
          itineraryId: widget.itineraryId,
          onItemAdded: () {
            widget.onItemAdded();
            Navigator.pop(context);
          },
          onBackPressed: () => setState(() => _selectedType = null),
        );
      case ItemType.food:
        return RestaurantItemForm(
          itineraryId: widget.itineraryId,
          onItemAdded: () {
            widget.onItemAdded();
            Navigator.pop(context);
          },
          onBackPressed: () => setState(() => _selectedType = null),
        );
      // ... other types
      default:
        return Container();
    }
  }
}

enum ItemType {
  flight,
  hotel,
  food,
  event,
  transport,
  attraction,
  activity,
  shopping,
}
```

---

## Providers

```dart
// lib/features/itinerary/presentation/providers/itinerary_providers.dart
@riverpod
ItineraryRepository itineraryRepository(ItineraryRepositoryRef ref) {
  return ItineraryRepositoryImpl(
    dataSource: ref.watch(itineraryRemoteDataSourceProvider),
    localDataSource: ref.watch(itineraryLocalDataSourceProvider),
    networkInfo: ref.watch(networkInfoProvider),
  );
}

@riverpod
Future<Itinerary> itinerary(ItineraryRef ref, String id) async {
  final repository = ref.watch(itineraryRepositoryProvider);
  final result = await repository.getItinerary(id);
  return result.fold(
    (failure) => throw failure,
    (itinerary) => itinerary,
  );
}

@riverpod
AddItineraryItem addItineraryItem(AddItineraryItemRef ref) {
  return AddItineraryItem(ref.watch(itineraryRepositoryProvider));
}

@riverpod
Future<Itinerary> updateItineraryItem(
  UpdateItineraryItemRef ref, {
  required String itineraryId,
  required ItineraryItem item,
}) async {
  final addItem = ref.watch(addItineraryItemProvider);
  final result = await addItem(itineraryId: itineraryId, item: item);
  return result.fold(
    (failure) => throw failure,
    (itinerary) => itinerary,
  );
}

@riverpod
UpdateItineraryItem updateItineraryItem(UpdateItineraryItemRef ref) {
  return UpdateItineraryItem(ref.watch(itineraryRepositoryProvider));
}

@riverpod
Future<Itinerary> updateItineraryItem(
  UpdateItineraryItemRef ref, {
  required String itineraryId,
  required ItineraryItem item,
}) async {
  final updateItem = ref.watch(updateItineraryItemProvider);
  final result = await updateItem(itineraryId: itineraryId, item: item);
  return result.fold(
    (failure) => throw failure,
    (itinerary) => itinerary,
  );
}

@riverpod
RemoveItineraryItem removeItineraryItem(RemoveItineraryItemRef ref) {
  return RemoveItineraryItem(ref.watch(itineraryRepositoryProvider));
}

@riverpod
Future<Itinerary> removeItineraryItem(
  RemoveItineraryItemRef ref, {
  required String itineraryId,
  required String itemId,
}) async {
  final removeItem = ref.watch(removeItineraryItemProvider);
  final result = await removeItem(itineraryId: itineraryId, itemId: itemId);
  return result.fold(
    (failure) => throw failure,
    (itinerary) => itinerary,
  );
}

@riverpod
ReorderItineraryItems reorderItineraryItems(ReorderItineraryItemsRef ref) {
  return ReorderItineraryItems(ref.watch(itineraryRepositoryProvider));
}

@riverpod
OptimizeItinerary optimizeItinerary(OptimizeItineraryRef ref) {
  return OptimizeItinerary(
    ItineraryOptimizer(
      weatherService: ref.watch(weatherServiceProvider),
      locationService: ref.watch(locationServiceProvider),
      placesService: ref.watch(placesServiceProvider),
    ),
  );
}

@riverpod
SmartSuggestionService smartSuggestionService(SmartSuggestionServiceRef ref) {
  return SmartSuggestionService(
    placesService: ref.watch(placesServiceProvider),
    weatherService: ref.watch(weatherServiceProvider),
    userProfileService: ref.watch(userProfileServiceProvider),
  );
}
```

---

## Testing

### Unit Tests

```dart
// test/features/itinerary/domain/usecases/add_itinerary_item_test.dart
void main() {
  late AddItineraryItem useCase;
  late MockItineraryRepository mockRepository;

  setUp(() {
    mockRepository = MockItineraryRepository();
    useCase = AddItineraryItem(mockRepository);
  });

  group('AddItineraryItem', () {
    final tItineraryId = 'itinerary-123';
    final tItem = ItineraryItem.activity(
      id: 'item-123',
      scheduledAt: DateTime(2026, 5, 12, 10),
      type: ActivityType.attraction,
      name: 'Louvre Museum',
      description: 'World-famous art museum',
    );

    test('should add item to itinerary', () async {
      // arrange
      when(() => mockRepository.addItem(
        itineraryId: any(named: 'itineraryId'),
        item: any(named: 'item'),
      )).thenAnswer((_) async => Right(mockItinerary));

      // act
      final result = await useCase(
        itineraryId: tItineraryId,
        item: tItem,
      );

      // assert
      expect(result.isRight(), true);
      verify(() => mockRepository.addItem(
        itineraryId: tItineraryId,
        item: tItem,
      )).called(1);
    });
  });
}
```

### Widget Tests

```dart
// test/features/itinerary/presentation/widgets/itinerary_item_tile_test.dart
void main() {
  testWidgets('should display item details', (tester) async {
    final item = ItineraryItem.activity(
      id: 'item-123',
      scheduledAt: DateTime(2026, 5, 12, 10, 30),
      type: ActivityType.attraction,
      name: 'Louvre Museum',
      description: 'World-famous art museum',
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ItineraryItemTile(
            item: item,
            onTap: () {},
            onToggleComplete: () {},
            onEdit: () {},
            onDelete: () {},
          ),
        ),
      ),
    );

    expect(find.text('Louvre Museum'), findsOneWidget);
    expect(find.text('World-famous art museum'), findsOneWidget);
    expect(find.text('10:30'), findsOneWidget);
    expect(find.byIcon(Icons.attractions), findsOneWidget);
  });
}
```

---

## Dependencies for Next Features

**Enables:**
- Feature 3: AI Recommendations (uses itinerary data for suggestions)
- Feature 4: Contextual Notifications (sends alerts for itinerary items)
- Feature 9: Meaningful Progress Tracking (tracks completion)

---

## Success Metrics

| Metric | Target | How to Measure |
|--------|--------|----------------|
| Session duration | 10+ minutes | Time spent editing per session |
| Return rate | 60%+ | Users who edit again within 24 hours |
| Edit actions | 5+ per session | Add/edit/delete/reorder actions |
| Optimization acceptance | 30%+ | Users who apply AI suggestions |

---

## Implementation Checklist

### Week 1: Core Functionality
- [ ] Domain entities (Itinerary, ItineraryItem, etc.)
- [ ] Repository interface and implementation
- [ ] CRUD use cases (Add, Update, Remove, Reorder)
- [ ] Basic UI (ItineraryScreen, DayExpansionTile)
- [ ] Item tiles for each type

### Week 2: Smart Features
- [ ] ItineraryOptimizer service
- [ ] SmartSuggestionService
- [ ] AI Suggestions bottom sheet
- [ ] Weather-based optimizations
- [ ] Geographic clustering
- [ ] Reorder mode with drag & drop

### Week 3: Polish
- [ ] Map view integration
- [ ] Calendar view
- [ ] Share functionality
- [ ] Offline support (cache itinerary)
- [ ] Performance optimization
- [ ] Testing

---

## Sources

- [Flutter ReorderableListView Documentation](https://api.flutter.dev/flutter/widgets/ReorderableListView-class.html)
- [Drag and Drop in Flutter](https://docs.flutter.dev/cookbook/effects/drag-to-scroll)
