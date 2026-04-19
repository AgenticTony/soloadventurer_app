// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'connection_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provider for matches/connections

@ProviderFor(matches)
const matchesProvider = MatchesProvider._();

/// Provider for matches/connections

final class MatchesProvider extends $FunctionalProvider<
        AsyncValue<List<Connection>>,
        List<Connection>,
        FutureOr<List<Connection>>>
    with $FutureModifier<List<Connection>>, $FutureProvider<List<Connection>> {
  /// Provider for matches/connections
  const MatchesProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'matchesProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$matchesHash();

  @$internal
  @override
  $FutureProviderElement<List<Connection>> $createElement(
          $ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<List<Connection>> create(Ref ref) {
    return matches(ref);
  }
}

String _$matchesHash() => r'555081db42de2dc82497ca8eeb8fd7945baf2904';

/// Provider for all connections (including hidden/blocked)

@ProviderFor(connections)
const connectionsProvider = ConnectionsProvider._();

/// Provider for all connections (including hidden/blocked)

final class ConnectionsProvider extends $FunctionalProvider<
        AsyncValue<List<Connection>>,
        List<Connection>,
        FutureOr<List<Connection>>>
    with $FutureModifier<List<Connection>>, $FutureProvider<List<Connection>> {
  /// Provider for all connections (including hidden/blocked)
  const ConnectionsProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'connectionsProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$connectionsHash();

  @$internal
  @override
  $FutureProviderElement<List<Connection>> $createElement(
          $ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<List<Connection>> create(Ref ref) {
    return connections(ref);
  }
}

String _$connectionsHash() => r'83185425c30abefde62efe8daa8408c4c7187857';

/// Provider for active matches count (for badges, etc.)

@ProviderFor(activeMatchesCount)
const activeMatchesCountProvider = ActiveMatchesCountProvider._();

/// Provider for active matches count (for badges, etc.)

final class ActiveMatchesCountProvider
    extends $FunctionalProvider<AsyncValue<int>, int, FutureOr<int>>
    with $FutureModifier<int>, $FutureProvider<int> {
  /// Provider for active matches count (for badges, etc.)
  const ActiveMatchesCountProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'activeMatchesCountProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$activeMatchesCountHash();

  @$internal
  @override
  $FutureProviderElement<int> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<int> create(Ref ref) {
    return activeMatchesCount(ref);
  }
}

String _$activeMatchesCountHash() =>
    r'67bebc5ceb1ab25f0c34c5f01feeb6cf0fe6413c';

/// Provider for pending matches count

@ProviderFor(pendingMatchesCount)
const pendingMatchesCountProvider = PendingMatchesCountProvider._();

/// Provider for pending matches count

final class PendingMatchesCountProvider
    extends $FunctionalProvider<AsyncValue<int>, int, FutureOr<int>>
    with $FutureModifier<int>, $FutureProvider<int> {
  /// Provider for pending matches count
  const PendingMatchesCountProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'pendingMatchesCountProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$pendingMatchesCountHash();

  @$internal
  @override
  $FutureProviderElement<int> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<int> create(Ref ref) {
    return pendingMatchesCount(ref);
  }
}

String _$pendingMatchesCountHash() =>
    r'ed3dda214cb6e052337d9bd2d376e42addbcfa58';

/// Provider for nearby travelers count

@ProviderFor(nearbyTravelersCount)
const nearbyTravelersCountProvider = NearbyTravelersCountProvider._();

/// Provider for nearby travelers count

final class NearbyTravelersCountProvider
    extends $FunctionalProvider<AsyncValue<int>, int, FutureOr<int>>
    with $FutureModifier<int>, $FutureProvider<int> {
  /// Provider for nearby travelers count
  const NearbyTravelersCountProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'nearbyTravelersCountProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$nearbyTravelersCountHash();

  @$internal
  @override
  $FutureProviderElement<int> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<int> create(Ref ref) {
    return nearbyTravelersCount(ref);
  }
}

String _$nearbyTravelersCountHash() =>
    r'3182de3887b0164c52ee63a87e7f05b834d9cfeb';

/// Notifier for managing connections

@ProviderFor(ConnectionNotifier)
const connectionProvider = ConnectionNotifierProvider._();

/// Notifier for managing connections
final class ConnectionNotifierProvider
    extends $AsyncNotifierProvider<ConnectionNotifier, void> {
  /// Notifier for managing connections
  const ConnectionNotifierProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'connectionProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$connectionNotifierHash();

  @$internal
  @override
  ConnectionNotifier create() => ConnectionNotifier();
}

String _$connectionNotifierHash() =>
    r'3fd46ba88cb8e2d4cb7155f64981ccd85faa8694';

/// Notifier for managing connections

abstract class _$ConnectionNotifier extends $AsyncNotifier<void> {
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
