// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sync_status_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Re-export of syncManagerProvider from app/providers/offline_service_providers.dart
/// The syncManagerProvider is now defined in app/providers/offline_service_providers.dart
/// Provider for sync status stream

@ProviderFor(syncStatusStream)
final syncStatusStreamProvider = SyncStatusStreamProvider._();

/// Re-export of syncManagerProvider from app/providers/offline_service_providers.dart
/// The syncManagerProvider is now defined in app/providers/offline_service_providers.dart
/// Provider for sync status stream

final class SyncStatusStreamProvider extends $FunctionalProvider<
        AsyncValue<SyncStatus>, SyncStatus, Stream<SyncStatus>>
    with $FutureModifier<SyncStatus>, $StreamProvider<SyncStatus> {
  /// Re-export of syncManagerProvider from app/providers/offline_service_providers.dart
  /// The syncManagerProvider is now defined in app/providers/offline_service_providers.dart
  /// Provider for sync status stream
  SyncStatusStreamProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'syncStatusStreamProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$syncStatusStreamHash();

  @$internal
  @override
  $StreamProviderElement<SyncStatus> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<SyncStatus> create(Ref ref) {
    return syncStatusStream(ref);
  }
}

String _$syncStatusStreamHash() => r'465783115fc5580afd5e794432f4a3926e9c9484';

/// Notifier for managing sync status state

@ProviderFor(SyncStatusNotifier)
final syncStatusProvider = SyncStatusNotifierProvider._();

/// Notifier for managing sync status state
final class SyncStatusNotifierProvider
    extends $NotifierProvider<SyncStatusNotifier, SyncStatus> {
  /// Notifier for managing sync status state
  SyncStatusNotifierProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'syncStatusProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$syncStatusNotifierHash();

  @$internal
  @override
  SyncStatusNotifier create() => SyncStatusNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SyncStatus value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SyncStatus>(value),
    );
  }
}

String _$syncStatusNotifierHash() =>
    r'47e853aa68c27e392030b28f24c0a2c09d5f6511';

/// Notifier for managing sync status state

abstract class _$SyncStatusNotifier extends $Notifier<SyncStatus> {
  SyncStatus build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<SyncStatus, SyncStatus>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<SyncStatus, SyncStatus>, SyncStatus, Object?, Object?>;
    element.handleCreate(ref, build);
  }
}

/// Selector provider for sync state enum

@ProviderFor(syncState)
final syncStateProvider = SyncStateProvider._();

/// Selector provider for sync state enum

final class SyncStateProvider
    extends $FunctionalProvider<SyncState, SyncState, SyncState>
    with $Provider<SyncState> {
  /// Selector provider for sync state enum
  SyncStateProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'syncStateProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$syncStateHash();

  @$internal
  @override
  $ProviderElement<SyncState> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  SyncState create(Ref ref) {
    return syncState(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SyncState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SyncState>(value),
    );
  }
}

String _$syncStateHash() => r'0d179a69b30cfa807eda6045de7ee6a6c036c458';

/// Selector provider for is syncing status

@ProviderFor(isSyncing)
final isSyncingProvider = IsSyncingProvider._();

/// Selector provider for is syncing status

