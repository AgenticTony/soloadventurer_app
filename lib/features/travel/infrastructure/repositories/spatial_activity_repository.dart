import 'dart:async';
import 'package:latlong2/latlong.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:soloadventurer/core/models/map_marker.dart';
import '../../domain/models/activity.dart';

/// Geographic bounding box defined by cardinal directions
class Bounds {
  /// Southern latitude boundary
  final double south;

  /// Western longitude boundary
  final double west;

  /// Northern latitude boundary
  final double north;

  /// Eastern longitude boundary
  final double east;

  const Bounds({
    required this.south,
    required this.west,
    required this.north,
    required this.east,
  });

  /// Create from two corner points (southWest, northEast)
  factory Bounds.fromCorners(LatLng southWest, LatLng northEast) {
    return Bounds(
      south: southWest.latitude,
      west: southWest.longitude,
      north: northEast.latitude,
      east: northEast.longitude,
    );
  }
}

/// Result of a spatial query for activities within bounds
class SpatialQueryResult {
  /// Activities found within the specified bounds
  final List<Activity> activities;

  /// Total activities available in the database (for statistics)
  final int totalActivities;

  /// Query bounds
  final Bounds bounds;

  /// Whether result is from cache
  final bool isFromCache;

  /// Whether result was limited (truncated at maxMarkers)
  final bool isLimited;

  const SpatialQueryResult({
    required this.activities,
    required this.totalActivities,
    required this.bounds,
    this.isFromCache = false,
    this.isLimited = false,
  });

  /// Convert activities to map markers
  List<MapMarker> get markers {
    return activities
        .where((a) => a.latitude != null && a.longitude != null)
        .map((a) => MapMarker.fromActivity(
              activityId: a.id,
              title: a.title,
              latitude: a.latitude,
              longitude: a.longitude,
              description: a.locationName,
            ))
        .toList();
  }

  /// Get statistics about the query result
  Map<String, dynamic> get statistics => {
        'activitiesInBounds': activities.length,
        'totalActivities': totalActivities,
        'isFromCache': isFromCache,
        'isLimited': isLimited,
        'bounds': {
          'south': bounds.south,
          'west': bounds.west,
          'north': bounds.north,
          'east': bounds.east,
        },
      };

  /// Create empty result
  factory SpatialQueryResult.empty({
    required Bounds bounds,
    required int totalActivities,
  }) {
    return SpatialQueryResult(
      activities: [],
      totalActivities: totalActivities,
      bounds: bounds,
    );
  }

  /// Copy result with modified fields
  SpatialQueryResult copyWith({
    List<Activity>? activities,
    int? totalActivities,
    Bounds? bounds,
    bool? isFromCache,
    bool? isLimited,
  }) {
    return SpatialQueryResult(
      activities: activities ?? this.activities,
      totalActivities: totalActivities ?? this.totalActivities,
      bounds: bounds ?? this.bounds,
      isFromCache: isFromCache ?? this.isFromCache,
      isLimited: isLimited ?? this.isLimited,
    );
  }

}

/// Cache entry for viewport query results
class _ViewportCacheEntry {
  final Bounds bounds;
  final SpatialQueryResult result;
  final DateTime timestamp;

