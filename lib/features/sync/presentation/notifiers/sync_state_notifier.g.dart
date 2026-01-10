// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sync_state_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Notifier for managing comprehensive sync state
///
/// Riverpod 3.0 Migration Notes:
/// - Converted from StateNotifier to @riverpod Notifier
/// - Dependencies injected via ref.watch() in build() method
/// - Uses ref.onDispose() for cleanup instead of dispose() method
/// - Initialization logic moved from constructor to build() method
///
/// Listens to all sync service status changes and queue updates,
/// providing reactive state for UI components to consume.
/// Ensures all status indicators update immediately when sync state changes.
/// Optionally persists state across app restarts.

@ProviderFor(SyncStateNotifier)
final syncStateProvider = SyncStateNotifierProvider._();

/// Notifier for managing comprehensive sync state
///
/// Riverpod 3.0 Migration Notes:
/// - Converted from StateNotifier to @riverpod Notifier
/// - Dependencies injected via ref.watch() in build() method
/// - Uses ref.onDispose() for cleanup instead of dispose() method
/// - Initialization logic moved from constructor to build() method
///
/// Listens to all sync service status changes and queue updates,
/// providing reactive state for UI components to consume.
/// Ensures all status indicators update immediately when sync state changes.
/// Optionally persists state across app restarts.
final class SyncStateNotifierProvider
    extends $NotifierProvider<SyncStateNotifier, SyncState> {
  /// Notifier for managing comprehensive sync state
  ///
  /// Riverpod 3.0 Migration Notes:
  /// - Converted from StateNotifier to @riverpod Notifier
  /// - Dependencies injected via ref.watch() in build() method
  /// - Uses ref.onDispose() for cleanup instead of dispose() method
  /// - Initialization logic moved from constructor to build() method
  ///
  /// Listens to all sync service status changes and queue updates,
  /// providing reactive state for UI components to consume.
  /// Ensures all status indicators update immediately when sync state changes.
  /// Optionally persists state across app restarts.
  SyncStateNotifierProvider._()
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
  String debugGetCreateSourceHash() => _$syncStateNotifierHash();

  @$internal
  @override
  SyncStateNotifier create() => SyncStateNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SyncState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SyncState>(value),
    );
  }
}

String _$syncStateNotifierHash() => r'a6f1b0adf17f57ecc444c39f9277805abc0feee8';

/// Notifier for managing comprehensive sync state
///
/// Riverpod 3.0 Migration Notes:
/// - Converted from StateNotifier to @riverpod Notifier
/// - Dependencies injected via ref.watch() in build() method
/// - Uses ref.onDispose() for cleanup instead of dispose() method
/// - Initialization logic moved from constructor to build() method
///
/// Listens to all sync service status changes and queue updates,
/// providing reactive state for UI components to consume.
/// Ensures all status indicators update immediately when sync state changes.
/// Optionally persists state across app restarts.

abstract class _$SyncStateNotifier extends $Notifier<SyncState> {
  SyncState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<SyncState, SyncState>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<SyncState, SyncState>, SyncState, Object?, Object?>;
    element.handleCreate(ref, build);
  }
}
