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

## Revised Phased Implementation

### Phase 1: Foundation (Completed)

- AWS Cognito for authentication
- Basic CloudWatch monitoring
- Simple API Gateway + Lambda setup
- Initial Flutter app with basic state management
- Core authentication flows

### Phase 2: Testing & Architecture Refinement (Current Focus)

#### AWS Cognito Integration

- **Token Lifecycle Management**

  ```dart
  class TokenManager {
    final FlutterSecureStorage _storage;
    final Duration _refreshThreshold;

    Future<void> storeTokens(AuthTokens tokens) async {
      await _storage.write(key: 'access_token', value: tokens.accessToken);
      await _storage.write(key: 'refresh_token', value: tokens.refreshToken);
      _scheduleTokenRefresh();
    }

    Future<AuthTokens?> getStoredTokens() async {
      final accessToken = await _storage.read(key: 'access_token');
      final refreshToken = await _storage.read(key: 'refresh_token');
      if (accessToken == null || refreshToken == null) return null;
      return AuthTokens(accessToken, refreshToken);
    }
  }
  ```

- **Session Management**

  ```dart
  @riverpod
  class SessionController extends _$SessionController {
    Timer? _refreshTimer;

    @override
    AsyncValue<SessionState> build() {
      ref.onDispose(() {
        _refreshTimer?.cancel();
      });
      return const AsyncValue.data(SessionState.initial());
    }

    Future<void> initialize() async {
      state = const AsyncValue.loading();
      state = await AsyncValue.guard(() async {
        final tokens = await _tokenManager.getStoredTokens();
        if (tokens != null) {
          await _validateAndRefreshTokens(tokens);
          return SessionState.authenticated;
        }
        return SessionState.unauthenticated;
      });
    }
  }
  ```

- **Error Handling**

  ```dart
  sealed class AuthError {
    final String message;
    final String code;
  }

  class UserNotFoundError extends AuthError {
    UserNotFoundError() : super(
      message: 'No account found with this email',
      code: 'USER_NOT_FOUND',
    );
  }

  @riverpod
  class ErrorHandler extends _$ErrorHandler {
    @override
    void build() {
      ref.listen(authStateProvider, (previous, next) {
        next.whenOrNull(
          error: (error, stack) => _handleError(error, stack),
        );
      });
    }
  }
  ```

#### Riverpod State Management

- **Authentication State**

  ```dart
  @riverpod
  class AuthController extends _$AuthController {
    @override
    AsyncValue<AuthState> build() => const AsyncValue.data(AuthState.initial());

    Future<void> signIn(String email, String password) async {
      state = const AsyncValue.loading();
      state = await AsyncValue.guard(() async {
        final result = await _authRepository.signIn(email, password);
        await _tokenManager.storeTokens(result.tokens);
        return AuthState.authenticated(result.user);
      });
    }
  }
  ```

- **Loading States**

  ```dart
  sealed class LoadingState {
    const LoadingState();
  }

  class InitialLoading extends LoadingState {
    const InitialLoading();
  }

  class ContentLoading extends LoadingState {
    final AuthState currentState;
    const ContentLoading(this.currentState);
  }
  ```

- **Error States**

  ```dart
  @riverpod
  class AuthError extends _$AuthError {
    @override
    AsyncValue<void> build() => const AsyncValue.data(null);

    void handleError(Object error, StackTrace stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }

    void clearError() {
      state = const AsyncValue.data(null);
    }
  }
  ```

#### Testing Infrastructure

- **Provider Testing**

  ```dart
  void main() {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer(
        overrides: [
          authRepositoryProvider.overrideWithValue(MockAuthRepository()),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    test('AuthController sign in success', () async {
      final controller = container.read(authControllerProvider.notifier);
      await controller.signIn('test@example.com', 'password');

      expect(
        container.read(authControllerProvider),
        isA<AsyncData<AuthState>>(),
      );
    });
  }
  ```

