import '../entities/safety_status.dart';
import '../repositories/safety_repository.dart';

/// Use case for retrieving the user's safety status
class GetSafetyStatusUseCase {
  final SafetyRepository _repository;

  /// Creates a new [GetSafetyStatusUseCase] with the given repository
  const GetSafetyStatusUseCase(this._repository);

  /// Execute the use case to get the current user's safety status
  ///
  /// Returns the current [SafetyStatus] for the authenticated user.
  /// This includes the status type (safe, need help, emergency), optional
  /// message, location, and timestamp information.
  Future<SafetyStatus> call() => _repository.getSafetyStatus();

  /// Get the safety status for a specific user
  ///
  /// This can be used by trusted contacts to check the status of another user.
  /// Requires the [userId] of the user whose status is being requested.
  ///
  /// Returns the latest [SafetyStatus] for the specified user.
  Future<SafetyStatus> forUser(String userId) =>
      _repository.getSafetyStatusForUser(userId);
}
