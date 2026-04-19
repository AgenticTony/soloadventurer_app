import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:soloadventurer/features/matching/domain/entities/matching_trip.dart';
import 'package:soloadventurer/features/matching/domain/entities/connection.dart';
import 'package:soloadventurer/features/matching/domain/entities/activity.dart';
import 'package:soloadventurer/features/matching/domain/entities/message.dart';
import 'package:soloadventurer/features/matching/domain/entities/chat.dart';
import 'package:soloadventurer/features/matching/domain/repositories/matching_repository.dart';
import 'test_config.dart';

// Test constants
const testUserId = 'user-123';
const testVerifiedWomanUserId = 'verified-woman-123';
const testUnverifiedUserId = 'unverified-user-123';
const testMaleUserId = 'male-user-123';
const testVerifiedWoman2UserId = 'verified-woman2-456';

/// User verification status for testing
enum VerificationStatus {
  unverified,
  verifiedWoman,
  verifiedMan,
  pending,
}

/// Mock user profile for testing
class MockUserProfile {
  final String id;
  final String displayName;
  final String gender;
  final VerificationStatus verificationStatus;
  final bool hasPremium;
  final bool womenOnlyModeEnabled;

  MockUserProfile({
    required this.id,
    required this.displayName,
    required this.gender,
    required this.verificationStatus,
    this.hasPremium = false,
    this.womenOnlyModeEnabled = false,
  });

  MockUserProfile copyWith({
    String? id,
    String? displayName,
    String? gender,
    VerificationStatus? verificationStatus,
    bool? hasPremium,
    bool? womenOnlyModeEnabled,
  }) {
    return MockUserProfile(
      id: id ?? this.id,
      displayName: displayName ?? this.displayName,
      gender: gender ?? this.gender,
      verificationStatus: verificationStatus ?? this.verificationStatus,
      hasPremium: hasPremium ?? this.hasPremium,
      womenOnlyModeEnabled: womenOnlyModeEnabled ?? this.womenOnlyModeEnabled,
    );
  }

  bool get canEnableWomenOnlyMode =>
      verificationStatus == VerificationStatus.verifiedWoman && hasPremium;
}

/// Mock verification service for testing
class MockVerificationService {
  final Map<String, VerificationStatus> _verificationStatuses = {};
  final Map<String, String> _userGenders = {};

  void setUserVerification(String userId, VerificationStatus status) {
    _verificationStatuses[userId] = status;
  }

  void setUserGender(String userId, String gender) {
    _userGenders[userId] = gender;
  }

  Future<VerificationStatus> getVerificationStatus(String userId) async {
    return _verificationStatuses[userId] ?? VerificationStatus.unverified;
  }

  Future<String?> getUserGender(String userId) async {
    return _userGenders[userId];
  }

  Future<bool> isVerifiedWoman(String userId) async {
    final status = await getVerificationStatus(userId);
    final gender = await getUserGender(userId);
    return status == VerificationStatus.verifiedWoman && gender == 'female';
  }

  void clearAll() {
    _verificationStatuses.clear();
    _userGenders.clear();
  }
}

/// Mock women-only repository for testing
class MockWomenOnlyRepository implements MatchingRepository {
  final MockVerificationService _verificationService;
  final Map<String, MockUserProfile> _profiles = {};
  final List<MatchingTrip> _trips = [];
  final List<Connection> _connections = [];
  final List<Chat> _chats = [];
  final List<Message> _messages = [];
  bool _isOnline = true;

  MockWomenOnlyRepository(this._verificationService);

  void setOnline(bool isOnline) => _isOnline = isOnline;

  void addProfile(MockUserProfile profile) {
    _profiles[profile.id] = profile;
    _verificationService.setUserVerification(
      profile.id,
      profile.verificationStatus,
    );
    _verificationService.setUserGender(profile.id, profile.gender);
  }

  MockUserProfile? getProfile(String userId) => _profiles[userId];

  Future<bool> _canEnableWomenOnlyMode(String userId) async {
    final profile = _profiles[userId];
    if (profile == null) return false;
    return await _verificationService.isVerifiedWoman(userId) &&
        profile.hasPremium;
  }

