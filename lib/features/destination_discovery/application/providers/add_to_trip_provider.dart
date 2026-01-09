import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/destination.dart';
import '../../../travel/domain/models/trip_planning_operation.dart';
import '../../../travel/domain/repositories/travel_operation_repository.dart';
import '../state/add_to_trip_state.dart';

/// Provider for the travel operation repository from the travel feature
final travelOperationRepositoryProvider =
    Provider<TravelOperationRepository>((ref) {
  throw UnimplementedError(
      'travelOperationRepositoryProvider must be overridden in main app');
});

/// Provider for managing add to trip operations
///
/// This provider manages the state of adding a destination from the
/// destination discovery feature to a trip in the travel feature.
///
/// Usage:
/// ```dart
/// final addToTripState = ref.watch(addToTripProvider);
/// final addToTripNotifier = ref.read(addToTripProvider.notifier);
///
/// // Add destination to existing trip
/// await addToTripNotifier.addToExistingTrip(
///   destination: destination,
///   tripId: tripId,
///   tripName: 'Japan Adventure',
///   startDate: startDate,
///   endDate: endDate,
///   notes: notes,
/// );
///
/// // Add destination to new trip
/// await addToTripNotifier.addToNewTrip(
///   destination: destination,
///   tripTitle: 'Summer Adventure',
///   tripDescription: 'Exploring new places',
///   startDate: startDate,
///   endDate: endDate,
///   notes: notes,
/// );
///
/// // Check if operation is loading
/// if (addToTripState.isLoading) {
///   // Show loading indicator
/// }
///
/// // Check if operation was successful
/// if (addToTripState.isSuccess) {
///   final tripId = addToTripState.tripId;
///   final tripName = addToTripState.tripName;
///   // Show success message
/// }
///
/// // Check for errors
/// if (addToTripState.hasError) {
///   final error = addToTripState.errorMessage;
///   // Show error message
/// }
/// ```
final addToTripProvider =
    StateNotifierProvider<AddToTripNotifier, AddToTripState>((ref) {
  final repository = ref.watch(travelOperationRepositoryProvider);
  return AddToTripNotifier(repository);
});

/// Notifier for managing add to trip operations
///
/// This notifier handles adding destinations from the discovery feature
/// to trips in the travel feature. It integrates with the existing
/// travel operation system using TripPlanningOperation.
class AddToTripNotifier extends StateNotifier<AddToTripState> {
  final TravelOperationRepository _repository;

  /// Creates a new [AddToTripNotifier]
  ///
  /// The [repository] parameter is required for performing trip planning operations.
  AddToTripNotifier(this._repository)
      : super(const AddToTripState.initial());

  /// Add a destination to an existing trip
  ///
  /// The [destination] parameter is the destination to add.
  /// The [tripId] parameter is the ID of the existing trip.
  /// The [tripName] parameter is the name of the trip for display purposes.
  /// The optional [startDate] parameter specifies when the destination visit starts.
  /// The optional [endDate] parameter specifies when the destination visit ends.
  /// The optional [notes] parameter allows adding personal notes about the destination.
  ///
  /// Throws an exception if the add operation fails.
  ///
  /// Example:
  /// ```dart
  /// await notifier.addToExistingTrip(
  ///   destination: destination,
  ///   tripId: 'trip123',
  ///   tripName: 'Japan Adventure',
  ///   startDate: DateTime(2024, 3, 15),
  ///   endDate: DateTime(2024, 3, 20),
  ///   notes: 'Must visit temples',
  /// );
  /// ```
  Future<void> addToExistingTrip({
    required Destination destination,
    required String tripId,
    required String tripName,
    DateTime? startDate,
    DateTime? endDate,
    String? notes,
  }) async {
    // Set loading state
    state = state.copyWith(
      destination: destination,
      tripId: tripId,
      tripName: tripName,
    ).asLoading();

    try {
      // Create a trip planning operation to add destination to existing trip
      final operation = TripPlanningOperation.update(
        tripId: tripId,
        // Include destination ID in changes
        destinations: [destination.id],
        startDate: startDate,
        endDate: endDate,
      );

      // Save the operation to the repository
      await _repository.saveOperation(operation);

      // Update state to success
      state = state.asSuccess(tripId, tripName);
    } catch (error, stackTrace) {
      // Update state to error
      state = state.asError(
        error.toString().replaceAll('Exception: ', ''),
      );
      // Re-throw for caller to handle if needed
      Error.throwWithStackTrace(error.toString(), stackTrace);
    }
  }

