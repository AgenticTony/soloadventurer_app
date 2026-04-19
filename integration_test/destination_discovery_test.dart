import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:soloadventurer/features/destination_discovery/domain/models/destination.dart' as dest_models;
import 'package:soloadventurer/features/destination_discovery/domain/models/destination_filter.dart';
import 'package:soloadventurer/features/destination_discovery/domain/models/curated_list.dart';
import 'package:soloadventurer/features/destination_discovery/domain/models/personalized_recommendation.dart';
import 'package:soloadventurer/features/destination_discovery/domain/models/saved_destination.dart';
import 'package:soloadventurer/features/destination_discovery/domain/repositories/destination_repository.dart';
import 'package:soloadventurer/features/auth/domain/entities/user.dart';
import 'package:soloadventurer/features/auth/domain/models/auth_session.dart';
import 'package:soloadventurer/features/auth/domain/repositories/auth_repository.dart';

import 'test_config.dart';

// ---------------------------------------------------------------------------
// In-memory mock: AuthRepository
// ---------------------------------------------------------------------------

class MockAuthRepository implements AuthRepository {
  User? _currentUser;
  final Map<String, (String, User)> _users = {}; // email -> (password, User)

  void _seedTestUser() {
    final user = User(
      id: 'test-user-1',
      email: TestConfig.testEmail,
      username: TestConfig.testName,
      createdAt: DateTime(2024, 1, 1),
    );
    _users[TestConfig.testEmail] = (TestConfig.testPassword, user);
  }

  MockAuthRepository() {
    _seedTestUser();
  }

  @override
  Future<User> signInWithEmailAndPassword(String email, String password) async {
    await Future.delayed(TestConfig.stepDelay);
    final entry = _users[email];
    if (entry == null || entry.$1 != password) {
      throw Exception('Invalid email or password');
    }
    _currentUser = entry.$2.copyWith(lastLoginAt: DateTime.now());
    return _currentUser!;
  }

  @override
  Future<(User, bool)> register({
    required String email,
    required String password,
    required String name,
  }) async {
    await Future.delayed(TestConfig.stepDelay);
    final exists = _users.containsKey(email);
    final user = User(
      id: 'user-${DateTime.now().millisecondsSinceEpoch}',
      email: email,
      username: name,
      createdAt: DateTime.now(),
    );
    _users[email] = (password, user);
    _currentUser = user;
    return (user, !exists);
  }

  @override
  Future<void> signOut() async {
    _currentUser = null;
  }

  @override
  Future<User?> getCurrentUser() async => _currentUser;

  @override
  Future<bool> isAuthenticated() async => _currentUser != null;

  // Unused AuthRepository methods — stubs required by the interface

  @override
  Future<void> sendPasswordResetEmail(String email) async {}

  @override
  Future<void> confirmPasswordReset({
    required String email,
    required String code,
    required String newPassword,
  }) async {}

  @override
  Future<User> updateUserProfile({
    String? name,
    String? email,
    String? photoUrl,
  }) async =>
      _currentUser!;

  @override
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {}

  @override
  Future<void> verifyEmail(String code, String email) async {}

  @override
  Future<void> resendVerificationEmail() async {}

  @override
  Future<String> enableTwoFactor() async => '';

  @override
  Future<void> disableTwoFactor(String code) async {}

  @override
  Future<void> verifyTwoFactor(String code) async {}

  @override
  Future<bool> isSignedIn() async => _currentUser != null;

  @override
  Future<String?> getAccessToken() async => _currentUser?.accessToken;

  @override
  Future<AuthSession> refreshToken() async => throw UnimplementedError();

  @override
  Future<AuthSession> performBasicTokenRefresh() async => throw UnimplementedError();

  @override
  Future<AuthSession?> getSession() async => null;

  @override
  Future<User> registerWithEmailAndPassword(
      String email, String password, String username) async {
    return (await register(email: email, password: password, name: username))
        .$1;
  }

  @override
  Future<void> deleteAccount() async {
    if (_currentUser != null) {
      _users.remove(_currentUser!.email);
      _currentUser = null;
    }
  }
}

