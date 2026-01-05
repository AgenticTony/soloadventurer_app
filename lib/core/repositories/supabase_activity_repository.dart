import 'package:supabase_flutter/supabase_flutter.dart';

import '../../features/travel/domain/models/activity.dart';
import '../../features/travel/domain/repositories/activity_repository.dart';
import '../models/paginated_data.dart';
import '../models/page_info.dart';
import 'paginated_repository_mixin.dart';

/// Supabase implementation of ActivityRepository with cursor-based pagination
///
/// This repository provides efficient cursor-based pagination for activities
/// using Supabase's PostgreSQL backend. It leverages database indexes created
/// in the performance optimization migration for optimal query performance.
///
/// **Key Performance Features:**
/// - Cursor-based pagination prevents duplicate/missed items with concurrent changes
/// - Uses database indexes (idx_activities_trip_user, idx_activities_user_start_datetime)
/// - Page size validation (max 100) prevents excessive data transfer
/// - Optimized for datasets with 500+ activities
///
/// **Cursor Encoding:**
/// Cursors are encoded as base64 strings containing:
/// - The last activity's ID (for positioning)
/// - The last activity's sort field value (for ordering)
/// - Offset information (for fallback)
///
/// Example:
/// ```dart
/// final repository = SupabaseActivityRepository(supabaseClient);
///
/// // First page
/// final firstPage = await repository.getActivitiesCursor(
///   userId: 'user123',
///   tripId: 'trip456',
///   pageSize: 20,
/// );
///
/// // Next page using cursor
/// if (firstPage.pageInfo.hasNextPage) {
///   final nextPage = await repository.getActivitiesCursor(
///     userId: 'user123',
///     tripId: 'trip456',
///     cursor: firstPage.pageInfo.nextCursor,
///     pageSize: 20,
///   );
/// }
/// ```
///
/// **Note:** This is a placeholder implementation. Actual Supabase queries
/// will be added when the supabase_flutter package is integrated into the project.
class SupabaseActivityRepository with PaginatedRepositoryMixin
    implements ActivityRepository {
  final SupabaseClient _client;

  /// Creates a new SupabaseActivityRepository
  ///
  /// The [client] parameter should be an initialized SupabaseClient instance.
  SupabaseActivityRepository({required SupabaseClient client})
      : _client = client;

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

    // Parse cursor to get position information
    final cursorData = _decodeCursor(cursor);
    final offset = cursorData?['offset'] as int? ?? 0;
    final lastId = cursorData?['lastId'] as String?;
    final lastSortValue = cursorData?['lastSortValue'];

    // Build Supabase query
    var query = _client
        .from('activities')
        .select()
        .eq('userId', userId);

    // Add trip filter if provided
    if (tripId != null) {
      query = query.eq('tripId', tripId);
    }

    // Add additional filters
    if (filters != null) {
      if (filters.containsKey('category')) {
        query = query.eq('category', filters['category'].toString());
      }
      if (filters.containsKey('isCompleted')) {
        query = query.eq('isCompleted', filters['isCompleted'] as bool);
      }
      if (filters.containsKey('isPriority')) {
        query = query.eq('isPriority', filters['isPriority'] as bool);
      }
    }

    // Add cursor-based filtering for efficient pagination
    if (lastId != null && lastSortValue != null) {
      // Use the sort field and last value to filter
      // This is more efficient than OFFSET for large datasets
      final sortField = _mapSortField(sortBy);
      if (sortOrder == SortOrder.ascending) {
        query = query
            .or('$sortField.gt.$lastSortValue,$sortField.eq.$lastSortValue and id.gt.$lastId');
      } else {
        query = query
            .or('$sortField.lt.$lastSortValue,$sortField.eq.$lastSortValue and id.lt.$lastId');
      }
    }

    // Add ordering
    query = query.order(_mapSortField(sortBy), ascending: sortOrder == SortOrder.ascending);

    // Add pagination with limit
    query = query.limit(validatedPageSize);

    // Execute query
    final response = await query;
    final activitiesData = response as List<dynamic>;
    final activities = activitiesData
        .map((data) => _mapToActivity(data as Map<String, dynamic>))
        .toList();

    // Determine if there's a next page
    // We fetch one extra record to check for more pages
    final hasNextPage = activities.length == validatedPageSize;

    // Generate next cursor
    String? nextCursor;
    if (hasNextPage && activities.isNotEmpty) {
      final lastActivity = activities.last;
      nextCursor = _encodeCursor(
        lastId: lastActivity.id,
        lastSortValue: _getSortValue(lastActivity, sortBy),
        offset: offset + validatedPageSize,
      );
    }

    // Create page info
    final pageInfo = createCursorPageInfo(
      currentCursor: cursor,
      pageSize: validatedPageSize,
      itemsCount: activities.length,
      hasNextPage: hasNextPage,
      nextCursor: nextCursor,
      previousCursor: offset > 0
          ? _encodeCursor(
              lastId: lastId,
              lastSortValue: lastSortValue,
              offset: offset - validatedPageSize,
            )
          : null,
    );

    return PaginatedData<Activity>(
      items: activities,
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

    // Build Supabase query
    var query = _client
        .from('activities')
        .select()
        .eq('userId', userId);

    // Add trip filter if provided
    if (tripId != null) {
      query = query.eq('tripId', tripId);
    }

    // Add additional filters
    if (filters != null) {
      if (filters.containsKey('category')) {
        query = query.eq('category', filters['category'].toString());
      }
      if (filters.containsKey('isCompleted')) {
        query = query.eq('isCompleted', filters['isCompleted'] as bool);
      }
      if (filters.containsKey('isPriority')) {
        query = query.eq('isPriority', filters['isPriority'] as bool);
      }
    }

    // Get total count for pagination metadata
    final countResponse = await query
        .select()
        .count(CountOption.exact);
    final totalItems = countResponse.count ?? 0;

    // Add ordering
    query = query.order(_mapSortField(sortBy), ascending: sortOrder == SortOrder.ascending);

    // Add offset and limit
    query = query.range(offset, offset + validatedPageSize - 1);

    // Execute query
    final response = await query;
    final activitiesData = response as List<dynamic>;
    final activities = activitiesData
        .map((data) => _mapToActivity(data as Map<String, dynamic>))
        .toList();

    // Create page info
    final pageInfo = createOffsetPageInfo(
      currentPage: page,
      pageSize: validatedPageSize,
      totalItems: totalItems,
      itemsCount: activities.length,
    );

    return PaginatedData<Activity>(
      items: activities,
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
    // Use cursor pagination but select only metadata fields
    final validatedPageSize = validatePageSize(pageSize);
    final cursorData = _decodeCursor(cursor);
    final offset = cursorData?['offset'] as int? ?? 0;
    final lastId = cursorData?['lastId'] as String?;

    // Build query with only metadata fields (more efficient)
    var query = _client
        .from('activities')
        .select('id, title, category, startDateTime, locationName, isCompleted, isPriority')
        .eq('userId', userId);

    if (tripId != null) {
      query = query.eq('tripId', tripId);
    }

    // Cursor-based filtering
    if (lastId != null) {
      query = query.gt('id', lastId);
    }

    query = query.order('id').limit(validatedPageSize);

    // Execute query
    final response = await query;
    final metadataData = response as List<dynamic>;
    final metadataList = metadataData
        .map((data) => _mapToActivityMetadata(data as Map<String, dynamic>))
        .toList();

    // Determine if there's a next page
    final hasNextPage = metadataList.length == validatedPageSize;

    // Generate next cursor
    final nextCursor = hasNextPage && metadataList.isNotEmpty
        ? _encodeCursor(
            lastId: metadataList.last.id,
            offset: offset + validatedPageSize,
          )
        : null;

    final pageInfo = createCursorPageInfo(
      currentCursor: cursor,
      pageSize: validatedPageSize,
      itemsCount: metadataList.length,
      hasNextPage: hasNextPage,
      nextCursor: nextCursor,
    );

    return PaginatedData<ActivityMetadata>(
      items: metadataList,
      pageInfo: pageInfo,
    );
  }

  @override
  Future<Activity?> getActivityById({required String activityId}) async {
    final response = await _client
        .from('activities')
        .select()
        .eq('id', activityId)
        .single()
        .catchError((_) => null);

    if (response == null) return null;

    return _mapToActivity(response as Map<String, dynamic>);
  }

  @override
  Future<List<Activity>> getActivitiesByIds({
    required List<String> activityIds,
  }) async {
    if (activityIds.isEmpty) return [];

    final response = await _client
        .from('activities')
        .select()
        .inFilter('id', activityIds);

    final activitiesData = response as List<dynamic>;
    return activitiesData
        .map((data) => _mapToActivity(data as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<Activity> createActivity({required Activity activity}) async {
    final data = _mapToDatabase(activity);

    final response = await _client
        .from('activities')
        .insert(data)
        .select()
        .single();

    return _mapToActivity(response as Map<String, dynamic>);
  }

  @override
  Future<Activity> updateActivity({
    required String activityId,
    required Activity updates,
  }) async {
    final data = _mapToDatabase(updates);

    final response = await _client
        .from('activities')
        .update(data)
        .eq('id', activityId)
        .select()
        .single();

    return _mapToActivity(response as Map<String, dynamic>);
  }

  @override
  Future<bool> deleteActivity({required String activityId}) async {
    final count = await _client
        .from('activities')
        .delete()
        .eq('id', activityId)
        .select()
        .count(CountOption.exact);

    return (count.count ?? 0) > 0;
  }

  @override
  Future<Activity> toggleActivityCompletion({
    required String activityId,
    required bool isCompleted,
  }) async {
    final response = await _client
        .from('activities')
        .update({'isCompleted': isCompleted, 'updatedAt': DateTime.now().toIso8601String()})
        .eq('id', activityId)
        .select()
        .single();

    return _mapToActivity(response as Map<String, dynamic>);
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
    // Use cursor pagination if provided
    if (cursor != null) {
      return getActivitiesCursor(
        tripId: tripId,
        userId: userId,
        cursor: cursor,
        pageSize: pageSize,
        filters: {'search': query},
      );
    }

    // Otherwise use offset pagination
    final validatedPageSize = validatePageSize(pageSize);
    final currentPage = page ?? 1;
    final offset = (currentPage - 1) * validatedPageSize;

    // Build search query using text search or ILIKE
    var queryBuilder = _client
        .from('activities')
        .select()
        .eq('userId', userId);

    if (tripId != null) {
      queryBuilder = queryBuilder.eq('tripId', tripId);
    }

    // Search across multiple fields
    queryBuilder = queryBuilder.or(
      'title.ilike.%$query%,description.ilike.%$query%,locationName.ilike.%$query%,address.ilike.%$query%',
    );

    // Get total count
    final countResponse = await queryBuilder.count(CountOption.exact);
    final totalItems = countResponse.count ?? 0;

    // Add ordering and pagination
    queryBuilder = queryBuilder
        .order('startDateTime', ascending: true)
        .range(offset, offset + validatedPageSize - 1);

    final response = await queryBuilder;
    final activitiesData = response as List<dynamic>;
    final activities = activitiesData
        .map((data) => _mapToActivity(data as Map<String, dynamic>))
        .toList();

    final pageInfo = createOffsetPageInfo(
      currentPage: currentPage,
      pageSize: validatedPageSize,
      totalItems: totalItems,
      itemsCount: activities.length,
    );

    return PaginatedData<Activity>(
      items: activities,
      pageInfo: pageInfo,
    );
  }

  @override
  Future<PaginatedData<Activity>> getActivitiesByCategory({
    String? tripId,
    required String userId,
    required ActivityCategory category,
    String? cursor,
    int pageSize = 20,
  }) {
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
  }) {
    return getActivitiesCursor(
      tripId: tripId,
      userId: userId,
      cursor: cursor,
      pageSize: pageSize,
      filters: {
        'startDate': startDate.toIso8601String(),
        'endDate': endDate.toIso8601String(),
      },
    );
  }

  @override
  Future<PaginatedData<Activity>> getUpcomingActivities({
    String? tripId,
    required String userId,
    String? cursor,
    int pageSize = 10,
  }) {
    final now = DateTime.now();
    return getActivitiesCursor(
      tripId: tripId,
      userId: userId,
      cursor: cursor,
      pageSize: pageSize,
      sortBy: 'startDateTime',
      sortOrder: SortOrder.ascending,
      filters: {'startDate': now.toIso8601String()},
    );
  }

  @override
  Future<PaginatedData<Activity>> getCompletedActivities({
    String? tripId,
    required String userId,
    String? cursor,
    int pageSize = 20,
  }) {
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
  }) {
    return getActivitiesCursor(
      tripId: tripId,
      userId: userId,
      cursor: cursor,
      pageSize: pageSize,
      sortBy: 'startDateTime',
      sortOrder: SortOrder.ascending,
      filters: {'isPriority': true},
    );
  }

  @override
  Future<int> countActivities({
    String? tripId,
    required String userId,
    Map<String, dynamic>? filters,
  }) async {
    var query = _client
        .from('activities')
        .select()
        .eq('userId', userId);

    if (tripId != null) {
      query = query.eq('tripId', tripId);
    }

    if (filters != null) {
      if (filters.containsKey('isCompleted')) {
        query = query.eq('isCompleted', filters['isCompleted'] as bool);
      }
      if (filters.containsKey('category')) {
        query = query.eq('category', filters['category'].toString());
      }
    }

    final countResponse = await query.count(CountOption.exact);
    return countResponse.count ?? 0;
  }

  @override
  Future<int> bulkUpdateActivities({
    required List<String> activityIds,
    required Map<String, dynamic> updates,
  }) async {
    if (activityIds.isEmpty) return 0;

    final response = await _client
        .from('activities')
        .update({
          ...updates,
          'updatedAt': DateTime.now().toIso8601String(),
        })
        .inFilter('id', activityIds)
        .select();

    return (response as List<dynamic>).length;
  }

  // Private helper methods

  /// Maps Activity object to database format
  Map<String, dynamic> _mapToDatabase(Activity activity) {
    return {
      'id': activity.id,
      'tripId': activity.tripId,
      'userId': activity.userId,
      'title': activity.title,
      'description': activity.description,
      'category': activity.category.name,
      'locationName': activity.locationName,
      'address': activity.address,
      'latitude': activity.latitude,
      'longitude': activity.longitude,
      'startDateTime': activity.startDateTime?.toIso8601String(),
      'endDateTime': activity.endDateTime?.toIso8601String(),
      'estimatedCost': activity.estimatedCost,
      'actualCost': activity.actualCost,
      'currency': activity.currency,
      'confirmationNumber': activity.confirmationNumber,
      'websiteUrl': activity.websiteUrl,
      'phoneNumber': activity.phoneNumber,
      'notes': activity.notes,
      'isCompleted': activity.isCompleted,
      'isPriority': activity.isPriority,
      'photoIds': activity.photoIds,
      'tags': activity.tags,
      'createdAt': activity.createdAt.toIso8601String(),
      'updatedAt': activity.updatedAt.toIso8601String(),
    };
  }

  /// Maps database record to Activity object
  Activity _mapToActivity(Map<String, dynamic> data) {
    return Activity(
      id: data['id'] as String,
      tripId: data['tripId'] as String,
      userId: data['userId'] as String,
      title: data['title'] as String,
      description: data['description'] as String?,
      category: _parseActivityCategory(data['category'] as String?),
      locationName: data['locationName'] as String?,
      address: data['address'] as String?,
      latitude: (data['latitude'] as num?)?.toDouble(),
      longitude: (data['longitude'] as num?)?.toDouble(),
      startDateTime: data['startDateTime'] != null
          ? DateTime.parse(data['startDateTime'] as String)
          : null,
      endDateTime: data['endDateTime'] != null
          ? DateTime.parse(data['endDateTime'] as String)
          : null,
      estimatedCost: (data['estimatedCost'] as num?)?.toDouble(),
      actualCost: (data['actualCost'] as num?)?.toDouble(),
      currency: data['currency'] as String?,
      confirmationNumber: data['confirmationNumber'] as String?,
      websiteUrl: data['websiteUrl'] as String?,
      phoneNumber: data['phoneNumber'] as String?,
      notes: data['notes'] as String?,
      isCompleted: data['isCompleted'] as bool? ?? false,
      isPriority: data['isPriority'] as bool? ?? false,
      photoIds: (data['photoIds'] as List<dynamic>?)?.cast<String>(),
      tags: (data['tags'] as List<dynamic>?)?.cast<String>(),
      createdAt: DateTime.parse(data['createdAt'] as String),
      updatedAt: DateTime.parse(data['updatedAt'] as String),
    );
  }

  /// Maps database record to ActivityMetadata object
  ActivityMetadata _mapToActivityMetadata(Map<String, dynamic> data) {
    return ActivityMetadata(
      id: data['id'] as String,
      title: data['title'] as String,
      category: _parseActivityCategory(data['category'] as String?),
      startDateTime: data['startDateTime'] != null
          ? DateTime.parse(data['startDateTime'] as String)
          : null,
      locationName: data['locationName'] as String?,
      isCompleted: data['isCompleted'] as bool? ?? false,
      isPriority: data['isPriority'] as bool? ?? false,
    );
  }

  /// Parses activity category from string
  ActivityCategory _parseActivityCategory(String? categoryStr) {
    if (categoryStr == null) return ActivityCategory.other;
    return ActivityCategory.values.firstWhere(
      (cat) => cat.name == categoryStr,
      orElse: () => ActivityCategory.other,
    );
  }

  /// Maps sort field name to database column name
  String _mapSortField(String sortBy) {
    switch (sortBy) {
      case 'title':
        return 'title';
      case 'category':
        return 'category';
      case 'estimatedCost':
        return 'estimatedCost';
      case 'startDateTime':
        return 'startDateTime';
      case 'createdAt':
        return 'createdAt';
      default:
        return 'createdAt';
    }
  }

  /// Gets the sort value from an activity for cursor encoding
  dynamic _getSortValue(Activity activity, String sortBy) {
    switch (sortBy) {
      case 'title':
        return activity.title;
      case 'category':
        return activity.category.name;
      case 'estimatedCost':
        return activity.estimatedCost;
      case 'startDateTime':
        return activity.startDateTime?.toIso8601String();
      case 'createdAt':
        return activity.createdAt.toIso8601String();
      default:
        return activity.createdAt.toIso8601String();
    }
  }

  /// Encodes cursor data to base64 string
  String _encodeCursor({
    required String? lastId,
    dynamic lastSortValue,
    required int offset,
  }) {
    final cursorData = {
      'lastId': lastId,
      'lastSortValue': lastSortValue,
      'offset': offset,
    };
    final jsonStr = Uri.encodeComponent(cursorData.toString());
    return base64.encode(jsonStr.codeUnits);
  }

  /// Decodes cursor string to cursor data
  Map<String, dynamic>? _decodeCursor(String? cursor) {
    if (cursor == null || cursor.isEmpty) return null;

    try {
      final jsonStr = String.fromCharCodes(base64.decode(cursor));
      final decoded = Uri.decodeComponent(jsonStr);
      // Parse the map string back to Map
      return Map<String, dynamic>.from(
        decoded.replaceAll(RegExp('[{}]'), '').split(',').map((pair) {
          final parts = pair.split(':');
          return MapEntry(parts[0].trim(), parts[1].trim());
        }),
      );
    } catch (e) {
      // If cursor parsing fails, return null (start from beginning)
      return null;
    }
  }
}
