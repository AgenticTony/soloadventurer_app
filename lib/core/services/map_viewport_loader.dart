import 'dart:async';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../models/map_marker.dart';

/// Result of viewport marker loading operation
class ViewportLoadResult {
  /// Markers currently visible in viewport
  final List<MapMarker> visibleMarkers;

  /// Markers preloaded for adjacent areas (buffer zone)
  final List<MapMarker> preloadedMarkers;

  /// Total markers available (all markers in dataset)
  final int totalMarkers;

  /// Current viewport bounds
  final Bounds viewportBounds;

  /// Extended bounds including buffer zone
  final Bounds extendedBounds;

  /// Whether this result is from a cache
  final bool isFromCache;

  const ViewportLoadResult({
    required this.visibleMarkers,
    required this.preloadedMarkers,
    required this.totalMarkers,
    required this.viewportBounds,
    required this.extendedBounds,
    this.isFromCache = false,
  });

  /// All markers (visible + preloaded)
  List<MapMarker> get allMarkers => [...visibleMarkers, ...preloadedMarkers];

  /// Get statistics about the load result
  Map<String, dynamic> get statistics => {
        'visibleMarkers': visibleMarkers.length,
        'preloadedMarkers': preloadedMarkers.length,
        'totalMarkers': totalMarkers,
        'loadEfficiency': totalMarkers > 0
            ? '${(allMarkers.length / totalMarkers * 100).toStringAsFixed(1)}%'
            : '0%',
        'isFromCache': isFromCache,
      };

  /// Create empty result
  factory ViewportLoadResult.empty({
    required Bounds viewportBounds,
    required Bounds extendedBounds,
    required int totalMarkers,
  }) {
    return ViewportLoadResult(
      visibleMarkers: [],
      preloadedMarkers: [],
      totalMarkers: totalMarkers,
      viewportBounds: viewportBounds,
      extendedBounds: extendedBounds,
      isFromCache: false,
    );
  }

  /// Copy result with modified fields
  ViewportLoadResult copyWith({
    List<MapMarker>? visibleMarkers,
    List<MapMarker>? preloadedMarkers,
    int? totalMarkers,
    Bounds? viewportBounds,
    Bounds? extendedBounds,
    bool? isFromCache,
  }) {
    return ViewportLoadResult(
      visibleMarkers: visibleMarkers ?? this.visibleMarkers,
      preloadedMarkers: preloadedMarkers ?? this.preloadedMarkers,
      totalMarkers: totalMarkers ?? this.totalMarkers,
      viewportBounds: viewportBounds ?? this.viewportBounds,
      extendedBounds: extendedBounds ?? this.extendedBounds,
      isFromCache: isFromCache ?? this.isFromCache,
    );
  }
}

/// Service for loading map markers based on viewport with intelligent
/// buffering and caching for optimal performance.
///
/// This service improves performance for large datasets by:
/// 1. Loading only markers visible in current viewport
/// 2. Preloading markers in adjacent areas (buffer zone) for smooth panning
/// 3. Caching recently loaded viewports for rapid navigation
/// 4. Debouncing rapid map movements to avoid excessive reloading
///
/// Features:
/// - Configurable buffer zone size (percentage of viewport)
/// - LRU cache for recently loaded viewports
/// - Debounced loading with configurable delay
/// - Smooth marker addition/removal
/// - Stream-based updates for reactive UI
/// - Statistics tracking for performance monitoring
class MapViewportLoader {
  /// All markers available in the dataset
  final List<MapMarker> _allMarkers;

  /// Current viewport bounds
  Bounds? _currentBounds;

  /// Extended bounds including buffer zone
  Bounds? _extendedBounds;

  /// Current load result
  ViewportLoadResult? _currentResult;

  /// Buffer zone size as percentage of viewport (0.0 to 1.0)
  /// Default 0.3 means 30% buffer around visible viewport
  final double bufferRatio;

  /// Debounce timer for viewport changes
  Timer? _debounceTimer;

  /// Debounce delay in milliseconds
  final int debounceDelayMs;

  /// Stream controller for load results
  final StreamController<ViewportLoadResult> _resultController =
      StreamController<ViewportLoadResult>.broadcast();

  /// Stream of load results
  Stream<ViewportLoadResult> get resultStream => _resultController.stream;

  /// Current load result
  ViewportLoadResult? get currentResult => _currentResult;

  /// Whether loader has been initialized
  bool get isInitialized => _currentResult != null;

  /// Cache for recently loaded viewports (LRU eviction)
  final _ViewportCache _cache;

  /// Maximum cache size
  final int maxCacheSize;

  /// Statistics tracking
  int _totalLoads = 0;
  int _cacheHits = 0;
  int _cacheMisses = 0;

