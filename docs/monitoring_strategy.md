# SoloAdventurer Monitoring Strategy

## Overview

This document outlines the monitoring approach for the SoloAdventurer app, focusing on a cost-effective initial implementation with a path for future expansion as the user base grows.

## Monitoring Philosophy

- **Start Simple**: Begin with essential monitoring using AWS services already in our stack
- **Design for Extensibility**: Create an abstraction layer that allows for easy integration of additional monitoring tools
- **Focus on Critical Metrics**: Monitor what matters most for user experience and system health
- **Cost Consciousness**: Avoid unnecessary monitoring costs in early stages
- **Complementary Tools**: Use the right tool for each monitoring need rather than forcing everything into one system

## Phase 1: AWS-Only Monitoring (Initial Launch) - ✅ IMPLEMENTED

### Backend Monitoring

- **AWS CloudWatch** ✅
  - Monitor Lambda function performance (duration, error rate, throttling)
  - Track API Gateway metrics (latency, error rates, request counts)
  - Monitor Cognito authentication events
  - Set up basic alarms for critical service failures
  - Track database performance metrics (Aurora PostgreSQL)

### App Monitoring

- **Custom Performance Tracking** ✅
  - Utilize the `performance_metrics.dart` and `performance_monitoring.dart` utilities
  - Track key user interactions and screen rendering times
  - Monitor API request/response times from the client perspective
  - Track app startup time and authentication flow performance
  - Measure UI operations, network operations, and database operations

### Error Tracking

- **Centralized Error Logging** ✅
  - Send critical app errors to CloudWatch via API Gateway/Lambda
  - Implement structured error logging with context information
  - Set up alerts for error rate spikes
  - Implement global error handler with zoned error handling

### Implementation Details

#### Monitoring Service Abstraction

```dart
// lib/services/monitoring/monitoring_service.dart
abstract class MonitoringService {
  void trackMetric(String metricName, double value, MetricCategory category);
  void reportError(String errorType, dynamic error, StackTrace stackTrace);
  void trackEvent(String eventName, {Map<String, dynamic>? parameters});
  void startSession();
  void endSession();
}

enum MetricCategory {
  api,
  ui,
  database,
  authentication,
  business,
}
```

#### AWS CloudWatch Implementation

```dart
// lib/services/monitoring/aws_cloudwatch_monitoring.dart
class AwsCloudWatchMonitoring implements MonitoringService {
  final ApiService _apiService;
  String? _userId;
  String? _appVersion;
  String? _platform;

  AwsCloudWatchMonitoring(this._apiService) {
    _initializeDeviceInfo();
    debugPrint('Performance monitoring initialized');
  }

  @override
  void trackMetric(String metricName, double value, MetricCategory category) {
    final data = {
      'metricName': metricName,
      'value': value,
      'category': category.toString().split('.').last,
      'timestamp': DateTime.now().toIso8601String(),
      'platform': _platform ?? 'unknown',
      'appVersion': _appVersion ?? 'unknown',
      'userId': _userId ?? 'unknown',
    };

    _apiService.post('/monitoring/metrics', data: data).catchError((error) {
      debugPrint('Error sending metric to CloudWatch: $error');
    });
  }

  @override
  void reportError(String errorType, dynamic error, StackTrace stackTrace) {
    final data = {
      'errorType': errorType,
      'errorMessage': error.toString(),
      'stackTrace': stackTrace.toString(),
      'timestamp': DateTime.now().toIso8601String(),
      'platform': _platform ?? 'unknown',
      'appVersion': _appVersion ?? 'unknown',
      'userId': _userId ?? 'unknown',
    };

    _apiService.post('/monitoring/errors', data: data).catchError((error) {
      debugPrint('Error sending error to CloudWatch: $error');
    });
  }

  // Other method implementations...
}
```

#### Performance Monitoring Utilities

