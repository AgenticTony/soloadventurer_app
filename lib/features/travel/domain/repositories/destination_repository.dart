/// Repository interface for Destination data management
///
/// Provides access to destination information including details,
/// images, and metadata. This repository supports both online
/// fetching from remote APIs and offline caching.
abstract class DestinationRepository {
  /// Gets destination details by place ID
  ///
  /// [placeId] The Google Places place ID
  ///
  /// Returns the destination with all available details
  ///
  /// Throws [ServerException] if the API is unavailable
  /// Throws [NetworkException] if there's a connectivity issue
  /// Throws [NotFoundException] if the destination is not found
  /// Throws [CacheException] if offline and destination not cached
  Future<Map<String, dynamic>> getDestinationByPlaceId(String placeId);

  /// Searches for destinations by query
  ///
  /// [query] Search query (e.g., "Paris", "Tokyo restaurants")
  /// [limit] Maximum number of results to return
  ///
  /// Returns a list of destinations matching the search query
  ///
  /// Throws [ServerException] if the API is unavailable
  /// Throws [NetworkException] if there's a connectivity issue
  Future<List<Map<String, dynamic>>> searchDestinations(
    String query, {
    int limit = 10,
  });

  /// Gets popular destinations for a given location
  ///
  /// [latitude] Latitude of the search center
  /// [longitude] Longitude of the search center
  /// [radius] Search radius in kilometers
  /// [limit] Maximum number of results
  ///
  /// Returns a list of popular destinations near the coordinates
  ///
  /// Throws [ServerException] if the API is unavailable
  /// Throws [NetworkException] if there's a connectivity issue
  Future<List<Map<String, dynamic>>> getNearbyDestinations({
    required double latitude,
    required double longitude,
    double radius = 50.0,
    int limit = 20,
  });

  /// Checks if destination data is available locally
  ///
  /// [placeId] The Google Places place ID
  ///
  /// Returns true if the destination is cached locally
  Future<bool> isDestinationCached(String placeId);

  /// Saves destination to local cache
  ///
  /// [destination] The destination data to cache
  ///
  /// Throws [CacheException] if unable to cache
  Future<void> cacheDestination(Map<String, dynamic> destination);

  /// Gets multiple destinations by place IDs
  ///
  /// [placeIds] List of Google Places place IDs
  ///
  /// Returns a list of destinations with all available details
  ///
  /// Throws [ServerException] if the API is unavailable
  /// Throws [NetworkException] if there's a connectivity issue
  Future<List<Map<String, dynamic>>> getDestinationsByPlaceIds(
    List<String> placeIds,
  );
}
