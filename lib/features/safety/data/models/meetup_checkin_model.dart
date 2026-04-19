import '../../domain/entities/meetup_checkin.dart';

/// Data model for meetup check-in, mapping between domain entity and Supabase JSON.
class MeetupCheckinModel {
  const MeetupCheckinModel({
    required this.id,
    required this.userId,
    required this.trustedContactId,
    required this.meetupTime,
    required this.status,
    this.locationName,
    this.meetingNote,
    this.checkinBufferMins = 120,
    this.activatedAt,
    this.checkedInAt,
    this.alertedAt,
    this.cancelledAt,
    this.sosTriggeredAt,
    this.lastKnownPoint,
    this.lastKnownAt,
    required this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String userId;
  final String trustedContactId;
  final DateTime meetupTime;
  final MeetupCheckinStatus status;
  final String? locationName;
  final String? meetingNote;
  final int checkinBufferMins;
  final DateTime? activatedAt;
  final DateTime? checkedInAt;
  final DateTime? alertedAt;
  final DateTime? cancelledAt;
  final DateTime? sosTriggeredAt;
  final String? lastKnownPoint;
  final DateTime? lastKnownAt;
  final DateTime createdAt;
  final DateTime? updatedAt;

  /// Construct from a Supabase JSON map
  factory MeetupCheckinModel.fromJson(Map<String, dynamic> json) {
    return MeetupCheckinModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      trustedContactId: json['trusted_contact_id'] as String,
      meetupTime: DateTime.parse(json['meetup_time'] as String),
      status: MeetupCheckinStatus.fromString(json['status'] as String),
      locationName: json['location_name'] as String?,
      meetingNote: json['meeting_note'] as String?,
      checkinBufferMins: json['checkin_buffer_mins'] as int? ?? 120,
      activatedAt: json['activated_at'] != null
          ? DateTime.parse(json['activated_at'] as String)
          : null,
      checkedInAt: json['checked_in_at'] != null
          ? DateTime.parse(json['checked_in_at'] as String)
          : null,
      alertedAt: json['alerted_at'] != null
          ? DateTime.parse(json['alerted_at'] as String)
          : null,
      cancelledAt: json['cancelled_at'] != null
          ? DateTime.parse(json['cancelled_at'] as String)
          : null,
      sosTriggeredAt: json['sos_triggered_at'] != null
          ? DateTime.parse(json['sos_triggered_at'] as String)
          : null,
      lastKnownPoint: json['last_known_point'] as String?,
      lastKnownAt: json['last_known_at'] != null
          ? DateTime.parse(json['last_known_at'] as String)
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  /// Convert to Supabase JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'trusted_contact_id': trustedContactId,
      'meetup_time': meetupTime.toUtc().toIso8601String(),
      'status': status.toDbString(),
      'location_name': locationName,
      'meeting_note': meetingNote,
      'checkin_buffer_mins': checkinBufferMins,
      'activated_at': activatedAt?.toUtc().toIso8601String(),
      'checked_in_at': checkedInAt?.toUtc().toIso8601String(),
      'alerted_at': alertedAt?.toUtc().toIso8601String(),
      'cancelled_at': cancelledAt?.toUtc().toIso8601String(),
      'sos_triggered_at': sosTriggeredAt?.toUtc().toIso8601String(),
      'last_known_point': lastKnownPoint,
      'last_known_at': lastKnownAt?.toUtc().toIso8601String(),
      'created_at': createdAt.toUtc().toIso8601String(),
      'updated_at': updatedAt?.toUtc().toIso8601String(),
    };
  }

  /// Convert to domain entity
  MeetupCheckin toEntity() {
    return MeetupCheckin(
      id: id,
      userId: userId,
      trustedContactId: trustedContactId,
      meetupTime: meetupTime,
      status: status,
      locationName: locationName,
      meetingNote: meetingNote,
      checkinBufferMins: checkinBufferMins,
      activatedAt: activatedAt,
      checkedInAt: checkedInAt,
      alertedAt: alertedAt,
      cancelledAt: cancelledAt,
      sosTriggeredAt: sosTriggeredAt,
      lastKnownPoint: lastKnownPoint,
      lastKnownAt: lastKnownAt,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
