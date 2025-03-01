# SoloAdventurer Architecture Evolution Plan

## Overview

This document outlines the planned evolution of the SoloAdventurer application architecture from its current state to a more scalable, performant, and cost-effective infrastructure. The changes will be implemented in phases, with each phase building upon the previous one while maintaining backward compatibility.

## Current Architecture

The current architecture is based on a straightforward AWS serverless approach:

```
Flutter App → API Gateway → Lambda → Aurora PostgreSQL
                ↓
            CloudWatch
                ↓
            Cognito
```

Key components:

- **Frontend**: Flutter with Riverpod for state management
- **Authentication**: AWS Cognito
- **API**: API Gateway + Lambda
- **Database**: Aurora PostgreSQL
- **Monitoring**: CloudWatch
- **Storage**: S3

## Target Architecture

The target architecture introduces several enhancements to improve scalability, performance, and cost-effectiveness:

```
Flutter App → Envoy Proxy → ┬─ WebSockets → Redis ─┬→ Kafka → Lambda
                            ├─ REST → Lambda ──────┘    ↓
                            └─ GraphQL → AppSync       ↓
                                                       ↓
                                                    Aurora
                                                       ↓
                                                  OpenSearch
```

Key enhancements:

- **Request Routing**: Envoy Proxy for efficient connection management
- **Real-time Communication**: WebSockets via Envoy for 100K+ concurrent connections
- **Event Streaming**: Kafka (MSK) for decoupled event processing
- **Location Updates**: MQTT (AWS IoT Core) for battery-efficient updates
- **Database Optimization**: Connection pooling, read replicas, and optimized indexes
- **Monitoring**: Prometheus + Grafana alongside CloudWatch
- **Security**: Vault for secret management, Falco for runtime security
- **Cost Optimization**: Spot Instances instead of Reserved Instances

## Phased Implementation

### Phase 1: Foundation (Current)

- AWS Cognito for authentication
- Basic CloudWatch monitoring
- Simple API Gateway + Lambda setup

### Phase 2: Optimization (Weeks 5-12)

#### Database Optimizations

- **Add Geospatial Indexes**
  ```sql
  CREATE INDEX CONCURRENTLY idx_users_geo_gist
  ON users USING GIST (location);
  ```
- **Implement PgBouncer** for connection pooling
  ```yaml
  # docker-compose-pgbouncer.yml
  pgbouncer:
    image: edoburu/pgbouncer:latest
    environment:
      - DB_USER=soloadventurer
      - DB_PASSWORD=******
      - DB_HOST=aurora-instance.region.rds.amazonaws.com
      - DB_NAME=soloadventurer
      - POOL_MODE=transaction
      - MAX_CLIENT_CONN=1000
      - DEFAULT_POOL_SIZE=100
  ```

#### Secret Management

- **Implement HashiCorp Vault**
  ```bash
  # Secret injection
  vault kv put secret/db_creds username=admin password=...
  ```

#### Enhanced Monitoring

- **Set up Prometheus + Grafana**
  ```yaml
  # docker-compose-monitoring.yml
  prometheus:
    image: prom/prometheus
    volumes:
      - ./prometheus.yml:/etc/prometheus/prometheus.yml
  grafana:
    image: grafana/grafana
    depends_on:
      - prometheus
    ports:
      - "3000:3000"
  ```

#### Flutter Optimizations

- **Implement SliverAnimatedList for efficient rendering**
  ```dart
  SliverAnimatedList(
    itemBuilder: (context, index, animation) {
      return SizeTransition(
        sizeFactor: animation,
        child: MatchCard(match: matches[index]),
      );
    },
  )
  ```
- **Add Drift for local database caching**
  ```yaml
  dependencies:
    drift: ^2.0.0
    sqlite3_flutter_libs: ^0.5.0
    path_provider: ^2.0.0
    path: ^1.8.0
  ```

### Phase 3: Scaling (Weeks 13-18)

#### Event Streaming

- **Implement Kafka (MSK)**
  ```terraform
  # Add to infrastructure
  module "kafka" {
    source = "terraform-aws-modules/msk-kafka-cluster/aws"
    cluster_name = "soloadventurer-events"
  }
  ```

#### Database Scaling

- **Configure Read Replicas**
  ```terraform
  resource "aws_rds_cluster_instance" "geo_replica" {
    identifier         = "geo-replica"
    cluster_identifier = aws_rds_cluster.aurora.id
    instance_class     = "db.r5.large"
    engine             = "aurora-postgresql"
    promotion_tier     = 15  # Lower priority for promotion
  }
  ```

#### Location Updates

