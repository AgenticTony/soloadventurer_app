# Cluster Tap Handling & Expand Functionality

## Overview

This document describes the tap-to-expand functionality for clustered map markers in the SoloAdventurer app. When users tap a cluster marker, they can view all locations contained within that cluster through an interactive bottom sheet.

## Features

### 1. Cluster Expand Bottom Sheet

Tapping a cluster opens a bottom sheet that displays:
- **Cluster Header**: Shows total number of locations in the cluster
- **Action Buttons**: Quick access to "Zoom to Fit" and "Close"
- **Organized List**: All markers grouped by type (Trips, Activities, Restaurants, etc.)
- **Marker Details**: Each marker shows title, description, and type icon
- **Direct Access**: Tap any marker to view its details

### 2. Type-Based Grouping

Markers are automatically grouped by type for better organization:
- **Trips** (blue, flight_takeoff icon)
- **Activities** (orange, hiking icon)
- **Photos** (purple, photo_camera icon)
- **Accommodations** (teal, hotel icon)
- **Restaurants** (red, restaurant icon)
- **Transport** (indigo, directions_car icon)
- **Places** (amber, place icon)
- **Other** (grey, location_on icon)

Each group shows a count badge indicating the number of markers in that category.

### 3. Quick Actions

**Zoom to Fit**:
- Automatically zooms the map to show all markers in the cluster
- Uses calculated bounds to ensure all markers are visible
- Adds padding for better visual presentation

**Close**:
- Dismisses the bottom sheet
- Returns to the map view

**Tap Marker**:
- Opens marker details sheet
- Shows full marker information (title, description, location, type)

## Architecture

### Components

#### `_ClusterExpandSheet`
Main bottom sheet widget that displays cluster contents.

**Properties:**
- `cluster`: The MapCluster to display
- `onZoomToFit`: Callback when user taps "Zoom to Fit" button
- `onMarkerTap`: Callback when user taps a specific marker

**Features:**
- Resolves marker IDs to actual marker objects
- Groups markers by type
- Displays action buttons
- Handles marker tap events

#### `_MarkerTypeSection`
Widget for displaying a section of markers of the same type.

**Features:**
- Shows type icon and label
- Displays count badge
- Lists all markers of that type
- Handles individual marker taps

#### `_MarkerListItem`
List item widget for a single marker.

**Features:**
- Shows marker icon with type-specific color
- Displays title and description
- Handles tap to show marker details
- Shows chevron icon for navigation indication

### Data Flow

```
User taps cluster
    ↓
_onClusterTap(cluster)
    ↓
Show _ClusterExpandSheet
    ↓
Resolve marker IDs from cluster.markerIds
    ↓
Group markers by type
    ↓
Display organized list
    ↓
User interaction (zoom, tap marker, close)
```

## Usage Examples

### Basic Cluster Tap Handling

```dart
// In TripMapScreen
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
```

### Zoom to Fit Implementation

```dart
void _onZoomToFitCluster(MapCluster cluster) {
  final bounds = _calculateBoundsForCluster(cluster);

  _mapController.fitCamera(
    CameraFit.bounds(
      bounds: bounds,
      padding: const EdgeInsets.all(50),
    ),
  );
}
```

### Bounds Calculation

```dart
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
```

## UI Design

### Bottom Sheet Structure

```
┌────────────────────────────────┐
│         ════════               │  ← Handle bar
├────────────────────────────────┤
│ [📚] 5 Locations              │  ← Header
│      Tap to view details       │
├────────────────────────────────┤
│ [🔍 Zoom to Fit] [🗺️ Close]   │  ← Action buttons
├────────────────────────────────┤
│                                │
│  🥾 Activities (2)            │  ← Type section
│    └─ Golden Gate Bridge      │
│    └─ Alcatraz Tour           │
│                                │
│  🍽️ Restaurants (1)           │
│    └─ Seafood Restaurant      │
│                                │
│  ✈️ Trips (1)                 │
│    └─ San Francisco Trip       │
│                                │
└────────────────────────────────┘
```

### Color Scheme

