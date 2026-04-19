import 'package:equatable/equatable.dart';

/// Details of a meetup shared with trusted contacts.
class SharedMeetup extends Equatable {
  /// Unique ID
  final String id;

  /// User who created the meetup share
  final String userId;

  /// Name of the person the user is meeting
  final String meetingWith;

  /// Profile photo URL of the person being met (if available)
  final String? meetingWithPhotoUrl;

  /// Meeting location name
  final String locationName;

  /// Meeting location address
  final String? locationAddress;

  /// Meeting date and time
  final DateTime meetupTime;

  /// ID of the trusted contact(s) this was shared with
  final List<String> sharedWithContactIds;

  /// Optional notes about the meetup
  final String? notes;

  /// Connection ID (from matching) if meeting with a matched user
  final String? connectionId;

  /// When this share was created
  final DateTime createdAt;

  /// When the meetup was last updated (plans changed, etc.)
  final DateTime? updatedAt;

  /// Whether plans have changed since initial share
  final bool plansChanged;

  /// Creates a new [SharedMeetup]
  const SharedMeetup({
    required this.id,
    required this.userId,
    required this.meetingWith,
    this.meetingWithPhotoUrl,
    required this.locationName,
    this.locationAddress,
    required this.meetupTime,
    this.sharedWithContactIds = const [],
    this.notes,
    this.connectionId,
    required this.createdAt,
    this.updatedAt,
    this.plansChanged = false,
  });

  /// Whether the meetup is in the past
  bool get isPast => DateTime.now().isAfter(meetupTime);

  /// Whether the meetup is within the next hour
  bool get isImminent =>
      !isPast &&
      DateTime.now().isAfter(meetupTime.subtract(const Duration(hours: 1)));

  /// Formatted time string
  String get formattedTime {
    final hour = meetupTime.hour.toString().padLeft(2, '0');
    final minute = meetupTime.minute.toString().padLeft(2, '0');
    return '${meetupTime.month}/${meetupTime.day}/${meetupTime.year} at $hour:$minute';
  }

  @override
  List<Object?> get props => [
        id, userId, meetingWith, meetingWithPhotoUrl,
        locationName, locationAddress, meetupTime,
        sharedWithContactIds, notes, connectionId,
        createdAt, updatedAt, plansChanged,
      ];

  SharedMeetup copyWith({
    String? id,
    String? userId,
    String? meetingWith,
    String? meetingWithPhotoUrl,
    String? locationName,
    String? locationAddress,
    DateTime? meetupTime,
    List<String>? sharedWithContactIds,
    String? notes,
    String? connectionId,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? plansChanged,
  }) {
    return SharedMeetup(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      meetingWith: meetingWith ?? this.meetingWith,
      meetingWithPhotoUrl:
          meetingWithPhotoUrl ?? this.meetingWithPhotoUrl,
      locationName: locationName ?? this.locationName,
      locationAddress: locationAddress ?? this.locationAddress,
      meetupTime: meetupTime ?? this.meetupTime,
      sharedWithContactIds:
          sharedWithContactIds ?? this.sharedWithContactIds,
      notes: notes ?? this.notes,
      connectionId: connectionId ?? this.connectionId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      plansChanged: plansChanged ?? this.plansChanged,
    );
  }
}
