// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sync_manager_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provider for the SyncManager that properly provides the userId callback
///
/// This provider creates a SyncManagerImpl with a getCurrentUserId callback
/// that reads from the auth state. This allows the sync manager to access
/// the current user ID without requiring a ProviderContainer at construction time.

@ProviderFor(syncManager)
const syncManagerProvider = SyncManagerProvider._();

/// Provider for the SyncManager that properly provides the userId callback
///
/// This provider creates a SyncManagerImpl with a getCurrentUserId callback
/// that reads from the auth state. This allows the sync manager to access
/// the current user ID without requiring a ProviderContainer at construction time.

final class SyncManagerProvider
    extends $FunctionalProvider<SyncManager, SyncManager, SyncManager>
    with $Provider<SyncManager> {
  /// Provider for the SyncManager that properly provides the userId callback
  ///
  /// This provider creates a SyncManagerImpl with a getCurrentUserId callback
  /// that reads from the auth state. This allows the sync manager to access
  /// the current user ID without requiring a ProviderContainer at construction time.
  const SyncManagerProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'syncManagerProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$syncManagerHash();

  @$internal
  @override
  $ProviderElement<SyncManager> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  SyncManager create(Ref ref) {
    return syncManager(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SyncManager value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SyncManager>(value),
    );
  }
}

String _$syncManagerHash() => r'5293a70cdfd2eacfc403bc6aa08d0b8500301d44';
