import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:soloadventurer/features/matching/presentation/providers/matching_provider.dart';
import 'package:soloadventurer/features/matching/data/datasources/matching_local_data_source_impl.dart';
import 'package:soloadventurer/features/matching/data/models/trip_model.dart';
import 'package:soloadventurer/features/matching/domain/repositories/matching_repository.dart';
import 'package:soloadventurer/features/journal/presentation/providers/journal_entry_providers.dart';
import 'package:soloadventurer/features/journal/domain/repositories/journal_repository.dart';
import 'package:soloadventurer/app/providers/core_service_providers.dart';

/// Fake MatchingRepository for DI resolution tests
class FakeMatchingRepository implements MatchingRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

/// Fake JournalRepository for DI resolution tests
class FakeJournalRepository implements JournalRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

void main() {
  group('Sprint 1a.1 — MatchingRepository DI Resolution', () {
    test('matchingRepositoryProvider resolves when overridden', () async {
      SharedPreferences.setMockInitialValues({});

      final container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider
              .overrideWithValue(await SharedPreferences.getInstance()),
          matchingRepositoryProvider
              .overrideWithValue(FakeMatchingRepository()),
        ],
      );

      expect(
        () => container.read(matchingRepositoryProvider),
        returnsNormally,
      );

      final repo = container.read(matchingRepositoryProvider);
      expect(repo, isA<MatchingRepository>());

      container.dispose();
    });
  });

  group('Sprint 1a.2 — JournalRepository DI Resolution', () {
    test('journalRepositoryProvider resolves when overridden', () async {
      SharedPreferences.setMockInitialValues({});

      final container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider
              .overrideWithValue(await SharedPreferences.getInstance()),
          journalRepositoryProvider
              .overrideWithValue(FakeJournalRepository()),
        ],
      );

      expect(
        () => container.read(journalRepositoryProvider),
        returnsNormally,
      );

      final repo = container.read(journalRepositoryProvider);
      expect(repo, isA<JournalRepository>());

      container.dispose();
    });
  });

  group('Sprint 1a.1 — MatchingLocalDataSourceImpl', () {
    late MatchingLocalDataSourceImpl localDataSource;

    setUp(() {
      localDataSource = MatchingLocalDataSourceImpl();
    });

    test('getUserTrips returns empty list initially', () async {
      final trips = await localDataSource.getUserTrips();
      expect(trips, isEmpty);
    });

    test('createTrip and getUserTrips work end-to-end', () async {
      final trip = TripModel(
        id: 'trip-1',
        userId: 'user-1',
        destinationName: 'Paris',
        latitude: 48.8566,
        longitude: 2.3522,
        startDate: DateTime(2026, 5, 1),
        endDate: DateTime(2026, 5, 7),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await localDataSource.createTrip(trip);
      final trips = await localDataSource.getUserTrips();

      expect(trips.length, 1);
      expect(trips.first.id, 'trip-1');
      expect(trips.first.destinationName, 'Paris');
    });

    test('getTrip returns null for nonexistent trip', () async {
      final trip = await localDataSource.getTrip('nonexistent');
      expect(trip, isNull);
    });

    test('deleteTrip removes trip from list', () async {
      final trip = TripModel(
        id: 'trip-delete',
        userId: 'user-1',
        destinationName: 'Tokyo',
        latitude: 35.6762,
        longitude: 139.6503,
        startDate: DateTime(2026, 6, 1),
        endDate: DateTime(2026, 6, 7),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await localDataSource.createTrip(trip);
      expect((await localDataSource.getUserTrips()).length, 1);

      await localDataSource.deleteTrip('trip-delete');
      expect((await localDataSource.getUserTrips()), isEmpty);
    });

    test('clearAllData resets everything', () async {
      final trip = TripModel(
        id: 'trip-1',
        userId: 'user-1',
        destinationName: 'Berlin',
        latitude: 52.52,
        longitude: 13.405,
        startDate: DateTime(2026, 7, 1),
        endDate: DateTime(2026, 7, 7),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await localDataSource.createTrip(trip);
      await localDataSource.cacheNearbyTravelersCount(5);

      await localDataSource.clearAllData();

      expect(await localDataSource.getUserTrips(), isEmpty);
      expect(await localDataSource.getNearbyTravelersCount(), isNull);
    });

    test('cacheNearbyTravelersCount and getNearbyTravelersCount', () async {
      await localDataSource.cacheNearbyTravelersCount(42);
      final count = await localDataSource.getNearbyTravelersCount();
      expect(count, 42);
    });

    test('isDatabaseHealthy returns true', () async {
      expect(await localDataSource.isDatabaseHealthy(), isTrue);
    });
  });
}
