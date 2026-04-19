import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:soloadventurer/core/models/map_marker.dart';

/// Tests for cluster tap handling logic and MapCluster behavior
///
/// Verifies that MapCluster correctly:
/// - Groups markers by type
/// - Counts markers per type
/// - Calculates center positions
/// - Handles single and multiple marker types
/// - Calculates cluster size
void main() {
  group('MapCluster Creation', () {
    test('creates cluster from markers with correct center position',
        () async {
      final markers = [
        MapMarker.fromLatLng(
          id: 'trip1',
          latitude: 37.7749,
          longitude: -122.4194,
          title: 'San Francisco Trip',
          description: 'A wonderful trip to SF',
          type: MarkerType.trip,
        ),
        MapMarker.fromLatLng(
          id: 'activity1',
          latitude: 37.7750,
          longitude: -122.4195,
          title: 'Golden Gate Bridge',
          description: 'Visit the famous bridge',
          type: MarkerType.activity,
        ),
        MapMarker.fromLatLng(
          id: 'restaurant1',
          latitude: 37.7751,
          longitude: -122.4196,
          title: 'Seafood Restaurant',
          description: 'Fresh seafood downtown',
          type: MarkerType.restaurant,
        ),
      ];

      final cluster = MapCluster.fromMarkers(
        id: 'cluster1',
        markers: markers,
      );

      expect(cluster.id, 'cluster1');
      expect(cluster.markerCount, 3);
      expect(cluster.markerIds, containsAll(['trip1', 'activity1', 'restaurant1']));
      expect(cluster.position.latitude, closeTo(37.7750, 0.001));
      expect(cluster.position.longitude, closeTo(-122.4195, 0.001));
    });

    test('throws when creating cluster from empty markers', () {
      expect(
        () => MapCluster.fromMarkers(id: 'empty', markers: []),
        throwsArgumentError,
      );
    });

    test('creates cluster with single marker', () {
      final markers = [
        MapMarker.fromLatLng(
          id: 'single1',
          latitude: 37.7749,
          longitude: -122.4194,
          title: 'Single Marker',
          type: MarkerType.trip,
        ),
      ];

      final cluster = MapCluster.fromMarkers(
        id: 'single-cluster',
        markers: markers,
      );

      expect(cluster.markerCount, 1);
      expect(cluster.markerIds, ['single1']);
      expect(cluster.position.latitude, 37.7749);
    });
  });

  group('Cluster Marker Type Grouping', () {
    late List<MapMarker> mixedMarkers;

    setUp(() {
      mixedMarkers = [
        MapMarker.fromLatLng(
          id: 'trip1',
          latitude: 37.7749,
          longitude: -122.4194,
          title: 'San Francisco Trip',
          description: 'A wonderful trip to SF',
          type: MarkerType.trip,
        ),
        MapMarker.fromLatLng(
          id: 'activity1',
          latitude: 37.7750,
          longitude: -122.4195,
          title: 'Golden Gate Bridge',
          description: 'Visit the famous bridge',
          type: MarkerType.activity,
        ),
        MapMarker.fromLatLng(
          id: 'restaurant1',
          latitude: 37.7751,
          longitude: -122.4196,
          title: 'Seafood Restaurant',
          description: 'Fresh seafood downtown',
          type: MarkerType.restaurant,
        ),
        MapMarker.fromLatLng(
          id: 'photo1',
          latitude: 37.7752,
          longitude: -122.4197,
          title: 'Sunset Photo',
          description: 'Beautiful sunset at the pier',
          type: MarkerType.photo,
        ),
        MapMarker.fromLatLng(
          id: 'accommodation1',
          latitude: 37.7753,
          longitude: -122.4198,
          title: 'Downtown Hotel',
          description: 'Central hotel location',
          type: MarkerType.accommodation,
        ),
      ];
    });

    test('cluster contains all marker types', () {
      final cluster = MapCluster.fromMarkers(
        id: 'cluster1',
        markers: mixedMarkers,
      );

      expect(cluster.markerTypes.length, 5);
      expect(cluster.containsType(MarkerType.trip), isTrue);
      expect(cluster.containsType(MarkerType.activity), isTrue);
      expect(cluster.containsType(MarkerType.restaurant), isTrue);
      expect(cluster.containsType(MarkerType.photo), isTrue);
      expect(cluster.containsType(MarkerType.accommodation), isTrue);
    });

    test('cluster counts by type correctly', () {
      final cluster = MapCluster.fromMarkers(
        id: 'cluster1',
        markers: mixedMarkers,
      );

      expect(cluster.countByType(MarkerType.trip), 1);
      expect(cluster.countByType(MarkerType.activity), 1);
      expect(cluster.countByType(MarkerType.restaurant), 1);
      expect(cluster.countByType(MarkerType.photo), 1);
      expect(cluster.countByType(MarkerType.accommodation), 1);
      expect(cluster.countByType(MarkerType.transport), 0);
    });

    test('cluster with multiple markers of same type groups correctly', () {
      final multiMarkers = [
        MapMarker.fromLatLng(
          id: 'trip1',
          latitude: 37.7749,
          longitude: -122.4194,
          title: 'Trip 1',
          type: MarkerType.trip,
        ),
        MapMarker.fromLatLng(
          id: 'trip2',
          latitude: 37.7750,
          longitude: -122.4195,
          title: 'Trip 2',
          type: MarkerType.trip,
        ),
        MapMarker.fromLatLng(
          id: 'trip3',
          latitude: 37.7751,
          longitude: -122.4196,
          title: 'Trip 3',
          type: MarkerType.trip,
        ),
      ];

      final cluster = MapCluster.fromMarkers(
        id: 'multi-trip-cluster',
        markers: multiMarkers,
      );

      expect(cluster.markerCount, 3);
      expect(cluster.countByType(MarkerType.trip), 3);
      expect(cluster.containsType(MarkerType.activity), isFalse);
    });
  });

  group('Cluster Bounds Calculation', () {
    test('calculates cluster size from markers', () {
      final markers = [
        MapMarker.fromLatLng(
          id: 'marker1',
          latitude: 37.7749,
          longitude: -122.4194,
          title: 'Marker 1',
        ),
        MapMarker.fromLatLng(
          id: 'marker2',
          latitude: 37.7849,
          longitude: -122.4094,
          title: 'Marker 2',
        ),
        MapMarker.fromLatLng(
          id: 'marker3',
          latitude: 37.7649,
          longitude: -122.4294,
          title: 'Marker 3',
        ),
      ];

      final cluster = MapCluster.fromMarkers(
        id: 'bounds-cluster',
        markers: markers,
      );

      final size = cluster.calculateSize(markers);
      expect(size, greaterThan(0));
    });

    test('cluster size is 0 for single marker', () {
      final markers = [
        MapMarker.fromLatLng(
          id: 'single',
          latitude: 37.7749,
          longitude: -122.4194,
          title: 'Single',
        ),
      ];

      final cluster = MapCluster.fromMarkers(
        id: 'single',
        markers: markers,
      );

      expect(cluster.calculateSize(markers), 0);
    });
  });

  group('Cluster Weighted Center', () {
    test('uses weighted center when enabled', () {
      final markers = [
        MapMarker.fromLatLng(
          id: 'trip1',
          latitude: 37.7749,
          longitude: -122.4194,
          title: 'Trip',
          type: MarkerType.trip,
        ),
        MapMarker.fromLatLng(
          id: 'photo1',
          latitude: 37.7849,
          longitude: -122.4094,
          title: 'Photo',
          type: MarkerType.photo,
        ),
      ];

      final cluster = MapCluster.fromMarkers(
        id: 'weighted-cluster',
        markers: markers,
        useWeightedCenter: true,
      );

      expect(cluster.weightedPosition, isNotNull);
      // Trip (weight 3.0) should pull center closer to its position
      expect(
        cluster.position.latitude,
        lessThan(cluster.position.latitude + 0.01),
      );
    });

    test('no weighted position when not enabled', () {
      final markers = [
        MapMarker.fromLatLng(
          id: 'm1',
          latitude: 37.7749,
          longitude: -122.4194,
          title: 'M1',
        ),
        MapMarker.fromLatLng(
          id: 'm2',
          latitude: 37.7849,
          longitude: -122.4094,
          title: 'M2',
        ),
      ];

      final cluster = MapCluster.fromMarkers(
        id: 'unweighted',
        markers: markers,
      );

      expect(cluster.weightedPosition, isNull);
    });
  });

  group('Cluster Equality', () {
    test('clusters with same properties are equal', () {
      final markers = [
        MapMarker.fromLatLng(
          id: 'm1',
          latitude: 37.7749,
          longitude: -122.4194,
        ),
      ];

      final cluster1 = MapCluster.fromMarkers(id: 'c1', markers: markers);
      final cluster2 = MapCluster.fromMarkers(id: 'c1', markers: markers);

      expect(cluster1, equals(cluster2));
    });

    test('clusters with different ids are not equal', () {
      final markers = [
        MapMarker.fromLatLng(
          id: 'm1',
          latitude: 37.7749,
          longitude: -122.4194,
        ),
      ];

      final cluster1 = MapCluster.fromMarkers(id: 'c1', markers: markers);
      final cluster2 = MapCluster.fromMarkers(id: 'c2', markers: markers);

      expect(cluster1, isNot(equals(cluster2)));
    });
  });

  group('MapMarker fromLatLng', () {
    test('creates marker with all properties', () {
      final marker = MapMarker.fromLatLng(
        id: 'test',
        latitude: 37.7749,
        longitude: -122.4194,
        title: 'Test Marker',
        description: 'A test',
        type: MarkerType.trip,
      );

      expect(marker.id, 'test');
      expect(marker.position, equals(const LatLng(37.7749, -122.4194)));
      expect(marker.title, 'Test Marker');
      expect(marker.description, 'A test');
      expect(marker.type, MarkerType.trip);
    });
  });
}
