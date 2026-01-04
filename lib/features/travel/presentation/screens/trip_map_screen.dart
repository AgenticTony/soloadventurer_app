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

  /// Handle cluster tap - show expand options
  void _onClusterTap(MapCluster cluster) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _ClusterExpandSheet(
        cluster: cluster,
        onZoomToFit: () => _onZoomToFitCluster(cluster),
        onMarkerTap: (marker) => _onMarkerTap(marker),
      ),
    );
  }

  /// Zoom to fit cluster bounds
  void _onZoomToFitCluster(MapCluster cluster) {
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
    final allMarkers = ref.read(tripMapMarkersProvider);
    final clusterMarkers = allMarkers
        .where((marker) => cluster.markerIds.contains(marker.id))
        .toList();

    if (clusterMarkers.isEmpty) {
      return LatLngBounds(cluster.position, cluster.position);
    }

    double minLat = cluster.position.latitude;
    double maxLat = cluster.position.latitude;
    double minLng = cluster.position.longitude;
    double maxLng = cluster.position.longitude;

    for (final marker in clusterMarkers) {
      minLat = math.min(minLat, marker.position.latitude);
      maxLat = math.max(maxLat, marker.position.latitude);
      minLng = math.min(minLng, marker.position.longitude);
      maxLng = math.max(maxLng, marker.position.longitude);
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
                  '${marker.position.latitude.toStringAsFixed(4)}, ${marker.position.longitude.toStringAsFixed(4)}',
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

/// Bottom sheet for expanding and viewing cluster contents
class _ClusterExpandSheet extends ConsumerWidget {
  final MapCluster cluster;
  final VoidCallback onZoomToFit;
  final Function(MapMarker) onMarkerTap;

  const _ClusterExpandSheet({
    required this.cluster,
    required this.onZoomToFit,
    required this.onMarkerTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final allMarkers = ref.watch(tripMapMarkersProvider);

    // Get markers in this cluster
    final clusterMarkers = allMarkers
        .where((marker) => cluster.markerIds.contains(marker.id))
        .toList();

    // Group markers by type for better organization
    final groupedMarkers = _groupMarkersByType(clusterMarkers);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: theme.dividerColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header with cluster info
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.layers,
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${cluster.markerCount} Locations',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Tap to view details',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // Quick action buttons
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Expanded(
                  child: FilledButton.tonalIcon(
                    onPressed: () {
                      Navigator.of(context).pop();
                      onZoomToFit();
                    },
                    icon: const Icon(Icons.zoom_in_map),
                    label: const Text('Zoom to Fit'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton.tonalIcon(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    icon: const Icon(Icons.map),
                    label: const Text('Close'),
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // Markers list
          Flexible(
            child: ListView.builder(
              shrinkWrap: true,
              physics: const ClampingScrollPhysics(),
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: groupedMarkers.length,
              itemBuilder: (context, index) {
                final entry = groupedMarkers.entries.elementAt(index);
                final type = entry.key;
                final markers = entry.value;

                return _MarkerTypeSection(
                  type: type,
                  markers: markers,
                  onMarkerTap: (marker) {
                    Navigator.of(context).pop();
                    onMarkerTap(marker);
                  },
                );
              },
            ),
          ),

          // Bottom padding
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  /// Group markers by type for organized display
  Map<MarkerType, List<MapMarker>> _groupMarkersByType(List<MapMarker> markers) {
    final grouped = <MarkerType, List<MapMarker>>{};

    for (final marker in markers) {
      grouped.putIfAbsent(marker.type, () => []).add(marker);
    }

    // Sort by marker count (most common types first)
    final sortedEntries = grouped.entries.toList()
      ..sort((a, b) => b.value.length.compareTo(a.value.length));

    return Map.fromEntries(sortedEntries);
  }
}

/// Widget for displaying a section of markers grouped by type
class _MarkerTypeSection extends StatelessWidget {
  final MarkerType type;
  final List<MapMarker> markers;
  final Function(MapMarker) onMarkerTap;

  const _MarkerTypeSection({
    required this.type,
    required this.markers,
    required this.onMarkerTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Type header
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Row(
            children: [
              Icon(
                _getTypeIcon(type),
                size: 16,
                color: _getTypeColor(type),
              ),
              const SizedBox(width: 8),
              Text(
                _getTypeLabel(type),
                style: theme.textTheme.titleSmall?.copyWith(
                  color: _getTypeColor(type),
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: theme.colorScheme.secondaryContainer,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${markers.length}',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSecondaryContainer,
                  ),
                ),
              ),
            ],
          ),
        ),

        // Markers in this type
        ...markers.map((marker) => _MarkerListItem(
              marker: marker,
              onTap: () => onMarkerTap(marker),
            )),
      ],
    );
  }

  IconData _getTypeIcon(MarkerType type) {
    switch (type) {
      case MarkerType.trip:
        return Icons.flight_takeoff;
      case MarkerType.activity:
        return Icons.hiking;
      case MarkerType.photo:
        return Icons.photo_camera;
      case MarkerType.accommodation:
        return Icons.hotel;
      case MarkerType.restaurant:
        return Icons.restaurant;
      case MarkerType.transport:
        return Icons.directions_car;
      case MarkerType.poi:
        return Icons.place;
      case MarkerType.defaultType:
        return Icons.location_on;
    }
  }

  Color _getTypeColor(MarkerType type) {
    switch (type) {
      case MarkerType.trip:
        return Colors.blue;
      case MarkerType.activity:
        return Colors.orange;
      case MarkerType.photo:
        return Colors.purple;
      case MarkerType.accommodation:
        return Colors.teal;
      case MarkerType.restaurant:
        return Colors.red;
      case MarkerType.transport:
        return Colors.indigo;
      case MarkerType.poi:
        return Colors.amber;
      case MarkerType.defaultType:
        return Colors.grey;
    }
  }

  String _getTypeLabel(MarkerType type) {
    switch (type) {
      case MarkerType.trip:
        return 'Trips';
      case MarkerType.activity:
        return 'Activities';
      case MarkerType.photo:
        return 'Photos';
      case MarkerType.accommodation:
        return 'Accommodations';
      case MarkerType.restaurant:
        return 'Restaurants';
      case MarkerType.transport:
        return 'Transport';
      case MarkerType.poi:
        return 'Places';
      case MarkerType.defaultType:
        return 'Other';
    }
  }
}

/// List item for a single marker in the cluster
class _MarkerListItem extends StatelessWidget {
  final MapMarker marker;
  final VoidCallback onTap;

  const _MarkerListItem({
    required this.marker,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            // Marker icon
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: _getMarkerColor(context).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                _getMarkerIcon(),
                color: _getMarkerColor(context),
                size: 24,
              ),
            ),
            const SizedBox(width: 12),

            // Marker info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    marker.title ?? 'Unnamed Marker',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (marker.description != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      marker.description!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),

            // Chevron icon
            Icon(
              Icons.chevron_right,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }

  Color _getMarkerColor(BuildContext context) {
    switch (marker.type) {
      case MarkerType.trip:
        return Colors.blue;
      case MarkerType.activity:
        return Colors.orange;
      case MarkerType.photo:
        return Colors.purple;
      case MarkerType.accommodation:
        return Colors.teal;
      case MarkerType.restaurant:
        return Colors.red;
      case MarkerType.transport:
        return Colors.indigo;
      case MarkerType.poi:
        return Colors.amber;
      case MarkerType.defaultType:
        return Theme.of(context).primaryColor;
    }
  }

  IconData _getMarkerIcon() {
    switch (marker.type) {
      case MarkerType.trip:
        return Icons.flight_takeoff;
      case MarkerType.activity:
        return Icons.hiking;
      case MarkerType.photo:
        return Icons.photo_camera;
      case MarkerType.accommodation:
        return Icons.hotel;
      case MarkerType.restaurant:
        return Icons.restaurant;
      case MarkerType.transport:
        return Icons.directions_car;
      case MarkerType.poi:
        return Icons.place;
      case MarkerType.defaultType:
        return Icons.location_on;
    }
  }
}
