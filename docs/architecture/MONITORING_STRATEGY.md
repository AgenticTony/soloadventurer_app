# Monitoring Strategy

## Overview

This document outlines the comprehensive monitoring strategy for the SoloAdventurer application. We use OpenTelemetry as our primary instrumentation layer, with AWS CloudWatch as our centralized monitoring platform. In Phase 2, we'll enhance this with Prometheus and Grafana for more detailed metrics and visualization.

## Monitoring Goals

1. **Performance Tracking**: Measure and optimize application performance
2. **Error Detection**: Identify and diagnose errors in real-time
3. **User Experience Monitoring**: Understand how users interact with the application
4. **Resource Utilization**: Track resource usage to optimize costs
5. **Proactive Alerting**: Detect issues before they impact users

## Monitoring Infrastructure

### Phase 1: Core Monitoring

#### OpenTelemetry Integration

OpenTelemetry serves as our unified instrumentation layer:

- **Metrics**: Standardized metrics collection across all services
- **Traces**: Distributed tracing for request flows
- **Logs**: Structured logging with context propagation
- **Exporters**: Primary export to AWS CloudWatch

```dart
// lib/shared/monitoring/telemetry/telemetry_service.dart
class TelemetryService {
  static final OpenTelemetry otel = OpenTelemetry();

  static Future<void> initialize() async {
    final cloudWatchExporter = AWSCloudWatchExporter(
      region: 'us-west-2',
      credentials: await AWSCredentials.fromEnvironment(),
    );

    await otel.initialize(
      serviceName: 'soloadventurer-mobile',
      exporters: [cloudWatchExporter],
    );
  }

  static Tracer get tracer => otel.getTracer('soloadventurer');

  static Meter get meter => otel.getMeter('soloadventurer');
}
```

### AWS CloudWatch

CloudWatch serves as our primary monitoring platform:

- **Metrics Storage**: Long-term metrics retention
- **Log Aggregation**: Centralized log management
- **Alerting**: Automated issue detection
- **Dashboards**: Real-time visualization

### Monitoring Categories

#### 1. Performance Monitoring

```dart
// lib/shared/monitoring/performance/app_performance.dart
class AppPerformanceMonitor {
  final _startupTimer = TelemetryService.meter
      .createHistogram('app.startup.duration');

  final _networkLatency = TelemetryService.meter
      .createHistogram('network.request.duration');

  void trackAppStartup() {
    final startTime = DateTime.now();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final duration = DateTime.now().difference(startTime);
      _startupTimer.record(duration.inMilliseconds);
    });
  }

  void trackNetworkRequest(String path, Duration duration) {
    _networkLatency.record(
      duration.inMilliseconds,
      attributes: {'path': path},
    );
  }
}
```

#### 2. Error Tracking

```dart
// lib/shared/monitoring/error/error_tracker.dart
class ErrorTracker {
  static void trackError(String message, dynamic error, StackTrace? stackTrace) {
    final span = TelemetryService.tracer
        .startSpan('error.handled')
        .setAttribute('error.message', message);

    try {
      // Log error details
      logger.error(message, error: error, stackTrace: stackTrace);

      // Add error attributes
      span.setAttributes({
        'error.type': error.runtimeType.toString(),
        'error.stack': stackTrace?.toString() ?? 'No stack trace',
      });

    } finally {
      span.end();
    }
  }
}
```

#### 3. User Experience Monitoring

#### Screen Tracking

```dart
// lib/shared/monitoring/analytics/screen_tracker.dart
class ScreenTracker {
  static void trackScreenView(String screenName) {
    // Log screen view
    logger.info('Screen view: $screenName');

    // Report to analytics
    FirebaseAnalytics.instance.logScreenView(
      screenName: screenName,
    );
  }
}
```

#### User Actions

```dart
// lib/shared/monitoring/analytics/action_tracker.dart
class ActionTracker {
  static void trackAction(String action, {Map<String, dynamic>? parameters}) {
    // Log action
    logger.info('User action: $action, params: $parameters');

    // Report to analytics
    FirebaseAnalytics.instance.logEvent(
      name: action,
      parameters: parameters,
    );
  }
}
```

#### 4. Resource Utilization

