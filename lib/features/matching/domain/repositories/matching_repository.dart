import 'package:soloadventurer/features/matching/domain/entities/matching_trip.dart';
import 'package:soloadventurer/features/matching/domain/entities/connection.dart';
import 'package:soloadventurer/features/matching/domain/entities/activity.dart';
import 'package:soloadventurer/features/matching/domain/entities/message.dart';
import 'package:soloadventurer/features/matching/domain/entities/chat.dart';

/// Repository interface for matching feature operations
abstract class MatchingRepository {
  // ============================================================
  // TRIP MANAGEMENT
  // ============================================================

  /// Create a new trip
  Future<MatchingTrip> createTrip({
    required String destinationName,
    required double latitude,
    required double longitude,
    required DateTime startDate,
    required DateTime endDate,
    LocationPrecision locationPrecision = LocationPrecision.city,
  });

  /// Get all trips for the current user
  Future<List<MatchingTrip>> getUserTrips();

  /// Get a specific trip by ID
  Future<MatchingTrip?> getTrip(String tripId);

  /// Update an existing trip
  Future<MatchingTrip> updateTrip(MatchingTrip trip);

  /// Delete a trip
  Future<void> deleteTrip(String tripId);

  /// Archive expired trips (called automatically or manually)
  Future<void> archiveExpiredTrips();

  // ============================================================
  // MATCHING / CONNECTIONS
  // ============================================================

  /// Find potential matches for the current user
  /// Returns a list of connections with matched user profiles
  Future<List<Connection>> findMatches();

  /// Get all connections for the current user
  Future<List<Connection>> getConnections();

  /// Get a specific connection by ID
  Future<Connection?> getConnection(String connectionId);

  /// Hide a connection (soft delete)
  Future<void> hideConnection(String connectionId);

  /// Get nearby travelers count (for UI badges, etc.)
  Future<int> getNearbyTravelersCount();

  // ============================================================
  // ACTIVITIES
  // ============================================================

  /// Get all available activities
  Future<List<Activity>> getActivities();

  /// Get user's selected activities
  Future<List<Activity>> getUserActivities();

  /// Set user's activities (replaces existing)
  Future<void> setUserActivities(List<String> activityIds);

  /// Add a single activity to user's interests
  Future<void> addUserActivity(String activityId);

  /// Remove a single activity from user's interests
  Future<void> removeUserActivity(String activityId);

  // ============================================================
  // OFFLINE SUPPORT
  // ============================================================

  /// Sync local data with remote (for offline-first architecture)
  Future<void> syncData();

  /// Check if there are pending changes to sync
  Future<bool> hasPendingChanges();

  /// Get last sync timestamp
  Future<DateTime?> getLastSyncTimestamp();

  // ============================================================
  // MESSAGING (F-004)
  // ============================================================

  /// Send a message to a matched user
  /// Returns the message ID for tracking
  Future<String> sendMessage({
    required String chatId,
    required String recipientId,
    required String content,
  });

  /// Get all chats for the current user
  Future<List<Chat>> getChats();

  /// Get or create a chat for a specific connection
  Future<Chat> getOrCreateChat(String connectionId);

  /// Get messages for a specific chat
  Future<List<Message>> getMessages(String chatId);

  /// Watch messages for real-time updates
  Stream<List<Message>> watchMessages(String chatId);

  /// Mark messages as read
  Future<void> markMessagesAsRead(String chatId);

  /// Get pending messages count (for sync indicator)
  Future<int> getPendingMessagesCount();

  // ============================================================
  // WOMEN-ONLY MODE (F-005)
  // ============================================================

  /// Enable women-only mode for the current user
  /// Requires verification and premium tier
  Future<void> enableWomenOnlyMode();

  /// Disable women-only mode
  Future<void> disableWomenOnlyMode();

  /// Check if women-only mode is enabled
  Future<bool> isWomenOnlyModeEnabled();

  /// Check if user is verified for women-only mode
  Future<bool> isVerifiedForWomenOnly();

  /// Get user's gender (from verification)
  Future<String?> getUserGender();
}
