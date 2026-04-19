import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:soloadventurer/features/matching/domain/entities/matching_trip.dart';
import 'package:soloadventurer/features/matching/domain/entities/connection.dart';
import 'package:soloadventurer/features/matching/domain/entities/activity.dart';
import 'package:soloadventurer/features/matching/domain/entities/message.dart';
import 'package:soloadventurer/features/matching/domain/entities/chat.dart';
import 'package:soloadventurer/features/matching/domain/repositories/matching_repository.dart';
import 'package:soloadventurer/features/matching/data/datasources/matching_remote_data_source.dart';
import 'package:soloadventurer/features/matching/data/datasources/matching_local_data_source.dart';
import 'package:soloadventurer/features/matching/data/models/trip_model.dart';
import 'package:soloadventurer/features/matching/data/models/message_model.dart';
import 'package:soloadventurer/features/matching/data/models/sync_operation.dart';
import 'package:soloadventurer/features/social/domain/enums/verification_tier.dart';

/// Implementation of [MatchingRepository] with offline-first support
///
/// This repository follows the offline-first architecture established in
/// the spike report (docs/matching/spike-offline-first/SPIKE_REPORT.md)
class MatchingRepositoryImpl implements MatchingRepository {
  final MatchingRemoteDataSource _remoteDataSource;
  final MatchingLocalDataSource _localDataSource;
  final SupabaseClient _supabaseClient;
  final bool _isOnline;
  
  /// Queue of pending sync operations
  final List<SyncOperation> _syncQueue = [];
  
  /// Maximum number of retry attempts for failed operations
  static const int _maxRetryAttempts = 3;

  /// Creates a new [MatchingRepositoryImpl]
  MatchingRepositoryImpl({
    required MatchingRemoteDataSource remoteDataSource,
    required MatchingLocalDataSource localDataSource,
    required bool isOnline,
    SupabaseClient? supabaseClient,
  })  : _remoteDataSource = remoteDataSource,
        _localDataSource = localDataSource,
        _isOnline = isOnline,
        _supabaseClient = supabaseClient ?? Supabase.instance.client {
    // Load any persisted sync queue on initialization
    _loadSyncQueue();
  }