  /// Create map viewport loader
  ///
  /// Parameters:
  /// - [markers]: All available markers in the dataset
  /// - [bufferRatio]: Buffer zone size as percentage of viewport (default: 0.3 = 30%)
  /// - [debounceDelayMs]: Delay before reloading after viewport change (default: 200ms)
  /// - [maxCacheSize]: Maximum number of cached viewports (default: 10)
  MapViewportLoader({
    required List<MapMarker> markers,
    this.bufferRatio = 0.3,
    this.debounceDelayMs = 200,
    this.maxCacheSize = 10,
  })  : _allMarkers = markers,
        _cache = _ViewportCache(maxSize: maxCacheSize);

  /// Initialize loader with initial viewport bounds
  Future<ViewportLoadResult> initialize(Bounds initialBounds) async {
    return updateBounds(initialBounds, force: true);
  }

  /// Update viewport bounds and reload markers
  ///
  /// This method is debounced to avoid excessive reloading during
  /// rapid map movements. The actual loading happens after [debounceDelayMs].
  ///
  /// Parameters:
  /// - [bounds]: New viewport bounds
  /// - [force]: If true, bypasses debounce and forces immediate reload
  ///
  /// Returns the load result (or current result if debounced).
  Future<ViewportLoadResult> updateBounds(
    Bounds bounds, {
    bool force = false,
  }) async {
    // Check if bounds changed significantly
    if (_currentBounds != null &&
        !_boundsChangedSignificantly(_currentBounds!, bounds) &&
        !force) {
      return _currentResult!;
    }

    _currentBounds = bounds;

    // If not forcing, debounce the reload
    if (!force) {
      _debounceTimer?.cancel();
      _debounceTimer = Timer(
        Duration(milliseconds: debounceDelayMs),
        () => _performLoad(bounds),
      );
      return _currentResult ?? _createEmptyResult(bounds);
    }

    // Force immediate load
    return _performLoad(bounds);
  }

  /// Get markers for a specific viewport without updating state
  ///
  /// Useful for peeking at markers for a viewport without affecting
  /// the current loaded state.
  ViewportLoadResult peekViewport(Bounds bounds) {
    final extendedBounds = _calculateExtendedBounds(bounds);
    final markersInBounds = _filterMarkersInBounds(_allMarkers, extendedBounds);

    final visibleMarkers = _filterMarkersInBounds(_allMarkers, bounds);
    final preloadedMarkers =
        markersInBounds.where((m) => !visibleMarkers.contains(m)).toList();

    return ViewportLoadResult(
      visibleMarkers: visibleMarkers,
      preloadedMarkers: preloadedMarkers,
      totalMarkers: _allMarkers.length,
      viewportBounds: bounds,
      extendedBounds: extendedBounds,
      isFromCache: false,
    );
  }

  /// Wait for pending debounced load to complete
  Future<ViewportLoadResult> waitForLoadUpdate() async {
    if (_debounceTimer != null && _debounceTimer!.isActive) {
      _debounceTimer!;
    }

    if (_currentResult != null) {
      return _currentResult!;
    }

    throw StateError('Loader not initialized. Call initialize() first.');
  }

  /// Get statistics about loader performance
  Map<String, dynamic> get statistics => {
        'totalMarkers': _allMarkers.length,
        'loadedMarkers': _currentResult?.allMarkers.length ?? 0,
        'visibleMarkers': _currentResult?.visibleMarkers.length ?? 0,
        'preloadedMarkers': _currentResult?.preloadedMarkers.length ?? 0,
        'totalLoads': _totalLoads,
        'cacheHits': _cacheHits,
        'cacheMisses': _cacheMisses,
        'cacheHitRate': _totalLoads > 0
            ? '${((_cacheHits / _totalLoads) * 100).toStringAsFixed(1)}%'
            : '0%',
        'cacheSize': _cache.size,
        'bufferRatio': bufferRatio,
        'debounceDelayMs': debounceDelayMs,
      };

  /// Clear cache and reset statistics
  void clearCache() {
    _cache.clear();
    _totalLoads = 0;
    _cacheHits = 0;
    _cacheMisses = 0;
  }

  /// Dispose of resources
  void dispose() {
    _debounceTimer?.cancel();
    _resultController.close();
  }

  // Private methods