```dart
// lib/utils/performance_monitoring.dart
class PerformanceMonitoring {
  static late MonitoringService _monitoringService;

  static void initialize(MonitoringService monitoringService) {
    _monitoringService = monitoringService;
    debugPrint('Performance monitoring initialized');
  }

  static Future<Duration> measureNetworkOperation({
    required String operationName,
    required Future<Duration> Function() operation,
    required Duration threshold,
  }) async {
    final stopwatch = Stopwatch()..start();

    try {
      final result = await operation();
      final duration = stopwatch.elapsed;

      _monitoringService.trackMetric(
        operationName,
        duration.inMilliseconds.toDouble(),
        MetricCategory.api,
      );

      if (duration > threshold) {
        debugPrint('⚠️ $operationName exceeded threshold: ${duration.inMilliseconds}ms > ${threshold.inMilliseconds}ms');
      }

      return result;
    } finally {
      stopwatch.stop();
    }
  }

  // Other measurement methods for UI, database, etc.
}
```

#### AWS Lambda Function for Metrics Collection

```javascript
// AWS Lambda function (soloadventurer-metrics-handler)
exports.handler = async (event) => {
  try {
    const body = JSON.parse(event.body);
    const {
      metricName,
      value,
      category,
      timestamp,
      platform,
      appVersion,
      userId,
    } = body;

    // Create CloudWatch client
    const cloudwatch = new AWS.CloudWatch();

    // Prepare metric data
    const params = {
      MetricData: [
        {
          MetricName: metricName,
          Dimensions: [
            { Name: "Category", Value: category },
            { Name: "Platform", Value: platform },
            { Name: "AppVersion", Value: appVersion },
            { Name: "UserId", Value: userId },
          ],
          Value: value,
          Timestamp: new Date(timestamp),
          Unit: "Milliseconds",
        },
      ],
      Namespace: "SoloAdventurer",
    };

    // Put metric data to CloudWatch
    await cloudwatch.putMetricData(params).promise();

    return {
      statusCode: 200,
      headers: {
        "Content-Type": "application/json",
        "Access-Control-Allow-Origin": "*",
      },
      body: JSON.stringify({ status: "success" }),
    };
  } catch (error) {
    console.error("Error processing metric:", error);

    return {
      statusCode: 500,
      headers: {
        "Content-Type": "application/json",
        "Access-Control-Allow-Origin": "*",
      },
      body: JSON.stringify({ status: "error", message: error.message }),
    };
  }
};
```

#### Example Performance Screen

We've implemented an example screen (`example_performance_screen.dart`) that demonstrates the use of performance monitoring utilities. This screen includes:

- Buttons to trigger various performance operations
- Display of operation durations
- A "Test CloudWatch" button to verify the CloudWatch integration
- Performance report generation

## Phase 2: Enhanced Monitoring (Post-MVP, 1000+ Users)

When the app reaches significant usage (1000+ active users), we will implement a more comprehensive monitoring strategy:

### Prometheus + Grafana Integration - 🔄 PLANNED FOR WEEKS 5-12

- **Prometheus for Metrics Collection**

  - Collect high-resolution metrics with better retention
  - Implement custom metrics for business-critical operations
  - Set up alerting based on metric thresholds
  - Enable powerful PromQL queries for troubleshooting

- **Grafana for Visualization**

  - Create comprehensive dashboards for different stakeholders
  - Combine metrics from multiple sources (CloudWatch, Prometheus)
  - Set up alerting with more sophisticated rules
  - Enable team collaboration on monitoring

- **Integration with Existing CloudWatch**
  - Use CloudWatch as a data source in Grafana
  - Maintain CloudWatch for AWS service monitoring
  - Use Prometheus for application-specific metrics

#### Implementation Plan

