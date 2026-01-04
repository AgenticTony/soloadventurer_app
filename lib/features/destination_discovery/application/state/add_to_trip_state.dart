import '../../domain/models/destination.dart';

/// State class for adding a destination to a trip
class AddToTripState {
  /// The destination being added
  final Destination? destination;

  /// The ID of the trip the destination is being added to
  final String? tripId;

  /// The name of the trip (for display purposes)
  final String? tripName;

  /// Whether the operation is currently loading
  final bool isLoading;

  /// Whether the operation completed successfully
  final bool isSuccess;

  /// Error message if the operation failed
  final String? errorMessage;

  /// Creates an initial add to trip state
  const AddToTripState.initial()
      : destination = null,
        tripId = null,
        tripName = null,
        isLoading = false,
        isSuccess = false,
        errorMessage = null;

  /// Creates an add to trip state with the given fields
  const AddToTripState({
    this.destination,
    this.tripId,
    this.tripName,
    required this.isLoading,
    required this.isSuccess,
    this.errorMessage,
  });

  /// Creates a copy of this state with the given fields replaced
  AddToTripState copyWith({
    Destination? destination,
    String? tripId,
    String? tripName,
    bool? isLoading,
    bool? isSuccess,
    String? errorMessage,
  }) {
    return AddToTripState(
      destination: destination ?? this.destination,
      tripId: tripId ?? this.tripId,
      tripName: tripName ?? this.tripName,
      isLoading: isLoading ?? this.isLoading,
      isSuccess: isSuccess ?? this.isSuccess,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  /// Creates a loading state
  AddToTripState asLoading() {
    return copyWith(
      isLoading: true,
      isSuccess: false,
      errorMessage: null,
    );
  }

  /// Creates a success state
  AddToTripState asSuccess(String tripId, String tripName) {
    return copyWith(
      isLoading: false,
      isSuccess: true,
      tripId: tripId,
      tripName: tripName,
      errorMessage: null,
    );
  }

  /// Creates an error state
  AddToTripState asError(String error) {
    return copyWith(
      isLoading: false,
      isSuccess: false,
      errorMessage: error,
    );
  }

  /// Check if the state is loading
  bool get isloading => isLoading;

  /// Check if the operation was successful
  bool get isSuccessful => isSuccess;

  /// Check if there's an error
  bool get hasError => errorMessage != null;

  /// Check if the operation is complete (success or error)
  bool get isComplete => isSuccess || errorMessage != null;
}