// ---------------------------------------------------------------------------
// Sample data helpers
// ---------------------------------------------------------------------------

final _now = DateTime(2024, 6, 1);
final _later = DateTime(2024, 12, 31);

dest_models.SoloSuitabilityFactors _soloFactors({
  double overall = 8.0,
  double safety = 8.0,
}) =>
    dest_models.SoloSuitabilityFactors(
      safety: safety,
      nightlife: 7.0,
      walkability: 8.0,
      accommodation: 7.5,
      soloDining: 8.0,
      communication: 7.0,
      overall: overall,
    );

List<dest_models.SafetyInsight> get _defaultSafetyInsights => [
      dest_models.SafetyInsight(
        category: 'general',
        description: 'Generally safe for solo travelers',
        severity: 'low',
        tips: ['Stay aware of your surroundings'],
      ),
    ];

dest_models.Activity _activity(String id, String name, {String category = 'cultural'}) =>
    dest_models.Activity(
      id: id,
      name: name,
      category: category,
      soloFriendly: true,
    );

dest_models.Destination _tokyo() => dest_models.Destination(
      id: 'dest-tokyo',
      name: 'Tokyo',
      description: 'Vibrant metropolis blending tradition and modernity',
      latitude: 35.6762,
      longitude: 139.6503,
      countryCode: 'JP',
      region: 'Kanto',
      safetyScore: 9.0,
      safetyInsights: _defaultSafetyInsights,
      soloSuitabilityScore: 8.5,
      soloSuitabilityFactors: _soloFactors(overall: 8.5, safety: 9.0),
      budgetLevel: dest_models.BudgetLevel.moderate,
      activityLevels: [dest_models.ActivityLevel.moderate, dest_models.ActivityLevel.adventurous],
      tags: ['urban', 'cultural', 'food'],
      images: ['https://example.com/tokyo1.jpg'],
      coverImageUrl: 'https://example.com/tokyo_cover.jpg',
      popularActivities: [
        _activity('act-1', 'Visit Senso-ji Temple'),
        _activity('act-2', 'Explore Shibuya Crossing'),
      ],
      bestTimeToVisit: 'March to May',
      averageDailyCost: 120,
      currencyCode: 'JPY',
      language: 'Japanese',
      timezone: 'Asia/Tokyo',
      isHiddenGem: false,
      popularityScore: 0.9,
      createdAt: _now,
      updatedAt: _now,
    );

dest_models.Destination _bali() => dest_models.Destination(
      id: 'dest-bali',
      name: 'Bali',
      description: 'Tropical paradise with rich culture and stunning landscapes',
      latitude: -8.3405,
      longitude: 115.092,
      countryCode: 'ID',
      region: 'Bali',
      safetyScore: 7.5,
      safetyInsights: _defaultSafetyInsights,
      soloSuitabilityScore: 9.0,
      soloSuitabilityFactors: _soloFactors(overall: 9.0, safety: 7.5),
      budgetLevel: dest_models.BudgetLevel.budget,
      activityLevels: [dest_models.ActivityLevel.relaxed, dest_models.ActivityLevel.moderate],
      tags: ['beach', 'nature', 'wellness'],
      images: ['https://example.com/bali1.jpg'],
      coverImageUrl: 'https://example.com/bali_cover.jpg',
      popularActivities: [
        _activity('act-3', 'Ubud Rice Terraces', category: 'nature'),
      ],
      bestTimeToVisit: 'April to October',
      averageDailyCost: 45,
      currencyCode: 'IDR',
      language: 'Indonesian',
      timezone: 'Asia/Makassar',
      isHiddenGem: false,
      popularityScore: 0.85,
      createdAt: _now,
      updatedAt: _now,
    );