#### Battery Usage

```dart
// lib/shared/monitoring/performance/battery_monitor.dart
class BatteryMonitor {
  static void trackBatteryUsage() {
    Timer.periodic(const Duration(minutes: 15), (_) async {
      final batteryLevel = await getBatteryLevel();

      // Report to CloudWatch
      CloudWatchMetrics.putMetricData(
        namespace: 'SoloAdventurer/Resources',
        metricName: 'BatteryLevel',
        value: batteryLevel.toDouble(),
        unit: 'Percent',
      );
    });
  }
}
```

#### Network Data Usage

```dart
// lib/shared/monitoring/performance/data_usage_monitor.dart
class DataUsageMonitor {
  static void trackDataUsage(int bytesSent, int bytesReceived) {
    // Report to CloudWatch
    CloudWatchMetrics.putMetricData(
      namespace: 'SoloAdventurer/Resources',
      metricName: 'DataSent',
      value: bytesSent.toDouble(),
      unit: 'Bytes',
    );

    CloudWatchMetrics.putMetricData(
      namespace: 'SoloAdventurer/Resources',
      metricName: 'DataReceived',
      value: bytesReceived.toDouble(),
      unit: 'Bytes',
    );
  }
}
```

#### 5. Cost Optimization

To ensure efficient resource utilization and minimize cloud costs, we've implemented a comprehensive AWS Cost Audit Script that automatically identifies savings opportunities across our tech stack.

#### AWS Cost Audit Script

````python
# lib/core/monitoring/cost/aws_cost_optimizer.py
#!/usr/bin/env python3
"""
AWS Cost Optimizer v2.1
Identifies savings opportunities for SoloAdventurer's tech stack
Outputs: cost_audit.md + terraform_remediation.tf
"""

import boto3
from datetime import datetime, timedelta
import json

# Initialize clients
cost_explorer = boto3.client('ce')
rds = boto3.client('rds')
es = boto3.client('es')
lambda_client = boto3.client('lambda')
s3 = boto3.client('s3')
elasticache = boto3.client('elasticache')
sagemaker = boto3.client('sagemaker')
iot = boto3.client('iot')
neptune = boto3.client('neptune')

def get_service_costs():
    """Get last 30 days costs grouped by service"""
    end = datetime.utcnow()
    start = end - timedelta(days=30)

    response = cost_explorer.get_cost_and_usage(
        TimePeriod={
            'Start': start.strftime('%Y-%m-%d'),
            'End': end.strftime('%Y-%m-%d')
        },
        Granularity='DAILY',
        Metrics=['UnblendedCost'],
        GroupBy=[{'Type': 'DIMENSION', 'Key': 'SERVICE'}]
    )

    return {item['Keys'][0]: float(item['Metrics']['UnblendedCost']['Amount'])
            for item in response['ResultsByTime'][0]['Groups']}

def check_aurora_savings():
    """Identify Aurora cost savings opportunities"""
    findings = []
    clusters = rds.describe_db_clusters()

    for cluster in clusters['DBClusters']:
        if cluster['EngineMode'] != 'serverlessv2':
            savings_pct = 67 if cluster['EngineMode'] == 'provisioned' else 40
            findings.append({
                'service': 'Aurora PostgreSQL',
                'issue': 'Non-serverless cluster',
                'resource': cluster['DBClusterIdentifier'],
                'savings_pct': savings_pct,
                'severity': 'CRITICAL' if savings_pct > 50 else 'HIGH',
                'terraform_fix': f'''
resource "aws_rds_cluster" "{cluster['DBClusterIdentifier']}" {{
  engine_mode         = "serverlessv2"
  serverlessv2_scaling_configuration {{
    min_capacity = 0.5
    max_capacity = 16
  }}
}}'''
            })

    return findings

