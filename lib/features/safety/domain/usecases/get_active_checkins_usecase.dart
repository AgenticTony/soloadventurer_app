import '../entities/meetup_checkin.dart';
import '../repositories/meetup_checkin_repository.dart';

/// Use case for fetching active meetup check-ins
class GetActiveCheckinsUseCase {
  final MeetupCheckinRepository _repository;

  const GetActiveCheckinsUseCase(this._repository);

  Future<List<MeetupCheckin>> call() => _repository.getActiveCheckins();
}
