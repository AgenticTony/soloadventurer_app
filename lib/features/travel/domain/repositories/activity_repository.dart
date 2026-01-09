import '../../../core/models/paginated_data.dart';
import '../../../core/repositories/paginated_repository_mixin.dart';
import '../models/activity.dart';

/// Repository interface for managing activity data with pagination support
///
/// This repository provides CRUD operations for activities along with
/// cursor-based and offset-based pagination methods for efficiently
/// handling large datasets (500+ activities).
///
/// Activities are individual events, tasks, or locations within a trip,
/// such as restaurant reservations, museum visits, transportation bookings, etc.
///
/// The repository follows these patterns:
/// - Cursor-based pagination for infinite scroll (recommended)
/// - Offset-based pagination for traditional page navigation
/// - Filtering by trip, category, date range, completion status
/// - Sorting by date, cost, priority
abstract class ActivityRepository {
  /// Get paginated list of activities using cursor-based pagination
  ///
  /// This is the recommended method for infinite scroll implementations.
  /// Cursor-based pagination provides better performance and consistency
  /// when new activities are added concurrently.
  ///
  /// Parameters:
  /// - [tripId]: Trip ID to filter activities (optional, if null gets all user activities)
  /// - [userId]: User ID to filter activities (required)
  /// - [cursor]: Pagination cursor from previous page's PageInfo.nextCursor
  ///             Use null for the first page
  /// - [pageSize]: Number of activities per page (default: 20, max: 100)
  /// - [sortBy]: Field to sort by (default: 'startDateTime')
  /// - [sortOrder]: Sort order - ascending or descending (default: ascending)
  /// - [filters]: Optional filters (e.g., {'category': 'food', 'isCompleted': false})
  ///
  /// Returns [PaginatedData<Activity>] containing activities and pagination metadata.
  ///
  /// Example:
  /// ```dart
  /// // First page of activities for a trip
  /// final firstPage = await activityRepository.getActivitiesCursor(
  ///   tripId: 'trip123',
  ///   userId: 'user123',
  ///   pageSize: 20,
  /// );
  ///
  /// // Next page
  /// if (firstPage.hasNextPage) {
  ///   final nextPage = await activityRepository.getActivitiesCursor(
  ///     tripId: 'trip123',
  ///     userId: 'user123',
  ///     cursor: firstPage.pageInfo.nextCursor,
  ///     pageSize: 20,
  ///   );
  /// }
  /// ```
  Future<PaginatedData<Activity>> getActivitiesCursor({
    String? tripId,
    required String userId,
    String? cursor,
    int pageSize = 20,
    String sortBy = 'startDateTime',
    SortOrder sortOrder = SortOrder.ascending,
    Map<String, dynamic>? filters,
  });

  /// Get paginated list of activities using offset-based pagination
  ///
  /// This method is useful for traditional page navigation (e.g., page 1, 2, 3).
  /// Note that offset-based pagination can be inconsistent with concurrent
  /// inserts/deletes. For infinite scroll, prefer [getActivitiesCursor].
  ///
  /// Parameters:
  /// - [tripId]: Trip ID to filter activities (optional)
  /// - [userId]: User ID to filter activities (required)
  /// - [page]: Page number (1-based, default: 1)
  /// - [pageSize]: Number of activities per page (default: 20, max: 100)
  /// - [sortBy]: Field to sort by (default: 'startDateTime')
  /// - [sortOrder]: Sort order - ascending or descending (default: ascending)
  /// - [filters]: Optional filters
  ///
  /// Returns [PaginatedData<Activity>] containing activities and pagination metadata.
  ///
  /// Example:
  /// ```dart
  /// // Page 1 of activities
  /// final page1 = await activityRepository.getActivitiesOffset(
  ///   tripId: 'trip123',
  ///   userId: 'user123',
  ///   page: 1,
  ///   pageSize: 20,
  /// );
  /// ```
  Future<PaginatedData<Activity>> getActivitiesOffset({
    String? tripId,
    required String userId,
    int page = 1,
    int pageSize = 20,
    String sortBy = 'startDateTime',
    SortOrder sortOrder = SortOrder.ascending,
    Map<String, dynamic>? filters,
  });

