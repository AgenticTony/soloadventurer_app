import 'package:dartz/dartz.dart';
import 'package:soloadventurer/core/error/failures.dart';
import 'package:soloadventurer/features/travel/domain/models/itinerary.dart';
import 'package:soloadventurer/features/travel/domain/models/itinerary_item.dart';

/// Repository interface for itinerary data operations
///
/// This abstract repository defines the contract for itinerary data access.
/// Implementations can provide offline-first, remote, or in-memory storage.
///
/// Key Operations:
/// - CRUD operations for itineraries and items
/// - Item reordering within an itinerary
/// - Filtering by user, date range, and completion status
///
/// Error Handling:
/// All methods return [Either<Failure, T>] for type-safe error handling.
abstract class ItineraryRepository {
  // ==============================================================================
  // ITINERARY CRUD OPERATIONS
  // ==============================================================================

  /// Gets an itinerary by ID
  ///
  /// The [id] parameter is the unique identifier for the itinerary.
  /// Returns [Right(Itinerary)] if found, [Left(Failure)] on error.
  Future<Either<Failure, Itinerary>> getItinerary(String id);

  /// Gets all itineraries, optionally filtered by user
  ///
  /// The [userId] parameter is optional - if provided, filters to that user's itineraries.
  /// Returns [Right(List<Itinerary>)] with the list of itineraries.
  Future<Either<Failure, List<Itinerary>>> getItineraries({String? userId});

  /// Gets all starter itineraries (generated during onboarding)
  ///
  /// Returns [Right(List<Itinerary>)] with the list of starter itineraries.
  Future<Either<Failure, List<Itinerary>>> getStarterItineraries();

  /// Creates a new itinerary
  ///
  /// The [itinerary] parameter is the itinerary to create.
  /// Returns [Right(Itinerary)] with the created itinerary (including server-generated ID).
  Future<Either<Failure, Itinerary>> createItinerary(Itinerary itinerary);

  /// Updates an existing itinerary
  ///
  /// The [id] parameter is the ID of the itinerary to update.
  /// The [itinerary] parameter contains the updated data.
  /// Returns [Right(Itinerary)] with the updated itinerary.
  Future<Either<Failure, Itinerary>> updateItinerary(String id, Itinerary itinerary);

  /// Deletes an itinerary
  ///
  /// The [id] parameter is the ID of the itinerary to delete.
  /// Returns [Right(void)] on success, [Left(Failure)] on error.
  Future<Either<Failure, void>> deleteItinerary(String id);

  // ==============================================================================
  // ITINERARY ITEM OPERATIONS
  // ==============================================================================

  /// Adds an item to an itinerary
  ///
  /// The [itineraryId] parameter is the parent itinerary ID.
  /// The [item] parameter is the item to add.
  /// Returns [Right(Itinerary)] with the updated itinerary.
  Future<Either<Failure, Itinerary>> addItem(String itineraryId, ItineraryItem item);

  /// Updates an item in an itinerary
  ///
  /// The [itineraryId] parameter is the parent itinerary ID.
  /// The [item] parameter contains the updated item data.
  /// Returns [Right(Itinerary)] with the updated itinerary.
  Future<Either<Failure, Itinerary>> updateItem(String itineraryId, ItineraryItem item);

  /// Removes an item from an itinerary
  ///
  /// The [itineraryId] parameter is the parent itinerary ID.
  /// The [itemId] parameter is the ID of the item to remove.
  /// Returns [Right(Itinerary)] with the updated itinerary.
  Future<Either<Failure, Itinerary>> removeItem(String itineraryId, String itemId);

  /// Reorders items within an itinerary
  ///
  /// The [itineraryId] parameter is the parent itinerary ID.
  /// The [itemIdsInNewOrder] parameter is the list of item IDs in the desired order.
  /// Returns [Right(Itinerary)] with the updated itinerary.
  Future<Either<Failure, Itinerary>> reorderItems(
    String itineraryId,
    List<String> itemIdsInNewOrder,
  );

  /// Toggles the completion status of an item
  ///
  /// The [itineraryId] parameter is the parent itinerary ID.
  /// The [itemId] parameter is the ID of the item to toggle.
  /// Returns [Right(Itinerary)] with the updated itinerary.
  Future<Either<Failure, Itinerary>> toggleItemCompletion(String itineraryId, String itemId);

  // ==============================================================================
  // QUERY OPERATIONS
  // ==============================================================================

  /// Gets items for a specific day in an itinerary
  ///
  /// The [itineraryId] parameter is the parent itinerary ID.
  /// The [dayNumber] parameter is the day number (-based).
  /// Returns [Right(List<ItineraryItem>)] with the list of items for that day.
  Future<Either<Failure, List<ItineraryItem>>> getItemsForDay(
    String itineraryId,
    int dayNumber,
  );

  /// Gets all uncompleted items for an itinerary
  ///
  /// The [itineraryId] parameter is the parent itinerary ID.
  /// Returns [Right(List<ItineraryItem>)] with the list of uncompleted items.
  Future<Either<Failure, List<ItineraryItem>>> getUncompletedItems(String itineraryId);

  /// Gets all completed items for an itinerary
  ///
  /// The [itineraryId] parameter is the parent itinerary ID.
  /// Returns [Right(List<ItineraryItem>)] with the list of completed items.
  Future<Either<Failure, List<ItineraryItem>>> getCompletedItems(String itineraryId);

  /// Gets itineraries by status
  ///
  /// The [status] parameter is the status to filter by (e.g., 'planning', 'ongoing').
  /// The [userId] parameter is optional - if provided, filters to that user's itineraries.
  /// Returns [Right(List<Itinerary>)] with the filtered list.
  Future<Either<Failure, List<Itinerary>>> getItinerariesByStatus(
    String status, {
    String? userId,
  });

  /// Gets itineraries within a date range
  ///
  /// The [startDate] and [endDate] parameters define the date range.
  /// The [userId] parameter is optional - if provided, filters to that user's itineraries.
  /// Returns [Right(List<Itinerary>)] with the filtered list.
  Future<Either<Failure, List<Itinerary>>> getItinerariesByDateRange(
    DateTime startDate,
    DateTime endDate, {
    String? userId,
  });
}
