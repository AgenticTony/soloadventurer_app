import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:soloadventurer/features/journal/data/datasources/journal_remote_data_source_impl.dart';
import 'package:soloadventurer/features/journal/data/repositories/journal_repository_impl.dart';
import 'package:soloadventurer/features/journal/domain/entities/journal_entry.dart';
import 'package:soloadventurer/features/journal/domain/repositories/journal_repository.dart';
import 'package:latlong2/latlong.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'journal_map_provider.g.dart';

// ============================================================================
// Dependency Injection Providers
// ============================================================================

/// Provides the Supabase client instance
@riverpod
SupabaseClient supabaseClient(Ref ref) {
  return Supabase.instance.client;
}

/// Provides the JournalRemoteDataSource implementation
@riverpod
JournalRemoteDataSourceImpl journalRemoteDataSource(Ref ref) {
  final client = ref.watch(supabaseClientProvider);
  return JournalRemoteDataSourceImpl(client: client);
}

/// Provides the JournalRepository implementation for map operations
@riverpod
JournalRepository journalMapRepository(Ref ref) {
  final remoteDataSource = ref.watch(journalRemoteDataSourceProvider);
  return JournalRepositoryImpl(remoteDataSource: remoteDataSource);
}

// ============================================================================
// Map Marker Data Model
// ============================================================================

/// Represents a journal entry location on the map
class JournalMapMarker {
  /// The journal entry
  final JournalEntry entry;

  /// The latitude/longitude position
  final LatLng position;

  /// Display label for the marker
  final String label;

  JournalMapMarker({
    required this.entry,
    required this.position,
    required this.label,
  });

  /// Creates a marker from a journal entry
  factory JournalMapMarker.fromEntry(JournalEntry entry) {
    final position = LatLng(entry.latitude!, entry.longitude!);
    final label = entry.locationName ??
        (entry.title.isNotEmpty ? entry.title : 'Untitled Entry');

    return JournalMapMarker(
      entry: entry,
      position: position,
      label: label,
    );
  }

  /// Calculates distance from another point in meters
  double distanceTo(LatLng point) {
    const Distance distance = Distance();
    return distance.as(LengthUnit.Meter, position, point);
  }
}

// ============================================================================
// Map View State
// ============================================================================

/// State for journal map view
class JournalMapState {
  /// All journal entries with location data
  final List<JournalEntry> entries;

  /// Map markers created from entries
  final List<JournalMapMarker> markers;

  /// Currently selected entry (if any)
  final JournalEntry? selectedEntry;

  /// Map center position
  final LatLng? centerPosition;

  /// Map zoom level
  final double zoomLevel;

  /// Loading state
  final bool isLoading;

  /// Error state
  final String? error;

  /// Filter: show only entries from specific trip
  final String? tripIdFilter;

  /// Filter: show only favorite entries
  final bool showOnlyFavorites;

  const JournalMapState({
    this.entries = const [],
    this.markers = const [],
    this.selectedEntry,
    this.centerPosition,
    this.zoomLevel = 13.0,
    this.isLoading = false,
    this.error,
    this.tripIdFilter,
    this.showOnlyFavorites = false,
  });

  JournalMapState copyWith({
    List<JournalEntry>? entries,
    List<JournalMapMarker>? markers,
    JournalEntry? Function()? selectedEntry,
    LatLng? Function()? centerPosition,
    double? zoomLevel,
    bool? isLoading,
    String? Function()? error,
    String? Function()? tripIdFilter,
    bool? showOnlyFavorites,
  }) {
    return JournalMapState(
      entries: entries ?? this.entries,
      markers: markers ?? this.markers,
      selectedEntry:
          selectedEntry != null ? selectedEntry() : this.selectedEntry,
      centerPosition:
          centerPosition != null ? centerPosition() : this.centerPosition,
      zoomLevel: zoomLevel ?? this.zoomLevel,
      isLoading: isLoading ?? this.isLoading,
      error: error != null ? error() : this.error,
      tripIdFilter: tripIdFilter != null ? tripIdFilter() : this.tripIdFilter,
      showOnlyFavorites: showOnlyFavorites ?? this.showOnlyFavorites,
    );
  }

  /// Whether there are any markers to display
  bool get hasMarkers => markers.isNotEmpty;

  /// Number of markers displayed
  int get markerCount => markers.length;

  /// Number of entries loaded
  int get entryCount => entries.length;

  /// Whether the map is loading
  bool get isInitialLoading => isLoading && entries.isEmpty;