final class IsSyncingProvider extends $FunctionalProvider<bool, bool, bool>
    with $Provider<bool> {
  /// Selector provider for is syncing status
  IsSyncingProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'isSyncingProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$isSyncingHash();

  @$internal
  @override
  $ProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  bool create(Ref ref) {
    return isSyncing(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$isSyncingHash() => r'23970d11b239f5c140a7d1196a852034890b16fb';

/// Selector provider for sync progress

@ProviderFor(syncProgress)
final syncProgressProvider = SyncProgressProvider._();

/// Selector provider for sync progress

final class SyncProgressProvider
    extends $FunctionalProvider<double, double, double> with $Provider<double> {
  /// Selector provider for sync progress
  SyncProgressProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'syncProgressProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$syncProgressHash();

  @$internal
  @override
  $ProviderElement<double> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  double create(Ref ref) {
    return syncProgress(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(double value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<double>(value),
    );
  }
}

String _$syncProgressHash() => r'c67cff3a3dc8370fd9d30951617938b1899508ef';

/// Selector provider for sync phase

@ProviderFor(syncPhase)
final syncPhaseProvider = SyncPhaseProvider._();

/// Selector provider for sync phase

final class SyncPhaseProvider
    extends $FunctionalProvider<SyncPhase, SyncPhase, SyncPhase>
    with $Provider<SyncPhase> {
  /// Selector provider for sync phase
  SyncPhaseProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'syncPhaseProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$syncPhaseHash();

  @$internal
  @override
  $ProviderElement<SyncPhase> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  SyncPhase create(Ref ref) {
    return syncPhase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SyncPhase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SyncPhase>(value),
    );
  }
}

String _$syncPhaseHash() => r'76c1ede92d38abaf65a727a423cec8a885f9e6ba';

/// Selector provider for pending operations count

@ProviderFor(pendingOperations)
final pendingOperationsProvider = PendingOperationsProvider._();

/// Selector provider for pending operations count

final class PendingOperationsProvider extends $FunctionalProvider<int, int, int>
    with $Provider<int> {
  /// Selector provider for pending operations count
  PendingOperationsProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'pendingOperationsProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$pendingOperationsHash();

  @$internal
  @override
  $ProviderElement<int> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  int create(Ref ref) {
    return pendingOperations(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(int value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<int>(value),
    );
  }
}

String _$pendingOperationsHash() => r'8287e0dbef2c3d0f182712c25de2a268881d6538';

/// Selector provider for has pending operations

@ProviderFor(hasPendingOperations)
final hasPendingOperationsProvider = HasPendingOperationsProvider._();

/// Selector provider for has pending operations

final class HasPendingOperationsProvider
    extends $FunctionalProvider<bool, bool, bool> with $Provider<bool> {
  /// Selector provider for has pending operations
  HasPendingOperationsProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'hasPendingOperationsProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$hasPendingOperationsHash();

  @$internal
  @override
  $ProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  bool create(Ref ref) {
    return hasPendingOperations(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$hasPendingOperationsHash() =>
    r'd6b85155f4bcb8edec4adb4aea79488244a87dc7';

/// Selector provider for sync error status

@ProviderFor(hasSyncError)
final hasSyncErrorProvider = HasSyncErrorProvider._();

/// Selector provider for sync error status

final class HasSyncErrorProvider extends $FunctionalProvider<bool, bool, bool>
    with $Provider<bool> {
  /// Selector provider for sync error status
  HasSyncErrorProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'hasSyncErrorProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$hasSyncErrorHash();

  @$internal
  @override
  $ProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  bool create(Ref ref) {
    return hasSyncError(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$hasSyncErrorHash() => r'6954754d230dd8131487c4b385a9c2772d9a2b3b';

/// Selector provider for error message

@ProviderFor(syncErrorMessage)
final syncErrorMessageProvider = SyncErrorMessageProvider._();

/// Selector provider for error message

final class SyncErrorMessageProvider
    extends $FunctionalProvider<String?, String?, String?>
    with $Provider<String?> {
  /// Selector provider for error message
  SyncErrorMessageProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'syncErrorMessageProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$syncErrorMessageHash();

  @$internal
  @override
  $ProviderElement<String?> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  String? create(Ref ref) {
    return syncErrorMessage(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String?>(value),
    );
  }
}

String _$syncErrorMessageHash() => r'6b80286c227823851a53e48fb85b7943d2d93274';

/// Selector provider for last sync time

@ProviderFor(lastSyncTime)
final lastSyncTimeProvider = LastSyncTimeProvider._();

/// Selector provider for last sync time

final class LastSyncTimeProvider
    extends $FunctionalProvider<DateTime?, DateTime?, DateTime?>
    with $Provider<DateTime?> {
  /// Selector provider for last sync time
  LastSyncTimeProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'lastSyncTimeProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$lastSyncTimeHash();

  @$internal
  @override
  $ProviderElement<DateTime?> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  DateTime? create(Ref ref) {
    return lastSyncTime(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DateTime? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DateTime?>(value),
    );
  }
}

String _$lastSyncTimeHash() => r'0945bfd8903b2c9d07f5fcb668dd43caba774077';

/// Selector provider for current operation description

@ProviderFor(currentSyncOperation)
final currentSyncOperationProvider = CurrentSyncOperationProvider._();

/// Selector provider for current operation description

final class CurrentSyncOperationProvider
    extends $FunctionalProvider<String?, String?, String?>
    with $Provider<String?> {
  /// Selector provider for current operation description
  CurrentSyncOperationProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'currentSyncOperationProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$currentSyncOperationHash();

  @$internal
  @override
  $ProviderElement<String?> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  String? create(Ref ref) {
    return currentSyncOperation(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String?>(value),
    );
  }
}

String _$currentSyncOperationHash() =>
    r'f60a533bbdbc9ea00132100d65179ae86aa233a7';

/// Selector provider for is idle status

@ProviderFor(isSyncIdle)
final isSyncIdleProvider = IsSyncIdleProvider._();

/// Selector provider for is idle status

final class IsSyncIdleProvider extends $FunctionalProvider<bool, bool, bool>
    with $Provider<bool> {
  /// Selector provider for is idle status
  IsSyncIdleProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'isSyncIdleProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$isSyncIdleHash();

  @$internal
  @override
  $ProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  bool create(Ref ref) {
    return isSyncIdle(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$isSyncIdleHash() => r'd483287123646e8beecd6123fe32196ac2d3bb23';
