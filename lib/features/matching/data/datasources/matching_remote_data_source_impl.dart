import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthException;
import 'package:soloadventurer/features/matching/data/datasources/matching_remote_data_source.dart';
import 'package:soloadventurer/features/matching/data/models/trip_model.dart';
import 'package:soloadventurer/features/matching/data/models/connection_model.dart';
import 'package:soloadventurer/features/matching/data/models/activity_model.dart';
import 'package:soloadventurer/features/matching/data/models/message_model.dart';
import 'package:soloadventurer/core/errors/exceptions.dart';

/// Supabase implementation of [MatchingRemoteDataSource]
///
/// This implementation uses Supabase RPC functions and Edge Functions
/// to perform matching operations:
/// - `find_potential_matches()` RPC for finding matches
/// - `request-connection` Edge Function for requesting connections
/// - `respond-connection` Edge Function for responding to connections
class MatchingRemoteDataSourceImpl implements MatchingRemoteDataSource {
  final SupabaseClient _client;

  /// Creates a new [MatchingRemoteDataSourceImpl]
  ///
  /// The [client] parameter should be an initialized SupabaseClient instance.
  MatchingRemoteDataSourceImpl({required SupabaseClient client}) : _client = client;

  /// Helper to get current user ID
  String? get _currentUserId => _client.auth.currentUser?.id;

  // ============================================================
  // TRIPS
  // ============================================================

  @override
  Future<TripModel> createTrip({
    required String destinationName,
    required double latitude,
    required double longitude,
    required DateTime startDate,
    required DateTime endDate,
    String locationPrecision = 'city',
  }) async {
    final userId = _currentUserId;
    if (userId == null) {
      throw const AuthException('User not authenticated', type: AuthErrorType.unauthorized);
    }

    try {
      final response = await _client
          .from('trips')
          .insert({
            'user_id': userId,
            'destination_name': destinationName,
            'location': {
              'type': 'Point',
              'coordinates': [longitude, latitude],
            },
            'start_date': startDate.toIso8601String().split('T')[0],
            'end_date': endDate.toIso8601String().split('T')[0],
            'location_precision': locationPrecision,
          })
          .select()
          .single();

      return TripModel.fromJson(response);
    } catch (e) {
      throw ServerException(message: 'Failed to create trip: $e');
    }
  }

