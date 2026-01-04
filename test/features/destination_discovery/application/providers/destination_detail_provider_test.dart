import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:solo_adventurer/features/destination_discovery/application/providers/destination_detail_provider.dart';
import 'package:solo_adventurer/features/destination_discovery/domain/models/destination.dart';
import 'package:solo_adventurer/features/destination_discovery/domain/models/destination_filter.dart';
import 'package:solo_adventurer/features/destination_discovery/domain/repositories/destination_repository.dart';

// Mock classes
class MockDestinationRepository extends Mock implements DestinationRepository {}

void main() {
  late MockDestinationRepository mockRepository;
  late DestinationDetailNotifier notifier;
  const testDestinationId = 'dest1';

  // Test data
  final testDestination = Destination(
    id: testDestinationId,
    name: 'Tokyo',
    description: 'Amazing city',
    location: (lat: 35.6762, lng: 139.6503),
    safetyScore: 8.5,
    soloSuitabilityScore: 8.0,
    soloSuitabilityFactors: SoloSuitabilityFactors(
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

  final relatedDestinations = [
    Destination(
      id: 'dest2',
      name: 'Kyoto',
      description: 'Historic city',
      location: (lat: 35.0116, lng: 135.7681),
      safetyScore: 9.0,
      soloSuitabilityScore: 8.5,
      soloSuitabilityFactors: SoloSuitabilityFactors(
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
    Destination(
      id: 'dest3',
      name: 'Osaka',
      description: 'Food capital',
      location: (lat: 34.6937, lng: 135.5023),
      safetyScore: 8.0,
      soloSuitabilityScore: 7.5,
      soloSuitabilityFactors: SoloSuitabilityFactors(
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
  ];

  setUp(() {
    mockRepository = MockDestinationRepository();
    notifier = DestinationDetailNotifier(mockRepository, testDestinationId);
  });

  group('DestinationDetailNotifier', () {
    group('initial state', () {
      test('should start with initial state and auto-load destination', () async {
        // The notifier auto-loads on creation, so we need to mock the repository
        when(() => mockRepository.getDestinationById(any()))
            .thenAnswer((_) async => testDestination);

        // Create a new notifier to test auto-load
        final newNotifier = DestinationDetailNotifier(mockRepository, testDestinationId);

        // Wait for auto-load to complete
        await Future.delayed(const Duration(milliseconds: 100));

        verify(() => mockRepository.getDestinationById(testDestinationId)).called(1);
      });
    });

    group('loadDestination', () {
      test('should load destination successfully', () async {
        when(() => mockRepository.getDestinationById(any()))
            .thenAnswer((_) async => testDestination);

        await notifier.loadDestination();

        verify(() => mockRepository.getDestinationById(testDestinationId)).called(1);
        expect(notifier.state.value, isNotNull);
        expect(notifier.state.value!.destination?.id, testDestinationId);
        expect(notifier.state.value!.destination?.name, 'Tokyo');
      });

      test('should handle errors', () async {
        when(() => mockRepository.getDestinationById(any()))
            .thenThrow(Exception('Not found'));

        await notifier.loadDestination();

        expect(notifier.state.hasValue, isFalse);
      });
    });

    group('refresh', () {
      test('should refresh destination data', () async {
        // Setup initial state
        when(() => mockRepository.getDestinationById(any()))
            .thenAnswer((_) async => testDestination);
        await notifier.loadDestination();

        // Reset mock for refresh
        reset(mockRepository);
        when(() => mockRepository.getDestinationById(any()))
            .thenAnswer((_) async => testDestination);

        await notifier.refresh();

        verify(() => mockRepository.getDestinationById(testDestinationId)).called(1);
        expect(notifier.state.value!.destination?.name, 'Tokyo');
      });

      test('should preserve related destinations on refresh', () async {
        // Setup initial state with related destinations
        when(() => mockRepository.getDestinationById(any()))
            .thenAnswer((_) async => testDestination);
        await notifier.loadDestination();

        // Add related destinations
        when(() => mockRepository.searchDestinations(any()))
            .thenAnswer((_) async => relatedDestinations);
        await notifier.loadRelatedDestinations();

        // Reset mock for refresh
        reset(mockRepository);
        when(() => mockRepository.getDestinationById(any()))
            .thenAnswer((_) async => testDestination);

        await notifier.refresh();

        expect(notifier.state.value!.relatedDestinations.length, 2);
      });

      test('should handle errors during refresh', () async {
        // Setup initial state
        when(() => mockRepository.getDestinationById(any()))
            .thenAnswer((_) async => testDestination);
        await notifier.loadDestination();

        // Mock error for refresh
        reset(mockRepository);
        when(() => mockRepository.getDestinationById(any()))
            .thenThrow(Exception('Network error'));

        await notifier.refresh();

        expect(notifier.state.hasValue, isFalse);
      });
    });

    group('loadRelatedDestinations', () {
      test('should load related destinations successfully', () async {
        // Setup initial state
        when(() => mockRepository.getDestinationById(any()))
            .thenAnswer((_) async => testDestination);
        await notifier.loadDestination();

        // Mock related destinations search
        when(() => mockRepository.searchDestinations(any()))
            .thenAnswer((_) async => relatedDestinations);

        await notifier.loadRelatedDestinations();

        verify(() => mockRepository.searchDestinations(any())).called(1);
        expect(notifier.state.value!.relatedDestinations.length, 2);
        expect(notifier.state.value!.relatedDestinations[0].id, 'dest2');
        expect(notifier.state.value!.relatedDestinations[1].id, 'dest3');
      });

      test('should exclude current destination from related', () async {
        // Setup initial state
        when(() => mockRepository.getDestinationById(any()))
            .thenAnswer((_) async => testDestination);
        await notifier.loadDestination();

        // Mock search to return current destination + others
        when(() => mockRepository.searchDestinations(any()))
            .thenAnswer((_) async => [testDestination, ...relatedDestinations]);

        await notifier.loadRelatedDestinations();

        // Should exclude current destination
        expect(notifier.state.value!.relatedDestinations.length, 2);
        expect(
          notifier.state.value!.relatedDestinations.any((d) => d.id == testDestinationId),
          isFalse,
        );
      });

      test('should limit results to maxRelatedDestinations', () async {
        // Setup initial state
        when(() => mockRepository.getDestinationById(any()))
            .thenAnswer((_) async => testDestination);
        await notifier.loadDestination();

        // Mock many related destinations
        final manyDestinations = List.generate(
          10,
          (i) => Destination(
            id: 'dest$i',
            name: 'Destination $i',
            description: 'Test',
            location: (lat: 35.0, lng: 139.0),
            safetyScore: 8.0,
            soloSuitabilityScore: 7.5,
            soloSuitabilityFactors: SoloSuitabilityFactors(
              safety: 8.0,
              nightlife: 7.0,
              walkability: 8.0,
              accommodation: 7.5,
              soloDining: 7.5,
              communication: 7.0,
              overall: 7.5,
            ),
            countryCode: 'JP',
            region: 'Kanto',
            budgetLevel: BudgetLevel.moderate,
            activityLevel: ActivityLevel.moderate,
            tags: [],
            images: [],
            popularActivities: [],
            bestTimeToVisit: 'Spring',
          ),
        );

        when(() => mockRepository.searchDestinations(any()))
            .thenAnswer((_) async => manyDestinations);

        await notifier.loadRelatedDestinations();

        // Should limit to 5 (maxRelatedDestinations)
        expect(notifier.state.value!.relatedDestinations.length, 5);
      });

      test('should do nothing when no destination is loaded', () async {
        notifier.clear();

        await notifier.loadRelatedDestinations();

        verifyNever(() => mockRepository.searchDestinations(any()));
      });

      test('should handle errors', () async {
        // Setup initial state
        when(() => mockRepository.getDestinationById(any()))
            .thenAnswer((_) async => testDestination);
        await notifier.loadDestination();

        // Mock error
        when(() => mockRepository.searchDestinations(any()))
            .thenThrow(Exception('Network error'));

        expect(() async => await notifier.loadRelatedDestinations(), throwsException);
      });
    });

    group('loadRelatedDestinationsWithFilter', () {
      test('should load related destinations with custom filter', () async {
        // Setup initial state
        when(() => mockRepository.getDestinationById(any()))
            .thenAnswer((_) async => testDestination);
        await notifier.loadDestination();

        // Custom filter
        final customFilter = DestinationFilter(
          budgetLevel: BudgetLevel.budget,
          tags: ['food'],
        );

        when(() => mockRepository.searchDestinations(any()))
            .thenAnswer((_) async => [relatedDestinations[1]]); // Only Osaka

        await notifier.loadRelatedDestinationsWithFilter(customFilter);

        verify(() => mockRepository.searchDestinations(any())).called(1);
        expect(notifier.state.value!.relatedDestinations.length, 1);
        expect(notifier.state.value!.relatedDestinations[0].id, 'dest3');
      });

      test('should exclude current destination from results', () async {
        // Setup initial state
        when(() => mockRepository.getDestinationById(any()))
            .thenAnswer((_) async => testDestination);
        await notifier.loadDestination();

        final customFilter = const DestinationFilter();
        when(() => mockRepository.searchDestinations(any()))
            .thenAnswer((_) async => [testDestination, ...relatedDestinations]);

        await notifier.loadRelatedDestinationsWithFilter(customFilter);

        expect(
          notifier.state.value!.relatedDestinations.any((d) => d.id == testDestinationId),
          isFalse,
        );
      });

      test('should do nothing when no destination is loaded', () async {
        notifier.clear();

        await notifier.loadRelatedDestinationsWithFilter(const DestinationFilter());

        verifyNever(() => mockRepository.searchDestinations(any()));
      });

      test('should handle errors', () async {
        // Setup initial state
        when(() => mockRepository.getDestinationById(any()))
            .thenAnswer((_) async => testDestination);
        await notifier.loadDestination();

        when(() => mockRepository.searchDestinations(any()))
            .thenThrow(Exception('Network error'));

        expect(
          () async => await notifier.loadRelatedDestinationsWithFilter(const DestinationFilter()),
          throwsException,
        );
      });
    });

    group('clear', () {
      test('should reset state to initial', () async {
        // Setup state
        when(() => mockRepository.getDestinationById(any()))
            .thenAnswer((_) async => testDestination);
        await notifier.loadDestination();

        notifier.clear();

        expect(notifier.state.value!.destination, isNull);
        expect(notifier.state.value!.relatedDestinations.isEmpty, isTrue);
      });
    });

    group('state getters', () {
      test('should provide access to destination data', () async {
        when(() => mockRepository.getDestinationById(any()))
            .thenAnswer((_) async => testDestination);
        await notifier.loadDestination();

        expect(notifier.state.value!.destination?.name, 'Tokyo');
        expect(notifier.state.value!.destination?.safetyScore, 8.5);
        expect(notifier.state.value!.destination?.countryCode, 'JP');
      });

      test('should provide access to related destinations', () async {
        // Setup state
        when(() => mockRepository.getDestinationById(any()))
            .thenAnswer((_) async => testDestination);
        await notifier.loadDestination();

        when(() => mockRepository.searchDestinations(any()))
            .thenAnswer((_) async => relatedDestinations);
        await notifier.loadRelatedDestinations();

        expect(notifier.state.value!.relatedDestinations.length, 2);
      });
    });
  });
}