1. **Infrastructure Setup**

   ```yaml
   # docker-compose-monitoring.yml
   version: "3"

   services:
     prometheus:
       image: prom/prometheus:latest
       volumes:
         - ./prometheus/prometheus.yml:/etc/prometheus/prometheus.yml
         - prometheus_data:/prometheus
       command:
         - "--config.file=/etc/prometheus/prometheus.yml"
         - "--storage.tsdb.path=/prometheus"
         - "--web.console.libraries=/etc/prometheus/console_libraries"
         - "--web.console.templates=/etc/prometheus/consoles"
         - "--web.enable-lifecycle"
       ports:
         - "9090:9090"
       restart: unless-stopped

     grafana:
       image: grafana/grafana:latest
       volumes:
         - grafana_data:/var/lib/grafana
         - ./grafana/provisioning:/etc/grafana/provisioning
       environment:
         - GF_SECURITY_ADMIN_USER=admin
         - GF_SECURITY_ADMIN_PASSWORD=soloadventurer
         - GF_USERS_ALLOW_SIGN_UP=false
       ports:
         - "3000:3000"
       depends_on:
         - prometheus
       restart: unless-stopped

   volumes:
     prometheus_data:
     grafana_data:
   ```

2. **Prometheus Configuration**

   ```yaml
   # prometheus/prometheus.yml
   global:
     scrape_interval: 15s
     evaluation_interval: 15s

   scrape_configs:
     - job_name: "prometheus"
       static_configs:
         - targets: ["localhost:9090"]

     - job_name: "api_gateway"
       metrics_path: "/metrics"
       static_configs:
         - targets: ["api-gateway:8080"]

     - job_name: "lambda_functions"
       metrics_path: "/metrics"
       static_configs:
         - targets: ["lambda-metrics:8080"]
   ```

3. **Application Integration**

   ```dart
   // lib/services/monitoring/prometheus_monitoring.dart
   class PrometheusMonitoring implements MonitoringService {
     final ApiService _apiService;
     final String _metricsEndpoint;

     PrometheusMonitoring(this._apiService, this._metricsEndpoint);

     @override
     void trackMetric(String metricName, double value, MetricCategory category) {
       final data = {
         'metricName': metricName,
         'value': value,
         'category': category.toString().split('.').last,
         'timestamp': DateTime.now().millisecondsSinceEpoch,
       };

       _apiService.post('$_metricsEndpoint/metrics', data: data).catchError((error) {
         debugPrint('Error sending metric to Prometheus: $error');
       });
     }

     // Other method implementations...
   }
   ```

4. **Metrics Exporter Lambda**

   ```javascript
   // AWS Lambda function (soloadventurer-prometheus-exporter)
   const client = require("prom-client");

   // Create a Registry to register metrics
   const register = new client.Registry();

   // Create metrics
   const apiLatency = new client.Histogram({
     name: "api_request_duration_seconds",
     help: "Duration of API requests in seconds",
     labelNames: ["endpoint", "method", "status_code"],
     buckets: [0.1, 0.3, 0.5, 0.7, 1, 3, 5, 7, 10],
     registers: [register],
   });

   // Handler for metrics collection
   exports.collectMetrics = async (event) => {
     try {
       const body = JSON.parse(event.body);
       const { metricName, value, category } = body;

       // Update appropriate metric based on the category and name
       if (category === "api" && metricName.includes("request")) {
         const endpoint = metricName.split("_")[0];
         apiLatency.observe(
           { endpoint, method: "POST", status_code: 200 },
           value / 1000
         );
       }

       return {
         statusCode: 200,
         body: JSON.stringify({ status: "success" }),
       };
     } catch (error) {
       console.error("Error collecting metrics:", error);
       return {
         statusCode: 500,
         body: JSON.stringify({ status: "error", message: error.message }),
       };
     }
   };

   // Handler for metrics exposition
   exports.exposeMetrics = async () => {
     try {
       const metrics = await register.metrics();

       return {
         statusCode: 200,
         headers: { "Content-Type": register.contentType },
         body: metrics,
       };
     } catch (error) {
       console.error("Error exposing metrics:", error);
       return {
         statusCode: 500,
         body: JSON.stringify({ status: "error", message: error.message }),
       };
     }
   };
   ```

