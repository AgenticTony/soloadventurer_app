import '../entities/check_in.dart';
import '../repositories/safety_repository.dart';

/// Use case for scheduling a check-in
class ScheduleCheckInUseCase {
  final SafetyRepository _repository;

  /// Creates a new [ScheduleCheckInUseCase] with the given repository
  const ScheduleCheckInUseCase(this._repository);

  /// Execute the use case to schedule a check-in
  ///
  /// Schedules a check-in for a specific time or location-based trigger.
  /// Trusted contacts will be notified if the check-in is not completed
  /// by the deadline.
  /// Returns the created [CheckIn] with status set to [CheckInStatus.scheduled].
  Future<CheckIn> call({
    required String userId,
    required DateTime scheduledTime,
    DateTime? deadline,
    CheckInLocation? location,
    String? statusMessage,
    List<String>? notifyContactIds,
    String? tripId,
    CheckInTriggerType? triggerType,
  }) =>
      _repository.scheduleCheckIn(
        userId: userId,
        scheduledTime: scheduledTime,
        deadline: deadline,
        location: location,
        statusMessage: statusMessage,
        notifyContactIds: notifyContactIds,
        tripId: tripId,
        triggerType: triggerType,
      );
}
