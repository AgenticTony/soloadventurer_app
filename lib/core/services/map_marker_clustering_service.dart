import 'dart:math';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../models/map_marker.dart';

/// Clustering algorithm type
enum ClusteringAlgorithm {
  /// Grid-based clustering (fast, good for large datasets)
  grid,

  /// Distance-based clustering (slower, more accurate)
  distance,

  /// K-means clustering (slower, produces tight clusters)
  kmeans,
}

/// Clustering result containing clusters and unclustered markers
class ClusteringResult {
  /// List of clusters formed
  final List<MapCluster> clusters;

  /// List of markers that were not clustered (single markers)
  final List<MapMarker> unclusteredMarkers;

  /// Total number of input markers
  final int totalMarkers;

  /// Clustering algorithm used
  final ClusteringAlgorithm algorithm;

  /// Clustering parameters used
  final ClusteringParams params;

  const ClusteringResult({
    required this.clusters,
    required this.unclusteredMarkers,
    required this.totalMarkers,
    required this.algorithm,
    required this.params,
  });

  /// Calculate clustering efficiency (ratio of markers reduced)
  double get efficiency {
    if (totalMarkers == 0) return 0;
    final markersRepresented = clusters.length + unclusteredMarkers.length;
    return 1.0 - (markersRepresented / totalMarkers);
  }

  /// Get statistics about the clustering result
  Map<String, dynamic> get statistics {
    return {
      'totalMarkers': totalMarkers,
      'clusters': clusters.length,
      'unclusteredMarkers': unclusteredMarkers.length,
      'efficiency': efficiency,
      'avgClusterSize': clusters.isEmpty
          ? 0.0
          : clusters.map((c) => c.markerCount).reduce((a, b) => a + b) /
              clusters.length,
      'maxClusterSize':
          clusters.isEmpty ? 0 : clusters.map((c) => c.markerCount).reduce(max),
      'algorithm': algorithm.name,
      'clusterRadius': params.clusterRadius,
    };
  }
}

/// Parameters for marker clustering
class ClusteringParams {
  /// Maximum distance in meters for markers to be clustered together
  final int clusterRadius;

  /// Minimum number of markers to form a cluster (1 = always cluster if close)
  final int minClusterSize;

  /// Maximum number of markers in a single cluster
  final int maxClusterSize;

  /// Whether to use weighted center for cluster position
  final bool useWeightedCenter;

  /// Clustering algorithm to use
  final ClusteringAlgorithm algorithm;

  /// Grid cell size for grid-based clustering (in meters)
  final int gridCellSize;

  /// Maximum iterations for K-means clustering
  final int kmeansMaxIterations;

  const ClusteringParams({
    this.clusterRadius = 80, // 80 meters default
    this.minClusterSize = 2,
    this.maxClusterSize = 100,
    this.useWeightedCenter = true,
    this.algorithm = ClusteringAlgorithm.distance,
    this.gridCellSize = 100,
    this.kmeansMaxIterations = 10,
  });

  /// Create params for high-density areas (many markers close together)
  const ClusteringParams.highDensity({
    this.clusterRadius = 50,
    this.minClusterSize = 3,
    this.maxClusterSize = 150,
    this.useWeightedCenter = true,
    this.algorithm = ClusteringAlgorithm.grid,
    this.gridCellSize = 80,
    this.kmeansMaxIterations = 10,
  });

  /// Create params for low-density areas (markers spread out)
  const ClusteringParams.lowDensity({
    this.clusterRadius = 120,
    this.minClusterSize = 2,
    this.maxClusterSize = 50,
    this.useWeightedCenter = false,
    this.algorithm = ClusteringAlgorithm.distance,
    this.gridCellSize = 150,
    this.kmeansMaxIterations = 10,
  });

  /// Create params for specific zoom level
  factory ClusteringParams.forZoomLevel(double zoomLevel) {
    if (zoomLevel >= 15) {
      // Very zoomed in - minimal clustering
      return const ClusteringParams(
        clusterRadius: 30,
        minClusterSize: 3,
        maxClusterSize: 20,
        algorithm: ClusteringAlgorithm.distance,
      );
    } else if (zoomLevel >= 12) {
      // Moderately zoomed in - balanced clustering
      return const ClusteringParams(
        clusterRadius: 60,
        minClusterSize: 2,
        maxClusterSize: 50,
        algorithm: ClusteringAlgorithm.distance,
      );
    } else if (zoomLevel >= 9) {
      // Zoomed out - aggressive clustering
      return const ClusteringParams(
        clusterRadius: 100,
        minClusterSize: 2,
        maxClusterSize: 100,
        algorithm: ClusteringAlgorithm.grid,
      );
    } else {
      // Very zoomed out - maximum clustering
      return const ClusteringParams.highDensity(
        clusterRadius: 150,
        minClusterSize: 2,
        maxClusterSize: 200,
      );
    }
  }
}

