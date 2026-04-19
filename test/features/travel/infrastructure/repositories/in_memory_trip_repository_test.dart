import 'package:flutter_test/flutter_test.dart';
import 'package:soloadventurer/core/repositories/paginated_repository_mixin.dart';
import 'package:soloadventurer/features/travel/domain/models/trip.dart';
import 'package:soloadventurer/features/travel/domain/repositories/trip_repository.dart';
import 'package:soloadventurer/features/travel/infrastructure/repositories/in_memory_trip_repository.dart';

void main() {
  group('InMemoryTripRepository', () {
    late InMemoryTripRepository repository;
    late String testUserId;
    late List<Trip> testTrips;

    setUp(() {
      repository = InMemoryTripRepository();
      testUserId = 'test-user-123';

      // Create test trips
      testTrips = List.generate(
        50,
        (index) => Trip(
          id: 'trip-$index',
          userId: testUserId,
          title: 'Trip $index',
          description: 'Description for trip $index',
          startDate: DateTime(2024, 1, 1).add(Duration(days: index)),
          endDate: DateTime(2024, 1, 5).add(Duration(days: index)),
          destination: 'Destination $index',
          status: index % 2 == 0 ? 'active' : 'completed',
          budget: 1000 + (index * 100),
          createdAt: DateTime(2024, 1, 1).add(Duration(days: index)),
          updatedAt: DateTime(2024, 1, 1).add(Duration(days: index)),
        ),
      );

      // Insert test trips
      for (final trip in testTrips) {
        repository.createTrip(trip: trip);
      }
    });

    group('Cursor-based pagination', () {
      test('getTripsCursor returns first page correctly', () async {
        final result = await repository.getTripsCursor(
          userId: testUserId,
          pageSize: 20,
        );

        expect(result.items.length, equals(20));
        expect(result.pageInfo.currentPage, equals(1));
        expect(result.pageInfo.itemsPerPage, equals(20));
        expect(result.pageInfo.hasNextPage, isTrue);
        expect(result.pageInfo.hasPreviousPage, isFalse);
        expect(result.pageInfo.nextCursor, isNotNull);
      });

      test('getTripsCursor returns second page using cursor', () async {
        final firstPage = await repository.getTripsCursor(
          userId: testUserId,
          pageSize: 20,
        );

        final secondPage = await repository.getTripsCursor(
          userId: testUserId,
          cursor: firstPage.pageInfo.nextCursor,
          pageSize: 20,
        );

        expect(secondPage.items.length, equals(20));
        expect(secondPage.pageInfo.hasNextPage, isTrue);
        expect(secondPage.pageInfo.hasPreviousPage, isTrue);
        expect(secondPage.items.first.id, isNot(firstPage.items.first.id));
      });

      test('getTripsCursor returns empty page when past end', () async {
        // Page 3 with pageSize 20 should have only 10 items (50 total)
        final page1 = await repository.getTripsCursor(
          userId: testUserId,
          pageSize: 20,
        );
        final page2 = await repository.getTripsCursor(
          userId: testUserId,
          cursor: page1.pageInfo.nextCursor,
          pageSize: 20,
        );
        final page3 = await repository.getTripsCursor(
          userId: testUserId,
          cursor: page2.pageInfo.nextCursor,
          pageSize: 20,
        );

        expect(page3.items.length, equals(10));
        expect(page3.pageInfo.hasNextPage, isFalse);
      });

      test('getTripsCursor filters by status', () async {
        final result = await repository.getTripsCursor(
          userId: testUserId,
          filters: {'status': 'active'},
          pageSize: 20,
        );

        // Should return only active trips (even indices: 0, 2, 4, ...)
        for (final trip in result.items) {
          expect(trip.status, equals('active'));
        }
      });

      test('getTripsCursor filters by destination', () async {
        final result = await repository.getTripsCursor(
          userId: testUserId,
          filters: {'destination': 'Destination 1'},
          pageSize: 20,
        );

        expect(result.items.length, greaterThan(0));
        expect(
          result.items
              .any((trip) => trip.destination.contains('Destination 1')),
          isTrue,
        );
      });

      test('getTripsCursor sorts by title ascending', () async {
        final result = await repository.getTripsCursor(
          userId: testUserId,
          sortBy: 'title',
          sortOrder: SortOrder.ascending,
          pageSize: 10,
        );

        final titles = result.items.map((trip) => trip.title).toList();
        final sortedTitles = List<String>.from(titles)..sort();

        expect(titles, equals(sortedTitles));
      });

      test('getTripsCursor validates page size', () async {
        // Request more than max page size
        final result = await repository.getTripsCursor(
          userId: testUserId,
          pageSize: 200, // Exceeds maxPageSize of 100
        );

        // Should use max page size
        expect(result.pageInfo.itemsPerPage, equals(100));
      });
    });

    group('Offset-based pagination', () {
      test('getTripsOffset returns first page correctly', () async {
        final result = await repository.getTripsOffset(
          userId: testUserId,
          page: 1,
          pageSize: 20,
        );

        expect(result.items.length, equals(20));
        expect(result.pageInfo.currentPage, equals(1));
        expect(result.pageInfo.totalItems, equals(50));
        expect(result.pageInfo.totalPages, equals(3));
        expect(result.pageInfo.hasNextPage, isTrue);
        expect(result.pageInfo.hasPreviousPage, isFalse);
      });

      test('getTripsOffset returns specific page', () async {
        final result = await repository.getTripsOffset(
          userId: testUserId,
          page: 2,
          pageSize: 20,
        );

        expect(result.items.length, equals(20));
        expect(result.pageInfo.currentPage, equals(2));
        expect(result.pageInfo.hasNextPage, isTrue);
        expect(result.pageInfo.hasPreviousPage, isTrue);
      });

      test('getTripsOffset returns last page with remaining items', () async {
        final result = await repository.getTripsOffset(
          userId: testUserId,
          page: 3,
          pageSize: 20,
        );

        expect(result.items.length, equals(10));
        expect(result.pageInfo.hasNextPage, isFalse);
        expect(result.pageInfo.hasPreviousPage, isTrue);
      });

      test('getTripsOffset with invalid page returns empty', () async {
        final result = await repository.getTripsOffset(
          userId: testUserId,
          page: 100,
          pageSize: 20,
        );

        expect(result.items.length, equals(0));
        expect(result.pageInfo.hasNextPage, isFalse);
      });
    });

    group('Metadata queries', () {
      test('getTripsMetadata returns lightweight objects', () async {
        final result = await repository.getTripsMetadata(
          userId: testUserId,
          pageSize: 20,
        );

        expect(result.items.length, equals(20));
        expect(result.items.first, isA<TripMetadata>());
        expect(result.items.first.id, isNotEmpty);
        expect(result.items.first.title, isNotEmpty);
        expect(result.items.first.destination, isNotEmpty);
      });
    });

    group('CRUD operations', () {
      test('createTrip generates ID and timestamps', () async {
        final newTrip = Trip(
          id: '', // Empty ID, should be generated
          userId: testUserId,
          title: 'New Trip',
          startDate: DateTime(2024, 6, 1),
          endDate: DateTime(2024, 6, 5),
          destination: 'New Destination',
          status: 'planning',
          budget: 5000,
          createdAt: DateTime.now(), // Will be overridden
          updatedAt: DateTime.now(), // Will be overridden
        );

        final created = await repository.createTrip(trip: newTrip);

        expect(created.id, startsWith('trip_'));
        expect(created.userId, equals(testUserId));
        expect(created.title, equals('New Trip'));
        expect(created.createdAt, isNotNull);
        expect(created.updatedAt, isNotNull);
      });

      test('getTripById returns correct trip', () async {
        final trip = await repository.getTripById(tripId: 'trip_6');

        expect(trip, isNotNull);
        expect(trip!.id, equals('trip_6'));
        expect(trip.title, equals('Trip 5'));
      });

      test('getTripById returns null for non-existent trip', () async {
        final trip = await repository.getTripById(tripId: 'non-existent');

        expect(trip, isNull);
      });

      test('getTripsByIds returns trips in order', () async {
        final trips = await repository.getTripsByIds(
          tripIds: ['trip_6', 'trip_3', 'trip_9'],
        );

        expect(trips.length, equals(3));
        expect(trips[0].id, equals('trip_6'));
        expect(trips[1].id, equals('trip_3'));
        expect(trips[2].id, equals('trip_9'));
      });

      test('updateTrip updates trip correctly', () async {
        final updates = testTrips[0].copyWith(
          title: 'Updated Title',
          budget: 9999,
        );

        final updated = await repository.updateTrip(
          tripId: 'trip_1',
          updates: updates,
        );

        expect(updated.title, equals('Updated Title'));
        expect(updated.budget, equals(9999));
        expect(updated.updatedAt.isAfter(testTrips[0].updatedAt), isTrue);
      });

      test('deleteTrip removes trip', () async {
        final result = await repository.deleteTrip(tripId: 'trip_1');

        expect(result, isTrue);

        final trip = await repository.getTripById(tripId: 'trip_1');
        expect(trip, isNull);
      });

      test('deleteTrip returns false for non-existent trip', () async {
        final result = await repository.deleteTrip(tripId: 'non-existent');

        expect(result, isFalse);
      });
    });

    group('Search', () {
      test('searchTrips finds trips by title', () async {
        final result = await repository.searchTrips(
          userId: testUserId,
          query: 'Trip 1',
          pageSize: 20,
        );

        expect(result.items.length, greaterThan(0));
        expect(
          result.items.every((trip) => trip.title.contains('Trip 1')),
          isTrue,
        );
      });

      test('searchTrips finds trips by destination', () async {
        final result = await repository.searchTrips(
          userId: testUserId,
          query: 'Destination 2',
          pageSize: 20,
        );

        expect(result.items.length, greaterThan(0));
      });

      test('searchTrips with cursor pagination', () async {
        final page1 = await repository.searchTrips(
          userId: testUserId,
          query: 'Trip',
          pageSize: 10,
        );

        expect(page1.items.length, equals(10));

        if (page1.pageInfo.nextCursor != null) {
          final page2 = await repository.searchTrips(
            userId: testUserId,
            query: 'Trip',
            cursor: page1.pageInfo.nextCursor,
            pageSize: 10,
          );

          expect(page2.items.length, greaterThan(0));
        }
      });
    });

    group('Date range queries', () {
      test('getTripsInDateRange filters correctly', () async {
        final result = await repository.getTripsInDateRange(
          userId: testUserId,
          startDate: DateTime(2024, 1, 5),
          endDate: DateTime(2024, 1, 10),
          pageSize: 20,
        );

        expect(result.items.length, greaterThan(0));
        for (final trip in result.items) {
          expect(
            trip.startDate.isAfter(DateTime(2024, 1, 4)) &&
                trip.startDate.isBefore(DateTime(2024, 1, 11)),
            isTrue,
          );
        }
      });
    });

    group('Count', () {
      test('countTrips returns total count', () async {
        final count = await repository.countTrips(
          userId: testUserId,
        );

        expect(count, equals(50));
      });

      test('countTrips with filters returns filtered count', () async {
        final count = await repository.countTrips(
          userId: testUserId,
          filters: {'status': 'active'},
        );

        // Half of the trips are active (even indices)
        expect(count, equals(25));
      });
    });

    group('Clear', () {
      test('clear removes all trips', () async {
        repository.clear();

        final count = await repository.countTrips(userId: testUserId);
        expect(count, equals(0));
      });
    });
  });
}