dest_models.Destination _kyoto() => dest_models.Destination(
      id: 'dest-kyoto',
      name: 'Kyoto',
      description: 'Ancient capital with serene temples and gardens',
      latitude: 35.0116,
      longitude: 135.7681,
      countryCode: 'JP',
      region: 'Kansai',
      safetyScore: 9.5,
      safetyInsights: _defaultSafetyInsights,
      soloSuitabilityScore: 8.0,
      soloSuitabilityFactors: _soloFactors(overall: 8.0, safety: 9.5),
      budgetLevel: dest_models.BudgetLevel.moderate,
      activityLevels: [dest_models.ActivityLevel.relaxed, dest_models.ActivityLevel.moderate],
      tags: ['cultural', 'temple', 'historic'],
      images: ['https://example.com/kyoto1.jpg'],
      coverImageUrl: 'https://example.com/kyoto_cover.jpg',
      popularActivities: [
        _activity('act-4', 'Fushimi Inari Shrine'),
      ],
      bestTimeToVisit: 'March to May',
      averageDailyCost: 100,
      currencyCode: 'JPY',
      language: 'Japanese',
      timezone: 'Asia/Tokyo',
      isHiddenGem: true,
      popularityScore: 0.75,
      createdAt: _now,
      updatedAt: _now,
    );

// ---------------------------------------------------------------------------
// In-memory mock: DestinationRepository
// ---------------------------------------------------------------------------

class MockDestinationRepository implements DestinationRepository {
  final List<dest_models.Destination> _destinations;
  final Map<String, SavedDestination> _saved = {};

  MockDestinationRepository()
      : _destinations = [_tokyo(), _bali(), _kyoto()];

  // --- DestinationRepository implementation ---

  @override
  Future<List<dest_models.Destination>> searchDestinations(
    DestinationFilter filter,
  ) async {
    await Future.delayed(TestConfig.stepDelay);
    var results = List<dest_models.Destination>.of(_destinations);

    if (filter.searchQuery != null && filter.searchQuery!.isNotEmpty) {
      final q = filter.searchQuery!.toLowerCase();
      results = results
          .where((d) =>
              d.name.toLowerCase().contains(q) ||
              d.description.toLowerCase().contains(q) ||
              d.tags.any((t) => t.toLowerCase().contains(q)))
          .toList();
    }

    if (filter.countryCode != null) {
      results =
          results.where((d) => d.countryCode == filter.countryCode).toList();
    }

    if (filter.budgetLevel != null) {
      results = results
          .where((d) => d.budgetLevel.name == filter.budgetLevel!.name)
          .toList();
    }

    if (filter.hiddenGemsOnly) {
      results = results.where((d) => d.isHiddenGem).toList();
    }

    if (filter.minSafetyScore != null) {
      results =
          results.where((d) => d.safetyScore >= filter.minSafetyScore!).toList();
    }

    if (filter.minSoloSuitabilityScore != null) {
      results = results.where(
          (d) => d.soloSuitabilityScore >= filter.minSoloSuitabilityScore!).toList();
    }

    if (filter.maxDailyCost != null) {
      results = results
          .where((d) =>
              d.averageDailyCost != null &&
              d.averageDailyCost! <= filter.maxDailyCost!)
          .toList();
    }

    if (filter.tags != null && filter.tags!.isNotEmpty) {
      results = results
          .where((d) =>
              filter.tags!.every((tag) => d.tags.contains(tag)))
          .toList();
    }

    return results.skip(filter.offset).take(filter.limit).toList();
  }

  @override
  Future<dest_models.Destination> getDestinationById(String id) async {
    await Future.delayed(TestConfig.stepDelay);
    final dest = _destinations.where((d) => d.id == id).firstOrNull;
    if (dest == null) {
      throw Exception('dest_models.Destination not found: $id');
    }
    return dest;
  }

  @override
  Future<PersonalizedRecommendation> getPersonalizedRecommendations(
    String userId,
  ) async {
    await Future.delayed(TestConfig.stepDelay);
    final recommendations = _destinations.map((d) => RecommendedDestination(
          destination: d,
          matchScore: d.soloSuitabilityScore / 10.0,
          reason: 'Great match based on your preferences',
          matchingFactors: ['solo suitability', ...d.tags.take(2)],
        )).toList();

    return PersonalizedRecommendation(
      id: 'rec-$userId',
      userId: userId,
      recommendations: recommendations,
      source: RecommendationSource.aiGenerated,
      summary: 'Destinations matched to your solo travel style',
      totalCount: recommendations.length,
      generatedAt: _now,
      expiresAt: _later,
    );
  }

