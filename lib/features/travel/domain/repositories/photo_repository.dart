import 'package:soloadventurer/core/models/paginated_data.dart';
import 'package:soloadventurer/core/repositories/paginated_repository_mixin.dart';
import '../models/photo.dart';

/// Repository interface for managing photo data with pagination support
///
/// This repository provides CRUD operations for photos along with
/// cursor-based and offset-based pagination methods for efficiently
/// handling large datasets (1000+ photos).
///
/// The repository follows these patterns:
/// - Cursor-based pagination for infinite scroll (recommended)
/// - Offset-based pagination for traditional page navigation
/// - Filtering by trip, date range, location
/// - Sorting by date, creation time
abstract class PhotoRepository {
  /// Get paginated list of photos using cursor-based pagination
  ///
  /// This is the recommended method for infinite scroll implementations.
  /// Cursor-based pagination provides better performance and consistency
  /// when new photos are added concurrently.
  ///
  /// Parameters:
  /// - [tripId]: Trip ID to filter photos (optional, if null gets all user photos)
  /// - [userId]: User ID to filter photos (required)
  /// - [cursor]: Pagination cursor from previous page's PageInfo.nextCursor
  ///             Use null for the first page
  /// - [pageSize]: Number of photos per page (default: 20, max: 100)
  /// - [sortBy]: Field to sort by (default: 'takenAt')
  /// - [sortOrder]: Sort order - ascending or descending (default: descending)
  /// - [filters]: Optional filters (e.g., {'hasLocation': true})
  ///
  /// Returns [PaginatedData<Photo>] containing photos and pagination metadata.
  ///
  /// Example:
  /// ```dart
  /// // First page of photos for a trip
  /// final firstPage = await photoRepository.getPhotosCursor(
  ///   tripId: 'trip123',
  ///   userId: 'user123',
  ///   pageSize: 20,
  /// );
  ///
  /// // Next page
  /// if (firstPage.hasNextPage) {
  ///   final nextPage = await photoRepository.getPhotosCursor(
  ///     tripId: 'trip123',
  ///     userId: 'user123',
  ///     cursor: firstPage.pageInfo.nextCursor,
  ///     pageSize: 20,
  ///   );
  /// }
  /// ```
  Future<PaginatedData<Photo>> getPhotosCursor({
    String? tripId,
    required String userId,
    String? cursor,
    int pageSize = 20,
    String sortBy = 'takenAt',
    SortOrder sortOrder = SortOrder.descending,
    Map<String, dynamic>? filters,
  });

  /// Get paginated list of photos using offset-based pagination
  ///
  /// This method is useful for traditional page navigation (e.g., page 1, 2, 3).
  /// Note that offset-based pagination can be inconsistent with concurrent
  /// inserts/deletes. For infinite scroll, prefer [getPhotosCursor].
  ///
  /// Parameters:
  /// - [tripId]: Trip ID to filter photos (optional)
  /// - [userId]: User ID to filter photos (required)
  /// - [page]: Page number (1-based, default: 1)
  /// - [pageSize]: Number of photos per page (default: 20, max: 100)
  /// - [sortBy]: Field to sort by (default: 'takenAt')
  /// - [sortOrder]: Sort order - ascending or descending (default: descending)
  /// - [filters]: Optional filters
  ///
  /// Returns [PaginatedData<Photo>] containing photos and pagination metadata.
  Future<PaginatedData<Photo>> getPhotosOffset({
    String? tripId,
    required String userId,
    int page = 1,
    int pageSize = 20,
    String sortBy = 'takenAt',
    SortOrder sortOrder = SortOrder.descending,
    Map<String, dynamic>? filters,
  });

  /// Get lightweight photo metadata for grid rendering (optimized for 1000+ items)
  ///
  /// This method returns only essential fields needed for grid items,
  /// reducing memory usage and improving rendering performance.
  ///
  /// Returns partial photo data: id, thumbnailUrl, takenAt, width, height, aspectRatio
  ///
  /// Use this when rendering photo grids and load full details on-demand
  /// when the user taps on a photo.
  Future<PaginatedData<PhotoMetadata>> getPhotosMetadata({
    String? tripId,
    required String userId,
    String? cursor,
    int pageSize = 50,
  });

  /// Get a single photo by ID
  ///
  /// Returns full photo details including all fields.
  /// Returns null if the photo is not found.
  Future<Photo?> getPhotoById({required String photoId});

