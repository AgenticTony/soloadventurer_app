import '../entities/check_in.dart';
import '../repositories/safety_repository.dart';

/// Use case for creating a new check-in (manual or scheduled)
class CreateCheckInUseCase {
  final SafetyRepository _repository;

  /// Creates a new [CreateCheckInUseCase] with the given repository
  const CreateCheckInUseCase(this._repository);

  /// Execute the use case to create a check-in
  ///
  /// Creates a new check-in with the provided data. The check-in can be
  /// manual (triggered by user action) or scheduled (triggered by time or location).
  /// Returns the created [CheckIn] with generated ID and timestamps.
  Future<CheckIn> call(CheckIn checkIn) => _repository.createCheckIn(checkIn);
}