- **Integration Testing**

  ```dart
  void main() {
    testWidgets('Full authentication flow', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: LoginScreen(),
          ),
        ),
      );

      // Test the complete authentication flow
      await tester.enterText(
        find.byKey(const Key('email_field')),
        'test@example.com',
      );
      await tester.enterText(
        find.byKey(const Key('password_field')),
        'password',
      );

      await tester.tap(find.byKey(const Key('login_button')));
      await tester.pumpAndSettle();

      expect(find.byType(HomeScreen), findsOneWidget);
    });
  }
  ```

- **Error Testing**

  ```dart
  test('AuthController handles network error', () async {
    final container = ProviderContainer(
      overrides: [
        authRepositoryProvider.overrideWithValue(
          MockAuthRepository()..throwsNetworkError(),
        ),
      ],
    );

    final controller = container.read(authControllerProvider.notifier);
    await controller.signIn('test@example.com', 'password');

    expect(
      container.read(authControllerProvider),
      isA<AsyncError>(),
    );
  });
  ```

#### Documentation Strategy

1. **Architecture Documentation**

   - Clean Architecture principles
   - AWS Cognito integration
   - Riverpod state management
   - Error handling patterns

2. **Testing Documentation**

   - Provider testing patterns
   - Integration testing approach
   - Error testing strategies
   - Mock implementation guidelines

3. **State Management Documentation**

   - Riverpod patterns
   - AsyncValue usage
   - Error handling
   - State persistence

4. **Security Documentation**
   - Token management
   - Session handling
   - Error message security
   - Rate limiting implementation

#### Project Restructuring

- **Migrate to Feature-Based Organization**

  ```
  lib/
  ├── app/                     # Core app infrastructure
  ├── features/                # Feature modules (vertical slices)
  │   ├── auth/                # Authentication feature
  │   │   ├── data/            # Data layer
  │   │   ├── domain/          # Business logic
  │   │   └── presentation/    # UI layer
  │   ├── trips/               # Trip management
  │   └── matching/            # Traveler matching system
  └── shared/                  # Cross-cutting concerns
  ```

- **Implement Proper Dependency Injection**

  ```dart
  // lib/app/di/service_locator.dart
  final getIt = GetIt.instance;

  void setupServiceLocator() {
    // Register repositories
    getIt.registerLazySingleton<AuthRepository>(
      () => AuthRepositoryImpl(
        localDataSource: getIt<AuthLocalDataSource>(),
        remoteDataSource: getIt<AuthRemoteDataSource>(),
      ),
    );

    // Register use cases
    getIt.registerLazySingleton(() => GetCurrentUser(getIt<AuthRepository>()));
    getIt.registerLazySingleton(() => SignIn(getIt<AuthRepository>()));
    getIt.registerLazySingleton(() => SignOut(getIt<AuthRepository>()));
  }
  ```

- **Enhance Documentation Strategy**
  - Create architecture documentation
  - Document testing strategies
  - Establish monitoring approach

### Phase 3: Database & Monitoring Optimization (Next Focus)

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

- **Integrate with CloudWatch**

  ```terraform
  # Integrate CloudWatch with Prometheus
  resource "aws_cloudwatch_log_group" "prometheus" {
    name = "/prometheus/metrics"
    retention_in_days = 30
  }
  ```

- **Create Comprehensive Dashboards**
  - Application health dashboard
  - User experience metrics
  - Resource utilization tracking

### Phase 4: API & Feature Development (Weeks 8-14)

#### API Endpoint Configuration

