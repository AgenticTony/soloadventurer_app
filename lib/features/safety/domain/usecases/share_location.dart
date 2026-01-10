import '../entities/location_update.dart';
import '../repositories/safety_repository.dart';

/// Use case for sharing current location with trusted contacts
class ShareLocationUseCase {
  final SafetyRepository _repository;

  /// Creates a new [ShareLocationUseCase] with the given repository
  const ShareLocationUseCase(this._repository);

  /// Execute the use case to share location with trusted contacts
  ///
  /// Returns the created [LocationUpdate] containing the shared location details.
  /// The location can be shared as a normal update or as an emergency update.
  Future<LocationUpdate> call({
    required double latitude,
    required double longitude,
    double? accuracy,
    double? altitude,
    double? speed,
    double? heading,
    String? address,
    String? placeName,
    required List<String> shareWithContactIds,
    int? batteryLevel,
    bool isEmergency = false,
    String? emergencyAlertId,
    String? checkInId,
  }) async {
    return _repository.shareLocation(
      latitude: latitude,
      longitude: longitude,
      accuracy: accuracy,
      altitude: altitude,
      speed: speed,
      heading: heading,
      address: address,
      placeName: placeName,
      shareWithContactIds: shareWithContactIds,
      batteryLevel: batteryLevel,
      isEmergency: isEmergency,
      emergencyAlertId: emergencyAlertId,
      checkInId: checkInId,
    );
  }

  /// Share location with a single trusted contact
  ///
  /// Convenience method for sharing with a single contact.
  /// Returns the created [LocationUpdate].
  Future<LocationUpdate> shareWithContact({
    required double latitude,
    required double longitude,
    required String contactId,
    double? accuracy,
    double? altitude,
    double? speed,
    double? heading,
    String? address,
    String? placeName,
    int? batteryLevel,
    bool isEmergency = false,
    String? emergencyAlertId,
    String? checkInId,
  }) async {
    return _repository.shareLocation(
      latitude: latitude,
      longitude: longitude,
      accuracy: accuracy,
      altitude: altitude,
      speed: speed,
      heading: heading,
      address: address,
      placeName: placeName,
      shareWithContactIds: [contactId],
      batteryLevel: batteryLevel,
      isEmergency: isEmergency,
      emergencyAlertId: emergencyAlertId,
      checkInId: checkInId,
    );
  }

  /// Share emergency location with all trusted contacts
  ///
  /// Convenience method for emergency situations that shares location
  /// with all contacts and marks it as an emergency update.
  /// Returns the created [LocationUpdate].
  Future<LocationUpdate> shareEmergencyLocation({
    required double latitude,
    required double longitude,
    required List<String> contactIds,
    double? accuracy,
    double? altitude,
    double? speed,
    double? heading,
    String? address,
    String? placeName,
    int? batteryLevel,
    String? emergencyAlertId,
  }) async {
    return _repository.shareLocation(
      latitude: latitude,
      longitude: longitude,
      accuracy: accuracy,
      altitude: altitude,
      speed: speed,
      heading: heading,
      address: address,
      placeName: placeName,
      shareWithContactIds: contactIds,
      batteryLevel: batteryLevel,
      isEmergency: true,
      emergencyAlertId: emergencyAlertId,
    );
  }
}