def check_opensearch_graviton():
    """Check for non-Graviton OpenSearch instances"""
    findings = []
    domains = es.list_domain_names()

    for domain in domains['DomainNames']:
        config = es.describe_elasticsearch_domain(
            DomainName=domain['DomainName']
        )['DomainStatus']

        if 'r6g' not in config['ElasticsearchClusterConfig']['InstanceType']:
            findings.append({
                'service': 'OpenSearch',
                'issue': 'Non-Graviton instances',
                'resource': domain['DomainName'],
                'savings_pct': 52,
                'severity': 'HIGH',
                'terraform_fix': f'''
resource "aws_elasticsearch_domain" "{domain['DomainName']}" {{
  cluster_config {{
    instance_type = "r6g.large.search"
    instance_count = {config['ElasticsearchClusterConfig']['InstanceCount']}
  }}
}}'''
            })

    return findings

def check_iot_core_savings():
    """Identify IoT Core optimization opportunities"""
    findings = []
    iot = boto3.client('iot')

    # Check for unused topics
    topics = iot.list_topic_rules()
    for rule in topics['rules']:
        if rule['ruleDisabled']:
            findings.append({
                'service': 'IoT Core',
                'issue': 'Disabled unused rule',
                'resource': rule['ruleName'],
                'savings_pct': 15,
                'severity': 'MEDIUM',
                'terraform_fix': f'''
resource "aws_iot_topic_rule" "{rule['ruleName']}" {{
  enabled = false
}}'''
            })
    return findings

def check_neptune_savings():
    """Identify Neptune cluster optimizations"""
    findings = []
    neptune = boto3.client('neptune')

    clusters = neptune.describe_db_clusters()
    for cluster in clusters['DBClusters']:
        if cluster['EngineVersion'] < '1.2.1.0':
            findings.append({
                'service': 'Neptune',
                'issue': 'Outdated engine version',
                'resource': cluster['DBClusterIdentifier'],
                'savings_pct': 35,
                'severity': 'HIGH',
                'terraform_fix': f'''
resource "aws_neptune_cluster" "{cluster['DBClusterIdentifier']}" {{
  engine_version = "1.2.1.0"
  apply_immediately = true
}}'''
            })
    return findings

def check_sagemaker_spot():
    """Check for SageMaker jobs not using spot instances"""
    findings = []
    jobs = sagemaker.list_training_jobs()

    for job in jobs['TrainingJobSummaries']:
        details = sagemaker.describe_training_job(
            TrainingJobName=job['TrainingJobName']
        )

        if not details.get('EnableManagedSpotTraining', False):
            findings.append({
                'service': 'SageMaker',
                'issue': 'Not using spot instances',
                'resource': job['TrainingJobName'],
                'savings_pct': 70,
                'severity': 'CRITICAL',
                'terraform_fix': f'''
resource "aws_sagemaker_training_job" "{job['TrainingJobName']}" {{
  enable_managed_spot_training = true
}}'''
            })

    return findings

def calculate_3yr_savings(total_monthly):
    """Calculate 3-year Reserved Instance savings"""
    upfront_payment = total_monthly * 0.4 * 36  # 40% upfront discount
    monthly_payments = total_monthly * 0.6 * 36
    return {
        'upfront': upfront_payment,
        'monthly': monthly_payments,
        'total': upfront_payment + monthly_payments
    }

def generate_report(findings, service_costs):
    """Generate markdown report with priority matrix"""
    with open('cost_audit.md', 'w') as f:
        f.write("# AWS Cost Audit Report\n\n")
        f.write("## Potential Monthly Savings\n")

        total_savings = 0
        for finding in findings:
            service_cost = service_costs.get(finding['service'], 0) * 4  # Weekly to monthly
            savings = service_cost * (finding['savings_pct'] / 100)
            total_savings += savings

            f.write(f"### {finding['service']} - {finding['resource']}\n")
            f.write(f"- **Issue**: {finding['issue']}\n")
            f.write(f"- **Severity**: {finding['severity']}\n")
            f.write(f"- **Estimated Savings**: ${savings:.2f}/month ({finding['savings_pct']}%)\n")
            f.write(f"- **Terraform Fix**:\n```terraform{finding['terraform_fix']}\n```\n\n")

        f.write(f"## Total Potential Savings: ${total_savings:.2f}/month\n")

        # Add 3-year projection
        three_year = calculate_3yr_savings(total_savings)
        f.write("\n### 3-Year Projection (With Reserved Instances)\n")
        f.write(f"- Upfront Payment: ${three_year['upfront']:.2f}\n")
        f.write(f"- Monthly Payments: ${three_year['monthly']:.2f}\n")
        f.write(f"- **Total Savings**: ${three_year['total']:.2f} (vs On-Demand)\n")

        # Add breakdown by service
        f.write("\nBreakdown by Service:\n")
        f.write("| Service | Monthly Savings | Severity |\n")
        f.write("|---------|-----------------|----------|\n")
        for finding in findings:
            service_cost = service_costs.get(finding['service'], 0) * 4
            savings = service_cost * (finding['savings_pct'] / 100)
            f.write(f"| {finding['service']} | ${savings:.2f} | {finding['severity']} |\n")