  // Women-Only Mode Methods
  @override
  Future<void> enableWomenOnlyMode() async {
    final profile = _profiles[testUserId];
    if (profile == null) {
      throw Exception('User not found');
    }

    final canEnable = await _canEnableWomenOnlyMode(testUserId);
    if (!canEnable) {
      throw Exception(
          'User not eligible for women-only mode. Verification and premium required.');
    }

    _profiles[testUserId] = profile.copyWith(womenOnlyModeEnabled: true);
  }

  @override
  Future<void> disableWomenOnlyMode() async {
    final profile = _profiles[testUserId];
    if (profile == null) return;

    _profiles[testUserId] = profile.copyWith(womenOnlyModeEnabled: false);
  }

  @override
  Future<bool> isWomenOnlyModeEnabled() async {
    final profile = _profiles[testUserId];
    return profile?.womenOnlyModeEnabled ?? false;
  }

  @override
  Future<bool> isVerifiedForWomenOnly() async {
    return _canEnableWomenOnlyMode(testUserId);
  }

  @override
  Future<String?> getUserGender() async {
    final profile = _profiles[testUserId];
    return profile?.gender;
  }

  // Visibility filtering for women-only mode
  Future<List<Connection>> getFilteredMatches(String userId) async {
    final userProfile = _profiles[userId];
    if (userProfile == null) return [];

    final allConnections = await findMatches();

    // If user has women-only mode enabled, filter to only show verified women
    if (userProfile.womenOnlyModeEnabled) {
      return allConnections.where((connection) {
        final otherUserId = connection.userAId == userId
            ? connection.userBId
            : connection.userAId;
        final otherProfile = _profiles[otherUserId];

        return otherProfile != null &&
            otherProfile.gender == 'female' &&
            otherProfile.verificationStatus ==
                VerificationStatus.verifiedWoman;
      }).toList();
    }

    // If another user has women-only mode enabled, don't show to non-verified-women
    return allConnections.where((connection) {
      final otherUserId = connection.userAId == userId
          ? connection.userBId
          : connection.userAId;
      final otherProfile = _profiles[otherUserId];

      if (otherProfile?.womenOnlyModeEnabled == true) {
        return userProfile.gender == 'female' &&
            userProfile.verificationStatus ==
                VerificationStatus.verifiedWoman;
      }

      return true;
    }).toList();
  }

