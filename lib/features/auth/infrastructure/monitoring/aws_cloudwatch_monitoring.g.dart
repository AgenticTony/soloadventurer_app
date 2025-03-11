// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'aws_cloudwatch_monitoring.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$awsCredentialsHash() => r'db60cf0b9cee1418f1e9c13fb0f766eba3e82a6c';

/// AWS service clients
///
/// Copied from [awsCredentials].
@ProviderFor(awsCredentials)
final awsCredentialsProvider =
    AutoDisposeProvider<AwsClientCredentials>.internal(
  awsCredentials,
  name: r'awsCredentialsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$awsCredentialsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AwsCredentialsRef = AutoDisposeProviderRef<AwsClientCredentials>;
String _$cloudWatchClientHash() => r'db7c7f0ac37149945a7a18507a129b5a956ca252';

/// Provider for CloudWatch client
///
/// Copied from [cloudWatchClient].
@ProviderFor(cloudWatchClient)
final cloudWatchClientProvider = AutoDisposeProvider<CloudWatch>.internal(
  cloudWatchClient,
  name: r'cloudWatchClientProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$cloudWatchClientHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CloudWatchClientRef = AutoDisposeProviderRef<CloudWatch>;
String _$snsClientHash() => r'c87ec0ab130bd4adfb2f7f35f8e60a4f02c14481';

/// Provider for SNS client
///
/// Copied from [snsClient].
@ProviderFor(snsClient)
final snsClientProvider = AutoDisposeProvider<SNS>.internal(
  snsClient,
  name: r'snsClientProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$snsClientHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef SnsClientRef = AutoDisposeProviderRef<SNS>;
String _$awsCloudWatchMonitoringHash() =>
    r'3e16b5e3167c2ba4e4b6e09891ace5fc2ba380ac';

/// Provider for CloudWatch monitoring service
///
/// Copied from [AwsCloudWatchMonitoring].
@ProviderFor(AwsCloudWatchMonitoring)
final awsCloudWatchMonitoringProvider =
    AutoDisposeNotifierProvider<AwsCloudWatchMonitoring, void>.internal(
  AwsCloudWatchMonitoring.new,
  name: r'awsCloudWatchMonitoringProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$awsCloudWatchMonitoringHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$AwsCloudWatchMonitoring = AutoDisposeNotifier<void>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