  /// Whether an entry is selected
  bool get hasSelection => selectedEntry != null;
}

// ============================================================================
// Map View Notifier (Riverpod 3.0)
// ============================================================================

/// Notifier for managing journal map state
/// MIGRATION: StateNotifier → Notifier pattern
/// - Constructor logic moved to build() method
/// - Dependencies accessed via ref.watch() in methods
/// - Automatic provider generation via @riverpod annotation
@riverpod
class JournalMap extends _$JournalMap {
  @override
  JournalMapState build() {
    // Initial load happens automatically when provider is first accessed
    // Note: We don't call loadEntries() here to avoid issues during build
    return const JournalMapState();
  }

  /// Loads all journal entries with location data
  Future<void> loadEntries() async {
    final repository = ref.watch(journalMapRepositoryProvider);
    state = state.copyWith(
      isLoading: true,
      error: () => null,
    );

    try {
      final entries = await repository.getEntriesWithLocation();

      // Apply filters
      var filteredEntries = entries;
      if (state.tripIdFilter != null) {
        filteredEntries = entries
            .where((entry) => entry.tripId == state.tripIdFilter)
            .toList();
      }
      if (state.showOnlyFavorites) {
        filteredEntries =
            filteredEntries.where((entry) => entry.isFavorite).toList();
      }

      // Create markers from entries
      final markers = filteredEntries
          .map((entry) => JournalMapMarker.fromEntry(entry))
          .toList();

      // Calculate center position if not set
      LatLng? centerPosition;
      if (markers.isNotEmpty && state.centerPosition == null) {
        centerPosition = _calculateCenter(markers);
      }

      state = state.copyWith(
        entries: filteredEntries,
        markers: markers,
        centerPosition: () => centerPosition ?? state.centerPosition,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: () => e.toString(),
      );
    }
  }

  /// Loads entries for a specific trip
  Future<void> loadEntriesForTrip(String tripId) async {
    final repository = ref.watch(journalMapRepositoryProvider);
    state = state.copyWith(
      tripIdFilter: () => tripId,
      isLoading: true,
      error: () => null,
    );

    try {
      final entries = await repository.getEntriesByTrip(tripId);
      final entriesWithLocation = entries.where((e) => e.hasLocation).toList();

      final markers = entriesWithLocation
          .map((entry) => JournalMapMarker.fromEntry(entry))
          .toList();

      LatLng? centerPosition;
      if (markers.isNotEmpty) {
        centerPosition = _calculateCenter(markers);
      }

      state = state.copyWith(
        entries: entriesWithLocation,
        markers: markers,
        centerPosition: () => centerPosition,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: () => e.toString(),
      );
    }
  }

  /// Selects an entry on the map
  void selectEntry(JournalEntry entry) {
    state = state.copyWith(
      selectedEntry: () => entry,
    );
  }

  /// Clears the current selection
  void clearSelection() {
    state = state.copyWith(
      selectedEntry: () => null,
    );
  }

  /// Updates the map center position
  void updateCenter(LatLng position, {double? zoomLevel}) {
    state = state.copyWith(
      centerPosition: () => position,
      zoomLevel: zoomLevel,
    );
  }

  /// Updates the zoom level
  void updateZoom(double zoomLevel) {
    state = state.copyWith(
      zoomLevel: zoomLevel,
    );
  }

  /// Toggles the favorites filter
  void toggleFavoritesFilter() {
    final newValue = !state.showOnlyFavorites;
    state = state.copyWith(showOnlyFavorites: newValue);
    // Reload entries with new filter
    loadEntries();
  }

  /// Clears the trip filter
  void clearTripFilter() {
    if (state.tripIdFilter != null) {
      state = state.copyWith(tripIdFilter: () => null);
      loadEntries();
    }
  }

  /// Refreshes the map data
  Future<void> refresh() async {
    await loadEntries();
  }

  /// Clears any error state
  void clearError() {
    state = state.copyWith(error: () => null);
  }

  /// Calculates the center point of all markers
  LatLng _calculateCenter(List<JournalMapMarker> markers) {
    if (markers.isEmpty) {
      return const LatLng(0, 0);
    }

    double totalLat = 0;
    double totalLng = 0;

    for (final marker in markers) {
      totalLat += marker.position.latitude;
      totalLng += marker.position.longitude;
    }

    return LatLng(
      totalLat / markers.length,
      totalLng / markers.length,
    );
  }

