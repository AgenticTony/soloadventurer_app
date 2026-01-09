# Authentication System Architecture

## Overview

The SoloAdventurer authentication system is a robust, production-ready implementation built on AWS Cognito with comprehensive token management, offline support, and graceful error handling. This document provides a high-level architectural overview of the authentication system.

## Table of Contents

- [Architecture Principles](#architecture-principles)
- [Core Components](#core-components)
- [Data Flow](#data-flow)
- [Service Layer](#service-layer)
- [State Management](#state-management)
- [Security Considerations](#security-considerations)
- [Technology Stack](#technology-stack)

## Architecture Principles

The authentication system is built on the following principles:

1. **Separation of Concerns**: Clear separation between domain, data, and presentation layers
2. **Dependency Inversion**: High-level modules don't depend on low-level modules
3. **Single Responsibility**: Each service/class has one clear purpose
4. **Robustness**: Comprehensive error handling and retry mechanisms
5. **Performance**: Optimized for minimal latency and resource usage
6. **Testability**: All components are easily testable in isolation

## Core Components

### Layer Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    Presentation Layer                        │
│  ┌──────────────────┐  ┌──────────────────┐                │
│  │   Auth Screens   │  │   Auth Widgets   │                │
│  │  (Login, Signup) │  │  (RetryButton,   │                │
│  │                  │  │   OfflineBanner) │                │
│  └──────────────────┘  └──────────────────┘                │
└─────────────────────────────────────────────────────────────┘
                           ▲
                           │
┌──────────────────────────┴──────────────────────────────────┐
│                     Domain Layer                             │
│  ┌──────────────────┐  ┌──────────────────┐                │
│  │   AuthRepository │  │   User Entity    │                │
│  │    (Interface)   │  │                  │                │
│  └──────────────────┘  └──────────────────┘                │
└─────────────────────────────────────────────────────────────┘
                           ▲
                           │
┌──────────────────────────┴──────────────────────────────────┐
│                   Infrastructure Layer                       │
│  ┌──────────────────────────────────────────────────┐      │
│  │               Services                            │      │
│  │  ┌─────────────────┐  ┌────────────────────┐     │      │
│  │  │ TokenRefresh    │  │ PersistentSession  │     │      │
│  │  │ Service         │  │ Manager            │     │      │
│  │  └─────────────────┘  └────────────────────┘     │      │
│  │  ┌─────────────────┐  ┌────────────────────┐     │      │
│  │  │ OfflineAuth     │  │ BackgroundRefresh  │     │      │
│  │  │ Manager         │  │ Scheduler          │     │      │
│  │  └─────────────────┘  └────────────────────┘     │      │
│  │  ┌─────────────────┐  ┌────────────────────┐     │      │
│  │  │ AuthError       │  │ RefreshQueue       │     │      │
│  │  │ Handler         │  │ Manager            │     │      │
│  │  └─────────────────┘  └────────────────────┘     │      │
│  └──────────────────────────────────────────────────┘      │
│  ┌──────────────────────────────────────────────────┐      │
│  │               Data Sources                        │      │
│  │  ┌─────────────────┐  ┌────────────────────┐     │      │
│  │  │ AuthRemote      │  │ AuthLocal          │     │      │
│  │  │ DataSource      │  │ DataSource         │     │      │
│  │  │ (AWS Cognito)   │  │ (Secure Storage)   │     │      │
│  │  └─────────────────┘  └────────────────────┘     │      │
│  └──────────────────────────────────────────────────┘      │
└─────────────────────────────────────────────────────────────┘
                           ▲
                           │
┌──────────────────────────┴──────────────────────────────────┐
│                      Core Layer                              │
│  ┌──────────────────┐  ┌──────────────────┐                │
│  │  HTTP Client     │  │   Connectivity   │                │
│  │    (Dio)         │  │    Service       │                │
│  │                  │  │                  │                │
│  └──────────────────┘  └──────────────────┘                │
│  ┌──────────────────┐  ┌──────────────────┐                │
│  │ AuthInterceptor  │  │ Secure Storage   │                │
│  │                  │  │ (flutter_secure_ │                │
│  │                  │  │    storage)       │                │
│  └──────────────────┘  └──────────────────┘                │
└─────────────────────────────────────────────────────────────┘
```

## Data Flow

### Authentication Flow

```
┌──────────┐
│   User   │
└────┬─────┘
     │
     │ 1. Enter credentials
     ▼
┌──────────────────┐
│ Login Screen     │
│ (Presentation)   │
└────┬─────────────┘
     │
     │ 2. Call signIn()
     ▼
┌──────────────────┐
│ AuthProvider     │
│ (Riverpod)       │
└────┬─────────────┘
     │
     │ 3. Call repository.signIn()
     ▼
┌──────────────────┐
│ AuthRepository   │
│ Impl             │
└────┬─────────────┘
     │
     ├──────────────┬─────────────┐
     │              │             │
     ▼              ▼             ▼
┌────────────┐ ┌────────────┐ ┌────────────┐
│  Cognito   │ │   Secure   │ │  Offline   │
│  (Remote)  │ │  Storage   │ │   Manager  │
└────────────┘ └────────────┘ └────────────┘
     │              │             │
     └──────────────┴─────────────┘
                    │ 4. Return AuthSession
                    ▼
           ┌──────────────────┐
           │ AuthProvider     │
           │ Updates state    │
           └────┬─────────────┘
                │
                │ 5. Save session
                ▼
           ┌──────────────────┐
           │ Persistent       │
           │ SessionManager   │
           └────┬─────────────┘
                │
                │ 6. Schedule refresh
                ▼
           ┌──────────────────┐
           │ Background       │
           │ RefreshScheduler │
           └──────────────────┘
```

### Token Refresh Flow

```
┌─────────────────────┐
│ API Request         │
│ with Auth Token     │
└──────┬──────────────┘
       │
       │ 1. Intercept request
       ▼
┌─────────────────────┐
│ AuthInterceptor     │
└──────┬──────────────┘
       │
       │ 2. Check token expiration
       ▼
┌─────────────────────┐      ┌──────────────────────┐
│ Token < 5 min to    │──NO──▶│ Proceed with         │
│ expiration?         │      │ request              │
└──────┬──────────────┘      └──────────────────────┘
       │ YES
       ▼
┌─────────────────────┐
│ RefreshQueueManager │
└──────┬──────────────┘
       │
       │ 3. Queue/Start refresh
       ▼
┌─────────────────────┐
│ TokenRefreshService │
└──────┬──────────────┘
       │
       │ 4. Perform refresh with retry
       ▼
┌─────────────────────┐      ┌──────────────────────┐
│ Success?            │──NO───▶│ Retry with           │
│                     │       │ exponential backoff  │
└──────┬──────────────┘      └──────────────────────┘
       │ YES                         │
       ▼                             │ (Max 3 retries)
┌─────────────────────┐              │
│ Update session      │◀─────────────┘
│ in storage          │
└──────┬──────────────┘
       │
       │ 5. Resolve all queued
       │    requests
       ▼
┌─────────────────────┐
│ Complete API        │
│ request             │
└─────────────────────┘
```

## Service Layer

### TokenRefreshService

**Purpose**: Manages token refresh operations with retry logic and exponential backoff.

**Key Features**:
- Exponential backoff: 1s, 2s, 4s, 8s, 16s, 32s max
- Mutex pattern to prevent concurrent refreshes
- Max 3 retry attempts
- Stream-based status updates
- Smart error categorization for retries

**Dependencies**:
- `AuthRepository` - for performing the actual token refresh

### PersistentSessionManager

**Purpose**: Manages secure storage and retrieval of authentication sessions.

**Key Features**:
- Secure token storage using flutter_secure_storage
- Session caching (5-minute validity)
- Session validation with 24-hour refresh threshold
- Session versioning for migration support
- Masked token logging for security

**Dependencies**:
- `AuthLocalDataSource` - for secure storage operations

### OfflineAuthManager

**Purpose**: Manages offline authentication state and cached data access.

**Key Features**:
- Network connectivity monitoring
- 4-state offline tracking (online, offlineWithCache, offlineWithoutCache, needsSync)
- Cached data freshness tracking (24-hour threshold)
- Sync on reconnection
- Automatic state transitions

**Dependencies**:
- `ConnectivityService` - for network status
- `AuthLocalDataSource` - for cached data access
- `TokenRefreshService` (optional) - for token refresh on reconnect
- `AuthRepository` (optional) - for fetching fresh data

### BackgroundTokenRefreshScheduler

**Purpose**: Schedules automatic token refresh based on expiration time.

**Key Features**:
- App lifecycle awareness (pauses when app is backgrounded)
- Proactive refresh at 75% of token lifetime
- Automatic resumption when app returns to foreground
- Graceful handling of app termination

**Dependencies**:
- `TokenExpirationTracker` - for calculating expiration time
- `TokenRefreshService` - for performing refresh

### RefreshQueueManager

**Purpose**: Manages pending token refresh requests to prevent duplicate operations.

**Key Features**:
- Queues requests when refresh is in progress
- Resolves all queued requests with the same result
- 30-second queue timeout
- Prevents race conditions

**Dependencies**:
- `TokenRefreshService` - for performing refresh

### AuthErrorHandler

**Purpose**: Centralized error handling for authentication errors.

**Key Features**:
- Error categorization (network, credentials, expired, rate limit, server)
- User-friendly error messages
- Actionable recovery steps
- Detailed logging for debugging

**Dependencies**: None (standalone service)

## State Management

### Riverpod Architecture

The authentication system uses Riverpod for state management:

```dart
// Auth State
AuthState {
  - isAuthenticated: bool
  - user: User?
  - session: AuthSession?
  - isLoading: bool
  - error: AuthException?
}

// Providers
authProvider → StateNotifierProvider<AuthNotifier, AuthState>
authRepositoryProvider → Provider<AuthRepository>
tokenRefreshServiceProvider → Provider<TokenRefreshService>
persistentSessionManagerProvider → Provider<PersistentSessionManager>
offlineAuthStateProvider → StreamProvider<OfflineAuthState>
```

### State Updates

1. **Authentication State**: Updated by `AuthProvider` on login/logout/refresh
2. **Offline State**: Updated by `OfflineAuthManager` on connectivity changes
3. **Session State**: Updated by `PersistentSessionManager` on save/load/clear
4. **Refresh State**: Updated by `TokenRefreshService` during refresh operations

## Security Considerations

### Token Storage

- **Access Token**: Stored in flutter_secure_storage
- **ID Token**: Stored in flutter_secure_storage
- **Refresh Token**: Stored in flutter_secure_storage
- **Expiration**: Timestamp stored and validated on every session load

### Token Refresh Strategy

1. **Proactive Refresh**: Trigger refresh at 75% of token lifetime
2. **Reactive Refresh**: Also refresh on 401 errors
3. **Retry Logic**: Exponential backoff with max 3 attempts
4. **Mutex Pattern**: Prevents concurrent refresh attempts

### Session Validation

- Sessions are validated on app startup
- Auto-refresh if token expired < 24 hours ago
- Require re-authentication if token expired > 24 hours ago
- Detect and handle corrupted session data

### Network Security

- All auth traffic uses HTTPS
- Tokens are never logged in plain text
- Masked token display (first 8 chars ... last 4 chars)
- Secure storage encryption keys managed by OS

## Technology Stack

### Backend

- **Authentication Provider**: AWS Cognito
- **User Pools**: User management and authentication
- **Token Expiration**: 1 hour (access token), 30 days (refresh token)

### Frontend

- **Framework**: Flutter 3.x
- **State Management**: Riverpod 2.x
- **HTTP Client**: Dio 5.x with interceptors
- **Secure Storage**: flutter_secure_storage
- **Connectivity**: connectivity_plus

### Architecture Pattern

- **Pattern**: Clean Architecture with Layered approach
- **Dependency Injection**: GetIt + Injectable
- **Repository Pattern**: For data abstraction
- **Service Layer**: For business logic

## Performance Optimizations

1. **Session Caching**: PersistentSessionManager caches sessions for 5 minutes
2. **AuthInterceptor Caching**: Caches AuthRepository reference
3. **Request Deduplication**: RefreshQueueManager prevents duplicate refresh calls
4. **Background Refresh**: TokenRefreshScheduler pauses when app is backgrounded
5. **Optimized Storage**: Minimal secure storage reads with caching

## Testing Strategy

### Unit Tests

- All services have comprehensive unit tests
- Test coverage > 90% for critical paths
- Mocked dependencies using Mocktail

### Integration Tests

- End-to-end authentication flows
- Session persistence across app restarts
- Token refresh during API calls
- Offline to online transitions

### Performance Tests

- Login performance < 3 seconds on 4G
- Token refresh < 1 second
- Session restoration < 500ms
- Memory leak detection

## Future Enhancements

1. **Biometric Auth**: Integrate fingerprint/face recognition
2. **Social Login**: Add Google, Apple, Facebook sign-in
3. **MFA**: Enhanced multi-factor authentication
4. **Token Rotation**: Implement proactive token rotation
5. **Audit Logging**: Track authentication events for security

---

**Document Version**: 1.0
**Last Updated**: 2026-01-04
**Maintainer**: SoloAdventurer Team
