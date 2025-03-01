# Project Restructuring Plan: Clean Architecture Implementation

This document outlines the plan for restructuring the SoloAdventurer application following clean architecture principles. The goal is to create a maintainable, testable, and scalable codebase that clearly separates concerns and dependencies.

## Clean Architecture Overview

Our implementation of clean architecture will consist of the following layers:

1. **Domain Layer** - Core business logic and entities
2. **Data Layer** - Implementation of repositories and data sources
3. **Presentation Layer** - UI components and state management
4. **Application Layer** - Use cases that orchestrate the flow of data between domain and presentation

Dependencies will flow from the outer layers (presentation, data) toward the inner layers (domain), never the reverse.

## Current Structure vs. Target Structure

### Current Structure (Simplified)

```
lib/
├── features/
│   └── auth/
│       ├── data/
│       │   └── sources/
│       ├── domain/
│       └── presentation/
├── shared/
│   ├── api/
│   ├── errors/
│   └── utils/
└── main.dart
```

### Enhanced Target Structure

```
lib/
├── app/                  # App-wide config
│   ├── di/               # Dependency injection
│   │   └── service_locator.dart
│   ├── router/           # Routing
│   │   └── app_router.dart
│   ├── feature_flags/    # Feature flag management
│   │   └── feature_config.dart
│   └── app.dart          # Main app component
├── core/                 # Cross-cutting concerns
│   ├── api/              # API clients
│   │   ├── client/
│   │   │   ├── api_client.dart
│   │   │   └── cost_aware_client.dart
│   │   ├── interceptors/
│   │   │   ├── auth_interceptor.dart
│   │   │   ├── error_interceptor.dart
│   │   │   └── rate_limit_interceptor.dart
│   │   └── models/
│   │       └── api_response.dart
│   ├── realtime/         # Real-time infrastructure
│   │   ├── websocket_service.dart
│   │   ├── presence_tracker.dart
│   │   └── geolocation_stream.dart
│   ├── errors/           # Error handling
│   │   ├── exceptions.dart
│   │   └── failures.dart
│   ├── storage/          # Storage
│   │   └── secure_storage.dart
│   └── utils/            # Utilities
│       ├── constants.dart
│       └── extensions/
├── features/             # Feature modules
│   ├── auth/             # Authentication feature
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   │   ├── auth_local_data_source.dart
│   │   │   │   └── auth_remote_data_source.dart
│   │   │   ├── models/
│   │   │   │   └── user_entity.dart
│   │   │   └── repositories/
│   │   │       └── auth_repository_impl.dart
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   └── user.dart
│   │   │   ├── repositories/
│   │   │   │   └── auth_repository.dart
│   │   │   └── usecases/
│   │   │       ├── get_current_user.dart
│   │   │       ├── login.dart
│   │   │       └── signup.dart
│   │   └── presentation/
│   │       ├── providers/
│   │       │   └── auth_providers.dart
│   │       ├── screens/
│   │       │   ├── login_screen.dart
│   │       │   └── signup_screen.dart
│   │       └── widgets/
│   │           └── auth_form.dart
│   ├── trips/            # Trip management
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   ├── matching/         # AI matching engine
│   │   ├── data/
│   │   │   └── repositories/
│   │   │       └── ml_repository_impl.dart
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   └── match.dart
│   │   │   ├── repositories/
│   │   │   │   └── ml_repository.dart
│   │   │   └── usecases/
│   │   │       ├── generate_matches.dart
│   │   │       └── rank_profiles.dart
│   │   └── presentation/
│   │       └── providers/
│   │           └── matching_provider.dart
│   └── discover/         # Traveler discovery
│       ├── data/
│       ├── domain/
│       └── presentation/
├── shared/               # Shared components
│   ├── design_system/    # UI components
│   │   ├── app_colors.dart
│   │   └── app_theme.dart
│   ├── monitoring/       # Monitoring infrastructure
│   │   ├── performance/
│   │   │   ├── app_start_tracker.dart
│   │   │   ├── fps_monitor.dart
│   │   │   ├── memory_profiler.dart
│   │   │   └── network_monitor.dart
│   │   ├── error_tracking/
│   │   │   ├── error_handler.dart
│   │   │   ├── sentry_adapter.dart
│   │   │   └── crashlytics_adapter.dart
│   │   └── analytics/
│   │       ├── event_logger.dart
│   │       └── user_journey_tracker.dart
│   └── localization/     # Internationalization
│       └── app_localizations.dart
└── main.dart             # App entry point
```

