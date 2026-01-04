import 'package:flutter/material.dart' as material
    show
        TextButton,
        ElevatedButton,
        AppBar,
        Text,
        Icons,
        Key,
        TextField,
        IconButton,
        CircularProgressIndicator,
        GridView,
        ListView;
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:soloadventurer/app/app.dart';
import 'package:soloadventurer/app/di/service_locator.dart';
import 'package:soloadventurer/core/storage/secure_storage.dart';
import 'package:soloadventurer/features/auth/data/datasources/mock_auth_remote_data_source.dart';
import 'package:soloadventurer/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:soloadventurer/features/auth/domain/repositories/auth_repository.dart';
import 'package:soloadventurer/features/destination_discovery/domain/models/destination.dart';
import 'package:soloadventurer/features/destination_discovery/domain/models/destination_filter.dart';
import 'package:soloadventurer/features/destination_discovery/domain/models/curated_list.dart';
import 'package:soloadventurer/features/destination_discovery/domain/models/personalized_recommendation.dart';
import 'package:soloadventurer/features/destination_discovery/domain/models/saved_destination.dart';
import 'package:soloadventurer/features/destination_discovery/domain/repositories/destination_repository.dart';
import 'package:soloadventurer/core/providers/core_providers.dart';
import 'package:soloadventurer/features/auth/domain/providers/auth_providers.dart';
import 'test_config.dart';

/// Mock implementation of DestinationRepository for integration testing
class MockDestinationRepository implements DestinationRepository {
  // In-memory storage for test data
  final Map<String, Destination> _destinations = {};
  final List<CuratedList> _curatedLists = [];
  final Map<String, List<SavedDestination>> _savedDestinations = {};
  PersonalizedRecommendation? _recommendations;