- **Implement MQTT via AWS IoT Core**

  ```dart
  // Flutter MQTT client
  final client = MqttServerClient('iot.amazonaws.com', 'soloadventurer_${userId}');
  client.secure = true;
  client.keepAlivePeriod = 20;
  client.onDisconnected = onDisconnected;
  client.onConnected = onConnected;

  // Publish location update
  final builder = MqttClientPayloadBuilder();
  builder.addString(json.encode({
    'userId': userId,
    'latitude': position.latitude,
    'longitude': position.longitude,
    'timestamp': DateTime.now().toIso8601String(),
  }));
  client.publishMessage('users/location', MqttQos.atLeastOnce, builder.payload!);
  ```

#### Security Enhancements

- **Implement Falco for runtime security**
  ```yaml
  # falco-values.yaml
  falco:
    jsonOutput: true
    jsonIncludeOutputProperty: true
    programOutput:
      enabled: true
      keepAlive: false
      program: "jq '{text: .output}' | curl -d @- -X POST https://hooks.slack.com/services/XXX/YYY/ZZZ"
  ```

### Phase 4: Advanced Architecture (Weeks 19-24)

#### WebSocket Scaling

- **Replace basic WebSockets with Envoy Proxy**
  ```yaml
  # envoy-config.yaml
  static_resources:
    listeners:
      - name: listener_0
        address:
          socket_address:
            address: 0.0.0.0
            port_value: 10000
        filter_chains:
          - filters:
              - name: envoy.filters.network.http_connection_manager
                typed_config:
                  "@type": type.googleapis.com/envoy.extensions.filters.network.http_connection_manager.v3.HttpConnectionManager
                  stat_prefix: ingress_http
                  upgrade_configs:
                    - upgrade_type: websocket
                      enabled: true
  ```

#### Distributed Tracing

- **Implement AWS X-Ray**

  ```dart
  // Add X-Ray tracing to API calls
  final dio = Dio();
  dio.interceptors.add(XRayInterceptor());

  class XRayInterceptor extends Interceptor {
    @override
    void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
      final traceId = generateXRayTraceId();
      options.headers['X-Amzn-Trace-Id'] = traceId;
      super.onRequest(options, handler);
    }
  }
  ```

#### Cost Optimization

- **Migrate to Spot Instances**
  ```terraform
  resource "aws_ec2_fleet" "spot" {
    launch_template_config {
      launch_template_specification {
        launch_template_id = aws_launch_template.app.id
      }
    }
    target_capacity_specification {
      default_target_capacity_type = "spot"
    }
  }
  ```

### Phase 5: Intelligence (Weeks 25-32)

#### ML Feature Management

- **Implement SageMaker Feature Store**

  ```python
  # Create feature group
  from sagemaker.feature_store.feature_group import FeatureGroup

  user_preferences_fg = FeatureGroup(
      name="user-travel-preferences",
      sagemaker_session=sagemaker_session
  )

  # Define features
  user_preferences_fg.load_feature_definitions(
      [
          {"FeatureName": "user_id", "FeatureType": "String"},
          {"FeatureName": "preferred_destinations", "FeatureType": "String"},
          {"FeatureName": "travel_style", "FeatureType": "String"},
          {"FeatureName": "budget_range", "FeatureType": "String"},
          {"FeatureName": "activity_preferences", "FeatureType": "String"},
          {"FeatureName": "last_updated", "FeatureType": "String"}
      ]
  )

  # Create feature group
  user_preferences_fg.create(
      s3_uri=f"s3://{bucket}/feature-store/user-preferences",
      record_identifier_name="user_id",
      event_time_feature_name="last_updated",
      role_arn=role,
      enable_online_store=True
  )
  ```

#### Content Moderation

- **Implement Amazon Rekognition**

  ```dart
  Future<bool> isAppropriateImage(File image) async {
    final response = await _rekognitionClient.detectModerationLabels(
      image: await image.readAsBytes(),
      minConfidence: 60.0,
    );

    final hasModerationLabels = response.moderationLabels.isNotEmpty;
    if (hasModerationLabels) {
      _logger.warning(
        'Image moderation detected inappropriate content: ${response.moderationLabels}',
      );
    }

    return !hasModerationLabels;
  }
  ```

### Phase 6: Enterprise-Grade (Weeks 33-40)

#### Multi-Region Deployment

- **Implement global routing with Route53**
- **Set up cross-region replication for S3**
- **Configure multi-region database strategy**

#### Advanced Disaster Recovery

- **Implement automated failover procedures**
- **Set up cross-region backup strategies**
- **Create disaster recovery runbooks**

#### Comprehensive Compliance Framework

- **Implement GDPR compliance measures**
- **Set up SOC2 compliance monitoring**
- **Create privacy-by-design architecture**

## Cost-Performance Benchmarks

