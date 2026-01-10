// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'destination_search_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Riverpod 3.0 Migration Notes:
/// - Converted from StateNotifier<AsyncValue<T>> to AsyncNotifier<T>
/// - Dependencies injected via ref.watch() in build() method
/// - build() returns Future<T> not AsyncValue<T> (Riverpod 3.0 handles wrapping)
/// - State is automatically AsyncValue<DestinationSearchState> when consumed
/// - Initialization logic moved from constructor to build() method
/// Provider for destination search state management
///
/// This provider manages the state of destination search operations including:
/// - Search results with pagination support
/// - Loading and error states
/// - Filter management
/// - Load more functionality
///
/// Riverpod 3.0: Uses @riverpod annotation with AsyncNotifier pattern.
/// State is automatically wrapped in AsyncValue when consumed.
///
/// Usage:
/// ```dart
/// final searchState = ref.watch(destinationSearchProvider);
/// final searchNotifier = ref.read(destinationSearchProvider.notifier);
///
/// // Perform search
/// await searchNotifier.search(filter);
///
/// // Load more results
/// await searchNotifier.loadMore();
///
/// // Clear search
/// searchNotifier.clear();
/// ```

@ProviderFor(DestinationSearch)
final destinationSearchProvider = DestinationSearchProvider._();

/// Riverpod 3.0 Migration Notes:
/// - Converted from StateNotifier<AsyncValue<T>> to AsyncNotifier<T>
/// - Dependencies injected via ref.watch() in build() method
/// - build() returns Future<T> not AsyncValue<T> (Riverpod 3.0 handles wrapping)
/// - State is automatically AsyncValue<DestinationSearchState> when consumed
/// - Initialization logic moved from constructor to build() method
/// Provider for destination search state management
///
/// This provider manages the state of destination search operations including:
/// - Search results with pagination support
/// - Loading and error states
/// - Filter management
/// - Load more functionality
///
/// Riverpod 3.0: Uses @riverpod annotation with AsyncNotifier pattern.
/// State is automatically wrapped in AsyncValue when consumed.
///
/// Usage:
/// ```dart
/// final searchState = ref.watch(destinationSearchProvider);
/// final searchNotifier = ref.read(destinationSearchProvider.notifier);
///
/// // Perform search
/// await searchNotifier.search(filter);
///
/// // Load more results
/// await searchNotifier.loadMore();
///
/// // Clear search
/// searchNotifier.clear();
/// ```
final class DestinationSearchProvider
    extends $AsyncNotifierProvider<DestinationSearch, DestinationSearchState> {
  /// Riverpod 3.0 Migration Notes:
  /// - Converted from StateNotifier<AsyncValue<T>> to AsyncNotifier<T>
  /// - Dependencies injected via ref.watch() in build() method
  /// - build() returns Future<T> not AsyncValue<T> (Riverpod 3.0 handles wrapping)
  /// - State is automatically AsyncValue<DestinationSearchState> when consumed
  /// - Initialization logic moved from constructor to build() method
  /// Provider for destination search state management
  ///
  /// This provider manages the state of destination search operations including:
  /// - Search results with pagination support
  /// - Loading and error states
  /// - Filter management
  /// - Load more functionality
  ///
  /// Riverpod 3.0: Uses @riverpod annotation with AsyncNotifier pattern.
  /// State is automatically wrapped in AsyncValue when consumed.
  ///
  /// Usage:
  /// ```dart
  /// final searchState = ref.watch(destinationSearchProvider);
  /// final searchNotifier = ref.read(destinationSearchProvider.notifier);
  ///
  /// // Perform search
  /// await searchNotifier.search(filter);
  ///
  /// // Load more results
  /// await searchNotifier.loadMore();
  ///
  /// // Clear search
  /// searchNotifier.clear();
  /// ```
  DestinationSearchProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'destinationSearchProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$destinationSearchHash();

  @$internal
  @override
  DestinationSearch create() => DestinationSearch();
}

String _$destinationSearchHash() => r'b7dab0173341f923833bcbbfa966e1c33b2efc4c';

/// Riverpod 3.0 Migration Notes:
/// - Converted from StateNotifier<AsyncValue<T>> to AsyncNotifier<T>
/// - Dependencies injected via ref.watch() in build() method
/// - build() returns Future<T> not AsyncValue<T> (Riverpod 3.0 handles wrapping)
/// - State is automatically AsyncValue<DestinationSearchState> when consumed
/// - Initialization logic moved from constructor to build() method
/// Provider for destination search state management
///
/// This provider manages the state of destination search operations including:
/// - Search results with pagination support
/// - Loading and error states
/// - Filter management
/// - Load more functionality
///
/// Riverpod 3.0: Uses @riverpod annotation with AsyncNotifier pattern.
/// State is automatically wrapped in AsyncValue when consumed.
///
/// Usage:
/// ```dart
/// final searchState = ref.watch(destinationSearchProvider);
/// final searchNotifier = ref.read(destinationSearchProvider.notifier);
///
/// // Perform search
/// await searchNotifier.search(filter);
///
/// // Load more results
/// await searchNotifier.loadMore();
///
/// // Clear search
/// searchNotifier.clear();
/// ```

abstract class _$DestinationSearch
    extends $AsyncNotifier<DestinationSearchState> {
  FutureOr<DestinationSearchState> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref
        as $Ref<AsyncValue<DestinationSearchState>, DestinationSearchState>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<AsyncValue<DestinationSearchState>, DestinationSearchState>,
        AsyncValue<DestinationSearchState>,
        Object?,
        Object?>;
    element.handleCreate(ref, build);
  }
}