  /// Get lightweight activity metadata for list rendering (optimized for 500+ items)
  ///
  /// This method returns only essential fields needed for list items,
  /// reducing memory usage and improving rendering performance.
  ///
  /// Returns partial activity data: id, title, category, startDateTime, locationName
  ///
  /// Use this when rendering activity lists and load full details on-demand
  /// when the user taps on an activity.
  ///
  /// Example:
  /// ```dart
  /// final activitiesMetadata = await activityRepository.getActivitiesMetadata(
  ///   tripId: 'trip123',
  ///   userId: 'user123',
  ///   cursor: null,
  ///   pageSize: 50,
  /// );
  /// ```
  Future<PaginatedData<ActivityMetadata>> getActivitiesMetadata({
    String? tripId,
    required String userId,
    String? cursor,
    int pageSize = 50,
  });

  /// Get a single activity by ID
  ///
  /// Returns full activity details including all fields.
  /// Returns null if the activity is not found.
  Future<Activity?> getActivityById({required String activityId});

  /// Get multiple activities by IDs (batch query)
  ///
  /// More efficient than calling [getActivityById] multiple times.
  /// Returns activities in the same order as the provided IDs.
  /// Missing activities will not be included in the result.
  ///
  /// Example:
  /// ```dart
  /// final activities = await activityRepository.getActivitiesByIds(
  ///   activityIds: ['activity1', 'activity2', 'activity3'],
  /// );
  /// ```
  Future<List<Activity>> getActivitiesByIds({required List<String> activityIds});

  /// Create a new activity
  ///
  /// Returns the created activity with generated ID and timestamps.
  Future<Activity> createActivity({required Activity activity});

  /// Update an existing activity
  ///
  /// Returns the updated activity.
  /// Throws [NotFoundException] if the activity doesn't exist.
  Future<Activity> updateActivity({
    required String activityId,
    required Activity updates,
  });

  /// Delete an activity
  ///
  /// Returns true if the activity was deleted, false if it didn't exist.
  Future<bool> deleteActivity({required String activityId});

  /// Toggle activity completion status
  ///
  /// Convenience method to mark an activity as completed/incomplete.
  /// Returns the updated activity.
  ///
  /// Example:
  /// ```dart
  /// final completedActivity = await activityRepository.toggleActivityCompletion(
  ///   activityId: 'activity123',
  ///   isCompleted: true,
  /// );
  /// ```
  Future<Activity> toggleActivityCompletion({
    required String activityId,
    required bool isCompleted,
  });

  /// Search activities by query string
  ///
  /// Searches across title, description, locationName, and address fields.
  /// Supports both cursor and offset pagination.
  ///
  /// Parameters:
  /// - [tripId]: Optional trip ID to scope search
  /// - [userId]: User ID to filter activities (required)
  /// - [query]: Search query string
  /// - [cursor]: Pagination cursor (for cursor-based)
  /// - [page]: Page number (for offset-based)
  /// - [pageSize]: Number of results per page
  ///
  /// Example:
  /// ```dart
  /// final results = await activityRepository.searchActivities(
  ///   userId: 'user123',
  ///   query: 'museum',
  ///   cursor: null,
  ///   pageSize: 20,
  /// );
  /// ```
  Future<PaginatedData<Activity>> searchActivities({
    String? tripId,
    required String userId,
    required String query,
    String? cursor,
    int? page,
    int pageSize = 20,
  });

  /// Get activities by category
  ///
  /// Useful for filtering activities by type (food, transport, accommodation, etc.)
  ///
  /// Example:
  /// ```dart
  /// final foodActivities = await activityRepository.getActivitiesByCategory(
  ///   tripId: 'trip123',
  ///   userId: 'user123',
  ///   category: ActivityCategory.food,
  ///   cursor: null,
  ///   pageSize: 20,
  /// );
  /// ```
  Future<PaginatedData<Activity>> getActivitiesByCategory({
    String? tripId,
    required String userId,
    required ActivityCategory category,
    String? cursor,
    int pageSize = 20,
  });

  /// Get activities within a date range
  ///
  /// Useful for filtering activities by scheduled time.
  /// Activities are filtered by startDateTime.
  ///
  /// Example:
  /// ```dart
  /// // Get activities for today
  /// final today = DateTime.now();
  /// final startOfDay = DateTime(today.year, today.month, today.day);
  /// final endOfDay = startOfDay.add(const Duration(days: 1));
  ///
  /// final todayActivities = await activityRepository.getActivitiesInDateRange(
  ///   tripId: 'trip123',
  ///   userId: 'user123',
  ///   startDate: startOfDay,
  ///   endDate: endOfDay,
  ///   cursor: null,
  ///   pageSize: 20,
  /// );
  /// ```
  Future<PaginatedData<Activity>> getActivitiesInDateRange({
    String? tripId,
    required String userId,
    required DateTime startDate,
    required DateTime endDate,
    String? cursor,
    int pageSize = 20,
  });

