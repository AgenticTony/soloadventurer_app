import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:intl/intl.dart';
import 'package:soloadventurer/features/journal/presentation/providers/journal_map_provider.dart';
import 'package:soloadventurer/features/journal/presentation/screens/journal_entry_detail_screen.dart';

/// Screen displaying all journal locations on an interactive map
class JournalMapScreen extends ConsumerStatefulWidget {
  /// Optional trip ID to filter entries
  final String? tripId;

  const JournalMapScreen({
    super.key,
    this.tripId,
  });

  @override
  ConsumerState<JournalMapScreen> createState() => _JournalMapScreenState();
}

class _JournalMapScreenState extends ConsumerState<JournalMapScreen> {
  final MapController _mapController = MapController();
  final DateFormat _dateFormat = DateFormat('MMM dd, yyyy');

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Use trip-specific provider if tripId is provided, otherwise use global provider
    final mapState = widget.tripId != null
        ? ref.watch(journalTripMapProvider(widget.tripId!))
        : ref.watch(journalMapProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Journal Map'),
        actions: [
          // Favorites filter
          if (widget.tripId == null)
            IconButton(
              icon: Icon(
                mapState.showOnlyFavorites
                    ? Icons.favorite
                    : Icons.favorite_border,
              ),
              onPressed: () {
                ref.read(journalMapProvider.notifier).toggleFavoritesFilter();
              },
              tooltip: mapState.showOnlyFavorites
                  ? 'Show all entries'
                  : 'Show favorites only',
            ),

          // Center on all markers
          IconButton(
            icon: const Icon(Icons.center_focus_strong),
            onPressed: mapState.hasMarkers
                ? () => _centerOnMarkers(mapState)
                : null,
            tooltip: 'Center on all markers',
          ),

          // Refresh button
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              if (widget.tripId != null) {
                ref.read(journalTripMapProvider(widget.tripId!).notifier).refresh();
              } else {
                ref.read(journalMapProvider.notifier).refresh();
              }
            },
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: mapState.isInitialLoading
          ? const Center(child: CircularProgressIndicator())
          : mapState.error != null
              ? _buildError(context, mapState.error!)
              : !mapState.hasMarkers
                  ? _buildEmptyState(context)
                  : _buildMap(context, mapState),
      floatingActionButton: mapState.hasSelection
          ? FloatingActionButton.extended(
              onPressed: () {
                _navigateToEntry(mapState.selectedEntry!);
              },
              icon: const Icon(Icons.open_in_full),
              label: const Text('View Entry'),
            )
          : null,
    );
  }

  /// Build the map widget
  Widget _buildMap(BuildContext context, JournalMapState mapState) {
    return Stack(
      children: [
        FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            initialCenter: mapState.centerPosition ?? const LatLng(0, 0),
            initialZoom: mapState.zoomLevel,
            minZoom: 2.0,
            maxZoom: 18.0,
            interactionOptions: const InteractionOptions(
              flags: InteractiveFlag.all,
            ),
            onMapEvent: (MapEvent event) {
              if (event is MapEventMoveEnd) {
                final notifier = widget.tripId != null
                    ? ref.read(journalTripMapProvider(widget.tripId!).notifier)
                    : ref.read(journalMapProvider.notifier);
                notifier.updateCenter(event.camera.center);
                notifier.updateZoom(event.camera.zoom);
              }
            },
          ),
          children: [
            // OpenStreetMap tile layer
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.soloadventurer.app',
              maxZoom: 19,
            ),

            // Marker layer
            MarkerLayer(
              markers: _buildMarkers(context, mapState),
            ),

            // Polyline layer (optional - connect markers in chronological order)
            if (mapState.markers.length > 1)
              PolylineLayer(
                polylines: [
                  Polyline(
                    points: mapState.markers
                        .map((marker) => marker.position)
                        .toList(),
                    strokeWidth: 3.0,
                    color: Theme.of(context)
                        .colorScheme
                        .primary
                        .withOpacity(0.5),
                  ),
                ],
              ),
          ],
        ),

        // Info card for selected marker
        if (mapState.hasSelection)
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: _buildEntryCard(context, mapState.selectedEntry!),
          ),

        // Marker count badge
        Positioned(
          bottom: 16,
          left: 16,
          child: _buildMarkerCountBadge(context, mapState),
        ),
      ],
    );
  }

  /// Build markers for the map
  List<Marker> _buildMarkers(BuildContext context, JournalMapState mapState) {
    return mapState.markers.map((marker) {
      final isSelected = mapState.selectedEntry?.id == marker.entry.id;
      final isFavorite = marker.entry.isFavorite;

      return Marker(
        point: marker.position,
        width: isSelected ? 50.0 : 40.0,
        height: isSelected ? 50.0 : 40.0,
        child: GestureDetector(
          onTap: () => _onMarkerTapped(marker, mapState),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Marker shadow
              Container(
                width: isSelected ? 40 : 30,
                height: isSelected ? 40 : 30,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.black.withOpacity(0.2),
                ),
              ),
              // Marker icon
              Container(
                width: isSelected ? 40 : 30,
                height: isSelected ? 40 : 30,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSelected
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.primaryContainer,
                  border: Border.all(
                    color: isSelected
                        ? Theme.of(context).colorScheme.onPrimary
                        : Theme.of(context).colorScheme.primary,
                    width: isSelected ? 3 : 2,
                  ),
                ),
                child: Icon(
                  Icons.location_on,
                  color: isSelected
                      ? Theme.of(context).colorScheme.onPrimary
                      : Theme.of(context).colorScheme.primary,
                  size: isSelected ? 24 : 18,
                ),
              ),
              // Favorite indicator
              if (isFavorite)
                Positioned(
                  top: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 1),
                    ),
                    child: const Icon(
                      Icons.favorite,
                      color: Colors.white,
                      size: 10,
                    ),
                  ),
                ),
            ],
          ),
        ),
      );
    }).toList();
  }

  /// Build entry card for selected marker
  Widget _buildEntryCard(BuildContext context, entry) {
    return Card(
      elevation: 8,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    entry.title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (entry.isFavorite) ...[
                  const SizedBox(width: 8),
                  const Icon(Icons.favorite, color: Colors.red, size: 16),
                ],
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.close, size: 20),
                  onPressed: () {
                    if (widget.tripId != null) {
                      ref.read(journalTripMapProvider(widget.tripId!).notifier).clearSelection();
                    } else {
                      ref.read(journalMapProvider.notifier).clearSelection();
                    }
                  },
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            const SizedBox(height: 4),
            if (entry.locationName != null)
              Row(
                children: [
                  const Icon(Icons.location_on, size: 14, color: Colors.grey),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      entry.locationName!,
                      style: Theme.of(context).textTheme.bodySmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 14, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  _dateFormat.format(entry.entryDate),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
            if (entry.mood != null) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.emoji_emotions, size: 14, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    entry.mood!,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Build marker count badge
  Widget _buildMarkerCountBadge(BuildContext context, JournalMapState mapState) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.location_on,
              size: 16,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 6),
            Text(
              '${mapState.markerCount} ${mapState.markerCount == 1 ? 'location' : 'locations'}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build error state
  Widget _buildError(BuildContext context, String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          Text(
            'Error Loading Map',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            error,
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              if (widget.tripId != null) {
                ref.read(journalTripMapProvider(widget.tripId!).notifier).refresh();
              } else {
                ref.read(journalMapProvider.notifier).refresh();
              }
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  /// Build empty state
  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.map_outlined,
            size: 80,
            color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
          ),
          const SizedBox(height: 24),
          Text(
            'No Locations Yet',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              widget.tripId != null
                  ? 'Journal entries with location data will appear on the map here'
                  : 'Your journal entries with location data will appear on the map here. Start documenting your adventures!',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  /// Handle marker tap
  void _onMarkerTapped(JournalMapMarker marker, JournalMapState mapState) {
    final notifier = widget.tripId != null
        ? ref.read(journalTripMapProvider(widget.tripId!).notifier)
        : ref.read(journalMapProvider.notifier);

    // Toggle selection
    if (mapState.selectedEntry?.id == marker.entry.id) {
      notifier.clearSelection();
    } else {
      notifier.selectEntry(marker.entry);
      // Move map to marker position
      _mapController.move(marker.position, 15.0);
    }
  }

  /// Center map on all markers
  void _centerOnMarkers(JournalMapState mapState) {
    if (mapState.markers.isEmpty) return;

    // Calculate bounds
    double minLat = mapState.markers.first.position.latitude;
    double maxLat = mapState.markers.first.position.latitude;
    double minLng = mapState.markers.first.position.longitude;
    double maxLng = mapState.markers.first.position.longitude;

    for (final marker in mapState.markers) {
      minLat = math.min(minLat, marker.position.latitude);
      maxLat = math.max(maxLat, marker.position.latitude);
      minLng = math.min(minLng, marker.position.longitude);
      maxLng = math.max(maxLng, marker.position.longitude);
    }

    // Calculate center and appropriate zoom
    final center = LatLng((minLat + maxLat) / 2, (minLng + maxLng) / 2);
    final latDiff = maxLat - minLat;
    final lngDiff = maxLng - minLng;
    final maxDiff = math.max(latDiff, lngDiff);

    // Adjust zoom based on spread
    double zoom = 13.0;
    if (maxDiff > 100) {
      zoom = 3.0;
    } else if (maxDiff > 50) zoom = 4.0;
    else if (maxDiff > 20) zoom = 5.0;
    else if (maxDiff > 10) zoom = 6.0;
    else if (maxDiff > 5) zoom = 7.0;
    else if (maxDiff > 2) zoom = 8.0;
    else if (maxDiff > 1) zoom = 9.0;
    else if (maxDiff > 0.5) zoom = 10.0;
    else if (maxDiff > 0.2) zoom = 11.0;
    else if (maxDiff > 0.1) zoom = 12.0;

    _mapController.move(center, zoom);
  }

  /// Navigate to entry detail screen
  void _navigateToEntry(entry) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => JournalEntryDetailScreen(entryId: entry.id),
      ),
    );
  }
}
