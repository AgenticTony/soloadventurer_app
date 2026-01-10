import '../entities/safety_status.dart';
import '../repositories/safety_repository.dart';

/// Use case for updating the user's safety status
class UpdateSafetyStatusUseCase {
  final SafetyRepository _repository;

  /// Creates a new [UpdateSafetyStatusUseCase] with the given repository
  const UpdateSafetyStatusUseCase(this._repository);

  /// Execute the use case to update safety status
  ///
  /// Returns the updated [SafetyStatus] containing the new status details.
  /// This can be used to manually set the user's status to safe, need help,
  /// or emergency.
  ///
  /// The [status] parameter is required and should be one of the predefined
  /// [SafetyStatusType] values. Optional [message] can be provided to give
  /// additional context about the status change.
  ///
  /// The [location] parameter can be optionally provided to include current
  /// GPS coordinates with the status update. [batteryLevel] can be included
  /// to indicate device power status.
  ///
  /// If this status update is related to a specific [safetyAlertId] or
  /// [checkInId], they can be provided for tracking purposes.
  Future<SafetyStatus> call({
    required SafetyStatusType status,
    String? message,
    SafetyStatusLocation? location,
    int? batteryLevel,
    String? safetyAlertId,
    String? checkInId,
  }) async {
    return _repository.updateSafetyStatus(
      status: status,
      message: message,
      location: location,
      batteryLevel: batteryLevel,
      safetyAlertId: safetyAlertId,
      checkInId: checkInId,
    );
  }

  /// Mark the user as safe
  ///
  /// Convenience method for setting status to [SafetyStatusType.safe].
  /// Optionally includes a [message] and current [location].
  Future<SafetyStatus> markAsSafe({
    String? message,
    SafetyStatusLocation? location,
    int? batteryLevel,
  }) async {
    return _repository.updateSafetyStatus(
      status: SafetyStatusType.safe,
      message: message,
      location: location,
      batteryLevel: batteryLevel,
    );
  }

  /// Mark the user as needing help
  ///
  /// Convenience method for setting status to [SafetyStatusType.needHelp].
  /// This is less urgent than an emergency but indicates the user requires
  /// assistance. Optionally includes a [message] and current [location].
  Future<SafetyStatus> markAsNeedHelp({
    String? message,
    SafetyStatusLocation? location,
    int? batteryLevel,
  }) async {
    return _repository.updateSafetyStatus(
      status: SafetyStatusType.needHelp,
      message: message,
      location: location,
      batteryLevel: batteryLevel,
    );
  }

  /// Mark the user as in an emergency situation
  ///
  /// Convenience method for setting status to [SafetyStatusType.emergency].
  /// This indicates a critical situation requiring immediate attention.
  /// Optionally includes a [message] and current [location].
  Future<SafetyStatus> markAsEmergency({
    String? message,
    SafetyStatusLocation? location,
    int? batteryLevel,
    String? safetyAlertId,
  }) async {
    return _repository.updateSafetyStatus(
      status: SafetyStatusType.emergency,
      message: message,
      location: location,
      batteryLevel: batteryLevel,
      safetyAlertId: safetyAlertId,
    );
  }
}
