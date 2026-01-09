import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:soloadventurer/features/journal/data/datasources/trip_remote_data_source_impl.dart';
import 'package:soloadventurer/features/journal/data/repositories/trip_repository_impl.dart';
import 'package:soloadventurer/features/journal/domain/entities/trip.dart';
import 'package:soloadventurer/features/journal/domain/repositories/trip_repository.dart';

// ============================================================================
// Dependency Injection Providers
// ============================================================================

/// Provides the Supabase client instance
final supabaseClientProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});

/// Provides the TripRemoteDataSource implementation
final tripRemoteDataSourceProvider = Provider<TripRemoteDataSourceImpl>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return TripRemoteDataSourceImpl(client: client);
});

/// Provides the TripRepository implementation
final tripRepositoryProvider = Provider<TripRepository>((ref) {
  final remoteDataSource = ref.watch(tripRemoteDataSourceProvider);
  return TripRepositoryImpl(remoteDataSource: remoteDataSource);
});

// ============================================================================
// Trip List State
// ============================================================================

/// State for trip list operations
class TripListState {
  final List<Trip> trips;
  final bool isLoading;
  final String? error;

  const TripListState({
    this.trips = const [],
    this.isLoading = false,
    this.error,
  });

  TripListState copyWith({
    List<Trip>? trips,
    bool? isLoading,
    String? error,
  }) {
    return TripListState(
      trips: trips ?? this.trips,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

/// Notifier for managing trip list state
class TripListNotifier extends StateNotifier<TripListState> {
  final TripRepository _repository;

  TripListNotifier(this._repository) : super(const TripListState()) {
    loadTrips();
  }

  /// Loads all trips for the current user
  Future<void> loadTrips() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final trips = await _repository.getTrips();
      state = state.copyWith(trips: trips, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Loads ongoing trips only
  Future<void> loadOngoingTrips() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final trips = await _repository.getOngoingTrips();
      state = state.copyWith(trips: trips, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Clears any error state
  void clearError() {
    state = state.copyWith(error: null);
  }
}

/// Provider for trip list state
final tripListProvider = StateNotifierProvider<TripListNotifier, TripListState>((ref) {
  final repository = ref.watch(tripRepositoryProvider);
  return TripListNotifier(repository);
});

// ============================================================================
// Trip Creation/Edit State
// ============================================================================

/// State for trip creation/editing
class TripFormState {
  final String name;
  final String? description;
  final DateTime startDate;
  final DateTime? endDate;
  final String? destination;
  final bool isPublic;
  final String? coverImageUrl;
  final bool isLoading;
  final String? error;

  const TripFormState({
    this.name = '',
    this.description,
    required this.startDate,
    this.endDate,
    this.destination,
    this.isPublic = false,
    this.coverImageUrl,
    this.isLoading = false,
    this.error,
  });

  TripFormState copyWith({
    String? name,
    String? description,
    DateTime? startDate,
    DateTime? endDate,
    String? destination,
    bool? isPublic,
    String? coverImageUrl,
    bool? isLoading,
    String? error,
  }) {
    return TripFormState(
      name: name ?? this.name,
      description: description ?? this.description,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      destination: destination ?? this.destination,
      isPublic: isPublic ?? this.isPublic,
      coverImageUrl: coverImageUrl ?? this.coverImageUrl,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  /// Validates the form
  String? validate() {
    if (name.trim().isEmpty) {
      return 'Trip name is required';
    }
    if (name.trim().length < 3) {
      return 'Trip name must be at least 3 characters';
    }
    if (name.trim().length > 200) {
      return 'Trip name must be less than 200 characters';
    }
    if (description != null && description!.trim().length > 2000) {
      return 'Description must be less than 2000 characters';
    }
    if (destination != null && destination!.trim().length > 200) {
      return 'Destination must be less than 200 characters';
    }
    if (endDate != null && endDate!.isBefore(startDate)) {
      return 'End date cannot be before start date';
    }
    return null;
  }

  /// Whether the form is valid
  bool get isValid => validate() == null;
}

/// Notifier for managing trip form state
class TripFormNotifier extends StateNotifier<TripFormState> {
  final TripRepository _repository;
  String? _editingTripId;

  TripFormNotifier(this._repository)
      : super(TripFormState(
          startDate: DateTime.now(),
        ));

  /// Updates the trip name
  void updateName(String name) {
    state = state.copyWith(name: name, error: null);
  }

  /// Updates the trip description
  void updateDescription(String? description) {
    state = state.copyWith(description: description, error: null);
  }

  /// Updates the start date
  void updateStartDate(DateTime startDate) {
    state = state.copyWith(startDate: startDate, error: null);
  }

  /// Updates the end date
  void updateEndDate(DateTime? endDate) {
    state = state.copyWith(endDate: endDate, error: null);
  }

  /// Updates the destination
  void updateDestination(String? destination) {
    state = state.copyWith(destination: destination, error: null);
  }

  /// Updates the public flag
  void updatePublic(bool isPublic) {
    state = state.copyWith(isPublic: isPublic, error: null);
  }

  /// Updates the cover image URL
  void updateCoverImage(String? coverImageUrl) {
    state = state.copyWith(coverImageUrl: coverImageUrl, error: null);
  }

  /// Loads an existing trip for editing
  Future<void> loadTrip(String tripId) async {
    state = state.copyWith(isLoading: true, error: null);
    _editingTripId = tripId;

    try {
      final trip = await _repository.getTrip(tripId);
      state = state.copyWith(
        name: trip.name,
        description: trip.description,
        startDate: trip.startDate,
        endDate: trip.endDate,
        destination: trip.destination,
        isPublic: trip.isPublic,
        coverImageUrl: trip.coverImageUrl,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Saves the trip (creates or updates)
  Future<Trip?> saveTrip() async {
    final validationError = state.validate();
    if (validationError != null) {
      state = state.copyWith(error: validationError);
      return null;
    }

    state = state.copyWith(isLoading: true, error: null);

    try {
      final now = DateTime.now();
      final userId = Supabase.instance.client.auth.currentUser?.id;

      if (userId == null) {
        throw Exception('User not authenticated');
      }

      Trip trip;
      if (_editingTripId != null) {
        // Update existing trip
        final existingTrip = await _repository.getTrip(_editingTripId!);
        trip = existingTrip.copyWith(
          name: state.name.trim(),
          description: state.description?.trim(),
          startDate: state.startDate,
          endDate: state.endDate,
          destination: state.destination?.trim(),
          isPublic: state.isPublic,
          coverImageUrl: state.coverImageUrl,
          updatedAt: now,
        );
        trip = await _repository.updateTrip(trip);
      } else {
        // Create new trip
        trip = Trip(
          id: '', // Will be generated by server
          userId: userId,
          name: state.name.trim(),
          description: state.description?.trim(),
          startDate: state.startDate,
          endDate: state.endDate,
          destination: state.destination?.trim(),
          isPublic: state.isPublic,
          coverImageUrl: state.coverImageUrl,
          createdAt: now,
          updatedAt: now,
        );
        trip = await _repository.createTrip(trip);
      }

      state = state.copyWith(isLoading: false);
      return trip;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return null;
    }
  }

  /// Resets the form to initial state
  void reset() {
    _editingTripId = null;
    state = TripFormState(startDate: DateTime.now());
  }

  /// Clears any error state
  void clearError() {
    state = state.copyWith(error: null);
  }
}

/// Provider for trip form state
final tripFormProvider = StateNotifierProvider<TripFormNotifier, TripFormState>((ref) {
  final repository = ref.watch(tripRepositoryProvider);
  return TripFormNotifier(repository);
});

// ============================================================================
// Trip Detail State
// ============================================================================

/// State for individual trip viewing
class TripDetailState {
  final Trip? trip;
  final int entryCount;
  final bool isLoading;
  final String? error;

  const TripDetailState({
    this.trip,
    this.entryCount = 0,
    this.isLoading = false,
    this.error,
  });

  TripDetailState copyWith({
    Trip? trip,
    int? entryCount,
    bool? isLoading,
    String? error,
  }) {
    return TripDetailState(
      trip: trip ?? this.trip,
      entryCount: entryCount ?? this.entryCount,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

/// Notifier for managing trip detail state
class TripDetailNotifier extends StateNotifier<TripDetailState> {
  final TripRepository _repository;

  TripDetailNotifier(this._repository) : super(const TripDetailState());

  /// Loads a trip by ID
  Future<void> loadTrip(String tripId) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final trip = await _repository.getTrip(tripId);
      final entryCount = await _repository.getEntryCountForTrip(tripId);

      state = state.copyWith(
        trip: trip,
        entryCount: entryCount,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Deletes the current trip
  Future<bool> deleteTrip() async {
    if (state.trip == null) return false;

    state = state.copyWith(isLoading: true, error: null);

    try {
      await _repository.deleteTrip(state.trip!.id);
      state = const TripDetailState();
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return false;
    }
  }

  /// Clears any error state
  void clearError() {
    state = state.copyWith(error: null);
  }
}

/// Provider for trip detail state (family provider for different trip IDs)
final tripDetailProvider = StateNotifierProvider.family<TripDetailNotifier, TripDetailState, String>((ref, tripId) {
  final repository = ref.watch(tripRepositoryProvider);
  final notifier = TripDetailNotifier(repository);
  // Load the trip immediately
  Future.microtask(() => notifier.loadTrip(tripId));
  return notifier;
});
