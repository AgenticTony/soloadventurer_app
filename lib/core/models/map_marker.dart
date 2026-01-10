import 'package:equatable/equatable.dart';
import 'package:latlong2/latlong.dart';

// Type alias for backward compatibility
typedef MapMarkerType = MarkerType;

/// Map marker model for clustering
///
/// Represents a single point of interest on a map with location data
/// and optional metadata for display and interaction.
class MapMarker extends Equatable {
  /// Unique identifier for this marker
  final String id;

  /// Geographic coordinates of the marker
  final LatLng position;

  /// Title/label for the marker
  final String? title;

  /// Optional description or snippet
  final String? description;

  /// Optional asset path for custom marker icon
  final String? iconPath;

  /// Optional color for default marker (if iconPath is null)
  final int? color;

  /// Optional data payload for custom marker types
  final Map<String, dynamic>? metadata;

  /// Marker type for categorization and custom rendering
  final MarkerType type;

  const MapMarker({
    required this.id,
    required this.position,
    this.title,
    this.description,
    this.iconPath,
    this.color,
    this.metadata,
    this.type = MarkerType.defaultType,
  });

  /// Create marker from latitude and longitude values
  factory MapMarker.fromLatLng({
    required String id,
    required double latitude,
    required double longitude,
    String? title,
    String? description,
    String? iconPath,
    int? color,
    Map<String, dynamic>? metadata,
    MarkerType type = MarkerType.defaultType,
  }) {
    return MapMarker(
      id: id,
      position: LatLng(latitude, longitude),
      title: title,
      description: description,
      iconPath: iconPath,
      color: color,
      metadata: metadata,
      type: type,
    );
  }

  /// Create marker from Trip model (with location data)
  factory MapMarker.fromTrip({
    required String tripId,
    required String title,
    required double? latitude,
    required double? longitude,
    String? description,
    int? color,
  }) {
    assert(latitude != null && longitude != null,
        'Trip must have valid latitude and longitude');

    return MapMarker(
      id: tripId,
      position: LatLng(latitude!, longitude!),
      title: title,
      description: description,
      type: MarkerType.trip,
      color: color,
    );
  }

  /// Create marker from Activity model
  factory MapMarker.fromActivity({
    required String activityId,
    required String title,
    required double? latitude,
    required double? longitude,
    String? description,
    int? color,
  }) {
    assert(latitude != null && longitude != null,
        'Activity must have valid latitude and longitude');

    return MapMarker(
      id: activityId,
      position: LatLng(latitude!, longitude!),
      title: title,
      description: description,
      type: MarkerType.activity,
      color: color,
    );
  }

  /// Calculate distance in meters to another marker
  double distanceTo(MapMarker other) {
    const Distance distance = Distance();
    return distance.as(LengthUnit.Meter, position, other.position);
  }

  /// Create a copy with modified fields
  MapMarker copyWith({
    String? id,
    LatLng? position,
    String? title,
    String? description,
    String? iconPath,
    int? color,
    Map<String, dynamic>? metadata,
    MarkerType? type,
  }) {
    return MapMarker(
      id: id ?? this.id,
      position: position ?? this.position,
      title: title ?? this.title,
      description: description ?? this.description,
      iconPath: iconPath ?? this.iconPath,
      color: color ?? this.color,
      metadata: metadata ?? this.metadata,
      type: type ?? this.type,
    );
  }

  @override
  List<Object?> get props => [
        id,
        position,
        title,
        description,
        iconPath,
        color,
        metadata,
        type,
      ];
}

/// Marker type for categorization
enum MarkerType {
  /// Default/uncategorized marker
  defaultType,

  /// Trip destination marker
  trip,

  /// Activity location marker
  activity,

  /// Photo location marker
  photo,

  /// Accommodation marker
  accommodation,

  /// Restaurant/food marker
  restaurant,

  /// Transportation marker
  transport,

  /// Point of interest marker
  poi,

  /// Shopping/market marker
  shopping,
}

