import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:soloadventurer/core/errors/exceptions.dart';
import '../../domain/entities/meetup_checkin.dart';
import '../../domain/repositories/meetup_checkin_repository.dart';
import '../datasources/meetup_checkin_remote_data_source.dart';

/// Implementation of [MeetupCheckinRepository] using Supabase
class MeetupCheckinRepositoryImpl implements MeetupCheckinRepository {
  MeetupCheckinRepositoryImpl({
    required MeetupCheckinRemoteDataSource remoteDataSource,
  }) : _remoteDataSource = remoteDataSource;

  final MeetupCheckinRemoteDataSource _remoteDataSource;

  /// Get the current authenticated user's ID
  /// Throws [UnauthorizedException] if no user is authenticated
  String _requireCurrentUserId() {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) {
      throw const UnauthorizedException(
        message: 'User must be authenticated to perform meetup check-in operations',
      );
    }
    return userId;
  }

  @override
  Future<MeetupCheckin> createMeetupCheckin({
    required String trustedContactId,
    required DateTime meetupTime,
    String? locationName,
    String? meetingNote,
    int checkinBufferMins = 120,
  }) async {
    final userId = _requireCurrentUserId();
    return _remoteDataSource.createMeetupCheckin(
      userId: userId,
      trustedContactId: trustedContactId,
      meetupTime: meetupTime,
      locationName: locationName,
      meetingNote: meetingNote,
      checkinBufferMins: checkinBufferMins,
    );
  }

  @override
  Future<void> checkIn(String checkinId) =>
      _remoteDataSource.checkIn(checkinId);

  @override
  Future<void> triggerSOS(String checkinId, {double? lat, double? lon}) =>
      _remoteDataSource.triggerSOS(checkinId, lat: lat, lon: lon);

  @override
  Future<void> cancelCheckin(String checkinId) =>
      _remoteDataSource.cancelCheckin(checkinId);

  @override
  Future<List<MeetupCheckin>> getActiveCheckins() =>
      _remoteDataSource.getActiveCheckins();

  @override
  Future<List<MeetupCheckin>> getCheckinHistory() =>
      _remoteDataSource.getCheckinHistory();
}
