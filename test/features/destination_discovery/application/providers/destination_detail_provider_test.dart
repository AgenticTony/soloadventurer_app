import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:soloadventurer/features/destination_discovery/application/providers/destination_detail_provider.dart';
import 'package:soloadventurer/features/destination_discovery/application/providers/destination_repository_provider.dart';
import 'package:soloadventurer/features/destination_discovery/domain/models/destination.dart';
import 'package:soloadventurer/features/destination_discovery/domain/models/destination_filter.dart'
    hide BudgetLevel, ActivityLevel;
import 'package:soloadventurer/features/destination_discovery/domain/repositories/destination_repository.dart';

class MockDestinationRepository extends Mock implements DestinationRepository {}

void main() {
  late MockDestinationRepository mockRepository;
  const testDestinationId = 'dest1';

  final testDestination = Destination(
    id: testDestinationId,
    name: 'Tokyo',
    description: 'Amazing city',
    latitude: 35.6762,
    longitude: 139.6503,
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
    activityLevels: [ActivityLevel.moderate],
    tags: ['urban', 'cultural'],
    images: ['https://example.com/tokyo.jpg'],
    popularActivities: [],
    safetyInsights: [],
    bestTimeToVisit: 'Spring',
    createdAt: DateTime(2024, 1, 1),
    updatedAt: DateTime(2024, 1, 1),
  );

  final relatedDestinations = [
    Destination(
      id: 'dest2',
      name: 'Kyoto',
      description: 'Historic city',
      latitude: 35.0116,
      longitude: 135.7681,
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
      activityLevels: [ActivityLevel.relaxed],
      tags: ['cultural', 'historical'],
      images: ['https://example.com/kyoto.jpg'],
      popularActivities: [],
      safetyInsights: [],
      bestTimeToVisit: 'Spring',
      createdAt: DateTime(2024, 1, 1),
      updatedAt: DateTime(2024, 1, 1),
    ),
    Destination(
      id: 'dest3',
      name: 'Osaka',
      description: 'Food capital',
      latitude: 34.6937,
      longitude: 135.5023,
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
      activityLevels: [ActivityLevel.moderate],
      tags: ['food', 'urban'],
      images: ['https://example.com/osaka.jpg'],
      popularActivities: [],
      safetyInsights: [],
      bestTimeToVisit: 'Fall',
      createdAt: DateTime(2024, 1, 1),
      updatedAt: DateTime(2024, 1, 1),
    ),
  ];

  ProviderContainer makeContainer() {
    return ProviderContainer.test(overrides: [
      destinationRepositoryProvider.overrideWithValue(mockRepository),
    ]);
  }

  setUpAll(() {
    registerFallbackValue(DestinationFilter());
  });

  setUp(() {
    mockRepository = MockDestinationRepository();
  });

  group('DestinationDetail', () {
    group('initial state', () {
      test('should auto-load destination on build', () async {
        when(() => mockRepository.getDestinationById(testDestinationId))
            .thenAnswer((_) async => testDestination);

        final container = makeContainer();
        addTearDown(container.dispose);

        // Trigger build and wait
        await container
            .read(destinationDetailProvider(testDestinationId).future);

        verify(() => mockRepository.getDestinationById(testDestinationId))
            .called(1);
        final state =
            container.read(destinationDetailProvider(testDestinationId)).value!;
        expect(state.destination?.id, testDestinationId);
        expect(state.destination?.name, 'Tokyo');
      });

      test('should handle error on build', () async {
        when(() => mockRepository.getDestinationById(any()))
            .thenThrow(Exception('Not found'));

        final errorContainer = ProviderContainer(overrides: [
          destinationRepositoryProvider.overrideWithValue(mockRepository),
        ]);

        bool gotError = false;
        final sub = errorContainer.listen(
          destinationDetailProvider(testDestinationId),
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
      test('should refresh destination data', () async {
        when(() => mockRepository.getDestinationById(testDestinationId))
            .thenAnswer((_) async => testDestination);

        final container = makeContainer();
        addTearDown(container.dispose);
        await container
            .read(destinationDetailProvider(testDestinationId).future);

        // Refresh
        reset(mockRepository);
        when(() => mockRepository.getDestinationById(testDestinationId))
            .thenAnswer((_) async => testDestination);

        await container
            .read(destinationDetailProvider(testDestinationId).notifier)
            .refresh();

        verify(() => mockRepository.getDestinationById(testDestinationId))
            .called(1);
        final state =
            container.read(destinationDetailProvider(testDestinationId)).value!;
        expect(state.destination?.name, 'Tokyo');
      });

      test('should preserve related destinations on refresh', () async {
        when(() => mockRepository.getDestinationById(testDestinationId))
            .thenAnswer((_) async => testDestination);
        when(() => mockRepository.searchDestinations(any()))
            .thenAnswer((_) async => relatedDestinations);

        final container = makeContainer();
        addTearDown(container.dispose);
        await container
            .read(destinationDetailProvider(testDestinationId).future);
        await container
            .read(destinationDetailProvider(testDestinationId).notifier)
            .loadRelatedDestinations();

        reset(mockRepository);
        when(() => mockRepository.getDestinationById(testDestinationId))
            .thenAnswer((_) async => testDestination);

        await container
            .read(destinationDetailProvider(testDestinationId).notifier)
            .refresh();

        final state =
            container.read(destinationDetailProvider(testDestinationId)).value!;
        expect(state.relatedDestinations.length, 2);
      });

      test('should handle errors during refresh', () async {
        when(() => mockRepository.getDestinationById(testDestinationId))
            .thenAnswer((_) async => testDestination);

        final container = makeContainer();
        addTearDown(container.dispose);
        await container
            .read(destinationDetailProvider(testDestinationId).future);

        reset(mockRepository);
        when(() => mockRepository.getDestinationById(testDestinationId))
            .thenThrow(Exception('Network error'));

        await container
            .read(destinationDetailProvider(testDestinationId).notifier)
            .refresh();

        expect(
            container
                .read(destinationDetailProvider(testDestinationId))
                .hasError,
            isTrue);
      });
    });

    group('loadRelatedDestinations', () {
      test('should load related destinations successfully', () async {
        when(() => mockRepository.getDestinationById(testDestinationId))
            .thenAnswer((_) async => testDestination);
        when(() => mockRepository.searchDestinations(any()))
            .thenAnswer((_) async => relatedDestinations);

        final container = makeContainer();
        addTearDown(container.dispose);
        await container
            .read(destinationDetailProvider(testDestinationId).future);

        await container
            .read(destinationDetailProvider(testDestinationId).notifier)
            .loadRelatedDestinations();

        verify(() => mockRepository.searchDestinations(any())).called(1);
        final state =
            container.read(destinationDetailProvider(testDestinationId)).value!;
        expect(state.relatedDestinations.length, 2);
        expect(state.relatedDestinations[0].id, 'dest2');
        expect(state.relatedDestinations[1].id, 'dest3');
      });

      test('should exclude current destination from related', () async {
        when(() => mockRepository.getDestinationById(testDestinationId))
            .thenAnswer((_) async => testDestination);
        when(() => mockRepository.searchDestinations(any()))
            .thenAnswer(
                (_) async => [testDestination, ...relatedDestinations]);

        final container = makeContainer();
        addTearDown(container.dispose);
        await container
            .read(destinationDetailProvider(testDestinationId).future);

        await container
            .read(destinationDetailProvider(testDestinationId).notifier)
            .loadRelatedDestinations();

        final state =
            container.read(destinationDetailProvider(testDestinationId)).value!;
        expect(state.relatedDestinations.length, 2);
        expect(
          state.relatedDestinations.any((d) => d.id == testDestinationId),
          isFalse,
        );
      });

      test('should limit results to maxRelatedDestinations', () async {
        when(() => mockRepository.getDestinationById(testDestinationId))
            .thenAnswer((_) async => testDestination);

        final manyDestinations = List.generate(
          10,
          (i) => Destination(
            id: 'dest$i',
            name: 'Destination $i',
            description: 'Test',
            latitude: 35.0,
            longitude: 139.0,
            safetyScore: 8.0,
            soloSuitabilityScore: 7.5,
            soloSuitabilityFactors: const SoloSuitabilityFactors(
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
            activityLevels: [ActivityLevel.moderate],
            tags: [],
            images: [],
            popularActivities: [],
            safetyInsights: [],
            bestTimeToVisit: 'Spring',
            createdAt: DateTime(2024, 1, 1),
            updatedAt: DateTime(2024, 1, 1),
          ),
        );

        when(() => mockRepository.searchDestinations(any()))
            .thenAnswer((_) async => manyDestinations);

        final container = makeContainer();
        addTearDown(container.dispose);
        await container
            .read(destinationDetailProvider(testDestinationId).future);

        await container
            .read(destinationDetailProvider(testDestinationId).notifier)
            .loadRelatedDestinations();

        final state =
            container.read(destinationDetailProvider(testDestinationId)).value!;
        // Should limit to 5 (maxRelatedDestinations)
        expect(state.relatedDestinations.length, 5);
      });

      test('should do nothing when no destination is loaded', () async {
        final container = makeContainer();
        addTearDown(container.dispose);

        // Use a different ID that won't auto-load
        // Actually, the provider auto-loads on build, so we need to clear first
        // Clear sets state to initial
        container
            .read(destinationDetailProvider(testDestinationId).notifier)
            .clear();

        await container
            .read(destinationDetailProvider(testDestinationId).notifier)
            .loadRelatedDestinations();

        verifyNever(() => mockRepository.searchDestinations(any()));
      });

      test('should handle errors', () async {
        when(() => mockRepository.getDestinationById(testDestinationId))
            .thenAnswer((_) async => testDestination);

        final container = makeContainer();
        addTearDown(container.dispose);
        await container
            .read(destinationDetailProvider(testDestinationId).future);

        when(() => mockRepository.searchDestinations(any()))
            .thenThrow(Exception('Network error'));

        await container
            .read(destinationDetailProvider(testDestinationId).notifier)
            .loadRelatedDestinations();

        expect(container.read(destinationDetailProvider(testDestinationId)).hasError, isTrue);
      });
    });

    group('loadRelatedDestinationsWithFilter', () {
      test('should load related destinations with custom filter', () async {
        when(() => mockRepository.getDestinationById(testDestinationId))
            .thenAnswer((_) async => testDestination);
        when(() => mockRepository.searchDestinations(any()))
            .thenAnswer((_) async => [relatedDestinations[1]]);

        final container = makeContainer();
        addTearDown(container.dispose);
        await container
            .read(destinationDetailProvider(testDestinationId).future);

        final customFilter = DestinationFilter(
          budgetLevel: FilterBudgetLevel.budget,
          tags: ['food'],
        );

        await container
            .read(destinationDetailProvider(testDestinationId).notifier)
            .loadRelatedDestinationsWithFilter(customFilter);

        verify(() => mockRepository.searchDestinations(any())).called(1);
        final state =
            container.read(destinationDetailProvider(testDestinationId)).value!;
        expect(state.relatedDestinations.length, 1);
        expect(state.relatedDestinations[0].id, 'dest3');
      });

      test('should exclude current destination from results', () async {
        when(() => mockRepository.getDestinationById(testDestinationId))
            .thenAnswer((_) async => testDestination);
        when(() => mockRepository.searchDestinations(any()))
            .thenAnswer(
                (_) async => [testDestination, ...relatedDestinations]);

        final container = makeContainer();
        addTearDown(container.dispose);
        await container
            .read(destinationDetailProvider(testDestinationId).future);

        final customFilter = DestinationFilter();
        await container
            .read(destinationDetailProvider(testDestinationId).notifier)
            .loadRelatedDestinationsWithFilter(customFilter);

        final state =
            container.read(destinationDetailProvider(testDestinationId)).value!;
        expect(
          state.relatedDestinations.any((d) => d.id == testDestinationId),
          isFalse,
        );
      });

      test('should do nothing when no destination is loaded', () async {
        final container = makeContainer();
        addTearDown(container.dispose);

        container
            .read(destinationDetailProvider(testDestinationId).notifier)
            .clear();

        await container
            .read(destinationDetailProvider(testDestinationId).notifier)
            .loadRelatedDestinationsWithFilter(DestinationFilter());

        verifyNever(() => mockRepository.searchDestinations(any()));
      });

      test('should handle errors', () async {
        when(() => mockRepository.getDestinationById(testDestinationId))
            .thenAnswer((_) async => testDestination);

        final container = makeContainer();
        addTearDown(container.dispose);
        await container
            .read(destinationDetailProvider(testDestinationId).future);

        when(() => mockRepository.searchDestinations(any()))
            .thenThrow(Exception('Network error'));

        await container
            .read(destinationDetailProvider(testDestinationId).notifier)
            .loadRelatedDestinationsWithFilter(DestinationFilter());

        expect(container.read(destinationDetailProvider(testDestinationId)).hasError, isTrue);
      });
    });

    group('clear', () {
      test('should reset state to initial', () async {
        when(() => mockRepository.getDestinationById(testDestinationId))
            .thenAnswer((_) async => testDestination);

        final container = makeContainer();
        addTearDown(container.dispose);
        await container
            .read(destinationDetailProvider(testDestinationId).future);

        container
            .read(destinationDetailProvider(testDestinationId).notifier)
            .clear();

        final state =
            container.read(destinationDetailProvider(testDestinationId)).value!;
        expect(state.destination, isNull);
        expect(state.relatedDestinations.isEmpty, isTrue);
      });
    });

    group('state getters', () {
      test('should provide access to destination data', () async {
        when(() => mockRepository.getDestinationById(testDestinationId))
            .thenAnswer((_) async => testDestination);

        final container = makeContainer();
        addTearDown(container.dispose);
        await container
            .read(destinationDetailProvider(testDestinationId).future);

        final state =
            container.read(destinationDetailProvider(testDestinationId)).value!;
        expect(state.destination?.name, 'Tokyo');
        expect(state.destination?.safetyScore, 8.5);
        expect(state.destination?.countryCode, 'JP');
      });

      test('should provide access to related destinations', () async {
        when(() => mockRepository.getDestinationById(testDestinationId))
            .thenAnswer((_) async => testDestination);
        when(() => mockRepository.searchDestinations(any()))
            .thenAnswer((_) async => relatedDestinations);

        final container = makeContainer();
        addTearDown(container.dispose);
        await container
            .read(destinationDetailProvider(testDestinationId).future);
        await container
            .read(destinationDetailProvider(testDestinationId).notifier)
            .loadRelatedDestinations();

        final state =
            container.read(destinationDetailProvider(testDestinationId)).value!;
        expect(state.relatedDestinations.length, 2);
      });
    });
  });
}
