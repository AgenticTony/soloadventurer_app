import 'package:soloadventurer/features/safety/domain/entities/check_in.dart';

/// Data layer representation of [CheckIn] entity
class CheckInModel extends CheckIn {
  const CheckInModel({
    required super.id,
    required super.userId,
    required super.triggerType,
    required super.status,
    super.scheduledTime,
    super.deadline,
    super.completedAt,
    super.location,
    super.statusMessage,
    super.tripId,
    required super.notifyContactIds,
    super.alertSent = false,
    super.alertSentAt,
    super.metadata,
    required super.createdAt,
    super.updatedAt,
  });

  /// Creates a [CheckInModel] from JSON map
  factory CheckInModel.fromJson(Map<String, dynamic> json) {
    return CheckInModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      triggerType: _parseTriggerType(json['trigger_type'] as String),
      status: _parseStatus(json['status'] as String),
      scheduledTime: json['scheduled_time'] != null
          ? DateTime.parse(json['scheduled_time'] as String)
          : null,
      deadline: json['deadline'] != null
          ? DateTime.parse(json['deadline'] as String)
          : null,
      completedAt: json['completed_at'] != null
          ? DateTime.parse(json['completed_at'] as String)
          : null,
      location: json['location'] != null
          ? CheckInLocationModel.fromJson(
              json['location'] as Map<String, dynamic>)
          : null,
      statusMessage: json['status_message'] as String?,
      tripId: json['trip_id'] as String?,
      notifyContactIds:
          (json['notify_contact_ids'] as List<dynamic>).cast<String>(),
      alertSent: json['alert_sent'] as bool? ?? false,
      alertSentAt: json['alert_sent_at'] != null
          ? DateTime.parse(json['alert_sent_at'] as String)
          : null,
      metadata: json['metadata'] as Map<String, dynamic>?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  /// Converts this [CheckInModel] to JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'trigger_type': _serializeTriggerType(triggerType),
      'status': _serializeStatus(status),
      'scheduled_time': scheduledTime?.toIso8601String(),
      'deadline': deadline?.toIso8601String(),
      'completed_at': completedAt?.toIso8601String(),
      'location': location?.toJson(),
      'status_message': statusMessage,
      'trip_id': tripId,
      'notify_contact_ids': notifyContactIds,
      'alert_sent': alertSent,
      'alert_sent_at': alertSentAt?.toIso8601String(),
      'metadata': metadata,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  /// Creates a [CheckInModel] from a [CheckIn] entity
  factory CheckInModel.fromEntity(CheckIn checkIn) {
    return CheckInModel(
      id: checkIn.id,
      userId: checkIn.userId,
      triggerType: checkIn.triggerType,
      status: checkIn.status,
      scheduledTime: checkIn.scheduledTime,
      deadline: checkIn.deadline,
      completedAt: checkIn.completedAt,
      location: checkIn.location != null
          ? CheckInLocationModel.fromEntity(checkIn.location!)
          : null,
      statusMessage: checkIn.statusMessage,
      tripId: checkIn.tripId,
      notifyContactIds: checkIn.notifyContactIds,
      alertSent: checkIn.alertSent,
      alertSentAt: checkIn.alertSentAt,
      metadata: checkIn.metadata,
      createdAt: checkIn.createdAt,
      updatedAt: checkIn.updatedAt,
    );
  }

  /// Converts this model to an entity
  CheckIn toEntity() {
    return CheckIn(
      id: id,
      userId: userId,
      triggerType: triggerType,
      status: status,
      scheduledTime: scheduledTime,
      deadline: deadline,
      completedAt: completedAt,
      location: location?.toEntity(),
      statusMessage: statusMessage,
      tripId: tripId,
      notifyContactIds: notifyContactIds,
      alertSent: alertSent,
      alertSentAt: alertSentAt,
      metadata: metadata,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  static CheckInStatus _parseStatus(String value) {
    switch (value) {
      case 'scheduled':
        return CheckInStatus.scheduled;
      case 'active':
        return CheckInStatus.active;
      case 'completed':
        return CheckInStatus.completed;
      case 'missed':
        return CheckInStatus.missed;
      case 'cancelled':
        return CheckInStatus.cancelled;
      default:
        throw ArgumentError('Invalid CheckInStatus: $value');
    }
  }

  static String _serializeStatus(CheckInStatus status) {
    switch (status) {
      case CheckInStatus.scheduled:
        return 'scheduled';
      case CheckInStatus.active:
        return 'active';
      case CheckInStatus.completed:
        return 'completed';
      case CheckInStatus.missed:
        return 'missed';
      case CheckInStatus.cancelled:
        return 'cancelled';
    }
  }

  static CheckInTriggerType _parseTriggerType(String value) {
    switch (value) {
      case 'manual':
        return CheckInTriggerType.manual;
      case 'scheduled_time':
        return CheckInTriggerType.scheduledTime;
      case 'location_arrival':
        return CheckInTriggerType.locationArrival;
      case 'location_departure':
        return CheckInTriggerType.locationDeparture;
      default:
        throw ArgumentError('Invalid CheckInTriggerType: $value');
    }
  }

  static String _serializeTriggerType(CheckInTriggerType triggerType) {
    switch (triggerType) {
      case CheckInTriggerType.manual:
        return 'manual';
      case CheckInTriggerType.scheduledTime:
        return 'scheduled_time';
      case CheckInTriggerType.locationArrival:
        return 'location_arrival';
      case CheckInTriggerType.locationDeparture:
        return 'location_departure';
    }
  }
}

/// Data layer representation of [CheckInLocation] entity
class CheckInLocationModel extends CheckInLocation {
  const CheckInLocationModel({
    required super.latitude,
    required super.longitude,
    super.accuracy,
    super.altitude,
    super.address,
    super.placeName,
    required super.timestamp,
  });

  /// Creates a [CheckInLocationModel] from JSON map
  factory CheckInLocationModel.fromJson(Map<String, dynamic> json) {
    return CheckInLocationModel(
      latitude: json['latitude'] as double,
      longitude: json['longitude'] as double,
      accuracy: json['accuracy'] as double?,
      altitude: json['altitude'] as double?,
      address: json['address'] as String?,
      placeName: json['place_name'] as String?,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }

  /// Converts this [CheckInLocationModel] to JSON map
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

  /// Creates a [CheckInLocationModel] from a [CheckInLocation] entity
  factory CheckInLocationModel.fromEntity(CheckInLocation location) {
    return CheckInLocationModel(
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
  CheckInLocation toEntity() {
    return CheckInLocation(
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
