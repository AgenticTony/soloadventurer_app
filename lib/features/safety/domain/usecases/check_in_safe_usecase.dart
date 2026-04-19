import '../repositories/meetup_checkin_repository.dart';

/// Use case for marking a meetup check-in as safe
class CheckInSafeUseCase {
  final MeetupCheckinRepository _repository;

  const CheckInSafeUseCase(this._repository);

  Future<void> call(String checkinId) =>
      _repository.checkIn(checkinId);
}
