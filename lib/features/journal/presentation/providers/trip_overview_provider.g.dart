// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'trip_overview_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Notifier for managing trip overview state
/// MIGRATION: StateNotifier → Notifier pattern with family parameter
/// - tripId is passed as a parameter to the build() method (family provider)
/// - Dependencies accessed via ref.watch() in methods
/// - Automatic provider generation via @riverpod annotation
/// Usage: ref.watch(tripOverviewProvider(tripId))

@ProviderFor(TripOverview)
const tripOverviewProvider = TripOverviewFamily._();

/// Notifier for managing trip overview state
/// MIGRATION: StateNotifier → Notifier pattern with family parameter
/// - tripId is passed as a parameter to the build() method (family provider)
/// - Dependencies accessed via ref.watch() in methods
/// - Automatic provider generation via @riverpod annotation
/// Usage: ref.watch(tripOverviewProvider(tripId))
final class TripOverviewProvider
    extends $NotifierProvider<TripOverview, TripOverviewState> {
  /// Notifier for managing trip overview state
  /// MIGRATION: StateNotifier → Notifier pattern with family parameter
  /// - tripId is passed as a parameter to the build() method (family provider)
  /// - Dependencies accessed via ref.watch() in methods
  /// - Automatic provider generation via @riverpod annotation
  /// Usage: ref.watch(tripOverviewProvider(tripId))
  const TripOverviewProvider._(
      {required TripOverviewFamily super.from, required String super.argument})
      : super(
          retry: null,
          name: r'tripOverviewProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$tripOverviewHash();

  @override
  String toString() {
    return r'tripOverviewProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  TripOverview create() => TripOverview();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(TripOverviewState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<TripOverviewState>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is TripOverviewProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$tripOverviewHash() => r'1a5fd65f28e15697ef0759191e41693aa05c5b14';

/// Notifier for managing trip overview state
/// MIGRATION: StateNotifier → Notifier pattern with family parameter
/// - tripId is passed as a parameter to the build() method (family provider)
/// - Dependencies accessed via ref.watch() in methods
/// - Automatic provider generation via @riverpod annotation
/// Usage: ref.watch(tripOverviewProvider(tripId))

final class TripOverviewFamily extends $Family
    with
        $ClassFamilyOverride<TripOverview, TripOverviewState, TripOverviewState,
            TripOverviewState, String> {
  const TripOverviewFamily._()
      : super(
          retry: null,
          name: r'tripOverviewProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: true,
        );

  /// Notifier for managing trip overview state
  /// MIGRATION: StateNotifier → Notifier pattern with family parameter
  /// - tripId is passed as a parameter to the build() method (family provider)
  /// - Dependencies accessed via ref.watch() in methods
  /// - Automatic provider generation via @riverpod annotation
  /// Usage: ref.watch(tripOverviewProvider(tripId))

  TripOverviewProvider call(
    String tripId,
  ) =>
      TripOverviewProvider._(argument: tripId, from: this);

  @override
  String toString() => r'tripOverviewProvider';
}

/// Notifier for managing trip overview state
/// MIGRATION: StateNotifier → Notifier pattern with family parameter
/// - tripId is passed as a parameter to the build() method (family provider)
/// - Dependencies accessed via ref.watch() in methods
/// - Automatic provider generation via @riverpod annotation
/// Usage: ref.watch(tripOverviewProvider(tripId))

abstract class _$TripOverview extends $Notifier<TripOverviewState> {
  late final _$args = ref.$arg as String;
  String get tripId => _$args;

  TripOverviewState build(
    String tripId,
  );
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build(
      _$args,
    );
    final ref = this.ref as $Ref<TripOverviewState, TripOverviewState>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<TripOverviewState, TripOverviewState>,
        TripOverviewState,
        Object?,
        Object?>;
    element.handleValue(ref, created);
  }
}
