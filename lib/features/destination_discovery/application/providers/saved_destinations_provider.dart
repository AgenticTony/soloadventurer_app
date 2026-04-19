import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/models/saved_destination.dart';
import '../../domain/models/destination.dart';
import '../state/saved_destinations_state.dart';
import 'destination_repository_provider.dart';

part 'saved_destinations_provider.g.dart';

/// Riverpod 3.0 Migration Notes:
/// - Converted from `StateNotifier<AsyncValue<T>>` to `AsyncNotifier<T>`
/// - Dependencies injected via ref.watch() in build() method
/// - Family provider with userId parameter in build()
/// - AutoDispose enabled via @Riverpod annotation
/// - build() returns `Future<T>` not `AsyncValue<T>`
/// - State is automatically `AsyncValue<SavedDestinationsState>` when consumed
/// - Constructor auto-load logic moved to build() method
///
/// Provider for saved destinations state management
///
/// This provider manages the state of user's saved destinations including:
/// - Wishlist and trip destinations
/// - Loading and error states
/// - Save/unsave operations
/// - Filtering by save type (wishlist or trip)
///
/// Riverpod 3.0: Uses @riverpod annotation with AsyncNotifier pattern.
/// Auto-dispose behavior for family provider.
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
@riverpod
class SavedDestinations extends _$SavedDestinations {
  /// Initialize the notifier and auto-load saved destinations
  ///
  /// Riverpod 3.0: build() returns `Future<SavedDestinationsState>`
  /// Family provider parameter (userId) is passed here
  /// AutoDispose behavior: provider will be disposed when no longer watched
  @override
  Future<SavedDestinationsState> build(String userId) async {
    // Get dependencies via ref.watch()
    final repository = ref.watch(destinationRepositoryProvider);

    // Auto-load saved destinations on build
    final savedDestinations = await repository.getSavedDestinations(userId);

    return SavedDestinationsState(
      savedDestinations: savedDestinations,
    );
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
    // Get userId from current state and repository
    final currentState = state.value;
    if (currentState == null || currentState.savedDestinations.isEmpty) {
      return;
    }

    final userId = currentState.savedDestinations.first.userId;
    final repository = ref.read(destinationRepositoryProvider);

    // Set loading state
    state = const AsyncValue.loading();

    // Load saved destinations
    state = await AsyncValue.guard(() async {
      final savedDestinations =
          await repository.getSavedDestinations(userId, saveType: saveType);

      return SavedDestinationsState(
        savedDestinations: savedDestinations,
      );
    });
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
    // Get repository
    final repository = ref.read(destinationRepositoryProvider);

    // Create a temporary ID for the new saved destination
    final tempId =
        '${userId}_${destination.id}_${DateTime.now().millisecondsSinceEpoch}';

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

    // Call repository to save
    final result = await repository.saveDestination(savedDestination);

    // Update state with the new saved destination
    if (state.hasValue) {
      final currentState = state.value!;
      final updatedList = [...currentState.savedDestinations, result];

      state = AsyncValue.data(currentState.copyWith(
        savedDestinations: updatedList,
      ));
    }

    return result;
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
    // Get repository
    final repository = ref.read(destinationRepositoryProvider);

    // Call repository to unsave
    await repository.unsaveDestination(
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
  }

  /// Update notes on a saved destination
  ///
  /// The [destinationId] parameter specifies the destination to update notes for.
  /// The [notes] parameter contains the new notes (can be empty string or null to clear).
  ///
  /// Throws an exception if the update fails.
  Future<void> updateNotes(String destinationId, String? notes) async {
    // Get repository
    final repository = ref.read(destinationRepositoryProvider);

    if (!state.hasValue) {
      return;
    }

    final currentState = state.value!;

    // Find the saved destination
    final savedDest = currentState.getSavedDestination(destinationId);
    if (savedDest == null) {
      throw Exception('Destination not found in saved list');
    }

    // Create updated saved destination with new notes
    final updated = savedDest.withNotes(notes);

    // Save the updated version
    await repository.saveDestination(updated);

    // Update state
    final updatedList = currentState.savedDestinations.map((item) {
      return item.destination.id == destinationId ? updated : item;
    }).toList();

    state = AsyncValue.data(currentState.copyWith(
      savedDestinations: updatedList,
    ));
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
