import '../repositories/safety_repository.dart';

/// Use case for cancelling a scheduled check-in
class CancelCheckInUseCase {
  final SafetyRepository _repository;

  /// Creates a new [CancelCheckInUseCase] with the given repository
  const CancelCheckInUseCase(this._repository);

  /// Execute the use case to cancel a check-in
  ///
  /// Cancels a scheduled check-in that has not yet been completed.
  /// The check-in status will be set to [CheckInStatus.cancelled].
  /// Throws an exception if the check-in is already completed or missed.
  Future<void> call(String checkInId) => _repository.cancelCheckIn(checkInId);
}
