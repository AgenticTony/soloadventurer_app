// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'memory_timeline_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Notifier for managing memory timeline state
/// MIGRATION: StateNotifier → Notifier pattern
/// - Constructor logic moved to build() method
/// - Dependencies accessed via ref.watch() in methods
/// - Automatic provider generation via @riverpod annotation

@ProviderFor(MemoryTimeline)
const memoryTimelineProvider = MemoryTimelineProvider._();

/// Notifier for managing memory timeline state
/// MIGRATION: StateNotifier → Notifier pattern
/// - Constructor logic moved to build() method
/// - Dependencies accessed via ref.watch() in methods
/// - Automatic provider generation via @riverpod annotation
final class MemoryTimelineProvider
    extends $NotifierProvider<MemoryTimeline, MemoryTimelineState> {
  /// Notifier for managing memory timeline state
  /// MIGRATION: StateNotifier → Notifier pattern
  /// - Constructor logic moved to build() method
  /// - Dependencies accessed via ref.watch() in methods
  /// - Automatic provider generation via @riverpod annotation
  const MemoryTimelineProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'memoryTimelineProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$memoryTimelineHash();

  @$internal
  @override
  MemoryTimeline create() => MemoryTimeline();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(MemoryTimelineState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<MemoryTimelineState>(value),
    );
  }
}

String _$memoryTimelineHash() => r'3a00d3479ce8682bd9aef7a020833c235ac7edc9';

/// Notifier for managing memory timeline state
/// MIGRATION: StateNotifier → Notifier pattern
/// - Constructor logic moved to build() method
/// - Dependencies accessed via ref.watch() in methods
/// - Automatic provider generation via @riverpod annotation

abstract class _$MemoryTimeline extends $Notifier<MemoryTimelineState> {
  MemoryTimelineState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<MemoryTimelineState, MemoryTimelineState>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<MemoryTimelineState, MemoryTimelineState>,
        MemoryTimelineState,
        Object?,
        Object?>;
    element.handleValue(ref, created);
  }
}
