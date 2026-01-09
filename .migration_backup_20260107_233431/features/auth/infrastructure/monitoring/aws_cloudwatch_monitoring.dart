import 'package:aws_cloudwatch/aws_cloudwatch.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Configuration for AWS CloudWatch monitoring
class AwsCloudWatchConfig {
  /// Initialize CloudWatch client with environment variables
  static CloudWatch initializeClient() {
    return CloudWatch(
      awsAccessKey: dotenv.env['AWS_ACCESS_KEY_ID'] ?? '',
      awsSecretKey: dotenv.env['AWS_SECRET_ACCESS_KEY'] ?? '',
      region: dotenv.env['AWS_REGION'] ?? 'us-east-1',
      groupName: 'SoloAdventurer/TokenSecurity',
      streamName: 'SecurityAlerts',
    );
  }

  /// Get CloudWatch log group name
  static String get logGroupName => 'SoloAdventurer/TokenSecurity';

  /// Get CloudWatch log stream name
  static String get logStreamName => 'SecurityAlerts';

  /// Get AWS region
  static String get region => dotenv.env['AWS_REGION'] ?? 'us-east-1';

  /// Check if AWS credentials are configured
  static bool get isConfigured {
    return dotenv.env['AWS_ACCESS_KEY_ID']?.isNotEmpty == true &&
        dotenv.env['AWS_SECRET_ACCESS_KEY']?.isNotEmpty == true;
  }
}