Markers use type-specific colors for visual distinction:
- **Trips**: Blue (#2196F3)
- **Activities**: Orange (#FF9800)
- **Photos**: Purple (#9C27B0)
- **Accommodations**: Teal (#009688)
- **Restaurants**: Red (#F44336)
- **Transport**: Indigo (#3F51B5)
- **Places**: Amber (#FFC107)
- **Other**: Grey (#9E9E9E)

## Testing

### Test Coverage

The cluster tap handling is tested in `cluster_tap_handling_test.dart`:

- ✅ Cluster expand sheet displays correct information
- ✅ Zoom to Fit button triggers callback
- ✅ Tapping marker item triggers marker tap callback
- ✅ Markers are grouped by type with correct counts
- ✅ Handle bar is displayed correctly
- ✅ Empty clusters display correctly
- ✅ Multiple markers of same type group correctly

### Running Tests

```bash
flutter test test/features/travel/presentation/screens/cluster_tap_handling_test.dart
```

## Performance Considerations

1. **Marker Resolution**: Markers are resolved from the provider once when the sheet opens
2. **Grouping**: Markers are grouped by type during build, which is efficient for typical cluster sizes
3. **Bounds Calculation**: Uses provider read (not watch) for efficient one-time access
4. **Scroll Physics**: Uses `ClampingScrollPhysics` for smooth scrolling in bottom sheet

## Best Practices

### When to Use Cluster Tap Handling

✅ **Use when:**
- User needs to see all locations in a cluster without zooming
- Showing marker details is important before map interaction
- Providing quick navigation to specific locations
- Displaying marker information in a list format

❌ **Don't use when:**
- Cluster contains only 2-3 markers (direct zoom is better)
- User wants immediate map navigation
- Showing list would take too much screen space

### UX Guidelines

1. **Cluster Size**: Use tap-to-expand for clusters with 4+ markers
2. **Action Priority**: "Zoom to Fit" is the primary action (leftmost button)
3. **Information Hierarchy**: Type → Count → Individual markers
4. **Scroll Behavior**: List should be scrollable for large clusters
5. **Visual Feedback**: Clear tap targets (48dp minimum) for all interactive elements

## Accessibility

- **Semantic Labels**: All buttons have clear labels
- **Tap Targets**: Minimum 48dp x 48dp for all interactive elements
- **Color Contrast**: Type colors meet WCAG AA standards
- **Screen Reader**: Markers have proper semantic labels

## Integration

### Dependencies

- `flutter_riverpod`: State management for marker providers
- `flutter_map`: Map controller for zoom operations
- `latlong2`: LatLng bounds calculation
- `Material`: Bottom sheet and navigation components

### Provider Integration

The cluster expand sheet uses `tripMapMarkersProvider` to resolve marker IDs:

```dart
final allMarkers = ref.watch(tripMapMarkersProvider);
final clusterMarkers = allMarkers
    .where((marker) => cluster.markerIds.contains(marker.id))
    .toList();
```

## Future Enhancements

Potential improvements to consider:

1. **Search Functionality**: Add search bar to filter markers in cluster
2. **Sort Options**: Allow sorting by distance, name, or type
3. **Map Preview**: Show mini-map preview of cluster location
4. **Batch Actions**: Select multiple markers for batch operations
5. **Animation**: Animate marker items when sheet opens
6. **Favorites**: Allow marking favorite markers
7. **Share**: Share cluster or individual markers

## Troubleshooting

### Common Issues

**Issue**: Markers not appearing in cluster sheet
- **Cause**: Marker IDs in cluster don't match IDs in provider
- **Fix**: Ensure marker IDs are consistent across cluster and provider

**Issue**: Bottom sheet doesn't open
- **Cause**: Missing or incorrect context
- **Fix**: Use valid context from widget tree

**Issue**: Bounds calculation is incorrect
- **Cause**: Empty marker list or incorrect position data
- **Fix**: Check that cluster has valid markers and positions

**Issue**: Performance degradation with large clusters
- **Cause**: Too many markers in single cluster
- **Fix**: Adjust clustering parameters to reduce cluster size

## Related Files

- `lib/features/travel/presentation/screens/trip_map_screen.dart` - Main map screen
- `lib/core/models/map_marker.dart` - MapMarker and MapCluster models
- `lib/core/services/map_marker_clustering_service.dart` - Clustering service
- `lib/core/services/zoom_aware_clustering_manager.dart` - Zoom-aware manager
- `lib/core/widgets/map_marker_widgets.dart` - Marker and cluster widgets

## References

- [Flutter Map Documentation](https://pub.dev/packages/flutter_map)
- [Riverpod Documentation](https://riverpod.dev)
- [Material Bottom Sheets](https://api.flutter.dev/flutter/material/BottomSheet-class.html)

## Version History

- **1.0.0** (2026-01-05): Initial implementation of cluster tap handling
  - Cluster expand bottom sheet
  - Type-based marker grouping
  - Zoom to fit functionality
  - Individual marker tap handling
  - Comprehensive test coverage