/// Service for clustering map markers based on proximity
///
/// Implements multiple clustering algorithms to group nearby markers
/// for efficient rendering on maps, especially with large datasets.
class MapMarkerClusteringService {
  /// Current clustering parameters
  ClusteringParams _params;

  /// Create clustering service with default parameters
  MapMarkerClusteringService([ClusteringParams? params])
      : _params = params ?? const ClusteringParams();

  /// Get current clustering parameters
  ClusteringParams get params => _params;

  /// Update clustering parameters
  void updateParams(ClusteringParams params) {
    _params = params;
  }

  /// Cluster markers based on current parameters
  ClusteringResult clusterMarkers(List<MapMarker> markers) {
    if (markers.isEmpty) {
      return ClusteringResult(
        clusters: [],
        unclusteredMarkers: [],
        totalMarkers: 0,
        algorithm: _params.algorithm,
        params: _params,
      );
    }

    // Select algorithm based on params
    switch (_params.algorithm) {
      case ClusteringAlgorithm.grid:
        return _gridBasedClustering(markers);
      case ClusteringAlgorithm.kmeans:
        return _kmeansClustering(markers);
      case ClusteringAlgorithm.distance:
      default:
        return _distanceBasedClustering(markers);
    }
  }

  /// Distance-based clustering algorithm
  ///
  /// Iteratively groups markers that are within clusterRadius of each other.
  /// Produces accurate clusters but can be slower for very large datasets.
  ClusteringResult _distanceBasedClustering(List<MapMarker> markers) {
    final List<MapCluster> clusters = [];
    final List<MapMarker> unclustered = [];
    final Set<String> clusteredIds = {};
    const Distance distance = Distance();

    // Sort markers by importance (optional optimization)
    final sortedMarkers = List<MapMarker>.from(markers);

    for (final marker in sortedMarkers) {
      if (clusteredIds.contains(marker.id)) continue;

      // Find nearby markers
      final nearbyMarkers = <MapMarker>[marker];
      final nearbyIds = <String>{marker.id};

      for (final other in sortedMarkers) {
        if (other.id == marker.id || clusteredIds.contains(other.id)) {
          continue;
        }

        final dist = distance.as(
          LengthUnit.Meter,
          marker.position,
          other.position,
        );

        if (dist <= _params.clusterRadius) {
          nearbyMarkers.add(other);
          nearbyIds.add(other.id);

          // Limit cluster size
          if (nearbyMarkers.length >= _params.maxClusterSize) {
            break;
          }
        }
      }

      // Create cluster if we have enough markers
      if (nearbyMarkers.length >= _params.minClusterSize) {
        final cluster = MapCluster.fromMarkers(
          id: 'cluster_${clusters.length}_${marker.id}',
          markers: nearbyMarkers,
          useWeightedCenter: _params.useWeightedCenter,
        );
        clusters.add(cluster);
        clusteredIds.addAll(nearbyIds);
      } else {
        unclustered.add(marker);
      }
    }

    return ClusteringResult(
      clusters: clusters,
      unclusteredMarkers: unclustered,
      totalMarkers: markers.length,
      algorithm: ClusteringAlgorithm.distance,
      params: _params,
    );
  }

