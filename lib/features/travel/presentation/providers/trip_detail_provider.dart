import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/trip.dart';
import '../../../destination_discovery/domain/models/destination.dart';
import '../../../destination_discovery/domain/repositories/destination_repository.dart';

part 'trip_detail_provider.g.dart';

/// Riverpod 3.0 Migration Notes:
/// - Converted from StateNotifier to @riverpod Notifier
/// - Dependencies injected via ref.watch() in build() method
/// - Family provider with tripId parameter in build()
/// - Initialization logic moved from constructor to build() method
///
/// Provider for the destination repository from the destination discovery feature
@riverpod
DestinationRepository tripDestinationRepository(
    TripDestinationRepositoryRef ref) {
  throw UnimplementedError(
      'tripDestinationRepositoryProvider must be overridden in main app');
}

/// Provider for managing trip detail state
///
/// This provider manages the state of a trip detail view, including
/// the trip data and the destinations from the discovery feature.
///
/// Riverpod 3.0: Uses @riverpod annotation with family provider pattern.
/// The tripId parameter is passed to the build() method.
///
/// Usage:
/// ```dart
/// final tripDetailState = ref.watch(tripDetailProvider(tripId));
/// final tripDetailNotifier = ref.read(tripDetailProvider(tripId).notifier);
///
/// // Load trip data
/// await tripDetailNotifier.loadTrip(trip);
///
/// // Refresh trip data
/// await tripDetailNotifier.refresh();
/// ```
@riverpod
class TripDetail extends _$TripDetail {
  /// Initialize the notifier with dependencies
  ///
  /// Riverpod 3.0: build() replaces constructor for initialization
  /// Family provider parameter (tripId) is passed here
  @override
  TripDetailState build(String tripId) {
    // Get dependencies via ref.watch()
    final destinationRepository = ref.watch(tripDestinationRepositoryProvider);

    // Return initial state
    return const TripDetailState.initial();
  }

  /// Load trip data with destinations
  ///
  /// The [trip] parameter is the trip to load.
  /// This method loads the trip data and fetches all associated destinations.
  ///
  /// Throws an exception if loading fails.
  ///
  /// Example:
  /// ```dart
  /// await notifier.loadTrip(trip);
  /// ```
  Future<void> loadTrip(Trip trip) async {
    // Get repository
    final destinationRepository = ref.read(tripDestinationRepositoryProvider);

    // Set loading state
    state = state.copyWith(trip: trip, isLoading: true);

    try {
      // Fetch destinations if trip has destination IDs
      List<Destination> destinations = [];
      if (trip.destinationIds.isNotEmpty) {
        destinations = await _fetchDestinations(
            trip.destinationIds, destinationRepository);
      }

      // Update state with loaded data
      state = state.copyWith(
        trip: trip,
        destinations: destinations,
        isLoading: false,
        errorMessage: null,
      );
    } catch (error) {
      // Update state to error
      state = state.copyWith(
        isLoading: false,
        errorMessage: error.toString().replaceAll('Exception: ', ''),
      );
    }
  }

  /// Refresh trip data
  ///
  /// Reloads the current trip's destinations.
  ///
  /// Throws an exception if refresh fails.
  ///
  /// Example:
  /// ```dart
  /// await notifier.refresh();
  /// ```
  Future<void> refresh() async {
    final currentTrip = state.trip;
    if (currentTrip == null) {
      return;
    }

    // Reload the trip
    await loadTrip(currentTrip);
  }

  /// Fetch destinations by IDs
  ///
  /// The [destinationIds] parameter is the list of destination IDs to fetch.
  /// Returns a list of [Destination] objects.
  ///
  /// Throws an exception if fetching fails.
  Future<List<Destination>> _fetchDestinations(
    List<String> destinationIds,
    DestinationRepository destinationRepository,
  ) async {
    try {
      final destinations = <Destination>[];

      // Fetch each destination by ID
      for (final destinationId in destinationIds) {
        try {
          final destination =
              await destinationRepository.getDestinationById(destinationId);
          destinations.add(destination);
        } catch (error) {
          // Continue with other destinations if one fails
          continue;
        }
      }

      return destinations;
    } catch (error) {
      throw Exception('Failed to fetch destinations: $error');
    }
  }

  /// Update notes for a destination
  ///
  /// The [destinationId] parameter is the ID of the destination.
  /// The [notes] parameter is the new notes content.
  ///
  /// Example:
  /// ```dart
  /// notifier.updateDestinationNotes('dest123', 'Must visit temples');
  /// ```
  void updateDestinationNotes(String destinationId, String notes) {
    final currentTrip = state.trip;
    if (currentTrip == null) {
      return;
    }

    final updatedNotes = Map<String, String>.from(currentTrip.destinationNotes);
    updatedNotes[destinationId] = notes;

    final updatedTrip = currentTrip.copyWith(
      destinationNotes: updatedNotes,
    );

    state = state.copyWith(trip: updatedTrip);
  }

  /// Clear the state
  ///
  /// This method resets the state to the initial state.
  ///
  /// Example:
  /// ```dart
  /// notifier.clear();
  /// ```
  void clear() {
    state = const TripDetailState.initial();
  }

  /// Get the current trip
  ///
  /// Returns the trip if loaded, null otherwise.
  Trip? get trip => state.trip;

  /// Get the current destinations
  ///
  /// Returns the list of destinations.
  List<Destination> get destinations => state.destinations;

  /// Check if data is currently loading
  ///
  /// Returns true if loading, false otherwise.
  bool get isLoading => state.isLoading;

  /// Check if there's an error
  ///
  /// Returns true if there's an error, false otherwise.
  bool get hasError => state.hasError;

  /// Get the error message
  ///
  /// Returns the error message if there's an error, null otherwise.
  String? get errorMessage => state.errorMessage;
}

/// State class for trip detail view
class TripDetailState {
  /// The trip being displayed
  final Trip? trip;

  /// The destinations in this trip
  final List<Destination> destinations;

  /// Whether data is currently loading
  final bool isLoading;

  /// Error message if loading failed
  final String? errorMessage;

  /// Creates an initial trip detail state
  const TripDetailState.initial()
      : trip = null,
        destinations = const [],
        isLoading = false,
        errorMessage = null;

  /// Creates a trip detail state with the given fields
  const TripDetailState({
    this.trip,
    this.destinations = const [],
    required this.isLoading,
    this.errorMessage,
  });

  /// Creates a copy of this state with the given fields replaced
  TripDetailState copyWith({
    Trip? trip,
    List<Destination>? destinations,
    bool? isLoading,
    String? errorMessage,
  }) {
    return TripDetailState(
      trip: trip ?? this.trip,
      destinations: destinations ?? this.destinations,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  /// Check if the state has a trip loaded
  bool get hasTrip => trip != null;

  /// Check if there are destinations in the trip
  bool get hasDestinations => destinations.isNotEmpty;

  /// Check if the state is loading
  bool get isLoadingData => isLoading;

  /// Check if there's an error
  bool get hasError => errorMessage != null;
}