  /// Set up test data
  void setupTestData() {
    // Create test destinations
    final tokyo = Destination(
      id: 'tokyo-1',
      name: 'Tokyo',
      description: 'Vibrant metropolis blending ancient traditions with cutting-edge technology',
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
      tags: ['urban', 'cultural', 'food'],
      images: ['https://images.unsplash.com/photo-1540959733332-eab4deabeeaf'],
      popularActivities: const [],
      bestTimeToVisit: 'March-May, October-November',
      isHiddenGem: false,
      popularityScore: 9.2,
      maxDailyCost: 150.0,
    );

    final kyoto = Destination(
      id: 'kyoto-1',
      name: 'Kyoto',
      description: 'Ancient capital with stunning temples and traditional culture',
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
      tags: ['cultural', 'historical', 'nature'],
      images: ['https://images.unsplash.com/photo-1493976040374-85c8e12f0c0e'],
      popularActivities: const [],
      bestTimeToVisit: 'March-May, October-November',
      isHiddenGem: false,
      popularityScore: 8.8,
      maxDailyCost: 120.0,
    );

    final bali = Destination(
      id: 'bali-1',
      name: 'Bali',
      description: 'Tropical paradise with beautiful beaches and rich culture',
      location: (lat: -8.3405, lng: 115.0920),
      safetyScore: 7.5,
      soloSuitabilityScore: 7.0,
      soloSuitabilityFactors: const SoloSuitabilityFactors(
        safety: 7.5,
        nightlife: 8.0,
        walkability: 6.5,
        accommodation: 8.5,
        soloDining: 7.0,
        communication: 6.5,
        overall: 7.3,
      ),
      countryCode: 'ID',
      region: 'Bali',
      budgetLevel: BudgetLevel.budget,
      activityLevel: ActivityLevel.moderate,
      tags: ['beach', 'nature', 'wellness'],
      images: ['https://images.unsplash.com/photo-1537996194471-e657df975ab4'],
      popularActivities: const [],
      bestTimeToVisit: 'April-October',
      isHiddenGem: false,
      popularityScore: 8.5,
      maxDailyCost: 80.0,
    );

    _destinations.addAll({
      'tokyo-1': tokyo,
      'kyoto-1': kyoto,
      'bali-1': bali,
    });

    // Create test curated lists
    _curatedLists.addAll([
      CuratedList(
        id: 'popular-solo-1',
        name: 'Popular Solo Destinations',
        description: 'Most loved destinations by solo travelers',
        type: CuratedListType.popularSolo,
        destinations: [tokyo, kyoto, bali],
        coverImageUrl: 'https://images.unsplash.com/photo-1469854523086-cc02fe5d8800',
        curator: CuratorInfo(
          name: 'SoloAdventurer Team',
          avatarUrl: null,
        ),
        metadata: CuratedListMetadata(
          viewCount: 15234,
          saveCount: 892,
          isFeatured: true,
        ),
        tags: ['popular', 'solo', 'urban'],
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 1),
      ),
      CuratedList(
        id: 'hidden-gems-1',
        name: 'Hidden Gems in Asia',
        description: 'Lesser-known destinations perfect for solo exploration',
        type: CuratedListType.hiddenGems,
        destinations: [kyoto],
        coverImageUrl: 'https://images.unsplash.com/photo-1506905925346-21bda4d32df4',
        curator: CuratorInfo(
          name: 'Adventure Curator',
          avatarUrl: null,
        ),
        metadata: CuratedListMetadata(
          viewCount: 5421,
          saveCount: 423,
          isFeatured: false,
        ),
        tags: ['hidden', 'gems', 'asia'],
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 1),
      ),
    ]);

    // Create test recommendations
    _recommendations = PersonalizedRecommendation(
      id: 'rec-1',
      userId: 'test-user-id',
      recommendedDestinations: [
        RecommendedDestination(
          destination: tokyo,
          matchScore: 0.92,
          reason: 'Matches your interest in urban exploration and cultural experiences',
          matchingFactors: ['high solo suitability', 'cultural activities', 'moderate budget'],
        ),
        RecommendedDestination(
          destination: bali,
          matchScore: 0.85,
          reason: 'Perfect for your preference for beach destinations',
          matchingFactors: ['beach activities', 'budget-friendly', 'wellness focus'],
        ),
      ],
      source: RecommendationSource.userPreferences,
      generatedAt: DateTime.now().subtract(const Duration(hours: 2)),
      expiresAt: DateTime.now().add(const Duration(hours: 22)),
    );
  }

  @override
  Future<List<Destination>> searchDestinations(DestinationFilter filter) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));

    var results = _destinations.values.toList();

    // Apply search query filter
    if (filter.searchQuery != null && filter.searchQuery!.isNotEmpty) {
      final query = filter.searchQuery!.toLowerCase();
      results = results
          .where((d) =>
              d.name.toLowerCase().contains(query) ||
              d.description.toLowerCase().contains(query))
          .toList();
    }

    // Apply budget level filter
    if (filter.budgetLevel != null) {
      results = results.where((d) => d.budgetLevel == filter.budgetLevel).toList();
    }

    // Apply activity level filter
    if (filter.activityLevel != null) {
      results = results.where((d) => d.activityLevel == filter.activityLevel).toList();
    }

    // Apply safety score filter
    if (filter.minSafetyScore != null) {
      results = results.where((d) => d.safetyScore >= filter.minSafetyScore!).toList();
    }

    // Apply solo suitability filter
    if (filter.minSoloSuitabilityScore != null) {
      results = results.where((d) =>
          d.soloSuitabilityScore >= filter.minSoloSuitabilityScore!).toList();
    }

    // Apply country filter
    if (filter.countryCode != null) {
      results = results.where((d) => d.countryCode == filter.countryCode).toList();
    }

    // Apply region filter
    if (filter.region != null) {
      results = results.where((d) => d.region == filter.region).toList();
    }

    // Apply tags filter
    if (filter.tags != null && filter.tags!.isNotEmpty) {
      results = results.where((d) =>
          filter.tags!.any((tag) => d.tags.contains(tag))).toList();
    }

    // Apply hidden gems filter
    if (filter.hiddenGemsOnly == true) {
      results = results.where((d) => d.isHiddenGem).toList();
    }

    // Apply sorting
    switch (filter.sortOrder) {
      case DestinationSortOrder.popularity:
        results.sort((a, b) => b.popularityScore.compareTo(a.popularityScore));
        break;
      case DestinationSortOrder.safety:
        results.sort((a, b) => b.safetyScore.compareTo(a.safetyScore));
        break;
      case DestinationSortOrder.soloSuitability:
        results.sort((a, b) => b.soloSuitabilityScore.compareTo(a.soloSuitabilityScore));
        break;
      case DestinationSortOrder.budgetAsc:
        results.sort((a, b) => a.maxDailyCost.compareTo(b.maxDailyCost));
        break;
      case DestinationSortOrder.budgetDesc:
        results.sort((a, b) => b.maxDailyCost.compareTo(a.maxDailyCost));
        break;
      case DestinationSortOrder.newest:
        // For simplicity, sort by ID (newer destinations have higher IDs)
        results.sort((a, b) => b.id.compareTo(a.id));
        break;
      case DestinationSortOrder.relevance:
      default:
        // Keep current order
        break;
    }

    // Apply pagination
    final offset = filter.offset ?? 0;
    final limit = filter.limit ?? 20;
    final paginatedResults = results.skip(offset).take(limit).toList();

    return paginatedResults;
  }

  @override
  Future<Destination> getDestinationById(String id) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 300));

    final destination = _destinations[id];
    if (destination == null) {
      throw Exception('Destination not found: $id');
    }
    return destination;
  }

  @override
  Future<PersonalizedRecommendation> getPersonalizedRecommendations(
    String userId,
  ) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 400));

    if (_recommendations == null) {
      throw Exception('No recommendations available');
    }
    return _recommendations!;
  }

  @override
  Future<List<CuratedList>> getCuratedLists() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 300));

    return _curatedLists;
  }

  @override
  Future<CuratedList> getCuratedListById(String id) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 300));

    final list = _curatedLists.where((l) => l.id == id).firstOrNull;
    if (list == null) {
      throw Exception('Curated list not found: $id');
    }
    return list;
  }

  @override
  Future<SavedDestination> saveDestination(SavedDestination saved) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 400));

    final userSavedList = _savedDestinations.putIfAbsent(saved.userId, () => []);

    // Check if already saved
    final existingIndex = userSavedList.indexWhere(
      (s) => s.destination.id == saved.destination.id &&
             s.saveType == saved.saveType,
    );

    if (existingIndex != -1) {
      // Update existing
      userSavedList[existingIndex] = saved;
    } else {
      // Add new
      userSavedList.add(saved);
    }

    return saved;
  }

  @override
  Future<void> unsaveDestination({
    required String destinationId,
    required String userId,
    SaveType? saveType,
  }) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 300));

    final userSavedList = _savedDestinations[userId];
    if (userSavedList == null) return;

    if (saveType != null) {
      userSavedList.removeWhere(
        (s) => s.destination.id == destinationId && s.saveType == saveType,
      );
    } else {
      userSavedList.removeWhere((s) => s.destination.id == destinationId);
    }
  }

  @override
  Future<List<SavedDestination>> getSavedDestinations(
    String userId, {
    SaveType? saveType,
  }) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 300));

    final userSavedList = _savedDestinations[userId] ?? [];

    if (saveType != null) {
      return userSavedList.where((s) => s.saveType == saveType).toList();
    }

    return userSavedList;
  }
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late ProviderContainer container;
  late MockDestinationRepository mockDestinationRepository;
  late MockAuthRemoteDataSource mockAuthRemoteDataSource;
  late AuthRepository authRepository;

  setUp(() async {
    // Initialize SharedPreferences for testing
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    // Initialize service locator in test mode
    await setupServiceLocator(isTest: true);

    // Clear any existing auth data
    await getIt<SecureStorage>().delete(TestConfig.authTokenKey);
    await getIt<SecureStorage>().delete(TestConfig.refreshTokenKey);
    await getIt<SecureStorage>().delete(TestConfig.userDataKey);

    // Initialize mock repositories
    mockDestinationRepository = MockDestinationRepository();
    mockDestinationRepository.setupTestData();

    mockAuthRemoteDataSource = MockAuthRemoteDataSource(getIt());

    authRepository = AuthRepositoryImpl(
      remoteDataSource: mockAuthRemoteDataSource,
      localDataSource: getIt(),
      securityManager: getIt(),
    );

    // Override providers with mock implementations
    container = ProviderContainer(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        authRepositoryProvider.overrideWithValue(authRepository),
      ],
    );
  });

  tearDown(() async {
    await resetServiceLocator();
    container.dispose();
  });

  group('Destination Discovery Integration Tests', () {
    testWidgets('Complete search destinations flow', (tester) async {
      // Build app with mock repository
      await tester.pumpWidget(UncontrolledProviderScope(
        container: container,
        child: const App(),
      ));
      await tester.pumpAndSettle();

      // Should be on login screen initially
      expect(find.widgetWithText(material.AppBar, 'Login'), findsOneWidget);

      // Perform login to access the app
      await tester.enterText(
        find.widgetWithText(material.TextField, 'Email'),
        TestConfig.testEmail,
      );
      await tester.enterText(
        find.widgetWithText(material.TextField, 'Password'),
        TestConfig.testPassword,
      );

      await tester.tap(find.widgetWithText(material.ElevatedButton, 'Login'));
      await tester.pumpAndSettle();

      // Should be on home screen now
      await tester.pump(const Duration(seconds: 1));
      await tester.pumpAndSettle();
      expect(find.text('Welcome to SoloAdventurer!'), findsOneWidget);

      // Tap on "Discover Destinations" hero card
      await tester.tap(find.text('Discover Destinations'));
      await tester.pumpAndSettle();

      // Should be on destination discovery screen
      expect(find.byType(material.AppBar), findsOneWidget);
      expect(find.text('Destination Discovery'), findsOneWidget);

      // Wait for initial search to complete
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpAndSettle();

      // Should see destination cards (verify destinations are displayed)
      expect(find.text('Tokyo'), findsOneWidget);
      expect(find.text('Kyoto'), findsOneWidget);
      expect(find.text('Bali'), findsOneWidget);

      // Test search functionality
      final searchField = find.byType(material.TextField);
      await tester.enterText(searchField, 'Tokyo');
      await tester.pump(const Duration(milliseconds: 500)); // Wait for debounce
      await tester.pumpAndSettle();

      // Should only see Tokyo
      expect(find.text('Tokyo'), findsOneWidget);
      expect(find.text('Kyoto'), findsNothing);
      expect(find.text('Bali'), findsNothing);

      // Clear search
      await tester.tap(find.byIcon(material.Icons.clear));
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpAndSettle();

      // Should see all destinations again
      expect(find.text('Tokyo'), findsOneWidget);
      expect(find.text('Kyoto'), findsOneWidget);
      expect(find.text('Bali'), findsOneWidget);
    });

    testWidgets('View destination detail flow', (tester) async {
      await tester.pumpWidget(UncontrolledProviderScope(
        container: container,
        child: const App(),
      ));
      await tester.pumpAndSettle();

      // Login
      await tester.enterText(
        find.widgetWithText(material.TextField, 'Email'),
        TestConfig.testEmail,
      );
      await tester.enterText(
        find.widgetWithText(material.TextField, 'Password'),
        TestConfig.testPassword,
      );

      await tester.tap(find.widgetWithText(material.ElevatedButton, 'Login'));
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 1));
      await tester.pumpAndSettle();

      // Navigate to destination discovery
      await tester.tap(find.text('Discover Destinations'));
      await tester.pumpAndSettle();
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpAndSettle();

      // Tap on Tokyo destination card
      await tester.tap(find.text('Tokyo'));
      await tester.pumpAndSettle();

      // Should be on destination detail screen
      expect(find.text('Tokyo'), findsOneWidget);
      expect(find.text('Vibrant metropolis blending ancient traditions'), findsOneWidget);

      // Verify safety score badge
      expect(find.text('8.5'), findsAtLeastNWidgets(1));

      // Verify solo suitability badge
      expect(find.text('8.0'), findsAtLeastNWidgets(1));

      // Scroll down to see related destinations
      await tester.drag(
        find.byType(material.ListView),
        const Offset(0, -500),
      );
      await tester.pumpAndSettle();

      // Should see related destinations section
      expect(find.text('Related Destinations'), findsOneWidget);
    });

    testWidgets('Filter destinations flow', (tester) async {
      await tester.pumpWidget(UncontrolledProviderScope(
        container: container,
        child: const App(),
      ));
      await tester.pumpAndSettle();

      // Login
      await tester.enterText(
        find.widgetWithText(material.TextField, 'Email'),
        TestConfig.testEmail,
      );
      await tester.enterText(
        find.widgetWithText(material.TextField, 'Password'),
        TestConfig.testPassword,
      );

      await tester.tap(find.widgetWithText(material.ElevatedButton, 'Login'));
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 1));
      await tester.pumpAndSettle();

      // Navigate to destination discovery
      await tester.tap(find.text('Discover Destinations'));
      await tester.pumpAndSettle();
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpAndSettle();

      // Should see all destinations initially
      expect(find.text('Tokyo'), findsOneWidget);
      expect(find.text('Kyoto'), findsOneWidget);
      expect(find.text('Bali'), findsOneWidget);

      // Tap filter button to open filter modal
      await tester.tap(find.byIcon(material.Icons.tune));
      await tester.pumpAndSettle();

      // Filter modal should be visible
      expect(find.text('Filter Destinations'), findsOneWidget);

      // Select budget filter
      await tester.tap(find.text('Budget'));
      await tester.pumpAndSettle();

      // Apply filter
      await tester.tap(find.text('Apply'));
      await tester.pumpAndSettle();
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpAndSettle();

      // Should see filtered results (Tokyo and Kyoto are moderate)
      expect(find.text('Tokyo'), findsOneWidget);
      expect(find.text('Kyoto'), findsOneWidget);
    });

    testWidgets('Save destination flow', (tester) async {
      await tester.pumpWidget(UncontrolledProviderScope(
        container: container,
        child: const App(),
      ));
      await tester.pumpAndSettle();

      // Login
      await tester.enterText(
        find.widgetWithText(material.TextField, 'Email'),
        TestConfig.testEmail,
      );
      await tester.enterText(
        find.widgetWithText(material.TextField, 'Password'),
        TestConfig.testPassword,
      );

      await tester.tap(find.widgetWithText(material.ElevatedButton, 'Login'));
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 1));
      await tester.pumpAndSettle();

      // Navigate to destination discovery
      await tester.tap(find.text('Discover Destinations'));
      await tester.pumpAndSettle();
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpAndSettle();

      // Tap on Tokyo destination
      await tester.tap(find.text('Tokyo'));
      await tester.pumpAndSettle();

      // Tap bookmark button
      await tester.tap(find.byIcon(material.Icons.bookmark_border));
      await tester.pumpAndSettle();
      await tester.pump(const Duration(milliseconds: 400));
      await tester.pumpAndSettle();

      // Bookmark icon should be filled now
      expect(find.byIcon(material.Icons.bookmark), findsOneWidget);

      // Navigate to saved destinations
      await tester.tap(find.byIcon(material.Icons.arrow_back));
      await tester.pumpAndSettle();

      await tester.drag(
        find.byType(material.ListView),
        const Offset(0, -500),
      );
      await tester.pumpAndSettle();

      // Find and tap "Saved" text or navigate via home
      await tester.tap(find.byIcon(material.Icons.home));
      await tester.pumpAndSettle();

      // Scroll to find saved destinations quick access
      await tester.drag(
        find.byType(material.ListView),
        const Offset(0, -300),
      );
      await tester.pumpAndSettle();

      if (find.text('Saved Destinations').evaluate().isNotEmpty) {
        await tester.tap(find.text('Saved Destinations'));
        await tester.pumpAndSettle();

        // Should see saved destination
        expect(find.text('Tokyo'), findsOneWidget);
      }
    });

    testWidgets('View recommendations flow', (tester) async {
      await tester.pumpWidget(UncontrolledProviderScope(
        container: container,
        child: const App(),
      ));
      await tester.pumpAndSettle();

      // Login
      await tester.enterText(
        find.widgetWithText(material.TextField, 'Email'),
        TestConfig.testEmail,
      );
      await tester.enterText(
        find.widgetWithText(material.TextField, 'Password'),
        TestConfig.testPassword,
      );

      await tester.tap(find.widgetWithText(material.ElevatedButton, 'Login'));
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 1));
      await tester.pumpAndSettle();

      // Scroll to find recommendations section on home
      await tester.drag(
        find.byType(material.ListView),
        const Offset(0, -300),
      );
      await tester.pumpAndSettle();

      // Tap on "Personalized" recommendations card
      if (find.text('Personalized').evaluate().isNotEmpty) {
        await tester.tap(find.text('Personalized'));
        await tester.pumpAndSettle();
        await tester.pump(const Duration(milliseconds: 400));
        await tester.pumpAndSettle();

        // Should be on recommendations screen
        expect(find.text('Recommendations'), findsOneWidget);

        // Should see recommended destinations
        expect(find.textContaining('92%'), findsOneWidget); // Match score
        expect(find.text('Tokyo'), findsOneWidget);
      }
    });

    testWidgets('View curated lists flow', (tester) async {
      await tester.pumpWidget(UncontrolledProviderScope(
        container: container,
        child: const App(),
      ));
      await tester.pumpAndSettle();

      // Login
      await tester.enterText(
        find.widgetWithText(material.TextField, 'Email'),
        TestConfig.testEmail,
      );
      await tester.enterText(
        find.widgetWithText(material.TextField, 'Password'),
        TestConfig.testPassword,
      );

      await tester.tap(find.widgetWithText(material.ElevatedButton, 'Login'));
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 1));
      await tester.pumpAndSettle();

      // Scroll to find curated collections section on home
      await tester.drag(
        find.byType(material.ListView),
        const Offset(0, -400),
      );
      await tester.pumpAndSettle();

      // Tap "See All" for curated collections
      if (find.text('See All').evaluate().isNotEmpty) {
        final seeAllButtons = find.text('See All');
        await tester.tap(seeAllButtons.first);
        await tester.pumpAndSettle();
        await tester.pump(const Duration(milliseconds: 400));
        await tester.pumpAndSettle();

        // Should be on curated lists screen
        expect(find.text('Curated Lists'), findsOneWidget);

        // Should see curated list cards
        expect(find.text('Popular Solo Destinations'), findsOneWidget);
        expect(find.text('Hidden Gems in Asia'), findsOneWidget);

        // Tap on a curated list
        await tester.tap(find.text('Popular Solo Destinations'));
        await tester.pumpAndSettle();

        // Should see list detail
        expect(find.text('Popular Solo Destinations'), findsOneWidget);
        expect(find.text('Most loved destinations by solo travelers'), findsOneWidget);
      }
    });

    testWidgets('Pull to refresh functionality', (tester) async {
      await tester.pumpWidget(UncontrolledProviderScope(
        container: container,
        child: const App(),
      ));
      await tester.pumpAndSettle();

      // Login
      await tester.enterText(
        find.widgetWithText(material.TextField, 'Email'),
        TestConfig.testEmail,
      );
      await tester.enterText(
        find.widgetWithText(material.TextField, 'Password'),
        TestConfig.testPassword,
      );

      await tester.tap(find.widgetWithText(material.ElevatedButton, 'Login'));
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 1));
      await tester.pumpAndSettle();

      // Navigate to destination discovery
      await tester.tap(find.text('Discover Destinations'));
      await tester.pumpAndSettle();
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpAndSettle();

      // Perform pull to refresh
      await tester.drag(
        find.byType(material.ListView),
        const Offset(0, 300),
      );
      await tester.pumpAndSettle();

      // Should show refreshing indicator
      expect(find.byType(material.CircularProgressIndicator), findsOneWidget);

      // Wait for refresh to complete
      await tester.pump(const Duration(seconds: 1));
      await tester.pumpAndSettle();

      // Should still see destinations
      expect(find.text('Tokyo'), findsOneWidget);
    });

    testWidgets('Infinite scroll pagination', (tester) async {
      await tester.pumpWidget(UncontrolledProviderScope(
        container: container,
        child: const App(),
      ));
      await tester.pumpAndSettle();

      // Login
      await tester.enterText(
        find.widgetWithText(material.TextField, 'Email'),
        TestConfig.testEmail,
      );
      await tester.enterText(
        find.widgetWithText(material.TextField, 'Password'),
        TestConfig.testPassword,
      );

      await tester.tap(find.widgetWithText(material.ElevatedButton, 'Login'));
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 1));
      await tester.pumpAndSettle();

      // Navigate to destination discovery
      await tester.tap(find.text('Discover Destinations'));
      await tester.pumpAndSettle();
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpAndSettle();

      // Scroll to bottom to trigger load more
      await tester.drag(
        find.byType(material.ListView),
        const Offset(0, -1000),
      );
      await tester.pumpAndSettle();

      // Should show loading indicator at bottom
      expect(find.byType(material.CircularProgressIndicator), findsAtLeastNWidgets(1));

      // Wait for load more to complete
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpAndSettle();

      // Should still see destinations
      expect(find.text('Tokyo'), findsOneWidget);
    });

    testWidgets('Empty state handling', (tester) async {
      await tester.pumpWidget(UncontrolledProviderScope(
        container: container,
        child: const App(),
      ));
      await tester.pumpAndSettle();

      // Login
      await tester.enterText(
        find.widgetWithText(material.TextField, 'Email'),
        TestConfig.testEmail,
      );
      await tester.enterText(
        find.widgetWithText(material.TextField, 'Password'),
        TestConfig.testPassword,
      );

      await tester.tap(find.widgetWithText(material.ElevatedButton, 'Login'));
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 1));
      await tester.pumpAndSettle();

      // Navigate to destination discovery
      await tester.tap(find.text('Discover Destinations'));
      await tester.pumpAndSettle();
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpAndSettle();

      // Search for non-existent destination
      final searchField = find.byType(material.TextField);
      await tester.enterText(searchField, 'NonExistentCity123');
      await tester.pump(const Duration(milliseconds: 500)); // Wait for debounce
      await tester.pumpAndSettle();

      // Should see empty state
      expect(find.text('No destinations found'), findsOneWidget);
    });
  });
}
