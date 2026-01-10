import 'package:soloadventurer/core/models/paginated_data.dart';
import 'package:soloadventurer/core/repositories/paginated_repository_mixin.dart';
import '../models/trip.dart';

/// Repository interface for managing trip data with pagination support
///
/// This repository provides CRUD operations for trips along with
/// cursor-based and offset-based pagination methods for efficiently
/// handling large datasets (500+ trips).
///
/// The repository follows these patterns:
/// - Cursor-based pagination for infinite scroll (recommended)
/// - Offset-based pagination for traditional page navigation
/// - Filtering and sorting support
/// - Metadata-only queries for efficient list views
abstract class TripRepository {
  /// Get paginated list of trips using cursor-based pagination
  ///
  /// This is the recommended method for infinite scroll implementations.
  /// Cursor-based pagination provides better performance and consistency
  /// when new trips are added concurrently.
  ///
  /// Parameters:
  /// - [userId]: User ID to filter trips (required)
  /// - [cursor]: Pagination cursor from previous page's PageInfo.nextCursor
  ///             Use null for the first page
  /// - [pageSize]: Number of trips per page (default: 20, max: 100)
  /// - [sortBy]: Field to sort by (default: 'createdAt')
  /// - [sortOrder]: Sort order - ascending or descending (default: descending)
  /// - [filters]: Optional filters (e.g., {'status': 'active', 'destination': 'Paris'})
  ///
  /// Returns [PaginatedData<Trip>] containing trips and pagination metadata.
  ///
  /// Example:
  /// ```dart
  /// // First page
  /// final firstPage = await tripRepository.getTripsCursor(
  ///   userId: 'user123',
  ///   pageSize: 20,
  /// );
  ///
  /// // Next page
  /// if (firstPage.hasNextPage) {
  ///   final nextPage = await tripRepository.getTripsCursor(
  ///     userId: 'user123',
  ///     cursor: firstPage.pageInfo.nextCursor,
  ///     pageSize: 20,
  ///   );
  /// }
  /// ```
  Future<PaginatedData<Trip>> getTripsCursor({
    required String userId,
    String? cursor,
    int pageSize = 20,
    String sortBy = 'createdAt',
    SortOrder sortOrder = SortOrder.descending,
    Map<String, dynamic>? filters,
  });

  /// Get paginated list of trips using offset-based pagination
  ///
  /// This method is useful for traditional page navigation (e.g., page 1, 2, 3).
  /// Note that offset-based pagination can be inconsistent with concurrent
  /// inserts/deletes. For infinite scroll, prefer [getTripsCursor].
  ///
  /// Parameters:
  /// - [userId]: User ID to filter trips (required)
  /// - [page]: Page number (1-based, default: 1)
  /// - [pageSize]: Number of trips per page (default: 20, max: 100)
  /// - [sortBy]: Field to sort by (default: 'createdAt')
  /// - [sortOrder]: Sort order - ascending or descending (default: descending)
  /// - [filters]: Optional filters
  ///
  /// Returns [PaginatedData<Trip>] containing trips and pagination metadata.
  ///
  /// Example:
  /// ```dart
  /// // Page 1
  /// final page1 = await tripRepository.getTripsOffset(
  ///   userId: 'user123',
  ///   page: 1,
  ///   pageSize: 20,
  /// );
  ///
  /// // Jump to page 5
  /// final page5 = await tripRepository.getTripsOffset(
  ///   userId: 'user123',
  ///   page: 5,
  ///   pageSize: 20,
  /// );
  /// ```
  Future<PaginatedData<Trip>> getTripsOffset({
    required String userId,
    int page = 1,
    int pageSize = 20,
    String sortBy = 'createdAt',
    SortOrder sortOrder = SortOrder.descending,
    Map<String, dynamic>? filters,
  });

  /// Get lightweight trip metadata for list rendering (optimized for 500+ items)
  ///
  /// This method returns only essential fields needed for list items,
  /// reducing memory usage and improving rendering performance.
  ///
  /// Returns partial trip data: id, title, destination, startDate, endDate, coverImageUrl
  ///
  /// Use this when rendering trip lists and load full details on-demand
  /// when the user taps on a trip.
  ///
  /// Example:
  /// ```dart
  /// final tripsMetadata = await tripRepository.getTripsMetadata(
  ///   userId: 'user123',
  ///   cursor: null,
  ///   pageSize: 50,
  /// );
  ///
  /// // Later, load full trip details
  /// final fullTrip = await tripRepository.getTripById(tripId: tripsMetadata.items.first.id);
  /// ```
  Future<PaginatedData<TripMetadata>> getTripsMetadata({
    required String userId,
    String? cursor,
    int pageSize = 50,
  });