  /// Get multiple photos by IDs (batch query)
  ///
  /// More efficient than calling [getPhotoById] multiple times.
  /// Returns photos in the same order as the provided IDs.
  /// Missing photos will not be included in the result.
  Future<List<Photo>> getPhotosByIds({required List<String> photoIds});

  /// Create a new photo
  ///
  /// Returns the created photo with generated ID and timestamps.
  Future<Photo> createPhoto({required Photo photo});

  /// Update an existing photo
  ///
  /// Returns the updated photo.
  /// Throws [NotFoundException] if the photo doesn't exist.
  Future<Photo> updatePhoto({
    required String photoId,
    required Photo updates,
  });

  /// Delete a photo
  ///
  /// Returns true if the photo was deleted, false if it didn't exist.
  Future<bool> deletePhoto({required String photoId});

  /// Search photos by query string
  ///
  /// Searches across caption and location fields.
  /// Supports both cursor and offset pagination.
  Future<PaginatedData<Photo>> searchPhotos({
    String? tripId,
    required String userId,
    required String query,
    String? cursor,
    int? page,
    int pageSize = 20,
  });

  /// Get photos within a date range
  ///
  /// Useful for filtering photos by when they were taken.
  /// Photos are filtered by takenAt timestamp.
  Future<PaginatedData<Photo>> getPhotosInDateRange({
    String? tripId,
    required String userId,
    required DateTime startDate,
    required DateTime endDate,
    String? cursor,
    int pageSize = 20,
  });

  /// Get photos with location data
  ///
  /// Returns only photos that have latitude and longitude coordinates.
  /// Useful for map features and location-based filtering.
  Future<PaginatedData<Photo>> getPhotosWithLocation({
    String? tripId,
    required String userId,
    String? cursor,
    int pageSize = 20,
  });

  /// Count total photos for a user or trip
  ///
  /// Returns the total number of photos matching optional filters.
  /// Useful for displaying counts and progress indicators.
  Future<int> countPhotos({
    String? tripId,
    required String userId,
    Map<String, dynamic>? filters,
  });

  /// Bulk delete photos
  ///
  /// Deletes multiple photos in a single operation.
  /// More efficient than calling [deletePhoto] multiple times.
  ///
  /// Returns the number of photos successfully deleted.
  Future<int> bulkDeletePhotos({required List<String> photoIds});

  /// Bulk update photos
  ///
  /// Updates multiple photos in a single operation.
  /// More efficient than calling [updatePhoto] multiple times.
  ///
  /// Returns the number of photos successfully updated.
  Future<int> bulkUpdatePhotos({
    required List<String> photoIds,
    required Map<String, dynamic> updates,
  });
}

/// Lightweight photo metadata for efficient grid rendering
///
/// Contains only essential fields needed for displaying photo items
/// in grids, reducing memory usage for 1000+ photos.
class PhotoMetadata {
  final String id;
  final String? thumbnailUrl;
  final DateTime takenAt;
  final int width;
  final int height;
  final double aspectRatio;
  final String? location;

  const PhotoMetadata({
    required this.id,
    this.thumbnailUrl,
    required this.takenAt,
    required this.width,
    required this.height,
    required this.aspectRatio,
    this.location,
  });

  /// Creates PhotoMetadata from full Photo object
  factory PhotoMetadata.fromPhoto(Photo photo) {
    return PhotoMetadata(
      id: photo.id,
      thumbnailUrl: photo.thumbnailUrl,
      takenAt: photo.takenAt,
      width: photo.width,
      height: photo.height,
      aspectRatio: photo.aspectRatio,
      location: photo.location,
    );
  }

  @override
  String toString() {
    return 'PhotoMetadata('
        'id: $id, '
        'takenAt: $takenAt, '
        'aspectRatio: $aspectRatio)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is PhotoMetadata &&
        other.id == id &&
        other.thumbnailUrl == thumbnailUrl &&
        other.takenAt == takenAt &&
        other.width == width &&
        other.height == height &&
        other.aspectRatio == aspectRatio &&
        other.location == location;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        thumbnailUrl.hashCode ^
        takenAt.hashCode ^
        width.hashCode ^
        height.hashCode ^
        aspectRatio.hashCode ^
        location.hashCode;
  }
}
