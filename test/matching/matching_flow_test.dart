import 'package:flutter_test/flutter_test.dart';
import 'package:soloadventurer/features/matching/domain/entities/matching_trip.dart';
import 'package:soloadventurer/features/matching/domain/entities/connection.dart';
import 'package:soloadventurer/features/matching/domain/entities/activity.dart';
import 'package:soloadventurer/features/matching/domain/entities/message.dart';
import 'package:soloadventurer/features/matching/domain/entities/chat.dart';
import 'package:soloadventurer/features/matching/domain/repositories/matching_repository.dart';
import 'package:soloadventurer/features/matching/data/models/message_model.dart';

// Test constants
const testUserId = 'user-123';
const testContactId = 'contact-123';
const testTripId = 'trip-123';
const testChatId = 'chat-123';
const testMessageId = 'msg-123';

/// Mock implementation of matching repository for testing
class MockMatchingRepository implements MatchingRepository {
  final List<MatchingTrip> _trips = [];
  final List<Connection> _connections = [];
  final List<Message> _messages = [];
  final List<Activity> _activities = [];
  final List<Chat> _chats = [];
  bool _isOnline = true;
  String? _currentUserId;
  bool _womenOnlyModeEnabled = false;
  bool _isVerifiedForWomenOnly = false;

  void setOnline(bool isOnline) => _isOnline = isOnline;
  void setCurrentUserId(String? userId) => _currentUserId = userId;

  void setWomenOnlyMode(bool enabled) => _womenOnlyModeEnabled = enabled;
  void setVerifiedForWomenOnly(bool verified) =>
      _isVerifiedForWomenOnly = verified;

  // Trip Management
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
      userId: _currentUserId ?? 'test-user',
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
  Future<List<MatchingTrip>> getUserTrips() async {
    return List.from(_trips);
  }

  @override
  Future<MatchingTrip?> getTrip(String tripId) async {
    return _trips.where((t) => t.id == tripId).firstOrNull;
  }

  @override
  Future<MatchingTrip> updateTrip(MatchingTrip trip) async {
    final index = _trips.indexWhere((t) => t.id == trip.id);
    if (index >= 0) {
      _trips[index] = trip;
    }
    return trip;
  }

  @override
  Future<void> deleteTrip(String tripId) async {
    _trips.removeWhere((t) => t.id == tripId);
  }

  @override
  Future<void> archiveExpiredTrips() async {
    _trips.removeWhere((t) => t.endDate.isBefore(DateTime.now()));
  }

  // Matching / Connections
  @override
  Future<List<Connection>> findMatches() async {
    return _connections.where((c) => c.isActive).toList();
  }

  @override
  Future<List<Connection>> getConnections() async {
    return _connections;
  }

  @override
  Future<Connection?> getConnection(String connectionId) async {
    return _connections.where((c) => c.id == connectionId).firstOrNull;
  }

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

  // Activities
  @override
  Future<List<Activity>> getActivities() async {
    if (_activities.isEmpty) {
      _activities.addAll([
        Activity(
          id: 'act-1',
          name: 'Hiking',
          icon: 'hiking',
          category: 'outdoor',
          createdAt: DateTime.now(),
        ),
        Activity(
          id: 'act-2',
          name: 'Sightseeing',
          icon: 'camera',
          category: 'cultural',
          createdAt: DateTime.now(),
        ),
        Activity(
          id: 'act-3',
          name: 'Dining',
          icon: 'restaurant',
          category: 'food',
          createdAt: DateTime.now(),
        ),
      ]);
    }
    return _activities;
  }

  @override
  Future<List<Activity>> getUserActivities() async {
    // Ensure activities are populated before taking subset
    await getActivities();
    return _activities.take(2).toList();
  }

  @override
  Future<void> setUserActivities(List<String> activityIds) async {
    // Mock implementation
  }

  @override
  Future<void> addUserActivity(String activityId) async {
    // Mock implementation
  }

  @override
  Future<void> removeUserActivity(String activityId) async {
    // Mock implementation
  }

  // Offline Support
  @override
  Future<void> syncData() async {
    // Mock implementation
  }

  @override
  Future<bool> hasPendingChanges() async => false;

  @override
  Future<DateTime?> getLastSyncTimestamp() async {
    return DateTime.now();
  }

  // Messaging (F-004)
  @override
  Future<String> sendMessage({
    required String chatId,
    required String recipientId,
    required String content,
  }) async {
    final message = MessageModel(
      id: 'msg-${DateTime.now().millisecondsSinceEpoch}',
      chatId: chatId,
      senderId: _currentUserId ?? 'test-user',
      content: content,
      status: MessageStatus.sent,
      createdAt: DateTime.now(),
    );

    _messages.add(message);
    return message.id;
  }

  @override
  Future<List<Chat>> getChats() async {
    return _chats;
  }

