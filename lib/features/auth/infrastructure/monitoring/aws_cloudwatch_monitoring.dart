import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:aws_client/aws_client.dart';

part 'aws_cloudwatch_monitoring.g.dart';

/// AWS service clients
@riverpod
AwsClientCredentials awsCredentials(AwsCredentialsRef ref) {
  return AwsClientCredentials(
    accessKey: const String.fromEnvironment('AWS_ACCESS_KEY_ID'),
    secretKey: const String.fromEnvironment('AWS_SECRET_ACCESS_KEY'),
    region:
        const String.fromEnvironment('AWS_REGION', defaultValue: 'us-east-1'),
  );
}

/// Provider for CloudWatch client
@riverpod
CloudWatch cloudWatchClient(CloudWatchClientRef ref) {
  final credentials = ref.watch(awsCredentialsProvider);
  return CloudWatch(credentials: credentials);
}

/// Provider for SNS client
@riverpod
SNS snsClient(SNSClientRef ref) {
  final credentials = ref.watch(awsCredentialsProvider);
  return SNS(credentials: credentials);
}

/// Provider for CloudWatch monitoring service
@riverpod
class AwsCloudWatchMonitoring extends _$AwsCloudWatchMonitoring {
  @override
  void build() {}

  /// Record a metric to CloudWatch
  Future<void> recordMetric(
    String metricName,
    double value, {
    Map<String, String>? dimensions,
  }) async {
    final cloudWatch = ref.read(cloudWatchClientProvider);

    try {
      final metricData = PutMetricDataInput(
        namespace: 'SoloAdventurer/TokenSecurity',
        metricData: [
          MetricDatum(
            metricName: metricName,
            value: value,
            timestamp: DateTime.now(),
            dimensions: dimensions?.entries
                .map((e) => Dimension(
                      name: e.key,
                      value: e.value,
                    ))
                .toList(),
          ),
        ],
      );

      await cloudWatch.putMetricData(metricData);
    } catch (e) {
      // Log error but don't rethrow to prevent app disruption
      print('Failed to record metric: $e');
    }
  }
}
