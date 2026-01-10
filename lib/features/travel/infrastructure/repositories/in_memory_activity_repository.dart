import '../../domain/models/activity.dart';
import '../../domain/repositories/activity_repository.dart';
import 'package:soloadventurer/core/models/paginated_data.dart';
import 'package:soloadventurer/core/repositories/paginated_repository_mixin.dart';

/// In-memory implementation of ActivityRepository for testing and development
///
/// This implementation stores activities in memory and demonstrates how to
/// implement cursor-based and offset-based pagination.
///
/// For production, replace with an implementation that uses a database
/// or remote API.
class InMemoryActivityRepository
    with PaginatedRepositoryMixin
    implements ActivityRepository {
  final Map<String, Activity> _activities = {};
  int _idCounter = 1;

  @override
  Future<PaginatedData<Activity>> getActivitiesCursor({
    String? tripId,
    required String userId,
    String? cursor,
    int pageSize = 20,
    String sortBy = 'startDateTime',
    SortOrder sortOrder = SortOrder.ascending,
    Map<String, dynamic>? filters,
  }) async {
    // Validate page size
    final validatedPageSize = validatePageSize(pageSize);

    // Parse cursor to get offset
    final offset = parseOffsetCursor(cursor) ?? 0;

    // Filter activities by user and trip
    var filteredActivities = _activities.values
        .where((activity) => activity.userId == userId)
        .toList();

    if (tripId != null) {
      filteredActivities = filteredActivities
          .where((activity) => activity.tripId == tripId)
          .toList();
    }

    // Apply additional filters
    if (filters != null) {
      if (filters.containsKey('category')) {
        filteredActivities = filteredActivities
            .where((activity) =>
                activity.category == filters['category'] as ActivityCategory)
            .toList();
      }
      if (filters.containsKey('isCompleted')) {
        filteredActivities = filteredActivities
            .where((activity) =>
                activity.isCompleted == (filters['isCompleted'] as bool))
            .toList();
      }
      if (filters.containsKey('isPriority')) {
        filteredActivities = filteredActivities
            .where((activity) =>
                activity.isPriority == (filters['isPriority'] as bool))
            .toList();
      }
    }

    // Sort activities
    filteredActivities = _sortActivities(filteredActivities, sortBy, sortOrder);

    // Apply pagination (cursor-based using offset)
    final startIndex = offset;
    final endIndex = startIndex + validatedPageSize;
    final paginatedActivities = startIndex < filteredActivities.length
        ? filteredActivities.sublist(
            startIndex,
            endIndex > filteredActivities.length
                ? filteredActivities.length
                : endIndex,
          )
        : <Activity>[];

    // Determine if there's a next page
    final hasNextPage = endIndex < filteredActivities.length;

    // Generate next cursor
    final nextCursor =
        hasNextPage ? generateOffsetCursor(offset + validatedPageSize) : null;

    // Create page info
    final pageInfo = createCursorPageInfo(
      currentCursor: cursor,
      pageSize: validatedPageSize,
      itemsCount: paginatedActivities.length,
      hasNextPage: hasNextPage,
      nextCursor: nextCursor,
      previousCursor:
          offset > 0 ? generateOffsetCursor(offset - validatedPageSize) : null,
    );

    return PaginatedData<Activity>(
      items: paginatedActivities,
      pageInfo: pageInfo,
    );
  }

  @override
  Future<PaginatedData<Activity>> getActivitiesOffset({
    String? tripId,
    required String userId,
    int page = 1,
    int pageSize = 20,
    String sortBy = 'startDateTime',
    SortOrder sortOrder = SortOrder.ascending,
    Map<String, dynamic>? filters,
  }) async {
    // Validate page size
    final validatedPageSize = validatePageSize(pageSize);

    // Calculate offset
    final offset = (page - 1) * validatedPageSize;

    // Filter activities by user and trip
    var filteredActivities = _activities.values
        .where((activity) => activity.userId == userId)
        .toList();

    if (tripId != null) {
      filteredActivities = filteredActivities
          .where((activity) => activity.tripId == tripId)
          .toList();
    }

    // Apply additional filters
    if (filters != null) {
      if (filters.containsKey('category')) {
        filteredActivities = filteredActivities
            .where((activity) =>
                activity.category == filters['category'] as ActivityCategory)
            .toList();
      }
      if (filters.containsKey('isCompleted')) {
        filteredActivities = filteredActivities
            .where((activity) =>
                activity.isCompleted == (filters['isCompleted'] as bool))
            .toList();
      }
    }

    final totalItems = filteredActivities.length;

    // Sort activities
    filteredActivities = _sortActivities(filteredActivities, sortBy, sortOrder);

    // Apply pagination (offset-based)
    final startIndex = offset;
    final endIndex = startIndex + validatedPageSize;
    final paginatedActivities = startIndex < filteredActivities.length
        ? filteredActivities.sublist(
            startIndex,
            endIndex > filteredActivities.length
                ? filteredActivities.length
                : endIndex,
          )
        : <Activity>[];

    // Create page info
    final pageInfo = createOffsetPageInfo(
      currentPage: page,
      pageSize: validatedPageSize,
      totalItems: totalItems,
      itemsCount: paginatedActivities.length,
    );

    return PaginatedData<Activity>(
      items: paginatedActivities,
      pageInfo: pageInfo,
    );
  }

  @override
  Future<PaginatedData<ActivityMetadata>> getActivitiesMetadata({
    String? tripId,
    required String userId,
    String? cursor,
    int pageSize = 50,
  }) async {
    // Get full activities using cursor pagination
    final fullActivities = await getActivitiesCursor(
      tripId: tripId,
      userId: userId,
      cursor: cursor,
      pageSize: pageSize,
    );

    // Convert to metadata
    final metadataList = fullActivities.items
        .map((activity) => ActivityMetadata.fromActivity(activity))
        .toList();

    return PaginatedData<ActivityMetadata>(
      items: metadataList,
      pageInfo: fullActivities.pageInfo,
    );
  }

  @override
  Future<Activity?> getActivityById({required String activityId}) async {
    return _activities[activityId];
  }

  @override
  Future<List<Activity>> getActivitiesByIds({
    required List<String> activityIds,
  }) async {
    final activities = <Activity>[];
    for (final id in activityIds) {
      final activity = _activities[id];
      if (activity != null) {
        activities.add(activity);
      }
    }
    return activities;
  }

  @override
  Future<Activity> createActivity({required Activity activity}) async {
    // Create a new activity with generated ID
    final newActivity = activity.copyWith(
      id: 'activity_${_idCounter++}',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    _activities[newActivity.id] = newActivity;
    return newActivity;
  }

  @override
  Future<Activity> updateActivity({
    required String activityId,
    required Activity updates,
  }) async {
    final existingActivity = _activities[activityId];
    if (existingActivity == null) {
      throw Exception('Activity not found: $activityId');
    }

    final updatedActivity = updates.copyWith(
      id: activityId, // Ensure ID doesn't change
      userId: existingActivity.userId, // Ensure userId doesn't change
      tripId: existingActivity.tripId, // Ensure tripId doesn't change
      createdAt: existingActivity.createdAt, // Ensure createdAt doesn't change
      updatedAt: DateTime.now(),
    );

    _activities[activityId] = updatedActivity;
    return updatedActivity;
  }

  @override
  Future<bool> deleteActivity({required String activityId}) async {
    return _activities.remove(activityId) != null;
  }

  @override
  Future<Activity> toggleActivityCompletion({
    required String activityId,
    required bool isCompleted,
  }) async {
    final activity = _activities[activityId];
    if (activity == null) {
      throw Exception('Activity not found: $activityId');
    }

    final updatedActivity = activity.copyWith(
      isCompleted: isCompleted,
      updatedAt: DateTime.now(),
    );

    _activities[activityId] = updatedActivity;
    return updatedActivity;
  }

  @override
  Future<PaginatedData<Activity>> searchActivities({
    String? tripId,
    required String userId,
    required String query,
    String? cursor,
    int? page,
    int pageSize = 20,
  }) async {
    // Filter activities by search query
    final searchResults = _activities.values
        .where((activity) =>
            activity.userId == userId &&
            (tripId == null || activity.tripId == tripId) &&
            (activity.title.toLowerCase().contains(query.toLowerCase()) ||
                activity.description
                        ?.toLowerCase()
                        .contains(query.toLowerCase()) ==
                    true ||
                activity.locationName
                        ?.toLowerCase()
                        .contains(query.toLowerCase()) ==
                    true ||
                activity.address?.toLowerCase().contains(query.toLowerCase()) ==
                    true))
        .toList();

    // Sort by startDateTime ascending
    final sortedResults =
        _sortActivities(searchResults, 'startDateTime', SortOrder.ascending);

    // Apply pagination based on whether cursor or page is provided
    if (cursor != null) {
      final offset = parseOffsetCursor(cursor) ?? 0;
      final validatedPageSize = validatePageSize(pageSize);
      final startIndex = offset;
      final endIndex = startIndex + validatedPageSize;
      final paginatedResults = startIndex < sortedResults.length
          ? sortedResults.sublist(
              startIndex,
              endIndex > sortedResults.length ? sortedResults.length : endIndex,
            )
          : <Activity>[];

      final hasNextPage = endIndex < sortedResults.length;
      final nextCursor =
          hasNextPage ? generateOffsetCursor(offset + validatedPageSize) : null;

      final pageInfo = createCursorPageInfo(
        currentCursor: cursor,
        pageSize: validatedPageSize,
        itemsCount: paginatedResults.length,
        hasNextPage: hasNextPage,
        nextCursor: nextCursor,
      );

      return PaginatedData<Activity>(
        items: paginatedResults,
        pageInfo: pageInfo,
      );
    } else {
      final currentPage = page ?? 1;
      final validatedPageSize = validatePageSize(pageSize);
      final startIndex = (currentPage - 1) * validatedPageSize;
      final endIndex = startIndex + validatedPageSize;
      final paginatedResults = startIndex < sortedResults.length
          ? sortedResults.sublist(
              startIndex,
              endIndex > sortedResults.length ? sortedResults.length : endIndex,
            )
          : <Activity>[];

      final pageInfo = createOffsetPageInfo(
        currentPage: currentPage,
        pageSize: validatedPageSize,
        totalItems: sortedResults.length,
        itemsCount: paginatedResults.length,
      );

      return PaginatedData<Activity>(
        items: paginatedResults,
        pageInfo: pageInfo,
      );
    }
  }

  @override
  Future<PaginatedData<Activity>> getActivitiesByCategory({
    String? tripId,
    required String userId,
    required ActivityCategory category,
    String? cursor,
    int pageSize = 20,
  }) async {
    return getActivitiesCursor(
      tripId: tripId,
      userId: userId,
      cursor: cursor,
      pageSize: pageSize,
      filters: {'category': category},
    );
  }

  @override
  Future<PaginatedData<Activity>> getActivitiesInDateRange({
    String? tripId,
    required String userId,
    required DateTime startDate,
    required DateTime endDate,
    String? cursor,
    int pageSize = 20,
  }) async {
    // Filter activities by date range (using startDateTime)
    final filteredActivities = _activities.values
        .where((activity) =>
            activity.userId == userId &&
            (tripId == null || activity.tripId == tripId) &&
            activity.startDateTime != null &&
            activity.startDateTime!.isAfter(startDate) &&
            activity.startDateTime!.isBefore(endDate))
        .toList();

    // Sort by startDateTime ascending
    final sortedActivities = _sortActivities(
        filteredActivities, 'startDateTime', SortOrder.ascending);

    // Apply pagination
    final offset = parseOffsetCursor(cursor) ?? 0;
    final validatedPageSize = validatePageSize(pageSize);
    final startIndex = offset;
    final endIndex = startIndex + validatedPageSize;
    final paginatedActivities = startIndex < sortedActivities.length
        ? sortedActivities.sublist(
            startIndex,
            endIndex > sortedActivities.length
                ? sortedActivities.length
                : endIndex,
          )
        : <Activity>[];

    final hasNextPage = endIndex < sortedActivities.length;
    final nextCursor =
        hasNextPage ? generateOffsetCursor(offset + validatedPageSize) : null;

    final pageInfo = createCursorPageInfo(
      currentCursor: cursor,
      pageSize: validatedPageSize,
      itemsCount: paginatedActivities.length,
      hasNextPage: hasNextPage,
      nextCursor: nextCursor,
    );

    return PaginatedData<Activity>(
      items: paginatedActivities,
      pageInfo: pageInfo,
    );
  }

  @override
  Future<PaginatedData<Activity>> getUpcomingActivities({
    String? tripId,
    required String userId,
    String? cursor,
    int pageSize = 10,
  }) async {
    final now = DateTime.now();

    // Filter activities with startDateTime in the future
    final upcomingActivities = _activities.values
        .where((activity) =>
            activity.userId == userId &&
            (tripId == null || activity.tripId == tripId) &&
            activity.startDateTime != null &&
            activity.startDateTime!.isAfter(now))
        .toList();

    // Sort by startDateTime ascending
    final sortedActivities = _sortActivities(
        upcomingActivities, 'startDateTime', SortOrder.ascending);

    // Apply pagination
    final offset = parseOffsetCursor(cursor) ?? 0;
    final validatedPageSize = validatePageSize(pageSize);
    final startIndex = offset;
    final endIndex = startIndex + validatedPageSize;
    final paginatedActivities = startIndex < sortedActivities.length
        ? sortedActivities.sublist(
            startIndex,
            endIndex > sortedActivities.length
                ? sortedActivities.length
                : endIndex,
          )
        : <Activity>[];

    final hasNextPage = endIndex < sortedActivities.length;
    final nextCursor =
        hasNextPage ? generateOffsetCursor(offset + validatedPageSize) : null;

    final pageInfo = createCursorPageInfo(
      currentCursor: cursor,
      pageSize: validatedPageSize,
      itemsCount: paginatedActivities.length,
      hasNextPage: hasNextPage,
      nextCursor: nextCursor,
    );

    return PaginatedData<Activity>(
      items: paginatedActivities,
      pageInfo: pageInfo,
    );
  }

  @override
  Future<PaginatedData<Activity>> getCompletedActivities({
    String? tripId,
    required String userId,
    String? cursor,
    int pageSize = 20,
  }) async {
    return getActivitiesCursor(
      tripId: tripId,
      userId: userId,
      cursor: cursor,
      pageSize: pageSize,
      filters: {'isCompleted': true},
    );
  }

  @override
  Future<PaginatedData<Activity>> getPriorityActivities({
    String? tripId,
    required String userId,
    String? cursor,
    int pageSize = 10,
  }) async {
    return getActivitiesCursor(
      tripId: tripId,
      userId: userId,
      cursor: cursor,
      pageSize: pageSize,
      filters: {'isPriority': true},
      sortBy: 'startDateTime',
      sortOrder: SortOrder.ascending,
    );
  }

  @override
  Future<int> countActivities({
    String? tripId,
    required String userId,
    Map<String, dynamic>? filters,
  }) async {
    var activities =
        _activities.values.where((activity) => activity.userId == userId);

    if (tripId != null) {
      activities = activities.where((activity) => activity.tripId == tripId);
    }

    if (filters != null) {
      if (filters.containsKey('isCompleted')) {
        activities = activities.where((activity) =>
            activity.isCompleted == (filters['isCompleted'] as bool));
      }
      if (filters.containsKey('category')) {
        activities = activities.where((activity) =>
            activity.category == filters['category'] as ActivityCategory);
      }
    }

    return activities.length;
  }

  @override
  Future<int> bulkUpdateActivities({
    required List<String> activityIds,
    required Map<String, dynamic> updates,
  }) async {
    var updatedCount = 0;

    for (final activityId in activityIds) {
      final activity = _activities[activityId];
      if (activity != null) {
        // Apply updates
        Activity updatedActivity = activity;

        if (updates.containsKey('isCompleted')) {
          updatedActivity = updatedActivity.copyWith(
            isCompleted: updates['isCompleted'] as bool,
            updatedAt: DateTime.now(),
          );
        }

        if (updates.containsKey('isPriority')) {
          updatedActivity = updatedActivity.copyWith(
            isPriority: updates['isPriority'] as bool,
            updatedAt: DateTime.now(),
          );
        }

        _activities[activityId] = updatedActivity;
        updatedCount++;
      }
    }

    return updatedCount;
  }

  /// Sort activities by field and order
  List<Activity> _sortActivities(
    List<Activity> activities,
    String field,
    SortOrder order,
  ) {
    final sortedActivities = List<Activity>.from(activities);

    sortedActivities.sort((a, b) {
      int comparison;
      switch (field) {
        case 'title':
          comparison = a.title.toLowerCase().compareTo(b.title.toLowerCase());
          break;
        case 'category':
          comparison = a.category.name.compareTo(b.category.name);
          break;
        case 'estimatedCost':
          final costA = a.estimatedCost ?? 0;
          final costB = b.estimatedCost ?? 0;
          comparison = costA.compareTo(costB);
          break;
        case 'startDateTime':
          // Activities with null startDateTime come last
          if (a.startDateTime == null && b.startDateTime == null) {
            comparison = 0;
          } else if (a.startDateTime == null) {
            comparison = 1;
          } else if (b.startDateTime == null) {
            comparison = -1;
          } else {
            comparison = a.startDateTime!.compareTo(b.startDateTime!);
          }
          break;
        case 'createdAt':
        default:
          comparison = a.createdAt.compareTo(b.createdAt);
          break;
      }

      return order == SortOrder.ascending ? comparison : -comparison;
    });

    return sortedActivities;
  }

  /// Clears all activities (useful for testing)
  void clear() {
    _activities.clear();
    _idCounter = 1;
  }
}
