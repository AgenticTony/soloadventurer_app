// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'trip_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provider for user's trips

@ProviderFor(userTrips)
const userTripsProvider = UserTripsProvider._();

/// Provider for user's trips

final class UserTripsProvider extends $FunctionalProvider<
        AsyncValue<List<MatchingTrip>>,
        List<MatchingTrip>,
        FutureOr<List<MatchingTrip>>>
    with
        $FutureModifier<List<MatchingTrip>>,
        $FutureProvider<List<MatchingTrip>> {
  /// Provider for user's trips
  const UserTripsProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'userTripsProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$userTripsHash();

  @$internal
  @override
  $FutureProviderElement<List<MatchingTrip>> $createElement(
          $ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<List<MatchingTrip>> create(Ref ref) {
    return userTrips(ref);
  }
}

String _$userTripsHash() => r'291139271bf29b84ffb17e4a915d2ba6ea4536b3';

/// Provider for active trips (currently happening or future)

@ProviderFor(activeTrips)
const activeTripsProvider = ActiveTripsProvider._();

/// Provider for active trips (currently happening or future)

final class ActiveTripsProvider extends $FunctionalProvider<
        AsyncValue<List<MatchingTrip>>,
        List<MatchingTrip>,
        FutureOr<List<MatchingTrip>>>
    with
        $FutureModifier<List<MatchingTrip>>,
        $FutureProvider<List<MatchingTrip>> {
  /// Provider for active trips (currently happening or future)
  const ActiveTripsProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'activeTripsProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$activeTripsHash();

  @$internal
  @override
  $FutureProviderElement<List<MatchingTrip>> $createElement(
          $ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<List<MatchingTrip>> create(Ref ref) {
    return activeTrips(ref);
  }
}

String _$activeTripsHash() => r'0c45f3eb1d714b219ec45b29c01aec495641ff27';

/// Provider for a specific trip by ID

@ProviderFor(tripById)
const tripByIdProvider = TripByIdFamily._();

/// Provider for a specific trip by ID

final class TripByIdProvider extends $FunctionalProvider<
        AsyncValue<MatchingTrip?>, MatchingTrip?, FutureOr<MatchingTrip?>>
    with $FutureModifier<MatchingTrip?>, $FutureProvider<MatchingTrip?> {
  /// Provider for a specific trip by ID
  const TripByIdProvider._(
      {required TripByIdFamily super.from, required String super.argument})
      : super(
          retry: null,
          name: r'tripByIdProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$tripByIdHash();

  @override
  String toString() {
    return r'tripByIdProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<MatchingTrip?> $createElement(
          $ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<MatchingTrip?> create(Ref ref) {
    final argument = this.argument as String;
    return tripById(
      ref,
      argument,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is TripByIdProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$tripByIdHash() => r'b95fbb53a37c624dc191dad771a3f1051c9dd9b1';

/// Provider for a specific trip by ID

final class TripByIdFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<MatchingTrip?>, String> {
  const TripByIdFamily._()
      : super(
          retry: null,
          name: r'tripByIdProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: false,
        );

  /// Provider for a specific trip by ID

  TripByIdProvider call(
    String tripId,
  ) =>
      TripByIdProvider._(argument: tripId, from: this);

  @override
  String toString() => r'tripByIdProvider';
}

/// Notifier for managing trip CRUD operations

@ProviderFor(TripNotifier)
const tripProvider = TripNotifierProvider._();

/// Notifier for managing trip CRUD operations
final class TripNotifierProvider
    extends $AsyncNotifierProvider<TripNotifier, void> {
  /// Notifier for managing trip CRUD operations
  const TripNotifierProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'tripProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$tripNotifierHash();

  @$internal
  @override
  TripNotifier create() => TripNotifier();
}

String _$tripNotifierHash() => r'd1a7534f292c1bc09252d0eaa65e50d8cf86016b';

/// Notifier for managing trip CRUD operations

abstract class _$TripNotifier extends $AsyncNotifier<void> {
  FutureOr<void> build();
  @$mustCallSuper
  @override
  void runBuild() {
    build();
    final ref = this.ref as $Ref<AsyncValue<void>, void>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<AsyncValue<void>, void>,
        AsyncValue<void>,
        Object?,
        Object?>;
    element.handleValue(ref, null);
  }
}
