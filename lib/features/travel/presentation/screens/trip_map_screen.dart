import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:soloadventurer/core/models/map_marker.dart';
import 'package:soloadventurer/core/services/map_marker_clustering_service.dart';
import 'package:soloadventurer/core/services/zoom_aware_clustering_manager.dart';
import 'package:soloadventurer/core/widgets/map_marker_widgets.dart';

/// Provider for trip map markers
///
/// In a real implementation, this would fetch markers from a repository
/// based on the trip ID. For demonstration, we provide an empty list.
final tripMapMarkersProvider = Provider<List<MapMarker>>((ref) {
  return [];
});

/// Screen displaying a trip map with dynamic marker clustering
///
/// This screen demonstrates the integration of [ZoomAwareClusteringManager]
/// with [FlutterMap] to provide intelligent marker clustering that
/// automatically adjusts based on zoom level.
///
/// Features:
/// - Automatic re-clustering on zoom changes (debounced 300ms)
/// - Bounds-based clustering for performance (only visible markers)
/// - Custom marker and cluster widgets
/// - Zoom and pan controls
/// - Cluster statistics display
/// - Cluster tap handling (zoom to fit)
///
/// Performance:
/// - Handles 500+ markers efficiently
/// - Debounced re-clustering prevents excessive calculations
/// - Stream-based updates for smooth UI
class TripMapScreen extends ConsumerStatefulWidget {
  /// Creates a new [TripMapScreen]
  const TripMapScreen({super.key});

  /// Route name for navigation
  static const String routeName = '/trips/map';

  @override
  ConsumerState<TripMapScreen> createState() => _TripMapScreenState();
}

class _TripMapScreenState extends ConsumerState<TripMapScreen> {
  /// Map controller
  final MapController _mapController = MapController();

  /// Clustering manager instance
  ZoomAwareClusteringManager? _clusteringManager;

  /// Current clustering result
  ClusteringResult? _currentResult;

  /// Map zoom level
  double _currentZoom = 12.0;

  /// Map center
  LatLng _mapCenter = const LatLng(37.7749, -122.4194); // San Francisco

  /// Show cluster statistics overlay
  bool _showStats = true;

  /// Stream subscription for clustering updates
  dynamic _clusterSubscription;

  @override
  void initState() {
    super.initState();
    _initializeClustering();
  }

  @override
  void dispose() {
    _clusterSubscription?.cancel();
    _clusteringManager?.dispose();
    _mapController.dispose();
    super.dispose();
  }

  /// Initialize clustering manager with markers
  void _initializeClustering() {
    final markers = ref.read(tripMapMarkersProvider);

    // Create clustering manager with high-density configuration
    _clusteringManager = ClusteringManagerFactories.forHighDensity(
      markers: markers,
      initialZoom: _currentZoom,
      debounceDelayMs: 300,
      useBoundsBasedClustering: true,
    );

    // Listen to clustering result stream
    _clusterSubscription = _clusteringManager!.resultStream.listen((result) {
      if (mounted) {
        setState(() {
          _currentResult = result;
        });
      }
    });

    // Perform initial clustering
    _clusteringManager!.initialize().then((result) {
      if (mounted) {
        setState(() {
          _currentResult = result;
        });
      }
    });
  }

  /// Handle map zoom change
  void _onMapZoomChanged(double zoom) {
    if (_clusteringManager == null) return;

    setState(() {
      _currentZoom = zoom;
    });

    // Update clustering parameters based on new zoom level
    // This is debounced to avoid excessive re-clustering
    _clusteringManager!.updateZoomLevel(zoom);
  }

  /// Handle map bounds change (for bounds-based clustering)
  void _onMapBoundsChanged(LatLngBounds bounds) {
    if (_clusteringManager == null) return;

    // Re-cluster only visible markers for better performance
    _clusteringManager!.updateMapBounds(bounds);
  }

  /// Handle cluster tap - zoom to fit cluster
  void _onClusterTap(MapCluster cluster) {
    // Calculate bounds to fit all markers in cluster
    final bounds = _calculateBoundsForCluster(cluster);

    // Zoom map to fit cluster bounds
    _mapController.fitCamera(
      CameraFit.bounds(
        bounds: bounds,
        padding: const EdgeInsets.all(50),
      ),
    );
  }