  /// Grid-based clustering algorithm
  ///
  /// Divides the map into a grid and clusters markers within each cell.
  /// Very fast but may produce less optimal clusters across cell boundaries.
  ClusteringResult _gridBasedClustering(List<MapMarker> markers) {
    final List<MapCluster> clusters = [];
    final List<MapMarker> unclustered = [];
    final Map<String, List<MapMarker>> gridCells = {};
    const Distance distance = Distance();

    // Calculate grid boundaries
    double minLat = double.infinity;
    double maxLat = double.negativeInfinity;
    double minLng = double.infinity;
    double maxLng = double.negativeInfinity;

    for (final marker in markers) {
      minLat = min(minLat, marker.position.latitude);
      maxLat = max(maxLat, marker.position.latitude);
      minLng = min(minLng, marker.position.longitude);
      maxLng = max(maxLng, marker.position.longitude);
    }

    // Assign markers to grid cells
    for (final marker in markers) {
      final cellX =
          ((marker.position.latitude - minLat) / _params.gridCellSize).floor();
      final cellY =
          ((marker.position.longitude - minLng) / _params.gridCellSize).floor();
      final cellKey = '${cellX}_$cellY';

      gridCells.putIfAbsent(cellKey, () => []).add(marker);
    }

    // Cluster markers within each cell
    int clusterIndex = 0;
    final Set<String> clusteredIds = {};

    for (final cellMarkers in gridCells.values) {
      if (cellMarkers.length < _params.minClusterSize) {
        unclustered.addAll(cellMarkers);
        continue;
      }

      // For larger cells, apply additional distance-based clustering
      if (cellMarkers.length > 20) {
        final subResult = _distanceBasedClustering(cellMarkers);
        clusters.addAll(subResult.clusters);
        clusteredIds.addAll(subResult.clusters
            .expand((c) => c.markerIds)
            .where((id) => !clusteredIds.contains(id)));
        unclustered.addAll(subResult.unclusteredMarkers
            .where((m) => !clusteredIds.contains(m.id)));
      } else {
        final cluster = MapCluster.fromMarkers(
          id: 'cluster_${clusterIndex++}_${cellMarkers.first.id}',
          markers: cellMarkers,
          useWeightedCenter: _params.useWeightedCenter,
        );
        clusters.add(cluster);
        clusteredIds.addAll(cellMarkers.map((m) => m.id));
      }
    }

    // Add remaining markers
    unclustered.addAll(markers.where((m) => !clusteredIds.contains(m.id)));

    return ClusteringResult(
      clusters: clusters,
      unclusteredMarkers: unclustered,
      totalMarkers: markers.length,
      algorithm: ClusteringAlgorithm.grid,
      params: _params,
    );
  }

  /// K-means clustering algorithm
  ///
  /// Partitions markers into k clusters using iterative refinement.
  /// Produces tight clusters but requires knowing the optimal k value.
  ClusteringResult _kmeansClustering(List<MapMarker> markers) {
    if (markers.length < _params.minClusterSize) {
      return ClusteringResult(
        clusters: [],
        unclusteredMarkers: markers,
        totalMarkers: markers.length,
        algorithm: ClusteringAlgorithm.kmeans,
        params: _params,
      );
    }

    // Estimate k based on marker density
    final estimatedK = (markers.length / _params.maxClusterSize).ceil().clamp(
          1,
          markers.length ~/ _params.minClusterSize,
        );

    // Initialize centroids using k-means++ approach
    final List<LatLng> centroids = _initializeCentroids(markers, estimatedK);

    // Run k-means iterations
    List<List<MapMarker>> clusters = List.generate(estimatedK, (_) => []);

    for (int iter = 0; iter < _params.kmeansMaxIterations; iter++) {
      // Assign markers to nearest centroid
      clusters = List.generate(estimatedK, (_) => []);
      for (final marker in markers) {
        int nearestCentroid = 0;
        double minDistance = double.infinity;

        for (int i = 0; i < centroids.length; i++) {
          final dist = _haversineDistance(marker.position, centroids[i]);
          if (dist < minDistance) {
            minDistance = dist;
            nearestCentroid = i;
          }
        }

        clusters[nearestCentroid].add(marker);
      }

      // Update centroids
      final List<LatLng> newCentroids = [];
      for (int i = 0; i < clusters.length; i++) {
        if (clusters[i].isEmpty) {
          newCentroids.add(centroids[i]);
        } else {
          final avgLat = clusters[i]
                  .map((m) => m.position.latitude)
                  .reduce((a, b) => a + b) /
              clusters[i].length;
          final avgLng = clusters[i]
                  .map((m) => m.position.longitude)
                  .reduce((a, b) => a + b) /
              clusters[i].length;
          newCentroids.add(LatLng(avgLat, avgLng));
        }
      }

      // Check for convergence
      bool converged = true;
      for (int i = 0; i < centroids.length; i++) {
        if (_haversineDistance(centroids[i], newCentroids[i]) > 1.0) {
          converged = false;
          break;
        }
      }

      centroids.clear();
      centroids.addAll(newCentroids);

      if (converged) break;
    }

    // Convert to MapCluster objects, filtering small clusters
    final List<MapCluster> validClusters = [];
    final List<MapMarker> unclustered = [];

    int clusterIndex = 0;
    for (int i = 0; i < clusters.length; i++) {
      if (clusters[i].length >= _params.minClusterSize) {
        final cluster = MapCluster.fromMarkers(
          id: 'cluster_${clusterIndex++}_kmeans_$i',
          markers: clusters[i],
          useWeightedCenter: _params.useWeightedCenter,
        );
        validClusters.add(cluster);
      } else {
        unclustered.addAll(clusters[i]);
      }
    }

    return ClusteringResult(
      clusters: validClusters,
      unclusteredMarkers: unclustered,
      totalMarkers: markers.length,
      algorithm: ClusteringAlgorithm.kmeans,
      params: _params,
    );
  }

