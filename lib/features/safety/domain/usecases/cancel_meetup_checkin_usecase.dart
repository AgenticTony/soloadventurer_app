import '../repositories/meetup_checkin_repository.dart';

/// Use case for cancelling a meetup check-in
class CancelMeetupCheckinUseCase {
  final MeetupCheckinRepository _repository;

  const CancelMeetupCheckinUseCase(this._repository);

  Future<void> call(String checkinId) =>
      _repository.cancelCheckin(checkinId);
}
