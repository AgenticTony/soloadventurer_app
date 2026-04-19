import '../repositories/meetup_checkin_repository.dart';

/// Use case for triggering SOS on a meetup check-in
class TriggerSOSUseCase {
  final MeetupCheckinRepository _repository;

  const TriggerSOSUseCase(this._repository);

  Future<void> call(String checkinId, {double? lat, double? lon}) =>
      _repository.triggerSOS(checkinId, lat: lat, lon: lon);
}