  @override
  Future<List<CuratedList>> getCuratedLists() async {
    await Future.delayed(TestConfig.stepDelay);
    return [
      CuratedList(
        id: 'cl-solo-asia',
        name: 'Best Solo Destinations in Asia',
        description: 'Curated list of top Asian destinations for solo travelers',
        type: CuratedListType.popularSolo,
        destinations: [_tokyo(), _bali()],
        coverImageUrl: 'https://example.com/cl-asia.jpg',
        curatorName: 'SoloAdventurer Team',
        destinationCount: 2,
        isFeatured: true,
        tags: ['asia', 'solo'],
        createdAt: _now,
        updatedAt: _now,
      ),
      CuratedList(
        id: 'cl-hidden-gems',
        name: 'Hidden Gems for Solo Travelers',
        description: 'Underrated destinations perfect for solo exploration',
        type: CuratedListType.hiddenGems,
        destinations: [_kyoto()],
        curatorName: 'SoloAdventurer Team',
        destinationCount: 1,
        tags: ['hidden-gems'],
        createdAt: _now,
        updatedAt: _now,
      ),
    ];
  }

  @override
  Future<CuratedList> getCuratedListById(String id) async {
    await Future.delayed(TestConfig.stepDelay);
    final lists = await getCuratedLists();
    final list = lists.where((l) => l.id == id).firstOrNull;
    if (list == null) {
      throw Exception('Curated list not found: $id');
    }
    return list;
  }

  @override
  Future<SavedDestination> saveDestination(SavedDestination saved) async {
    await Future.delayed(TestConfig.stepDelay);
    _saved['${saved.userId}-${saved.destination.id}'] = saved;
    return saved;
  }

  @override
  Future<void> unsaveDestination({
    required String destinationId,
    required String userId,
    SaveType? saveType,
  }) async {
    await Future.delayed(TestConfig.stepDelay);
    final key = '$userId-$destinationId';
    final entry = _saved[key];
    if (entry != null && (saveType == null || entry.saveType == saveType)) {
      _saved.remove(key);
    }
  }

  @override
  Future<List<SavedDestination>> getSavedDestinations(
    String userId, {
    SaveType? saveType,
  }) async {
    await Future.delayed(TestConfig.stepDelay);
    var results = _saved.values.where((s) => s.userId == userId).toList();
    if (saveType != null) {
      results = results.where((s) => s.saveType == saveType).toList();
    }
    return results;
  }
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late MockDestinationRepository destinationRepo;
  late MockAuthRepository authRepo;

  setUp(() {
    destinationRepo = MockDestinationRepository();
    authRepo = MockAuthRepository();
  });

  // =========================================================================
  // Auth helpers
  // =========================================================================

  group('Authentication', () {
    test('sign in with test credentials', () async {
      final user = await authRepo.signInWithEmailAndPassword(
        TestConfig.testEmail,
        TestConfig.testPassword,
      );

      expect(user.email, TestConfig.testEmail);
      expect(user.username, TestConfig.testName);
      expect(user.id, isNotEmpty);

      final authenticated = await authRepo.isAuthenticated();
      expect(authenticated, isTrue);
    });

    test('sign out clears current user', () async {
      await authRepo.signInWithEmailAndPassword(
        TestConfig.testEmail,
        TestConfig.testPassword,
      );
      await authRepo.signOut();

      final current = await authRepo.getCurrentUser();
      expect(current, isNull);

      final authenticated = await authRepo.isAuthenticated();
      expect(authenticated, isFalse);
    });

    test('register creates a new user', () async {
      final email = TestConfig.generateTestEmail();
      final (user, isNew) = await authRepo.register(
        email: email,
        password: 'NewPass123!',
        name: 'New Explorer',
      );

      expect(isNew, isTrue);
      expect(user.email, email);
      expect(user.username, 'New Explorer');
    });

    test('sign in with wrong password throws', () async {
      expect(
        () => authRepo.signInWithEmailAndPassword(
          TestConfig.testEmail,
          'wrong-password',
        ),
        throwsException,
      );
    });
  });

