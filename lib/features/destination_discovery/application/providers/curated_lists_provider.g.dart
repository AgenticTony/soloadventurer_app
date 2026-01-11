// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'curated_lists_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Riverpod 3.0 Migration Notes:
/// - Converted from StateNotifier<AsyncValue<T>> to AsyncNotifier<T>
/// - Dependencies injected via ref.watch() in build() method
/// - build() returns Future<T> not AsyncValue<T>
/// - State is automatically AsyncValue<CuratedListsState> when consumed
/// - Constructor auto-load logic moved to build() method
///
/// Provider for curated destination lists state management
///
/// This provider manages the state of curated destination collections including:
/// - All curated lists
/// - Selected/detailed curated list
/// - Loading and error states
///
/// Riverpod 3.0: Uses @riverpod annotation with AsyncNotifier pattern.
///
/// Usage:
/// ```dart
/// final curatedListsState = ref.watch(curatedListsProvider);
/// final curatedListsNotifier = ref.watch(curatedListsProvider.notifier);
///
/// // Load all curated lists (automatically called on first watch)
/// // Lists are auto-loaded when the provider is first watched
///
/// // Load a specific curated list
/// await curatedListsNotifier.loadCuratedList(listId);
///
/// // Refresh all curated lists
/// await curatedListsNotifier.refresh();
///
/// // Clear all curated lists
/// curatedListsNotifier.clear();
///
/// // Get curated lists by type
/// final hiddenGems = curatedListsNotifier.hiddenGemsLists;
/// ```

@ProviderFor(CuratedLists)
const curatedListsProvider = CuratedListsProvider._();

/// Riverpod 3.0 Migration Notes:
/// - Converted from StateNotifier<AsyncValue<T>> to AsyncNotifier<T>
/// - Dependencies injected via ref.watch() in build() method
/// - build() returns Future<T> not AsyncValue<T>
/// - State is automatically AsyncValue<CuratedListsState> when consumed
/// - Constructor auto-load logic moved to build() method
///
/// Provider for curated destination lists state management
///
/// This provider manages the state of curated destination collections including:
/// - All curated lists
/// - Selected/detailed curated list
/// - Loading and error states
///
/// Riverpod 3.0: Uses @riverpod annotation with AsyncNotifier pattern.
///
/// Usage:
/// ```dart
/// final curatedListsState = ref.watch(curatedListsProvider);
/// final curatedListsNotifier = ref.watch(curatedListsProvider.notifier);
///
/// // Load all curated lists (automatically called on first watch)
/// // Lists are auto-loaded when the provider is first watched
///
/// // Load a specific curated list
/// await curatedListsNotifier.loadCuratedList(listId);
///
/// // Refresh all curated lists
/// await curatedListsNotifier.refresh();
///
/// // Clear all curated lists
/// curatedListsNotifier.clear();
///
/// // Get curated lists by type
/// final hiddenGems = curatedListsNotifier.hiddenGemsLists;
/// ```
final class CuratedListsProvider
    extends $AsyncNotifierProvider<CuratedLists, CuratedListsState> {
  /// Riverpod 3.0 Migration Notes:
  /// - Converted from StateNotifier<AsyncValue<T>> to AsyncNotifier<T>
  /// - Dependencies injected via ref.watch() in build() method
  /// - build() returns Future<T> not AsyncValue<T>
  /// - State is automatically AsyncValue<CuratedListsState> when consumed
  /// - Constructor auto-load logic moved to build() method
  ///
  /// Provider for curated destination lists state management
  ///
  /// This provider manages the state of curated destination collections including:
  /// - All curated lists
  /// - Selected/detailed curated list
  /// - Loading and error states
  ///
  /// Riverpod 3.0: Uses @riverpod annotation with AsyncNotifier pattern.
  ///
  /// Usage:
  /// ```dart
  /// final curatedListsState = ref.watch(curatedListsProvider);
  /// final curatedListsNotifier = ref.watch(curatedListsProvider.notifier);
  ///
  /// // Load all curated lists (automatically called on first watch)
  /// // Lists are auto-loaded when the provider is first watched
  ///
  /// // Load a specific curated list
  /// await curatedListsNotifier.loadCuratedList(listId);
  ///
  /// // Refresh all curated lists
  /// await curatedListsNotifier.refresh();
  ///
  /// // Clear all curated lists
  /// curatedListsNotifier.clear();
  ///
  /// // Get curated lists by type
  /// final hiddenGems = curatedListsNotifier.hiddenGemsLists;
  /// ```
  const CuratedListsProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'curatedListsProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$curatedListsHash();

  @$internal
  @override
  CuratedLists create() => CuratedLists();
}

String _$curatedListsHash() => r'219a7110f3a3798f1f51f009766569b5b9994758';

/// Riverpod 3.0 Migration Notes:
/// - Converted from StateNotifier<AsyncValue<T>> to AsyncNotifier<T>
/// - Dependencies injected via ref.watch() in build() method
/// - build() returns Future<T> not AsyncValue<T>
/// - State is automatically AsyncValue<CuratedListsState> when consumed
/// - Constructor auto-load logic moved to build() method
///
/// Provider for curated destination lists state management
///
/// This provider manages the state of curated destination collections including:
/// - All curated lists
/// - Selected/detailed curated list
/// - Loading and error states
///
/// Riverpod 3.0: Uses @riverpod annotation with AsyncNotifier pattern.
///
/// Usage:
/// ```dart
/// final curatedListsState = ref.watch(curatedListsProvider);
/// final curatedListsNotifier = ref.watch(curatedListsProvider.notifier);
///
/// // Load all curated lists (automatically called on first watch)
/// // Lists are auto-loaded when the provider is first watched
///
/// // Load a specific curated list
/// await curatedListsNotifier.loadCuratedList(listId);
///
/// // Refresh all curated lists
/// await curatedListsNotifier.refresh();
///
/// // Clear all curated lists
/// curatedListsNotifier.clear();
///
/// // Get curated lists by type
/// final hiddenGems = curatedListsNotifier.hiddenGemsLists;
/// ```

abstract class _$CuratedLists extends $AsyncNotifier<CuratedListsState> {
  FutureOr<CuratedListsState> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref =
        this.ref as $Ref<AsyncValue<CuratedListsState>, CuratedListsState>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<AsyncValue<CuratedListsState>, CuratedListsState>,
        AsyncValue<CuratedListsState>,
        Object?,
        Object?>;
    element.handleValue(ref, created);
  }
}