/// Map cluster model for grouped markers
///
/// Represents a cluster of multiple markers that are close together.
/// Used for efficient rendering when many markers are in close proximity.
class MapCluster extends Equatable {
  /// Unique identifier for this cluster
  final String id;

  /// Geographic center of the cluster (average of all marker positions)
  final LatLng position;

  /// Count of markers in this cluster
  final int markerCount;

  /// List of marker IDs in this cluster
  final List<String> markerIds;

  /// Optional list of marker types in this cluster
  final List<MarkerType> markerTypes;

  /// Optional weighted position for better visual center
  final LatLng? weightedPosition;

  const MapCluster({
    required this.id,
    required this.position,
    required this.markerCount,
    required this.markerIds,
    this.markerTypes = const [],
    this.weightedPosition,
  });

  /// Create cluster from a list of markers
  factory MapCluster.fromMarkers({
    required String id,
    required List<MapMarker> markers,
    bool useWeightedCenter = false,
  }) {
    if (markers.isEmpty) {
      throw ArgumentError('Cannot create cluster from empty marker list');
    }

    // Calculate center position
    LatLng center;
    if (useWeightedCenter && markers.length > 1) {
      // Weighted center based on marker type importance
      final weights = markers.map(_getMarkerWeight).toList();
      final totalWeight = weights.reduce((a, b) => a + b);

      double avgLat = 0;
      double avgLng = 0;

      for (int i = 0; i < markers.length; i++) {
        final weight = weights[i] / totalWeight;
        avgLat += markers[i].position.latitude * weight;
        avgLng += markers[i].position.longitude * weight;
      }

      center = LatLng(avgLat, avgLng);
    } else {
      // Simple average center
      final avgLat =
          markers.map((m) => m.position.latitude).reduce((a, b) => a + b) /
              markers.length;
      final avgLng =
          markers.map((m) => m.position.longitude).reduce((a, b) => a + b) /
              markers.length;
      center = LatLng(avgLat, avgLng);
    }

    return MapCluster(
      id: id,
      position: center,
      markerCount: markers.length,
      markerIds: markers.map((m) => m.id).toList(),
      markerTypes: markers.map((m) => m.type).toSet().toList(),
      weightedPosition: useWeightedCenter ? center : null,
    );
  }

  /// Get weight for marker type (for weighted center calculation)
  static double _getMarkerWeight(MapMarker marker) {
    switch (marker.type) {
      case MarkerType.trip:
        return 3.0;
      case MarkerType.activity:
        return 2.0;
      case MarkerType.photo:
        return 1.0;
      case MarkerType.accommodation:
        return 2.5;
      case MarkerType.restaurant:
        return 2.0;
      case MarkerType.transport:
        return 1.5;
      case MarkerType.poi:
        return 2.0;
      case MarkerType.shopping:
        return 2.0;
      case MarkerType.defaultType:
        return 1.0;
    }
  }

  /// Check if cluster contains a specific marker type
  bool containsType(MarkerType type) {
    return markerTypes.contains(type);
  }

  /// Get count of specific marker type in cluster
  int countByType(MarkerType type) {
    return markerTypes.where((t) => t == type).length;
  }

  /// Calculate cluster size in meters (approximate bounding box)
  double calculateSize(List<MapMarker> allMarkers) {
    if (markerIds.isEmpty) return 0;

    final clusterMarkers =
        allMarkers.where((m) => markerIds.contains(m.id)).toList();
    if (clusterMarkers.length <= 1) return 0;

    double maxDistance = 0;
    for (int i = 0; i < clusterMarkers.length; i++) {
      for (int j = i + 1; j < clusterMarkers.length; j++) {
        final distance = clusterMarkers[i].distanceTo(clusterMarkers[j]);
        if (distance > maxDistance) {
          maxDistance = distance;
        }
      }
    }

    return maxDistance;
  }

  @override
  List<Object?> get props => [
        id,
        position,
        markerCount,
        markerIds,
        markerTypes,
        weightedPosition,
      ];
}