5. **Grafana Dashboard Configuration**
   ```json
   // grafana/provisioning/dashboards/api_performance.json
   {
     "annotations": {
       "list": [
         {
           "builtIn": 1,
           "datasource": "-- Grafana --",
           "enable": true,
           "hide": true,
           "iconColor": "rgba(0, 211, 255, 1)",
           "name": "Annotations & Alerts",
           "type": "dashboard"
         }
       ]
     },
     "editable": true,
     "gnetId": null,
     "graphTooltip": 0,
     "id": 1,
     "links": [],
     "panels": [
       {
         "aliasColors": {},
         "bars": false,
         "dashLength": 10,
         "dashes": false,
         "datasource": "Prometheus",
         "fieldConfig": {
           "defaults": {
             "custom": {}
           },
           "overrides": []
         },
         "fill": 1,
         "fillGradient": 0,
         "gridPos": {
           "h": 9,
           "w": 12,
           "x": 0,
           "y": 0
         },
         "hiddenSeries": false,
         "id": 2,
         "legend": {
           "avg": false,
           "current": false,
           "max": false,
           "min": false,
           "show": true,
           "total": false,
           "values": false
         },
         "lines": true,
         "linewidth": 1,
         "nullPointMode": "null",
         "options": {
           "alertThreshold": true
         },
         "percentage": false,
         "pluginVersion": "7.3.7",
         "pointradius": 2,
         "points": false,
         "renderer": "flot",
         "seriesOverrides": [],
         "spaceLength": 10,
         "stack": false,
         "steppedLine": false,
         "targets": [
           {
             "expr": "histogram_quantile(0.95, sum(rate(api_request_duration_seconds_bucket[5m])) by (le, endpoint))",
             "interval": "",
             "legendFormat": "{{endpoint}} - 95th percentile",
             "refId": "A"
           }
         ],
         "thresholds": [],
         "timeFrom": null,
         "timeRegions": [],
         "timeShift": null,
         "title": "API Request Duration (95th Percentile)",
         "tooltip": {
           "shared": true,
           "sort": 0,
           "value_type": "individual"
         },
         "type": "graph",
         "xaxis": {
           "buckets": null,
           "mode": "time",
           "name": null,
           "show": true,
           "values": []
         },
         "yaxes": [
           {
             "format": "s",
             "label": null,
             "logBase": 1,
             "max": null,
             "min": null,
             "show": true
           },
           {
             "format": "short",
             "label": null,
             "logBase": 1,
             "max": null,
             "min": null,
             "show": true
           }
         ],
         "yaxis": {
           "align": false,
           "alignLevel": null
         }
       }
     ],
     "schemaVersion": 26,
     "style": "dark",
     "tags": [],
     "templating": {
       "list": []
     },
     "time": {
       "from": "now-6h",
       "to": "now"
     },
     "timepicker": {},
     "timezone": "",
     "title": "API Performance",
     "uid": "api_performance",
     "version": 1
   }
   ```

### AWS X-Ray for Distributed Tracing - 🔄 PLANNED FOR WEEKS 19-24

- **End-to-End Request Tracing**

  - Track requests across multiple services
  - Identify bottlenecks in distributed systems
  - Visualize service dependencies
  - Analyze latency in each component

- **Integration with Existing Services**
  - Instrument Lambda functions
  - Add tracing to API Gateway
  - Implement client-side tracing in Flutter app

#### Implementation Plan

1. **AWS X-Ray SDK Integration**

   ```dart
   // lib/services/api/x_ray_interceptor.dart
   class XRayInterceptor extends Interceptor {
     final String _serviceName;

     XRayInterceptor(this._serviceName);

     @override
     void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
       final traceId = _generateXRayTraceId();
       options.headers['X-Amzn-Trace-Id'] = traceId;

       debugPrint('X-Ray trace ID: $traceId');

       super.onRequest(options, handler);
     }

     String _generateXRayTraceId() {
       final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
       final random = Random().nextInt(1000000000);

       return 'Root=1-${now.toRadixString(16).padLeft(8, '0')}-${random.toRadixString(16).padLeft(24, '0')};Parent=0000000000000000;Sampled=1';
     }
   }
   ```

