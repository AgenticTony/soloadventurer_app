import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:soloadventurer/features/destination_discovery/application/providers/saved_destinations_provider.dart';
import 'package:soloadventurer/features/destination_discovery/domain/models/saved_destination.dart';
import 'package:soloadventurer/features/destination_discovery/domain/models/destination.dart';
import 'package:soloadventurer/features/destination_discovery/domain/repositories/destination_repository.dart';

// Mock classes
class MockDestinationRepository extends Mock implements DestinationRepository {}

void main() {
  late MockDestinationRepository mockRepository;
  late SavedDestinationsNotifier notifier;
  const testUserId = 'user123';

  // Test data
  final testDestination = Destination(
    id: 'dest1',
    name: 'Tokyo',
    description: 'Amazing city',
    location: (lat: 35.6762, lng: 139.6503),
    safetyScore: 8.5,
    soloSuitabilityScore: 8.0,
    soloSuitabilityFactors: const SoloSuitabilityFactors(
      safety: 8.5,
      nightlife: 7.0,
      walkability: 9.0,
      accommodation: 8.0,
      soloDining: 7.5,
      communication: 6.5,
      overall: 7.8,
    ),
    countryCode: 'JP',
    region: 'Kanto',
    budgetLevel: BudgetLevel.moderate,
    activityLevel: ActivityLevel.moderate,
    tags: ['urban', 'cultural'],
    images: ['https://example.com/tokyo.jpg'],
    popularActivities: [],
    bestTimeToVisit: 'Spring',
  );

  final testSavedDestinations = [
    SavedDestination(
      id: 'saved1',
      userId: testUserId,
      destination: Destination(
        id: 'dest1',
        name: 'Tokyo',
        description: 'Amazing city',
        location: (lat: 35.6762, lng: 139.6503),
        safetyScore: 8.5,
        soloSuitabilityScore: 8.0,
        soloSuitabilityFactors: const SoloSuitabilityFactors(
          safety: 8.5,
          nightlife: 7.0,
          walkability: 9.0,
          accommodation: 8.0,
          soloDining: 7.5,
          communication: 6.5,
          overall: 7.8,
        ),
        countryCode: 'JP',
        region: 'Kanto',
        budgetLevel: BudgetLevel.moderate,
        activityLevel: ActivityLevel.moderate,
        tags: ['urban', 'cultural'],
        images: ['https://example.com/tokyo.jpg'],
        popularActivities: [],
        bestTimeToVisit: 'Spring',
      ),
      saveType: SaveType.wishlist,
      notes: 'Must visit',
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      updatedAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
    SavedDestination(
      id: 'saved2',
      userId: testUserId,
      destination: Destination(
        id: 'dest2',
        name: 'Kyoto',
        description: 'Historic city',
        location: (lat: 35.0116, lng: 135.7681),
        safetyScore: 9.0,
        soloSuitabilityScore: 8.5,
        soloSuitabilityFactors: const SoloSuitabilityFactors(
          safety: 9.0,
          nightlife: 6.0,
          walkability: 8.5,
          accommodation: 8.5,
          soloDining: 8.0,
          communication: 6.0,
          overall: 7.7,
        ),
        countryCode: 'JP',
        region: 'Kansai',
        budgetLevel: BudgetLevel.moderate,
        activityLevel: ActivityLevel.relaxed,
        tags: ['cultural', 'historical'],
        images: ['https://example.com/kyoto.jpg'],
        popularActivities: [],
        bestTimeToVisit: 'Spring',
      ),
      saveType: SaveType.trip,
      tripId: 'trip1',
      notes: 'Temple visit',
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
      updatedAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
    SavedDestination(
      id: 'saved3',
      userId: testUserId,
      destination: Destination(
        id: 'dest3',
        name: 'Osaka',
        description: 'Food capital',
        location: (lat: 34.6937, lng: 135.5023),
        safetyScore: 8.0,
        soloSuitabilityScore: 7.5,
        soloSuitabilityFactors: const SoloSuitabilityFactors(
          safety: 8.0,
          nightlife: 8.0,
          walkability: 7.5,
          accommodation: 7.5,
          soloDining: 8.5,
          communication: 6.5,
          overall: 7.7,
        ),
        countryCode: 'JP',
        region: 'Kansai',
        budgetLevel: BudgetLevel.budget,
        activityLevel: ActivityLevel.moderate,
        tags: ['food', 'urban'],
        images: ['https://example.com/osaka.jpg'],
        popularActivities: [],
        bestTimeToVisit: 'Fall',
      ),
      saveType: SaveType.trip,
      tripId: 'trip1',
      notes: null,
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
      updatedAt: DateTime.now().subtract(const Duration(days: 3)),
    ),
  ];

  setUp(() {
    mockRepository = MockDestinationRepository();
    // Setup mock to return test saved destinations
    when(() => mockRepository.getSavedDestinations(any()))
        .thenAnswer((_) async => testSavedDestinations);
    notifier = SavedDestinationsNotifier(mockRepository, testUserId);

    // Wait for auto-load
    Future.delayed(const Duration(milliseconds: 100));
  });

  group('SavedDestinationsNotifier', () {
    group('initial state', () {
      test('should start with initial state', () {
        notifier.clear();

        expect(notifier.state.value, isNotNull);
        expect(notifier.state.value!.savedDestinations.isEmpty, isTrue);
      });

      test('should auto-load saved destinations on creation', () async {
        // Create a new notifier to verify auto-load
        final newNotifier =
            SavedDestinationsNotifier(mockRepository, testUserId);

        // Wait for auto-load
        await Future.delayed(const Duration(milliseconds: 100));

        verify(() => mockRepository.getSavedDestinations(testUserId)).called(1);
      });
    });

    group('loadSavedDestinations', () {
      test('should load all saved destinations successfully', () async {
        notifier.clear(); // Clear auto-loaded state

        await notifier.loadSavedDestinations();

        verify(() =>
                mockRepository.getSavedDestinations(testUserId, saveType: null))
            .called(1);
        expect(notifier.state.value, isNotNull);
        expect(notifier.state.value!.count, 3);
      });

      test('should load wishlist items only', () async {
        notifier.clear();

        final wishlistOnly = testSavedDestinations
            .where((sd) => sd.saveType == SaveType.wishlist)
            .toList();
        when(() => mockRepository.getSavedDestinations(testUserId,
            saveType: SaveType.wishlist)).thenAnswer((_) async => wishlistOnly);

        await notifier.loadSavedDestinations(saveType: SaveType.wishlist);

        expect(notifier.state.value!.count, 1);
        expect(notifier.state.value!.wishlistCount, 1);
        expect(notifier.state.value!.tripCount, 0);
      });

      test('should handle errors', () async {
        notifier.clear();
        when(() => mockRepository.getSavedDestinations(any(),
                saveType: any(named: 'saveType')))
            .thenThrow(Exception('Network error'));

        await notifier.loadSavedDestinations();

        expect(notifier.state.hasValue, isFalse);
      });
    });

    group('refresh', () {
      test('should refresh saved destinations', () async {
        // Wait for initial load
        await Future.delayed(const Duration(milliseconds: 100));

        // Reset mock
        reset(mockRepository);
        final refreshedDestinations = [testSavedDestinations[0]];
        when(() => mockRepository.getSavedDestinations(any(),
                saveType: any(named: 'saveType')))
            .thenAnswer((_) async => refreshedDestinations);

        await notifier.refresh();

        expect(notifier.state.value!.count, 1);
      });

      test('should handle errors during refresh', () async {
        notifier.clear();
        await notifier.loadSavedDestinations();

        reset(mockRepository);
        when(() => mockRepository.getSavedDestinations(any(),
                saveType: any(named: 'saveType')))
            .thenThrow(Exception('Network error'));

        await notifier.refresh();

        expect(notifier.state.hasValue, isFalse);
      });
    });

    group('saveDestination', () {
      test('should save destination to wishlist', () async {
        notifier.clear();
        await notifier.loadSavedDestinations();

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

        await notifier.saveDestination(
          userId: testUserId,
          destination: testDestination,
          saveType: SaveType.wishlist,
        );

        expect(notifier.state.value!.count, 4); // 3 initial + 1 new
        expect(notifier.state.value!.savedDestinations.last.id, 'saved4');
      });

      test('should save destination to trip', () async {
        notifier.clear();
        await notifier.loadSavedDestinations();

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

        await notifier.saveDestination(
          userId: testUserId,
          destination: testDestination,
          saveType: SaveType.trip,
          tripId: 'trip2',
          notes: 'Test notes',
        );

        expect(notifier.state.value!.count, 4);
        expect(notifier.state.value!.savedDestinations.last.tripId, 'trip2');
      });

      test('should handle errors during save', () async {
        notifier.clear();
        await notifier.loadSavedDestinations();

        when(() => mockRepository.saveDestination(any()))
            .thenThrow(Exception('Network error'));

        expect(
          () async => await notifier.saveDestination(
            userId: testUserId,
            destination: testDestination,
            saveType: SaveType.wishlist,
          ),
          throwsException,
        );
      });
    });

    group('unsaveDestination', () {
      test('should remove destination from all saves when saveType is null',
          () async {
        notifier.clear();
        await notifier.loadSavedDestinations();

        // Mock unsave
        when(() => mockRepository.unsaveDestination(
              destinationId: any(named: 'destinationId'),
              userId: any(named: 'userId'),
              saveType: any(named: 'saveType'),
            )).thenAnswer((_) async => {});

        await notifier.unsaveDestination(
          userId: testUserId,
          destinationId: 'dest1',
        );

        expect(
            notifier.state.value!.savedDestinations
                .any((sd) => sd.destination.id == 'dest1'),
            isFalse);
        verify(() => mockRepository.unsaveDestination(
              destinationId: 'dest1',
              userId: testUserId,
              saveType: null,
            )).called(1);
      });

      test('should remove destination from wishlist only', () async {
        notifier.clear();
        await notifier.loadSavedDestinations();

        when(() => mockRepository.unsaveDestination(
              destinationId: any(named: 'destinationId'),
              userId: any(named: 'userId'),
              saveType: any(named: 'saveType'),
            )).thenAnswer((_) async => {});

        await notifier.unsaveDestination(
          userId: testUserId,
          destinationId: 'dest1',
          saveType: SaveType.wishlist,
        );

        expect(notifier.state.value!.wishlistCount, 0);
        verify(() => mockRepository.unsaveDestination(
              destinationId: 'dest1',
              userId: testUserId,
              saveType: SaveType.wishlist,
            )).called(1);
      });

      test('should handle errors during unsave', () async {
        notifier.clear();
        await notifier.loadSavedDestinations();

        when(() => mockRepository.unsaveDestination(
              destinationId: any(named: 'destinationId'),
              userId: any(named: 'userId'),
              saveType: any(named: 'saveType'),
            )).thenThrow(Exception('Network error'));

        expect(
          () async => await notifier.unsaveDestination(
            userId: testUserId,
            destinationId: 'dest1',
          ),
          throwsException,
        );
      });
    });

    group('updateNotes', () {
      test('should update notes for saved destination', () async {
        notifier.clear();
        await notifier.loadSavedDestinations();

        when(() => mockRepository.saveDestination(any()))
            .thenAnswer((_) async => testSavedDestinations[0]);

        await notifier.updateNotes('dest1', 'Updated notes');

        final updated = notifier.state.value!.getSavedDestination('dest1');
        expect(updated?.notes, 'Updated notes');
      });

      test('should throw error when destination not found', () async {
        notifier.clear();
        await notifier.loadSavedDestinations();

        expect(
          () async => await notifier.updateNotes('nonexistent', 'Notes'),
          throwsException,
        );
      });

      test('should handle errors during update', () async {
        notifier.clear();
        await notifier.loadSavedDestinations();

        when(() => mockRepository.saveDestination(any()))
            .thenThrow(Exception('Network error'));

        expect(
          () async => await notifier.updateNotes('dest1', 'Notes'),
          throwsException,
        );
      });
    });

    group('clear', () {
      test('should reset state to initial', () async {
        await notifier.loadSavedDestinations();

        notifier.clear();

        expect(notifier.state.value!.savedDestinations.isEmpty, isTrue);
      });
    });

    group('checker methods', () {
      test('isDestinationSaved should return true for saved destination',
          () async {
        notifier.clear();
        await notifier.loadSavedDestinations();

        expect(notifier.isDestinationSaved('dest1'), isTrue);
        expect(notifier.isDestinationSaved('dest99'), isFalse);
      });

      test('isDestinationInWishlist should check wishlist', () async {
        notifier.clear();
        await notifier.loadSavedDestinations();

        expect(notifier.isDestinationInWishlist('dest1'), isTrue);
        expect(notifier.isDestinationInWishlist('dest2'), isFalse);
      });

      test('isDestinationInTrip should check trip saves', () async {
        notifier.clear();
        await notifier.loadSavedDestinations();

        expect(notifier.isDestinationInTrip('dest2'), isTrue);
        expect(notifier.isDestinationInTrip('dest1'), isFalse);
      });

      test('should return false when state has no value', () async {
        notifier.clear();

        expect(notifier.isDestinationSaved('dest1'), isFalse);
        expect(notifier.isDestinationInWishlist('dest1'), isFalse);
        expect(notifier.isDestinationInTrip('dest1'), isFalse);
      });
    });

    group('getters', () {
      test('getSavedDestination should return saved destination', () async {
        notifier.clear();
        await notifier.loadSavedDestinations();

        final saved = notifier.getSavedDestination('dest1');
        expect(saved?.id, 'saved1');
      });

      test('wishlistItems should return wishlist items', () async {
        notifier.clear();
        await notifier.loadSavedDestinations();

        expect(notifier.wishlistItems.length, 1);
        expect(notifier.wishlistItems[0].destination.id, 'dest1');
      });

      test('tripItems should return trip items', () async {
        notifier.clear();
        await notifier.loadSavedDestinations();

        expect(notifier.tripItems.length, 2);
        expect(notifier.tripItems.every((sd) => sd.saveType == SaveType.trip),
            isTrue);
      });

      test('totalCount should return total count', () async {
        notifier.clear();
        await notifier.loadSavedDestinations();

        expect(notifier.totalCount, 3);
      });

      test('wishlistCount should return wishlist count', () async {
        notifier.clear();
        await notifier.loadSavedDestinations();

        expect(notifier.wishlistCount, 1);
      });

      test('tripCount should return trip count', () async {
        notifier.clear();
        await notifier.loadSavedDestinations();

        expect(notifier.tripCount, 2);
      });

      test('groupedByTrip should group by trip ID', () async {
        notifier.clear();
        await notifier.loadSavedDestinations();

        final grouped = notifier.groupedByTrip;

        expect(grouped.length, 1); // Only one trip
        expect(grouped['trip1']?.length, 2);
      });

      test('isEmpty should return true when empty', () async {
        notifier.clear();

        expect(notifier.isEmpty, isTrue);
      });

      test('isNotEmpty should return true when has items', () async {
        notifier.clear();
        await notifier.loadSavedDestinations();

        expect(notifier.isNotEmpty, isTrue);
      });

      test('getters should return empty/null when state has no value',
          () async {
        notifier.clear();

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