## Phased Implementation Plan

### 🏗️ Phase 1: Foundation Setup (Weeks 1-2)

**Goal**: Establish core infrastructure without disrupting existing features

#### Dependency Injection Overhaul

```dart
// lib/app/di/service_locator.dart
final getIt = GetIt.instance;

void init() {
  // Auth Layer
  getIt.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl());

  // API Layer
  getIt.registerLazySingleton<Dio>(() => CostAwareDio(
    interceptors: [
      AuthInterceptor(),
      RateLimitInterceptor(),
    ],
  ));
}
```

#### Core API Implementation

```
lib/core/api/
├── cost_aware_client.dart     # Budget-enforced client
├── websocket_service.dart     # Shared WS connection manager
└── interceptors/
    ├── auth_interceptor.dart  # JWT injection
    └── cost_logger.dart       # AWS Cost Explorer integration
```

#### Error Monitoring Baseline

```dart
// lib/shared/monitoring/error_tracking.dart
void reportError(dynamic error, StackTrace stack) {
  // Unified error reporting
  FirebaseCrashlytics.instance.recordError(error, stack);
  Sentry.captureException(error, stackTrace: stack);
  CloudWatch.putMetricData(
    namespace: 'Errors',
    metricData: [/*...*/]
  );
}
```

**Deliverables**:

- Production-ready DI system
- Cost-monitored API client
- Unified error tracking
- CloudWatch dashboard baseline
- 20% test coverage for core components

### 🧩 Phase 2: Feature Modularization (Weeks 3-6)

**Goal**: Rebuild auth and trip features using new architecture

#### Auth Feature Migration

```
lib/features/auth/
├── data/
│   ├── sources/           # Cognito + SecureStorage
│   └── repositories/      # AuthRepositoryImpl
├── domain/
│   └── usecases/          # LoginWithEmail, SocialSignIn
└── presentation/
    ├── providers/         # AuthStateNotifier
    └── screens/           # New responsive layouts
```

#### Design System Implementation

```dart
// lib/shared/design_system/buttons.dart
class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    @required this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      style: _buildStyle(context),
      onPressed: isLoading ? null : onPressed,
      child: isLoading
          ? LoadingIndicator()
          : Text('Continue'),
    );
  }
}
```

#### Feature Toggle System

```dart
// lib/app/feature_flags/feature_toggles.dart
final featureProvider = FutureProvider<FeatureConfig>((ref) async {
  return FeatureConfig(
    enableChat: await LaunchDarkly.client.boolVariation('chat-enabled', false),
    enablePremium: await isUserSubscribed(),
  );
});
```

**Deliverables**:

- Production-grade auth flow
- Shared UI component library
- Feature flag system
- 30% test coverage
- Documentation for feature modules

### 🌐 Phase 3: Real-Time Infrastructure (Weeks 7-10)

**Goal**: Implement Tinder-like real-time features

#### WebSocket Service

```dart
// lib/core/realtime/websocket_service.dart
class WebSocketManager {
  final _channel = WebSocketChannel.connect(
    Uri.parse('wss://api.soloadventurer.com/ws'),
  );

  Stream<Message> get messages => _channel.stream
    .transform(MessageDecoder())
    .handleError(_handleError);

  void send(Message message) {
    _channel.sink.add(message.toJson());
  }
}
```

