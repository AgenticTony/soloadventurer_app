import 'dart:convert';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../../features/travel/domain/models/photo.dart';
import '../../features/travel/domain/repositories/photo_repository.dart';
import '../models/paginated_data.dart';
import 'paginated_repository_mixin.dart';

/// Supabase implementation of PhotoRepository with cursor-based pagination
///
/// This repository provides efficient cursor-based pagination for photos
/// using Supabase's PostgreSQL backend. It leverages database indexes created
/// in the performance optimization migration for optimal query performance.
///
/// **Key Performance Features:**
/// - Cursor-based pagination prevents duplicate/missed items with concurrent changes
/// - Uses database indexes (idx_photos_trip, idx_photos_trip_taken_at)
/// - Page size validation (max 100) prevents excessive data transfer
/// - Optimized for datasets with 1000+ photos
/// - Metadata-only queries for efficient grid rendering
///
/// **Cursor Encoding:**
/// Cursors are encoded as base64 JSON strings containing:
/// - The last photo's ID (for positioning)
/// - The last photo's sort field value (for ordering)
/// - Offset information (for fallback)
///
/// Example:
/// ```dart
/// final repository = SupabasePhotoRepository(supabaseClient);
///
/// // First page
/// final firstPage = await repository.getPhotosCursor(
///   userId: 'user123',
///   tripId: 'trip456',
///   pageSize: 20,
/// );
///
/// // Next page using cursor
/// if (firstPage.pageInfo.hasNextPage) {
///   final nextPage = await repository.getPhotosCursor(
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
class SupabasePhotoRepository
    with PaginatedRepositoryMixin
    implements PhotoRepository {
  final SupabaseClient _client;

  /// Creates a new SupabasePhotoRepository
  ///
  /// The [client] parameter should be an initialized SupabaseClient instance.
  SupabasePhotoRepository({required SupabaseClient client}) : _client = client;

  @override
  Future<PaginatedData<Photo>> getPhotosCursor({
    String? tripId,
    required String userId,
    String? cursor,
    int pageSize = 20,
    String sortBy = 'takenAt',
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
    // Assuming photos table has a userId foreign key or join table
    var query = _client.from('photos').select().eq('userId', userId);

    // Add trip filter if provided
    if (tripId != null) {
      query = query.eq('tripId', tripId);
    }

    // Add additional filters
    if (filters != null) {
      if (filters.containsKey('hasLocation') &&
          filters['hasLocation'] == true) {
        query = query.not('latitude', 'is', null).not('longitude', 'is', null);
      }
      if (filters.containsKey('startDate')) {
        query = query.gte('takenAt', filters['startDate'] as String);
      }
      if (filters.containsKey('endDate')) {
        query = query.lte('takenAt', filters['endDate'] as String);
      }
      if (filters.containsKey('search')) {
        final searchQuery = filters['search'] as String;
        query = query
            .or('caption.ilike.%$searchQuery%,location.ilike.%$searchQuery%');
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
    final photosData = response as List<dynamic>;
    final photos = photosData
        .map((data) => _mapToPhoto(data as Map<String, dynamic>))
        .toList();

    // Determine if there's a next page
    final hasNextPage = photos.length == validatedPageSize;

    // Generate next cursor
    String? nextCursor;
    if (hasNextPage && photos.isNotEmpty) {
      final lastPhoto = photos.last;
      nextCursor = _encodeCursor(
        lastId: lastPhoto.id,
        lastSortValue: _getSortValue(lastPhoto, sortBy),
        offset: offset + validatedPageSize,
      );
    }

    // Create page info
    final pageInfo = createCursorPageInfo(
      currentCursor: cursor,
      pageSize: validatedPageSize,
      itemsCount: photos.length,
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

    return PaginatedData<Photo>(
      items: photos,
      pageInfo: pageInfo,
    );
  }

  @override
  Future<PaginatedData<Photo>> getPhotosOffset({
    String? tripId,
    required String userId,
    int page = 1,
    int pageSize = 20,
    String sortBy = 'takenAt',
    SortOrder sortOrder = SortOrder.descending,
    Map<String, dynamic>? filters,
  }) async {
    // Validate page size
    final validatedPageSize = validatePageSize(pageSize);

    // Calculate offset
    final offset = (page - 1) * validatedPageSize;

    // Build Supabase query
    var query = _client.from('photos').select().eq('userId', userId);

    // Add trip filter if provided
    if (tripId != null) {
      query = query.eq('tripId', tripId);
    }

    // Add additional filters
    if (filters != null) {
      if (filters.containsKey('hasLocation') &&
          filters['hasLocation'] == true) {
        query = query.not('latitude', 'is', null).not('longitude', 'is', null);
      }
      if (filters.containsKey('startDate')) {
        query = query.gte('takenAt', filters['startDate'] as String);
      }
      if (filters.containsKey('endDate')) {
        query = query.lte('takenAt', filters['endDate'] as String);
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
    final photosData = response as List<dynamic>;
    final photos = photosData
        .map((data) => _mapToPhoto(data as Map<String, dynamic>))
        .toList();

    // Create page info
    final pageInfo = createOffsetPageInfo(
      currentPage: page,
      pageSize: validatedPageSize,
      totalItems: totalItems,
      itemsCount: photos.length,
    );

    return PaginatedData<Photo>(
      items: photos,
      pageInfo: pageInfo,
    );
  }

  @override
  Future<PaginatedData<PhotoMetadata>> getPhotosMetadata({
    String? tripId,
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
    var query = _client
        .from('photos')
        .select('id, thumbnailUrl, takenAt, width, height, location')
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
        .map((data) => _mapToPhotoMetadata(data as Map<String, dynamic>))
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

    return PaginatedData<PhotoMetadata>(
      items: metadataList,
      pageInfo: pageInfo,
    );
  }

  @override
  Future<Photo?> getPhotoById({required String photoId}) async {
    final response = await _client
        .from('photos')
        .select()
        .eq('id', photoId)
        .single()
        .catchError((_) => null);

    return _mapToPhoto(response);
  }

  @override
  Future<List<Photo>> getPhotosByIds({required List<String> photoIds}) async {
    if (photoIds.isEmpty) return [];

    final response =
        await _client.from('photos').select().inFilter('id', photoIds);

    final photosData = response as List<dynamic>;
    return photosData
        .map((data) => _mapToPhoto(data as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<Photo> createPhoto({required Photo photo}) async {
    final data = _mapToDatabase(photo);

    final response =
        await _client.from('photos').insert(data).select().single();

    return _mapToPhoto(response);
  }

  @override
  Future<Photo> updatePhoto({
    required String photoId,
    required Photo updates,
  }) async {
    final data = _mapToDatabase(updates);

    final response = await _client
        .from('photos')
        .update(data)
        .eq('id', photoId)
        .select()
        .single();

    return _mapToPhoto(response);
  }

  @override
  Future<bool> deletePhoto({required String photoId}) async {
    final count = await _client
        .from('photos')
        .delete()
        .eq('id', photoId)
        .select()
        .count(CountOption.exact);

    return (count.count ?? 0) > 0;
  }

  @override
  Future<PaginatedData<Photo>> searchPhotos({
    String? tripId,
    required String userId,
    required String query,
    String? cursor,
    int? page,
    int pageSize = 20,
  }) async {
    // Use cursor pagination if provided
    if (cursor != null) {
      return getPhotosCursor(
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

    // Build search query using ILIKE
    var queryBuilder = _client.from('photos').select().eq('userId', userId);

    if (tripId != null) {
      queryBuilder = queryBuilder.eq('tripId', tripId);
    }

    // Search across caption and location fields
    queryBuilder = queryBuilder.or(
      'caption.ilike.%$query%,location.ilike.%$query%',
    );

    // Get total count
    final countResponse = await queryBuilder.count(CountOption.exact);
    final totalItems = countResponse.count ?? 0;

    // Add ordering and pagination
    queryBuilder = queryBuilder
        .order('takenAt', ascending: false)
        .range(offset, offset + validatedPageSize - 1);

    final response = await queryBuilder;
    final photosData = response as List<dynamic>;
    final photos = photosData
        .map((data) => _mapToPhoto(data as Map<String, dynamic>))
        .toList();

    final pageInfo = createOffsetPageInfo(
      currentPage: currentPage,
      pageSize: validatedPageSize,
      totalItems: totalItems,
      itemsCount: photos.length,
    );

    return PaginatedData<Photo>(
      items: photos,
      pageInfo: pageInfo,
    );
  }

  @override
  Future<PaginatedData<Photo>> getPhotosInDateRange({
    String? tripId,
    required String userId,
    required DateTime startDate,
    required DateTime endDate,
    String? cursor,
    int pageSize = 20,
  }) {
    return getPhotosCursor(
      tripId: tripId,
      userId: userId,
      cursor: cursor,
      pageSize: pageSize,
      sortBy: 'takenAt',
      sortOrder: SortOrder.ascending,
      filters: {
        'startDate': startDate.toIso8601String(),
        'endDate': endDate.toIso8601String(),
      },
    );
  }

  @override
  Future<PaginatedData<Photo>> getPhotosWithLocation({
    String? tripId,
    required String userId,
    String? cursor,
    int pageSize = 20,
  }) {
    return getPhotosCursor(
      tripId: tripId,
      userId: userId,
      cursor: cursor,
      pageSize: pageSize,
      filters: {'hasLocation': true},
    );
  }

  @override
  Future<int> countPhotos({
    String? tripId,
    required String userId,
    Map<String, dynamic>? filters,
  }) async {
    var query = _client.from('photos').select().eq('userId', userId);

    if (tripId != null) {
      query = query.eq('tripId', tripId);
    }

    if (filters != null) {
      if (filters.containsKey('hasLocation') &&
          filters['hasLocation'] == true) {
        query = query.not('latitude', 'is', null).not('longitude', 'is', null);
      }
    }

    final countResponse = await query.count(CountOption.exact);
    return countResponse.count ?? 0;
  }

  @override
  Future<int> bulkDeletePhotos({required List<String> photoIds}) async {
    if (photoIds.isEmpty) return 0;

    final response =
        await _client.from('photos').delete().inFilter('id', photoIds).select();

    return (response as List<dynamic>).length;
  }

  @override
  Future<int> bulkUpdatePhotos({
    required List<String> photoIds,
    required Map<String, dynamic> updates,
  }) async {
    if (photoIds.isEmpty) return 0;

    final response = await _client
        .from('photos')
        .update(updates)
        .inFilter('id', photoIds)
        .select();

    return (response as List<dynamic>).length;
  }

  // Private helper methods

  /// Maps Photo object to database format
  Map<String, dynamic> _mapToDatabase(Photo photo) {
    return {
      'id': photo.id,
      'imageUrl': photo.imageUrl,
      'thumbnailUrl': photo.thumbnailUrl,
      'caption': photo.caption,
      'tripId': photo.tripId,
      'location': photo.location,
      'latitude': photo.latitude,
      'longitude': photo.longitude,
      'takenAt': photo.takenAt.toIso8601String(),
      'width': photo.width,
      'height': photo.height,
      'sizeInBytes': photo.sizeInBytes,
      'createdAt': photo.createdAt.toIso8601String(),
    };
  }

  /// Maps database record to Photo object
  Photo _mapToPhoto(Map<String, dynamic> data) {
    return Photo(
      id: data['id'] as String,
      imageUrl: data['imageUrl'] as String,
      thumbnailUrl: data['thumbnailUrl'] as String?,
      caption: data['caption'] as String?,
      tripId: data['tripId'] as String,
      location: data['location'] as String?,
      latitude: (data['latitude'] as num?)?.toDouble(),
      longitude: (data['longitude'] as num?)?.toDouble(),
      takenAt: DateTime.parse(data['takenAt'] as String),
      width: data['width'] as int,
      height: data['height'] as int,
      sizeInBytes: data['sizeInBytes'] as int,
      createdAt: DateTime.parse(data['createdAt'] as String),
    );
  }

  /// Maps database record to PhotoMetadata object
  PhotoMetadata _mapToPhotoMetadata(Map<String, dynamic> data) {
    final width = data['width'] as int? ?? 0;
    final height = data['height'] as int? ?? 0;

    return PhotoMetadata(
      id: data['id'] as String,
      thumbnailUrl: data['thumbnailUrl'] as String?,
      takenAt: DateTime.parse(data['takenAt'] as String),
      width: width,
      height: height,
      aspectRatio: height > 0 ? width / height : 1.0,
      location: data['location'] as String?,
    );
  }

  /// Maps sort field name to database column name
  String _mapSortField(String sortBy) {
    switch (sortBy) {
      case 'takenAt':
        return 'takenAt';
      case 'createdAt':
        return 'createdAt';
      case 'location':
        return 'location';
      default:
        return 'takenAt';
    }
  }

  /// Gets the sort value from a photo for cursor encoding
  dynamic _getSortValue(Photo photo, String sortBy) {
    switch (sortBy) {
      case 'takenAt':
        return photo.takenAt.toIso8601String();
      case 'createdAt':
        return photo.createdAt.toIso8601String();
      case 'location':
        return photo.location;
      default:
        return photo.takenAt.toIso8601String();
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
