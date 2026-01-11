// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'journal_list_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Notifier for managing journal list state
/// MIGRATION: StateNotifier → Notifier pattern
/// - Constructor logic moved to build() method
/// - Dependencies accessed via ref.watch() in methods
/// - Automatic provider generation via @riverpod annotation

@ProviderFor(JournalList)
const journalListProvider = JournalListProvider._();

/// Notifier for managing journal list state
/// MIGRATION: StateNotifier → Notifier pattern
/// - Constructor logic moved to build() method
/// - Dependencies accessed via ref.watch() in methods
/// - Automatic provider generation via @riverpod annotation
final class JournalListProvider
    extends $NotifierProvider<JournalList, JournalListState> {
  /// Notifier for managing journal list state
  /// MIGRATION: StateNotifier → Notifier pattern
  /// - Constructor logic moved to build() method
  /// - Dependencies accessed via ref.watch() in methods
  /// - Automatic provider generation via @riverpod annotation
  const JournalListProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'journalListProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$journalListHash();

  @$internal
  @override
  JournalList create() => JournalList();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(JournalListState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<JournalListState>(value),
    );
  }
}

String _$journalListHash() => r'8aa5f7207ebedd3081b45a95b691f7d2543f24a8';

/// Notifier for managing journal list state
/// MIGRATION: StateNotifier → Notifier pattern
/// - Constructor logic moved to build() method
/// - Dependencies accessed via ref.watch() in methods
/// - Automatic provider generation via @riverpod annotation

abstract class _$JournalList extends $Notifier<JournalListState> {
  JournalListState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<JournalListState, JournalListState>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<JournalListState, JournalListState>,
        JournalListState,
        Object?,
        Object?>;
    element.handleValue(ref, created);
  }
}

/// Provider for entries grouped by trip
/// Computed from the main journalListProvider state

@ProviderFor(journalEntriesByTrip)
const journalEntriesByTripProvider = JournalEntriesByTripProvider._();

/// Provider for entries grouped by trip
/// Computed from the main journalListProvider state

final class JournalEntriesByTripProvider extends $FunctionalProvider<
        Map<String?, List<JournalEntry>>,
        Map<String?, List<JournalEntry>>,
        Map<String?, List<JournalEntry>>>
    with $Provider<Map<String?, List<JournalEntry>>> {
  /// Provider for entries grouped by trip
  /// Computed from the main journalListProvider state
  const JournalEntriesByTripProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'journalEntriesByTripProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$journalEntriesByTripHash();

  @$internal
  @override
  $ProviderElement<Map<String?, List<JournalEntry>>> $createElement(
          $ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  Map<String?, List<JournalEntry>> create(Ref ref) {
    return journalEntriesByTrip(ref);
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

String _$journalEntriesByTripHash() =>
    r'9a594df39a6d302e185346fd1f13713bc39773e6';

/// Provider for entries grouped by date
/// Computed from the main journalListProvider state

@ProviderFor(journalEntriesByDate)
const journalEntriesByDateProvider = JournalEntriesByDateProvider._();

/// Provider for entries grouped by date
/// Computed from the main journalListProvider state

final class JournalEntriesByDateProvider extends $FunctionalProvider<
        Map<String, List<JournalEntry>>,
        Map<String, List<JournalEntry>>,
        Map<String, List<JournalEntry>>>
    with $Provider<Map<String, List<JournalEntry>>> {
  /// Provider for entries grouped by date
  /// Computed from the main journalListProvider state
  const JournalEntriesByDateProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'journalEntriesByDateProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$journalEntriesByDateHash();

  @$internal
  @override
  $ProviderElement<Map<String, List<JournalEntry>>> $createElement(
          $ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  Map<String, List<JournalEntry>> create(Ref ref) {
    return journalEntriesByDate(ref);
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

String _$journalEntriesByDateHash() =>
    r'813c552c780fa5bd93843d30fe6efbd2527cef70';
