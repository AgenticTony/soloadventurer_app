import 'package:equatable/equatable.dart';

/// Activity entity representing a suggested meetup activity
class Activity extends Equatable {
  /// Unique identifier for the activity
  final String id;

  /// Activity name (e.g., "coffee", "hiking", "sightseeing")
  final String name;

  /// Activity category (e.g., "food", "outdoor", "culture")
  final String category;

  /// Emoji or icon identifier for UI display
  final String? icon;

  /// Whether this activity is location-specific
  final bool isLocationSpecific;

  /// When the activity was created
  final DateTime createdAt;

  /// Creates a new [Activity] instance
  const Activity({
    required this.id,
    required this.name,
    required this.category,
    this.icon,
    this.isLocationSpecific = false,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        category,
        icon,
        isLocationSpecific,
        createdAt,
      ];

  /// Creates a copy of this activity with the given fields replaced
  Activity copyWith({
    String? id,
    String? name,
    String? category,
    String? icon,
    bool? isLocationSpecific,
    DateTime? createdAt,
  }) {
    return Activity(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      icon: icon ?? this.icon,
      isLocationSpecific: isLocationSpecific ?? this.isLocationSpecific,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// Creates an empty activity
  factory Activity.empty() {
    return Activity(
      id: '',
      name: '',
      category: '',
      createdAt: DateTime.now(),
    );
  }

  /// Whether this activity is empty
  bool get isEmpty => id.isEmpty;

  /// Whether this activity is not empty
  bool get isNotEmpty => !isEmpty;

  @override
  String toString() {
    return 'Activity{id: $id, name: $name, category: $category, icon: $icon}';
  }
}

/// User's interest in an activity
class UserActivity extends Equatable {
  /// Unique identifier for this user-activity relationship
  final String id;

  /// User ID
  final String userId;

  /// Activity ID
  final String activityId;

  /// When the user expressed interest in this activity
  final DateTime createdAt;

  /// Creates a new [UserActivity] instance
  const UserActivity({
    required this.id,
    required this.userId,
    required this.activityId,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, userId, activityId, createdAt];

  /// Creates an empty user activity
  factory UserActivity.empty() {
    return UserActivity(
      id: '',
      userId: '',
      activityId: '',
      createdAt: DateTime.now(),
    );
  }

  /// Whether this user activity is empty
  bool get isEmpty => id.isEmpty;

  /// Whether this user activity is not empty
  bool get isNotEmpty => !isEmpty;
}
