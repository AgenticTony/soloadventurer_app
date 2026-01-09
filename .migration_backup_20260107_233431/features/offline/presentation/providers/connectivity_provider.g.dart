// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'connectivity_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Re-export of connectivityServiceProvider from app/providers/offline_service_providers.dart
/// This maintains backward compatibility for existing imports
// The connectivityServiceProvider is now defined in app/providers/offline_service_providers.dart
/// Notifier for managing connectivity state

@ProviderFor(ConnectivityNotifier)
final connectivityProvider = ConnectivityNotifierProvider._();

/// Re-export of connectivityServiceProvider from app/providers/offline_service_providers.dart
/// This maintains backward compatibility for existing imports
// The connectivityServiceProvider is now defined in app/providers/offline_service_providers.dart
/// Notifier for managing connectivity state
final class ConnectivityNotifierProvider
    extends $NotifierProvider<ConnectivityNotifier, ConnectivityState> {
  /// Re-export of connectivityServiceProvider from app/providers/offline_service_providers.dart
  /// This maintains backward compatibility for existing imports
// The connectivityServiceProvider is now defined in app/providers/offline_service_providers.dart
  /// Notifier for managing connectivity state
  ConnectivityNotifierProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'connectivityProvider',
          isAutoDispose: false,
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
    r'd481a2ff3feeedc77c95b442c500bf8bb4e22903';

/// Re-export of connectivityServiceProvider from app/providers/offline_service_providers.dart
/// This maintains backward compatibility for existing imports
// The connectivityServiceProvider is now defined in app/providers/offline_service_providers.dart
/// Notifier for managing connectivity state

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