  @override
  Future<List<TripModel>> getUserTrips() async {
    final userId = _currentUserId;
    if (userId == null) {
      throw const AuthException('User not authenticated', type: AuthErrorType.unauthorized);
    }

    try {
      final response = await _client
          .from('trips')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      return (response as List<dynamic>)
          .map((json) => TripModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw ServerException(message: 'Failed to get user trips: $e');
    }
  }

  @override
  Future<TripModel?> getTrip(String tripId) async {
    try {
      final response = await _client
          .from('trips')
          .select()
          .eq('id', tripId)
          .single();

      return TripModel.fromJson(response);
    } catch (e) {
      // Return null if not found
      return null;
    }
  }

  @override
  Future<TripModel> updateTrip(TripModel trip) async {
    try {
      final response = await _client
          .from('trips')
          .update(trip.toJson())
          .eq('id', trip.id)
          .select()
          .single();

      return TripModel.fromJson(response);
    } catch (e) {
      throw ServerException(message: 'Failed to update trip: $e');
    }
  }

  @override
  Future<void> deleteTrip(String tripId) async {
    try {
      await _client
          .from('trips')
          .delete()
          .eq('id', tripId);
    } catch (e) {
      throw ServerException(message: 'Failed to delete trip: $e');
    }
  }

  @override
  Future<void> archiveExpiredTrips() async {
    final userId = _currentUserId;
    if (userId == null) return;

    try {
      await _client
          .from('trips')
          .update({'status': 'archived'})
          .eq('user_id', userId)
          .lt('end_date', DateTime.now().toIso8601String().split('T')[0]);
    } catch (e) {
      throw ServerException(message: 'Failed to archive trips: $e');
    }
  }

  // ============================================================
  // MATCHES / CONNECTIONS
  // ============================================================

  @override
  Future<List<ConnectionModel>> findMatches() async {
    final userId = _currentUserId;
    if (userId == null) {
      throw const AuthException('User not authenticated', type: AuthErrorType.unauthorized);
    }

    try {
      // Try the new semantic matching Edge Function first
      final response = await _client.functions.invoke(
        'find-potential-matches-semantic',
        body: {'user_id': userId, 'limit': 20},
      );

      if (response.status == 200 && response.data != null) {
        final data = response.data;
        final matchesRaw = data is Map ? data['matches'] as List? : data as List?;
        if (matchesRaw != null) {
          return matchesRaw
              .map((m) => ConnectionModel.fromMatchingJson(m as Map<String, dynamic>))
              .toList();
        }
      }

      // Fall back to the old RPC if Edge Function didn't return valid data
      return await _findMatchesFallback(userId);
    } catch (e) {
      // Fall back to the old RPC on any Edge Function error
      try {
        return await _findMatchesFallback(userId);
      } catch (fallbackError) {
        throw ServerException(message: 'Failed to find matches: $fallbackError');
      }
    }
  }

  /// Fallback to the original RPC-based matching
  Future<List<ConnectionModel>> _findMatchesFallback(String userId) async {
    final response = await _client.rpc(
      'find_potential_matches',
      params: {
        'user_id': userId,
        'radius_km': 50.0,
      },
    );
    return (response as List<dynamic>)
        .map((json) => ConnectionModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<ConnectionModel>> getConnections() async {
    final userId = _currentUserId;
    if (userId == null) {
      throw const AuthException('User not authenticated', type: AuthErrorType.unauthorized);
    }

    try {
      // Get all connections where user is either user_a or user_b
      final response = await _client
          .from('connections')
          .select('''
            *,
            matched_user:user_a_id (
              id,
              first_name,
              age_range,
              home_country,
              gender,
              avatar_url,
              trip:trips (
                destination_name,
                start_date,
                end_date
              )
            )
          ''')
          .or('user_a_id.eq.$userId,user_b_id.eq.$userId')
          .eq('is_active', true)
          .order('created_at', ascending: false);

      return (response as List<dynamic>)
          .map((json) => ConnectionModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw ServerException(message: 'Failed to get connections: $e');
    }
  }

  @override
  Future<ConnectionModel?> getConnection(String connectionId) async {
    try {
      final response = await _client
          .from('connections')
          .select()
          .eq('id', connectionId)
          .single();

      return ConnectionModel.fromJson(response);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> hideConnection(String connectionId) async {
    try {
      await _client
          .from('connections')
          .update({'is_active': false})
          .eq('id', connectionId);
    } catch (e) {
      throw ServerException(message: 'Failed to hide connection: $e');
    }
  }

  @override
  Future<ConnectionModel> requestConnection({
    required String recipientId,
    String? message,
  }) async {
    final userId = _currentUserId;
    if (userId == null) {
      throw const AuthException('User not authenticated', type: AuthErrorType.unauthorized);
    }

    try {
      // Call the request-connection Edge Function
      final response = await _client.functions.invoke(
        'request-connection',
        body: {
          'recipient_id': recipientId,
          'message': message,
        },
      );

      if (response.status != 200) {
        throw ServerException(message: 'Failed to request connection: ${response.data}');
      }

      return ConnectionModel.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(message: 'Failed to request connection: $e');
    }
  }

  @override
  Future<ConnectionModel> respondToConnection({
    required String connectionId,
    required bool accept,
    String? message,
  }) async {
    final userId = _currentUserId;
    if (userId == null) {
      throw const AuthException('User not authenticated', type: AuthErrorType.unauthorized);
    }

    try {
      // Call the respond-connection Edge Function
      final response = await _client.functions.invoke(
        'respond-connection',
        body: {
          'connection_id': connectionId,
          'accept': accept,
          'message': message,
        },
      );

      if (response.status != 200) {
        throw ServerException(message: 'Failed to respond to connection: ${response.data}');
      }

      return ConnectionModel.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(message: 'Failed to respond to connection: $e');
    }
  }

  @override
  Future<int> getNearbyTravelersCount() async {
    final userId = _currentUserId;
    if (userId == null) {
      return 0;
    }

    try {
      // Call the find_potential_matches RPC function with count only
      final response = await _client.rpc(
        'find_potential_matches',
        params: {
          'user_id': userId,
          'radius_km': 50.0,
        },
      );

      // Return the count
      return (response as List<dynamic>).length;
    } catch (e) {
      // Return 0 on error
      return 0;
    }
  }

  // ============================================================
  // ACTIVITIES
  // ============================================================

  @override
  Future<List<ActivityModel>> getActivities() async {
    try {
      final response = await _client
          .from('activities')
          .select()
          .order('name', ascending: true);

      return (response as List<dynamic>)
          .map((json) => ActivityModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw ServerException(message: 'Failed to get activities: $e');
    }
  }

  @override
  Future<List<ActivityModel>> getUserActivities() async {
    final userId = _currentUserId;
    if (userId == null) {
      return [];
    }

    try {
      final response = await _client
          .from('user_activities')
          .select('''
            activity_id,
            activities (*)
          ''')
          .eq('user_id', userId);

      return (response as List<dynamic>)
          .map((json) => ActivityModel.fromJson(
              json['activities'] as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw ServerException(message: 'Failed to get user activities: $e');
    }
  }

  @override
  Future<void> setUserActivities(List<String> activityIds) async {
    final userId = _currentUserId;
    if (userId == null) {
      throw const AuthException('User not authenticated', type: AuthErrorType.unauthorized);
    }

    try {
      // Delete existing activities
      await _client
          .from('user_activities')
          .delete()
          .eq('user_id', userId);

      // Insert new activities
      if (activityIds.isNotEmpty) {
        final inserts = activityIds.map((activityId) => {
          'user_id': userId,
          'activity_id': activityId,
        }).toList();

        await _client
            .from('user_activities')
            .insert(inserts);
      }
    } catch (e) {
      throw ServerException(message: 'Failed to set user activities: $e');
    }
  }

  @override
  Future<void> addUserActivity(String activityId) async {
    final userId = _currentUserId;
    if (userId == null) {
      throw const AuthException('User not authenticated', type: AuthErrorType.unauthorized);
    }

    try {
      await _client
          .from('user_activities')
          .insert({
            'user_id': userId,
            'activity_id': activityId,
          });
    } catch (e) {
      throw ServerException(message: 'Failed to add user activity: $e');
    }
  }

  @override
  Future<void> removeUserActivity(String activityId) async {
    final userId = _currentUserId;
    if (userId == null) {
      throw const AuthException('User not authenticated', type: AuthErrorType.unauthorized);
    }

    try {
      await _client
          .from('user_activities')
          .delete()
          .eq('user_id', userId)
          .eq('activity_id', activityId);
    } catch (e) {
      throw ServerException(message: 'Failed to remove user activity: $e');
    }
  }

  // ============================================================
  // SYNC
  // ============================================================

  @override
  Future<void> syncLocalChanges() async {
    // This is handled by the repository layer
    // The remote data source just provides the API endpoints
  }

  @override
  Future<Map<String, dynamic>> getServerChanges(DateTime since) async {
    final userId = _currentUserId;
    if (userId == null) {
      return {'changes': []};
    }

    try {
      // Get changes from server since timestamp
      // This would typically call a server function that tracks changes
      // For now, return empty changes
      return {'changes': []};
    } catch (e) {
      throw ServerException(message: 'Failed to get server changes: $e');
    }
  }

  // ============================================================
  // MESSAGING (Real-time)
  // ============================================================

  @override
  Future<MessageModel> sendMessage({
    required String connectionId,
    required String recipientId,
    required String content,
    String? clientMessageId,
    DateTime? clientCreatedAt,
  }) async {
    final userId = _currentUserId;
    if (userId == null) {
      throw const AuthException('User not authenticated', type: AuthErrorType.unauthorized);
    }

    try {
      final response = await _client
          .from('messages')
          .insert({
            'connection_id': connectionId,
            'sender_id': userId,
            'receiver_id': recipientId,
            'content': content,
            'client_message_id': clientMessageId,
            'client_created_at': clientCreatedAt?.toIso8601String(),
          })
          .select()
          .single();

      final message = MessageModel.fromJson(response);

      // Fire-and-forget push notification to recipient
      _triggerPushNotification(message: message, recipientId: recipientId);

      return message;
    } catch (e) {
      throw ServerException(message: 'Failed to send message: $e');
    }
  }

  @override
  Future<List<MessageModel>> getMessages(String connectionId, {int limit = 50, DateTime? before}) async {
    try {
      var query = _client
          .from('messages')
          .select('*')
          .eq('connection_id', connectionId);

      if (before != null) {
        query = query.lt('sent_at', before.toIso8601String());
      }

      final response = await query
          .order('sent_at', ascending: false)
          .limit(limit);

      return (response as List<dynamic>)
          .map((json) => MessageModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw ServerException(message: 'Failed to get messages: $e');
    }
  }

  @override
  Stream<List<MessageModel>> watchMessages(String connectionId) {
    final controller = StreamController<List<MessageModel>>.broadcast();
    
    // Initial fetch
    _fetchMessages(connectionId).then((messages) {
      controller.add(messages);
    });
    
    // Set up real-time subscription
    _client
        .channel('messages:$connectionId')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'messages',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'connection_id',
            value: connectionId,
          ),
          callback: (payload) async {
            final newMessage = MessageModel.fromJson(
              payload.newRecord,
            );
            final currentMessages = await _fetchMessages(connectionId);
            controller.add([...currentMessages, newMessage]);
          },
        )
        .onPostgresChanges(
          event: PostgresChangeEvent.update,
          schema: 'public',
          table: 'messages',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'connection_id',
            value: connectionId,
          ),
          callback: (payload) async {
            // Refresh messages on update (e.g., read status)
            final messages = await _fetchMessages(connectionId);
            controller.add(messages);
          },
        )
        .subscribe((status, error) {
          if (error != null) {
            // Realtime subscription error - silently handle
          }
        });

    return controller.stream;
  }

  Future<List<MessageModel>> _fetchMessages(String connectionId) async {
    final response = await _client
        .from('messages')
        .select('*')
        .eq('connection_id', connectionId)
        .order('sent_at', ascending: false);

    return (response as List<dynamic>)
        .map((json) => MessageModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> setTypingIndicator(String connectionId) async {
    final userId = _currentUserId;
    if (userId == null) return;

    try {
      await _client.rpc('set_typing_indicator', params: {
        'p_chat_id': connectionId,
        'p_user_id': userId,
      });
    } catch (e) {
      // Silently fail - typing indicators are not critical
    }
  }

  @override
  Future<void> clearTypingIndicator(String connectionId) async {
    final userId = _currentUserId;
    if (userId == null) return;

    try {
      await _client.rpc('clear_typing_indicator', params: {
        'p_chat_id': connectionId,
        'p_user_id': userId,
      });
    } catch (e) {
      // Silently fail - typing indicators are not critical
    }
  }

  @override
  Future<void> markMessagesDelivered(String connectionId, List<String> messageIds) async {
    if (messageIds.isEmpty) return;
    try {
      await _client
          .from('messages')
          .update({'delivered_at': DateTime.now().toIso8601String()})
          .filter('id', 'in', messageIds)
          .eq('connection_id', connectionId);
    } catch (e) {
      // Silently fail - delivery receipts are not critical
    }
  }

  @override
  Future<void> markMessagesRead(String connectionId) async {
    final userId = _currentUserId;
    if (userId == null) return;
    try {
      await _client
          .from('messages')
          .update({'read_at': DateTime.now().toIso8601String()})
          .eq('connection_id', connectionId)
          .neq('sender_id', userId)
          .filter('read_at', 'is', null);
    } catch (e) {
      // Silently fail - read receipts are not critical
    }
  }

  @override
  Future<List<String>> getTypingUsers(String connectionId) async {
    try {
      final response = await _client.rpc('get_typing_users', params: {
        'p_chat_id': connectionId,
      });

      if (response is List) {
        return response
            .map((u) => u['user_id'] as String?)
            .whereType<String>()
            .toList();
      }
      return [];
    } catch (e) {
      // Silently fail and return empty list
      return [];
    }
  }

  // ============================================================
  // NOTIFICATION TOKENS
  // ============================================================

  @override
  Future<void> registerNotificationToken({
    required String token,
    required String platform,
    String? deviceId,
    String? deviceName,
    String? appVersion,
    String? osVersion,
  }) async {
    final userId = _currentUserId;
    if (userId == null) {
      throw const AuthException('User not authenticated', type: AuthErrorType.unauthorized);
    }

    try {
      await _client
          .from('notification_tokens')
          .upsert({
            'user_id': userId,
            'token': token,
            'platform': platform,
            'device_id': deviceId,
            'device_name': deviceName,
            'app_version': appVersion,
            'os_version': osVersion,
            'is_active': true,
          }, onConflict: 'user_id,device_id');
    } catch (e) {
      throw ServerException(message: 'Failed to register notification token: $e');
    }
  }

  @override
  Future<void> unregisterNotificationToken(String token) async {
    try {
      await _client
          .from('notification_tokens')
          .update({'is_active': false})
          .eq('token', token);
    } catch (e) {
      throw ServerException(message: 'Failed to unregister notification token: $e');
    }
  }

  /// Fire-and-forget call to the notify-new-message edge function
  void _triggerPushNotification({
    required MessageModel message,
    required String recipientId,
  }) {
    // Run in background — don't block the send message flow
    Future.microtask(() async {
      try {
        await _client.functions.invoke(
          'notify-new-message',
          body: {
            'record': {
              'id': message.id,
              'chat_id': message.chatId,
              'sender_id': message.senderId,
              'content': message.content,
              'message_type': 'text',
              'created_at': message.createdAt.toIso8601String(),
            },
          },
        );
      } catch (e) {
      // intentional silent catch
      }
    });
  }
}
