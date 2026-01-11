// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'manual_sync_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Notifier for managing manual sync operations
///
/// Riverpod 3.0 Migration Notes:
/// - Converted from StateNotifier to @riverpod Notifier
/// - Dependencies injected via ref.watch() in build() method
/// - Uses ref.onDispose() for cleanup instead of dispose() method
/// - Initialization logic moved from constructor to build() method
///
/// Handles manual sync triggers, tracks sync progress,
/// and provides state updates for UI components.

@ProviderFor(ManualSyncNotifier)
const manualSyncProvider = ManualSyncNotifierProvider._();

/// Notifier for managing manual sync operations
///
/// Riverpod 3.0 Migration Notes:
/// - Converted from StateNotifier to @riverpod Notifier
/// - Dependencies injected via ref.watch() in build() method
/// - Uses ref.onDispose() for cleanup instead of dispose() method
/// - Initialization logic moved from constructor to build() method
///
/// Handles manual sync triggers, tracks sync progress,
/// and provides state updates for UI components.
final class ManualSyncNotifierProvider
    extends $NotifierProvider<ManualSyncNotifier, ManualSyncState> {
  /// Notifier for managing manual sync operations
  ///
  /// Riverpod 3.0 Migration Notes:
  /// - Converted from StateNotifier to @riverpod Notifier
  /// - Dependencies injected via ref.watch() in build() method
  /// - Uses ref.onDispose() for cleanup instead of dispose() method
  /// - Initialization logic moved from constructor to build() method
  ///
  /// Handles manual sync triggers, tracks sync progress,
  /// and provides state updates for UI components.
  const ManualSyncNotifierProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'manualSyncProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$manualSyncNotifierHash();

  @$internal
  @override
  ManualSyncNotifier create() => ManualSyncNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ManualSyncState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ManualSyncState>(value),
    );
  }
}

String _$manualSyncNotifierHash() =>
    r'c926b6b0daae70a046778f0ca1fe8f5e1f2f66a4';

/// Notifier for managing manual sync operations
///
/// Riverpod 3.0 Migration Notes:
/// - Converted from StateNotifier to @riverpod Notifier
/// - Dependencies injected via ref.watch() in build() method
/// - Uses ref.onDispose() for cleanup instead of dispose() method
/// - Initialization logic moved from constructor to build() method
///
/// Handles manual sync triggers, tracks sync progress,
/// and provides state updates for UI components.

abstract class _$ManualSyncNotifier extends $Notifier<ManualSyncState> {
  ManualSyncState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<ManualSyncState, ManualSyncState>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<ManualSyncState, ManualSyncState>,
        ManualSyncState,
        Object?,
        Object?>;
    element.handleValue(ref, created);
  }
}
