// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'journal_list_provider_optimized.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Optimized notifier for managing journal list with pagination and caching
///
/// Migration from StateNotifier to Notifier (Riverpod 3.0)
/// See: https://riverpod.dev/docs/migration/from_state_notifier

@ProviderFor(OptimizedJournalList)
final optimizedJournalListProvider = OptimizedJournalListProvider._();

/// Optimized notifier for managing journal list with pagination and caching
///
/// Migration from StateNotifier to Notifier (Riverpod 3.0)
/// See: https://riverpod.dev/docs/migration/from_state_notifier
final class OptimizedJournalListProvider
    extends $NotifierProvider<OptimizedJournalList, OptimizedJournalListState> {
  /// Optimized notifier for managing journal list with pagination and caching
  ///
  /// Migration from StateNotifier to Notifier (Riverpod 3.0)
  /// See: https://riverpod.dev/docs/migration/from_state_notifier
  OptimizedJournalListProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'optimizedJournalListProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$optimizedJournalListHash();

  @$internal
  @override
  OptimizedJournalList create() => OptimizedJournalList();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(OptimizedJournalListState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<OptimizedJournalListState>(value),
    );
  }
}

String _$optimizedJournalListHash() =>
    r'7b3094e2aefd1e29cf592066f10e783ad8f2d7f9';

/// Optimized notifier for managing journal list with pagination and caching
///
/// Migration from StateNotifier to Notifier (Riverpod 3.0)
/// See: https://riverpod.dev/docs/migration/from_state_notifier

abstract class _$OptimizedJournalList
    extends $Notifier<OptimizedJournalListState> {
  OptimizedJournalListState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref as $Ref<OptimizedJournalListState, OptimizedJournalListState>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<OptimizedJournalListState, OptimizedJournalListState>,
        OptimizedJournalListState,
        Object?,
        Object?>;
    element.handleCreate(ref, build);
  }
}

/// Provider for query optimizer

@ProviderFor(journalQueryOptimizer)
final journalQueryOptimizerProvider = JournalQueryOptimizerProvider._();

/// Provider for query optimizer

final class JournalQueryOptimizerProvider
    extends $FunctionalProvider<QueryOptimizer, QueryOptimizer, QueryOptimizer>
    with $Provider<QueryOptimizer> {
  /// Provider for query optimizer
  JournalQueryOptimizerProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'journalQueryOptimizerProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$journalQueryOptimizerHash();

  @$internal
  @override
  $ProviderElement<QueryOptimizer> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  QueryOptimizer create(Ref ref) {
    return journalQueryOptimizer(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(QueryOptimizer value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<QueryOptimizer>(value),
    );
  }
}

String _$journalQueryOptimizerHash() =>
    r'36315a08a59e64f2854aab9bf85c6ef12d35a4f5';

/// Provider for entries grouped by trip (optimized)

@ProviderFor(optimizedJournalEntriesByTrip)
final optimizedJournalEntriesByTripProvider =
    OptimizedJournalEntriesByTripProvider._();

/// Provider for entries grouped by trip (optimized)

final class OptimizedJournalEntriesByTripProvider extends $FunctionalProvider<
        Map<String?, List<JournalEntry>>,
        Map<String?, List<JournalEntry>>,
        Map<String?, List<JournalEntry>>>
    with $Provider<Map<String?, List<JournalEntry>>> {
  /// Provider for entries grouped by trip (optimized)
  OptimizedJournalEntriesByTripProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'optimizedJournalEntriesByTripProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$optimizedJournalEntriesByTripHash();

  @$internal
  @override
  $ProviderElement<Map<String?, List<JournalEntry>>> $createElement(
          $ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  Map<String?, List<JournalEntry>> create(Ref ref) {
    return optimizedJournalEntriesByTrip(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Map<String?, List<JournalEntry>> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride:
          $SyncValueProvider<Map<String?, List<JournalEntry>>>(value),
    );
  }
}

String _$optimizedJournalEntriesByTripHash() =>
    r'1b60708de959e3fe5264d7805d1a5837652f7c7c';

/// Provider for entries grouped by date (optimized)

@ProviderFor(optimizedJournalEntriesByDate)
final optimizedJournalEntriesByDateProvider =
    OptimizedJournalEntriesByDateProvider._();

/// Provider for entries grouped by date (optimized)

final class OptimizedJournalEntriesByDateProvider extends $FunctionalProvider<
        Map<String, List<JournalEntry>>,
        Map<String, List<JournalEntry>>,
        Map<String, List<JournalEntry>>>
    with $Provider<Map<String, List<JournalEntry>>> {
  /// Provider for entries grouped by date (optimized)
  OptimizedJournalEntriesByDateProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'optimizedJournalEntriesByDateProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$optimizedJournalEntriesByDateHash();

  @$internal
  @override
  $ProviderElement<Map<String, List<JournalEntry>>> $createElement(
          $ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  Map<String, List<JournalEntry>> create(Ref ref) {
    return optimizedJournalEntriesByDate(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Map<String, List<JournalEntry>> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride:
          $SyncValueProvider<Map<String, List<JournalEntry>>>(value),
    );
  }
}

String _$optimizedJournalEntriesByDateHash() =>
    r'9d1a52bfb58135e2b3f6ac46a3ea539d10040f0c';