  // =========================================================================
  // Destination Search
  // =========================================================================

  group('Destination Search', () {
    test('search with empty filter returns all destinations', () async {
      final filter = DestinationFilter();
      final results = await destinationRepo.searchDestinations(filter);

      expect(results, hasLength(3));
      expect(results.map((d) => d.name), containsAll(['Tokyo', 'Bali', 'Kyoto']));
    });

    test('search by name query', () async {
      final filter = DestinationFilter(searchQuery: 'Tokyo');
      final results = await destinationRepo.searchDestinations(filter);

      expect(results, hasLength(1));
      expect(results.first.name, 'Tokyo');
    });

    test('search by country code', () async {
      final filter = DestinationFilter(countryCode: 'JP');
      final results = await destinationRepo.searchDestinations(filter);

      expect(results, hasLength(2));
      expect(results.every((d) => d.countryCode == 'JP'), isTrue);
    });

    test('search with budget level filter', () async {
      final filter = DestinationFilter(
        budgetLevel: BudgetLevel.budget,
      );
      final results = await destinationRepo.searchDestinations(filter);

      expect(results, hasLength(1));
      expect(results.first.name, 'Bali');
    });

    test('search hidden gems only', () async {
      final filter = DestinationFilter(hiddenGemsOnly: true);
      final results = await destinationRepo.searchDestinations(filter);

      expect(results, hasLength(1));
      expect(results.first.name, 'Kyoto');
      expect(results.first.isHiddenGem, isTrue);
    });

    test('search with minimum safety score', () async {
      final filter = DestinationFilter(minSafetyScore: 9.0);
      final results = await destinationRepo.searchDestinations(filter);

      expect(results, hasLength(2)); // Tokyo (9.0) and Kyoto (9.5)
      expect(results.every((d) => d.safetyScore >= 9.0), isTrue);
    });

    test('search with minimum solo suitability score', () async {
      final filter = DestinationFilter(minSoloSuitabilityScore: 8.5);
      final results = await destinationRepo.searchDestinations(filter);

      expect(results.every((d) => d.soloSuitabilityScore >= 8.5), isTrue);
    });

    test('search with max daily cost filter', () async {
      final filter = DestinationFilter(maxDailyCost: 50);
      final results = await destinationRepo.searchDestinations(filter);

      expect(results, hasLength(1));
      expect(results.first.name, 'Bali');
    });

    test('search with tag filter', () async {
      final filter = DestinationFilter(tags: ['cultural']);
      final results = await destinationRepo.searchDestinations(filter);

      expect(results, hasLength(2)); // Tokyo and Kyoto
      expect(results.every((d) => d.tags.contains('cultural')), isTrue);
    });

    test('search with pagination', () async {
      final filter = DestinationFilter(offset: 0, limit: 2);
      final page1 = await destinationRepo.searchDestinations(filter);

      expect(page1, hasLength(2));

      final filter2 = DestinationFilter(offset: 2, limit: 2);
      final page2 = await destinationRepo.searchDestinations(filter2);

      expect(page2, hasLength(1));
    });

    test('search combined filters', () async {
      final filter = DestinationFilter(
        countryCode: 'JP',
        minSafetyScore: 9.0,
      );
      final results = await destinationRepo.searchDestinations(filter);

      expect(results, hasLength(2));
      expect(results.every((d) => d.countryCode == 'JP'), isTrue);
      expect(results.every((d) => d.safetyScore >= 9.0), isTrue);
    });

    test('search returns empty for non-matching query', () async {
      final filter = DestinationFilter(searchQuery: 'Antarctica');
      final results = await destinationRepo.searchDestinations(filter);

      expect(results, isEmpty);
    });
  });

  // =========================================================================
  // Destination Detail
  // =========================================================================