  /// Initialize centroids using k-means++ algorithm
  List<LatLng> _initializeCentroids(List<MapMarker> markers, int k) {
    final List<LatLng> centroids = [];
    final Random random = Random();

    // Choose first centroid randomly
    centroids.add(markers[random.nextInt(markers.length)].position);

    // Choose remaining centroids with probability proportional to distance
    while (centroids.length < k) {
      final List<double> distances = [];
      double totalDistance = 0;

      for (final marker in markers) {
        double minDistance = double.infinity;
        for (final centroid in centroids) {
          final dist = _haversineDistance(marker.position, centroid);
          if (dist < minDistance) {
            minDistance = dist;
          }
        }
        distances.add(minDistance * minDistance); // Square for probability
        totalDistance += distances.last;
      }

      // Select next centroid
      double threshold = random.nextDouble() * totalDistance;
      double cumulative = 0;
      int selectedIndex = 0;

      for (int i = 0; i < markers.length; i++) {
        cumulative += distances[i];
        if (cumulative >= threshold) {
          selectedIndex = i;
          break;
        }
      }

      centroids.add(markers[selectedIndex].position);
    }

    return centroids;
  }

  /// Calculate Haversine distance between two points in meters
  double _haversineDistance(LatLng p1, LatLng p2) {
    const Distance distance = Distance();
    return distance.as(LengthUnit.Meter, p1, p2);
  }

  /// Cluster markers within a specific geographic bounds
  ClusteringResult clusterMarkersInBounds(
    List<MapMarker> markers,
    LatLngBounds bounds,
  ) {
    // Filter markers within bounds
    final markersInBounds = markers.where((marker) {
      return bounds.contains(marker.position);
    }).toList();

    return clusterMarkers(markersInBounds);
  }

  /// Incremental clustering for real-time updates
  ///
  /// Clusters only new/changed markers without reclustering everything.
  /// Useful for real-time map updates.
  ClusteringResult incrementalCluster(
    List<MapMarker> existingMarkers,
    List<MapMarker> newMarkers,
    ClusteringResult previousResult,
  ) {
    // Remove markers that are in new list from previous clusters
    final newIds = newMarkers.map((m) => m.id).toSet();

    final remainingClusters = previousResult.clusters
        .where(
            (cluster) => !cluster.markerIds.every((id) => newIds.contains(id)))
        .toList();

    final remainingUnclustered = previousResult.unclusteredMarkers
        .where((marker) => !newIds.contains(marker.id))
        .toList();

    // Cluster the new markers
    final newResult = clusterMarkers(newMarkers);

    // Combine results
    return ClusteringResult(
      clusters: [...remainingClusters, ...newResult.clusters],
      unclusteredMarkers: [
        ...remainingUnclustered,
        ...newResult.unclusteredMarkers
      ],
      totalMarkers: remainingClusters.fold<int>(
            0,
            (sum, c) => sum + c.markerCount,
          ) +
          remainingUnclustered.length +
          newMarkers.length,
      algorithm: _params.algorithm,
      params: _params,
    );
  }