- **Design for Multiple Request Types**

  ```dart
  // lib/shared/api/api_client.dart
  abstract class ApiClient {
    Future<Response<T>> get<T>(String path, {Map<String, dynamic>? queryParameters});
    Future<Response<T>> post<T>(String path, {dynamic data});
    Future<Response<T>> put<T>(String path, {dynamic data});
    Future<Response<T>> delete<T>(String path);
    Stream<T> subscribe<T>(String topic);
  }

  // REST implementation
  class RestApiClient implements ApiClient {
    final Dio _dio;
    // Implementation
  }

  // GraphQL implementation
  class GraphQLApiClient implements ApiClient {
    final GraphQLClient _client;
    // Implementation
  }

  // WebSocket implementation
  class WebSocketApiClient implements ApiClient {
    final WebSocketChannel _channel;
    // Implementation for real-time features
  }
  ```

- **Implement Abstraction Layers**

  ```dart
  // lib/shared/api/api_service.dart
  class ApiService {
    final ApiClient _client;
    final ApiResponseMapper _mapper;

    ApiService(this._client, this._mapper);

    Future<T> fetchData<T>(String endpoint, {Map<String, dynamic>? params}) async {
      final response = await _client.get(endpoint, queryParameters: params);
      return _mapper.map<T>(response);
    }

    // Other methods
  }
  ```

#### Feature Development

- **Travel Preferences UI**

  - Implement preference selection screens
  - Create preference management system
  - Build preference-based recommendation engine

- **Trip Planning Interface**

  - Develop trip creation workflow
  - Implement itinerary management
  - Build collaborative planning features

- **Location Visualization**
  - Integrate Google Maps/Flutter Map
  - Implement location search functionality
  - Create interactive map features

### Phase 5: Scaling & Performance (Weeks 15-20)

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

### Phase 6: Advanced Features (Weeks 21-28)

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

- **Implement HashiCorp Vault**

  ```bash
  # Secret injection
  vault kv put secret/db_creds username=admin password=...
  ```

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

### Phase 7: Advanced Architecture (Weeks 29-36)

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

### Phase 8: Intelligence & Enterprise Features (Future)

#### ML Feature Management

- **Implement SageMaker Feature Store**
- **Deploy recommendation models**
- **Implement content moderation**

#### Multi-Region Deployment

- **Implement global routing with Route53**
- **Set up cross-region replication for S3**
- **Configure multi-region database strategy**

#### Advanced Disaster Recovery

- **Implement automated failover procedures**
- **Set up cross-region backup strategies**
- **Create disaster recovery runbooks**

## Cost-Performance Benchmarks

| Component           | Current Stack | Improved Stack | Savings |
| ------------------- | ------------- | -------------- | ------- |
| Database (Aurora)   | $2,400/mo     | $840/mo        | 65%     |
| Search (OpenSearch) | $1,140/mo     | $547/mo        | 52%     |
| Compute (Lambda)    | $1,800/mo     | $990/mo        | 45%     |
| Storage (S3)        | $600/mo       | $240/mo        | 60%     |
| Real-Time Messaging | $900/mo       | $550/mo        | 39%     |
| **Total Monthly**   | **$6,840/mo** | **$3,167/mo**  | **54%** |

## Implementation Roadmap

### Immediate Focus (Next 2 Weeks)

- Complete Riverpod testing infrastructure
- Implement project restructuring based on clean architecture
- Document provider patterns and testing approach

### Short-Term (2-4 Weeks)

- Implement critical database optimizations
- Set up enhanced monitoring with Prometheus+Grafana
- Configure API endpoints with new architecture in mind

### Medium-Term (1-3 Months)

- Develop travel preferences UI
- Build trip planning interface
- Integrate Google Maps/Flutter Map for location visualization

### Long-Term (3+ Months)

- Implement event streaming with Kafka
- Configure database scaling with read replicas
- Deploy advanced security features

## Conclusion

This architecture evolution plan provides a roadmap for transforming the SoloAdventurer application from its current state to a more scalable, performant, and cost-effective infrastructure. By implementing these changes in phases, we can minimize risk while continuously improving the application's capabilities.

The revised phasing aligns with our current priorities as outlined in the project plan, focusing first on establishing a solid foundation with proper testing infrastructure and clean architecture before moving on to performance optimizations and advanced features.
