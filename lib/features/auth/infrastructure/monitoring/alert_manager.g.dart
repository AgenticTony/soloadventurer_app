// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'alert_manager.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Manager responsible for handling security alerts and notifications

@ProviderFor(AlertManager)
final alertManagerProvider = AlertManagerProvider._();

/// Manager responsible for handling security alerts and notifications
final class AlertManagerProvider
    extends $AsyncNotifierProvider<AlertManager, void> {
  /// Manager responsible for handling security alerts and notifications
  AlertManagerProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'alertManagerProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$alertManagerHash();

  @$internal
  @override
  AlertManager create() => AlertManager();
}

String _$alertManagerHash() => r'e0354d7cd10f193d752dc2722cbfc6371617b2be';

/// Manager responsible for handling security alerts and notifications

abstract class _$AlertManager extends $AsyncNotifier<void> {
  FutureOr<void> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<void>, void>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<AsyncValue<void>, void>,
        AsyncValue<void>,
        Object?,
        Object?>;
    element.handleCreate(ref, build);
  }
}
