import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soloadventurer/features/destination_discovery/application/providers/saved_destinations_provider.dart';
import 'package:soloadventurer/features/destination_discovery/application/providers/destination_repository_provider.dart';
import 'package:soloadventurer/features/destination_discovery/domain/models/saved_destination.dart';
import 'package:soloadventurer/features/destination_discovery/domain/models/destination.dart';
import 'package:soloadventurer/features/destination_discovery/domain/repositories/destination_repository.dart';

// Mock classes
class MockDestinationRepository extends Mock implements DestinationRepository {}

void main() {
  late MockDestinationRepository mockRepository;
  late ProviderContainer container;
  const testUserId = 'user123';

  // Helper to create test destinations
  Destination createTestDestination({
    String id = 'dest1',
    String name = 'Tokyo',
    double lat = 35.6762,
    double lng = 139.6503,
    double safetyScore = 8.5,
    double soloScore = 8.0,
    BudgetLevel budget = BudgetLevel.moderate,
    List<ActivityLevel> activities = const [ActivityLevel.moderate],
    List<String> tags = const ['urban', 'cultural'],
  }) {
    return Destination(
      id: id,
      name: name,
      description: 'Amazing city',
      latitude: lat,
      longitude: lng,
      safetyScore: safetyScore,
      safetyInsights: [],
      soloSuitabilityScore: soloScore,
      soloSuitabilityFactors: SoloSuitabilityFactors(
        safety: safetyScore,
        nightlife: 7.0,
        walkability: 9.0,
        accommodation: 8.0,
        soloDining: 7.5,
        communication: 6.5,
        overall: 7.8,
      ),
      countryCode: 'JP',
      region: 'Kanto',
      budgetLevel: budget,
      activityLevels: activities,
      tags: tags,
      images: ['https://example.com/$name.jpg'],
      popularActivities: [],
      createdAt: DateTime(2024, 1, 1),
      updatedAt: DateTime(2024, 1, 1),
    );
  }

  List<SavedDestination> createTestSavedDestinations() {
    final now = DateTime.now();
    return [
      SavedDestination(
        id: 'saved1',
        userId: testUserId,
        destination: createTestDestination(id: 'dest1', name: 'Tokyo'),
        saveType: SaveType.wishlist,
        notes: 'Must visit',
        createdAt: now.subtract(const Duration(days: 1)),
        updatedAt: now.subtract(const Duration(days: 1)),
      ),
      SavedDestination(
        id: 'saved2',
        userId: testUserId,
        destination: createTestDestination(
          id: 'dest2',
          name: 'Kyoto',
          lat: 35.0116,
          lng: 135.7681,
          activities: [ActivityLevel.relaxed],
          tags: ['cultural', 'historical'],
        ),
        saveType: SaveType.trip,
        tripId: 'trip1',
        notes: 'Temple visit',
        createdAt: now.subtract(const Duration(days: 2)),
        updatedAt: now.subtract(const Duration(days: 2)),
      ),
      SavedDestination(
        id: 'saved3',
        userId: testUserId,
        destination: createTestDestination(
          id: 'dest3',
          name: 'Osaka',
          lat: 34.6937,
          lng: 135.5023,
          safetyScore: 8.0,
          soloScore: 7.5,
          budget: BudgetLevel.budget,
          tags: ['food', 'urban'],
        ),
        saveType: SaveType.trip,
        tripId: 'trip1',
        notes: null,
        createdAt: now.subtract(const Duration(days: 3)),
        updatedAt: now.subtract(const Duration(days: 3)),
      ),
    ];
  }

  setUpAll(() {
    registerFallbackValue(SavedDestination(
      id: 'fallback',
      userId: 'fallback-user',
      destination: createTestDestination(),
      saveType: SaveType.wishlist,
      createdAt: DateTime(2024, 1, 1),
      updatedAt: DateTime(2024, 1, 1),
    ));
  });

  setUp(() {
    mockRepository = MockDestinationRepository();
    when(() => mockRepository.getSavedDestinations(any()))
        .thenAnswer((_) async => createTestSavedDestinations());

    container = ProviderContainer.test(
      overrides: [
        destinationRepositoryProvider.overrideWith((ref) => mockRepository),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  group('savedDestinationsProvider', () {
    group('initial state', () {
      test('should auto-load saved destinations on build', () async {
        await container.read(savedDestinationsProvider(testUserId).future);

        verify(() => mockRepository.getSavedDestinations(testUserId)).called(1);
      });
    });

    group('loadSavedDestinations via refresh', () {
      test('should load all saved destinations successfully', () async {
        final state = await container.read(savedDestinationsProvider(testUserId).future);

        verify(() => mockRepository.getSavedDestinations(testUserId)).called(1);
        expect(state.savedDestinations.length, 3);
      });

      test('should handle errors', () async {
        when(() => mockRepository.getSavedDestinations(any()))
            .thenThrow(Exception('Network error'));

        final errorContainer = ProviderContainer(
          overrides: [
            destinationRepositoryProvider.overrideWith((ref) => mockRepository),
          ],
        );

        bool gotError = false;
        final sub = errorContainer.listen(
          savedDestinationsProvider(testUserId),
          (_, next) {
            if (next.hasError) gotError = true;
          },
          fireImmediately: true,
          onError: (error, stackTrace) {
            gotError = true;
          },
        );

        await Future.delayed(const Duration(milliseconds: 100));

        expect(gotError, isTrue);

        sub.close();
        errorContainer.dispose();
      });
    });

    group('refresh', () {
      test('should refresh saved destinations', () async {
        await container.read(savedDestinationsProvider(testUserId).future);

        reset(mockRepository);
        final refreshedDestinations = [createTestSavedDestinations()[0]];
        when(() => mockRepository.getSavedDestinations(any(), saveType: any(named: 'saveType')))
            .thenAnswer((_) async => refreshedDestinations);

        await container
            .read(savedDestinationsProvider(testUserId).notifier)
            .refresh();

        final state = container.read(savedDestinationsProvider(testUserId));
        expect(state.value, isNotNull);
        expect(state.value!.savedDestinations.length, 1);
      });
    });

    group('saveDestination', () {
      test('should save destination to wishlist', () async {
        await container.read(savedDestinationsProvider(testUserId).future);

        final testDestination = createTestDestination();
        final newSaved = SavedDestination(
          id: 'saved4',
          userId: testUserId,
          destination: testDestination,
          saveType: SaveType.wishlist,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        when(() => mockRepository.saveDestination(any()))
            .thenAnswer((_) async => newSaved);

        await container
            .read(savedDestinationsProvider(testUserId).notifier)
            .saveDestination(
              userId: testUserId,
              destination: testDestination,
              saveType: SaveType.wishlist,
            );

        final state = container.read(savedDestinationsProvider(testUserId));
        expect(state.value!.savedDestinations.length, 4);
        expect(state.value!.savedDestinations.last.id, 'saved4');
      });

      test('should save destination to trip', () async {
        await container.read(savedDestinationsProvider(testUserId).future);

        final testDestination = createTestDestination();
        final newSaved = SavedDestination(
          id: 'saved4',
          userId: testUserId,
          destination: testDestination,
          saveType: SaveType.trip,
          tripId: 'trip2',
          notes: 'Test notes',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        when(() => mockRepository.saveDestination(any()))
            .thenAnswer((_) async => newSaved);

        await container
            .read(savedDestinationsProvider(testUserId).notifier)
            .saveDestination(
              userId: testUserId,
              destination: testDestination,
              saveType: SaveType.trip,
              tripId: 'trip2',
              notes: 'Test notes',
            );

        final state = container.read(savedDestinationsProvider(testUserId));
        expect(state.value!.savedDestinations.length, 4);
        expect(state.value!.savedDestinations.last.tripId, 'trip2');
      });

      test('should handle errors during save', () async {
        await container.read(savedDestinationsProvider(testUserId).future);

        when(() => mockRepository.saveDestination(any()))
            .thenThrow(Exception('Network error'));

        expect(
          () => container
              .read(savedDestinationsProvider(testUserId).notifier)
              .saveDestination(
                userId: testUserId,
                destination: createTestDestination(),
                saveType: SaveType.wishlist,
              ),
          throwsException,
        );
      });
    });

    group('unsaveDestination', () {
      test('should remove destination from all saves when saveType is null',
          () async {
        await container.read(savedDestinationsProvider(testUserId).future);

        when(() => mockRepository.unsaveDestination(
              destinationId: any(named: 'destinationId'),
              userId: any(named: 'userId'),
              saveType: any(named: 'saveType'),
            )).thenAnswer((_) async => {});

        await container
            .read(savedDestinationsProvider(testUserId).notifier)
            .unsaveDestination(
              userId: testUserId,
              destinationId: 'dest1',
            );

        final state = container.read(savedDestinationsProvider(testUserId));
        expect(
            state.value!.savedDestinations
                .any((sd) => sd.destination.id == 'dest1'),
            isFalse);
        verify(() => mockRepository.unsaveDestination(
              destinationId: 'dest1',
              userId: testUserId,
              saveType: null,
            )).called(1);
      });

      test('should remove destination from wishlist only', () async {
        await container.read(savedDestinationsProvider(testUserId).future);

        when(() => mockRepository.unsaveDestination(
              destinationId: any(named: 'destinationId'),
              userId: any(named: 'userId'),
              saveType: any(named: 'saveType'),
            )).thenAnswer((_) async => {});

        await container
            .read(savedDestinationsProvider(testUserId).notifier)
            .unsaveDestination(
              userId: testUserId,
              destinationId: 'dest1',
              saveType: SaveType.wishlist,
            );

        final state = container.read(savedDestinationsProvider(testUserId));
        expect(state.value!.wishlistCount, 0);
        verify(() => mockRepository.unsaveDestination(
              destinationId: 'dest1',
              userId: testUserId,
              saveType: SaveType.wishlist,
            )).called(1);
      });

      test('should handle errors during unsave', () async {
        await container.read(savedDestinationsProvider(testUserId).future);

        when(() => mockRepository.unsaveDestination(
              destinationId: any(named: 'destinationId'),
              userId: any(named: 'userId'),
              saveType: any(named: 'saveType'),
            )).thenThrow(Exception('Network error'));

        expect(
          () => container
              .read(savedDestinationsProvider(testUserId).notifier)
              .unsaveDestination(
                userId: testUserId,
                destinationId: 'dest1',
              ),
          throwsException,
        );
      });
    });

    group('updateNotes', () {
      test('should update notes for saved destination', () async {
        await container.read(savedDestinationsProvider(testUserId).future);

        when(() => mockRepository.saveDestination(any()))
            .thenAnswer((_) async => createTestSavedDestinations()[0]);

        await container
            .read(savedDestinationsProvider(testUserId).notifier)
            .updateNotes('dest1', 'Updated notes');

        final state = container.read(savedDestinationsProvider(testUserId));
        final updated = state.value!.getSavedDestination('dest1');
        expect(updated?.notes, 'Updated notes');
      });

      test('should throw error when destination not found', () async {
        await container.read(savedDestinationsProvider(testUserId).future);

        expect(
          () => container
              .read(savedDestinationsProvider(testUserId).notifier)
              .updateNotes('nonexistent', 'Notes'),
          throwsException,
        );
      });
    });

    group('clear', () {
      test('should reset state to initial', () async {
        await container.read(savedDestinationsProvider(testUserId).future);

        container
            .read(savedDestinationsProvider(testUserId).notifier)
            .clear();

        final state = container.read(savedDestinationsProvider(testUserId));
        expect(state.value!.savedDestinations.isEmpty, isTrue);
      });
    });

    group('checker methods', () {
      test('isDestinationSaved should return true for saved destination',
          () async {
        await container.read(savedDestinationsProvider(testUserId).future);

        final notifier = container
            .read(savedDestinationsProvider(testUserId).notifier);
        expect(notifier.isDestinationSaved('dest1'), isTrue);
        expect(notifier.isDestinationSaved('dest99'), isFalse);
      });

      test('isDestinationInWishlist should check wishlist', () async {
        await container.read(savedDestinationsProvider(testUserId).future);

        final notifier = container
            .read(savedDestinationsProvider(testUserId).notifier);
        expect(notifier.isDestinationInWishlist('dest1'), isTrue);
        expect(notifier.isDestinationInWishlist('dest2'), isFalse);
      });

      test('isDestinationInTrip should check trip saves', () async {
        await container.read(savedDestinationsProvider(testUserId).future);

        final notifier = container
            .read(savedDestinationsProvider(testUserId).notifier);
        expect(notifier.isDestinationInTrip('dest2'), isTrue);
        expect(notifier.isDestinationInTrip('dest1'), isFalse);
      });

      test('should return false when state has no value', () async {
        // Wait for auto-load then clear
        await container.read(savedDestinationsProvider(testUserId).future);
        container
            .read(savedDestinationsProvider(testUserId).notifier)
            .clear();

        final notifier = container
            .read(savedDestinationsProvider(testUserId).notifier);
        expect(notifier.isDestinationSaved('dest1'), isFalse);
        expect(notifier.isDestinationInWishlist('dest1'), isFalse);
        expect(notifier.isDestinationInTrip('dest1'), isFalse);
      });
    });

    group('getters', () {
      test('getSavedDestination should return saved destination', () async {
        await container.read(savedDestinationsProvider(testUserId).future);

        final notifier = container
            .read(savedDestinationsProvider(testUserId).notifier);
        final saved = notifier.getSavedDestination('dest1');
        expect(saved?.id, 'saved1');
      });

      test('wishlistItems should return wishlist items', () async {
        await container.read(savedDestinationsProvider(testUserId).future);

        final notifier = container
            .read(savedDestinationsProvider(testUserId).notifier);
        expect(notifier.wishlistItems.length, 1);
        expect(notifier.wishlistItems[0].destination.id, 'dest1');
      });

      test('tripItems should return trip items', () async {
        await container.read(savedDestinationsProvider(testUserId).future);

        final notifier = container
            .read(savedDestinationsProvider(testUserId).notifier);
        expect(notifier.tripItems.length, 2);
        expect(notifier.tripItems.every((sd) => sd.saveType == SaveType.trip),
            isTrue);
      });

      test('totalCount should return total count', () async {
        await container.read(savedDestinationsProvider(testUserId).future);

        final notifier = container
            .read(savedDestinationsProvider(testUserId).notifier);
        expect(notifier.totalCount, 3);
      });

      test('wishlistCount should return wishlist count', () async {
        await container.read(savedDestinationsProvider(testUserId).future);

        final notifier = container
            .read(savedDestinationsProvider(testUserId).notifier);
        expect(notifier.wishlistCount, 1);
      });

      test('tripCount should return trip count', () async {
        await container.read(savedDestinationsProvider(testUserId).future);

        final notifier = container
            .read(savedDestinationsProvider(testUserId).notifier);
        expect(notifier.tripCount, 2);
      });

      test('groupedByTrip should group by trip ID', () async {
        await container.read(savedDestinationsProvider(testUserId).future);

        final notifier = container
            .read(savedDestinationsProvider(testUserId).notifier);
        final grouped = notifier.groupedByTrip;

        expect(grouped.length, 1); // Only one trip
        expect(grouped['trip1']?.length, 2);
      });

      test('isEmpty should return true when empty', () async {
        await container.read(savedDestinationsProvider(testUserId).future);
        container
            .read(savedDestinationsProvider(testUserId).notifier)
            .clear();

        final notifier = container
            .read(savedDestinationsProvider(testUserId).notifier);
        expect(notifier.isEmpty, isTrue);
      });

      test('isNotEmpty should return true when has items', () async {
        await container.read(savedDestinationsProvider(testUserId).future);

        final notifier = container
            .read(savedDestinationsProvider(testUserId).notifier);
        expect(notifier.isNotEmpty, isTrue);
      });

      test('getters should return empty/null when state has no value',
          () async {
        await container.read(savedDestinationsProvider(testUserId).future);
        container
            .read(savedDestinationsProvider(testUserId).notifier)
            .clear();

        final notifier = container
            .read(savedDestinationsProvider(testUserId).notifier);
        expect(notifier.getSavedDestination('dest1'), isNull);
        expect(notifier.wishlistItems.isEmpty, isTrue);
        expect(notifier.tripItems.isEmpty, isTrue);
        expect(notifier.totalCount, 0);
        expect(notifier.wishlistCount, 0);
        expect(notifier.tripCount, 0);
        expect(notifier.groupedByTrip.isEmpty, isTrue);
        expect(notifier.isEmpty, isTrue);
        expect(notifier.isNotEmpty, isFalse);
      });
    });
  });
}