2. **Lambda Function Instrumentation**

   ```javascript
   // AWS Lambda function with X-Ray tracing
   const AWSXRay = require("aws-xray-sdk-core");
   const AWS = AWSXRay.captureAWS(require("aws-sdk"));

   exports.handler = async (event) => {
     // Create subsegment for business logic
     const segment = AWSXRay.getSegment();
     const subsegment = segment.addNewSubsegment("BusinessLogic");

     try {
       // Business logic here
       const result = await processRequest(event);

       subsegment.close();
       return {
         statusCode: 200,
         body: JSON.stringify(result),
       };
     } catch (error) {
       subsegment.addError(error);
       subsegment.close();

       return {
         statusCode: 500,
         body: JSON.stringify({ error: error.message }),
       };
     }
   };
   ```

### Firebase Integration - 🔄 PLANNED FOR FUTURE

- **Firebase Crashlytics**

  - Mobile-specific crash reporting
  - User-session context for crashes
  - Detailed stack traces and device information

- **Firebase Performance Monitoring**
  - Mobile-focused performance metrics
  - Automatic HTTP request monitoring
  - Screen rendering time tracking
  - App startup time monitoring

## Phase 3: Advanced Monitoring (10,000+ Users)

For larger scale deployments, we'll implement:

### Elastic Stack (ELK) - 🔄 PLANNED FOR FUTURE

- **Elasticsearch**

  - Centralized log storage and indexing
  - Advanced search capabilities
  - Long-term log retention

- **Logstash**

  - Log processing and transformation
  - Multiple input and output plugins
  - Data enrichment

- **Kibana**
  - Advanced log visualization
  - Custom dashboards
  - Log-based alerting

### Custom Business Metrics - 🔄 PLANNED FOR FUTURE

- **User Engagement Metrics**

  - Active users (daily, weekly, monthly)
  - Session duration and frequency
  - Feature usage statistics
  - Conversion rates for key actions

- **Business Performance Metrics**
  - Revenue tracking
  - Subscription metrics
  - User acquisition cost
  - Lifetime value calculations

## Monitoring Integration Architecture

The following diagram illustrates how the different monitoring systems will integrate:

```
┌─────────────────┐     ┌───────────────┐     ┌─────────────────┐
│                 │     │               │     │                 │
│  Flutter App    │────▶│  API Gateway  │────▶│  Lambda         │
│                 │     │               │     │                 │
└────────┬────────┘     └───────┬───────┘     └────────┬────────┘
         │                      │                      │
         │                      │                      │
         ▼                      ▼                      ▼
┌─────────────────┐     ┌───────────────┐     ┌─────────────────┐
│                 │     │               │     │                 │
│  CloudWatch     │◀────┤  X-Ray        │◀────┤  Prometheus     │
│                 │     │               │     │                 │
└────────┬────────┘     └───────┬───────┘     └────────┬────────┘
         │                      │                      │
         │                      │                      │
         └──────────────────────┼──────────────────────┘
                               │
                               ▼
                      ┌─────────────────┐
                      │                 │
                      │  Grafana        │
                      │                 │
                      └─────────────────┘
```

## Monitoring Responsibility Matrix

| Monitoring System | Primary Responsibility | Secondary Responsibility  |
| ----------------- | ---------------------- | ------------------------- |
| CloudWatch        | AWS service monitoring | Basic application metrics |
| Prometheus        | Application metrics    | Service health checks     |
| X-Ray             | Distributed tracing    | Performance bottlenecks   |
| Grafana           | Visualization          | Alerting                  |
| Firebase          | Mobile-specific issues | User experience metrics   |

## Cost Considerations

| Monitoring System  | Estimated Monthly Cost (1K users) | Estimated Monthly Cost (10K users) | Estimated Monthly Cost (100K users) |
| ------------------ | --------------------------------- | ---------------------------------- | ----------------------------------- |
| CloudWatch         | $50-100                           | $200-400                           | $1,000-2,000                        |
| Prometheus+Grafana | $100-200                          | $300-500                           | $800-1,500                          |
| X-Ray              | $50-100                           | $200-500                           | $1,000-3,000                        |
| Firebase           | $0 (Free tier)                    | $50-150                            | $300-800                            |
| **Total**          | **$200-400**                      | **$750-1,550**                     | **$3,100-7,300**                    |

