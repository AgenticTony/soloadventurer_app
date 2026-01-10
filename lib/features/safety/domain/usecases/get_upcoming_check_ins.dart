import '../entities/check_in.dart';
import '../repositories/safety_repository.dart';

/// Use case for retrieving upcoming scheduled check-ins
class GetUpcomingCheckInsUseCase {
  final SafetyRepository _repository;

  /// Creates a new [GetUpcomingCheckInsUseCase] with the given repository
  const GetUpcomingCheckInsUseCase(this._repository);

  /// Execute the use case to get upcoming check-ins
  ///
  /// Returns all upcoming check-ins that are scheduled or active.
  /// The results are sorted by scheduled time (earliest first).
  Future<List<CheckIn>> call() => _repository.getUpcomingCheckIns();

  /// Get all check-ins regardless of status
  ///
  /// Returns all check-ins including completed, missed, scheduled, and cancelled.
  /// Useful for displaying check-in history.
  Future<List<CheckIn>> getAllCheckIns() => _repository.getAllCheckIns();

  /// Get check-ins for a specific trip
  ///
  /// Returns all check-ins associated with the given [tripId].
  Future<List<CheckIn>> getCheckInsByTrip(String tripId) =>
      _repository.getCheckInsByTrip(tripId);

  /// Get a specific check-in by ID
  ///
  /// Returns the check-in with the given [checkInId].
  /// Throws an exception if the check-in is not found.
  Future<CheckIn> getCheckInById(String checkInId) =>
      _repository.getCheckIn(checkInId);
}
