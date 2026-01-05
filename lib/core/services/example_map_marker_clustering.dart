/// Example usage of enhanced MapMarkerClusteringService
///
/// This file demonstrates how to use the zoom-level aware clustering
/// and custom cluster rendering features.

import 'package:latlong2/latlong.dart';
import '../models/map_marker.dart';
import 'map_marker_clustering_service.dart';
import '../widgets/map_marker_widgets.dart';

/// Example 1: Basic clustering with zoom-level awareness
void example1_ZoomLevelClustering() {
  // Create clustering service
  final clusteringService = MapMarkerClusteringService();

  // Create sample markers
  final markers = _generateSampleMarkers(500);

  // Cluster for different zoom levels
  for (final zoom in [8.0, 12.0, 15.0]) {
    final params = ClusteringParams.forZoomLevel(zoom);
    clusteringService.updateParams(params);

    final result = clusteringService.clusterMarkers(markers);
    print('Zoom $zoom: ${result.clusters.length} clusters, '
          '${result.unclusteredMarkers.length} unclustered');
  }
}

/// Example 2: Limit visible items to max 50 for performance
void example2_LimitVisibleItems() {
  final clusteringService = MapMarkerClusteringService();
  final markers = _generateSampleMarkers(1000);

  // Standard clustering (may return 100+ items)
  final standardResult = clusteringService.clusterMarkers(markers);
  print('Standard: ${standardResult.clusters.length + standardResult.unclusteredMarkers.length} items');

  // Limited clustering (max 50 items)
  final limitedResult = clusteringService.limitVisibleItems(
    standardResult,
    maxVisibleItems: 50,
  );
  print('Limited: ${limitedResult.clusters.length + limitedResult.unclusteredMarkers.length} items');
}

/// Example 3: Convenience method for clustering with limit
void example3_ClusterWithLimit() {
  final clusteringService = MapMarkerClusteringService();
  final markers = _generateSampleMarkers(1000);

  // Single method to cluster and limit
  final result = clusteringService.clusterMarkersWithLimit(
    markers,
    maxVisibleItems: 50,
  );

  print('Efficiency: ${(result.efficiency * 100).toStringAsFixed(1)}%');
  print('Visible items: ${result.clusters.length + result.unclusteredMarkers.length}');
}

/// Example 4: Bounds-based clustering with limit
void example4_BoundsBasedClustering() {
  final clusteringService = MapMarkerClusteringService();
  final markers = _generateSampleMarkers(1000);

  // Define viewport bounds
  final bounds = LatLngBounds(
    LatLng(37.7, -122.5), // Southwest
    LatLng(37.8, -122.3), // Northeast
  );

  // Cluster only markers within bounds, limited to 50 items
  final result = clusteringService.clusterMarkersInBoundsWithLimit(
    markers,
    bounds,
    maxVisibleItems: 50,
  );

  print('Viewport: ${result.clusters.length} clusters, '
        '${result.unclusteredMarkers.length} markers');
}

/// Example 5: Using ZoomAwareClusterWidget in Flutter
///
/// ```dart
/// // In your map widget
/// Widget buildCluster(MapCluster cluster, double zoomLevel) {
///   return ZoomAwareClusterWidget(
///     cluster: cluster,
///     zoomLevel: zoomLevel,
///     onTap: () => onClusterTap(cluster),
///     abbreviateCount: true,
///     animate: true,
///   );
/// }
/// ```
void example5_ZoomAwareWidget() {
  // This is just documentation for Flutter usage
  // See example below
}

/// Example 6: Custom color schemes for clusters
///
/// ```dart
/// Widget buildClusterWithCustomColor(MapCluster cluster, double zoomLevel) {
///   return ZoomAwareClusterWidget(
///     cluster: cluster,
///     zoomLevel: zoomLevel,
///     colorScheme: ClusterColorScheme.heatmap(),
///     onTap: () => onClusterTap(cluster),
///   );
/// }
///
/// // Or create your own color scheme
/// Widget buildClusterWithMonochrome(MapCluster cluster, double zoomLevel) {
///   return ZoomAwareClusterWidget(
///     cluster: cluster,
///     zoomLevel: zoomLevel,
///     colorScheme: ClusterColorScheme.monochrome(
///       baseColor: Colors.indigo,
///     ),
///     onTap: () => onClusterTap(cluster),
///   );
/// }
/// ```
void example6_CustomColorSchemes() {
  // This is just documentation for Flutter usage
}

