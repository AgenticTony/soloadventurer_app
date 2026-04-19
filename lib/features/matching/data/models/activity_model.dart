import 'package:soloadventurer/features/matching/domain/entities/activity.dart';

/// Data layer representation of [Activity] entity
class ActivityModel extends Activity {
  /// Creates a new [ActivityModel] instance
  const ActivityModel({
    required super.id,
    required super.name,
    required super.category,
    super.icon,
    super.isLocationSpecific,
    required super.createdAt,
  });

  /// Creates an [ActivityModel] from JSON map (Supabase format)
  factory ActivityModel.fromJson(Map<String, dynamic> json) {
    return ActivityModel(
      id: json['id'] as String,
      name: json['name'] as String,
      category: json['category'] as String,
      icon: json['icon'] as String?,
      isLocationSpecific: json['is_location_specific'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  /// Converts this [ActivityModel] to JSON map (Supabase format)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'icon': icon,
      'is_location_specific': isLocationSpecific,
      'created_at': createdAt.toIso8601String(),
    };
  }

  /// Creates an [ActivityModel] from an [Activity] entity
  factory ActivityModel.fromEntity(Activity activity) {
    return ActivityModel(
      id: activity.id,
      name: activity.name,
      category: activity.category,
      icon: activity.icon,
      isLocationSpecific: activity.isLocationSpecific,
      createdAt: activity.createdAt,
    );
  }

  /// Converts to a map for local database storage (Drift)
  Map<String, dynamic> toLocalDbMap() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'icon': icon,
      'is_location_specific': isLocationSpecific ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
    };
  }

  /// Creates an [ActivityModel] from local database map (Drift)
  factory ActivityModel.fromLocalDbMap(Map<String, dynamic> map) {
    return ActivityModel(
      id: map['id'] as String,
      name: map['name'] as String,
      category: map['category'] as String,
      icon: map['icon'] as String?,
      isLocationSpecific: (map['is_location_specific'] as int) == 1,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }
}

/// Data layer representation of [UserActivity] entity
class UserActivityModel extends UserActivity {
  /// Creates a new [UserActivityModel] instance
  const UserActivityModel({
    required super.id,
    required super.userId,
    required super.activityId,
    required super.createdAt,
  });

  /// Creates a [UserActivityModel] from JSON map (Supabase format)
  factory UserActivityModel.fromJson(Map<String, dynamic> json) {
    return UserActivityModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      activityId: json['activity_id'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  /// Converts this [UserActivityModel] to JSON map (Supabase format)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'activity_id': activityId,
      'created_at': createdAt.toIso8601String(),
    };
  }

  /// Creates a [UserActivityModel] from a [UserActivity] entity
  factory UserActivityModel.fromEntity(UserActivity userActivity) {
    return UserActivityModel(
      id: userActivity.id,
      userId: userActivity.userId,
      activityId: userActivity.activityId,
      createdAt: userActivity.createdAt,
    );
  }

  /// Converts to a map for local database storage (Drift)
  Map<String, dynamic> toLocalDbMap() {
    return {
      'id': id,
      'user_id': userId,
      'activity_id': activityId,
      'created_at': createdAt.toIso8601String(),
    };
  }

  /// Creates a [UserActivityModel] from local database map (Drift)
  factory UserActivityModel.fromLocalDbMap(Map<String, dynamic> map) {
    return UserActivityModel(
      id: map['id'] as String,
      userId: map['user_id'] as String,
      activityId: map['activity_id'] as String,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }
}
