// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sync_state_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Notifier for managing comprehensive sync state
///
/// Riverpod 3.0 AsyncNotifier Migration:
/// - Uses AsyncNotifier pattern with AsyncValue wrapper
/// - Loading/error states handled by AsyncValue, NOT manual state fields
/// - isProcessing/lastError removed from state (AsyncValue handles them)
/// - Stream subscriptions update state via AsyncData
/// - UI reads state via ref.watch(syncStateProvider)
/// - UI calls methods via ref.read(syncStateProvider.notifier)

@ProviderFor(SyncStateNotifier)
const syncStateProvider = SyncStateNotifierProvider._();

/// Notifier for managing comprehensive sync state
///
/// Riverpod 3.0 AsyncNotifier Migration:
/// - Uses AsyncNotifier pattern with AsyncValue wrapper
/// - Loading/error states handled by AsyncValue, NOT manual state fields
/// - isProcessing/lastError removed from state (AsyncValue handles them)
/// - Stream subscriptions update state via AsyncData
/// - UI reads state via ref.watch(syncStateProvider)
/// - UI calls methods via ref.read(syncStateProvider.notifier)
final class SyncStateNotifierProvider
    extends $AsyncNotifierProvider<SyncStateNotifier, SyncState> {
  /// Notifier for managing comprehensive sync state
  ///
  /// Riverpod 3.0 AsyncNotifier Migration:
  /// - Uses AsyncNotifier pattern with AsyncValue wrapper
  /// - Loading/error states handled by AsyncValue, NOT manual state fields
  /// - isProcessing/lastError removed from state (AsyncValue handles them)
  /// - Stream subscriptions update state via AsyncData
  /// - UI reads state via ref.watch(syncStateProvider)
  /// - UI calls methods via ref.read(syncStateProvider.notifier)
  const SyncStateNotifierProvider._()
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
}

String _$syncStateNotifierHash() => r'9a1a87e501d29b4201c282a605c7f958c40c0d2a';

/// Notifier for managing comprehensive sync state
///
/// Riverpod 3.0 AsyncNotifier Migration:
/// - Uses AsyncNotifier pattern with AsyncValue wrapper
/// - Loading/error states handled by AsyncValue, NOT manual state fields
/// - isProcessing/lastError removed from state (AsyncValue handles them)
/// - Stream subscriptions update state via AsyncData
/// - UI reads state via ref.watch(syncStateProvider)
/// - UI calls methods via ref.read(syncStateProvider.notifier)

abstract class _$SyncStateNotifier extends $AsyncNotifier<SyncState> {
  FutureOr<SyncState> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<AsyncValue<SyncState>, SyncState>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<AsyncValue<SyncState>, SyncState>,
        AsyncValue<SyncState>,
        Object?,
        Object?>;
    element.handleValue(ref, created);
  }
}