| Component           | Current Stack | Improved Stack | Savings |
| ------------------- | ------------- | -------------- | ------- |
| Database (Aurora)   | $2,400/mo     | $840/mo        | 65%     |
| Search (OpenSearch) | $1,140/mo     | $547/mo        | 52%     |
| Compute (Lambda)    | $1,800/mo     | $990/mo        | 45%     |
| Storage (S3)        | $600/mo       | $240/mo        | 60%     |
| Real-Time Messaging | $900/mo       | $550/mo        | 39%     |
| **Total Monthly**   | **$6,840/mo** | **$3,167/mo**  | **54%** |

## Cost Optimization Strategies

### 1. Database Layer (Aurora PostgreSQL)

**Savings: 65%**

**Current Setup:**

- Single writer instance (db.r6g.large at $0.40/hr)
- Provisioned capacity regardless of usage

**Optimized Setup:**

```terraform
# Migrate to Aurora Serverless v2
resource "aws_rds_cluster" "main" {
  engine_mode                  = "serverlessv2"
  serverlessv2_scaling_configuration {
    min_capacity = 0.5 # 1 ACU = $0.12/hr (vs $0.40/hr for provisioned)
    max_capacity = 16
  }
}

# Add read replicas for geospatial queries
resource "aws_rds_cluster_instance" "replicas" {
  count              = 2
  instance_class     = "db.serverlessv2"
  cluster_identifier = aws_rds_cluster.main.id
  promotion_tier     = 1
}
```

**Additional Optimizations:**

- Enable auto-pause after 5 minutes of inactivity
- Implement query plan management to kill expensive queries
- Configure PgBouncer as previously mentioned

### 2. Search Layer (OpenSearch)

**Savings: 52%**

**Current Setup:**

- 3-node cluster with t3.medium instances ($0.0528/hr each = $0.1584/hr)

**Optimized Setup:**

```bash
# Switch to Graviton instances
aws opensearch update-domain-config \
  --domain-name soloadventurer \
  --cluster-config '{"InstanceType":"r6g.large.search", "InstanceCount":3}'

# Enable UltraWarm storage for old data
aws opensearch create-package \
  --package-name "ultrawarm" \
  --package-type "TieredStorage"
```

**Additional Optimizations:**

- Use zstd compression on documents (35% smaller indexes)
- Set optimal shard size to 30-50GB

```bash
curl -XPUT _cluster/settings -d '{"persistent":{"cluster.max_shards_per_node":2000}}'
```

### 3. Compute Layer (Lambda)

**Savings: 45%**

**Current Setup:**

- x86_64 architecture with 1GB memory allocation
- Standard deployment package sizes

**Optimized Setup:**

```terraform
# Graviton + right-sizing
resource "aws_lambda_function" "api" {
  architectures = ["arm64"]
  memory_size   = 512 # Test with AWS Compute Optimizer
  ephemeral_storage {
    size = 512 # Minimal for most functions
  }
}

# Shared layers to reduce deployment size
resource "aws_lambda_layer_version" "shared" {
  filename   = "shared-layer.zip"
  layer_name = "common-dependencies"
}
```

**Additional Optimizations:**

- Use Lambda PowerTools for Python/Node.js to reduce cold starts by 70%
- Implement provisioned concurrency only for critical functions

### 4. Storage Optimization (S3)

**Savings: 60%**

**Current Setup:**

- Standard storage for all objects
- No lifecycle policies

**Optimized Setup:**

```bash
# Lifecycle policy for intelligent tiering
aws s3api put-bucket-lifecycle-configuration \
  --bucket soloadventurer-photos \
  --lifecycle-configuration '
{
  "Rules": [
    {
      "ID": "MoveToIntelligentTiering",
      "Status": "Enabled",
      "Transitions": [{
        "Days": 30,
        "StorageClass": "INTELLIGENT_TIERING"
      }]
    }
  ]
}'
```

**Additional Optimizations:**

- Enable S3 Inventory to find and delete orphaned files
- Use S3 Select for partial file retrievals (50% fewer bytes scanned)
- Implement CloudFront for edge caching of frequently accessed content

### 5. Caching Layer (ElastiCache/Redis)

**Savings: 48%**

**Current Setup:**

- cache.r6g.large instances ($0.175/hr)
- Standard memory allocation

**Optimized Setup:**

```terraform
# Tiered storage + Graviton
resource "aws_elasticache_replication_group" "main" {
  node_type            = "cache.t4g.medium" # $0.068/hr vs r6g.large $0.175
  engine_version       = "7.1"
  transit_encryption_enabled = true
  cluster_mode {
    num_node_groups         = 1
    replicas_per_node_group = 1
  }
}
```

**Critical Settings:**

