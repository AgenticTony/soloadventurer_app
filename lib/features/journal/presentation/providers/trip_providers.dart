import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:soloadventurer/features/journal/data/datasources/trip_remote_data_source_impl.dart';
import 'package:soloadventurer/features/journal/data/repositories/trip_repository_impl.dart';
import 'package:soloadventurer/features/journal/domain/entities/trip.dart';
import 'package:soloadventurer/features/journal/domain/repositories/trip_repository.dart';

// Generated file
part 'trip_providers.g.dart';

// ============================================================================
// Dependency Injection Providers
// ============================================================================

/// Provides the Supabase client instance
@riverpod
SupabaseClient supabaseClient(Ref ref) {
  return Supabase.instance.client;
}

/// Provides the TripRemoteDataSource implementation
@riverpod
TripRemoteDataSourceImpl tripRemoteDataSource(Ref ref) {
  final client = ref.watch(supabaseClientProvider);
  return TripRemoteDataSourceImpl(client: client);
}

/// Provides the TripRepository implementation
@riverpod
TripRepository tripRepository(Ref ref) {
  final remoteDataSource = ref.watch(tripRemoteDataSourceProvider);
  return TripRepositoryImpl(remoteDataSource: remoteDataSource);
}

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
///
/// Migration from StateNotifier to Notifier (Riverpod 3.0)
/// See: https://riverpod.dev/docs/migration/from_state_notifier
@riverpod
class TripList extends _$TripList {
  @override
  TripListState build() {
    // Load trips automatically on build
    loadTrips();
    return const TripListState();
  }

  /// Loads all trips for the current user
  Future<void> loadTrips() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final repository = ref.read(tripRepositoryProvider);
      final trips = await repository.getTrips();
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
      final repository = ref.read(tripRepositoryProvider);
      final trips = await repository.getOngoingTrips();
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
///
/// Migration from StateNotifier to Notifier (Riverpod 3.0)
/// See: https://riverpod.dev/docs/migration/from_state_notifier
@riverpod
class TripForm extends _$TripForm {
  String? _editingTripId;

  @override
  TripFormState build() {
    return TripFormState(startDate: DateTime.now());
  }

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
      final repository = ref.read(tripRepositoryProvider);
      final trip = await repository.getTrip(tripId);
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

      final repository = ref.read(tripRepositoryProvider);
      Trip trip;

      if (_editingTripId != null) {
        // Update existing trip
        final existingTrip = await repository.getTrip(_editingTripId!);
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
        trip = await repository.updateTrip(trip);
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
        trip = await repository.createTrip(trip);
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
///
/// Migration from StateNotifier to Notifier (Riverpod 3.0)
/// See: https://riverpod.dev/docs/migration/from_state_notifier
///
/// Family provider pattern: pass tripId as parameter
/// Usage: ref.watch(tripDetailProvider(tripId))
@riverpod
class TripDetail extends _$TripDetail {
  @override
  TripDetailState build(String tripIdArg) {
    // Load trip automatically on build with the provided tripId
    if (tripIdArg.isNotEmpty) {
      // Use a microtask to avoid calling async during build
      Future.microtask(() => loadTrip(tripIdArg));
    }
    return const TripDetailState();
  }

  /// Loads a trip by ID
  Future<void> loadTrip(String tripIdParam) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final repository = ref.read(tripRepositoryProvider);
      final trip = await repository.getTrip(tripIdParam);
      final entryCount = await repository.getEntryCountForTrip(tripIdParam);

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
      final repository = ref.read(tripRepositoryProvider);
      await repository.deleteTrip(state.trip!.id);
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
