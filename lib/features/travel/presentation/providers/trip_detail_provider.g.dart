// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'trip_detail_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Riverpod 3.0 Migration Notes:
/// - Converted from StateNotifier to @riverpod Notifier
/// - Dependencies injected via ref.watch() in build() method
/// - Family provider with tripId parameter in build()
/// - Initialization logic moved from constructor to build() method
///
/// Provider for the destination repository from the destination discovery feature

@ProviderFor(tripDestinationRepository)
final tripDestinationRepositoryProvider = TripDestinationRepositoryProvider._();

/// Riverpod 3.0 Migration Notes:
/// - Converted from StateNotifier to @riverpod Notifier
/// - Dependencies injected via ref.watch() in build() method
/// - Family provider with tripId parameter in build()
/// - Initialization logic moved from constructor to build() method
///
/// Provider for the destination repository from the destination discovery feature

final class TripDestinationRepositoryProvider extends $FunctionalProvider<
    DestinationRepository,
    DestinationRepository,
    DestinationRepository> with $Provider<DestinationRepository> {
  /// Riverpod 3.0 Migration Notes:
  /// - Converted from StateNotifier to @riverpod Notifier
  /// - Dependencies injected via ref.watch() in build() method
  /// - Family provider with tripId parameter in build()
  /// - Initialization logic moved from constructor to build() method
  ///
  /// Provider for the destination repository from the destination discovery feature
  TripDestinationRepositoryProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'tripDestinationRepositoryProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$tripDestinationRepositoryHash();

  @$internal
  @override
  $ProviderElement<DestinationRepository> $createElement(
          $ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  DestinationRepository create(Ref ref) {
    return tripDestinationRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DestinationRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DestinationRepository>(value),
    );
  }
}

String _$tripDestinationRepositoryHash() =>
    r'1712a1bbf95a0f5516e834ad97e9b298285f4c63';

/// Provider for managing trip detail state
///
/// This provider manages the state of a trip detail view, including
/// the trip data and the destinations from the discovery feature.
///
/// Riverpod 3.0: Uses @riverpod annotation with family provider pattern.
/// The tripId parameter is passed to the build() method.
///
/// Usage:
/// ```dart
/// final tripDetailState = ref.watch(tripDetailProvider(tripId));
/// final tripDetailNotifier = ref.read(tripDetailProvider(tripId).notifier);
///
/// // Load trip data
/// await tripDetailNotifier.loadTrip(trip);
///
/// // Refresh trip data
/// await tripDetailNotifier.refresh();
/// ```

@ProviderFor(TripDetail)
final tripDetailProvider = TripDetailFamily._();

/// Provider for managing trip detail state
///
/// This provider manages the state of a trip detail view, including
/// the trip data and the destinations from the discovery feature.
///
/// Riverpod 3.0: Uses @riverpod annotation with family provider pattern.
/// The tripId parameter is passed to the build() method.
///
/// Usage:
/// ```dart
/// final tripDetailState = ref.watch(tripDetailProvider(tripId));
/// final tripDetailNotifier = ref.read(tripDetailProvider(tripId).notifier);
///
/// // Load trip data
/// await tripDetailNotifier.loadTrip(trip);
///
/// // Refresh trip data
/// await tripDetailNotifier.refresh();
/// ```
final class TripDetailProvider
    extends $NotifierProvider<TripDetail, TripDetailState> {
  /// Provider for managing trip detail state
  ///
  /// This provider manages the state of a trip detail view, including
  /// the trip data and the destinations from the discovery feature.
  ///
  /// Riverpod 3.0: Uses @riverpod annotation with family provider pattern.
  /// The tripId parameter is passed to the build() method.
  ///
  /// Usage:
  /// ```dart
  /// final tripDetailState = ref.watch(tripDetailProvider(tripId));
  /// final tripDetailNotifier = ref.read(tripDetailProvider(tripId).notifier);
  ///
  /// // Load trip data
  /// await tripDetailNotifier.loadTrip(trip);
  ///
  /// // Refresh trip data
  /// await tripDetailNotifier.refresh();
  /// ```
  TripDetailProvider._(
      {required TripDetailFamily super.from, required String super.argument})
      : super(
          retry: null,
          name: r'tripDetailProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$tripDetailHash();

  @override
  String toString() {
    return r'tripDetailProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  TripDetail create() => TripDetail();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(TripDetailState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<TripDetailState>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is TripDetailProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$tripDetailHash() => r'48311977bfc93d3a011cc58943641da7564938cd';

/// Provider for managing trip detail state
///
/// This provider manages the state of a trip detail view, including
/// the trip data and the destinations from the discovery feature.
///
/// Riverpod 3.0: Uses @riverpod annotation with family provider pattern.
/// The tripId parameter is passed to the build() method.
///
/// Usage:
/// ```dart
/// final tripDetailState = ref.watch(tripDetailProvider(tripId));
/// final tripDetailNotifier = ref.read(tripDetailProvider(tripId).notifier);
///
/// // Load trip data
/// await tripDetailNotifier.loadTrip(trip);
///
/// // Refresh trip data
/// await tripDetailNotifier.refresh();
/// ```

final class TripDetailFamily extends $Family
    with
        $ClassFamilyOverride<TripDetail, TripDetailState, TripDetailState,
            TripDetailState, String> {
  TripDetailFamily._()
      : super(
          retry: null,
          name: r'tripDetailProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: true,
        );

  /// Provider for managing trip detail state
  ///
  /// This provider manages the state of a trip detail view, including
  /// the trip data and the destinations from the discovery feature.
  ///
  /// Riverpod 3.0: Uses @riverpod annotation with family provider pattern.
  /// The tripId parameter is passed to the build() method.
  ///
  /// Usage:
  /// ```dart
  /// final tripDetailState = ref.watch(tripDetailProvider(tripId));
  /// final tripDetailNotifier = ref.read(tripDetailProvider(tripId).notifier);
  ///
  /// // Load trip data
  /// await tripDetailNotifier.loadTrip(trip);
  ///
  /// // Refresh trip data
  /// await tripDetailNotifier.refresh();
  /// ```

  TripDetailProvider call(
    String tripId,
  ) =>
      TripDetailProvider._(argument: tripId, from: this);

  @override
  String toString() => r'tripDetailProvider';
}

/// Provider for managing trip detail state
///
/// This provider manages the state of a trip detail view, including
/// the trip data and the destinations from the discovery feature.
///
/// Riverpod 3.0: Uses @riverpod annotation with family provider pattern.
/// The tripId parameter is passed to the build() method.
///
/// Usage:
/// ```dart
/// final tripDetailState = ref.watch(tripDetailProvider(tripId));
/// final tripDetailNotifier = ref.read(tripDetailProvider(tripId).notifier);
///
/// // Load trip data
/// await tripDetailNotifier.loadTrip(trip);
///
/// // Refresh trip data
/// await tripDetailNotifier.refresh();
/// ```

abstract class _$TripDetail extends $Notifier<TripDetailState> {
  late final _$args = ref.$arg as String;
  String get tripId => _$args;

  TripDetailState build(
    String tripId,
  );
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<TripDetailState, TripDetailState>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<TripDetailState, TripDetailState>,
        TripDetailState,
        Object?,
        Object?>;
    element.handleCreate(
        ref,
        () => build(
              _$args,
            ));
  }
}
