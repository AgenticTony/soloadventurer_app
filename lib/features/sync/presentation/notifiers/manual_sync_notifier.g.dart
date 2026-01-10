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
final manualSyncProvider = ManualSyncNotifierProvider._();

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
  ManualSyncNotifierProvider._()
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
    r'de230942da04c0d3ba59ba1af4be822fd84441d1';

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
    final ref = this.ref as $Ref<ManualSyncState, ManualSyncState>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<ManualSyncState, ManualSyncState>,
        ManualSyncState,
        Object?,
        Object?>;
    element.handleCreate(ref, build);
  }
}
