import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/models/destination_filter.dart';
import '../state/destination_detail_state.dart';
import 'destination_repository_provider.dart';

part 'destination_detail_provider.g.dart';

/// Riverpod 3.0 Migration Notes:
/// - Converted from StateNotifier<AsyncValue<T>> to AsyncNotifier<T>
/// - Dependencies injected via ref.watch() in build() method
/// - Family provider with destinationId parameter in build()
/// - AutoDispose enabled via @Riverpod annotation
/// - build() returns Future<T> not AsyncValue<T>
/// - State is automatically AsyncValue<DestinationDetailState> when consumed
///
/// Provider for destination detail state management
///
/// This provider manages the state of a single destination's detail view including:
/// - Destination data
/// - Related/suggested destinations
/// - Loading and error states
///
/// Riverpod 3.0: Uses @riverpod annotation with AsyncNotifier pattern.
/// Auto-dispose behavior for family provider.
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
@riverpod
class DestinationDetail extends _$DestinationDetail {
  /// Maximum number of related destinations to load
  static const int _maxRelatedDestinations = 5;

  /// Initialize the notifier with dependencies
  ///
  /// Riverpod 3.0: build() returns Future<DestinationDetailState>
  /// Family provider parameter (destinationId) is passed here
  /// AutoDispose behavior: provider will be disposed when no longer watched
  @override
  Future<DestinationDetailState> build(String destinationId) async {
    // Get dependencies via ref.watch()
    final repository = ref.watch(destinationRepositoryProvider);

    // Auto-load destination on build
    final destination = await repository.getDestinationById(destinationId);
    return DestinationDetailState(destination: destination);
  }

  /// Refresh the destination data
  ///
  /// This method reloads the current destination from the repository.
  /// Useful for pull-to-refresh functionality or ensuring fresh data.
  ///
  /// Throws an exception if refreshing fails.
  Future<void> refresh() async {
    // Get destinationId from state
    final currentState = state.value;
    if (currentState == null || currentState.destination == null) {
      return;
    }

    // Get repository
    final repository = ref.read(destinationRepositoryProvider);

    // Get destinationId from the first load
    final destinationId = currentState.destination!.id;

    // Preserve current state while loading
    state = const AsyncValue.loading();

    // Load destination
    state = await AsyncValue.guard(() async {
      final destination = await repository.getDestinationById(destinationId);
      return DestinationDetailState(
        destination: destination,
        relatedDestinations: currentState.relatedDestinations,
      );
    });
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
    // Get repository
    final repository = ref.read(destinationRepositoryProvider);

    // Guard against loading if no destination is loaded
    final currentValue = state.value;
    final currentDestination = currentValue?.destination;
    if (currentDestination == null) {
      return;
    }

    // Build filter for related destinations
    final filter = DestinationFilter(
      countryCode: currentDestination.countryCode,
      region: currentDestination.region,
      tags: currentDestination.tags,
      budgetLevel: currentDestination.budgetLevel as BudgetLevel?,
    );

    // Set loading state
    state = await AsyncValue.guard(() async {
      // Search for related destinations
      final related = await repository.searchDestinations(
        filter.copyWith(limit: _maxRelatedDestinations + 1),
      );

      // Exclude current destination from results and limit results
      final destinationId = currentDestination.id;
      final filteredRelated = related
          .where((d) => d.id != destinationId)
          .take(_maxRelatedDestinations)
          .toList();

      // Return state with related destinations
      return currentValue!.copyWith(
        relatedDestinations: filteredRelated,
      );
    });
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
    // Get repository
    final repository = ref.read(destinationRepositoryProvider);

    // Guard against loading if no destination is loaded
    final currentValue = state.value;
    if (currentValue == null || currentValue.destination == null) {
      return;
    }

    final destinationId = currentValue.destination!.id;

    // Set loading state
    state = await AsyncValue.guard(() async {
      // Search for related destinations with custom filter
      final related = await repository.searchDestinations(
        filter.copyWith(limit: _maxRelatedDestinations + 1),
      );

      // Exclude current destination from results and limit results
      final filteredRelated = related
          .where((d) => d.id != destinationId)
          .take(_maxRelatedDestinations)
          .toList();

      // Return state with related destinations
      return currentValue.copyWith(
        relatedDestinations: filteredRelated,
      );
    });
  }

  /// Clear the destination detail state
  ///
  /// This method resets the state to initial, clearing all data.
  /// This is useful for cleanup or when navigating away from the detail view.
  void clear() {
    state = const AsyncValue.data(DestinationDetailState.initial());
  }
}