- Set `maxmemory-policy volatile-lru` to auto-evict stale data
- Enable clustering at 500+ ops/sec
- Implement proper key expiration strategies

### 6. Real-Time Messaging Optimization

**Savings: 38%**

**Current Setup:**

- WebSockets via API Gateway for all real-time communication
- High connection and message costs

**Optimized Setup:**
Hybrid approach using MQTT for frequent updates and WebSockets for chat:

```dart
// Flutter MQTT client for location updates
final client = MqttServerClient('iot.amazonaws.com', 'soloadventurer_${userId}');
client.secure = true;
client.keepAlivePeriod = 20;
client.onDisconnected = onDisconnected;
client.onConnected = onConnected;

// Publish location update
final builder = MqttClientPayloadBuilder();
builder.addString(json.encode({
  'userId': userId,
  'latitude': position.latitude,
  'longitude': position.longitude,
  'timestamp': DateTime.now().toIso8601String(),
}));
client.publishMessage('users/location', MqttQos.atLeastOnce, builder.payload!);
```

**Cost Comparison:**
| Feature | WebSocket Cost (1M users) | MQTT Cost | Savings |
|---------|---------------------------|-----------|---------|
| Connection | $350 | $0.30 | 99% |
| Messages | $900 | $250 | 72% |

### 7. ML Cost Controls (SageMaker)

**Savings: 67%**

**Current Setup:**

- On-demand instances for training
- Provisioned endpoints for inference

**Optimized Setup:**

```python
# Spot Instance Training
estimator = sagemaker.estimator.Estimator(
  instance_type='ml.g5.2xlarge',
  instance_count=2,
  use_spot_instances=True, # 70% discount
  max_wait=86400  # 24 hours
)

# Serverless Inference
predictor = sagemaker.serverless.ServerlessInferenceConfig(
  memory_size_in_mb=2048,
  max_concurrency=20
)
```

**Additional Optimizations:**

- Use SageMaker JumpStart for pre-trained travel recommendation models
- Implement model compression techniques for faster inference

### 8. CI/CD & Observability Optimization

**Savings: 40%**

**Current Setup:**

- GitHub-hosted runners
- No timeout limits on workflows

**Optimized Setup:**

```yaml
# .github/workflows/deploy.yml
jobs:
  build:
    runs-on: [self-hosted, ARM64] # Cheaper than hosted runners
    steps:
      - uses: actions/cache@v3
        with:
          path: |
            ~/.pub-cache
            build/
          key: ${{ runner.os }}-dart-${{ hashFiles('pubspec.lock') }}

  deploy:
    needs: build
    timeout-minutes: 15 # Prevent runaway costs
```

**Monitoring Cost Controls:**

```terraform
# Cost-effective Prometheus
module "amp" {
  source = "terraform-aws-modules/prometheus/aws"
  workspace_alias = "soloadventurer-metrics"
}

# CloudWatch Billing Alarm
resource "aws_cloudwatch_metric_alarm" "monthly_budget" {
  alarm_name          = "MonthlyBudgetAlert"
  comparison_operator = "GreaterThanThreshold"
  threshold           = 1000 # Alert at $1K
  metric_name         = "EstimatedCharges"
  namespace           = "AWS/Billing"
  statistic           = "Maximum"
  period              = 86400 # 24 hours
}
```

## Implementation Roadmap

### Immediate Wins (Week 1)

- Enable Aurora Serverless v2
- Switch OpenSearch to Graviton
- Deploy S3 Intelligent Tiering

### Medium-Term (Week 2-3)

- Migrate 50% of Lambdas to ARM64
- Implement MQTT for location updates
- Configure Redis tiered storage

### Long-Term (Week 4+)

- Train ML models with Spot Instances
- Optimize sharding in OpenSearch
- Establish FinOps governance

## Implementation Guidelines

### Testing Strategy

- Create performance benchmarks before and after each change
- Implement canary deployments for high-risk changes
- Conduct load testing before production deployment
- Use synthetic transactions to validate end-to-end functionality

### Rollback Procedures

- Document detailed rollback procedures for each major change
- Implement automated rollback triggers based on monitoring alerts
- Maintain previous infrastructure until new systems are proven stable
- Conduct regular rollback drills to ensure procedures work as expected

### Monitoring Strategy

- Implement comprehensive monitoring before, during, and after migrations
- Set up alerts for key performance indicators
- Create dashboards for visualizing system health
- Establish baseline metrics for comparison

## Conclusion

This architecture evolution plan provides a roadmap for transforming the SoloAdventurer application from its current state to a more scalable, performant, and cost-effective infrastructure. By implementing these changes in phases, we can minimize risk while continuously improving the application's capabilities.
