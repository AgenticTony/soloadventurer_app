import 'dart:async';
import 'package:flutter_map/flutter_map.dart';
import '../models/map_marker.dart';
import 'map_marker_clustering_service.dart';

/// Zoom-aware clustering manager that automatically re-clusters markers
/// based on map zoom level changes.
///
/// This manager wraps MapMarkerClusteringService and provides:
/// - Automatic parameter adjustment based on zoom level
/// - Efficient re-clustering with debouncing
/// - Optional bounds-based clustering for better performance
/// - Clustering history for zoom undo/redo
class ZoomAwareClusteringManager {
  /// Current zoom level
  double _currentZoom;

  /// All markers managed by this manager
  final List<MapMarker> _allMarkers;

  /// Current clustering result
  ClusteringResult? _currentResult;

  /// Clustering service instance
  final MapMarkerClusteringService _clusteringService;

  /// Debounce timer for re-clustering
  Timer? _debounceTimer;

  /// Debounce delay in milliseconds
  final int debounceDelayMs;

  /// Whether to use bounds-based clustering
  final bool useLatLngBoundsBasedClustering;

  /// Current map bounds (if using bounds-based clustering)
  LatLngBounds? _currentLatLngBounds;

  /// Clustering history for zoom changes (undo/redo support)
  final List<_ClusteringSnapshot> _history = [];

  /// Maximum history size
  final int maxHistorySize;

  /// Stream controller for clustering updates
  final StreamController<ClusteringResult> _resultController =
      StreamController<ClusteringResult>.broadcast();

  /// Stream of clustering results
  Stream<ClusteringResult> get resultStream => _resultController.stream;

  /// Current clustering result
  ClusteringResult? get currentResult => _currentResult;

  /// Current zoom level
  double get currentZoom => _currentZoom;

  /// Current clustering parameters
  ClusteringParams get currentParams => _clusteringService.params;

  /// Create zoom-aware clustering manager
  ///
  /// Parameters:
  /// - [markers]: Initial list of markers to cluster
  /// - [initialZoom]: Initial zoom level (default: 12.0)
  /// - [debounceDelayMs]: Delay before re-clustering after zoom change (default: 300ms)
  /// - [useLatLngBoundsBasedClustering]: Whether to cluster only visible markers (default: false)
  /// - [params]: Optional custom clustering parameters
  /// - [maxHistorySize]: Maximum number of clustering snapshots to keep (default: 20)
  ZoomAwareClusteringManager({
    required List<MapMarker> markers,
    double initialZoom = 12.0,
    this.debounceDelayMs = 300,
    this.useLatLngBoundsBasedClustering = false,
    ClusteringParams? params,
    this.maxHistorySize = 20,
  })  : _allMarkers = markers,
        _currentZoom = initialZoom,
        _clusteringService = MapMarkerClusteringService(
          params ?? ClusteringParams.forZoomLevel(initialZoom),
        );

  /// Initialize clustering manager and perform initial clustering
  Future<ClusteringResult> initialize() async {
    return _performClustering(saveSnapshot: false);
  }

  /// Update zoom level and re-cluster markers
  ///
  /// This method is debounced to avoid excessive re-clustering during
  /// rapid zoom changes. The actual clustering happens after [debounceDelayMs].
  ///
  /// Use [waitForClusterUpdate] to get the clustering result after it completes.
  void updateZoomLevel(double newZoom, {bool force = false}) {
    if (_currentZoom == newZoom && !force) return;

    _currentZoom = newZoom;

    // Cancel any pending re-clustering
    _debounceTimer?.cancel();

    // Debounce re-clustering
    _debounceTimer = Timer(Duration(milliseconds: debounceDelayMs), () {
      _updateClusteringParams();
      _performClustering();
    });
  }

  /// Update map bounds (for bounds-based clustering)
  ///
  /// Only has an effect if [useLatLngBoundsBasedClustering] is true.
  void updateMapLatLngBounds(LatLngBounds bounds, {bool force = false}) {
    if (!useLatLngBoundsBasedClustering) return;

    if (_currentLatLngBounds != null &&
        _currentLatLngBounds!.south == bounds.south &&
        _currentLatLngBounds!.north == bounds.north &&
        _currentLatLngBounds!.west == bounds.west &&
        _currentLatLngBounds!.east == bounds.east &&
        !force) {
      return;
    }

    _currentLatLngBounds = bounds;

    // Re-cluster with new bounds
    _debounceTimer?.cancel();
    _debounceTimer = Timer(Duration(milliseconds: debounceDelayMs), () {
      _performClustering();
    });
  }

  /// Update markers and re-cluster
  ///
  /// Uses incremental clustering if possible for better performance.
  void updateMarkers(List<MapMarker> newMarkers,
      {bool forceRecluster = false}) {
    _allMarkers.clear();
    _allMarkers.addAll(newMarkers);

    if (forceRecluster || _currentResult == null) {
      _performClustering();
    } else {
      // Use incremental clustering
      _performIncrementalClustering(newMarkers);
    }
  }

  /// Add new markers and incrementally update clusters
  void addMarkers(List<MapMarker> newMarkers) {
    if (newMarkers.isEmpty) return;

    _allMarkers.addAll(newMarkers);
    _performIncrementalClustering(newMarkers);
  }

  /// Remove markers and re-cluster
  void removeMarkers(List<String> markerIds) {
    if (markerIds.isEmpty) return;

    final remainingMarkers =
        _allMarkers.where((m) => !markerIds.contains(m.id)).toList();
    updateMarkers(remainingMarkers, forceRecluster: true);
  }

