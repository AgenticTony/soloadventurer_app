import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:soloadventurer/features/safety/domain/entities/safety_alert.dart';

part 'safety_alert_model.freezed.dart';
part 'safety_alert_model.g.dart';

/// Model for [SafetyAlert] with JSON serialization
@freezed
class SafetyAlertModel with _$SafetyAlertModel {

  const factory SafetyAlertModel({
    required String id,
    required String userId,
    required SafetyAlertType type,
    required SafetyAlertStatus status,
    String? message,
    SafetyAlertLocation? location,
    required List<String> notifiedContactIds,
    required List<String> acknowledgedByContactIds,
    required DateTime triggeredAt,
    DateTime? firstAcknowledgedAt,
    DateTime? resolvedAt,
    DateTime? cancelledAt,
    int? batteryLevel,
    String? checkInId,
    String? tripId,
    Map<String, dynamic>? metadata,
    required DateTime createdAt,
    DateTime? updatedAt,
  }) = _SafetyAlertModel;

  factory SafetyAlertModel.fromJson(Map<String, dynamic> json) =>
      _$SafetyAlertModelFromJson(json);

  /// Convert from domain entity
  factory SafetyAlertModel.fromEntity(SafetyAlert entity) {
    return SafetyAlertModel(
      id: entity.id,
      userId: entity.userId,
      type: entity.type,
      status: entity.status,
      message: entity.message,
      location: entity.location,
      notifiedContactIds: entity.notifiedContactIds,
      acknowledgedByContactIds: entity.acknowledgedByContactIds,
      triggeredAt: entity.triggeredAt,
      firstAcknowledgedAt: entity.firstAcknowledgedAt,
      resolvedAt: entity.resolvedAt,
      cancelledAt: entity.cancelledAt,
      batteryLevel: entity.batteryLevel,
      checkInId: entity.checkInId,
      tripId: entity.tripId,
      metadata: entity.metadata,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  /// Convert to domain entity
  SafetyAlert toEntity() {
    return SafetyAlert(
      id: id,
      userId: userId,
      type: type,
      status: status,
      message: message,
      location: location,
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
}