## Implementation Timeline

| Phase | Monitoring System  | Implementation Timeframe |
| ----- | ------------------ | ------------------------ |
| 1     | CloudWatch         | Weeks 1-4 (✅ COMPLETED) |
| 2     | Prometheus+Grafana | Weeks 5-12               |
| 2     | X-Ray              | Weeks 19-24              |
| 2     | Firebase           | Post-MVP                 |
| 3     | ELK Stack          | 10,000+ users            |
| 3     | Custom Business    | 10,000+ users            |

## Success Metrics for Monitoring

- **Coverage**: % of critical user flows being monitored
- **Alerting Accuracy**: % of alerts that represent actual issues
- **MTTR**: Mean time to resolution for detected issues
- **Proactive Detection**: % of issues detected before user reports

## CloudWatch Dashboard Setup

We've created a CloudWatch dashboard for visualizing key metrics:

1. **API Performance Metrics**

   - API call durations by endpoint
   - Error rates by API category
   - Threshold breaches

2. **User Experience Metrics**

   - UI operation durations
   - Screen rendering times
   - Authentication operation durations

3. **Error Tracking**
   - Error counts by type
   - Error rates over time
   - Critical errors with alerts

## Testing and Verification

We've conducted comprehensive testing of the monitoring implementation to ensure it functions correctly:

### App-Side Testing

1. **Initialization Testing**

   - ✅ Verified that the monitoring service initializes correctly on app startup
   - ✅ Confirmed that the initialization log message appears in the console
   - ✅ Tested initialization with different API service configurations

2. **Performance Monitoring Testing**

   - ✅ Tested `measureNetworkOperation` with various thresholds and durations
   - ✅ Tested `measureUiOperation` with different UI rendering scenarios
   - ✅ Verified threshold breach detection and reporting
   - ✅ Tested performance report generation functionality

3. **Error Handling Testing**

   - ✅ Tested global error handler with various error types
   - ✅ Verified that Flutter errors are properly caught and reported
   - ✅ Tested error context inclusion in reports
   - ✅ Verified that the app continues to function after error reporting

4. **Example Screen Testing**
   - ✅ Verified that the "Test CloudWatch" button sends a test metric
   - ✅ Tested UI feedback for successful and failed metric transmission
   - ✅ Verified that performance operations correctly measure and report durations
   - ✅ Tested the performance report display

### AWS-Side Testing

1. **Lambda Function Testing**

   - ✅ Tested the Lambda function with various metric payloads
   - ✅ Verified error handling for malformed requests
   - ✅ Tested CloudWatch client integration
   - ✅ Verified proper dimension handling for metrics

2. **API Gateway Testing**

   - ✅ Tested the API endpoint with direct requests
   - ✅ Verified CORS configuration for cross-origin requests
   - ✅ Tested authentication and authorization (when applicable)

3. **CloudWatch Integration Testing**
   - ✅ Verified that metrics appear in the CloudWatch console
   - ✅ Confirmed that metrics have the correct dimensions (Category, Platform, AppVersion, UserId)
   - ✅ Tested metric visualization in the CloudWatch dashboard
   - ✅ Verified that metrics are properly grouped and filterable

### Test Results

All tests have been successfully completed, confirming that:

1. The monitoring system correctly captures and reports performance metrics
2. Error handling functions as expected, with proper context information
3. The AWS infrastructure correctly processes and stores metrics
4. The CloudWatch dashboard accurately displays the collected metrics

## Next Steps

1. **Set up CloudWatch Alarms** for critical thresholds
2. **Create additional Lambda functions** for error and event tracking
3. **Implement automated testing** of the monitoring pipeline
4. **Document alert response procedures** for the team

## Monitoring Cost Optimization

As our monitoring infrastructure grows, it's important to implement cost optimization strategies to ensure we're getting maximum value without unnecessary expenses. Here are specific strategies for each component of our monitoring stack:

### CloudWatch Cost Optimization

