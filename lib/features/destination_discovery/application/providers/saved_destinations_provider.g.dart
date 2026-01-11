// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'saved_destinations_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Riverpod 3.0 Migration Notes:
/// - Converted from StateNotifier<AsyncValue<T>> to AsyncNotifier<T>
/// - Dependencies injected via ref.watch() in build() method
/// - Family provider with userId parameter in build()
/// - AutoDispose enabled via @Riverpod annotation
/// - build() returns Future<T> not AsyncValue<T>
/// - State is automatically AsyncValue<SavedDestinationsState> when consumed
/// - Constructor auto-load logic moved to build() method
///
/// Provider for saved destinations state management
///
/// This provider manages the state of user's saved destinations including:
/// - Wishlist and trip destinations
/// - Loading and error states
/// - Save/unsave operations
/// - Filtering by save type (wishlist or trip)
///
/// Riverpod 3.0: Uses @riverpod annotation with AsyncNotifier pattern.
/// Auto-dispose behavior for family provider.
///
/// Usage:
/// ```dart
/// final savedState = ref.watch(savedDestinationsProvider(userId));
/// final savedNotifier = ref.read(savedDestinationsProvider(userId).notifier);
///
/// // Load saved destinations (automatically called on first watch)
/// // The userId is passed as a parameter to the provider
///
/// // Save a destination to wishlist
/// await savedNotifier.saveDestination(
///   userId: userId,
///   destination: destination,
///   saveType: SaveType.wishlist,
/// );
///
/// // Unsave a destination
/// await savedNotifier.unsaveDestination(
///   userId: userId,
///   destinationId: destinationId,
/// );
///
/// // Refresh saved destinations
/// await savedNotifier.refresh();
/// ```
///
/// The [userId] parameter is the user ID to manage saved destinations for.

@ProviderFor(SavedDestinations)
const savedDestinationsProvider = SavedDestinationsFamily._();

