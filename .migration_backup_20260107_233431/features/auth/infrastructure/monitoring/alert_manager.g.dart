// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'alert_manager.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provider for CloudWatch client

@ProviderFor(cloudWatchClient)
final cloudWatchClientProvider = CloudWatchClientProvider._();

/// Provider for CloudWatch client

final class CloudWatchClientProvider
    extends $FunctionalProvider<CloudWatch, CloudWatch, CloudWatch>
    with $Provider<CloudWatch> {
  /// Provider for CloudWatch client
  CloudWatchClientProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'cloudWatchClientProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$cloudWatchClientHash();

  @$internal
  @override
  $ProviderElement<CloudWatch> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  CloudWatch create(Ref ref) {
    return cloudWatchClient(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CloudWatch value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CloudWatch>(value),
    );
  }
}

String _$cloudWatchClientHash() => r'c0c6625ab2e0d3adef94b66194a422d1674b7c9b';

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

String _$alertManagerHash() => r'78c9bfa1782f76a4535c8507950f116db1e10691';

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
