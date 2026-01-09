// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'itinerary_screen.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provider for view mode

@ProviderFor(ViewModeNotifier)
final viewModeProvider = ViewModeNotifierProvider._();

/// Provider for view mode
final class ViewModeNotifierProvider
    extends $NotifierProvider<ViewModeNotifier, ViewMode> {
  /// Provider for view mode
  ViewModeNotifierProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'viewModeProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$viewModeNotifierHash();

  @$internal
  @override
  ViewModeNotifier create() => ViewModeNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ViewMode value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ViewMode>(value),
    );
  }
}

String _$viewModeNotifierHash() => r'a13f871e5a9dc238bb2cb6b20293d8755a0acf1e';

/// Provider for view mode

abstract class _$ViewModeNotifier extends $Notifier<ViewMode> {
  ViewMode build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<ViewMode, ViewMode>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<ViewMode, ViewMode>, ViewMode, Object?, Object?>;
    element.handleCreate(ref, build);
  }
}

/// Provider for reorder mode

@ProviderFor(IsReorderModeNotifier)
final isReorderModeProvider = IsReorderModeNotifierProvider._();

/// Provider for reorder mode
final class IsReorderModeNotifierProvider
    extends $NotifierProvider<IsReorderModeNotifier, bool> {
  /// Provider for reorder mode
  IsReorderModeNotifierProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'isReorderModeProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$isReorderModeNotifierHash();

  @$internal
  @override
  IsReorderModeNotifier create() => IsReorderModeNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$isReorderModeNotifierHash() =>
    r'92640d345366ac892580662e4c510e9a02a5ba4d';

/// Provider for reorder mode

abstract class _$IsReorderModeNotifier extends $Notifier<bool> {
  bool build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<bool, bool>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<bool, bool>, bool, Object?, Object?>;
    element.handleCreate(ref, build);
  }
}