  /// Get a single trip by ID
  ///
  /// Returns full trip details including all fields.
  /// Returns null if the trip is not found.
  Future<Trip?> getTripById({required String tripId});

  /// Get multiple trips by IDs (batch query)
  ///
  /// More efficient than calling [getTripById] multiple times.
  /// Returns trips in the same order as the provided IDs.
  /// Missing trips will not be included in the result.
  ///
  /// Example:
  /// ```dart
  /// final trips = await tripRepository.getTripsByIds(
  ///   tripIds: ['trip1', 'trip2', 'trip3'],
  /// );
  /// ```
  Future<List<Trip>> getTripsByIds({required List<String> tripIds});

  /// Create a new trip
  ///
  /// Returns the created trip with generated ID and timestamps.
  Future<Trip> createTrip({required Trip trip});

  /// Update an existing trip
  ///
  /// Returns the updated trip.
  /// Throws [NotFoundException] if the trip doesn't exist.
  Future<Trip> updateTrip({required String tripId, required Trip updates});

  /// Delete a trip
  ///
  /// Returns true if the trip was deleted, false if it didn't exist.
  Future<bool> deleteTrip({required String tripId});

  /// Search trips by query string
  ///
  /// Searches across title, description, and destination fields.
  /// Supports both cursor and offset pagination.
  ///
  /// Parameters:
  /// - [userId]: User ID to filter trips (required)
  /// - [query]: Search query string
  /// - [cursor]: Pagination cursor (for cursor-based)
  /// - [page]: Page number (for offset-based)
  /// - [pageSize]: Number of results per page
  ///
  /// Example:
  /// ```dart
  /// final results = await tripRepository.searchTrips(
  ///   userId: 'user123',
  ///   query: 'Paris',
  ///   cursor: null,
  ///   pageSize: 20,
  /// );
  /// ```
  Future<PaginatedData<Trip>> searchTrips({
    required String userId,
    required String query,
    String? cursor,
    int? page,
    int pageSize = 20,
  });

  /// Count total trips for a user
  ///
  /// Returns the total number of trips matching optional filters.
  /// Useful for displaying counts and progress indicators.
  ///
  /// Example:
  /// ```dart
  /// final totalTrips = await tripRepository.countTrips(
  ///   userId: 'user123',
  ///   filters: {'status': 'active'},
  /// );
  /// ```
  Future<int> countTrips({
    required String userId,
    Map<String, dynamic>? filters,
  });

  /// Get trips within a date range
  ///
  /// Useful for filtering trips by upcoming dates, past trips, etc.
  ///
  /// Example:
  /// ```dart
  /// final upcomingTrips = await tripRepository.getTripsInDateRange(
  ///   userId: 'user123',
  ///   startDate: DateTime.now(),
  ///   endDate: DateTime.now().add(const Duration(days: 30)),
  ///   cursor: null,
  ///   pageSize: 20,
  /// );
  /// ```
  Future<PaginatedData<Trip>> getTripsInDateRange({
    required String userId,
    required DateTime startDate,
    required DateTime endDate,
    String? cursor,
    int pageSize = 20,
  });
}

/// Lightweight trip metadata for efficient list rendering
///
/// Contains only essential fields needed for displaying trip items
/// in lists, reducing memory usage for 500+ trips.
class TripMetadata {
  final String id;
  final String title;
  final String destination;
  final DateTime startDate;
  final DateTime endDate;
  final String? coverImageUrl;

  const TripMetadata({
    required this.id,
    required this.title,
    required this.destination,
    required this.startDate,
    required this.endDate,
    this.coverImageUrl,
  });

  /// Creates TripMetadata from full Trip object
  factory TripMetadata.fromTrip(Trip trip) {
    return TripMetadata(
      id: trip.id,
      title: trip.title,
      destination: trip.destination,
      startDate: trip.startDate,
      endDate: trip.endDate,
      coverImageUrl: trip.coverImageUrl,
    );
  }

  @override
  String toString() {
    return 'TripMetadata('
        'id: $id, '
        'title: $title, '
        'destination: $destination)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is TripMetadata &&
        other.id == id &&
        other.title == title &&
        other.destination == destination &&
        other.startDate == startDate &&
        other.endDate == endDate &&
        other.coverImageUrl == coverImageUrl;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        title.hashCode ^
        destination.hashCode ^
        startDate.hashCode ^
        endDate.hashCode ^
        coverImageUrl.hashCode;
  }
}
