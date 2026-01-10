// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'destination_detail_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
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

@ProviderFor(DestinationDetail)
final destinationDetailProvider = DestinationDetailFamily._();

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
final class DestinationDetailProvider
    extends $AsyncNotifierProvider<DestinationDetail, DestinationDetailState> {
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
  DestinationDetailProvider._(
      {required DestinationDetailFamily super.from,
      required String super.argument})
      : super(
          retry: null,
          name: r'destinationDetailProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$destinationDetailHash();

  @override
  String toString() {
    return r'destinationDetailProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  DestinationDetail create() => DestinationDetail();

  @override
  bool operator ==(Object other) {
    return other is DestinationDetailProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$destinationDetailHash() => r'd6dbff7fc3b2ffa79e4897564edf4f4d37ad2cdb';

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

final class DestinationDetailFamily extends $Family
    with
        $ClassFamilyOverride<
            DestinationDetail,
            AsyncValue<DestinationDetailState>,
            DestinationDetailState,
            FutureOr<DestinationDetailState>,
            String> {
  DestinationDetailFamily._()
      : super(
          retry: null,
          name: r'destinationDetailProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: true,
        );

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

  DestinationDetailProvider call(
    String destinationId,
  ) =>
      DestinationDetailProvider._(argument: destinationId, from: this);

  @override
  String toString() => r'destinationDetailProvider';
}

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

abstract class _$DestinationDetail
    extends $AsyncNotifier<DestinationDetailState> {
  late final _$args = ref.$arg as String;
  String get destinationId => _$args;

  FutureOr<DestinationDetailState> build(
    String destinationId,
  );
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref
        as $Ref<AsyncValue<DestinationDetailState>, DestinationDetailState>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<AsyncValue<DestinationDetailState>, DestinationDetailState>,
        AsyncValue<DestinationDetailState>,
        Object?,
        Object?>;
    element.handleCreate(
        ref,
        () => build(
              _$args,
            ));
  }
}
