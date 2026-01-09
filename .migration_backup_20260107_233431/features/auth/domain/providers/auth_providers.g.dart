// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Notifier for managing authentication metrics with persistence

@ProviderFor(AuthMetricsNotifier)
final authMetricsProvider = AuthMetricsNotifierProvider._();

/// Notifier for managing authentication metrics with persistence
final class AuthMetricsNotifierProvider
    extends $NotifierProvider<AuthMetricsNotifier, AuthMetricsState> {
  /// Notifier for managing authentication metrics with persistence
  AuthMetricsNotifierProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'authMetricsProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$authMetricsNotifierHash();

  @$internal
  @override
  AuthMetricsNotifier create() => AuthMetricsNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AuthMetricsState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AuthMetricsState>(value),
    );
  }
}

String _$authMetricsNotifierHash() =>
    r'560803d4a4b1aaedd426882252f6e1d0ad0cebe7';

/// Notifier for managing authentication metrics with persistence

abstract class _$AuthMetricsNotifier extends $Notifier<AuthMetricsState> {
  AuthMetricsState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AuthMetricsState, AuthMetricsState>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<AuthMetricsState, AuthMetricsState>,
        AuthMetricsState,
        Object?,
        Object?>;
    element.handleCreate(ref, build);
  }
}
