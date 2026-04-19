import 'dart:async';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:soloadventurer/features/matching/domain/entities/matching_trip.dart';
import 'matching_provider.dart';
import 'connection_provider.dart';

part 'trip_provider.g.dart';

/// Provider for user's trips
@Riverpod(keepAlive: true)
Future<List<MatchingTrip>> userTrips(Ref ref) async {
  final repository = ref.watch(matchingRepositoryProvider);
  return repository.getUserTrips();
}

/// Provider for active trips (currently happening or future)
@Riverpod(keepAlive: true)
Future<List<MatchingTrip>> activeTrips(Ref ref) async {
  final trips = await ref.watch(userTripsProvider.future);
  return trips.where((trip) => trip.isActive && !trip.isPastTrip).toList();
}

/// Provider for a specific trip by ID
@Riverpod(keepAlive: true)
Future<MatchingTrip?> tripById(Ref ref, String tripId) async {
  final repository = ref.watch(matchingRepositoryProvider);
  return repository.getTrip(tripId);
}

/// Notifier for managing trip CRUD operations
@Riverpod(keepAlive: true)
class TripNotifier extends _$TripNotifier {
  @override
  FutureOr<void> build() {
    // Initial state is void (no action pending)
    return null;
  }

  /// Create a new trip
  Future<MatchingTrip> createTrip({
    required String destinationName,
    required double latitude,
    required double longitude,
    required DateTime startDate,
    required DateTime endDate,
    LocationPrecision locationPrecision = LocationPrecision.city,
  }) async {
    state = const AsyncValue.loading();

    final repository = ref.read(matchingRepositoryProvider);

    final result = await AsyncValue.guard(() async {
      final trip = await repository.createTrip(
        destinationName: destinationName,
        latitude: latitude,
        longitude: longitude,
        startDate: startDate,
        endDate: endDate,
        locationPrecision: locationPrecision,
      );

      // Invalidate related providers to refresh data
      ref.invalidate(userTripsProvider);
      ref.invalidate(activeTripsProvider);
      ref.invalidate(matchesProvider);

      return trip;
    });

    state = result;

    if (result.hasError) {
      throw result.error!;
    }

    return result.value as MatchingTrip;
  }

  /// Update an existing trip
  Future<void> updateTrip(MatchingTrip trip) async {
    state = const AsyncValue.loading();

    final repository = ref.read(matchingRepositoryProvider);

    final result = await AsyncValue.guard(() async {
      await repository.updateTrip(trip);

      // Invalidate related providers
      ref.invalidate(userTripsProvider);
      ref.invalidate(activeTripsProvider);
      ref.invalidate(tripByIdProvider(trip.id));
    });

    state = result;

    if (result.hasError) {
      throw result.error!;
    }
  }

  /// Delete a trip
  Future<void> deleteTrip(String tripId) async {
    state = const AsyncValue.loading();

    final repository = ref.read(matchingRepositoryProvider);

    final result = await AsyncValue.guard(() async {
      await repository.deleteTrip(tripId);

      // Invalidate related providers
      ref.invalidate(userTripsProvider);
      ref.invalidate(activeTripsProvider);
      ref.invalidate(tripByIdProvider(tripId));
      ref.invalidate(matchesProvider);
    });

    state = result;

    if (result.hasError) {
      throw result.error!;
    }
  }

  /// Archive expired trips (cleanup operation)
  Future<void> archiveExpiredTrips() async {
    final repository = ref.read(matchingRepositoryProvider);

    final result = await AsyncValue.guard(() async {
      await repository.archiveExpiredTrips();
      ref.invalidate(userTripsProvider);
      ref.invalidate(activeTripsProvider);
    });

    state = result;

    if (result.hasError) {
      throw result.error!;
    }
  }
}
