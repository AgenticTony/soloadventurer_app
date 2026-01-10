import '../../domain/models/trip.dart';
import '../../domain/repositories/trip_repository.dart';
import 'package:soloadventurer/core/models/paginated_data.dart';
import 'package:soloadventurer/core/repositories/paginated_repository_mixin.dart';

/// In-memory implementation of TripRepository for testing and development
///
/// This implementation stores trips in memory and demonstrates how to
/// implement cursor-based and offset-based pagination.
///
/// For production, replace with an implementation that uses a database
/// or remote API.
class InMemoryTripRepository
    with PaginatedRepositoryMixin
    implements TripRepository {
  final Map<String, Trip> _trips = {};
  int _idCounter = 1;

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

    // Parse cursor to get offset
    final offset = parseOffsetCursor(cursor) ?? 0;

    // Filter trips by user and additional filters
    var filteredTrips =
        _trips.values.where((trip) => trip.userId == userId).toList();

    // Apply additional filters
    if (filters != null) {
      if (filters.containsKey('status')) {
        filteredTrips = filteredTrips
            .where((trip) => trip.status == filters['status'] as String)
            .toList();
      }
      if (filters.containsKey('destination')) {
        filteredTrips = filteredTrips
            .where((trip) => trip.destination
                .toLowerCase()
                .contains((filters['destination'] as String).toLowerCase()))
            .toList();
      }
    }

    // Sort trips
    filteredTrips = _sortTrips(filteredTrips, sortBy, sortOrder);

    // Apply pagination (cursor-based using offset)
    final startIndex = offset;
    final endIndex = startIndex + validatedPageSize;
    final paginatedTrips = startIndex < filteredTrips.length
        ? filteredTrips.sublist(
            startIndex,
            endIndex > filteredTrips.length ? filteredTrips.length : endIndex,
          )
        : <Trip>[];

    // Determine if there's a next page
    final hasNextPage = endIndex < filteredTrips.length;

    // Generate next cursor
    final nextCursor =
        hasNextPage ? generateOffsetCursor(offset + validatedPageSize) : null;

    // Create page info
    final pageInfo = createCursorPageInfo(
      currentCursor: cursor,
      pageSize: validatedPageSize,
      itemsCount: paginatedTrips.length,
      hasNextPage: hasNextPage,
      nextCursor: nextCursor,
      previousCursor:
          offset > 0 ? generateOffsetCursor(offset - validatedPageSize) : null,
    );

    return PaginatedData<Trip>(
      items: paginatedTrips,
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

    // Filter trips by user and additional filters
    var filteredTrips =
        _trips.values.where((trip) => trip.userId == userId).toList();

    // Apply additional filters
    if (filters != null) {
      if (filters.containsKey('status')) {
        filteredTrips = filteredTrips
            .where((trip) => trip.status == filters['status'] as String)
            .toList();
      }
    }

    final totalItems = filteredTrips.length;

    // Sort trips
    filteredTrips = _sortTrips(filteredTrips, sortBy, sortOrder);

    // Apply pagination (offset-based)
    final startIndex = offset;
    final endIndex = startIndex + validatedPageSize;
    final paginatedTrips = startIndex < filteredTrips.length
        ? filteredTrips.sublist(
            startIndex,
            endIndex > filteredTrips.length ? filteredTrips.length : endIndex,
          )
        : <Trip>[];

    // Create page info
    final pageInfo = createOffsetPageInfo(
      currentPage: page,
      pageSize: validatedPageSize,
      totalItems: totalItems,
      itemsCount: paginatedTrips.length,
    );

    return PaginatedData<Trip>(
      items: paginatedTrips,
      pageInfo: pageInfo,
    );
  }

  @override
  Future<PaginatedData<TripMetadata>> getTripsMetadata({
    required String userId,
    String? cursor,
    int pageSize = 50,
  }) async {
    // Get full trips using cursor pagination
    final fullTrips = await getTripsCursor(
      userId: userId,
      cursor: cursor,
      pageSize: pageSize,
    );

    // Convert to metadata
    final metadataList =
        fullTrips.items.map((trip) => TripMetadata.fromTrip(trip)).toList();

    return PaginatedData<TripMetadata>(
      items: metadataList,
      pageInfo: fullTrips.pageInfo,
    );
  }

  @override
  Future<Trip?> getTripById({required String tripId}) async {
    return _trips[tripId];
  }

  @override
  Future<List<Trip>> getTripsByIds({required List<String> tripIds}) async {
    final trips = <Trip>[];
    for (final id in tripIds) {
      final trip = _trips[id];
      if (trip != null) {
        trips.add(trip);
      }
    }
    return trips;
  }

  @override
  Future<Trip> createTrip({required Trip trip}) async {
    // Create a new trip with generated ID
    final newTrip = trip.copyWith(
      id: 'trip_${_idCounter++}',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    _trips[newTrip.id] = newTrip;
    return newTrip;
  }

  @override
  Future<Trip> updateTrip({
    required String tripId,
    required Trip updates,
  }) async {
    final existingTrip = _trips[tripId];
    if (existingTrip == null) {
      throw Exception('Trip not found: $tripId');
    }

    final updatedTrip = updates.copyWith(
      id: tripId, // Ensure ID doesn't change
      userId: existingTrip.userId, // Ensure userId doesn't change
      createdAt: existingTrip.createdAt, // Ensure createdAt doesn't change
      updatedAt: DateTime.now(),
    );

    _trips[tripId] = updatedTrip;
    return updatedTrip;
  }

  @override
  Future<bool> deleteTrip({required String tripId}) async {
    return _trips.remove(tripId) != null;
  }

  @override
  Future<PaginatedData<Trip>> searchTrips({
    required String userId,
    required String query,
    String? cursor,
    int? page,
    int pageSize = 20,
  }) async {
    // Filter trips by search query
    final searchResults = _trips.values
        .where((trip) =>
            trip.userId == userId &&
            (trip.title.toLowerCase().contains(query.toLowerCase()) ||
                trip.description?.toLowerCase().contains(query.toLowerCase()) ==
                    true ||
                trip.destination.toLowerCase().contains(query.toLowerCase())))
        .toList();

    // Sort by createdAt descending
    final sortedResults =
        _sortTrips(searchResults, 'createdAt', SortOrder.descending);

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
          : <Trip>[];

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

      return PaginatedData<Trip>(
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
          : <Trip>[];

      final pageInfo = createOffsetPageInfo(
        currentPage: currentPage,
        pageSize: validatedPageSize,
        totalItems: sortedResults.length,
        itemsCount: paginatedResults.length,
      );

      return PaginatedData<Trip>(
        items: paginatedResults,
        pageInfo: pageInfo,
      );
    }
  }

  @override
  Future<int> countTrips({
    required String userId,
    Map<String, dynamic>? filters,
  }) async {
    var trips = _trips.values.where((trip) => trip.userId == userId);

    if (filters != null) {
      if (filters.containsKey('status')) {
        trips =
            trips.where((trip) => trip.status == filters['status'] as String);
      }
    }

    return trips.length;
  }

  @override
  Future<PaginatedData<Trip>> getTripsInDateRange({
    required String userId,
    required DateTime startDate,
    required DateTime endDate,
    String? cursor,
    int pageSize = 20,
  }) async {
    // Filter trips by date range
    final filteredTrips = _trips.values
        .where((trip) =>
            trip.userId == userId &&
            trip.startDate
                .isAfter(startDate.subtract(const Duration(days: 1))) &&
            trip.endDate.isBefore(endDate.add(const Duration(days: 1))))
        .toList();

    // Sort by startDate ascending
    final sortedTrips =
        _sortTrips(filteredTrips, 'startDate', SortOrder.ascending);

    // Apply pagination
    final offset = parseOffsetCursor(cursor) ?? 0;
    final validatedPageSize = validatePageSize(pageSize);
    final startIndex = offset;
    final endIndex = startIndex + validatedPageSize;
    final paginatedTrips = startIndex < sortedTrips.length
        ? sortedTrips.sublist(
            startIndex,
            endIndex > sortedTrips.length ? sortedTrips.length : endIndex,
          )
        : <Trip>[];

    final hasNextPage = endIndex < sortedTrips.length;
    final nextCursor =
        hasNextPage ? generateOffsetCursor(offset + validatedPageSize) : null;

    final pageInfo = createCursorPageInfo(
      currentCursor: cursor,
      pageSize: validatedPageSize,
      itemsCount: paginatedTrips.length,
      hasNextPage: hasNextPage,
      nextCursor: nextCursor,
    );

    return PaginatedData<Trip>(
      items: paginatedTrips,
      pageInfo: pageInfo,
    );
  }

  /// Sort trips by field and order
  List<Trip> _sortTrips(List<Trip> trips, String field, SortOrder order) {
    final sortedTrips = List<Trip>.from(trips);

    sortedTrips.sort((a, b) {
      int comparison;
      switch (field) {
        case 'title':
          comparison = a.title.toLowerCase().compareTo(b.title.toLowerCase());
          break;
        case 'destination':
          comparison = a.destination
              .toLowerCase()
              .compareTo(b.destination.toLowerCase());
          break;
        case 'startDate':
          comparison = a.startDate.compareTo(b.startDate);
          break;
        case 'endDate':
          comparison = a.endDate.compareTo(b.endDate);
          break;
        case 'createdAt':
        default:
          comparison = a.createdAt.compareTo(b.createdAt);
          break;
      }

      return order == SortOrder.ascending ? comparison : -comparison;
    });

    return sortedTrips;
  }

  /// Clears all trips (useful for testing)
  void clear() {
    _trips.clear();
    _idCounter = 1;
  }
}