  /// Calculate bounds for a cluster
  LatLngBounds _calculateBoundsForCluster(MapCluster cluster) {
    double minLat = cluster.lat;
    double maxLat = cluster.lat;
    double minLng = cluster.lng;
    double maxLng = cluster.lng;

    for (final marker in cluster.markers) {
      minLat = math.min(minLat, marker.lat);
      maxLat = math.max(maxLat, marker.lat);
      minLng = math.min(minLng, marker.lng);
      maxLng = math.max(maxLng, marker.lng);
    }

    return LatLngBounds(
      LatLng(minLat, minLng),
      LatLng(maxLat, maxLng),
    );
  }

  /// Build marker widget for individual marker
  Widget _buildMarker(MapMarker marker) {
    return MapMarkerWidget(
      marker: marker,
      size: 50,
      showTitle: false,
      onTap: () => _onMarkerTap(marker),
    );
  }

  /// Build cluster widget
  Widget _buildCluster(MapCluster cluster) {
    return MapClusterWithTypesWidget(
      cluster: cluster,
      showTypeIcons: true,
      onTap: () => _onClusterTap(cluster),
    );
  }

  /// Handle marker tap
  void _onMarkerTap(MapMarker marker) {
    showModalBottomSheet(
      context: context,
      builder: (context) => _MarkerDetailsSheet(marker: marker),
    );
  }

