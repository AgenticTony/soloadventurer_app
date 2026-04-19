import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:soloadventurer/features/safety/domain/entities/check_in.dart';

part 'check_in_model.freezed.dart';
part 'check_in_model.g.dart';

/// Model for [CheckIn] with JSON serialization
@freezed
sealed class CheckInModel with _$CheckInModel {
  const CheckInModel._(); // Private constructor for custom methods

  const factory CheckInModel({
    required String id,
    required String userId,
    required CheckInTriggerType triggerType,
    required CheckInStatus status,
    DateTime? scheduledTime,
    DateTime? deadline,
    DateTime? completedAt,
    CheckInLocation? location,
    String? statusMessage,
    String? tripId,
    required List<String> notifyContactIds,
    @Default(false) bool alertSent,
    DateTime? alertSentAt,
    required DateTime createdAt,
    DateTime? updatedAt,
  }) = _CheckInModel;

  factory CheckInModel.fromJson(Map<String, dynamic> json) =>
      _$CheckInModelFromJson(json);

  /// Convert from domain entity
  factory CheckInModel.fromEntity(CheckIn entity) {
    return CheckInModel(
      id: entity.id,
      userId: entity.userId,
      triggerType: entity.triggerType,
      status: entity.status,
      scheduledTime: entity.scheduledTime,
      deadline: entity.deadline,
      completedAt: entity.completedAt,
      location: entity.location,
      statusMessage: entity.statusMessage,
      tripId: entity.tripId,
      notifyContactIds: entity.notifyContactIds,
      alertSent: entity.alertSent,
      alertSentAt: entity.alertSentAt,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  /// Convert to domain entity
  CheckIn toEntity() {
    return CheckIn(
      id: id,
      userId: userId,
      triggerType: triggerType,
      status: status,
      scheduledTime: scheduledTime,
      deadline: deadline,
      completedAt: completedAt,
      location: location,
      statusMessage: statusMessage,
      tripId: tripId,
      notifyContactIds: notifyContactIds,
      alertSent: alertSent,
      alertSentAt: alertSentAt,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
