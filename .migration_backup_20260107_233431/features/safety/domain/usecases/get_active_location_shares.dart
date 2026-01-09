import '../entities/location_update.dart';
import '../repositories/safety_repository.dart';

/// Use case for retrieving active location shares
class GetActiveLocationSharesUseCase {
  final SafetyRepository _repository;

  /// Creates a new [GetActiveLocationSharesUseCase] with the given repository
  const GetActiveLocationSharesUseCase(this._repository);

  /// Execute the use case to get all currently active location shares
  ///
  /// Returns a list of [LocationUpdate] objects that represent currently
  /// active location shares (status is [LocationSharingStatus.active]).
  Future<List<LocationUpdate>> call() => _repository.getActiveLocationShares();

  /// Get recent location updates
  ///
  /// Returns a list of recent location updates with optional filtering.
  /// By default returns the 20 most recent updates.
  ///
  /// Parameters:
  /// - [limit] Maximum number of updates to return (default: 20)
  /// - [startDate] Optional start date for filtering updates
  /// - [endDate] Optional end date for filtering updates
  Future<List<LocationUpdate>> getRecentUpdates({
    int limit = 20,
    DateTime? startDate,
    DateTime? endDate,
  }) =>
      _repository.getLocationUpdates(
        limit: limit,
        startDate: startDate,
        endDate: endDate,
      );

  /// Get location updates for a specific contact
  ///
  /// Returns a list of active location updates that are being shared
  /// with the specified [contactId].
  Future<List<LocationUpdate>> getSharesForContact(String contactId) async {
    final allShares = await _repository.getActiveLocationShares();
    return allShares
        .where((update) => update.sharedWithContactIds.contains(contactId))
        .toList();
  }

  /// Get emergency location updates
  ///
  /// Returns a list of active location updates that are marked as emergency updates.
  Future<List<LocationUpdate>> getEmergencyShares() async {
    final allShares = await _repository.getActiveLocationShares();
    return allShares.where((update) => update.isEmergency).toList();
  }

  /// Get location updates for a specific check-in
  ///
  /// Returns active location updates associated with the specified [checkInId].
  Future<List<LocationUpdate>> getSharesForCheckIn(String checkInId) async {
    final allShares = await _repository.getActiveLocationShares();
    return allShares
        .where((update) => update.checkInId == checkInId)
        .toList();
  }

  /// Get location updates for an emergency alert
  ///
  /// Returns active location updates associated with the specified [emergencyAlertId].
  Future<List<LocationUpdate>> getSharesForEmergencyAlert(
      String emergencyAlertId) async {
    final allShares = await _repository.getActiveLocationShares();
    return allShares
        .where((update) => update.emergencyAlertId == emergencyAlertId)
        .toList();
  }
}
