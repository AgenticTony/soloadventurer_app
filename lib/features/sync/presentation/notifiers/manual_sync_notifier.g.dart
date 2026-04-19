// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'manual_sync_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Notifier for managing manual sync operations
///
/// Riverpod 3.0 AsyncNotifier Migration:
/// - Uses AsyncNotifier pattern with AsyncValue wrapper
/// - Loading/error states handled by AsyncValue, NOT manual state fields
/// - isSyncing/errorMessage removed from state (AsyncValue handles them)
/// - Methods use AsyncValue.guard() for async operations
/// - UI reads state via ref.watch(manualSyncProvider)
/// - UI calls methods via ref.read(manualSyncProvider.notifier)

@ProviderFor(ManualSyncNotifier)
const manualSyncProvider = ManualSyncNotifierProvider._();

/// Notifier for managing manual sync operations
///
/// Riverpod 3.0 AsyncNotifier Migration:
/// - Uses AsyncNotifier pattern with AsyncValue wrapper
/// - Loading/error states handled by AsyncValue, NOT manual state fields
/// - isSyncing/errorMessage removed from state (AsyncValue handles them)
/// - Methods use AsyncValue.guard() for async operations
/// - UI reads state via ref.watch(manualSyncProvider)
/// - UI calls methods via ref.read(manualSyncProvider.notifier)
final class ManualSyncNotifierProvider
    extends $AsyncNotifierProvider<ManualSyncNotifier, ManualSyncState> {
  /// Notifier for managing manual sync operations
  ///
  /// Riverpod 3.0 AsyncNotifier Migration:
  /// - Uses AsyncNotifier pattern with AsyncValue wrapper
  /// - Loading/error states handled by AsyncValue, NOT manual state fields
  /// - isSyncing/errorMessage removed from state (AsyncValue handles them)
  /// - Methods use AsyncValue.guard() for async operations
  /// - UI reads state via ref.watch(manualSyncProvider)
  /// - UI calls methods via ref.read(manualSyncProvider.notifier)
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
}

String _$manualSyncNotifierHash() =>
    r'e6a0f73dd2da4bf1fc7f9e2035824987fd78a5e7';

/// Notifier for managing manual sync operations
///
/// Riverpod 3.0 AsyncNotifier Migration:
/// - Uses AsyncNotifier pattern with AsyncValue wrapper
/// - Loading/error states handled by AsyncValue, NOT manual state fields
/// - isSyncing/errorMessage removed from state (AsyncValue handles them)
/// - Methods use AsyncValue.guard() for async operations
/// - UI reads state via ref.watch(manualSyncProvider)
/// - UI calls methods via ref.read(manualSyncProvider.notifier)

abstract class _$ManualSyncNotifier extends $AsyncNotifier<ManualSyncState> {
  FutureOr<ManualSyncState> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<AsyncValue<ManualSyncState>, ManualSyncState>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<AsyncValue<ManualSyncState>, ManualSyncState>,
        AsyncValue<ManualSyncState>,
        Object?,
        Object?>;
    element.handleValue(ref, created);
  }
}