1. **Selective Metric Collection**

   ```javascript
   // Lambda function to filter metrics before sending to CloudWatch
   exports.handler = async (event) => {
     const { metricName, value, category } = JSON.parse(event.body);

     // Only send metrics that exceed thresholds or are critical
     const criticalMetrics = ['api_error_rate', 'authentication_failure', 'database_connection_error'];
     const isHighValue = value > THRESHOLD_MAP[metricName] || criticalMetrics.includes(metricName);

     if (isHighValue) {
       // Send to CloudWatch
       await cloudwatch.putMetricData({...}).promise();
     } else {
       // Store in lower-cost storage or aggregate
       await storeMetricLocally({...});
     }
   };
   ```

2. **Metric Resolution Optimization**

   - Use 1-minute resolution only for critical metrics
   - Use 5-minute resolution for standard metrics
   - Use hourly resolution for long-term trend metrics

3. **Log Volume Reduction**

   ```terraform
   resource "aws_cloudwatch_log_group" "api_logs" {
     name              = "/aws/lambda/api-function"
     retention_in_days = 14  # Shorter retention for high-volume logs
   }

   resource "aws_cloudwatch_log_group" "critical_logs" {
     name              = "/aws/lambda/critical-function"
     retention_in_days = 90  # Longer retention only for critical logs
   }
   ```

### Prometheus & Grafana Cost Optimization

1. **Efficient Storage Configuration**

   ```yaml
   # prometheus.yml
   global:
     scrape_interval: 30s # Default is 15s, increase to reduce storage
     evaluation_interval: 30s

   storage:
     tsdb:
       retention.time: 15d # Keep data for 15 days instead of default 30
       retention.size: 10GB # Limit total storage size
   ```

2. **Managed Service vs. Self-Hosted**

   - Use Amazon Managed Service for Prometheus (AMP) to eliminate infrastructure management costs
   - Cost comparison: Self-hosted ($200-300/month) vs. AMP ($100-150/month) for similar workloads

   ```terraform
   # Use Amazon Managed Service for Prometheus
   module "amp" {
     source  = "terraform-aws-modules/managed-service-prometheus/aws"
     version = "~> 2.1"

     workspace_alias = "soloadventurer-metrics"

     scraper_security_group_rules = {
       egress_to_prometheus = {
         type        = "egress"
         from_port   = 9090
         to_port     = 9090
         protocol    = "tcp"
         cidr_blocks = ["10.0.0.0/16"]
       }
     }
   }
   ```

3. **Grafana Dashboard Optimization**

   - Use variables and templates to create reusable dashboards instead of duplicating panels
   - Implement proper caching for dashboard queries

   ```yaml
   # grafana.ini
   [dashboards]
   versions_to_keep = 5  # Limit dashboard version history

   [panels]
   disable_sanitize_html = false  # Security measure

   [dataproxy]
   timeout = 30  # Reduce long-running queries
   ```

### X-Ray Cost Optimization

1. **Sampling Rules**

   ```json
   // xray-sampling-rules.json
   {
     "SamplingRule": {
       "RuleName": "Default",
       "ResourceARN": "*",
       "Priority": 10000,
       "FixedRate": 0.05, // Sample 5% of requests
       "ReservoirSize": 1,
       "ServiceName": "*",
       "ServiceType": "*",
       "Host": "*",
       "HTTPMethod": "*",
       "URLPath": "*",
       "Version": 1
     }
   }
   ```

2. **Critical Path Tracing**

   ```javascript
   // Only trace important paths
   const AWSXRay = require("aws-xray-sdk");

   // Configure custom sampling rules
   const rules = {
     rules: [
       {
         description: "Critical API paths",
         host: "*",
         http_method: "*",
         url_path: "/api/critical/*",
         fixed_target: 1,
         rate: 1.0,
       },
       {
         description: "Standard paths",
         host: "*",
         http_method: "*",
         url_path: "*",
         fixed_target: 0,
         rate: 0.05,
       },
     ],
     default: {
       fixed_target: 0,
       rate: 0.01,
     },
     version: 1,
   };

   AWSXRay.middleware.setSamplingRules(rules);
   ```