#### Presence Tracking

```
lib/features/presence/
├── data/
│   └── repositories/      # Redis-backed PresenceRepo
└── presentation/
    └── providers/         # OnlineStatusProvider
```

#### Geolocation Optimization

```dart
// lib/core/realtime/geolocation_service.dart
void startLocationUpdates() {
  Geolocator.getPositionStream(
    locationSettings: LocationSettings(
      accuracy: LocationAccuracy.bestForNavigation,
      distanceFilter: 100, // Meters
      timeInterval: 30000, // 30 seconds
    )
  ).listen((position) {
    _updateServerPosition(position);
    _cacheLocalPosition(position);
  });
}
```

**Deliverables**:

- Live user presence system
- Battery-optimized location tracking
- Real-time messaging foundation
- 50ms latency for presence updates
- Offline support for critical features
- 40% test coverage for real-time components

### 🤖 Phase 4: AI/ML Integration (Weeks 11-14)

**Goal**: Implement smart matching like Tinder's algorithm

#### SageMaker Pipeline Setup

```python
# scripts/ml/train_model.py
estimator = sagemaker.estimator.Estimator(
  image_uri=AML_IMAGE_URI,
  role=IAM_ROLE,
  instance_count=2,
  instance_type='ml.g5.2xlarge',
  output_path=f's3://{BUCKET}/models',
  use_spot_instances=True,
)

estimator.fit({'training': TRAINING_DATA_PATH})
```

#### Graph Database Implementation

```
lib/features/matching/
├── data/
│   └── repositories/      # Neptune graph queries
└── domain/
    └── usecases/          # FindCompatibleTravelers
```

#### Recommendation Service

```dart
// lib/features/matching/presentation/providers/matching_provider.dart
final matchProvider = StateNotifierProvider<MatchingNotifier, MatchingState>(
  (ref) => MatchingNotifier(
    mlEngine: ref.watch(mlServiceProvider),
    location: ref.watch(locationProvider),
  )
);
```

**Deliverables**:

- Travel compatibility prediction model
- Real-time match suggestions
- Graph-based relationship mapping
- Personalization engine
- 50% test coverage for ML components
- Documentation for ML integration

### 🚀 Phase 5: Optimization & Launch (Weeks 15-18)

**Goal**: Achieve production readiness

#### Performance Tuning

```bash
# Run in CI pipeline
flutter build apk --analyze-size
flutter run --profile --trace-startup
```

#### Security Hardening

```terraform
# infrastructure/security.tf
resource "aws_security_group" "db" {
  ingress {
    from_port = 5432
    to_port   = 5432
    protocol  = "tcp"
    security_groups = [module.vpc.default_security_group_id]
  }
}
```

#### Launch Preparation

```dart
// lib/app/env/production.dart
final env = AppEnvironment(
  apiBaseUrl: 'https://api.soloadventurer.com',
  enableExperimentalFeatures: false,
  logLevel: LogLevel.warning,
  useEmulators: false,
);
```

**Deliverables**:

- App Store ready builds
- SOC 2 compliance checklist
- Auto-scaling configured
- Disaster recovery plan
- 70% overall test coverage
- Complete user documentation

## File Movement Reference

| Current Location                                              | New Location                                                      |
| ------------------------------------------------------------- | ----------------------------------------------------------------- |
| `lib/shared/api/api_client.dart`                              | `lib/core/api/client/api_client.dart`                             |
| `lib/shared/errors/exceptions.dart`                           | `lib/core/errors/exceptions.dart`                                 |
| `lib/shared/errors/failures.dart`                             | `lib/core/errors/failures.dart`                                   |
| `lib/shared/utils/constants.dart`                             | `lib/core/utils/constants.dart`                                   |
| `lib/features/auth/data/sources/auth_local_data_source.dart`  | `lib/features/auth/data/datasources/auth_local_data_source.dart`  |
| `lib/features/auth/data/sources/auth_remote_data_source.dart` | `lib/features/auth/data/datasources/auth_remote_data_source.dart` |