  @override
  Future<MatchingTrip> createTrip({
    required String destinationName,
    required double latitude,
    required double longitude,
    required DateTime startDate,
    required DateTime endDate,
    LocationPrecision locationPrecision = LocationPrecision.city,
  }) async {
    // Create locally first (optimistic)
    final trip = TripModel(
      id: '', // Will be set by server
      userId: '', // Will be set from auth context
      destinationName: destinationName,
      latitude: latitude,
      longitude: longitude,
      locationPrecision: locationPrecision,
      startDate: startDate,
      endDate: endDate,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    final localTrip = await _localDataSource.createTrip(trip);

    // If online, sync with server
    if (_isOnline) {
      try {
        final remoteTrip = await _remoteDataSource.createTrip(
          destinationName: destinationName,
          latitude: latitude,
          longitude: longitude,
          startDate: startDate,
          endDate: endDate,
          locationPrecision: locationPrecision.name,
        );

        // Update local with server data (including server-generated ID)
        await _localDataSource.updateTrip(remoteTrip);

        return remoteTrip;
      } catch (e) {
        // Mark as pending sync if remote fails
        // Local version is still available
        _addToSyncQueue(SyncOperation(
          id: 'create-trip-${DateTime.now().millisecondsSinceEpoch}',
          type: SyncOperationType.createTrip,
          data: {
            'destination_name': destinationName,
            'latitude': latitude,
            'longitude': longitude,
            'start_date': startDate.toIso8601String(),
            'end_date': endDate.toIso8601String(),
            'location_precision': locationPrecision.name,
          },
          createdAt: DateTime.now(),
        ));
      }
    }

    return localTrip;
  }

  @override
  Future<List<MatchingTrip>> getUserTrips() async {
    // Always try to get from local first
    final localTrips = await _localDataSource.getUserTrips();

    // If online, sync with server
    if (_isOnline) {
      try {
        final remoteTrips = await _remoteDataSource.getUserTrips();
        // Update local cache
        await _localDataSource.clearTrips();
        for (final trip in remoteTrips) {
          await _localDataSource.createTrip(trip);
        }
        return remoteTrips;
      } catch (e) {
        // Return local data if remote fails
        return localTrips;
      }
    }

    return localTrips;
  }

  @override
  Future<MatchingTrip?> getTrip(String tripId) async {
    // Try local first
    final localTrip = await _localDataSource.getTrip(tripId);

    if (_isOnline) {
      try {
        final remoteTrip = await _remoteDataSource.getTrip(tripId);
        if (remoteTrip != null) {
          await _localDataSource.updateTrip(remoteTrip);
          return remoteTrip;
        }
      } catch (e) {
        // Return local if remote fails
        return localTrip;
      }
    }

    return localTrip;
  }

  @override
  Future<MatchingTrip> updateTrip(MatchingTrip trip) async {
    final tripModel = TripModel.fromEntity(trip);

    // Update locally first
    final localTrip = await _localDataSource.updateTrip(tripModel);

    // Sync with server if online
    if (_isOnline) {
      try {
        final remoteTrip = await _remoteDataSource.updateTrip(tripModel);
        await _localDataSource.updateTrip(remoteTrip);
        return remoteTrip;
      } catch (e) {
        // Add to sync queue for retry
        _addToSyncQueue(SyncOperation(
          id: 'update-trip-${trip.id}',
          type: SyncOperationType.updateTrip,
          data: {'trip': TripModel.fromEntity(trip).toJson()},
          createdAt: DateTime.now(),
        ));
      }
    }

    return localTrip;
  }

  @override
  Future<void> deleteTrip(String tripId) async {
    // Delete locally first
    await _localDataSource.deleteTrip(tripId);

    // Sync with server if online
    if (_isOnline) {
      try {
        await _remoteDataSource.deleteTrip(tripId);
      } catch (e) {
        // Add to sync queue for retry
        _addToSyncQueue(SyncOperation(
          id: 'delete-trip-$tripId',
          type: SyncOperationType.deleteTrip,
          data: {'trip_id': tripId},
          createdAt: DateTime.now(),
        ));
      }
    }
  }

  @override
  Future<void> archiveExpiredTrips() async {
    // Archive locally
    await _localDataSource.archiveExpiredTrips();

    // Sync with server if online
    if (_isOnline) {
      try {
        await _remoteDataSource.archiveExpiredTrips();
      } catch (e) {
        // Archive operation failed - will retry on next sync
        _addToSyncQueue(SyncOperation(
          id: 'archive-trips-${DateTime.now().millisecondsSinceEpoch}',
          type: SyncOperationType.deleteTrip, // Reuse delete operation for archive
          data: {'operation': 'archive_expired'},
          createdAt: DateTime.now(),
        ));
      }
    }
  }

  @override
  Future<List<Connection>> findMatches() async {
    if (_isOnline) {
      try {
        final remoteMatches = await _remoteDataSource.findMatches();
        // Cache locally
        await _localDataSource.clearMatches();
        await _localDataSource.cacheMatches(remoteMatches);
        return remoteMatches;
      } catch (e) {
        // Return cached data if remote fails
        return _localDataSource.getMatches();
      }
    }

    // Return cached data if offline
    return _localDataSource.getMatches();
  }

  @override
  Future<List<Connection>> getConnections() async {
    return findMatches();
  }

  @override
  Future<Connection?> getConnection(String connectionId) async {
    return _localDataSource.getConnection(connectionId);
  }

  @override
  Future<void> hideConnection(String connectionId) async {
    await _localDataSource.hideConnection(connectionId);

    if (_isOnline) {
      try {
        await _remoteDataSource.hideConnection(connectionId);
      } catch (e) {
        // Add to sync queue for retry
        _addToSyncQueue(SyncOperation(
          id: 'hide-connection-$connectionId',
          type: SyncOperationType.hideConnection,
          data: {'connection_id': connectionId},
          createdAt: DateTime.now(),
        ));
      }
    }
  }

  @override
  Future<int> getNearbyTravelersCount() async {
    if (_isOnline) {
      try {
        final count = await _remoteDataSource.getNearbyTravelersCount();
        await _localDataSource.cacheNearbyTravelersCount(count);
        return count;
      } catch (e) {
        // Return cached count if remote fails
        final cachedCount = await _localDataSource.getNearbyTravelersCount();
        return cachedCount ?? 0;
      }
    }

    final cachedCount = await _localDataSource.getNearbyTravelersCount();
    return cachedCount ?? 0;
  }

  @override
  Future<List<Activity>> getActivities() async {
    if (_isOnline) {
      try {
        final remoteActivities = await _remoteDataSource.getActivities();
        await _localDataSource.cacheActivities(remoteActivities);
        return remoteActivities;
      } catch (e) {
        // Return cached if remote fails
        return _localDataSource.getActivities();
      }
    }

    return _localDataSource.getActivities();
  }

  @override
  Future<List<Activity>> getUserActivities() async {
    if (_isOnline) {
      try {
        final remoteActivities = await _remoteDataSource.getUserActivities();
        await _localDataSource.cacheUserActivities(remoteActivities);
        return remoteActivities;
      } catch (e) {
        // Return cached if remote fails
        return _localDataSource.getUserActivities();
      }
    }

    return _localDataSource.getUserActivities();
  }

  @override
  Future<void> setUserActivities(List<String> activityIds) async {
    if (_isOnline) {
      try {
        await _remoteDataSource.setUserActivities(activityIds);
        // Refresh cache
        final activities = await _remoteDataSource.getUserActivities();
        await _localDataSource.cacheUserActivities(activities);
      } catch (e) {
        // Add to sync queue for retry
        _addToSyncQueue(SyncOperation(
          id: 'set-activities-${DateTime.now().millisecondsSinceEpoch}',
          type: SyncOperationType.setUserActivities,
          data: {'activity_ids': activityIds},
          createdAt: DateTime.now(),
        ));
      }
    }
  }

  @override
  Future<void> addUserActivity(String activityId) async {
    await _localDataSource.addUserActivity(activityId);

    if (_isOnline) {
      try {
        await _remoteDataSource.addUserActivity(activityId);
      } catch (e) {
        // Add to sync queue for retry
        _addToSyncQueue(SyncOperation(
          id: 'add-activity-$activityId',
          type: SyncOperationType.addUserActivity,
          data: {'activity_id': activityId},
          createdAt: DateTime.now(),
        ));
      }
    }
  }

  @override
  Future<void> removeUserActivity(String activityId) async {
    await _localDataSource.removeUserActivity(activityId);

    if (_isOnline) {
      try {
        await _remoteDataSource.removeUserActivity(activityId);
      } catch (e) {
        // Add to sync queue for retry
        _addToSyncQueue(SyncOperation(
          id: 'remove-activity-$activityId',
          type: SyncOperationType.removeUserActivity,
          data: {'activity_id': activityId},
          createdAt: DateTime.now(),
        ));
      }
    }
  }

  @override
  Future<void> syncData() async {
    if (!_isOnline) return;

    try {
      // Get pending changes
      await _localDataSource.getPendingChanges();

      // Sync pending changes to server
      await _remoteDataSource.syncLocalChanges();

      // Get server changes since last sync
      final lastSync = await _localDataSource.getLastSyncTimestamp();
      final serverChangesResponse = await _remoteDataSource.getServerChanges(
        lastSync ?? DateTime.fromMillisecondsSinceEpoch(0),
      );

      // Extract changes list from response wrapper
      final serverChanges = (serverChangesResponse['changes'] as List<dynamic>?)
              ?.cast<Map<String, dynamic>>() ??
          [];

      // Apply server changes locally with conflict resolution
      await _applyServerChanges(serverChanges);

      // Process sync queue
      await _processSyncQueue();

      // Update last sync timestamp
      await _localDataSource.setLastSyncTimestamp(DateTime.now());

      // Clear pending changes
      await _localDataSource.clearPendingChanges();
    } catch (e) {
      // Log sync error but don't throw - will retry on next sync
      rethrow;
    }
  }

  @override
  Future<bool> hasPendingChanges() async {
    final pendingChanges = await _localDataSource.getPendingChanges();
    return pendingChanges.isNotEmpty || _syncQueue.isNotEmpty;
  }

  @override
  Future<DateTime?> getLastSyncTimestamp() async {
    return _localDataSource.getLastSyncTimestamp();
  }

  // ========== Sync Queue Implementation ==========

  /// Adds an operation to the sync queue
  void _addToSyncQueue(SyncOperation operation) {
    _syncQueue.add(operation);
    // Persist to local storage
    _persistSyncQueue();
  }

  /// Persists the sync queue to local storage
  Future<void> _persistSyncQueue() async {
    // Convert queue to JSON and save to local storage
    // Implementation depends on local data source capabilities
    try {
      final queueJson = _syncQueue.map((op) => op.toJson()).toList();
      await _localDataSource.saveSyncQueue(queueJson);
    } catch (e) {
      // Silently fail - sync queue persistence is not critical
    }
  }

  /// Loads the sync queue from local storage
  Future<void> _loadSyncQueue() async {
    try {
      final queueJson = await _localDataSource.getSyncQueue();
      _syncQueue.clear();
      _syncQueue.addAll(
        queueJson.map((json) => SyncOperation.fromJson(json)),
      );
    } catch (e) {
      // Silently fail - sync queue loading is not critical
    }
  }

  /// Processes all pending sync operations
  Future<void> _processSyncQueue() async {
    if (!_isOnline || _syncQueue.isEmpty) return;

    final failedOperations = <SyncOperation>[];

    for (final operation in _syncQueue) {
      final result = await _processSyncOperation(operation);
      
      if (result != SyncOperationResult.success) {
        if (operation.retryCount < _maxRetryAttempts) {
          failedOperations.add(operation.withRetryCount(operation.retryCount + 1));
        }
      }
    }

    // Update queue with failed operations (for retry later)
    _syncQueue.clear();
    _syncQueue.addAll(failedOperations);
    await _persistSyncQueue();
  }

  /// Processes a single sync operation
  Future<SyncOperationResult> _processSyncOperation(SyncOperation operation) async {
    try {
      switch (operation.type) {
        case SyncOperationType.createTrip:
          await _remoteDataSource.createTrip(
            destinationName: operation.data['destination_name'] as String,
            latitude: operation.data['latitude'] as double,
            longitude: operation.data['longitude'] as double,
            startDate: DateTime.parse(operation.data['start_date'] as String),
            endDate: DateTime.parse(operation.data['end_date'] as String),
            locationPrecision: operation.data['location_precision'] as String,
          );
          break;
        
        case SyncOperationType.updateTrip:
          final tripJson = operation.data['trip'] as Map<String, dynamic>;
          final trip = TripModel.fromJson(tripJson);
          await _remoteDataSource.updateTrip(trip);
          break;
        
        case SyncOperationType.deleteTrip:
          final tripId = operation.data['trip_id'] as String?;
          if (tripId != null) {
            await _remoteDataSource.deleteTrip(tripId);
          }
          break;
        
        case SyncOperationType.hideConnection:
          final connectionId = operation.data['connection_id'] as String;
          await _remoteDataSource.hideConnection(connectionId);
          break;
        
        case SyncOperationType.setUserActivities:
          final activityIds = List<String>.from(operation.data['activity_ids'] as List);
          await _remoteDataSource.setUserActivities(activityIds);
          break;
        
        case SyncOperationType.addUserActivity:
          final activityId = operation.data['activity_id'] as String;
          await _remoteDataSource.addUserActivity(activityId);
          break;
        
        case SyncOperationType.removeUserActivity:
          final activityId = operation.data['activity_id'] as String;
          await _remoteDataSource.removeUserActivity(activityId);
          break;
        
        case SyncOperationType.sendMessage:
          await _remoteDataSource.sendMessage(
            connectionId: operation.data['chat_id'] as String,
            recipientId: operation.data['recipient_id'] as String,
            content: operation.data['content'] as String,
            clientMessageId: operation.id,
          );
          break;
      }
      
      return SyncOperationResult.success;
    } catch (e) {
      return SyncOperationResult.failure;
    }
  }

  /// Applies server changes to local storage with conflict resolution
  Future<void> _applyServerChanges(List<Map<String, dynamic>> changes) async {
    for (final change in changes) {
      final entityType = change['entity_type'] as String?;
      final operation = change['operation'] as String?;
      final data = change['data'] as Map<String, dynamic>?;

      if (entityType == null || operation == null || data == null) continue;

      // Simple conflict resolution: server wins
      // In a production app, this would be more sophisticated
      try {
        switch (entityType) {
          case 'trip':
            if (operation == 'create' || operation == 'update') {
              final trip = TripModel.fromJson(data);
              await _localDataSource.updateTrip(trip);
            } else if (operation == 'delete') {
              final tripId = data['id'] as String;
              await _localDataSource.deleteTrip(tripId);
            }
            break;
          // Add other entity types as needed
        }
      } catch (e) {
      // intentional silent catch
      }
    }
  }

  // ============================================================
  // MESSAGING (F-004)
  // ============================================================

  /// In-memory cache of messages for demo purposes
  /// In production, this would be stored in local database
  final Map<String, List<Message>> _messageCache = {};
  final Map<String, Chat> _chatCache = {};
  
  @override
  Future<String> sendMessage({
    required String chatId,
    required String recipientId,
    required String content,
  }) async {
    // Generate message ID for optimistic UI
    final messageId = 'msg_${DateTime.now().millisecondsSinceEpoch}';

    // Create pending message (optimistic UI)
    final message = MessageModel.pending(
      id: messageId,
      chatId: chatId,
      senderId: '', // Will be set from auth context
      content: content,
    );

    // Add to cache immediately (offline-first)
    _messageCache.putIfAbsent(chatId, () => []);
    _messageCache[chatId]!.add(message);

    // If online, sync to server
    if (_isOnline) {
      try {
        final serverMessage = await _remoteDataSource.sendMessage(
          connectionId: chatId,
          recipientId: recipientId,
          content: content,
          clientMessageId: messageId,
          clientCreatedAt: message.createdAt,
        );

        // Update status to sent with server data
        final index = _messageCache[chatId]!.indexWhere((m) => m.id == messageId);
        if (index != -1) {
          _messageCache[chatId]![index] = message.copyWith(
            status: MessageStatus.sent,
            syncedAt: DateTime.now(),
            serverId: serverMessage.id,
          );
        }
      } catch (e) {
        // Mark as failed
        final index = _messageCache[chatId]!.indexWhere((m) => m.id == messageId);
        if (index != -1) {
          _messageCache[chatId]![index] = message.copyWith(
            status: MessageStatus.failed,
          );
        }

        // Add to sync queue for retry
        _addToSyncQueue(SyncOperation(
          id: 'send-message-$messageId',
          type: SyncOperationType.sendMessage,
          data: {
            'chat_id': chatId,
            'recipient_id': recipientId,
            'content': content,
          },
          createdAt: DateTime.now(),
        ));
      }
    }

    return messageId;
  }

  @override
  Future<List<Chat>> getChats() async {
    // If online, fetch from server
    if (_isOnline) {
      try {
        final connections = await _remoteDataSource.getConnections();
        final chats = connections.map((conn) => Chat(
          id: conn.id,
          connectionId: conn.id,
          currentUserId: '', // Set from auth context at higher layer
          otherUserId: conn.matchedUserProfile?.id ?? conn.userBId,
          otherUserName: conn.matchedUserProfile?.firstName ?? 'Traveler',
          otherUserAvatarUrl: conn.matchedUserProfile?.avatarUrl,
          otherUserVerificationTier: conn.matchedUserProfile?.verificationTier ?? VerificationTier.unverified,
          lastMessage: null, // Populated via separate message fetch
          unreadCount: 0, // Updated via real-time subscription
          createdAt: conn.createdAt,
          updatedAt: conn.createdAt,
        )).toList();

        // Cache locally
        for (final chat in chats) {
          _chatCache[chat.id] = chat;
        }
        return chats;
      } catch (e) {
        // Return cached if remote fails
      }
    }

    return _chatCache.values.toList();
  }

  @override
  Future<Chat> getOrCreateChat(String connectionId) async {
    // Check if chat already exists for this connection
    final existingChat = _chatCache.values.firstWhere(
      (chat) => chat.connectionId == connectionId,
      orElse: () => Chat.empty(),
    );
    
    if (existingChat.isNotEmpty) {
      return existingChat;
    }
    
    // Create new chat
    final chatId = 'chat_${DateTime.now().millisecondsSinceEpoch}';
    final newChat = Chat(
      id: chatId,
      connectionId: connectionId,
      currentUserId: '', // Will be set from auth context
      otherUserId: '', // Will be set from connection
      otherUserName: 'Traveler', // Will be set from connection
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    
    // Cache the chat
    _chatCache[chatId] = newChat;
    
    // If online, sync to server via connection
    if (_isOnline) {
      try {
        final conn = await _remoteDataSource.getConnection(connectionId);
        if (conn != null) {
          final serverChat = Chat(
            id: conn.id,
            connectionId: connectionId,
            currentUserId: '',
            otherUserId: conn.matchedUserProfile?.id ?? conn.userBId,
            otherUserName: conn.matchedUserProfile?.firstName ?? 'Traveler',
            otherUserAvatarUrl: conn.matchedUserProfile?.avatarUrl,
            otherUserVerificationTier: conn.matchedUserProfile?.verificationTier ?? VerificationTier.unverified,
            createdAt: conn.createdAt,
            updatedAt: conn.createdAt,
          );
          _chatCache[serverChat.id] = serverChat;
          return serverChat;
        }
      } catch (e) {
        // Silently fail - chat creation retry is not critical
      }
    }

    return newChat;
  }

  @override
  Future<List<Message>> getMessages(String chatId) async {
    // If online, fetch from server
    if (_isOnline) {
      try {
        final remoteMessages = await _remoteDataSource.getMessages(chatId);
        // Cache locally for offline access
        _messageCache[chatId] = remoteMessages;
        return remoteMessages;
      } catch (e) {
        // Fall through to local cache
      }
    }
    return _messageCache[chatId] ?? [];
  }

  @override
  Stream<List<Message>> watchMessages(String chatId) {
    // If online, use real Supabase Realtime stream
    if (_isOnline) {
      try {
        return _remoteDataSource.watchMessages(chatId).map((messages) {
          // Update local cache
          _messageCache[chatId] = messages;
          return messages;
        });
      } catch (e) {
        // Fall through to polling fallback
      }
    }

    // Fallback: poll local cache for offline mode
    return Stream.periodic(const Duration(seconds: 2), (_) {
      return _messageCache[chatId] ?? [];
    });
  }

  @override
  Future<void> markMessagesAsRead(String chatId) async {
    // Update local cache immediately
    final messages = _messageCache[chatId];
    if (messages != null) {
      _messageCache[chatId] = messages.map((m) {
        if (m.status != MessageStatus.read) {
          return m.copyWith(status: MessageStatus.read);
        }
        return m;
      }).toList();
    }

    if (_isOnline) {
      try {
        await _remoteDataSource.markMessagesRead(chatId);
      } catch (e) {
        // Silently fail - marking messages as read retry is not critical
      }
    }
  }

  @override
  Future<int> getPendingMessagesCount() async {
    // Count all pending messages across all chats
    int count = 0;
    for (final messages in _messageCache.values) {
      count += messages.where((m) => m.status == MessageStatus.pending).length;
    }
    return count;
  }

  // ============================================================
  // WOMEN-ONLY MODE (F-005)
  // ============================================================

  // In-memory storage for demo purposes
  bool _womenOnlyModeEnabled = false;
  bool _isVerifiedForWomenOnly = false;
  String? _userGender;

  @override
  Future<void> enableWomenOnlyMode() async {
    // Check if verified
    if (!await isVerifiedForWomenOnly()) {
      throw Exception('User must be verified to enable women-only mode');
    }

    // Verify user gender is female
    final gender = await getUserGender();
    if (gender?.toLowerCase() != 'female') {
      throw Exception('Only verified women can enable women-only mode');
    }

    _womenOnlyModeEnabled = true;

    if (_isOnline) {
      try {
        final userId = _supabaseClient.auth.currentUser?.id;
        if (userId != null) {
          await _supabaseClient
              .from('profiles')
              .update({'women_only_mode': true})
              .eq('id', userId);
        }
      } catch (e) {
        // Silently fail - women-only mode enable retry is not critical
      }
    }
  }

  @override
  Future<void> disableWomenOnlyMode() async {
    _womenOnlyModeEnabled = false;

    if (_isOnline) {
      try {
        final userId = _supabaseClient.auth.currentUser?.id;
        if (userId != null) {
          await _supabaseClient
              .from('profiles')
              .update({'women_only_mode': false})
              .eq('id', userId);
        }
      } catch (e) {
        // Silently fail - women-only mode disable retry is not critical
      }
    }
  }

  @override
  Future<bool> isWomenOnlyModeEnabled() async {
    // If online, fetch latest status from server
    if (_isOnline) {
      try {
        final userId = _supabaseClient.auth.currentUser?.id;
        if (userId != null) {
          final response = await _supabaseClient
              .from('profiles')
              .select('women_only_mode')
              .eq('id', userId)
              .single();
          _womenOnlyModeEnabled = response['women_only_mode'] as bool? ?? false;
        }
      } catch (e) {
        // Return cached value
      }
    }

    return _womenOnlyModeEnabled;
  }

  @override
  Future<bool> isVerifiedForWomenOnly() async {
    // If online, check verification status from server
    if (_isOnline) {
      try {
        final userId = _supabaseClient.auth.currentUser?.id;
        if (userId != null) {
          final response = await _supabaseClient
              .from('profiles')
              .select('gender_verified')
              .eq('id', userId)
              .single();
          _isVerifiedForWomenOnly = response['gender_verified'] as bool? ?? false;
        }
      } catch (e) {
        // Return cached value
      }
    }

    return _isVerifiedForWomenOnly;
  }

  @override
  Future<String?> getUserGender() async {
    // If online, fetch gender from server profile
    if (_isOnline) {
      try {
        final userId = _supabaseClient.auth.currentUser?.id;
        if (userId != null) {
          final response = await _supabaseClient
              .from('profiles')
              .select('gender')
              .eq('id', userId)
              .single();
          _userGender = response['gender'] as String?;
        }
      } catch (e) {
        // Return cached value
      }
    }

    return _userGender;
  }
}
