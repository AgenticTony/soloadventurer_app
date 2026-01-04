import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/destination.dart';
import '../../domain/models/destination_filter.dart';
import '../../domain/repositories/destination_repository.dart';
import '../state/destination_detail_state.dart';

/// Provider for destination detail state management
///
/// This provider manages the state of a single destination's detail view including:
/// - Destination data
/// - Related/suggested destinations
/// - Loading and error states
///
/// Usage:
/// ```dart
/// final detailState = ref.watch(destinationDetailProvider(destinationId));
/// final detailNotifier = ref.read(destinationDetailProvider(destinationId).notifier);
///
/// // Load destination (automatically called on first watch)
/// // The destinationId is passed as a parameter to the provider
///
/// // Refresh destination data
/// await detailNotifier.refresh();
///
/// // Load related destinations
/// await detailNotifier.loadRelatedDestinations();
/// ```
///
/// The [destinationId] parameter is the unique identifier of the destination to load.
final destinationDetailProvider = StateNotifierProvider.autoDispose
    .family<DestinationDetailNotifier, AsyncValue<DestinationDetailState>, String>(
  (ref, destinationId) {
    final repository = ref.watch(destinationRepositoryProvider);
    return DestinationDetailNotifier(repository, destinationId);
  },
);

/// Notifier for managing destination detail state
///
/// This notifier handles all operations for a single destination detail view:
/// - Loading destination by ID
/// - Refreshing destination data
/// - Loading related/suggested destinations
class DestinationDetailNotifier
    extends StateNotifier<AsyncValue<DestinationDetailState>> {
  final DestinationRepository _repository;
  final String _destinationId;

  /// Maximum number of related destinations to load
  static const int _maxRelatedDestinations = 5;

  /// Creates a new [DestinationDetailNotifier]
  ///
  /// The [repository] parameter is required for performing data operations.
  /// The [destinationId] parameter is the ID of the destination to manage.
  DestinationDetailNotifier(this._repository, this._destinationId)
      : super(const AsyncValue.data(DestinationDetailState.initial())) {
    // Auto-load destination on creation
    loadDestination();
  }

  /// Load the destination by ID
  ///
  /// This method fetches the destination data from the repository.
  /// Throws an exception if loading fails.
  ///
  /// Note: This is automatically called when the notifier is created.
  Future<void> loadDestination() async {
    state = const AsyncValue.loading();

    try {
      final destination = await _repository.getDestinationById(_destinationId);

      state = AsyncValue.data(DestinationDetailState(
        destination: destination,
      ));
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      rethrow;
    }
  }

  /// Refresh the destination data
  ///
  /// This method reloads the current destination from the repository.
  /// Useful for pull-to-refresh functionality or ensuring fresh data.
  ///
  /// Throws an exception if refreshing fails.
  Future<void> refresh() async {
    // Preserve current state while loading if available
    if (state.hasValue && state.value!.destination != null) {
      state = AsyncValue.data(state.value!);
    }

    try {
      final destination = await _repository.getDestinationById(_destinationId);

      state = AsyncValue.data(DestinationDetailState(
        destination: destination,
        relatedDestinations: state.value?.relatedDestinations ?? [],
      ));
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      rethrow;
    }
  }

  /// Load related/suggested destinations
  ///
  /// This method finds destinations related to the current destination based on:
  /// - Same country/region
  /// - Similar tags
  /// - Similar budget level
  /// - Similar activity level
  ///
  /// The results are limited to [_maxRelatedDestinations] and exclude the
  /// current destination from the suggestions.
  ///
  /// Throws an exception if loading related destinations fails.
  Future<void> loadRelatedDestinations() async {
    // Guard against loading if no destination is loaded
    if (!state.hasValue || state.value!.destination == null) {
      return;
    }

    final currentDestination = state.value!.destination!;

    // Update state to loading while keeping current data
    state = AsyncValue.data(state.value!);

    try {
      // Build filter for related destinations
      final filter = DestinationFilter(
        countryCode: currentDestination.countryCode,
        region: currentDestination.region,
        tags: currentDestination.tags,
        budgetLevel: currentDestination.budgetLevel,
        // Exclude current destination by searching for similar destinations
        // The repository implementation should handle exclusion
      );

      // Search for related destinations
      final related = await _repository.searchDestinations(
        filter.copyWith(limit: _maxRelatedDestinations + 1),
      );

      // Exclude current destination from results and limit results
      final filteredRelated = related
          .where((d) => d.id != _destinationId)
          .take(_maxRelatedDestinations)
          .toList();

      // Update state with related destinations
      final currentState = state.value!;
      state = AsyncValue.data(currentState.copyWith(
        relatedDestinations: filteredRelated,
      ));
    } catch (error, stackTrace) {
      // Revert to previous state on error
      state = AsyncValue.error(error, stackTrace);
      rethrow;
    }
  }

  /// Load related destinations with specific criteria
  ///
  /// This method allows customizing the criteria for finding related destinations.
  /// The [filter] parameter specifies the search criteria.
  ///
  /// The results exclude the current destination and are limited to
  /// [_maxRelatedDestinations].
  ///
  /// Throws an exception if loading related destinations fails.
  Future<void> loadRelatedDestinationsWithFilter(
      DestinationFilter filter) async {
    // Guard against loading if no destination is loaded
    if (!state.hasValue || state.value!.destination == null) {
      return;
    }

    // Update state to loading while keeping current data
    state = AsyncValue.data(state.value!);

    try {
      // Search for related destinations with custom filter
      final related = await _repository.searchDestinations(
        filter.copyWith(limit: _maxRelatedDestinations + 1),
      );

      // Exclude current destination from results and limit results
      final filteredRelated = related
          .where((d) => d.id != _destinationId)
          .take(_maxRelatedDestinations)
          .toList();

      // Update state with related destinations
      final currentState = state.value!;
      state = AsyncValue.data(currentState.copyWith(
        relatedDestinations: filteredRelated,
      ));
    } catch (error, stackTrace) {
      // Revert to previous state on error
      state = AsyncValue.error(error, stackTrace);
      rethrow;
    }
  }

  /// Clear the destination detail state
  ///
  /// This method resets the state to initial, clearing all data.
  /// This is useful for cleanup or when navigating away from the detail view.
  void clear() {
    state = const AsyncValue.data(DestinationDetailState.initial());
  }
}
