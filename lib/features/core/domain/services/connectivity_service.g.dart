// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'connectivity_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provider for the connectivity service implementation

@ProviderFor(connectivityService)
const connectivityServiceProvider = ConnectivityServiceProvider._();

/// Provider for the connectivity service implementation

final class ConnectivityServiceProvider extends $FunctionalProvider<
    ConnectivityService,
    ConnectivityService,
    ConnectivityService> with $Provider<ConnectivityService> {
  /// Provider for the connectivity service implementation
  const ConnectivityServiceProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'connectivityServiceProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$connectivityServiceHash();

  @$internal
  @override
  $ProviderElement<ConnectivityService> $createElement(
          $ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  ConnectivityService create(Ref ref) {
    return connectivityService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ConnectivityService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ConnectivityService>(value),
    );
  }
}

String _$connectivityServiceHash() =>
    r'811bf8f1e3129c38cf832dc965131ce338ce74e3';

/// Provider that exposes the current network status

@ProviderFor(NetworkStatusNotifier)
const networkStatusProvider = NetworkStatusNotifierProvider._();

/// Provider that exposes the current network status
final class NetworkStatusNotifierProvider
    extends $AsyncNotifierProvider<NetworkStatusNotifier, NetworkStatus> {
  /// Provider that exposes the current network status
  const NetworkStatusNotifierProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'networkStatusProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$networkStatusNotifierHash();

  @$internal
  @override
  NetworkStatusNotifier create() => NetworkStatusNotifier();
}

String _$networkStatusNotifierHash() =>
    r'9e5d0d4958a6e4fe31c8dbcf4fc4c90ba35c0993';

/// Provider that exposes the current network status

abstract class _$NetworkStatusNotifier extends $AsyncNotifier<NetworkStatus> {
  FutureOr<NetworkStatus> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<AsyncValue<NetworkStatus>, NetworkStatus>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<AsyncValue<NetworkStatus>, NetworkStatus>,
        AsyncValue<NetworkStatus>,
        Object?,
        Object?>;
    element.handleValue(ref, created);
  }
}
