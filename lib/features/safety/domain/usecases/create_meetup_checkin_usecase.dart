import '../repositories/meetup_checkin_repository.dart';
import '../entities/meetup_checkin.dart';

/// Use case for creating a new meetup check-in
class CreateMeetupCheckinUseCase {
  final MeetupCheckinRepository _repository;

  const CreateMeetupCheckinUseCase(this._repository);

  Future<MeetupCheckin> call({
    required String trustedContactId,
    required DateTime meetupTime,
    String? locationName,
    String? meetingNote,
    int checkinBufferMins = 120,
  }) =>
      _repository.createMeetupCheckin(
        trustedContactId: trustedContactId,
        meetupTime: meetupTime,
        locationName: locationName,
        meetingNote: meetingNote,
        checkinBufferMins: checkinBufferMins,
      );
}