### Firebase Monitoring Cost Optimization

1. **Selective Event Logging**

   ```dart
   // Only log important events to Firebase
   void logEvent(String name, Map<String, dynamic> parameters) {
     final importantEvents = [
       'signup_completed',
       'purchase_made',
       'critical_error',
       'trip_booked'
     ];

     if (importantEvents.contains(name) ||
         parameters.containsKey('is_critical')) {
       FirebaseAnalytics.instance.logEvent(
         name: name,
         parameters: parameters,
       );
     } else {
       // Log to local analytics only
       _localAnalytics.logEvent(name, parameters);
     }
   }
   ```

2. **Crashlytics Optimization**

   ```dart
   // Configure Crashlytics to reduce unnecessary reports
   await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(
     !kDebugMode && _userHasOptedIn
   );

   // Set custom keys only for important context
   FirebaseCrashlytics.instance.setCustomKey('last_action', lastUserAction);
   FirebaseCrashlytics.instance.setCustomKey('user_tier', userSubscriptionTier);
   ```

### Monitoring Cost Comparison

| Monitoring Approach      | Monthly Cost (1K users) | Monthly Cost (10K users) | Monthly Cost (100K users) | Cost-Saving Techniques               |
| ------------------------ | ----------------------- | ------------------------ | ------------------------- | ------------------------------------ |
| CloudWatch Only          | $50-100                 | $200-400                 | $1,000-2,000              | Metric filtering, reduced resolution |
| Prometheus (Self-hosted) | $150-250                | $300-500                 | $800-1,500                | Storage optimization, sampling       |
| Prometheus (AMP)         | $75-125                 | $150-300                 | $500-1,000                | Managed service efficiencies         |
| X-Ray (100% sampling)    | $100-200                | $400-800                 | $2,000-4,000              | N/A                                  |
| X-Ray (5% sampling)      | $5-10                   | $20-40                   | $100-200                  | Intelligent sampling rules           |
| Firebase (full)          | $0 (Free tier)          | $100-300                 | $500-1,200                | N/A                                  |
| Firebase (optimized)     | $0 (Free tier)          | $50-150                  | $250-600                  | Selective event logging              |
| **Optimized Stack**      | **$130-235**            | **$420-790**             | **$1,350-2,800**          | **Combined strategies**              |

### Monitoring Cost Optimization Roadmap

#### Phase 1: Immediate Optimizations (Current)

- Implement CloudWatch metric filtering
- Set appropriate log retention periods
- Configure basic X-Ray sampling

#### Phase 2: Enhanced Optimizations (1,000+ Users)

- Deploy Amazon Managed Service for Prometheus
- Implement intelligent X-Ray sampling rules
- Configure selective Firebase event logging

#### Phase 3: Advanced Optimizations (10,000+ Users)

- Implement metric aggregation and downsampling
- Set up multi-tier storage for logs (hot/warm/cold)
- Create custom monitoring dashboards optimized for performance

### Monitoring Cost Governance

1. **Budget Alerts**

   ```terraform
   resource "aws_budgets_budget" "monitoring" {
     name              = "monitoring-budget"
     budget_type       = "COST"
     limit_amount      = "500"
     limit_unit        = "USD"
     time_unit         = "MONTHLY"

     notification {
       comparison_operator = "GREATER_THAN"
       threshold           = 80
       threshold_type      = "PERCENTAGE"
       notification_type   = "ACTUAL"
     }

     cost_filter {
       name = "Service"
       values = [
         "AmazonCloudWatch",
         "AmazonOpenSearchService",
         "AWSXRay"
       ]
     }
   }
   ```

2. **Regular Cost Reviews**

   - Schedule monthly cost review meetings
   - Analyze cost trends and identify optimization opportunities
   - Document cost-saving measures implemented and their impact

3. **Monitoring Efficiency Metrics**
   - Track cost per monitored service
   - Measure alert signal-to-noise ratio
   - Calculate cost per detected incident