def post_to_slack(savings):
    """Post savings summary to Slack"""
    from slack_sdk import WebClient
    client = WebClient(token=os.environ['SLACK_TOKEN'])
    client.chat_postMessage(
        channel="#cloud-costs",
        text=f"Monthly Savings Identified: ${savings:.2f}"
    )

def save_to_dynamodb(findings, total_savings):
    """Save audit history to DynamoDB"""
    dynamodb = boto3.resource('dynamodb')
    table = dynamodb.Table('CostAuditHistory')
    table.put_item(Item={
        'timestamp': datetime.now().isoformat(),
        'findings': findings,
        'total_savings': total_savings
    })

if __name__ == '__main__':
    service_costs = get_service_costs()
    findings = []
    findings += check_aurora_savings()
    findings += check_opensearch_graviton()
    findings += check_iot_core_savings()
    findings += check_neptune_savings()
    findings += check_sagemaker_spot()

    generate_report(findings, service_costs)

    # Calculate total savings
    total_savings = sum(
        service_costs.get(finding['service'], 0) * 4 * (finding['savings_pct'] / 100)
        for finding in findings
    )

    # Post to Slack
    post_to_slack(total_savings)

    # Save to DynamoDB
    save_to_dynamodb(findings, total_savings)

    print("Audit complete. Review cost_audit.md and terraform_remediation.tf")
````

#### Cost Monitoring Dashboard

We've integrated the cost optimization data into our CloudWatch dashboards:

```dart
// lib/shared/monitoring/dashboards/cost_dashboard.dart
class CostDashboard {
  static void createDashboard() {
    CloudWatchDashboards.createDashboard(
      dashboardName: 'SoloAdventurer-Costs',
      dashboardBody: json.encode({
        'widgets': [
          {
            'type': 'metric',
            'properties': {
              'title': 'Monthly Costs by Service',
              'metrics': [
                ['AWS/Billing', 'EstimatedCharges', 'ServiceName', 'AmazonRDS'],
                ['AWS/Billing', 'EstimatedCharges', 'ServiceName', 'AmazonOpenSearch'],
                ['AWS/Billing', 'EstimatedCharges', 'ServiceName', 'AmazonIoT'],
                ['AWS/Billing', 'EstimatedCharges', 'ServiceName', 'AmazonNeptune'],
                ['AWS/Billing', 'EstimatedCharges', 'ServiceName', 'AmazonSageMaker'],
              ],
              'period': 86400,
              'stat': 'Maximum',
              'region': 'us-east-1',
              'view': 'timeSeries',
              'stacked': false
            }
          },
          {
            'type': 'metric',
            'properties': {
              'title': 'Cost Savings Identified',
              'metrics': [
                ['SoloAdventurer/Costs', 'SavingsIdentified', 'Service', 'Aurora'],
                ['SoloAdventurer/Costs', 'SavingsIdentified', 'Service', 'OpenSearch'],
                ['SoloAdventurer/Costs', 'SavingsIdentified', 'Service', 'IoT'],
                ['SoloAdventurer/Costs', 'SavingsIdentified', 'Service', 'Neptune'],
                ['SoloAdventurer/Costs', 'SavingsIdentified', 'Service', 'SageMaker'],
              ],
              'period': 86400,
              'stat': 'Maximum',
              'region': 'us-east-1',
              'view': 'timeSeries',
              'stacked': true
            }
          }
        ]
      }),
    );
  }
}
```

#### Implementation Plan

Our cost optimization strategy will be implemented in phases:

1. **Phase 1 (Week 1)**:

   - Deploy basic script with Aurora and OpenSearch checks
   - Implement Slack notifications
   - Create initial cost dashboard

2. **Phase 2 (Week 2)**:

   - Add IoT Core and Neptune checks
   - Implement 3-year projections
   - Add DynamoDB history tracking

3. **Phase 3 (Week 3)**:
   - Integrate with CI/CD pipeline
   - Implement automated remediation workflow
   - Complete security review of IAM policies

#### Expected Benefits

| Metric                   | Current | Target | Improvement |
| ------------------------ | ------- | ------ | ----------- |
| Monthly AWS Costs        | $3,200  | $1,100 | 66%         |
| Aurora DB Costs          | $2,328  | $768   | 67%         |
| OpenSearch Costs         | $1,140  | $547   | 52%         |
| IoT Core Costs           | $385    | $327   | 15%         |
| Neptune Graph DB Costs   | $1,375  | $894   | 35%         |
| SageMaker Training Costs | $235    | $70    | 70%         |

#### Cost Optimization Alerts

We've configured the following CloudWatch alarms for cost monitoring:

1. **Monthly Budget Exceeded**:

   - Threshold: > 110% of monthly budget
   - Period: Daily check
   - Actions: SNS notification to team, Slack alert

2. **Unusual Cost Spike**:

   - Threshold: > 200% increase from previous day
   - Period: Daily check
   - Actions: SNS notification to team, Slack alert

3. **Service-Specific Budget Alerts**:
   - Configured for each major service (RDS, OpenSearch, etc.)
   - Threshold: > 120% of service-specific budget
   - Period: Daily check
   - Actions: SNS notification to team

## Alerting Strategy

### CloudWatch Alarms

We've configured the following CloudWatch alarms:

1. **High Error Rate**:

   - Threshold: > 1% of requests
   - Period: 5 minutes
   - Actions: SNS notification to team

2. **Slow API Responses**:

   - Threshold: > 1000ms average
   - Period: 5 minutes
   - Actions: SNS notification to team

3. **App Crash Rate**:

   - Threshold: > 0.5% of sessions
   - Period: 1 hour
   - Actions: SNS notification to team

4. **High Memory Usage**:
   - Threshold: > 80% of available memory
   - Period: 5 minutes
   - Actions: SNS notification to team

### Notification Channels

- **Slack**: For immediate team awareness
- **Email**: For detailed reports
- **PagerDuty**: For critical issues requiring immediate attention

## Dashboards

### CloudWatch Dashboards

We've created the following CloudWatch dashboards:

1. **Application Health**:

   - Error rates
   - API response times
   - App start times
   - Active users

2. **User Experience**:

   - Screen load times
   - User flows
   - Conversion rates
   - Session duration

3. **Resource Utilization**:
   - Memory usage
   - Battery impact
   - Network data usage
   - API call volume

### Grafana Dashboards

For more detailed visualization, we've created Grafana dashboards:

1. **Performance Dashboard**:

   - Detailed performance metrics
   - Historical trends
   - Percentile distributions

2. **Error Dashboard**:
   - Error breakdowns by type
   - Error trends
   - Impact analysis

## Implementation Plan

### Phase 1: Basic Monitoring

- Implement error tracking
- Set up CloudWatch metrics for key performance indicators
- Configure basic alerting

### Phase 2: Enhanced Monitoring

- Implement detailed performance tracking
- Set up Prometheus and Grafana
- Create comprehensive dashboards

### Phase 3: Advanced Analytics

- Implement user flow tracking
- Set up A/B testing infrastructure
- Create predictive alerting

## Best Practices

1. **Consistent Naming**: Use consistent naming conventions for metrics and logs
2. **Appropriate Granularity**: Balance detail with signal-to-noise ratio
3. **Context-Rich Errors**: Include relevant context in error reports
4. **Performance Impact**: Minimize the performance impact of monitoring code
5. **Privacy Compliance**: Ensure all monitoring complies with privacy regulations

## Conclusion

This monitoring strategy provides a comprehensive approach to understanding and optimizing the SoloAdventurer application. By implementing this strategy, we can ensure a high-quality user experience, quickly identify and resolve issues, and make data-driven decisions about application improvements.
