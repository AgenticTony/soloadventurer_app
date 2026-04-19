// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'filter_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provider for destination filter state management
///
/// This provider manages the state of destination search filters including:
/// - Budget level
/// - Safety score
/// - Activity level
/// - Solo suitability score
/// - Location/region
/// - Tags/categories
/// - Search query
/// - Sort order
///
/// This provider is separate from [destinationSearchProvider] to allow UI
/// components to manage filter state without triggering searches immediately.
///
/// Usage:
/// ```dart
/// final filterState = ref.watch(filterProvider);
/// final filterNotifier = ref.read(filterProvider.notifier);
///
/// // Update individual filter fields
/// filterNotifier.updateBudgetLevel(BudgetLevel.moderate);
/// filterNotifier.updateMinSafetyScore(7.0);
/// filterNotifier.updateSearchQuery('Tokyo');
///
/// // Update multiple fields at once
/// filterNotifier.updateFilter(
///   const DestinationFilter(
///     budgetLevel: BudgetLevel.budget,
///     minSafetyScore: 8.0,
///   ),
/// );
///
/// // Reset all filters
/// filterNotifier.reset();
///
/// // Check if filters are active
/// if (filterState.hasActiveFilters) {
///   // Show active filters indicator
/// }
/// ```
/// Notifier for managing destination filter state
///
/// Migration from StateNotifier to Notifier (Riverpod 3.0)
/// See: https://riverpod.dev/docs/migration/from_state_notifier
///
/// This notifier handles all filter update operations:
/// - Updating individual filter fields
/// - Updating the entire filter at once
/// - Resetting filters to default values
/// - Providing helper methods to check filter status

@ProviderFor(Filter)
const filterProvider = FilterProvider._();

/// Provider for destination filter state management
///
/// This provider manages the state of destination search filters including:
/// - Budget level
/// - Safety score
/// - Activity level
/// - Solo suitability score
/// - Location/region
/// - Tags/categories
/// - Search query
/// - Sort order
///
/// This provider is separate from [destinationSearchProvider] to allow UI
/// components to manage filter state without triggering searches immediately.
///
/// Usage:
/// ```dart
/// final filterState = ref.watch(filterProvider);
/// final filterNotifier = ref.read(filterProvider.notifier);
///
/// // Update individual filter fields
/// filterNotifier.updateBudgetLevel(BudgetLevel.moderate);
/// filterNotifier.updateMinSafetyScore(7.0);
/// filterNotifier.updateSearchQuery('Tokyo');
///
/// // Update multiple fields at once
/// filterNotifier.updateFilter(
///   const DestinationFilter(
///     budgetLevel: BudgetLevel.budget,
///     minSafetyScore: 8.0,
///   ),
/// );
///
/// // Reset all filters
/// filterNotifier.reset();
///
/// // Check if filters are active
/// if (filterState.hasActiveFilters) {
///   // Show active filters indicator
/// }
/// ```
/// Notifier for managing destination filter state
///
/// Migration from StateNotifier to Notifier (Riverpod 3.0)
/// See: https://riverpod.dev/docs/migration/from_state_notifier
///
/// This notifier handles all filter update operations:
/// - Updating individual filter fields
/// - Updating the entire filter at once
/// - Resetting filters to default values
/// - Providing helper methods to check filter status
final class FilterProvider
    extends $NotifierProvider<Filter, DestinationFilter> {
  /// Provider for destination filter state management
  ///
  /// This provider manages the state of destination search filters including:
  /// - Budget level
  /// - Safety score
  /// - Activity level
  /// - Solo suitability score
  /// - Location/region
  /// - Tags/categories
  /// - Search query
  /// - Sort order
  ///
  /// This provider is separate from [destinationSearchProvider] to allow UI
  /// components to manage filter state without triggering searches immediately.
  ///
  /// Usage:
  /// ```dart
  /// final filterState = ref.watch(filterProvider);
  /// final filterNotifier = ref.read(filterProvider.notifier);
  ///
  /// // Update individual filter fields
  /// filterNotifier.updateBudgetLevel(BudgetLevel.moderate);
  /// filterNotifier.updateMinSafetyScore(7.0);
  /// filterNotifier.updateSearchQuery('Tokyo');
  ///
  /// // Update multiple fields at once
  /// filterNotifier.updateFilter(
  ///   const DestinationFilter(
  ///     budgetLevel: BudgetLevel.budget,
  ///     minSafetyScore: 8.0,
  ///   ),
  /// );
  ///
  /// // Reset all filters
  /// filterNotifier.reset();
  ///
  /// // Check if filters are active
  /// if (filterState.hasActiveFilters) {
  ///   // Show active filters indicator
  /// }
  /// ```
  /// Notifier for managing destination filter state
  ///
  /// Migration from StateNotifier to Notifier (Riverpod 3.0)
  /// See: https://riverpod.dev/docs/migration/from_state_notifier
  ///
  /// This notifier handles all filter update operations:
  /// - Updating individual filter fields
  /// - Updating the entire filter at once
  /// - Resetting filters to default values
  /// - Providing helper methods to check filter status
  const FilterProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'filterProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$filterHash();

  @$internal
  @override
  Filter create() => Filter();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DestinationFilter value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DestinationFilter>(value),
    );
  }
}

String _$filterHash() => r'4a7e688c6c1fa90d8df18560e1c7c799672185fb';

/// Provider for destination filter state management
///
/// This provider manages the state of destination search filters including:
/// - Budget level
/// - Safety score
/// - Activity level
/// - Solo suitability score
/// - Location/region
/// - Tags/categories
/// - Search query
/// - Sort order
///
/// This provider is separate from [destinationSearchProvider] to allow UI
/// components to manage filter state without triggering searches immediately.
///
/// Usage:
/// ```dart
/// final filterState = ref.watch(filterProvider);
/// final filterNotifier = ref.read(filterProvider.notifier);
///
/// // Update individual filter fields
/// filterNotifier.updateBudgetLevel(BudgetLevel.moderate);
/// filterNotifier.updateMinSafetyScore(7.0);
/// filterNotifier.updateSearchQuery('Tokyo');
///
/// // Update multiple fields at once
/// filterNotifier.updateFilter(
///   const DestinationFilter(
///     budgetLevel: BudgetLevel.budget,
///     minSafetyScore: 8.0,
///   ),
/// );
///
/// // Reset all filters
/// filterNotifier.reset();
///
/// // Check if filters are active
/// if (filterState.hasActiveFilters) {
///   // Show active filters indicator
/// }
/// ```
/// Notifier for managing destination filter state
///
/// Migration from StateNotifier to Notifier (Riverpod 3.0)
/// See: https://riverpod.dev/docs/migration/from_state_notifier
///
/// This notifier handles all filter update operations:
/// - Updating individual filter fields
/// - Updating the entire filter at once
/// - Resetting filters to default values
/// - Providing helper methods to check filter status

abstract class _$Filter extends $Notifier<DestinationFilter> {
  DestinationFilter build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<DestinationFilter, DestinationFilter>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<DestinationFilter, DestinationFilter>,
        DestinationFilter,
        Object?,
        Object?>;
    element.handleValue(ref, created);
  }
}