  group('Destination Detail', () {
    test('get destination by id', () async {
      final dest = await destinationRepo.getDestinationById('dest-tokyo');

      expect(dest.id, 'dest-tokyo');
      expect(dest.name, 'Tokyo');
      expect(dest.countryCode, 'JP');
      expect(dest.safetyScore, 9.0);
      expect(dest.soloSuitabilityScore, 8.5);
      expect(dest.budgetLevel, dest_models.BudgetLevel.moderate);
      expect(dest.popularActivities, isNotEmpty);
    });

    test('get destination with full details', () async {
      final dest = await destinationRepo.getDestinationById('dest-bali');

      expect(dest.description, isNotEmpty);
      expect(dest.latitude, isNotNull);
      expect(dest.longitude, isNotNull);
      expect(dest.safetyInsights, isNotEmpty);
      expect(dest.soloSuitabilityFactors.overall, greaterThan(0));
      expect(dest.images, isNotEmpty);
      expect(dest.bestTimeToVisit, isNotNull);
      expect(dest.averageDailyCost, isNotNull);
      expect(dest.currencyCode, isNotNull);
      expect(dest.timezone, isNotNull);
    });

    test('get non-existent destination throws', () async {
      expect(
        () => destinationRepo.getDestinationById('non-existent'),
        throwsException,
      );
    });

    test('destination has correct activity levels', () async {
      final tokyo = await destinationRepo.getDestinationById('dest-tokyo');
      expect(tokyo.activityLevels, contains(dest_models.ActivityLevel.moderate));

      final bali = await destinationRepo.getDestinationById('dest-bali');
      expect(bali.activityLevels, contains(dest_models.ActivityLevel.relaxed));
    });
  });

  // =========================================================================
  // Personalized Recommendations
  // =========================================================================

  group('Personalized Recommendations', () {
    test('get recommendations for a user', () async {
      final rec = await destinationRepo.getPersonalizedRecommendations(
        'test-user-1',
      );

      expect(rec.userId, 'test-user-1');
      expect(rec.recommendations, isNotEmpty);
      expect(rec.source, RecommendationSource.aiGenerated);
      expect(rec.summary, isNotNull);
      expect(rec.totalCount, greaterThan(0));
    });

    test('recommendations contain valid destinations', () async {
      final rec = await destinationRepo.getPersonalizedRecommendations(
        'test-user-1',
      );

      for (final r in rec.recommendations) {
        expect(r.destination, isNotNull);
        expect(r.matchScore, greaterThanOrEqualTo(0.0));
        expect(r.matchScore, lessThanOrEqualTo(1.0));
        expect(r.reason, isNotEmpty);
        expect(r.matchingFactors, isNotEmpty);
      }
    });

    test('recommendations have valid timestamps', () async {
      final rec = await destinationRepo.getPersonalizedRecommendations(
        'test-user-1',
      );

      expect(rec.generatedAt, isNotNull);
      expect(rec.expiresAt, isNotNull);
      expect(rec.expiresAt.isAfter(rec.generatedAt), isTrue);
    });
  });

  // =========================================================================
  // Curated Lists
  // =========================================================================

  group('Curated Lists', () {
    test('get all curated lists', () async {
      final lists = await destinationRepo.getCuratedLists();

      expect(lists, hasLength(2));
      expect(lists.map((l) => l.name),
          contains('Best Solo Destinations in Asia'));
    });

    test('curated lists have required fields', () async {
      final lists = await destinationRepo.getCuratedLists();

      for (final list in lists) {
        expect(list.id, isNotEmpty);
        expect(list.name, isNotEmpty);
        expect(list.description, isNotEmpty);
        expect(list.type, isNotNull);
        expect(list.destinations, isNotNull);
        expect(list.destinationCount, greaterThanOrEqualTo(0));
        expect(list.createdAt, isNotNull);
        expect(list.updatedAt, isNotNull);
      }
    });

    test('get curated list by id', () async {
      final list = await destinationRepo.getCuratedListById('cl-solo-asia');

      expect(list.id, 'cl-solo-asia');
      expect(list.name, 'Best Solo Destinations in Asia');
      expect(list.type, CuratedListType.popularSolo);
      expect(list.destinations, hasLength(2));
      expect(list.isFeatured, isTrue);
    });

    test('get non-existent curated list throws', () async {
      expect(
        () => destinationRepo.getCuratedListById('non-existent'),
        throwsException,
      );
    });

    test('curated list contains destinations', () async {
      final list = await destinationRepo.getCuratedListById('cl-solo-asia');

      expect(list.destinations, isNotEmpty);
      expect(list.destinations.map((d) => d.name), containsAll(['Tokyo', 'Bali']));
    });

    test('hidden gems curated list', () async {
      final list = await destinationRepo.getCuratedListById('cl-hidden-gems');

      expect(list.type, CuratedListType.hiddenGems);
      expect(list.destinations, hasLength(1));
      expect(list.destinations.first.isHiddenGem, isTrue);
    });
  });

