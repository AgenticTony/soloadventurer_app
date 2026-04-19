import '../entities/meetup_checkin.dart';

/// Repository interface for meetup check-in operations
abstract class MeetupCheckinRepository {
  /// Create a new meetup check-in
  Future<MeetupCheckin> createMeetupCheckin({
    required String trustedContactId,
    required DateTime meetupTime,
    String? locationName,
    String? meetingNote,
    int checkinBufferMins = 120,
  });

  /// Mark a check-in as safe (user checked in)
  Future<void> checkIn(String checkinId);

  /// Trigger SOS on a check-in, optionally with current location
  Future<void> triggerSOS(String checkinId, {double? lat, double? lon});

  /// Cancel a check-in
  Future<void> cancelCheckin(String checkinId);

  /// Get all active check-ins for the current user
  Future<List<MeetupCheckin>> getActiveCheckins();

  /// Get check-in history for the current user
  Future<List<MeetupCheckin>> getCheckinHistory();
}
