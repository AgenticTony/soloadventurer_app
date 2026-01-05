import '../entities/check_in.dart';
import '../repositories/safety_repository.dart';

/// Use case for completing a check-in manually
class CompleteCheckInUseCase {
  final SafetyRepository _repository;

  /// Creates a new [CompleteCheckInUseCase] with the given repository
  const CompleteCheckInUseCase(this._repository);

  /// Execute the use case to complete a check-in
  ///
  /// Marks a check-in as completed with the current location and optional
  /// status message. The location is required to provide trusted contacts
  /// with the user's whereabouts at check-in time.
  /// Returns the updated [CheckIn] with status set to [CheckInStatus.completed].
  Future<CheckIn> call({
    required String checkInId,
    required CheckInLocation location,
    String? statusMessage,
  }) =>
      _repository.completeCheckIn(
        checkInId: checkInId,
        location: location,
        statusMessage: statusMessage,
      );
}
