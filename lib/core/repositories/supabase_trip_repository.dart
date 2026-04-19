import 'dart:convert';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../../features/travel/domain/models/trip.dart';
import '../../features/travel/domain/repositories/trip_repository.dart';
import '../models/paginated_data.dart';
import 'paginated_repository_mixin.dart';

/// Supabase implementation of TripRepository with cursor-based pagination
///
/// This repository provides efficient cursor-based pagination for trips
/// using Supabase's PostgreSQL backend. It leverages database indexes created
/// in the performance optimization migration for optimal query performance.
///
/// **Key Performance Features:**
/// - Cursor-based pagination prevents duplicate/missed items with concurrent changes
/// - Uses database indexes (idx_trips_user, idx_trips_user_created_at)
/// - Page size validation (max 100) prevents excessive data transfer
/// - Optimized for datasets with 200+ trips
///
/// **Cursor Encoding:**
/// Cursors are encoded as base64 JSON strings containing:
/// - The last trip's ID (for positioning)
/// - The last trip's sort field value (for ordering)
/// - Offset information (for fallback)
///
/// Example:
/// ```dart
/// final repository = SupabaseTripRepository(supabaseClient);
///
/// // First page
/// final firstPage = await repository.getTripsCursor(
///   userId: 'user123',
///   pageSize: 20,
/// );
///
/// // Next page using cursor
/// if (firstPage.pageInfo.hasNextPage) {
///   final nextPage = await repository.getTripsCursor(
///     userId: 'user123',
///     cursor: firstPage.pageInfo.nextCursor,
///     pageSize: 20,
///   );
/// }
/// ```
///
/// **Note:** This is a placeholder implementation. Actual Supabase queries
/// will be added when the supabase_flutter package is integrated into the project.
class SupabaseTripRepository
    with PaginatedRepositoryMixin
    implements TripRepository {
  final SupabaseClient _client;

  /// Creates a new SupabaseTripRepository
  ///
  /// The [client] parameter should be an initialized SupabaseClient instance.
  SupabaseTripRepository({required SupabaseClient client}) : _client = client;

  @override
  Future<PaginatedData<Trip>> getTripsCursor({
    required String userId,
    String? cursor,
    int pageSize = 20,
    String sortBy = 'createdAt',
    SortOrder sortOrder = SortOrder.descending,
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
    dynamic query = _client.from('trips').select().eq('userId', userId);

    // Add additional filters
    if (filters != null) {
      if (filters.containsKey('status')) {
        query = query.eq('status', filters['status'] as String);
      }
      if (filters.containsKey('destination')) {
        query = query.ilike('destination', '%${filters['destination']}%');
      }
      if (filters.containsKey('startDate')) {
        query = query.gte('startDate', filters['startDate'] as String);
      }
      if (filters.containsKey('endDate')) {
        query = query.lte('endDate', filters['endDate'] as String);
      }
    }

    // Add cursor-based filtering for efficient pagination
    if (lastId != null && lastSortValue != null) {
      final sortField = _mapSortField(sortBy);
      if (sortOrder == SortOrder.ascending) {
        query = query.or(
            '$sortField.gt.$lastSortValue,$sortField.eq.$lastSortValue and id.gt.$lastId');
      } else {
        query = query.or(
            '$sortField.lt.$lastSortValue,$sortField.eq.$lastSortValue and id.lt.$lastId');
      }
    }

    // Add ordering
    query = query.order(_mapSortField(sortBy),
        ascending: sortOrder == SortOrder.ascending);

    // Add pagination with limit
    query = query.limit(validatedPageSize);

    // Execute query
    final response = await query;
    final tripsData = response as List<dynamic>;
    final trips = tripsData
        .map((data) => _mapToTrip(data as Map<String, dynamic>))
        .toList();

    // Determine if there's a next page
    final hasNextPage = trips.length == validatedPageSize;

    // Generate next cursor
    String? nextCursor;
    if (hasNextPage && trips.isNotEmpty) {
      final lastTrip = trips.last;
      nextCursor = _encodeCursor(
        lastId: lastTrip.id,
        lastSortValue: _getSortValue(lastTrip, sortBy),
        offset: offset + validatedPageSize,
      );
    }

    // Create page info
    final pageInfo = createCursorPageInfo(
      currentCursor: cursor,
      pageSize: validatedPageSize,
      itemsCount: trips.length,
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

    return PaginatedData<Trip>(
      items: trips,
      pageInfo: pageInfo,
    );
  }

  @override
  Future<PaginatedData<Trip>> getTripsOffset({
    required String userId,
    int page = 1,
    int pageSize = 20,
    String sortBy = 'createdAt',
    SortOrder sortOrder = SortOrder.descending,
    Map<String, dynamic>? filters,
  }) async {
    // Validate page size
    final validatedPageSize = validatePageSize(pageSize);

    // Calculate offset
    final offset = (page - 1) * validatedPageSize;

    // Build Supabase query
    dynamic query = _client.from('trips').select().eq('userId', userId);

    // Add additional filters
    if (filters != null) {
      if (filters.containsKey('status')) {
        query = query.eq('status', filters['status'] as String);
      }
      if (filters.containsKey('destination')) {
        query = query.ilike('destination', '%${filters['destination']}%');
      }
      if (filters.containsKey('startDate')) {
        query = query.gte('startDate', filters['startDate'] as String);
      }
      if (filters.containsKey('endDate')) {
        query = query.lte('endDate', filters['endDate'] as String);
      }
    }

    // Get total count for pagination metadata
    final countResponse = await query.count(CountOption.exact);
    final totalItems = countResponse.count ?? 0;

    // Add ordering
    query = query.order(_mapSortField(sortBy),
        ascending: sortOrder == SortOrder.ascending);

    // Add offset and limit
    query = query.range(offset, offset + validatedPageSize - 1);

    // Execute query
    final response = await query;
    final tripsData = response as List<dynamic>;
    final trips = tripsData
        .map((data) => _mapToTrip(data as Map<String, dynamic>))
        .toList();

    // Create page info
    final pageInfo = createOffsetPageInfo(
      currentPage: page,
      pageSize: validatedPageSize,
      totalItems: totalItems,
      itemsCount: trips.length,
    );

    return PaginatedData<Trip>(
      items: trips,
      pageInfo: pageInfo,
    );
  }

  @override
  Future<PaginatedData<TripMetadata>> getTripsMetadata({
    required String userId,
    String? cursor,
    int pageSize = 50,
  }) async {
    // Use cursor pagination but select only metadata fields (more efficient)
    final validatedPageSize = validatePageSize(pageSize);
    final cursorData = _decodeCursor(cursor);
    final offset = cursorData?['offset'] as int? ?? 0;
    final lastId = cursorData?['lastId'] as String?;

    // Build query with only metadata fields
    dynamic query = _client
        .from('trips')
        .select('id, title, destination, startDate, endDate, coverImageUrl')
        .eq('userId', userId);

    // Cursor-based filtering
    if (lastId != null) {
      query = query.gt('id', lastId);
    }

    query = query.order('id').limit(validatedPageSize);

    // Execute query
    final response = await query;
    final metadataData = response as List<dynamic>;
    final metadataList = metadataData
        .map((data) => _mapToTripMetadata(data as Map<String, dynamic>))
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

    return PaginatedData<TripMetadata>(
      items: metadataList,
      pageInfo: pageInfo,
    );
  }

  @override
  Future<Trip?> getTripById({required String tripId}) async {
    final response = await _client
        .from('trips')
        .select()
        .eq('id', tripId)
        .single()
        .catchError((_) => null);

    return _mapToTrip(response);
  }

  @override
  Future<List<Trip>> getTripsByIds({required List<String> tripIds}) async {
    if (tripIds.isEmpty) return [];

    final response =
        await _client.from('trips').select().inFilter('id', tripIds);

    final tripsData = response as List<dynamic>;
    return tripsData
        .map((data) => _mapToTrip(data as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<Trip> createTrip({required Trip trip}) async {
    final data = _mapToDatabase(trip);

    final response = await _client.from('trips').insert(data).select().single();

    return _mapToTrip(response);
  }

  @override
  Future<Trip> updateTrip({
    required String tripId,
    required Trip updates,
  }) async {
    final data = _mapToDatabase(updates);

    final response = await _client
        .from('trips')
        .update(data)
        .eq('id', tripId)
        .select()
        .single();

    return _mapToTrip(response);
  }

  @override
  Future<bool> deleteTrip({required String tripId}) async {
    final count = await _client
        .from('trips')
        .delete()
        .eq('id', tripId)
        .select()
        .count(CountOption.exact);

    return count.count > 0;
  }

  @override
  Future<PaginatedData<Trip>> searchTrips({
    required String userId,
    required String query,
    String? cursor,
    int? page,
    int pageSize = 20,
  }) async {
    // Use cursor pagination if provided
    if (cursor != null) {
      return getTripsCursor(
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

    // Build search query using ILIKE for case-insensitive search
    dynamic queryBuilder = _client.from('trips').select().eq('userId', userId);

    // Search across multiple fields
    queryBuilder = queryBuilder.or(
      'title.ilike.%$query%,description.ilike.%$query%,destination.ilike.%$query%',
    );

    // Get total count
    final countResponse = await queryBuilder.count(CountOption.exact);
    final totalItems = countResponse.count ?? 0;

    // Add ordering and pagination
    queryBuilder = queryBuilder
        .order('createdAt', ascending: false)
        .range(offset, offset + validatedPageSize - 1);

    final response = await queryBuilder;
    final tripsData = response as List<dynamic>;
    final trips = tripsData
        .map((data) => _mapToTrip(data as Map<String, dynamic>))
        .toList();

    final pageInfo = createOffsetPageInfo(
      currentPage: currentPage,
      pageSize: validatedPageSize,
      totalItems: totalItems,
      itemsCount: trips.length,
    );

    return PaginatedData<Trip>(
      items: trips,
      pageInfo: pageInfo,
    );
  }

  @override
  Future<int> countTrips({
    required String userId,
    Map<String, dynamic>? filters,
  }) async {
    dynamic query = _client.from('trips').select().eq('userId', userId);

    if (filters != null) {
      if (filters.containsKey('status')) {
        query = query.eq('status', filters['status'] as String);
      }
    }

    final countResponse = await query.count(CountOption.exact);
    return countResponse.count ?? 0;
  }

  @override
  Future<PaginatedData<Trip>> getTripsInDateRange({
    required String userId,
    required DateTime startDate,
    required DateTime endDate,
    String? cursor,
    int pageSize = 20,
  }) {
    return getTripsCursor(
      userId: userId,
      cursor: cursor,
      pageSize: pageSize,
      sortBy: 'startDate',
      sortOrder: SortOrder.ascending,
      filters: {
        'startDate': startDate.toIso8601String(),
        'endDate': endDate.toIso8601String(),
      },
    );
  }

  // Private helper methods

  /// Maps Trip object to database format
  Map<String, dynamic> _mapToDatabase(Trip trip) {
    return {
      'id': trip.id,
      'userId': trip.userId,
      'title': trip.title,
      'description': trip.description,
      'startDate': trip.startDate.toIso8601String(),
      'endDate': trip.endDate.toIso8601String(),
      'destination': trip.destination,
      'latitude': trip.latitude,
      'longitude': trip.longitude,
      'status': trip.status,
      'budget': trip.budget,
      'coverImageUrl': trip.coverImageUrl,
      'travelCompanionIds': trip.travelCompanionIds,
      'createdAt': trip.createdAt.toIso8601String(),
      'updatedAt': trip.updatedAt.toIso8601String(),
    };
  }

  /// Maps database record to Trip object
  Trip _mapToTrip(Map<String, dynamic> data) {
    return Trip(
      id: data['id'] as String,
      userId: data['userId'] as String,
      title: data['title'] as String,
      description: data['description'] as String?,
      startDate: DateTime.parse(data['startDate'] as String),
      endDate: DateTime.parse(data['endDate'] as String),
      destination: data['destination'] as String,
      latitude: (data['latitude'] as num?)?.toDouble(),
      longitude: (data['longitude'] as num?)?.toDouble(),
      status: data['status'] as String,
      budget: data['budget'] as int,
      coverImageUrl: data['coverImageUrl'] as String?,
      travelCompanionIds:
          (data['travelCompanionIds'] as List<dynamic>?)?.cast<String>(),
      createdAt: DateTime.parse(data['createdAt'] as String),
      updatedAt: DateTime.parse(data['updatedAt'] as String),
    );
  }

  /// Maps database record to TripMetadata object
  TripMetadata _mapToTripMetadata(Map<String, dynamic> data) {
    return TripMetadata(
      id: data['id'] as String,
      title: data['title'] as String,
      destination: data['destination'] as String,
      startDate: DateTime.parse(data['startDate'] as String),
      endDate: DateTime.parse(data['endDate'] as String),
      coverImageUrl: data['coverImageUrl'] as String?,
    );
  }

  /// Maps sort field name to database column name
  String _mapSortField(String sortBy) {
    switch (sortBy) {
      case 'title':
        return 'title';
      case 'destination':
        return 'destination';
      case 'startDate':
        return 'startDate';
      case 'endDate':
        return 'endDate';
      case 'createdAt':
        return 'createdAt';
      default:
        return 'createdAt';
    }
  }

  /// Gets the sort value from a trip for cursor encoding
  dynamic _getSortValue(Trip trip, String sortBy) {
    switch (sortBy) {
      case 'title':
        return trip.title;
      case 'destination':
        return trip.destination;
      case 'startDate':
        return trip.startDate.toIso8601String();
      case 'endDate':
        return trip.endDate.toIso8601String();
      case 'createdAt':
        return trip.createdAt.toIso8601String();
      default:
        return trip.createdAt.toIso8601String();
    }
  }

  /// Encodes cursor data to base64 JSON string
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
    final jsonStr = jsonEncode(cursorData);
    return base64.encode(utf8.encode(jsonStr));
  }

  /// Decodes cursor string to cursor data
  Map<String, dynamic>? _decodeCursor(String? cursor) {
    if (cursor == null || cursor.isEmpty) return null;

    try {
      final jsonStr = utf8.decode(base64.decode(cursor));
      return Map<String, dynamic>.from(jsonDecode(jsonStr));
    } catch (e) {
      // If cursor parsing fails, return null (start from beginning)
      return null;
    }
  }
}
