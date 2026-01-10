// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'journal_search_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Notifier for journal search
///
/// Migration from StateNotifier to Notifier (Riverpod 3.0)
/// See: https://riverpod.dev/docs/migration/from_state_notifier

@ProviderFor(JournalSearch)
final journalSearchProvider = JournalSearchProvider._();

/// Notifier for journal search
///
/// Migration from StateNotifier to Notifier (Riverpod 3.0)
/// See: https://riverpod.dev/docs/migration/from_state_notifier
final class JournalSearchProvider
    extends $NotifierProvider<JournalSearch, JournalSearchState> {
  /// Notifier for journal search
  ///
  /// Migration from StateNotifier to Notifier (Riverpod 3.0)
  /// See: https://riverpod.dev/docs/migration/from_state_notifier
  JournalSearchProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'journalSearchProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$journalSearchHash();

  @$internal
  @override
  JournalSearch create() => JournalSearch();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(JournalSearchState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<JournalSearchState>(value),
    );
  }
}

String _$journalSearchHash() => r'799a445500111aea168fd5b09a8ff558fce60b75';

/// Notifier for journal search
///
/// Migration from StateNotifier to Notifier (Riverpod 3.0)
/// See: https://riverpod.dev/docs/migration/from_state_notifier

abstract class _$JournalSearch extends $Notifier<JournalSearchState> {
  JournalSearchState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<JournalSearchState, JournalSearchState>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<JournalSearchState, JournalSearchState>,
        JournalSearchState,
        Object?,
        Object?>;
    element.handleCreate(ref, build);
  }
}
