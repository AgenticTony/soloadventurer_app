import '../models/destination.dart';
import '../models/destination_filter.dart';
import '../models/curated_list.dart';
import '../models/personalized_recommendation.dart';
import '../models/saved_destination.dart';

/// Repository interface for destination data operations
///
/// This abstract class defines the contract for accessing and manipulating
/// destination data, including search, retrieval, recommendations, curated lists,
/// and user-saved destinations.
///
/// Implementations of this interface are responsible for:
/// - Fetching destination data from data sources (API, cache, etc.)
/// - Handling errors and exceptions appropriately
/// - Mapping data source responses to domain models
/// - Providing a clean API for the application layer
abstract class DestinationRepository {
  /// Search for destinations based on the provided filter criteria
  ///
  /// The [filter] parameter supports various filtering options including:
  /// - Text search query (name/description)
  /// - Budget level, safety score, solo suitability score
  /// - Activity level, location (country/region)
  /// - Tags/categories, hidden gems only
  /// - Popularity score, daily cost
  /// - Sorting and pagination
  ///
  /// Returns a list of [Destination] objects matching the filter criteria.
  /// Throws an exception if the search fails or network issues occur.
  Future<List<Destination>> searchDestinations(DestinationFilter filter);

  /// Get a specific destination by its unique identifier
  ///
  /// The [id] parameter is the unique destination ID.
  ///
  /// Returns the [Destination] object with the given ID.
  /// Throws an exception if the destination is not found or retrieval fails.
  Future<Destination> getDestinationById(String id);

  /// Get personalized recommendations for a specific user
  ///
  /// The [userId] parameter specifies the user to generate recommendations for.
  /// Recommendations are generated based on:
  /// - User preferences and profile
  /// - Past trip history
  /// - Similar users' preferences
  /// - Trending destinations
  /// - Curated collections
  ///
  /// Returns a [PersonalizedRecommendation] object containing recommended
  /// destinations with match scores and reasons.
  /// Throws an exception if recommendation generation fails.
  Future<PersonalizedRecommendation> getPersonalizedRecommendations(
    String userId,
  );

  /// Get all available curated destination lists
  ///
  /// Returns a list of [CuratedList] objects representing various
  /// thematic collections (popular solo destinations, hidden gems, etc.).
  /// Throws an exception if retrieval fails.
  Future<List<CuratedList>> getCuratedLists();

  /// Get a specific curated list by its unique identifier
  ///
  /// The [id] parameter is the unique curated list ID.
  ///
  /// Returns the [CuratedList] object with the given ID, including
  /// all destinations in the collection.
  /// Throws an exception if the curated list is not found or retrieval fails.
  Future<CuratedList> getCuratedListById(String id);

  /// Save a destination to a user's wishlist or trip
  ///
  /// The [saved] parameter contains the destination to save, along with
  /// the user ID, save type (wishlist/trip), and optional notes.
  ///
  /// Returns the saved [SavedDestination] object with timestamps and
  /// system-generated ID.
  /// Throws an exception if the save operation fails.
  Future<SavedDestination> saveDestination(SavedDestination saved);

  /// Remove a destination from a user's saved destinations
  ///
  /// The [destinationId] parameter specifies the destination to unsave.
  /// The [userId] parameter specifies the user whose saved list to modify.
  /// The [saveType] parameter specifies whether to remove from wishlist
  /// or a specific trip.
  ///
  /// Throws an exception if the unsave operation fails or if the
  /// destination is not in the user's saved list.
  Future<void> unsaveDestination({
    required String destinationId,
    required String userId,
    SaveType? saveType,
  });

  /// Get all saved destinations for a specific user
  ///
  /// The [userId] parameter specifies the user to fetch saved destinations for.
  /// The optional [saveType] parameter filters by save type (wishlist or trip).
  /// When null, returns all saved destinations regardless of type.
  ///
  /// Returns a list of [SavedDestination] objects for the user.
  /// Throws an exception if retrieval fails.
  Future<List<SavedDestination>> getSavedDestinations(
    String userId, {
    SaveType? saveType,
  });
}