  /// Add a destination to a new trip
  ///
  /// The [destination] parameter is the destination to add.
  /// The [tripTitle] parameter is the title of the new trip.
  /// The optional [tripDescription] parameter is a description of the trip.
  /// The optional [startDate] parameter specifies when the trip starts.
  /// The optional [endDate] parameter specifies when the trip ends.
  /// The optional [notes] parameter allows adding personal notes about the destination.
  ///
  /// Returns the ID of the newly created trip.
  /// Throws an exception if the creation or add operation fails.
  ///
  /// Example:
  /// ```dart
  /// final tripId = await notifier.addToNewTrip(
  ///   destination: destination,
  ///   tripTitle: 'Summer Adventure 2024',
  ///   tripDescription: 'Exploring Europe',
  ///   startDate: DateTime(2024, 6, 1),
  ///   endDate: DateTime(2024, 6, 21),
  ///   notes: 'First stop: Paris',
  /// );
  /// ```
  Future<String> addToNewTrip({
    required Destination destination,
    required String tripTitle,
    String? tripDescription,
    DateTime? startDate,
    DateTime? endDate,
    String? notes,
  }) async {
    // Set loading state
    state = state.copyWith(
      destination: destination,
      tripName: tripTitle,
    ).asLoading();

    try {
      // Create a trip planning operation to create a new trip
      final operation = TripPlanningOperation.create(
        tripName: tripTitle,
        // Include destination IDs in changes
        destinations: [destination.id],
        startDate: startDate,
        endDate: endDate,
      );

      // Save the operation to the repository
      await _repository.saveOperation(operation);

      // Get the new trip ID from the operation
      final newTripId = operation.tripId;

      // Update state to success
      state = state.asSuccess(newTripId, tripTitle);

      return newTripId;
    } catch (error, stackTrace) {
      // Update state to error
      state = state.asError(
        error.toString().replaceAll('Exception: ', ''),
      );
      // Re-throw for caller to handle if needed
      Error.throwWithStackTrace(error.toString(), stackTrace);
      // Return empty string to satisfy return type (will never reach here)
      return '';
    }
  }

  /// Reset the state to initial
  ///
  /// This method resets the state to the initial state, clearing all data.
  /// This is useful for clearing the state after a successful operation
  /// or when the flow is cancelled.
  ///
  /// Example:
  /// ```dart
  /// notifier.reset();
  /// ```
  void reset() {
    state = const AddToTripState.initial();
  }

  /// Clear the error message
  ///
  /// This method clears the error message from the state while preserving
  /// other state data. This is useful when the user wants to retry an operation.
  ///
  /// Example:
  /// ```dart
  /// notifier.clearError();
  /// ```
  void clearError() {
    if (state.hasError) {
      state = state.copyWith(errorMessage: null);
    }
  }

  /// Get the current destination being added
  ///
  /// Returns the destination if set, null otherwise.
  Destination? get destination => state.destination;

  /// Get the current trip ID
  ///
  /// Returns the trip ID if set, null otherwise.
  String? get tripId => state.tripId;

  /// Get the current trip name
  ///
  /// Returns the trip name if set, null otherwise.
  String? get tripName => state.tripName;

  /// Check if the operation is currently loading
  ///
  /// Returns true if loading, false otherwise.
  bool get isLoading => state.isLoading;

  /// Check if the last operation was successful
  ///
  /// Returns true if successful, false otherwise.
  bool get isSuccess => state.isSuccess;

  /// Check if there's an error
  ///
  /// Returns true if there's an error, false otherwise.
  bool get hasError => state.hasError;

  /// Get the error message
  ///
  /// Returns the error message if there's an error, null otherwise.
  String? get errorMessage => state.errorMessage;

  /// Check if the operation is complete (success or error)
  ///
  /// Returns true if complete, false otherwise.
  bool get isComplete => state.isComplete;
}
