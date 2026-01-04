import 'package:soloadventurer/features/safety/domain/entities/safety_status.dart';

/// Data layer representation of [SafetyStatus] entity
class SafetyStatusModel extends SafetyStatus {
  const SafetyStatusModel({
    required super.id,
    required super.userId,
    required super.status,
    super.message,
    super.location,
    super.batteryLevel,
    required super.timestamp,
    super.updatedAt,
    super.safetyAlertId,
    super.checkInId,
    super.metadata,
  });

  /// Creates a [SafetyStatusModel] from JSON map
  factory SafetyStatusModel.fromJson(Map<String, dynamic> json) {
    return SafetyStatusModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      status: _parseStatusType(json['status'] as String),
      message: json['message'] as String?,
      location: json['location'] != null
          ? SafetyStatusLocationModel.fromJson(
              json['location'] as Map<String, dynamic>)
          : null,
      batteryLevel: json['battery_level'] as int?,
      timestamp: DateTime.parse(json['timestamp'] as String),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
      safetyAlertId: json['safety_alert_id'] as String?,
      checkInId: json['check_in_id'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  /// Converts this [SafetyStatusModel] to JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'status': _serializeStatusType(status),
      'message': message,
      'location': location?.toJson(),
      'battery_level': batteryLevel,
      'timestamp': timestamp.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'safety_alert_id': safetyAlertId,
      'check_in_id': checkInId,
      'metadata': metadata,
    };
  }

  /// Creates a [SafetyStatusModel] from a [SafetyStatus] entity
  factory SafetyStatusModel.fromEntity(SafetyStatus safetyStatus) {
    return SafetyStatusModel(
      id: safetyStatus.id,
      userId: safetyStatus.userId,
      status: safetyStatus.status,
      message: safetyStatus.message,
      location: safetyStatus.location != null
          ? SafetyStatusLocationModel.fromEntity(safetyStatus.location!)
          : null,
      batteryLevel: safetyStatus.batteryLevel,
      timestamp: safetyStatus.timestamp,
      updatedAt: safetyStatus.updatedAt,
      safetyAlertId: safetyStatus.safetyAlertId,
      checkInId: safetyStatus.checkInId,
      metadata: safetyStatus.metadata,
    );
  }

  /// Converts this model to an entity
  SafetyStatus toEntity() {
    return SafetyStatus(
      id: id,
      userId: userId,
      status: status,
      message: message,
      location: location?.toEntity(),
      batteryLevel: batteryLevel,
      timestamp: timestamp,
      updatedAt: updatedAt,
      safetyAlertId: safetyAlertId,
      checkInId: checkInId,
      metadata: metadata,
    );
  }

  static SafetyStatusType _parseStatusType(String value) {
    switch (value) {
      case 'safe':
        return SafetyStatusType.safe;
      case 'need_help':
        return SafetyStatusType.needHelp;
      case 'emergency':
        return SafetyStatusType.emergency;
      case 'unknown':
        return SafetyStatusType.unknown;
      default:
        throw ArgumentError('Invalid SafetyStatusType: $value');
    }
  }

  static String _serializeStatusType(SafetyStatusType status) {
    switch (status) {
      case SafetyStatusType.safe:
        return 'safe';
      case SafetyStatusType.needHelp:
        return 'need_help';
      case SafetyStatusType.emergency:
        return 'emergency';
      case SafetyStatusType.unknown:
        return 'unknown';
    }
  }
}

/// Data layer representation of [SafetyStatusLocation] entity
class SafetyStatusLocationModel extends SafetyStatusLocation {
  const SafetyStatusLocationModel({
    required super.latitude,
    required super.longitude,
    super.accuracy,
    super.altitude,
    super.address,
    super.placeName,
    required super.timestamp,
  });

  /// Creates a [SafetyStatusLocationModel] from JSON map
  factory SafetyStatusLocationModel.fromJson(Map<String, dynamic> json) {
    return SafetyStatusLocationModel(
      latitude: json['latitude'] as double,
      longitude: json['longitude'] as double,
      accuracy: json['accuracy'] as double?,
      altitude: json['altitude'] as double?,
      address: json['address'] as String?,
      placeName: json['place_name'] as String?,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }

  /// Converts this [SafetyStatusLocationModel] to JSON map
  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'accuracy': accuracy,
      'altitude': altitude,
      'address': address,
      'place_name': placeName,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  /// Creates a [SafetyStatusLocationModel] from a [SafetyStatusLocation] entity
  factory SafetyStatusLocationModel.fromEntity(SafetyStatusLocation location) {
    return SafetyStatusLocationModel(
      latitude: location.latitude,
      longitude: location.longitude,
      accuracy: location.accuracy,
      altitude: location.altitude,
      address: location.address,
      placeName: location.placeName,
      timestamp: location.timestamp,
    );
  }

  /// Converts this model to an entity
  SafetyStatusLocation toEntity() {
    return SafetyStatusLocation(
      latitude: latitude,
      longitude: longitude,
      accuracy: accuracy,
      altitude: altitude,
      address: address,
      placeName: placeName,
      timestamp: timestamp,
    );
  }
}
