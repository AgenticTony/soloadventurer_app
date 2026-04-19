import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:soloadventurer/core/services/places_service.dart';
import 'package:soloadventurer/core/services/viator_service.dart';
import 'package:soloadventurer/features/onboarding/domain/entities/destination.dart';
import 'package:soloadventurer/features/travel/domain/models/place_activity.dart';

part 'unified_discovery_provider.g.dart';

/// Source of a place/activity result.
enum PlaceSource {
  /// From Google Places API (restaurants, cafes, landmarks, POIs).
  googlePlaces,

  /// From Viator Transactional API (tours, experiences, bookable activities).
  viator,
}

/// A unified place result from either Google Places or Viator.
class UnifiedPlaceResult {
  /// The underlying PlaceActivity.
  final PlaceActivity activity;

  /// Which API provided this result.
  final PlaceSource source;

  /// Viator product code (only set for Viator results).
  final String? viatorProductCode;

  /// Whether this is a bookable Viator activity.
  bool get isBookable => source == PlaceSource.viator;

  /// Whether this result has a price.
  bool get hasPrice => activity.cost != null && activity.cost! > 0;

  /// Formatted price string.
  String? get formattedPrice {
    if (!hasPrice) return null;
    if (activity.cost == 0) return 'Free';
    return '\$${activity.cost!.toStringAsFixed(0)}';
  }

  const UnifiedPlaceResult({
    required this.activity,
    required this.source,
    this.viatorProductCode,
  });
}

/// Category tabs for the unified discovery view.
enum DiscoveryTab {
  /// Restaurants, cafes, bars.
  eatDrink('Eat & Drink'),

  /// Tours, experiences, classes.
  thingsToDo('Things to Do'),

  /// Landmarks, museums, parks.
  sights('Sights');

  final String label;

  const DiscoveryTab(this.label);
}

/// State for the unified discovery view.
class UnifiedDiscoveryState {
  /// Results per tab.
  final Map<DiscoveryTab, List<UnifiedPlaceResult>> tabResults;

  /// Loading state per tab.
  final Map<DiscoveryTab, bool> loading;

  /// Error message per tab (null = no error).
  final Map<DiscoveryTab, String?> errors;

  /// Currently active tab.
  final DiscoveryTab activeTab;

  /// Search query.
  final String searchQuery;

  /// The destination being searched.
  final Destination? destination;

  const UnifiedDiscoveryState({
    this.tabResults = const {},
    this.loading = const {},
    this.errors = const {},
    this.activeTab = DiscoveryTab.eatDrink,
    this.searchQuery = '',
    this.destination,
  });

  /// Get results for the active tab.
  List<UnifiedPlaceResult> get activeResults =>
      tabResults[activeTab] ?? const [];

  /// Whether the active tab is loading.
  bool get isActiveLoading => loading[activeTab] ?? false;

  /// Error for the active tab.
  String? get activeError => errors[activeTab];

  /// Whether the active tab has results.
  bool get hasActiveResults => activeResults.isNotEmpty;

  UnifiedDiscoveryState copyWith({
    Map<DiscoveryTab, List<UnifiedPlaceResult>>? tabResults,
    Map<DiscoveryTab, bool>? loading,
    Map<DiscoveryTab, String?>? errors,
    DiscoveryTab? activeTab,
    String? searchQuery,
    Destination? destination,
  }) {
    return UnifiedDiscoveryState(
      tabResults: tabResults ?? this.tabResults,
      loading: loading ?? this.loading,
      errors: errors ?? this.errors,
      activeTab: activeTab ?? this.activeTab,
      searchQuery: searchQuery ?? this.searchQuery,
      destination: destination ?? this.destination,
    );
  }
}

/// Provider for unified discovery combining Google Places + Viator.
@riverpod
class UnifiedDiscovery extends _$UnifiedDiscovery {
  @override
  Future<UnifiedDiscoveryState> build() async {
    return const UnifiedDiscoveryState();
  }

  /// Set the active tab.
  void setTab(DiscoveryTab tab) {
    final current = state.value;
    if (current == null) return;

    state = AsyncValue.data(current.copyWith(activeTab: tab));

    // Load if not yet loaded for this tab
    if (!(current.tabResults.containsKey(tab)) && current.destination != null) {
      _loadForTab(tab);
    }
  }

  /// Set the search destination and query.
  Future<void> search({
    required Destination destination,
    String query = '',
  }) async {
    final current = state.value;
    if (current == null) return;

    state = AsyncValue.data(current.copyWith(
      destination: destination,
      searchQuery: query,
    ));

    // Load all tabs
    await Future.wait([
      _loadForTab(DiscoveryTab.eatDrink),
      _loadForTab(DiscoveryTab.thingsToDo),
      _loadForTab(DiscoveryTab.sights),
    ]);
  }

