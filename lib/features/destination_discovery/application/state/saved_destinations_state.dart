import '../../domain/models/saved_destination.dart';

/// State class for saved destinations (wishlist and trips)
class SavedDestinationsState {
  /// List of all saved destinations
  final List<SavedDestination> savedDestinations;

  /// Creates an initial saved destinations state
  const SavedDestinationsState.initial() : savedDestinations = const [];

  /// Creates a saved destinations state with the given list
  const SavedDestinationsState({
    required this.savedDestinations,
  });

  /// Creates a copy of this state with the given fields replaced
  SavedDestinationsState copyWith({
    List<SavedDestination>? savedDestinations,
  }) {
    return SavedDestinationsState(
      savedDestinations: savedDestinations ?? this.savedDestinations,
    );
  }

  /// Returns the number of saved destinations
  int get count => savedDestinations.length;

  /// Returns true if no destinations are saved
  bool get isEmpty => savedDestinations.isEmpty;

  /// Returns true if there are saved destinations
  bool get isNotEmpty => savedDestinations.isNotEmpty;

  /// Get only wishlist items
  List<SavedDestination> get wishlistItems =>
      savedDestinations.where((item) => item.isWishlist).toList();

  /// Get only trip items
  List<SavedDestination> get tripItems =>
      savedDestinations.where((item) => item.isTrip).toList();

  /// Get wishlist count
  int get wishlistCount => wishlistItems.length;

  /// Get trip count
  int get tripCount => tripItems.length;

  /// Check if a specific destination is saved (either wishlist or trip)
  bool isDestinationSaved(String destinationId) {
    return savedDestinations.any(
      (item) => item.destination.id == destinationId,
    );
  }

  /// Check if a specific destination is in wishlist
  bool isDestinationInWishlist(String destinationId) {
    return savedDestinations.any(
      (item) => item.destination.id == destinationId && item.isWishlist,
    );
  }

  /// Check if a specific destination is saved to a trip
  bool isDestinationInTrip(String destinationId) {
    return savedDestinations.any(
      (item) => item.destination.id == destinationId && item.isTrip,
    );
  }

  /// Get saved destination by destination ID
  SavedDestination? getSavedDestination(String destinationId) {
    try {
      return savedDestinations.firstWhere(
        (item) => item.destination.id == destinationId,
      );
    } catch (e) {
      return null;
    }
  }

  /// Get saved destination by destination ID and save type
  SavedDestination? getSavedDestinationByType(
    String destinationId,
    SaveType saveType,
  ) {
    try {
      return savedDestinations.firstWhere(
        (item) =>
            item.destination.id == destinationId && item.saveType == saveType,
      );
    } catch (e) {
      return null;
    }
  }

  /// Get all saved destinations grouped by trip ID
  /// Returns a map where key is tripId and value is list of destinations for that trip
  /// Wishlist items are not included in this map
  Map<String, List<SavedDestination>> get groupedByTrip {
    final Map<String, List<SavedDestination>> grouped = {};

    for (final item in tripItems) {
      final tripId = item.tripId ?? 'unknown';
      grouped.putIfAbsent(tripId, () => []);
      grouped[tripId]!.add(item);
    }

    return grouped;
  }
}