  /// Get upcoming activities (scheduled in the future)
  ///
  /// Convenience method that returns activities with startDateTime after now.
  ///
  /// Example:
  /// ```dart
  /// final upcoming = await activityRepository.getUpcomingActivities(
  ///   tripId: 'trip123',
  ///   userId: 'user123',
  ///   cursor: null,
  ///   pageSize: 10,
  /// );
  /// ```
  Future<PaginatedData<Activity>> getUpcomingActivities({
    String? tripId,
    required String userId,
    String? cursor,
    int pageSize = 10,
  });

  /// Get completed activities
  ///
  /// Convenience method that returns activities where isCompleted is true.
  ///
  /// Example:
  /// ```dart
  /// final completed = await activityRepository.getCompletedActivities(
  ///   tripId: 'trip123',
  ///   userId: 'user123',
  ///   cursor: null,
  ///   pageSize: 20,
  /// );
  /// ```
  Future<PaginatedData<Activity>> getCompletedActivities({
    String? tripId,
    required String userId,
    String? cursor,
    int pageSize = 20,
  });

  /// Get priority activities
  ///
  /// Convenience method that returns activities where isPriority is true.
  ///
  /// Example:
  /// ```dart
  /// final priority = await activityRepository.getPriorityActivities(
  ///   tripId: 'trip123',
  ///   userId: 'user123',
  ///   cursor: null,
  ///   pageSize: 10,
  /// );
  /// ```
  Future<PaginatedData<Activity>> getPriorityActivities({
    String? tripId,
    required String userId,
    String? cursor,
    int pageSize = 10,
  });

  /// Count total activities for a user or trip
  ///
  /// Returns the total number of activities matching optional filters.
  /// Useful for displaying counts and progress indicators.
  ///
  /// Example:
  /// ```dart
  /// final totalActivities = await activityRepository.countActivities(
  ///   tripId: 'trip123',
  ///   userId: 'user123',
  ///   filters: {'isCompleted': false},
  /// );
  /// ```
  Future<int> countActivities({
    String? tripId,
    required String userId,
    Map<String, dynamic>? filters,
  });

  /// Bulk update activities
  ///
  /// Updates multiple activities in a single operation.
  /// More efficient than calling [updateActivity] multiple times.
  ///
  /// Returns the number of activities successfully updated.
  ///
  /// Example:
  /// ```dart
  /// final updatedCount = await activityRepository.bulkUpdateActivities(
  ///   activityIds: ['activity1', 'activity2', 'activity3'],
  ///   updates: {'isCompleted': true},
  /// );
  /// ```
  Future<int> bulkUpdateActivities({
    required List<String> activityIds,
    required Map<String, dynamic> updates,
  });
}

/// Lightweight activity metadata for efficient list rendering
///
/// Contains only essential fields needed for displaying activity items
/// in lists, reducing memory usage for 500+ activities.
class ActivityMetadata {
  final String id;
  final String title;
  final ActivityCategory category;
  final DateTime? startDateTime;
  final String? locationName;
  final bool isCompleted;
  final bool isPriority;

  const ActivityMetadata({
    required this.id,
    required this.title,
    required this.category,
    this.startDateTime,
    this.locationName,
    this.isCompleted = false,
    this.isPriority = false,
  });

  /// Creates ActivityMetadata from full Activity object
  factory ActivityMetadata.fromActivity(Activity activity) {
    return ActivityMetadata(
      id: activity.id,
      title: activity.title,
      category: activity.category,
      startDateTime: activity.startDateTime,
      locationName: activity.locationName,
      isCompleted: activity.isCompleted,
      isPriority: activity.isPriority,
    );
  }

  @override
  String toString() {
    return 'ActivityMetadata('
        'id: $id, '
        'title: $title, '
        'category: $category, '
        'startDateTime: $startDateTime)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ActivityMetadata &&
        other.id == id &&
        other.title == title &&
        other.category == category &&
        other.startDateTime == startDateTime &&
        other.locationName == locationName &&
        other.isCompleted == isCompleted &&
        other.isPriority == isPriority;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        title.hashCode ^
        category.hashCode ^
        startDateTime.hashCode ^
        locationName.hashCode ^
        isCompleted.hashCode ^
        isPriority.hashCode;
  }
}
