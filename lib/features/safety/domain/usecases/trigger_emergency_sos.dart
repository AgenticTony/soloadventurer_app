import '../entities/safety_alert.dart';
import '../repositories/safety_repository.dart';

/// Use case for triggering an emergency SOS alert
class TriggerEmergencySOSUseCase {
  final SafetyRepository _repository;

  /// Creates a new [TriggerEmergencySOSUseCase] with the given repository
  const TriggerEmergencySOSUseCase(this._repository);

  /// Execute the use case to trigger an emergency SOS alert
  ///
  /// Returns the created [SafetyAlert] containing the alert details.
  /// This will notify all trusted contacts and share the user's current location.
  ///
  /// The [location] parameter is required and should contain the user's current
  /// GPS coordinates. Optional [message] can be provided to give additional context
  /// about the emergency. [notifyContactIds] specifies which trusted contacts
  /// should be notified - if not provided, all trusted contacts will be notified.
  ///
  /// The [batteryLevel] can be optionally provided to help contacts understand
  /// how long the user's device will remain operational. [tripId] can be associated
  /// if the emergency is related to a specific trip.
  Future<SafetyAlert> call({
    required String userId,
    String? message,
    required SafetyAlertLocation location,
    required List<String> notifyContactIds,
    int? batteryLevel,
    String? tripId,
  }) async {
    return _repository.triggerEmergencySOS(
      userId: userId,
      message: message,
      location: location,
      notifyContactIds: notifyContactIds,
      batteryLevel: batteryLevel,
      tripId: tripId,
    );
  }
}