  /// Limit visible items to maximum count for performance
  ///
  /// Ensures the total number of visible items (clusters + unclustered markers)
  /// does not exceed [maxVisibleItems]. Uses priority-based selection to keep
  /// the most important items visible.
  ///
  /// Priority is determined by:
  /// 1. Larger clusters are prioritized (they represent more data)
  /// 2. Clustered markers are prioritized over unclustered
  /// 3. Marker type importance (trip > accommodation > activity > others)
  ///
  /// Returns a new [ClusteringResult] with limited visible items.
  ClusteringResult limitVisibleItems(
    ClusteringResult result, {
    int maxVisibleItems = 50,
  }) {
    final totalItems =
        result.clusters.length + result.unclusteredMarkers.length;

    // If already under limit, return as-is
    if (totalItems <= maxVisibleItems) {
      return result;
    }

    // Sort clusters by priority (larger first, then by marker type importance)
    final sortedClusters = List<MapCluster>.from(result.clusters);
    sortedClusters.sort((a, b) {
      // Primary sort: by marker count (descending)
      final countComparison = b.markerCount.compareTo(a.markerCount);
      if (countComparison != 0) return countComparison;

      // Secondary sort: by importance of marker types in cluster
      final aImportance = _calculateClusterImportance(a);
      final bImportance = _calculateClusterImportance(b);
      return bImportance.compareTo(aImportance);
    });

    // Sort unclustered markers by priority
    final sortedMarkers = List<MapMarker>.from(result.unclusteredMarkers);
    sortedMarkers.sort((a, b) {
      return _getMarkerImportance(b).compareTo(_getMarkerImportance(a));
    });

    // Select top items using a greedy approach
    final selectedClusters = <MapCluster>[];
    final selectedMarkers = <MapMarker>[];
    int visibleCount = 0;

    // First, add as many high-priority clusters as possible
    for (final cluster in sortedClusters) {
      if (visibleCount >= maxVisibleItems) break;

      // Prefer clusters over single markers (they represent more data)
      selectedClusters.add(cluster);
      visibleCount++;
    }

    // Then add unclustered markers if we have space
    if (visibleCount < maxVisibleItems) {
      final remainingSlots = maxVisibleItems - visibleCount;
      selectedMarkers.addAll(
        sortedMarkers.take(remainingSlots),
      );
      visibleCount += remainingSlots;
    }

    return ClusteringResult(
      clusters: selectedClusters,
      unclusteredMarkers: selectedMarkers,
      totalMarkers: result.totalMarkers,
      algorithm: result.algorithm,
      params: result.params,
    );
  }

  /// Calculate cluster importance score for prioritization
  ///
  /// Higher score = more important to show
  double _calculateClusterImportance(MapCluster cluster) {
    double score = 0;

    for (final type in cluster.markerTypes) {
      score += _getMarkerTypeImportance(type);
    }

    // Bonus for larger clusters
    score *= (1 + (cluster.markerCount / 100));

    return score;
  }

  /// Get importance score for a single marker
  double _getMarkerImportance(MapMarker marker) {
    return _getMarkerTypeImportance(marker.type);
  }

  /// Get importance score for marker type
  double _getMarkerTypeImportance(MarkerType type) {
    switch (type) {
      case MarkerType.trip:
        return 10.0; // Highest importance
      case MarkerType.accommodation:
        return 8.0;
      case MarkerType.activity:
        return 6.0;
      case MarkerType.restaurant:
        return 5.0;
      case MarkerType.shopping:
        return 4.5;
      case MarkerType.transport:
        return 4.0;
      case MarkerType.poi:
        return 3.0;
      case MarkerType.photo:
        return 2.0;
      case MarkerType.defaultType:
        return 1.0; // Lowest importance
    }
  }

  /// Cluster markers with automatic visible item limiting
  ///
  /// Convenience method that performs clustering and then limits
  /// the visible items to [maxVisibleItems] for optimal performance.
  ClusteringResult clusterMarkersWithLimit(
    List<MapMarker> markers, {
    int maxVisibleItems = 50,
  }) {
    final result = clusterMarkers(markers);
    return limitVisibleItems(result, maxVisibleItems: maxVisibleItems);
  }

  /// Cluster markers within bounds with automatic visible item limiting
  ///
  /// Convenience method that performs bounds-based clustering and then limits
  /// the visible items to [maxVisibleItems] for optimal performance.
  ClusteringResult clusterMarkersInBoundsWithLimit(
    List<MapMarker> markers,
    LatLngBounds bounds, {
    int maxVisibleItems = 50,
  }) {
    final result = clusterMarkersInBounds(markers, bounds);
    return limitVisibleItems(result, maxVisibleItems: maxVisibleItems);
  }
}
