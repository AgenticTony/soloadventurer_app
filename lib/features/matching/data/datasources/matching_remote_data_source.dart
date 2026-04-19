import 'dart:async';
import 'package:soloadventurer/features/matching/data/models/trip_model.dart';
import 'package:soloadventurer/features/matching/data/models/message_model.dart';
import 'package:soloadventurer/features/matching/data/models/connection_model.dart';
import 'package:soloadventurer/features/matching/data/models/activity_model.dart';

/// Remote data source for matching operations (Supabase)
abstract class MatchingRemoteDataSource {
  // ============================================================
  // TRIPS
  // ============================================================

  /// Create a new trip on the server
  Future<TripModel> createTrip({
    required String destinationName,
    required double latitude,
    required double longitude,
    required DateTime startDate,
    required DateTime endDate,
    String locationPrecision = 'city',
  });

  /// Get all trips for the current user from server
  Future<List<TripModel>> getUserTrips();

  /// Get a specific trip by ID from server
  Future<TripModel?> getTrip(String tripId);

  /// Update an existing trip on the server
  Future<TripModel> updateTrip(TripModel trip);

  /// Delete a trip from the server
  Future<void> deleteTrip(String tripId);

  /// Archive expired trips on the server
  Future<void> archiveExpiredTrips();

  // ============================================================
  // MATCHES / CONNECTIONS
  // ============================================================

  /// Find potential matches from the server
  Future<List<ConnectionModel>> findMatches();

  /// Get all connections for the current user
  Future<List<ConnectionModel>> getConnections();

  /// Get a specific connection by ID
  Future<ConnectionModel?> getConnection(String connectionId);

  /// Hide a connection on the server
  Future<void> hideConnection(String connectionId);

  /// Request a new connection with another user
  Future<ConnectionModel> requestConnection({
    required String recipientId,
    String? message,
  });

  /// Respond to a connection request (accept/decline)
  Future<ConnectionModel> respondToConnection({
    required String connectionId,
    required bool accept,
    String? message,
  });

  /// Get count of nearby travelers
  Future<int> getNearbyTravelersCount();

  // ============================================================
  // ACTIVITIES
  // ============================================================

  /// Get all available activities from server
  Future<List<ActivityModel>> getActivities();

  /// Get user's selected activities
  Future<List<ActivityModel>> getUserActivities();

  /// Set user's activities (replaces existing)
  Future<void> setUserActivities(List<String> activityIds);

  /// Add a single activity to user's interests
  Future<void> addUserActivity(String activityId);

  /// Remove a single activity from user's interests
  Future<void> removeUserActivity(String activityId);

  // ============================================================
  // SYNC
  // ============================================================

  /// Sync local changes to server
  Future<void> syncLocalChanges();

  /// Get server changes since last sync
  Future<Map<String, dynamic>> getServerChanges(DateTime since);

  // ============================================================
  // MESSAGING (Real-time)
  // ============================================================

  /// Send a message to a matched user
  Future<MessageModel> sendMessage({
    required String connectionId,
    required String recipientId,
    required String content,
    String? clientMessageId,
  DateTime? clientCreatedAt,
  });

  /// Get messages for a connection
  Future<List<MessageModel>> getMessages(String connectionId, {
    int limit = 50,
    DateTime? before,
  });

  /// Watch messages for real-time updates
  Stream<List<MessageModel>> watchMessages(String connectionId);

  /// Mark messages as delivered
  Future<void> markMessagesDelivered(String connectionId, List<String> messageIds);

  /// Mark messages as read
  Future<void> markMessagesRead(String connectionId);

  // ============================================================
  // TYPING INDICATORS
  // ============================================================

  /// Set typing indicator
  Future<void> setTypingIndicator(String connectionId);

  /// Clear typing indicator
  Future<void> clearTypingIndicator(String connectionId);

  /// Get users currently typing in a chat
  Future<List<String>> getTypingUsers(String connectionId);

  // ============================================================
  // NOTIFICATION TOKENS
  // ============================================================

  /// Register device token for push notifications
  Future<void> registerNotificationToken({
    required String token,
    required String platform,
    String? deviceId,
    String? deviceName,
    String? appVersion,
    String? osVersion,
  });

  /// Unregister device token
  Future<void> unregisterNotificationToken(String token);
}
