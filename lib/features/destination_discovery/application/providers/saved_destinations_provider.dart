import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/saved_destination.dart';
import '../../domain/models/destination.dart';
import '../../domain/repositories/destination_repository.dart';
import '../state/saved_destinations_state.dart';

/// Provider for saved destinations state management
///
/// This provider manages the state of user's saved destinations including:
/// - Wishlist and trip destinations
/// - Loading and error states
/// - Save/unsave operations
/// - Filtering by save type (wishlist or trip)
///
/// Usage:
/// ```dart
/// final savedState = ref.watch(savedDestinationsProvider(userId));
/// final savedNotifier = ref.read(savedDestinationsProvider(userId).notifier);
///
/// // Load saved destinations (automatically called on first watch)
/// // The userId is passed as a parameter to the provider
///
/// // Save a destination to wishlist
/// await savedNotifier.saveDestination(
///   userId: userId,
///   destination: destination,
///   saveType: SaveType.wishlist,
/// );
///
/// // Unsave a destination
/// await savedNotifier.unsaveDestination(
///   userId: userId,
///   destinationId: destinationId,
/// );
///
/// // Refresh saved destinations
/// await savedNotifier.refresh();
/// ```
///
/// The [userId] parameter is the user ID to manage saved destinations for.
final savedDestinationsProvider = StateNotifierProvider.autoDispose
    .family<SavedDestinationsNotifier, AsyncValue<SavedDestinationsState>,
        String>(
  (ref, userId) {
    final repository = ref.watch(destinationRepositoryProvider);
    return SavedDestinationsNotifier(repository, userId);
  },
);