## Testing Considerations

- Update test file paths to match the new structure
- Ensure mocks and test utilities are properly organized
- Create a parallel test directory structure that mirrors the lib directory
- Implement specific tests for real-time components and cost-aware API client
- Develop specialized testing utilities for WebSocket and geolocation services
- Create mock ML models for testing recommendation engine

## Migration Strategy

To minimize disruption, we'll follow these steps:

1. Create the new directory structure
2. Move files one feature at a time, starting with core infrastructure
3. Update imports and dependencies incrementally
4. Run tests after each significant move to catch issues early
5. Create a comprehensive pull request with detailed documentation
6. Implement feature flags to gradually roll out new architecture components

## Success Criteria

The restructuring will be considered successful when:

1. All code follows the clean architecture principles
2. All tests pass with the new structure
3. The application builds and runs without issues
4. Code review confirms proper separation of concerns
5. Documentation is updated to reflect the new structure
6. Real-time features work correctly
7. Monitoring infrastructure provides comprehensive insights
8. API cost optimization is effective

## Expected Benefits

| Metric                | Current | Target | Improvement |
| --------------------- | ------- | ------ | ----------- |
| API Latency (p95)     | 1200ms  | <300ms | +75%        |
| Matching Relevance    | N/A     | 82%    | New         |
| Cold Start Time       | 4.2s    | <1.5s  | +64%        |
| Monthly Cloud Cost    | $3,200  | $1,100 | +66%        |
| Crash-Free Users      | 92%     | 99.9%  | +8.6%       |
| Feature Isolation     | 60%     | 95%    | +58%        |
| Error Resolution Time | 48hr    | 2hr    | +96%        |

### Cost Optimization Benefits

The implementation of our AWS Cost Audit Script (v2.1) will provide significant cost savings across our infrastructure:

| Service              | Current Cost  | Target Cost   | Savings % | Annual Savings |
| -------------------- | ------------- | ------------- | --------- | -------------- |
| Aurora PostgreSQL    | $2,328/mo     | $768/mo       | 67%       | $18,720        |
| OpenSearch           | $1,140/mo     | $547/mo       | 52%       | $7,116         |
| IoT Core (Real-time) | $385/mo       | $327/mo       | 15%       | $696           |
| Neptune (Graph DB)   | $1,375/mo     | $894/mo       | 35%       | $5,772         |
| SageMaker (ML)       | $235/mo       | $70/mo        | 70%       | $1,980         |
| **Total**            | **$5,463/mo** | **$2,606/mo** | **52%**   | **$34,284**    |

Key optimization strategies include:

1. **Database Optimization**:

   - Converting Aurora clusters to Serverless v2 (67% savings)
   - Implementing proper scaling configurations with min capacity of 0.5 ACUs

2. **Compute Efficiency**:

   - Migrating OpenSearch to Graviton instances (52% savings)
   - Using SageMaker spot instances for ML training (70% savings)

3. **Real-time Infrastructure**:

   - Optimizing IoT Core rule configurations (15% savings)
   - Implementing efficient MQTT topic structure

4. **Graph Database Performance**:
   - Upgrading Neptune to version 1.2.1.0 (35% savings + performance boost)
   - Implementing proper query caching

The cost audit script will run daily through our CI/CD pipeline, automatically identifying new savings opportunities as our infrastructure evolves. The script also provides Terraform remediation steps for immediate implementation.

## Post-Launch Roadmap

- Week 19: Feature Rollout (Chat, Groups)
- Week 22: Monetization Integration
- Week 26: Localization (10 Languages)
- Week 30: Android Auto/iOS CarPlay

This plan balances technical debt reduction with feature development, using proven patterns from apps handling 1M+ concurrent users.
