/// State machine for meetup safety check-ins:
///   scheduled -> active -> checked_in OR alerted -> sos
///   cancelled (any state)
enum MeetupCheckinStatus {
  scheduled,
  active,
  checkedIn,
  alerted,
  sos,
  cancelled;

  /// Parse from Supabase status string
  static MeetupCheckinStatus fromString(String value) {
    switch (value) {
      case 'scheduled':
        return MeetupCheckinStatus.scheduled;
      case 'active':
        return MeetupCheckinStatus.active;
      case 'checked_in':
        return MeetupCheckinStatus.checkedIn;
      case 'alerted':
        return MeetupCheckinStatus.alerted;
      case 'sos':
        return MeetupCheckinStatus.sos;
      case 'cancelled':
        return MeetupCheckinStatus.cancelled;
      default:
        throw ArgumentError('Unknown MeetupCheckinStatus: $value');
    }
  }

  /// Convert to Supabase enum string
  String toDbString() {
    switch (this) {
      case MeetupCheckinStatus.scheduled:
        return 'scheduled';
      case MeetupCheckinStatus.active:
        return 'active';
      case MeetupCheckinStatus.checkedIn:
        return 'checked_in';
      case MeetupCheckinStatus.alerted:
        return 'alerted';
      case MeetupCheckinStatus.sos:
        return 'sos';
      case MeetupCheckinStatus.cancelled:
        return 'cancelled';
    }
  }
}

/// Represents a meetup safety check-in entry from the meetup_checkins table.
///
/// State machine: scheduled -> active -> checked_in OR alerted -> sos
/// Any state can transition to cancelled.
class MeetupCheckin {
  const MeetupCheckin({
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

  /// Unique identifier
  final String id;

  /// User who created this check-in
  final String userId;

  /// Trusted contact who will be notified
  final String trustedContactId;

  /// When the meetup is scheduled
  final DateTime meetupTime;

  /// Current state in the state machine
  final MeetupCheckinStatus status;

  /// Optional location description
  final String? locationName;

  /// Optional note about the meeting
  final String? meetingNote;

  /// Minutes after meetup_time before auto-alert (default 120)
  final int checkinBufferMins;

  /// When status changed to active
  final DateTime? activatedAt;

  /// When user confirmed safe
  final DateTime? checkedInAt;

  /// When alert was triggered (by pg_cron)
  final DateTime? alertedAt;

  /// When user cancelled
  final DateTime? cancelledAt;

  /// When SOS was triggered
  final DateTime? sosTriggeredAt;

  /// Last known GPS point (PostGIS)
  final String? lastKnownPoint;

  /// When last known location was recorded
  final DateTime? lastKnownAt;

  /// When this record was created
  final DateTime createdAt;

  /// When this record was last updated
  final DateTime? updatedAt;

  /// Whether the check-in is currently active (not completed/cancelled)
  bool get isActive =>
      status == MeetupCheckinStatus.scheduled ||
      status == MeetupCheckinStatus.active;

  /// Whether this check-in is in a terminal state
  bool get isTerminal {
    if (status == MeetupCheckinStatus.checkedIn) return checkedInAt != null;
    if (status == MeetupCheckinStatus.alerted) return alertedAt != null;
    if (status == MeetupCheckinStatus.sos) return sosTriggeredAt != null;
    if (status == MeetupCheckinStatus.cancelled) return cancelledAt != null;
    return false;
  }

  /// Whether this check-in needs user action
  bool get needsAction =>
      status == MeetupCheckinStatus.active ||
      status == MeetupCheckinStatus.alerted;

  /// Creates a copy of this check-in with the given fields replaced
  MeetupCheckin copyWith({
    String? id,
    String? userId,
    String? trustedContactId,
    DateTime? meetupTime,
    MeetupCheckinStatus? status,
    String? locationName,
    String? meetingNote,
    int? checkinBufferMins,
    DateTime? activatedAt,
    DateTime? checkedInAt,
    DateTime? alertedAt,
    DateTime? cancelledAt,
    DateTime? sosTriggeredAt,
    String? lastKnownPoint,
    DateTime? lastKnownAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return MeetupCheckin(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      trustedContactId: trustedContactId ?? this.trustedContactId,
      meetupTime: meetupTime ?? this.meetupTime,
      status: status ?? this.status,
      locationName: locationName ?? this.locationName,
      meetingNote: meetingNote ?? this.meetingNote,
      checkinBufferMins: checkinBufferMins ?? this.checkinBufferMins,
      activatedAt: activatedAt ?? this.activatedAt,
      checkedInAt: checkedInAt ?? this.checkedInAt,
      alertedAt: alertedAt ?? this.alertedAt,
      cancelledAt: cancelledAt ?? this.cancelledAt,
      sosTriggeredAt: sosTriggeredAt ?? this.sosTriggeredAt,
      lastKnownPoint: lastKnownPoint ?? this.lastKnownPoint,
      lastKnownAt: lastKnownAt ?? this.lastKnownAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