/// Example 7: Priority-based selection for limiting
///
/// The limitVisibleItems method uses smart prioritization:
/// - Larger clusters are prioritized (represent more data)
/// - Important marker types (trip, accommodation) get priority
/// - Clustered markers preferred over unclustered
void example7_PriorityBasedSelection() {
  final clusteringService = MapMarkerClusteringService();

  // Create markers with different types
  final markers = [
    // Trip markers (highest priority)
    MapMarker.fromLatLng(
      id: 'trip1',
      latitude: 37.7749,
      longitude: -122.4194,
      title: 'San Francisco',
      type: MarkerType.trip,
    ),
    // Accommodation markers (high priority)
    MapMarker.fromLatLng(
      id: 'hotel1',
      latitude: 37.7849,
      longitude: -122.4094,
      title: 'Hotel',
      type: MarkerType.accommodation,
    ),
    // Activity markers (medium priority)
    MapMarker.fromLatLng(
      id: 'activity1',
      latitude: 37.7649,
      longitude: -122.4294,
      title: 'Activity',
      type: MarkerType.activity,
    ),
    // Photo markers (lower priority)
    MapMarker.fromLatLng(
      id: 'photo1',
      latitude: 37.7549,
      longitude: -122.4394,
      title: 'Photo',
      type: MarkerType.photo,
    ),
  ];

  // Cluster with limit - important types will be kept visible
  final result = clusteringService.clusterMarkersWithLimit(
    markers,
    maxVisibleItems: 2,
  );

  print('Kept ${result.clusters.length + result.unclusteredMarkers.length} items');
  print('Prioritized: trip, accommodation > activities > photos');
}

/// Example 8: Full workflow with ZoomAwareClusteringManager
///
/// ```dart
/// class MyMapScreen extends StatefulWidget {
///   @override
///   _MyMapScreenState createState() => _MyMapScreenState();
/// }
///
/// class _MyMapScreenState extends State<MyMapScreen> {
///   late ZoomAwareClusteringManager _clusteringManager;
///   double _currentZoom = 12.0;
///
///   @override
///   void initState() {
///     super.initState();
///
///     final markers = loadMarkers(); // Your marker loading logic
///     _clusteringManager = ZoomAwareClusteringManager(
///       markers: markers,
///       initialZoom: _currentZoom,
///       useBoundsBasedClustering: true,
///     );
///
///     _clusteringManager.initialize();
///   }
///
///   void onZoomChanged(double newZoom) {
///     setState(() {
///       _currentZoom = newZoom;
///       _clusteringManager.updateZoomLevel(newZoom);
///     });
///   }
///
///   @override
///   Widget build(BuildContext context) {
///     return StreamBuilder<ClusteringResult>(
///       stream: _clusteringManager.resultStream,
///       builder: (context, snapshot) {
///         if (!snapshot.hasData) return CircularProgressIndicator();
///
///         final result = snapshot.data!;
///         final limitedResult = _clusteringManager._clusteringService
///             .limitVisibleItems(result, maxVisibleItems: 50);
///
///         return MapView(
///           clusters: limitedResult.clusters,
///           markers: limitedResult.unclusteredMarkers,
///           zoomLevel: _currentZoom,
///           onZoomChanged: onZoomChanged,
///           clusterBuilder: (cluster) => ZoomAwareClusterWidget(
///             cluster: cluster,
///             zoomLevel: _currentZoom,
///             onTap: () => showClusterDetails(cluster),
///           ),
///         );
///       },
///     );
///   }
///
///   @override
///   void dispose() {
///     _clusteringManager.dispose();
///     super.dispose();
///   }
/// }
/// ```
void example8_CompleteWorkflow() {
  // This is just documentation for Flutter usage
}

// Helper function to generate sample markers
List<MapMarker> _generateSampleMarkers(int count) {
  final random = DateTime.now().millisecondsSinceEpoch;
  final markers = <MapMarker>[];
  final types = MarkerType.values;

  for (int i = 0; i < count; i++) {
    final lat = 37.7749 + (i % 100 - 50) * 0.001;
    final lng = -122.4194 + (i % 100 - 50) * 0.001;

    markers.add(MapMarker.fromLatLng(
      id: 'marker_$i',
      latitude: lat,
      longitude: lng,
      title: 'Marker $i',
      type: types[i % types.length],
    ));
  }

  return markers;
}

/// Summary of new features:
///
/// 1. **limitVisibleItems()** - Limits visible clusters + markers to max 50
///    - Uses priority-based selection (larger clusters, important types)
///    - Ensures smooth performance even with 1000+ markers
///
/// 2. **clusterMarkersWithLimit()** - Convenience method combining clustering + limiting
///    - Single call for optimal performance
///
/// 3. **ZoomAwareClusterWidget** - Widget that adapts to zoom level
///    - Larger clusters when zoomed out
///    - Smaller clusters when zoomed in
///    - Smooth animations during zoom changes
///
/// 4. **ClusterColorScheme** - Custom color schemes for clusters
///    - trafficLight() - Green/yellow/orange/red
///    - heatmap() - Full gradient from green to purple
///    - monochrome() - Single color with opacity variations
///
/// 5. **Smart prioritization** - Keeps important items visible
///    - Trips > Accommodations > Activities > Photos
///    - Larger clusters prioritized over smaller ones
///    - Ensures best user experience with limited screen space