  /// Refresh the active tab.
  Future<void> refreshActiveTab() async {
    final current = state.value;
    if (current == null || current.destination == null) return;
    await _loadForTab(current.activeTab);
  }

  /// Refresh all tabs.
  Future<void> refreshAll() async {
    final current = state.value;
    if (current == null || current.destination == null) return;

    await Future.wait([
      _loadForTab(DiscoveryTab.eatDrink),
      _loadForTab(DiscoveryTab.thingsToDo),
      _loadForTab(DiscoveryTab.sights),
    ]);
  }

  Future<void> _loadForTab(DiscoveryTab tab) async {
    final current = state.value;
    if (current == null || current.destination == null) return;

    // Set loading for this tab
    state = AsyncValue.data(current.copyWith(
      loading: {...current.loading, tab: true},
      errors: {...current.errors, tab: null},
    ));

    try {
      List<UnifiedPlaceResult> results;

      switch (tab) {
        case DiscoveryTab.eatDrink:
          results = await _loadEatDrink(current.destination!, current.searchQuery);
        case DiscoveryTab.thingsToDo:
          results = await _loadThingsToDo(current.destination!, current.searchQuery);
        case DiscoveryTab.sights:
          results = await _loadSights(current.destination!, current.searchQuery);
      }

      final updated = state.value;
      if (updated == null) return;

      state = AsyncValue.data(updated.copyWith(
        tabResults: {...updated.tabResults, tab: results},
        loading: {...updated.loading, tab: false},
      ));
    } catch (e) {
      final updated = state.value;
      if (updated == null) return;

      state = AsyncValue.data(updated.copyWith(
        loading: {...updated.loading, tab: false},
        errors: {...updated.errors, tab: e.toString()},
      ));
    }
  }

  Future<List<UnifiedPlaceResult>> _loadEatDrink(
    Destination destination,
    String query,
  ) async {
    final placesService = ref.read(placesServiceProvider);

    final searches = <String>[
      query.isNotEmpty ? '$query restaurants' : 'restaurants',
      query.isNotEmpty ? '$query cafes' : 'cafes',
    ];

    final allResults = <UnifiedPlaceResult>[];
    final seenIds = <String>{};

    for (final searchQuery in searches) {
      final places = await placesService.searchPlaces(
        query: searchQuery,
        destination: destination,
        radius: 5000,
      );

      for (final place in places) {
        if (seenIds.add(place.id)) {
          allResults.add(UnifiedPlaceResult(
            activity: place,
            source: PlaceSource.googlePlaces,
          ));
        }
      }
    }

    return allResults;
  }

  Future<List<UnifiedPlaceResult>> _loadThingsToDo(
    Destination destination,
    String query,
  ) async {
    final viatorService = ref.read(viatorServiceProvider);

    // First, search for the Viator destination ID
    final viatorDests = await viatorService.searchDestinations(destination.name);
    final destId = viatorDests.isNotEmpty ? viatorDests.first.id : '';

    if (destId.isEmpty) {
      // Fallback: use Google Places for tours
      final placesService = ref.read(placesServiceProvider);
      final places = await placesService.searchPlaces(
        query: query.isNotEmpty ? '$query tours activities' : 'tours activities',
        destination: destination,
        radius: 10000,
      );
      return places
          .map((p) => UnifiedPlaceResult(
                activity: p,
                source: PlaceSource.googlePlaces,
              ))
          .toList();
    }

    // Search Viator for bookable experiences
    final viatorResult = await viatorService.searchProducts(
      destinationId: destId,
      filter: ViatorSearchFilter(query: query.isNotEmpty ? query : null),
    );

    return viatorResult.products
        .map((product) => UnifiedPlaceResult(
              activity: product,
              source: PlaceSource.viator,
              viatorProductCode: product.id,
            ))
        .toList();
  }

  Future<List<UnifiedPlaceResult>> _loadSights(
    Destination destination,
    String query,
  ) async {
    final placesService = ref.read(placesServiceProvider);

    final searches = <String>[
      query.isNotEmpty ? '$query landmarks' : 'landmarks tourist attractions',
      query.isNotEmpty ? '$query museums' : 'museums',
    ];

    final allResults = <UnifiedPlaceResult>[];
    final seenIds = <String>{};

    for (final searchQuery in searches) {
      final places = await placesService.searchPlaces(
        query: searchQuery,
        destination: destination,
        radius: 5000,
      );

      for (final place in places) {
        if (seenIds.add(place.id)) {
          allResults.add(UnifiedPlaceResult(
            activity: place,
            source: PlaceSource.googlePlaces,
          ));
        }
      }
    }

    return allResults;
  }
}