  _ViewportCacheEntry({
    required this.bounds,
    required this.result,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();
}

/// LRU cache for viewport query results
class _ViewportCache {
  final int maxSize;
  final List<_ViewportCacheEntry> _entries = [];
  final Duration _ttl;

  _ViewportCache({
    this.maxSize = 10,
    Duration ttl = const Duration(minutes: 5),
  }) : _ttl = ttl;

  /// Get cached result for bounds
  SpatialQueryResult? get(Bounds bounds) {
    _removeExpired();

    // Find exact or very similar bounds (within 5% tolerance)
    for (var i = 0; i < _entries.length; i++) {
      final entry = _entries[i];
      if (_boundsMatch(entry.bounds, bounds, tolerance: 0.05)) {
        // Move to end (most recently used)
        final entry = _entries.removeAt(i);
        _entries.add(entry);
        return entry.result;
      }
    }

    return null;
  }

  /// Put result in cache
  void put(Bounds bounds, SpatialQueryResult result) {
    _removeExpired();

    // Remove existing entry if present
    _entries.removeWhere((entry) => _boundsMatch(entry.bounds, bounds));

    // Add new entry
    _entries.add(_ViewportCacheEntry(
      bounds: bounds,
      result: result,
    ));

    // Evict oldest if over capacity
    while (_entries.length > maxSize) {
      _entries.removeAt(0);
    }
  }

  /// Clear all entries
  void clear() {
    _entries.clear();
  }

  /// Get current size
  int get size => _entries.length;

  /// Remove expired entries
  void _removeExpired() {
    final now = DateTime.now();
    _entries.removeWhere((entry) => now.difference(entry.timestamp) > _ttl);
  }

  /// Check if bounds match within tolerance
  bool _boundsMatch(Bounds a, Bounds b, {double tolerance = 0.05}) {
    final latTolerance = (a.north - a.south) * tolerance;
    final lngTolerance = (a.east - a.west) * tolerance;

    return (a.south - b.south).abs() < latTolerance &&
        (a.north - b.north).abs() < latTolerance &&
        (a.west - b.west).abs() < lngTolerance &&
        (a.east - b.east).abs() < lngTolerance;
  }
}

/// Repository for efficient spatial querying of activities within geographic bounds
///
/// This repository provides optimized spatial queries for map markers with:
/// - Database-level spatial filtering using latitude/longitude bounds
/// - Viewport-based caching to reduce redundant queries
/// - Debouncing for rapid pan/zoom operations
/// - Maximum marker limiting for clustering performance
///
/// **Performance Features:**
/// - Queries only activities within visible map bounds
/// - Caches recent viewport results (LRU with TTL)
/// - Debounces rapid map movements (200ms default)
/// - Limits results to max 1000 markers for clustering
/// - Integrates with database indexes for optimal query performance
///
/// **Spatial Query:**
/// Uses standard SQL bounding box query:
/// ```sql
/// WHERE latitude >= minLat AND latitude <= maxLat
///   AND longitude >= minLng AND longitude <= maxLng
/// ```
///
/// Example:
/// ```dart
/// final spatialRepo = SpatialActivityRepository(
///   supabaseClient: client,
///   maxMarkers: 1000,
///   debounceDelayMs: 200,
/// );
///
/// // Query activities within viewport
/// final result = await spatialRepo.getActivitiesInBounds(
///   bounds: Bounds(
///     south: 37.7,
///     west: -122.5,
///     north: 37.8,
///     east: -122.4,
///   ),
///   userId: 'user123',
///   tripId: 'trip456', // optional
/// );
///
/// // Get markers for clustering
/// final markers = result.markers;
/// ```
class SpatialActivityRepository {
  final SupabaseClient _client;
  final int maxMarkers;
  final int debounceDelayMs;

  /// Cache for viewport query results
  final _ViewportCache _cache;

  /// Debounce timer for rapid queries
  Timer? _debounceTimer;

  /// Stream controller for query results
  StreamController<SpatialQueryResult>? _resultController;

  /// Pending query to execute after debounce
  Bounds? _pendingBounds;
  String? _pendingUserId;
  String? _pendingTripId;

  /// Statistics tracking
  int _totalQueries = 0;
  int _cacheHits = 0;
  int _cacheMisses = 0;

  /// Create spatial activity repository
  ///
  /// Parameters:
  /// - [supabaseClient]: Initialized Supabase client
  /// - [maxMarkers]: Maximum markers to return (default: 1000)
  /// - [debounceDelayMs]: Debounce delay in milliseconds (default: 200)
  /// - [cacheSize]: Maximum number of cached viewports (default: 10)
  /// - [cacheTtl]: Time-to-live for cache entries (default: 5 minutes)
  SpatialActivityRepository({
    required SupabaseClient supabaseClient,
    this.maxMarkers = 1000,
    this.debounceDelayMs = 200,
    int cacheSize = 10,
    Duration cacheTtl = const Duration(minutes: 5),
  })  : _client = supabaseClient,
        _cache = _ViewportCache(
          maxSize: cacheSize,
          ttl: cacheTtl,
        );

  /// Stream of query results (for debounced queries)
  Stream<SpatialQueryResult> get resultStream {
    _resultController ??= StreamController<SpatialQueryResult>.broadcast();
    return _resultController!.stream;
  }

  /// Query activities within geographic bounds
  ///
  /// This method performs an immediate spatial query without debouncing.
  /// Use [queryActivitiesInBoundsDebounced] for reactive map updates.
  ///
  /// Parameters:
  /// - [bounds]: Geographic bounding box
  /// - [userId]: User ID to filter activities (required)
  /// - [tripId]: Optional trip ID to scope query
  /// - [useCache]: Whether to check cache first (default: true)
  ///
  /// Returns activities within bounds, limited to [maxMarkers].
  Future<SpatialQueryResult> getActivitiesInBounds({
    required Bounds bounds,
    required String userId,
    String? tripId,
    bool useCache = true,
  }) async {
    _totalQueries++;

    // Check cache first
    if (useCache) {
      final cachedResult = _cache.get(bounds);
      if (cachedResult != null) {
        _cacheHits++;
        return cachedResult;
      }
      _cacheMisses++;
    }

    // Perform spatial query
    final result = await _executeSpatialQuery(
      bounds: bounds,
      userId: userId,
      tripId: tripId,
    );

    // Cache the result
    _cache.put(bounds, result);

    return result;
  }

  /// Query activities within bounds with debouncing
  ///
  /// This method debounces rapid successive queries and emits results
  /// to the [resultStream]. Ideal for reactive map updates during pan/zoom.
  ///
  /// The query is executed after [debounceDelayMs] of no new bounds updates.
  ///
  /// Parameters:
  /// - [bounds]: Geographic bounding box
  /// - [userId]: User ID to filter activities (required)
  /// - [tripId]: Optional trip ID to scope query
  ///
  /// Use the [resultStream] to receive debounced results.
  void queryActivitiesInBoundsDebounced({
    required Bounds bounds,
    required String userId,
    String? tripId,
  }) {
    // Store pending query parameters
    _pendingBounds = bounds;
    _pendingUserId = userId;
    _pendingTripId = tripId;

    // Reset debounce timer
    _debounceTimer?.cancel();
    _debounceTimer = Timer(Duration(milliseconds: debounceDelayMs), () {
      _executeDebouncedQuery();
    });
  }

  /// Wait for pending debounced query to complete
  ///
  /// Use this to await the result of the latest debounced query.
  Future<SpatialQueryResult> waitForDebouncedQuery() async {
    if (_pendingBounds == null || _pendingUserId == null) {
      throw StateError('No debounced query pending');
    }

    // Wait for next result on stream
    final future = resultStream.first;

    // Ensure debounce timer is running
    if (_debounceTimer == null || !_debounceTimer!.isActive) {
      _executeDebouncedQuery();
    }

    return future;
  }

  /// Get total count of activities with location data
  ///
  /// Returns the total number of activities that have latitude/longitude
  /// for the given user and optional trip.
  Future<int> countActivitiesWithLocation({
    required String userId,
    String? tripId,
  }) async {
    var query = _client
        .from('activities')
        .select()
        .eq('userId', userId)
        .not('latitude', 'is', null)
        .not('longitude', 'is', null);

    if (tripId != null) {
      query = query.eq('tripId', tripId);
    }

    final response = await query;
    return (response as List).length;
  }

  /// Get statistics about query performance
  Map<String, dynamic> get statistics => {
        'totalQueries': _totalQueries,
        'cacheHits': _cacheHits,
        'cacheMisses': _cacheMisses,
        'cacheHitRate': _totalQueries > 0
            ? '${(_cacheHits / _totalQueries * 100).toStringAsFixed(1)}%'
            : '0%',
        'cacheSize': _cache.size,
        'maxCacheSize': 10,
        'maxMarkers': maxMarkers,
        'debounceDelayMs': debounceDelayMs,
      };

  /// Clear the viewport cache
  void clearCache() {
    _cache.clear();
  }

  /// Reset statistics
  void resetStatistics() {
    _totalQueries = 0;
    _cacheHits = 0;
    _cacheMisses = 0;
  }

  /// Dispose resources
  void dispose() {
    _debounceTimer?.cancel();
    _resultController?.close();
  }

  /// Execute spatial query against database
  Future<SpatialQueryResult> _executeSpatialQuery({
    required Bounds bounds,
    required String userId,
    String? tripId,
  }) async {
    // Build spatial query using bounding box
    final filterQuery = _client
        .from('activities')
        .select()
        .eq('userId', userId)
        .gte('latitude', bounds.south)
        .lte('latitude', bounds.north)
        .gte('longitude', bounds.west)
        .lte('longitude', bounds.east);

    // Add trip filter if provided (before transform operations)
    var filteredQuery = filterQuery;
    if (tripId != null) {
      filteredQuery = filteredQuery.eq('tripId', tripId);
    }

    final response =
        await filteredQuery.order('createdAt', ascending: false).limit(maxMarkers);

    // Parse activities from response
    final activities = (response as List)
        .map((json) => Activity.fromJson(json as Map<String, dynamic>))
        .toList();

    // Get total count for statistics
    final totalCount = await countActivitiesWithLocation(
      userId: userId,
      tripId: tripId,
    );

    return SpatialQueryResult(
      activities: activities,
      totalActivities: totalCount,
      bounds: bounds,
      isFromCache: false,
      isLimited: activities.length >= maxMarkers,
    );
  }

  /// Execute debounced query
  Future<void> _executeDebouncedQuery() async {
    if (_pendingBounds == null || _pendingUserId == null) {
      return;
    }

    final bounds = _pendingBounds!;
    final userId = _pendingUserId!;
    final tripId = _pendingTripId;

    // Clear pending parameters
    _pendingBounds = null;
    _pendingUserId = null;
    _pendingTripId = null;

    // Execute query
    final result = await getActivitiesInBounds(
      bounds: bounds,
      userId: userId,
      tripId: tripId,
      useCache: true,
    );

    // Emit to stream
    _resultController?.add(result);
  }
}