  // =========================================================================
  // Save / Unsave Destinations
  // =========================================================================

  group('Save and Unsave Destinations', () {
    test('save a destination to wishlist', () async {
      final dest = await destinationRepo.getDestinationById('dest-tokyo');
      final saved = SavedDestination(
        id: 'saved-1',
        userId: 'test-user-1',
        destination: dest,
        saveType: SaveType.wishlist,
        createdAt: _now,
        updatedAt: _now,
      );

      final result = await destinationRepo.saveDestination(saved);
      expect(result.id, 'saved-1');
      expect(result.saveType, SaveType.wishlist);
      expect(result.destination.id, 'dest-tokyo');
    });

    test('save a destination to a trip', () async {
      final dest = await destinationRepo.getDestinationById('dest-bali');
      final saved = SavedDestination(
        id: 'saved-2',
        userId: 'test-user-1',
        destination: dest,
        saveType: SaveType.trip,
        tripId: 'trip-42',
        notes: 'Want to visit rice terraces',
        createdAt: _now,
        updatedAt: _now,
      );

      final result = await destinationRepo.saveDestination(saved);
      expect(result.saveType, SaveType.trip);
      expect(result.tripId, 'trip-42');
      expect(result.notes, 'Want to visit rice terraces');
    });

    test('get saved destinations for a user', () async {
      // Save two destinations
      final tokyo = await destinationRepo.getDestinationById('dest-tokyo');
      final bali = await destinationRepo.getDestinationById('dest-bali');

      await destinationRepo.saveDestination(SavedDestination(
        id: 'saved-3',
        userId: 'test-user-1',
        destination: tokyo,
        saveType: SaveType.wishlist,
        createdAt: _now,
        updatedAt: _now,
      ));

      await destinationRepo.saveDestination(SavedDestination(
        id: 'saved-4',
        userId: 'test-user-1',
        destination: bali,
        saveType: SaveType.trip,
        tripId: 'trip-1',
        createdAt: _now,
        updatedAt: _now,
      ));

      final saved = await destinationRepo.getSavedDestinations('test-user-1');
      expect(saved, hasLength(2));
    });

    test('get saved destinations filtered by save type', () async {
      // Fresh repo per test — seed data first
      final tokyo = await destinationRepo.getDestinationById('dest-tokyo');
      await destinationRepo.saveDestination(SavedDestination(
        id: 'saved-w1',
        userId: 'user-filter',
        destination: tokyo,
        saveType: SaveType.wishlist,
        createdAt: _now,
        updatedAt: _now,
      ));
      await destinationRepo.saveDestination(SavedDestination(
        id: 'saved-t1',
        userId: 'user-filter',
        destination: tokyo,
        saveType: SaveType.trip,
        tripId: 'trip-x',
        createdAt: _now,
        updatedAt: _now,
      ));

      final wishlists = await destinationRepo.getSavedDestinations(
        'user-filter',
        saveType: SaveType.wishlist,
      );
      expect(wishlists, hasLength(1));
      expect(wishlists.first.saveType, SaveType.wishlist);

      final trips = await destinationRepo.getSavedDestinations(
        'user-filter',
        saveType: SaveType.trip,
      );
      expect(trips, hasLength(1));
      expect(trips.first.saveType, SaveType.trip);
    });

    test('unsave a destination', () async {
      final tokyo = await destinationRepo.getDestinationById('dest-tokyo');
      await destinationRepo.saveDestination(SavedDestination(
        id: 'saved-unsave',
        userId: 'user-unsave',
        destination: tokyo,
        saveType: SaveType.wishlist,
        createdAt: _now,
        updatedAt: _now,
      ));

      var saved = await destinationRepo.getSavedDestinations('user-unsave');
      expect(saved, hasLength(1));

      await destinationRepo.unsaveDestination(
        destinationId: 'dest-tokyo',
        userId: 'user-unsave',
      );

      saved = await destinationRepo.getSavedDestinations('user-unsave');
      expect(saved, isEmpty);
    });

    test('unsave with save type filter', () async {
      final tokyo = await destinationRepo.getDestinationById('dest-tokyo');
      await destinationRepo.saveDestination(SavedDestination(
        id: 'saved-st1',
        userId: 'user-st',
        destination: tokyo,
        saveType: SaveType.wishlist,
        createdAt: _now,
        updatedAt: _now,
      ));
      await destinationRepo.saveDestination(SavedDestination(
        id: 'saved-st2',
        userId: 'user-st',
        destination: tokyo,
        saveType: SaveType.trip,
        tripId: 'trip-z',
        createdAt: _now,
        updatedAt: _now,
      ));

      // Unsave only the wishlist entry
      await destinationRepo.unsaveDestination(
        destinationId: 'dest-tokyo',
        userId: 'user-st',
        saveType: SaveType.wishlist,
      );

      final remaining = await destinationRepo.getSavedDestinations('user-st');
      expect(remaining, hasLength(1));
      expect(remaining.first.saveType, SaveType.trip);
    });

    test('saved destination has notes', () async {
      final kyoto = await destinationRepo.getDestinationById('dest-kyoto');
      final saved = SavedDestination(
        id: 'saved-notes',
        userId: 'test-user-1',
        destination: kyoto,
        saveType: SaveType.wishlist,
        notes: 'Must visit during cherry blossom season',
        createdAt: _now,
        updatedAt: _now,
      );

      final result = await destinationRepo.saveDestination(saved);
      expect(result.hasNotes, isTrue);
      expect(result.notes, contains('cherry blossom'));
    });
  });

