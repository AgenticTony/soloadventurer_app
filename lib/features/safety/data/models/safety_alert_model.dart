import 'package:soloadventurer/features/safety/domain/entities/safety_alert.dart';

/// Data layer representation of [SafetyAlert] entity
class SafetyAlertModel extends SafetyAlert {
  const SafetyAlertModel({
    required super.id,
    required super.userId,
    required super.type,
    required super.status,
    super.message,
    super.location,
    required super.notifiedContactIds,
    required super.acknowledgedByContactIds,
    required super.triggeredAt,
    super.firstAcknowledgedAt,
    super.resolvedAt,
    super.cancelledAt,
    super.batteryLevel,
    super.checkInId,
    super.tripId,
    super.metadata,
    required super.createdAt,
    super.updatedAt,
  });

  /// Creates a [SafetyAlertModel] from JSON map
  factory SafetyAlertModel.fromJson(Map<String, dynamic> json) {
    return SafetyAlertModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      type: _parseAlertType(json['type'] as String),
      status: _parseAlertStatus(json['status'] as String),
      message: json['message'] as String?,
      location: json['location'] != null
          ? SafetyAlertLocationModel.fromJson(
              json['location'] as Map<String, dynamic>)
          : null,
      notifiedContactIds:
          (json['notified_contact_ids'] as List<dynamic>).cast<String>(),
      acknowledgedByContactIds:
          (json['acknowledged_by_contact_ids'] as List<dynamic>).cast<String>(),
      triggeredAt: DateTime.parse(json['triggered_at'] as String),
      firstAcknowledgedAt: json['first_acknowledged_at'] != null
          ? DateTime.parse(json['first_acknowledged_at'] as String)
          : null,
      resolvedAt: json['resolved_at'] != null
          ? DateTime.parse(json['resolved_at'] as String)
          : null,
      cancelledAt: json['cancelled_at'] != null
          ? DateTime.parse(json['cancelled_at'] as String)
          : null,
      batteryLevel: json['battery_level'] as int?,
      checkInId: json['check_in_id'] as String?,
      tripId: json['trip_id'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  /// Converts this [SafetyAlertModel] to JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'type': _serializeAlertType(type),
      'status': _serializeAlertStatus(status),
      'message': message,
      'location': location?.toJson(),
      'notified_contact_ids': notifiedContactIds,
      'acknowledged_by_contact_ids': acknowledgedByContactIds,
      'triggered_at': triggeredAt.toIso8601String(),
      'first_acknowledged_at': firstAcknowledgedAt?.toIso8601String(),
      'resolved_at': resolvedAt?.toIso8601String(),
      'cancelled_at': cancelledAt?.toIso8601String(),
      'battery_level': batteryLevel,
      'check_in_id': checkInId,
      'trip_id': tripId,
      'metadata': metadata,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  /// Creates a [SafetyAlertModel] from a [SafetyAlert] entity
  factory SafetyAlertModel.fromEntity(SafetyAlert alert) {
    return SafetyAlertModel(
      id: alert.id,
      userId: alert.userId,
      type: alert.type,
      status: alert.status,
      message: alert.message,
      location: alert.location != null
          ? SafetyAlertLocationModel.fromEntity(alert.location!)
          : null,
      notifiedContactIds: alert.notifiedContactIds,
      acknowledgedByContactIds: alert.acknowledgedByContactIds,
      triggeredAt: alert.triggeredAt,
      firstAcknowledgedAt: alert.firstAcknowledgedAt,
      resolvedAt: alert.resolvedAt,
      cancelledAt: alert.cancelledAt,
      batteryLevel: alert.batteryLevel,
      checkInId: alert.checkInId,
      tripId: alert.tripId,
      metadata: alert.metadata,
      createdAt: alert.createdAt,
      updatedAt: alert.updatedAt,
    );
  }

  /// Converts this model to an entity
  SafetyAlert toEntity() {
    return SafetyAlert(
      id: id,
      userId: userId,
      type: type,
      status: status,
      message: message,
      location: location?.toEntity(),
      notifiedContactIds: notifiedContactIds,
      acknowledgedByContactIds: acknowledgedByContactIds,
      triggeredAt: triggeredAt,
      firstAcknowledgedAt: firstAcknowledgedAt,
      resolvedAt: resolvedAt,
      cancelledAt: cancelledAt,
      batteryLevel: batteryLevel,
      checkInId: checkInId,
      tripId: tripId,
      metadata: metadata,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  static SafetyAlertType _parseAlertType(String value) {
    switch (value) {
      case 'emergency_sos':
        return SafetyAlertType.emergencySOS;
      case 'need_help':
        return SafetyAlertType.needHelp;
      case 'emergency':
        return SafetyAlertType.emergency;
      case 'missed_check_in':
        return SafetyAlertType.missedCheckIn;
      case 'location_update':
        return SafetyAlertType.locationUpdate;
      case 'safe':
        return SafetyAlertType.safe;
      default:
        throw ArgumentError('Invalid SafetyAlertType: $value');
    }
  }

  static String _serializeAlertType(SafetyAlertType type) {
    switch (type) {
      case SafetyAlertType.emergencySOS:
        return 'emergency_sos';
      case SafetyAlertType.needHelp:
        return 'need_help';
      case SafetyAlertType.emergency:
        return 'emergency';
      case SafetyAlertType.missedCheckIn:
        return 'missed_check_in';
      case SafetyAlertType.locationUpdate:
        return 'location_update';
      case SafetyAlertType.safe:
        return 'safe';
    }
  }

  static SafetyAlertStatus _parseAlertStatus(String value) {
    switch (value) {
      case 'sent':
        return SafetyAlertStatus.sent;
      case 'acknowledged':
        return SafetyAlertStatus.acknowledged;
      case 'resolved':
        return SafetyAlertStatus.resolved;
      case 'cancelled':
        return SafetyAlertStatus.cancelled;
      default:
        throw ArgumentError('Invalid SafetyAlertStatus: $value');
    }
  }

  static String _serializeAlertStatus(SafetyAlertStatus status) {
    switch (status) {
      case SafetyAlertStatus.sent:
        return 'sent';
      case SafetyAlertStatus.acknowledged:
        return 'acknowledged';
      case SafetyAlertStatus.resolved:
        return 'resolved';
      case SafetyAlertStatus.cancelled:
        return 'cancelled';
    }
  }
}

/// Data layer representation of [SafetyAlertLocation] entity
class SafetyAlertLocationModel extends SafetyAlertLocation {
  const SafetyAlertLocationModel({
    required super.latitude,
    required super.longitude,
    super.accuracy,
    super.altitude,
    super.address,
    super.placeName,
    required super.timestamp,
    super.mapsUrl,
  });

  /// Creates a [SafetyAlertLocationModel] from JSON map
  factory SafetyAlertLocationModel.fromJson(Map<String, dynamic> json) {
    return SafetyAlertLocationModel(
      latitude: json['latitude'] as double,
      longitude: json['longitude'] as double,
      accuracy: json['accuracy'] as double?,
      altitude: json['altitude'] as double?,
      address: json['address'] as String?,
      placeName: json['place_name'] as String?,
      timestamp: DateTime.parse(json['timestamp'] as String),
      mapsUrl: json['maps_url'] as String?,
    );
  }

  /// Converts this [SafetyAlertLocationModel] to JSON map
  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'accuracy': accuracy,
      'altitude': altitude,
      'address': address,
      'place_name': placeName,
      'timestamp': timestamp.toIso8601String(),
      'maps_url': mapsUrl,
    };
  }

  /// Creates a [SafetyAlertLocationModel] from a [SafetyAlertLocation] entity
  factory SafetyAlertLocationModel.fromEntity(SafetyAlertLocation location) {
    return SafetyAlertLocationModel(
      latitude: location.latitude,
      longitude: location.longitude,
      accuracy: location.accuracy,
      altitude: location.altitude,
      address: location.address,
      placeName: location.placeName,
      timestamp: location.timestamp,
      mapsUrl: location.mapsUrl,
    );
  }

  /// Converts this model to an entity
  SafetyAlertLocation toEntity() {
    return SafetyAlertLocation(
      latitude: latitude,
      longitude: longitude,
      accuracy: accuracy,
      altitude: altitude,
      address: address,
      placeName: placeName,
      timestamp: timestamp,
      mapsUrl: mapsUrl,
    );
  }
}
