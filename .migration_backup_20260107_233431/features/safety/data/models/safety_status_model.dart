import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:soloadventurer/features/safety/domain/entities/safety_status.dart';

part 'safety_status_model.freezed.dart';
part 'safety_status_model.g.dart';

/// Model for [SafetyStatus] with JSON serialization
@freezed
class SafetyStatusModel with _$SafetyStatusModel {
  const SafetyStatusModel._();

  const factory SafetyStatusModel({
    required String id,
    required String userId,
    required SafetyStatusType statusType,
    String? message,
    SafetyStatusLocation? location,
    int? batteryLevel,
    required DateTime timestamp,
    DateTime? updatedAt,
    String? safetyAlertId,
    String? checkInId,
    Map<String, dynamic>? metadata,
  }) = _SafetyStatusModel;

  factory SafetyStatusModel.fromJson(Map<String, dynamic> json) =>
      _$SafetyStatusModelFromJson(json);

  /// Convert from domain entity
  factory SafetyStatusModel.fromEntity(SafetyStatus entity) {
    return SafetyStatusModel(
      id: entity.id,
      userId: entity.userId,
      statusType: entity.statusType,
      message: entity.message,
      location: entity.location,
      batteryLevel: entity.batteryLevel,
      timestamp: entity.timestamp,
      updatedAt: entity.updatedAt,
      safetyAlertId: entity.safetyAlertId,
      checkInId: entity.checkInId,
      metadata: entity.metadata,
    );
  }

  /// Convert to domain entity
  SafetyStatus toEntity() {
    return SafetyStatus(
      id: id,
      userId: userId,
      statusType: statusType,
      message: message,
      location: location,
      batteryLevel: batteryLevel,
      timestamp: timestamp,
      updatedAt: updatedAt,
      safetyAlertId: safetyAlertId,
      checkInId: checkInId,
      metadata: metadata,
    );
  }
}
