// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'connectivity_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(connectivityService)
final connectivityServiceProvider = ConnectivityServiceProvider._();

final class ConnectivityServiceProvider extends $FunctionalProvider<
    ConnectivityService,
    ConnectivityService,
    ConnectivityService> with $Provider<ConnectivityService> {
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
    r'6176a137dc83b81479363eb81f447438e9e20df4';

@ProviderFor(ConnectivityNotifier)
final connectivityProvider = ConnectivityNotifierProvider._();

final class ConnectivityNotifierProvider
    extends $NotifierProvider<ConnectivityNotifier, ConnectivityState> {
  ConnectivityNotifierProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'connectivityProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$connectivityNotifierHash();

  @$internal
  @override
  ConnectivityNotifier create() => ConnectivityNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ConnectivityState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ConnectivityState>(value),
    );
  }
}

String _$connectivityNotifierHash() =>
    r'9e3b58289adc7ceb4a01d5fcf242c287328e47ec';

abstract class _$ConnectivityNotifier extends $Notifier<ConnectivityState> {
  ConnectivityState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<ConnectivityState, ConnectivityState>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<ConnectivityState, ConnectivityState>,
        ConnectivityState,
        Object?,
        Object?>;
    element.handleCreate(ref, build);
  }
}

/// Selector provider for connection status

@ProviderFor(isConnected)
final isConnectedProvider = IsConnectedProvider._();

/// Selector provider for connection status

final class IsConnectedProvider extends $FunctionalProvider<bool, bool, bool>
    with $Provider<bool> {
  /// Selector provider for connection status
  IsConnectedProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'isConnectedProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$isConnectedHash();

  @$internal
  @override
  $ProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  bool create(Ref ref) {
    return isConnected(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$isConnectedHash() => r'db7edf9daf8e02d7f84bc136be7109023f299b76';

/// Selector provider for connection type

@ProviderFor(connectionType)
final connectionTypeProvider = ConnectionTypeProvider._();

/// Selector provider for connection type

final class ConnectionTypeProvider
    extends $FunctionalProvider<ConnectionType, ConnectionType, ConnectionType>
    with $Provider<ConnectionType> {
  /// Selector provider for connection type
  ConnectionTypeProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'connectionTypeProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$connectionTypeHash();

  @$internal
  @override
  $ProviderElement<ConnectionType> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  ConnectionType create(Ref ref) {
    return connectionType(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ConnectionType value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ConnectionType>(value),
    );
  }
}

String _$connectionTypeHash() => r'4dd371882a90d1510affd54102b374fc4f1edfe5';

/// Selector provider for offline status

@ProviderFor(isOffline)
final isOfflineProvider = IsOfflineProvider._();

/// Selector provider for offline status

final class IsOfflineProvider extends $FunctionalProvider<bool, bool, bool>
    with $Provider<bool> {
  /// Selector provider for offline status
  IsOfflineProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'isOfflineProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$isOfflineHash();

  @$internal
  @override
  $ProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  bool create(Ref ref) {
    return isOffline(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$isOfflineHash() => r'f585bdcb0492b7db96063b2cd0b4e53076c1a6b3';