  /// Finds entries near a specific location
  List<JournalEntry> findEntriesNearLocation(
    LatLng position, {
    double radiusKm = 10,
  }) {
    const Distance distance = Distance();

    return state.entries.where((entry) {
      if (!entry.hasLocation) return false;
      final entryPosition = LatLng(entry.latitude!, entry.longitude!);
      final dist = distance.as(LengthUnit.Kilometer, position, entryPosition);
      return dist <= radiusKm;
    }).toList();
  }

  /// Gets a marker for a specific entry
  JournalMapMarker? getMarkerForEntry(String entryId) {
    try {
      return state.markers.firstWhere(
        (marker) => marker.entry.id == entryId,
      );
    } catch (e) {
      return null;
    }
  }
}

// ============================================================================
// Family Provider for Trip-Scoped Map View (Riverpod 3.0)
// ============================================================================

/// Provider for journal map state scoped to a trip
/// MIGRATION: StateNotifierProvider.family → Notifier with family parameter
/// Usage: ref.watch(journalTripMapProvider(tripId))
@riverpod
class JournalTripMap extends _$JournalTripMap {
  @override
  JournalMapState build(String tripId) {
    // Load entries for the specific trip
    // Note: We can't call async methods in build(), so consumers should
    // explicitly call loadEntriesForTrip() when needed
    return const JournalMapState();
  }

  /// Loads entries for a specific trip
  Future<void> loadEntriesForTrip(String tripId) async {
    final repository = ref.watch(journalMapRepositoryProvider);
    state = state.copyWith(
      tripIdFilter: () => tripId,
      isLoading: true,
      error: () => null,
    );

    try {
      final entries = await repository.getEntriesByTrip(tripId);
      final entriesWithLocation = entries.where((e) => e.hasLocation).toList();

      final markers = entriesWithLocation
          .map((entry) => JournalMapMarker.fromEntry(entry))
          .toList();

      LatLng? centerPosition;
      if (markers.isNotEmpty) {
        centerPosition = _calculateCenter(markers);
      }

      state = state.copyWith(
        entries: entriesWithLocation,
        markers: markers,
        centerPosition: () => centerPosition,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: () => e.toString(),
      );
    }
  }

  /// Selects an entry on the map
  void selectEntry(JournalEntry entry) {
    state = state.copyWith(
      selectedEntry: () => entry,
    );
  }

  /// Clears the current selection
  void clearSelection() {
    state = state.copyWith(
      selectedEntry: () => null,
    );
  }

  /// Updates the map center position
  void updateCenter(LatLng position, {double? zoomLevel}) {
    state = state.copyWith(
      centerPosition: () => position,
      zoomLevel: zoomLevel,
    );
  }

  /// Updates the zoom level
  void updateZoom(double zoomLevel) {
    state = state.copyWith(
      zoomLevel: zoomLevel,
    );
  }

  /// Toggles the favorites filter
  void toggleFavoritesFilter() {
    final newValue = !state.showOnlyFavorites;
    state = state.copyWith(showOnlyFavorites: newValue);
    // Reload entries with new filter
    loadEntriesForTrip(state.tripIdFilter ?? tripId);
  }

  /// Refreshes the map data
  Future<void> refresh() async {
    await loadEntriesForTrip(state.tripIdFilter ?? tripId);
  }

  /// Clears any error state
  void clearError() {
    state = state.copyWith(error: () => null);
  }

  /// Calculates the center point of all markers
  LatLng _calculateCenter(List<JournalMapMarker> markers) {
    if (markers.isEmpty) {
      return const LatLng(0, 0);
    }

    double totalLat = 0;
    double totalLng = 0;

    for (final marker in markers) {
      totalLat += marker.position.latitude;
      totalLng += marker.position.longitude;
    }

    return LatLng(
      totalLat / markers.length,
      totalLng / markers.length,
    );
  }

  /// Finds entries near a specific location
  List<JournalEntry> findEntriesNearLocation(
    LatLng position, {
    double radiusKm = 10,
  }) {
    const Distance distance = Distance();

    return state.entries.where((entry) {
      if (!entry.hasLocation) return false;
      final entryPosition = LatLng(entry.latitude!, entry.longitude!);
      final dist = distance.as(LengthUnit.Kilometer, position, entryPosition);
      return dist <= radiusKm;
    }).toList();
  }

  /// Gets a marker for a specific entry
  JournalMapMarker? getMarkerForEntry(String entryId) {
    try {
      return state.markers.firstWhere(
        (marker) => marker.entry.id == entryId,
      );
    } catch (e) {
      return null;
    }
  }
}