/// Riverpod 3.0 Migration Notes:
/// - Converted from StateNotifier<AsyncValue<T>> to AsyncNotifier<T>
/// - Dependencies injected via ref.watch() in build() method
/// - Family provider with userId parameter in build()
/// - AutoDispose enabled via @Riverpod annotation
/// - build() returns Future<T> not AsyncValue<T>
/// - State is automatically AsyncValue<SavedDestinationsState> when consumed
/// - Constructor auto-load logic moved to build() method
///
/// Provider for saved destinations state management
///
/// This provider manages the state of user's saved destinations including:
/// - Wishlist and trip destinations
/// - Loading and error states
/// - Save/unsave operations
/// - Filtering by save type (wishlist or trip)
///
/// Riverpod 3.0: Uses @riverpod annotation with AsyncNotifier pattern.
/// Auto-dispose behavior for family provider.
///
/// Usage:
/// ```dart
/// final savedState = ref.watch(savedDestinationsProvider(userId));
/// final savedNotifier = ref.read(savedDestinationsProvider(userId).notifier);
///
/// // Load saved destinations (automatically called on first watch)
/// // The userId is passed as a parameter to the provider
///
/// // Save a destination to wishlist
/// await savedNotifier.saveDestination(
///   userId: userId,
///   destination: destination,
///   saveType: SaveType.wishlist,
/// );
///
/// // Unsave a destination
/// await savedNotifier.unsaveDestination(
///   userId: userId,
///   destinationId: destinationId,
/// );
///
/// // Refresh saved destinations
/// await savedNotifier.refresh();
/// ```
///
/// The [userId] parameter is the user ID to manage saved destinations for.
final class SavedDestinationsProvider
    extends $AsyncNotifierProvider<SavedDestinations, SavedDestinationsState> {
  /// Riverpod 3.0 Migration Notes:
  /// - Converted from StateNotifier<AsyncValue<T>> to AsyncNotifier<T>
  /// - Dependencies injected via ref.watch() in build() method
  /// - Family provider with userId parameter in build()
  /// - AutoDispose enabled via @Riverpod annotation
  /// - build() returns Future<T> not AsyncValue<T>
  /// - State is automatically AsyncValue<SavedDestinationsState> when consumed
  /// - Constructor auto-load logic moved to build() method
  ///
  /// Provider for saved destinations state management
  ///
  /// This provider manages the state of user's saved destinations including:
  /// - Wishlist and trip destinations
  /// - Loading and error states
  /// - Save/unsave operations
  /// - Filtering by save type (wishlist or trip)
  ///
  /// Riverpod 3.0: Uses @riverpod annotation with AsyncNotifier pattern.
  /// Auto-dispose behavior for family provider.
  ///
  /// Usage:
  /// ```dart
  /// final savedState = ref.watch(savedDestinationsProvider(userId));
  /// final savedNotifier = ref.read(savedDestinationsProvider(userId).notifier);
  ///
  /// // Load saved destinations (automatically called on first watch)
  /// // The userId is passed as a parameter to the provider
  ///
  /// // Save a destination to wishlist
  /// await savedNotifier.saveDestination(
  ///   userId: userId,
  ///   destination: destination,
  ///   saveType: SaveType.wishlist,
  /// );
  ///
  /// // Unsave a destination
  /// await savedNotifier.unsaveDestination(
  ///   userId: userId,
  ///   destinationId: destinationId,
  /// );
  ///
  /// // Refresh saved destinations
  /// await savedNotifier.refresh();
  /// ```
  ///
  /// The [userId] parameter is the user ID to manage saved destinations for.
  const SavedDestinationsProvider._(
      {required SavedDestinationsFamily super.from,
      required String super.argument})
      : super(
          retry: null,
          name: r'savedDestinationsProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$savedDestinationsHash();

  @override
  String toString() {
    return r'savedDestinationsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  SavedDestinations create() => SavedDestinations();

  @override
  bool operator ==(Object other) {
    return other is SavedDestinationsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$savedDestinationsHash() => r'e991f28dd18ca9ceddf424eab36ae2b547f1d655';

/// Riverpod 3.0 Migration Notes:
/// - Converted from StateNotifier<AsyncValue<T>> to AsyncNotifier<T>
/// - Dependencies injected via ref.watch() in build() method
/// - Family provider with userId parameter in build()
/// - AutoDispose enabled via @Riverpod annotation
/// - build() returns Future<T> not AsyncValue<T>
/// - State is automatically AsyncValue<SavedDestinationsState> when consumed
/// - Constructor auto-load logic moved to build() method
///
/// Provider for saved destinations state management
///
/// This provider manages the state of user's saved destinations including:
/// - Wishlist and trip destinations
/// - Loading and error states
/// - Save/unsave operations
/// - Filtering by save type (wishlist or trip)
///
/// Riverpod 3.0: Uses @riverpod annotation with AsyncNotifier pattern.
/// Auto-dispose behavior for family provider.
///
/// Usage:
/// ```dart
/// final savedState = ref.watch(savedDestinationsProvider(userId));
/// final savedNotifier = ref.read(savedDestinationsProvider(userId).notifier);
///
/// // Load saved destinations (automatically called on first watch)
/// // The userId is passed as a parameter to the provider
///
/// // Save a destination to wishlist
/// await savedNotifier.saveDestination(
///   userId: userId,
///   destination: destination,
///   saveType: SaveType.wishlist,
/// );
///
/// // Unsave a destination
/// await savedNotifier.unsaveDestination(
///   userId: userId,
///   destinationId: destinationId,
/// );
///
/// // Refresh saved destinations
/// await savedNotifier.refresh();
/// ```
///
/// The [userId] parameter is the user ID to manage saved destinations for.

final class SavedDestinationsFamily extends $Family
    with
        $ClassFamilyOverride<
            SavedDestinations,
            AsyncValue<SavedDestinationsState>,
            SavedDestinationsState,
            FutureOr<SavedDestinationsState>,
            String> {
  const SavedDestinationsFamily._()
      : super(
          retry: null,
          name: r'savedDestinationsProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: true,
        );

  /// Riverpod 3.0 Migration Notes:
  /// - Converted from StateNotifier<AsyncValue<T>> to AsyncNotifier<T>
  /// - Dependencies injected via ref.watch() in build() method
  /// - Family provider with userId parameter in build()
  /// - AutoDispose enabled via @Riverpod annotation
  /// - build() returns Future<T> not AsyncValue<T>
  /// - State is automatically AsyncValue<SavedDestinationsState> when consumed
  /// - Constructor auto-load logic moved to build() method
  ///
  /// Provider for saved destinations state management
  ///
  /// This provider manages the state of user's saved destinations including:
  /// - Wishlist and trip destinations
  /// - Loading and error states
  /// - Save/unsave operations
  /// - Filtering by save type (wishlist or trip)
  ///
  /// Riverpod 3.0: Uses @riverpod annotation with AsyncNotifier pattern.
  /// Auto-dispose behavior for family provider.
  ///
  /// Usage:
  /// ```dart
  /// final savedState = ref.watch(savedDestinationsProvider(userId));
  /// final savedNotifier = ref.read(savedDestinationsProvider(userId).notifier);
  ///
  /// // Load saved destinations (automatically called on first watch)
  /// // The userId is passed as a parameter to the provider
  ///
  /// // Save a destination to wishlist
  /// await savedNotifier.saveDestination(
  ///   userId: userId,
  ///   destination: destination,
  ///   saveType: SaveType.wishlist,
  /// );
  ///
  /// // Unsave a destination
  /// await savedNotifier.unsaveDestination(
  ///   userId: userId,
  ///   destinationId: destinationId,
  /// );
  ///
  /// // Refresh saved destinations
  /// await savedNotifier.refresh();
  /// ```
  ///
  /// The [userId] parameter is the user ID to manage saved destinations for.

  SavedDestinationsProvider call(
    String userId,
  ) =>
      SavedDestinationsProvider._(argument: userId, from: this);

  @override
  String toString() => r'savedDestinationsProvider';
}

/// Riverpod 3.0 Migration Notes:
/// - Converted from StateNotifier<AsyncValue<T>> to AsyncNotifier<T>
/// - Dependencies injected via ref.watch() in build() method
/// - Family provider with userId parameter in build()
/// - AutoDispose enabled via @Riverpod annotation
/// - build() returns Future<T> not AsyncValue<T>
/// - State is automatically AsyncValue<SavedDestinationsState> when consumed
/// - Constructor auto-load logic moved to build() method
///
/// Provider for saved destinations state management
///
/// This provider manages the state of user's saved destinations including:
/// - Wishlist and trip destinations
/// - Loading and error states
/// - Save/unsave operations
/// - Filtering by save type (wishlist or trip)
///
/// Riverpod 3.0: Uses @riverpod annotation with AsyncNotifier pattern.
/// Auto-dispose behavior for family provider.
///
/// Usage:
/// ```dart
/// final savedState = ref.watch(savedDestinationsProvider(userId));
/// final savedNotifier = ref.read(savedDestinationsProvider(userId).notifier);
///
/// // Load saved destinations (automatically called on first watch)
/// // The userId is passed as a parameter to the provider
///
/// // Save a destination to wishlist
/// await savedNotifier.saveDestination(
///   userId: userId,
///   destination: destination,
///   saveType: SaveType.wishlist,
/// );
///
/// // Unsave a destination
/// await savedNotifier.unsaveDestination(
///   userId: userId,
///   destinationId: destinationId,
/// );
///
/// // Refresh saved destinations
/// await savedNotifier.refresh();
/// ```
///
/// The [userId] parameter is the user ID to manage saved destinations for.

abstract class _$SavedDestinations
    extends $AsyncNotifier<SavedDestinationsState> {
  late final _$args = ref.$arg as String;
  String get userId => _$args;

  FutureOr<SavedDestinationsState> build(
    String userId,
  );
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build(
      _$args,
    );
    final ref = this.ref
        as $Ref<AsyncValue<SavedDestinationsState>, SavedDestinationsState>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<AsyncValue<SavedDestinationsState>, SavedDestinationsState>,
        AsyncValue<SavedDestinationsState>,
        Object?,
        Object?>;
    element.handleValue(ref, created);
  }
}
