import 'package:supabase_flutter/supabase_flutter.dart' hide AuthException;
import 'package:soloadventurer/core/errors/exceptions.dart';
import 'package:soloadventurer/core/utils/json_helpers.dart';
import '../../domain/entities/meetup_checkin.dart';
import '../models/meetup_checkin_model.dart';

/// Abstract interface for meetup check-in remote data operations
abstract class MeetupCheckinRemoteDataSource {
  /// Create a new meetup check-in
  Future<MeetupCheckin> createMeetupCheckin({
    required String userId,
    required String trustedContactId,
    required DateTime meetupTime,
    String? locationName,
    String? meetingNote,
    int checkinBufferMins = 120,
  });

  /// Mark a check-in as safe
  Future<void> checkIn(String checkinId);

  /// Trigger SOS on a check-in
  Future<void> triggerSOS(String checkinId, {double? lat, double? lon});

  /// Cancel a check-in
  Future<void> cancelCheckin(String checkinId);

  /// Get all active check-ins for the current user
  Future<List<MeetupCheckin>> getActiveCheckins();

  /// Get check-in history
  Future<List<MeetupCheckin>> getCheckinHistory();
}

/// Supabase implementation of [MeetupCheckinRemoteDataSource]
class MeetupCheckinRemoteDataSourceImpl implements MeetupCheckinRemoteDataSource {
  MeetupCheckinRemoteDataSourceImpl({required SupabaseClient client}) : _client = client;

  final SupabaseClient _client;

  static const _table = 'meetup_checkins';

  @override
  Future<MeetupCheckin> createMeetupCheckin({
    required String userId,
    required String trustedContactId,
    required DateTime meetupTime,
    String? locationName,
    String? meetingNote,
    int checkinBufferMins = 120,
  }) async {
    try {
      final response = await _client.from(_table).insert({
        'user_id': userId,
        'trusted_contact_id': trustedContactId,
        'meetup_time': meetupTime.toUtc().toIso8601String(),
        'location_name': locationName,
        'meeting_note': meetingNote,
        'checkin_buffer_mins': checkinBufferMins,
        'status': 'scheduled',
      }).select().single();

      return MeetupCheckinModel.fromJson(response).toEntity();
    } on PostgrestException catch (e) {
      if (e.code == '23505') {
        throw const ConflictException(
          message: 'Meetup check-in already exists',
        );
      }
      throw ServerException(
        message: 'Failed to create meetup check-in: ${e.message}',
        statusCode: JsonHelpers.parseIntOrDefault(e.code, defaultValue: 500),
      );
    } catch (e) {
      throw ServerException(
        message: 'Failed to create meetup check-in: $e',
        statusCode: 500,
      );
    }
  }

  @override
  Future<void> checkIn(String checkinId) async {
    try {
      await _client.from(_table).update({
        'status': 'checked_in',
        'checked_in_at': DateTime.now().toUtc().toIso8601String(),
        'updated_at': DateTime.now().toUtc().toIso8601String(),
      }).eq('id', checkinId);
    } on PostgrestException catch (e) {
      throw ServerException(
        message: 'Failed to check in: ${e.message}',
        statusCode: JsonHelpers.parseIntOrDefault(e.code, defaultValue: 500),
      );
    } catch (e) {
      throw ServerException(
        message: 'Failed to check in: $e',
        statusCode: 500,
      );
    }
  }

  @override
  Future<void> triggerSOS(String checkinId, {double? lat, double? lon}) async {
    try {
      final updates = <String, dynamic>{
        'status': 'sos',
        'sos_triggered_at': DateTime.now().toUtc().toIso8601String(),
        'updated_at': DateTime.now().toUtc().toIso8601String(),
      };

      if (lat != null && lon != null) {
        updates['last_known_point'] = 'SRID=4326;POINT($lon $lat)';
        updates['last_known_at'] = DateTime.now().toUtc().toIso8601String();
      }

      await _client.from(_table).update(updates).eq('id', checkinId);
    } on PostgrestException catch (e) {
      throw ServerException(
        message: 'Failed to trigger SOS: ${e.message}',
        statusCode: JsonHelpers.parseIntOrDefault(e.code, defaultValue: 500),
      );
    } catch (e) {
      throw ServerException(
        message: 'Failed to trigger SOS: $e',
        statusCode: 500,
      );
    }
  }

  @override
  Future<void> cancelCheckin(String checkinId) async {
    try {
      await _client.from(_table).update({
        'status': 'cancelled',
        'cancelled_at': DateTime.now().toUtc().toIso8601String(),
        'updated_at': DateTime.now().toUtc().toIso8601String(),
      }).eq('id', checkinId);
    } on PostgrestException catch (e) {
      throw ServerException(
        message: 'Failed to cancel check-in: ${e.message}',
        statusCode: JsonHelpers.parseIntOrDefault(e.code, defaultValue: 500),
      );
    } catch (e) {
      throw ServerException(
        message: 'Failed to cancel check-in: $e',
        statusCode: 500,
      );
    }
  }

  @override
  Future<List<MeetupCheckin>> getActiveCheckins() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) {
      throw const UnauthorizedException(
        message: 'User must be authenticated',
      );
    }

    try {
      final response = await _client
          .from(_table)
          .select()
          .eq('user_id', userId)
          .inFilter('status', ['scheduled', 'active'])
          .order('meetup_time', ascending: true);

      return (response as List)
          .map((json) =>
              MeetupCheckinModel.fromJson(json as Map<String, dynamic>).toEntity())
          .toList();
    } on PostgrestException catch (e) {
      throw ServerException(
        message: 'Failed to get active check-ins: ${e.message}',
        statusCode: JsonHelpers.parseIntOrDefault(e.code, defaultValue: 500),
      );
    } catch (e) {
      throw ServerException(
        message: 'Failed to get active check-ins: $e',
        statusCode: 500,
      );
    }
  }

  @override
  Future<List<MeetupCheckin>> getCheckinHistory() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) {
      throw const UnauthorizedException(
        message: 'User must be authenticated',
      );
    }

    try {
      final response = await _client
          .from(_table)
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false)
          .limit(50);

      return (response as List)
          .map((json) =>
              MeetupCheckinModel.fromJson(json as Map<String, dynamic>).toEntity())
          .toList();
    } on PostgrestException catch (e) {
      throw ServerException(
        message: 'Failed to get check-in history: ${e.message}',
        statusCode: JsonHelpers.parseIntOrDefault(e.code, defaultValue: 500),
      );
    } catch (e) {
      throw ServerException(
        message: 'Failed to get check-in history: $e',
        statusCode: 500,
      );
    }
  }
}

