// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'connectivity_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provider for the connectivity service implementation

@ProviderFor(connectivityService)
final connectivityServiceProvider = ConnectivityServiceProvider._();

/// Provider for the connectivity service implementation

final class ConnectivityServiceProvider extends $FunctionalProvider<
    ConnectivityService,
    ConnectivityService,
    ConnectivityService> with $Provider<ConnectivityService> {
  /// Provider for the connectivity service implementation
  ConnectivityServiceProvider._()
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
    r'5b7e4948cef2ab1c6394bec82a52f9b8b8c94263';

/// Provider that exposes the current network status

@ProviderFor(NetworkStatusNotifier)
final networkStatusProvider = NetworkStatusNotifierProvider._();

/// Provider that exposes the current network status
final class NetworkStatusNotifierProvider
    extends $AsyncNotifierProvider<NetworkStatusNotifier, NetworkStatus> {
  /// Provider that exposes the current network status
  NetworkStatusNotifierProvider._()
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
    final ref = this.ref as $Ref<AsyncValue<NetworkStatus>, NetworkStatus>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<AsyncValue<NetworkStatus>, NetworkStatus>,
        AsyncValue<NetworkStatus>,
        Object?,
        Object?>;
    element.handleCreate(ref, build);
  }
}