  @override
  Future<Chat> getOrCreateChat(String connectionId) async {
    final existingChat = _chats
        .where((c) => c.connectionId == connectionId)
        .firstOrNull;
    if (existingChat != null) {
      return existingChat;
    }

    final chat = Chat(
      id: 'chat-${DateTime.now().millisecondsSinceEpoch}',
      connectionId: connectionId,
      currentUserId: _currentUserId ?? 'test-user',
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
    return Stream.value(
        _messages.where((m) => m.chatId == chatId).toList());
  }

  @override
  Future<void> markMessagesAsRead(String chatId) async {
    // Mock implementation
  }

  @override
  Future<int> getPendingMessagesCount() async => 0;

  // Women-Only Mode
  @override
  Future<void> enableWomenOnlyMode() async {
    if (!_isOnline) {
      throw Exception('No internet connection');
    }
    _womenOnlyModeEnabled = true;
  }

  @override
  Future<void> disableWomenOnlyMode() async {
    if (!_isOnline) {
      throw Exception('No internet connection');
    }
    _womenOnlyModeEnabled = false;
  }

  @override
  Future<bool> isWomenOnlyModeEnabled() async {
    return _womenOnlyModeEnabled;
  }

  @override
  Future<bool> isVerifiedForWomenOnly() async {
    return _isVerifiedForWomenOnly;
  }

  @override
  Future<String?> getUserGender() async => null;
}

void main() {
  late MockMatchingRepository repository;

  setUp(() {
    repository = MockMatchingRepository();
    repository.setCurrentUserId(testUserId);
  });

  group('MatchingFlow - Trip Management', () {
    test('createTrip creates a trip successfully', () async {
      final now = DateTime.now();
      final trip = await repository.createTrip(
        destinationName: 'Paris, France',
        latitude: 48.8566,
        longitude: 2.3522,
        startDate: now,
        endDate: now.add(const Duration(days: 7)),
      );

      expect(trip.destinationName, 'Paris, France');
      expect(trip.latitude, 48.8566);
      expect(trip.longitude, 2.3522);
      expect(trip.isActive, true);
    });

    test('getUserTrips returns all trips', () async {
      final now = DateTime.now();
      await repository.createTrip(
        destinationName: 'Paris',
        latitude: 48.8566,
        longitude: 2.3522,
        startDate: now,
        endDate: now.add(const Duration(days: 7)),
      );
      await repository.createTrip(
        destinationName: 'Tokyo',
        latitude: 35.6762,
        longitude: 139.6503,
        startDate: now,
        endDate: now.add(const Duration(days: 5)),
      );

      final trips = await repository.getUserTrips();
      expect(trips.length, 2);
    });

    test('deleteTrip removes a trip', () async {
      final now = DateTime.now();
      final trip = await repository.createTrip(
        destinationName: 'Berlin',
        latitude: 52.52,
        longitude: 13.405,
        startDate: now,
        endDate: now.add(const Duration(days: 3)),
      );

      await repository.deleteTrip(trip.id);
      final trips = await repository.getUserTrips();
      expect(trips.length, 0);
    });
  });

  group('MatchingFlow - Connections', () {
    test('findMatches returns active connections', () async {
      // Connections list is empty, should return empty
      final matches = await repository.findMatches();
      expect(matches, isEmpty);
    });

    test('getNearbyTravelersCount returns active count', () async {
      final count = await repository.getNearbyTravelersCount();
      expect(count, 0);
    });
  });

  group('MatchingFlow - Activities', () {
    test('getActivities returns default activities', () async {
      final activities = await repository.getActivities();
      expect(activities.length, 3);
      expect(activities[0].name, 'Hiking');
      expect(activities[1].name, 'Sightseeing');
      expect(activities[2].name, 'Dining');
    });

    test('getUserActivities returns subset', () async {
      final activities = await repository.getUserActivities();
      expect(activities.length, 2);
    });
  });

  group('MatchingFlow - Messaging', () {
    test('sendMessage creates a message', () async {
      final msgId = await repository.sendMessage(
        chatId: testChatId,
        recipientId: testContactId,
        content: 'Hello!',
      );
      expect(msgId, isNotEmpty);
    });

    test('getOrCreateChat creates a new chat', () async {
      final chat = await repository.getOrCreateChat('conn-1');
      expect(chat.connectionId, 'conn-1');
      expect(chat.currentUserId, testUserId);
    });

    test('getOrCreateChat returns existing chat', () async {
      final chat1 = await repository.getOrCreateChat('conn-1');
      final chat2 = await repository.getOrCreateChat('conn-1');
      expect(chat1.id, chat2.id);
    });

    test('getMessages returns messages for a chat', () async {
      await repository.sendMessage(
        chatId: testChatId,
        recipientId: testContactId,
        content: 'Hello!',
      );
      final messages = await repository.getMessages(testChatId);
      expect(messages.length, 1);
      expect(messages[0].content, 'Hello!');
    });

    test('getPendingMessagesCount returns zero', () async {
      final count = await repository.getPendingMessagesCount();
      expect(count, 0);
    });
  });

  group('MatchingFlow - Women-Only Mode', () {
    test('enableWomenOnlyMode succeeds when online', () async {
      await repository.enableWomenOnlyMode();
      final enabled = await repository.isWomenOnlyModeEnabled();
      expect(enabled, true);
    });

    test('disableWomenOnlyMode succeeds when online', () async {
      await repository.enableWomenOnlyMode();
      await repository.disableWomenOnlyMode();
      final enabled = await repository.isWomenOnlyModeEnabled();
      expect(enabled, false);
    });

    test('enableWomenOnlyMode throws when offline', () async {
      repository.setOnline(false);
      expect(
        () => repository.enableWomenOnlyMode(),
        throwsA(isA<Exception>()),
      );
    });

    test('isVerifiedForWomenOnly returns set value', () async {
      repository.setVerifiedForWomenOnly(true);
      final verified = await repository.isVerifiedForWomenOnly();
      expect(verified, true);
    });

    test('getUserGender returns null by default', () async {
      final gender = await repository.getUserGender();
      expect(gender, isNull);
    });
  });

  group('MatchingFlow - Offline Support', () {
    test('hasPendingChanges returns false', () async {
      final pending = await repository.hasPendingChanges();
      expect(pending, false);
    });

    test('getLastSyncTimestamp returns a value', () async {
      final timestamp = await repository.getLastSyncTimestamp();
      expect(timestamp, isNotNull);
    });
  });
}
