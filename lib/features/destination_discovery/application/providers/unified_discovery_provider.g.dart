// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'unified_discovery_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provider for unified discovery combining Google Places + Viator.

@ProviderFor(UnifiedDiscovery)
const unifiedDiscoveryProvider = UnifiedDiscoveryProvider._();

/// Provider for unified discovery combining Google Places + Viator.
final class UnifiedDiscoveryProvider
    extends $AsyncNotifierProvider<UnifiedDiscovery, UnifiedDiscoveryState> {
  /// Provider for unified discovery combining Google Places + Viator.
  const UnifiedDiscoveryProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'unifiedDiscoveryProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$unifiedDiscoveryHash();

  @$internal
  @override
  UnifiedDiscovery create() => UnifiedDiscovery();
}

String _$unifiedDiscoveryHash() => r'c57d0ceeb17e05e401e1e6f54a51af542598d503';

/// Provider for unified discovery combining Google Places + Viator.

abstract class _$UnifiedDiscovery
    extends $AsyncNotifier<UnifiedDiscoveryState> {
  FutureOr<UnifiedDiscoveryState> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref
        as $Ref<AsyncValue<UnifiedDiscoveryState>, UnifiedDiscoveryState>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<AsyncValue<UnifiedDiscoveryState>, UnifiedDiscoveryState>,
        AsyncValue<UnifiedDiscoveryState>,
        Object?,
        Object?>;
    element.handleValue(ref, created);
  }
}