  // =========================================================================
  // End-to-End Flow
  // =========================================================================

  group('End-to-End Discovery Flow', () {
    test('complete discovery workflow', () async {
      // 1. Sign in
      final user = await authRepo.signInWithEmailAndPassword(
        TestConfig.testEmail,
        TestConfig.testPassword,
      );
      expect(user, isNotNull);

      // 2. Search for destinations in Japan
      final searchResults = await destinationRepo.searchDestinations(
        DestinationFilter(countryCode: 'JP'),
      );
      expect(searchResults, isNotEmpty);

      // 3. Pick a destination and view details
      final dest = await destinationRepo.getDestinationById(searchResults.first.id);
      expect(dest.name, isNotEmpty);
      expect(dest.safetyScore, greaterThan(0));

      // 4. Get personalized recommendations
      final rec = await destinationRepo.getPersonalizedRecommendations(user.id);
      expect(rec.recommendations, isNotEmpty);

      // 5. Browse curated lists
      final lists = await destinationRepo.getCuratedLists();
      expect(lists, isNotEmpty);

      // 6. Save a destination
      await destinationRepo.saveDestination(SavedDestination(
        id: 'saved-e2e',
        userId: user.id,
        destination: dest,
        saveType: SaveType.wishlist,
        createdAt: _now,
        updatedAt: _now,
      ));

      final saved = await destinationRepo.getSavedDestinations(user.id);
      expect(saved, hasLength(1));

      // 7. Unsave
      await destinationRepo.unsaveDestination(
        destinationId: dest.id,
        userId: user.id,
      );
      final afterUnsave = await destinationRepo.getSavedDestinations(user.id);
      expect(afterUnsave, isEmpty);

      // 8. Sign out
      await authRepo.signOut();
      expect(await authRepo.isAuthenticated(), isFalse);
    });
  });
}