  /// Get clustering result after zoom update completes
  ///
  /// Useful for awaiting clustering completion after calling [updateZoomLevel].
  Future<ClusteringResult> waitForClusterUpdate() async {
    // If there's a pending debounce, wait for it to complete
    while (_debounceTimer != null && _debounceTimer!.isActive) {
      await Future.delayed(const Duration(milliseconds: 50));
    }

    // Return current result
    if (_currentResult != null) {
      return _currentResult!;
    }

    // Perform clustering if no result exists
    return _performClustering();
  }

  /// Get statistics about current clustering state
  Map<String, dynamic> get statistics {
    return {
      'currentZoom': _currentZoom,
      'totalMarkers': _allMarkers.length,
      'clusters': _currentResult?.clusters.length ?? 0,
      'unclusteredMarkers': _currentResult?.unclusteredMarkers.length ?? 0,
      'efficiency': _currentResult?.efficiency ?? 0.0,
      'algorithm': _clusteringService.params.algorithm.name,
      'clusterRadius': _clusteringService.params.clusterRadius,
      'historySize': _history.length,
      'usingLatLngBoundsBasedClustering': useLatLngBoundsBasedClustering,
    };
  }

  /// Undo last clustering operation
  ClusteringResult? undo() {
    if (_history.isEmpty) return null;

    final snapshot = _history.removeLast();
    _currentZoom = snapshot.zoom;
    _currentResult = snapshot.result;
    _clusteringService.updateParams(snapshot.params);

    _resultController.add(_currentResult!);
    return _currentResult;
  }

  /// Clear clustering history
  void clearHistory() {
    _history.clear();
  }

  /// Dispose of resources
  void dispose() {
    _debounceTimer?.cancel();
    _resultController.close();
  }

  // Private methods

  /// Update clustering parameters based on current zoom level
  void _updateClusteringParams() {
    final newParams = ClusteringParams.forZoomLevel(_currentZoom);
    _clusteringService.updateParams(newParams);
  }

  /// Perform clustering operation
  ClusteringResult _performClustering({bool saveSnapshot = true}) {
    ClusteringResult result;

    if (useLatLngBoundsBasedClustering && _currentLatLngBounds != null) {
      // LatLngBounds-based clustering
      result = _clusteringService.clusterMarkersInLatLngBounds(
        _allMarkers,
        _currentLatLngBounds!,
      );
    } else {
      // Standard clustering
      result = _clusteringService.clusterMarkers(_allMarkers);
    }

    _currentResult = result;

    if (saveSnapshot) {
      _saveSnapshot(result);
    }

    _resultController.add(result);
    return result;
  }

  /// Perform incremental clustering
  void _performIncrementalClustering(List<MapMarker> newMarkers) {
    if (_currentResult == null) {
      _performClustering();
      return;
    }

    final result = _clusteringService.incrementalCluster(
      _allMarkers,
      newMarkers,
      _currentResult!,
    );

    _currentResult = result;
    _saveSnapshot(result);
    _resultController.add(result);
  }

  /// Save clustering snapshot to history
  void _saveSnapshot(ClusteringResult result) {
    _history.add(_ClusteringSnapshot(
      zoom: _currentZoom,
      params: _clusteringService.params,
      result: result,
    ));

    // Limit history size
    if (_history.length > maxHistorySize) {
      _history.removeAt(0);
    }
  }
}

/// Snapshot of clustering state at a specific zoom level
class _ClusteringSnapshot {
  final double zoom;
  final ClusteringParams params;
  final ClusteringResult result;

  _ClusteringSnapshot({
    required this.zoom,
    required this.params,
    required this.result,
  });
}

/// Convenience factory methods for creating managers with common configurations
///
/// These factory methods provide pre-configured managers for common use cases.
class ClusteringManagerFactories {
  /// Create manager for high-density areas (cities, tourist attractions)
  static ZoomAwareClusteringManager forHighDensity({
    required List<MapMarker> markers,
    double initialZoom = 14.0,
    int debounceDelayMs = 300,
    bool useLatLngBoundsBasedClustering = true,
  }) {
    return ZoomAwareClusteringManager(
      markers: markers,
      initialZoom: initialZoom,
      debounceDelayMs: debounceDelayMs,
      useLatLngBoundsBasedClustering: useLatLngBoundsBasedClustering,
      params: const ClusteringParams.highDensity(),
    );
  }

  /// Create manager for low-density areas (rural, scattered locations)
  static ZoomAwareClusteringManager forLowDensity({
    required List<MapMarker> markers,
    double initialZoom = 10.0,
    int debounceDelayMs = 300,
    bool useLatLngBoundsBasedClustering = false,
  }) {
    return ZoomAwareClusteringManager(
      markers: markers,
      initialZoom: initialZoom,
      debounceDelayMs: debounceDelayMs,
      useLatLngBoundsBasedClustering: useLatLngBoundsBasedClustering,
      params: const ClusteringParams.lowDensity(),
    );
  }

  /// Create manager for performance-critical scenarios (500+ markers)
  static ZoomAwareClusteringManager forPerformance({
    required List<MapMarker> markers,
    double initialZoom = 10.0,
    int debounceDelayMs = 200, // Faster response
    bool useLatLngBoundsBasedClustering = true, // Only cluster visible
  }) {
    return ZoomAwareClusteringManager(
      markers: markers,
      initialZoom: initialZoom,
      debounceDelayMs: debounceDelayMs,
      useLatLngBoundsBasedClustering: useLatLngBoundsBasedClustering,
      params: const ClusteringParams(
        algorithm: ClusteringAlgorithm.grid, // Fastest algorithm
        gridCellSize: 100,
      ),
    );
  }
}