/// Notifier for managing saved destinations state
///
/// This notifier handles all operations for saved destinations:
/// - Loading saved destinations for a user
/// - Saving destinations to wishlist or trips
/// - Unsaving destinations
/// - Updating notes on saved destinations
/// - Checking if destinations are saved
/// - Filtering by save type
class SavedDestinationsNotifier
    extends StateNotifier<AsyncValue<SavedDestinationsState>> {
  final DestinationRepository _repository;
  final String _userId;

  /// Creates a new [SavedDestinationsNotifier]
  ///
  /// The [repository] parameter is required for performing data operations.
  /// The [userId] parameter is the ID of the user to manage saved destinations for.
  SavedDestinationsNotifier(this._repository, this._userId)
      : super(const AsyncValue.data(SavedDestinationsState.initial())) {
    // Auto-load saved destinations on creation
    loadSavedDestinations();
  }

  /// Load saved destinations for the user
  ///
  /// The optional [saveType] parameter filters by save type (wishlist or trip).
  /// When null, loads all saved destinations regardless of type.
  ///
  /// Throws an exception if loading fails.
  ///
  /// Note: This is automatically called when the notifier is created.
  Future<void> loadSavedDestinations({SaveType? saveType}) async {
    state = const AsyncValue.loading();

    try {
      final savedDestinations =
          await _repository.getSavedDestinations(_userId, saveType: saveType);

      state = AsyncValue.data(SavedDestinationsState(
        savedDestinations: savedDestinations,
      ));
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      rethrow;
    }
  }

  /// Refresh the saved destinations
  ///
  /// This method reloads saved destinations from the repository.
  /// Useful for pull-to-refresh functionality or ensuring fresh data.
  ///
  /// The optional [saveType] parameter filters by save type (wishlist or trip).
  /// When null, loads all saved destinations regardless of type.
  ///
  /// Throws an exception if refreshing fails.
  Future<void> refresh({SaveType? saveType}) async {
    // Preserve current state while loading if available
    if (state.hasValue && state.value!.savedDestinations.isNotEmpty) {
      state = AsyncValue.data(state.value!);
    }

    try {
      final savedDestinations =
          await _repository.getSavedDestinations(_userId, saveType: saveType);

      state = AsyncValue.data(SavedDestinationsState(
        savedDestinations: savedDestinations,
      ));
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      rethrow;
    }
  }

  /// Save a destination to wishlist or trip
  ///
  /// The [userId] parameter is the ID of the user saving the destination.
  /// The [destination] parameter is the destination to save.
  /// The [saveType] parameter specifies whether to save to wishlist or trip.
  /// The optional [tripId] parameter is required when saveType is SaveType.trip.
  /// The optional [notes] parameter allows adding personal notes.
  ///
  /// Returns the saved [SavedDestination] object with system-generated ID and timestamps.
  /// Throws an exception if the save operation fails.
  Future<SavedDestination> saveDestination({
    required String userId,
    required Destination destination,
    required SaveType saveType,
    String? tripId,
    String? notes,
  }) async {
    // Create a temporary ID for the new saved destination
    // The actual ID will be generated by the backend
    final tempId = '${userId}_${destination.id}_${DateTime.now().millisecondsSinceEpoch}';

    final savedDestination = SavedDestination(
      id: tempId,
      userId: userId,
      destination: destination,
      saveType: saveType,
      tripId: tripId,
      notes: notes,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    try {
      // Call repository to save
      final result = await _repository.saveDestination(savedDestination);

      // Update state with the new saved destination
      if (state.hasValue) {
        final currentState = state.value!;
        final updatedList = [...currentState.savedDestinations, result];

        state = AsyncValue.data(currentState.copyWith(
          savedDestinations: updatedList,
        ));
      }

      return result;
    } catch (error, stackTrace) {
      // Don't change state on error, just rethrow
      state = AsyncValue.error(error, stackTrace);
      rethrow;
    }
  }

  /// Remove a destination from saved destinations
  ///
  /// The [userId] parameter specifies the user whose saved list to modify.
  /// The [destinationId] parameter specifies the destination to unsave.
  /// The optional [saveType] parameter specifies whether to remove from wishlist
  /// or a specific trip. When null, removes from all locations.
  ///
  /// Throws an exception if the unsave operation fails.
  Future<void> unsaveDestination({
    required String userId,
    required String destinationId,
    SaveType? saveType,
  }) async {
    try {
      // Call repository to unsave
      await _repository.unsaveDestination(
        destinationId: destinationId,
        userId: userId,
        saveType: saveType,
      );

      // Update state by removing the unsaved destination(s)
      if (state.hasValue) {
        final currentState = state.value!;

        // Filter out the removed destinations
        final updatedList = currentState.savedDestinations.where((item) {
          // Keep item if it doesn't match the destinationId
          if (item.destination.id != destinationId) {
            return true;
          }

          // If saveType is specified, remove only matching type
          if (saveType != null) {
            return item.saveType != saveType;
          }

          // If saveType is not specified, remove all matching destinations
          return false;
        }).toList();

        state = AsyncValue.data(currentState.copyWith(
          savedDestinations: updatedList,
        ));
      }
    } catch (error, stackTrace) {
      // Don't change state on error, just rethrow
      state = AsyncValue.error(error, stackTrace);
      rethrow;
    }
  }

  /// Update notes on a saved destination
  ///
  /// The [destinationId] parameter specifies the destination to update notes for.
  /// The [notes] parameter contains the new notes (can be empty string or null to clear).
  ///
  /// Throws an exception if the update fails.
  Future<void> updateNotes(String destinationId, String? notes) async {
    if (!state.hasValue) {
      return;
    }

    final currentState = state.value!;

    // Find the saved destination
    final savedDest = currentState.getSavedDestination(destinationId);
    if (savedDest == null) {
      throw Exception('Destination not found in saved list');
    }

    try {
      // Create updated saved destination with new notes
      final updated = savedDest.withNotes(notes);

      // Save the updated version
      await _repository.saveDestination(updated);

      // Update state
      final updatedList = currentState.savedDestinations.map((item) {
        return item.destination.id == destinationId ? updated : item;
      }).toList();

      state = AsyncValue.data(currentState.copyWith(
        savedDestinations: updatedList,
      ));
    } catch (error, stackTrace) {
      // Don't change state on error, just rethrow
      state = AsyncValue.error(error, stackTrace);
      rethrow;
    }
  }

  /// Clear the saved destinations state
  ///
  /// This method resets the state to initial, clearing all data.
  /// This is useful for cleanup or when the user logs out.
  void clear() {
    state = const AsyncValue.data(SavedDestinationsState.initial());
  }

  /// Check if a destination is saved (either wishlist or trip)
  ///
  /// The [destinationId] parameter is the ID of the destination to check.
  ///
  /// Returns true if the destination is in the saved list, false otherwise.
  /// Returns false if the state is not loaded or an error occurred.
  bool isDestinationSaved(String destinationId) {
    if (!state.hasValue) {
      return false;
    }

    return state.value!.isDestinationSaved(destinationId);
  }

  /// Check if a destination is in wishlist
  ///
  /// The [destinationId] parameter is the ID of the destination to check.
  ///
  /// Returns true if the destination is in the wishlist, false otherwise.
  /// Returns false if the state is not loaded or an error occurred.
  bool isDestinationInWishlist(String destinationId) {
    if (!state.hasValue) {
      return false;
    }

    return state.value!.isDestinationInWishlist(destinationId);
  }

  /// Check if a destination is saved to a trip
  ///
  /// The [destinationId] parameter is the ID of the destination to check.
  ///
  /// Returns true if the destination is saved to a trip, false otherwise.
  /// Returns false if the state is not loaded or an error occurred.
  bool isDestinationInTrip(String destinationId) {
    if (!state.hasValue) {
      return false;
    }

    return state.value!.isDestinationInTrip(destinationId);
  }

  /// Get a saved destination by destination ID
  ///
  /// The [destinationId] parameter is the ID of the destination.
  ///
  /// Returns the [SavedDestination] object if found, null otherwise.
  /// Returns null if the state is not loaded or an error occurred.
  SavedDestination? getSavedDestination(String destinationId) {
    if (!state.hasValue) {
      return null;
    }

    return state.value!.getSavedDestination(destinationId);
  }

  /// Get all wishlist items
  ///
  /// Returns a list of saved destinations that are in the wishlist.
  /// Returns an empty list if the state is not loaded or an error occurred.
  List<SavedDestination> get wishlistItems {
    if (!state.hasValue) {
      return const [];
    }

    return state.value!.wishlistItems;
  }

  /// Get all trip items
  ///
  /// Returns a list of saved destinations that are saved to trips.
  /// Returns an empty list if the state is not loaded or an error occurred.
  List<SavedDestination> get tripItems {
    if (!state.hasValue) {
      return const [];
    }

    return state.value!.tripItems;
  }

  /// Get the total count of saved destinations
  ///
  /// Returns the total count of all saved destinations (wishlist + trips).
  /// Returns 0 if the state is not loaded or an error occurred.
  int get totalCount {
    if (!state.hasValue) {
      return 0;
    }

    return state.value!.count;
  }

  /// Get the count of wishlist items
  ///
  /// Returns the count of destinations in the wishlist.
  /// Returns 0 if the state is not loaded or an error occurred.
  int get wishlistCount {
    if (!state.hasValue) {
      return 0;
    }

    return state.value!.wishlistCount;
  }

  /// Get the count of trip items
  ///
  /// Returns the count of destinations saved to trips.
  /// Returns 0 if the state is not loaded or an error occurred.
  int get tripCount {
    if (!state.hasValue) {
      return 0;
    }

    return state.value!.tripCount;
  }

  /// Get all saved destinations grouped by trip ID
  ///
  /// Returns a map where key is tripId and value is list of destinations for that trip.
  /// Wishlist items are not included in this map.
  /// Returns an empty map if the state is not loaded or an error occurred.
  Map<String, List<SavedDestination>> get groupedByTrip {
    if (!state.hasValue) {
      return {};
    }

    return state.value!.groupedByTrip;
  }

  /// Check if the saved destinations list is empty
  ///
  /// Returns true if there are no saved destinations, false otherwise.
  /// Returns true if the state is not loaded or an error occurred.
  bool get isEmpty {
    if (!state.hasValue) {
      return true;
    }

    return state.value!.isEmpty;
  }

  /// Check if there are any saved destinations
  ///
  /// Returns true if there are saved destinations, false otherwise.
  /// Returns false if the state is not loaded or an error occurred.
  bool get isNotEmpty {
    if (!state.hasValue) {
      return false;
    }

    return state.value!.isNotEmpty;
  }
}