  /// Perform actual marker loading for bounds
  ViewportLoadResult _performLoad(Bounds bounds) {
    _totalLoads++;

    // Calculate extended bounds with buffer zone
    final extendedBounds = _calculateExtendedBounds(bounds);
    _extendedBounds = extendedBounds;

    // Check cache first
    final cached = _cache.get(extendedBounds);
    if (cached != null) {
      _cacheHits++;
      _currentResult = cached.copyWith(
        viewportBounds: bounds,
        extendedBounds: extendedBounds,
      );
      _resultController.add(_currentResult!);
      return _currentResult!;
    }

    _cacheMisses++;

    // Filter markers in extended bounds (visible + buffer zone)
    final markersInExtendedBounds =
        _filterMarkersInBounds(_allMarkers, extendedBounds);

    // Split into visible and preloaded markers
    final visibleMarkers = _filterMarkersInBounds(_allMarkers, bounds);
    final preloadedMarkers = markersInExtendedBounds
        .where((m) => !visibleMarkers.contains(m))
        .toList();

    // Create result
    final result = ViewportLoadResult(
      visibleMarkers: visibleMarkers,
      preloadedMarkers: preloadedMarkers,
      totalMarkers: _allMarkers.length,
      viewportBounds: bounds,
      extendedBounds: extendedBounds,
      isFromCache: false,
    );

    _currentResult = result;

    // Cache the result
    _cache.put(extendedBounds, result);

    // Emit result
    _resultController.add(result);

    return result;
  }

  /// Calculate extended bounds with buffer zone
  Bounds _calculateExtendedBounds(Bounds bounds) {
    final latDelta = (bounds.north - bounds.south) * bufferRatio;
    final lngDelta = (bounds.east - bounds.west) * bufferRatio;

    return Bounds(
      LatLng(bounds.south - latDelta, bounds.west - lngDelta),
      LatLng(bounds.north + latDelta, bounds.east + lngDelta),
    );
  }

  /// Check if bounds changed significantly (more than 10%)
  bool _boundsChangedSignificantly(
    Bounds oldBounds,
    Bounds newBounds,
  ) {
    const threshold = 0.1; // 10% change threshold

    final centerChanged = _distanceBetweenPoints(
              oldBounds.center,
              newBounds.center,
            ) >
            _calculateBoundsSize(oldBounds) * threshold ||
        _distanceBetweenPoints(
              oldBounds.center,
              newBounds.center,
            ) >
            _calculateBoundsSize(newBounds) * threshold;

    final sizeChanged =
        (_calculateBoundsSize(newBounds) - _calculateBoundsSize(oldBounds))
                    .abs() /
                _calculateBoundsSize(oldBounds) >
            threshold;

    return centerChanged || sizeChanged;
  }

  /// Calculate approximate size of bounds in meters
  double _calculateBoundsSize(Bounds bounds) {
    const Distance distance = Distance();
    return distance.as(
      LengthUnit.Meter,
      bounds.southWest,
      bounds.northEast,
    );
  }

  /// Calculate distance between two points in meters
  double _distanceBetweenPoints(LatLng p1, LatLng p2) {
    const Distance distance = Distance();
    return distance.as(LengthUnit.Meter, p1, p2);
  }

  /// Filter markers that are within bounds
  List<MapMarker> _filterMarkersInBounds(
    List<MapMarker> markers,
    Bounds bounds,
  ) {
    return markers.where((marker) => bounds.contains(marker.position)).toList();
  }

  /// Create empty result for uninitialized state
  ViewportLoadResult _createEmptyResult(Bounds bounds) {
    final extendedBounds = _calculateExtendedBounds(bounds);
    return ViewportLoadResult.empty(
      viewportBounds: bounds,
      extendedBounds: extendedBounds,
      totalMarkers: _allMarkers.length,
    );
  }
}

/// LRU cache for viewport load results
class _ViewportCache {
  final int maxSize;
  final List<_CacheEntry> _entries = [];

  _ViewportCache({required this.maxSize});

  /// Get cached result for bounds
  ViewportLoadResult? get(Bounds bounds) {
    for (final entry in _entries) {
      if (_boundsEqual(entry.bounds, bounds)) {
        // Move to end (most recently used)
        _entries.remove(entry);
        _entries.add(entry);
        return entry.result;
      }
    }
    return null;
  }

  /// Put result in cache
  void put(Bounds bounds, ViewportLoadResult result) {
    // Remove existing entry if present
    _entries.removeWhere((e) => _boundsEqual(e.bounds, bounds));

    // Add new entry
    _entries.add(_CacheEntry(bounds, result));

    // Evict oldest if at capacity
    if (_entries.length > maxSize) {
      _entries.removeAt(0);
    }
  }

  /// Get current cache size
  int get size => _entries.length;

  /// Clear all entries
  void clear() {
    _entries.clear();
  }

  /// Check if two bounds are approximately equal
  bool _boundsEqual(Bounds a, Bounds b) {
    const epsilon = 0.0001; // ~11 meters at equator
    return (a.south - b.south).abs() < epsilon &&
        (a.north - b.north).abs() < epsilon &&
        (a.west - b.west).abs() < epsilon &&
        (a.east - b.east).abs() < epsilon;
  }
}

/// Cache entry combining bounds and result
class _CacheEntry {
  final Bounds bounds;
  final ViewportLoadResult result;

  _CacheEntry(this.bounds, this.result);
}