  // MatchingRepository implementation
  @override
  Future<MatchingTrip> createTrip({
    required String destinationName,
    required double latitude,
    required double longitude,
    required DateTime startDate,
    required DateTime endDate,
    LocationPrecision locationPrecision = LocationPrecision.city,
  }) async {
    final trip = MatchingTrip(
      id: 'trip-${DateTime.now().millisecondsSinceEpoch}',
      userId: testUserId,
      destinationName: destinationName,
      latitude: latitude,
      longitude: longitude,
      locationPrecision: locationPrecision,
      startDate: startDate,
      endDate: endDate,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    _trips.add(trip);
    return trip;
  }

  @override
  Future<List<MatchingTrip>> getUserTrips() async => _trips;

  @override
  Future<MatchingTrip?> getTrip(String tripId) async =>
      _trips.where((t) => t.id == tripId).firstOrNull;

  @override
  Future<MatchingTrip> updateTrip(MatchingTrip trip) async {
    final index = _trips.indexWhere((t) => t.id == trip.id);
    if (index >= 0) {
      _trips[index] = trip;
    } else {
      _trips.add(trip);
    }
    return trip;
  }

  @override
  Future<void> deleteTrip(String tripId) async {
    _trips.removeWhere((t) => t.id == tripId);
  }

  @override
  Future<void> archiveExpiredTrips() async {
    _trips.removeWhere(
      (t) => t.endDate.isBefore(DateTime.now()) && t.isActive == false,
    );
  }

  @override
  Future<List<Connection>> findMatches() async {
    return _connections.where((c) => c.isActive).toList();
  }

  @override
  Future<List<Connection>> getConnections() async => _connections;

  @override
  Future<Connection?> getConnection(String connectionId) async =>
      _connections.where((c) => c.id == connectionId).firstOrNull;

  @override
  Future<void> hideConnection(String connectionId) async {
    final index = _connections.indexWhere((c) => c.id == connectionId);
    if (index >= 0) {
      _connections[index] =
          _connections[index].copyWith(isActive: false);
    }
  }

  @override
  Future<int> getNearbyTravelersCount() async {
    return _connections.where((c) => c.isActive).length;
  }

  @override
  Future<List<Activity>> getActivities() async {
    return [
      Activity(
        id: 'act-1',
        name: 'Hiking',
        category: 'outdoor',
        icon: 'hiking',
        createdAt: DateTime.now(),
      ),
      Activity(
        id: 'act-2',
        name: 'Sightseeing',
        category: 'cultural',
        icon: 'camera',
        createdAt: DateTime.now(),
      ),
      Activity(
        id: 'act-3',
        name: 'Dining',
        category: 'food',
        icon: 'restaurant',
        createdAt: DateTime.now(),
      ),
    ];
  }

  @override
  Future<List<Activity>> getUserActivities() async {
    final acts = await getActivities();
    return acts.take(2).toList();
  }

  @override
  Future<void> setUserActivities(List<String> activityIds) async {}

  @override
  Future<void> addUserActivity(String activityId) async {}

  @override
  Future<void> removeUserActivity(String activityId) async {}

  @override
  Future<void> syncData() async {}

  @override
  Future<bool> hasPendingChanges() async => false;

  @override
  Future<DateTime?> getLastSyncTimestamp() async => DateTime.now();

  @override
  Future<String> sendMessage({
    required String chatId,
    required String recipientId,
    required String content,
  }) async {
    final message = Message(
      id: 'msg-${DateTime.now().millisecondsSinceEpoch}',
      chatId: chatId,
      senderId: testUserId,
      content: content,
      status: MessageStatus.sent,
      createdAt: DateTime.now(),
    );
    _messages.add(message);
    return message.id;
  }

  @override
  Future<List<Chat>> getChats() async {
    return [
      Chat(
        id: 'chat-1',
        connectionId: 'conn-1',
        currentUserId: testUserId,
        otherUserId: 'user-2',
        otherUserName: 'Other User',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    ];
  }

  @override
  Future<Chat> getOrCreateChat(String connectionId) async {
    final existingChat =
        _chats.where((c) => c.connectionId == connectionId).firstOrNull;
    if (existingChat != null) {
      return existingChat;
    }

    final chat = Chat(
      id: 'chat-${DateTime.now().millisecondsSinceEpoch}',
      connectionId: connectionId,
      currentUserId: testUserId,
      otherUserId: 'other-user',
      otherUserName: 'Other User',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    _chats.add(chat);
    return chat;
  }

  @override
  Future<List<Message>> getMessages(String chatId) async {
    return _messages.where((m) => m.chatId == chatId).toList();
  }

  @override
  Stream<List<Message>> watchMessages(String chatId) {
    return Stream.value(_messages.where((m) => m.chatId == chatId).toList());
  }

  @override
  Future<void> markMessagesAsRead(String chatId) async {}

  @override
  Future<int> getPendingMessagesCount() async => 0;

  void addMockConnection(Connection connection) {
    _connections.add(connection);
  }

  void clearAll() {
    _trips.clear();
    _connections.clear();
    _chats.clear();
    _messages.clear();
  }
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late ProviderContainer container;
  late MockVerificationService mockVerificationService;
  late MockWomenOnlyRepository mockWomenOnlyRepository;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    mockVerificationService = MockVerificationService();
    mockWomenOnlyRepository =
        MockWomenOnlyRepository(mockVerificationService);

    container = ProviderContainer();
  });

  tearDown(() async {
    container.dispose();
    mockVerificationService.clearAll();
    mockWomenOnlyRepository.clearAll();
  });

  group('Women-Only Mode Tests', () {
    group('Unverified user tests', () {
      test('Unverified user cannot enable women-only mode', () async {
        mockWomenOnlyRepository.addProfile(MockUserProfile(
          id: testUnverifiedUserId,
          displayName: 'Unverified User',
          gender: 'female',
          verificationStatus: VerificationStatus.unverified,
          hasPremium: true,
        ));

        expect(
          () => mockWomenOnlyRepository.enableWomenOnlyMode(),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('Verified woman tests', () {
      test('Verified woman with premium can enable women-only mode', () async {
        mockWomenOnlyRepository.addProfile(MockUserProfile(
          id: testVerifiedWomanUserId,
          displayName: 'Verified Woman',
          gender: 'female',
          verificationStatus: VerificationStatus.verifiedWoman,
          hasPremium: true,
        ));

        expect(
          await mockWomenOnlyRepository.isWomenOnlyModeEnabled(),
          isFalse,
        );

        await mockWomenOnlyRepository.enableWomenOnlyMode();
        expect(
          await mockWomenOnlyRepository.isWomenOnlyModeEnabled(),
          isTrue,
        );

        expect(
          await mockWomenOnlyRepository.isVerifiedForWomenOnly(),
          isTrue,
        );
      });

      test('Verified woman without premium cannot enable women-only mode',
          () async {
        mockWomenOnlyRepository.addProfile(MockUserProfile(
          id: 'verified-no-premium',
          displayName: 'Verified Woman No Premium',
          gender: 'female',
          verificationStatus: VerificationStatus.verifiedWoman,
          hasPremium: false,
        ));

        expect(
          () => mockWomenOnlyRepository.enableWomenOnlyMode(),
          throwsA(isA<Exception>()),
        );
      });

      test('Verified woman can disable women-only mode', () async {
        mockWomenOnlyRepository.addProfile(MockUserProfile(
          id: testVerifiedWoman2UserId,
          displayName: 'Verified Woman 2',
          gender: 'female',
          verificationStatus: VerificationStatus.verifiedWoman,
          hasPremium: true,
        ));

        await mockWomenOnlyRepository.enableWomenOnlyMode();
        expect(
          await mockWomenOnlyRepository.isWomenOnlyModeEnabled(),
          isTrue,
        );

        await mockWomenOnlyRepository.disableWomenOnlyMode();
        expect(
          await mockWomenOnlyRepository.isWomenOnlyModeEnabled(),
          isFalse,
        );
      });
    });

    group('Visibility filtering tests', () {
      test("Women-only users don't appear to men", () async {
        mockWomenOnlyRepository.addProfile(MockUserProfile(
          id: testVerifiedWomanUserId,
          displayName: 'Verified Woman',
          gender: 'female',
          verificationStatus: VerificationStatus.verifiedWoman,
          hasPremium: true,
          womenOnlyModeEnabled: true,
        ));

        mockWomenOnlyRepository.addProfile(MockUserProfile(
          id: testMaleUserId,
          displayName: 'Male User',
          gender: 'male',
          verificationStatus: VerificationStatus.verifiedMan,
          hasPremium: true,
        ));

        mockWomenOnlyRepository.addMockConnection(Connection(
          id: 'conn-1',
          userAId: testVerifiedWomanUserId,
          userBId: testMaleUserId,
          status: ConnectionStatus.pending,
          overlapStartDate: DateTime.now(),
          overlapEndDate: DateTime.now().add(const Duration(days: 5)),
          overlapDays: 5,
          isActive: true,
          createdAt: DateTime.now(),
          matchedUserProfile: MatchedUserProfile(
            id: testMaleUserId,
            firstName: 'Male User',
            ageRange: '25-30',
            homeCountry: 'US',
            gender: 'male',
          ),
        ));

        final matches = await mockWomenOnlyRepository
            .getFilteredMatches(testVerifiedWomanUserId);

        expect(matches, isEmpty);
      });

      test('Women-only users only see verified women', () async {
        mockWomenOnlyRepository.addProfile(MockUserProfile(
          id: testVerifiedWomanUserId,
          displayName: 'Verified Woman',
          gender: 'female',
          verificationStatus: VerificationStatus.verifiedWoman,
          hasPremium: true,
          womenOnlyModeEnabled: true,
        ));

        mockWomenOnlyRepository.addProfile(MockUserProfile(
          id: testVerifiedWoman2UserId,
          displayName: 'Verified Woman 2',
          gender: 'female',
          verificationStatus: VerificationStatus.verifiedWoman,
          hasPremium: false,
        ));

        mockWomenOnlyRepository.addProfile(MockUserProfile(
          id: 'unverified-woman',
          displayName: 'Unverified Woman',
          gender: 'female',
          verificationStatus: VerificationStatus.unverified,
          hasPremium: true,
        ));

        mockWomenOnlyRepository.addMockConnection(Connection(
          id: 'conn-2',
          userAId: testVerifiedWomanUserId,
          userBId: testVerifiedWoman2UserId,
          status: ConnectionStatus.pending,
          overlapStartDate: DateTime.now(),
          overlapEndDate: DateTime.now().add(const Duration(days: 5)),
          overlapDays: 5,
          isActive: true,
          createdAt: DateTime.now(),
          matchedUserProfile: MatchedUserProfile(
            id: testVerifiedWoman2UserId,
            firstName: 'Verified Woman 2',
            ageRange: '25-30',
            homeCountry: 'US',
            gender: 'female',
          ),
        ));

        mockWomenOnlyRepository.addMockConnection(Connection(
          id: 'conn-3',
          userAId: testVerifiedWomanUserId,
          userBId: 'unverified-woman',
          status: ConnectionStatus.pending,
          overlapStartDate: DateTime.now(),
          overlapEndDate: DateTime.now().add(const Duration(days: 3)),
          overlapDays: 3,
          isActive: true,
          createdAt: DateTime.now(),
          matchedUserProfile: MatchedUserProfile(
            id: 'unverified-woman',
            firstName: 'Unverified Woman',
            ageRange: '25-30',
            homeCountry: 'US',
            gender: 'female',
          ),
        ));

        final matches = await mockWomenOnlyRepository
            .getFilteredMatches(testVerifiedWomanUserId);

        expect(matches.length, equals(1));
        expect(
            matches.first.matchedUserProfile?.id, equals(testVerifiedWoman2UserId));
      });

      test('Non-verified woman cannot see women-only users', () async {
        mockWomenOnlyRepository.addProfile(MockUserProfile(
          id: 'unverified-viewer',
          displayName: 'Unverified Viewer',
          gender: 'female',
          verificationStatus: VerificationStatus.unverified,
          hasPremium: true,
        ));

        mockWomenOnlyRepository.addProfile(MockUserProfile(
          id: 'wo-user',
          displayName: 'Women Only User',
          gender: 'female',
          verificationStatus: VerificationStatus.verifiedWoman,
          hasPremium: true,
          womenOnlyModeEnabled: true,
        ));

        mockWomenOnlyRepository.addMockConnection(Connection(
          id: 'conn-4',
          userAId: 'unverified-viewer',
          userBId: 'wo-user',
          status: ConnectionStatus.pending,
          overlapStartDate: DateTime.now(),
          overlapEndDate: DateTime.now().add(const Duration(days: 5)),
          overlapDays: 5,
          isActive: true,
          createdAt: DateTime.now(),
          matchedUserProfile: MatchedUserProfile(
            id: 'wo-user',
            firstName: 'Women Only User',
            ageRange: '25-30',
            homeCountry: 'US',
            gender: 'female',
          ),
        ));

        final matches = await mockWomenOnlyRepository
            .getFilteredMatches('unverified-viewer');

        expect(matches, isEmpty);
      });

      test('Verified man cannot see women-only users', () async {
        mockWomenOnlyRepository.addProfile(MockUserProfile(
          id: 'verified-man-viewer',
          displayName: 'Verified Man',
          gender: 'male',
          verificationStatus: VerificationStatus.verifiedMan,
          hasPremium: true,
        ));

        mockWomenOnlyRepository.addProfile(MockUserProfile(
          id: 'wo-user-2',
          displayName: 'Women Only User 2',
          gender: 'female',
          verificationStatus: VerificationStatus.verifiedWoman,
          hasPremium: true,
          womenOnlyModeEnabled: true,
        ));

        mockWomenOnlyRepository.addMockConnection(Connection(
          id: 'conn-5',
          userAId: 'verified-man-viewer',
          userBId: 'wo-user-2',
          status: ConnectionStatus.pending,
          overlapStartDate: DateTime.now(),
          overlapEndDate: DateTime.now().add(const Duration(days: 5)),
          overlapDays: 5,
          isActive: true,
          createdAt: DateTime.now(),
          matchedUserProfile: MatchedUserProfile(
            id: 'wo-user-2',
            firstName: 'Women Only User 2',
            ageRange: '25-30',
            homeCountry: 'US',
            gender: 'female',
          ),
        ));

        final matches = await mockWomenOnlyRepository
            .getFilteredMatches('verified-man-viewer');

        expect(matches, isEmpty);
      });
    });
  });
}