  /// Build statistics overlay
  Widget _buildStatsOverlay() {
    if (!_showStats || _clusteringManager == null) {
      return const SizedBox.shrink();
    }

    final stats = _clusteringManager!.statistics;
    final theme = Theme.of(context);

    return Positioned(
      top: 16,
      right: 16,
      child: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface.withOpacity(0.9),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Map Statistics',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            _buildStatRow('Zoom', '${stats['currentZoom'].toStringAsFixed(1)}'),
            _buildStatRow('Markers', '${stats['totalMarkers']}'),
            _buildStatRow('Clusters', '${stats['clusters']}'),
            _buildStatRow('Unclustered', '${stats['unclusteredMarkers']}'),
            _buildStatRow(
              'Efficiency',
              '${(stats['efficiency'] * 100).toStringAsFixed(0)}%',
            ),
            _buildStatRow('Algorithm', '${stats['algorithm']}'),
          ],
        ),
      ),
    );
  }

  /// Build a statistics row
  Widget _buildStatRow(String label, String value) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '$label:',
            style: theme.textTheme.bodySmall,
          ),
          Text(
            value,
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final markers = ref.watch(tripMapMarkersProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Trip Map'),
        actions: [
          IconButton(
            icon: Icon(_showStats ? Icons.analytics : Icons.analytics_outlined),
            onPressed: () {
              setState(() {
                _showStats = !_showStats;
              });
            },
            tooltip: 'Toggle statistics',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              _clusteringManager?.clearHistory();
              _initializeClustering();
            },
            tooltip: 'Reset clustering',
          ),
          PopupMenuButton<ClusteringPreset>(
            onSelected: (preset) {
              _applyClusteringPreset(preset);
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: ClusteringPreset.highDensity,
                child: Text('High Density (City)'),
              ),
              const PopupMenuItem(
                value: ClusteringPreset.lowDensity,
                child: Text('Low Density (Rural)'),
              ),
              const PopupMenuItem(
                value: ClusteringPreset.performance,
                child: Text('Performance (500+ markers)'),
              ),
            ],
          ),
        ],
      ),
      body: Stack(
        children: [
          _buildMap(markers),
          if (_showStats) _buildStatsOverlay(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _mapController.move(_mapCenter, _currentZoom);
        },
        child: const Icon(Icons.center_focus_strong),
      ),
    );
  }

  /// Build the Flutter Map widget
  Widget _buildMap(List<MapMarker> markers) {
    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        initialCenter: _mapCenter,
        initialZoom: _currentZoom,
        minZoom: 2,
        maxZoom: 18,
        onMapEvent: (event) {
          if (event is MapEventMoveEnd) {
            // Update clustering when map movement ends
            _onMapZoomChanged(event.camera.zoom);
            _onMapBoundsChanged(event.camera.bounds);
          }
        },
      ),
      children: [
        // OpenStreetMap tile layer
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.example.soloadventurer',
        ),
        // Marker and cluster layer
        if (_currentResult != null)
          MarkerLayer(
            markers: _buildMapMarkers(),
          ),
        // Zoom controls
        const RichAttributionWidget(
          attributions: [
            TextSourceAttribution('OpenStreetMap contributors'),
          ],
        ),
      ],
    );
  }

  /// Build map markers from clustering result
  List<Marker> _buildMapMarkers() {
    final markers = <Marker>[];

    // Add clusters
    for (final cluster in _currentResult!.clusters) {
      markers.add(
        Marker(
          point: LatLng(cluster.lat, cluster.lng),
          width: cluster.markerSize.toDouble(),
          height: cluster.markerSize.toDouble(),
          child: _buildCluster(cluster),
        ),
      );
    }

    // Add unclustered markers
    for (final marker in _currentResult!.unclusteredMarkers) {
      markers.add(
        Marker(
          point: LatLng(marker.lat, marker.lng),
          width: 50.0,
          height: 50.0,
          child: _buildMarker(marker),
        ),
      );
    }

    return markers;
  }

  /// Apply clustering preset configuration
  void _applyClusteringPreset(ClusteringPreset preset) {
    final markers = ref.read(tripMapMarkersProvider);

    // Cancel current subscription
    _clusterSubscription?.cancel();
    _clusteringManager?.dispose();

    // Create new manager with preset configuration
    switch (preset) {
      case ClusteringPreset.highDensity:
        _clusteringManager = ClusteringManagerFactories.forHighDensity(
          markers: markers,
          initialZoom: _currentZoom,
          debounceDelayMs: 300,
          useBoundsBasedClustering: true,
        );
        break;
      case ClusteringPreset.lowDensity:
        _clusteringManager = ClusteringManagerFactories.forLowDensity(
          markers: markers,
          initialZoom: _currentZoom,
          debounceDelayMs: 300,
          useBoundsBasedClustering: false,
        );
        break;
      case ClusteringPreset.performance:
        _clusteringManager = ClusteringManagerFactories.forPerformance(
          markers: markers,
          initialZoom: _currentZoom,
          debounceDelayMs: 200,
          useBoundsBasedClustering: true,
        );
        break;
    }

    // Re-subscribe to result stream
    _clusterSubscription = _clusteringManager!.resultStream.listen((result) {
      if (mounted) {
        setState(() {
          _currentResult = result;
        });
      }
    });

    // Re-cluster with new configuration
    _clusteringManager!.initialize().then((result) {
      if (mounted) {
        setState(() {
          _currentResult = result;
        });
      }
    });
  }
}

/// Clustering preset options
enum ClusteringPreset {
  highDensity,
  lowDensity,
  performance,
}

/// Bottom sheet for displaying marker details
class _MarkerDetailsSheet extends StatelessWidget {
  final MapMarker marker;

  const _MarkerDetailsSheet({required this.marker});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            marker.title ?? 'Marker',
            style: theme.textTheme.titleLarge,
          ),
          if (marker.description != null) ...[
            const SizedBox(height: 8),
            Text(
              marker.description!,
              style: theme.textTheme.bodyMedium,
            ),
          ],
          const SizedBox(height: 16),
          Row(
            children: [
              Icon(Icons.location_on, color: theme.colorScheme.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '${marker.lat.toStringAsFixed(4)}, ${marker.lng.toStringAsFixed(4)}',
                  style: theme.textTheme.bodySmall,
                ),
              ),
            ],
          ),
          if (marker.metadata != null) ...[
            const SizedBox(height: 8),
            Text(
              'Type: ${marker.type}',
              style: theme.textTheme.bodySmall,
            ),
          ],
        ],
      ),
    );
  }
}
