// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'aws_cloudwatch_monitoring.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provider for AWS CloudWatch monitoring service

@ProviderFor(awsCloudWatchMonitoring)
final awsCloudWatchMonitoringProvider = AwsCloudWatchMonitoringProvider._();

/// Provider for AWS CloudWatch monitoring service

final class AwsCloudWatchMonitoringProvider extends $FunctionalProvider<
    AwsCloudWatchMonitoring,
    AwsCloudWatchMonitoring,
    AwsCloudWatchMonitoring> with $Provider<AwsCloudWatchMonitoring> {
  /// Provider for AWS CloudWatch monitoring service
  AwsCloudWatchMonitoringProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'awsCloudWatchMonitoringProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$awsCloudWatchMonitoringHash();

  @$internal
  @override
  $ProviderElement<AwsCloudWatchMonitoring> $createElement(
          $ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AwsCloudWatchMonitoring create(Ref ref) {
    return awsCloudWatchMonitoring(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AwsCloudWatchMonitoring value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AwsCloudWatchMonitoring>(value),
    );
  }
}

String _$awsCloudWatchMonitoringHash() =>
    r'b65e8f5f36e6c8127dabb49e3deb6de14c8b6fc6';
