# Token Refresh Flow Diagram

## Overview

This document provides detailed flow diagrams for the token refresh mechanism in the SoloAdventurer authentication system. The system implements both proactive and reactive token refresh strategies with robust retry logic and error handling.

## Table of Contents

- [Proactive Token Refresh](#proactive-token-refresh)
- [Reactive Token Refresh](#reactive-token-refresh)
- [Token Refresh with Retry Logic](#token-refresh-with-retry-logic)
- [Queue Management](#queue-management)
- [Error Handling Flow](#error-handling-flow)

## Proactive Token Refresh

Proactive refresh occurs automatically in the background before tokens expire.

### Mermaid Diagram

```mermaid
graph TD
    A[App Starts] --> B[TokenRefreshScheduler.start]
    B --> C{Session Exists?}
    C -->|Yes| D[TokenExpirationTracker.calculateTimeUntilExpiration]
    C -->|No| E[Wait for Login]
    D --> F{Time Until Expiration}
    F -->|> 25%| G[Schedule Refresh at 75%]
    F -->|<= 25%| H[Trigger Immediate Refresh]
    G --> I[Wait for Scheduled Time]
    I --> H
    H --> J[RefreshQueueManager.enqueueRequest]
    J --> K[TokenRefreshService.refreshToken]
    K --> L{Refresh Success?}
    L -->|Yes| M[PersistentSessionManager.saveSession]
    L -->|No| N[Retry with Exponential Backoff]
    M --> O[Reschedule Next Refresh]
    N -->|Max 3 retries| K
    N -->|Failed| P[Notify User of Error]
    O --> F

    style A fill:#e1f5fe
    style M fill:#c8e6c9
    style P fill:#ffcdd2
```

### Sequence Diagram

```mermaid
sequenceDiagram
    participant App as Flutter App
    participant Scheduler as TokenRefreshScheduler
    participant Tracker as TokenExpirationTracker
    participant Queue as RefreshQueueManager
    participant Service as TokenRefreshService
    participant Repo as AuthRepository
    participant Storage as PersistentSessionManager

    App->>Scheduler: start(session)
    activate Scheduler
    Scheduler->>Tracker: calculateTimeUntilExpiration()
    activate Tracker
    Tracker-->>Scheduler: Duration (e.g., 45 minutes)
    deactivate Tracker

    Scheduler->>Scheduler: Schedule refresh at 75%

    Note over Scheduler: Wait for scheduled time...

    Scheduler->>Queue: enqueueRequest()
    activate Queue
    Queue->>Service: refreshToken()
    activate Service

    Service->>Repo: performBasicTokenRefresh()
    activate Repo
    Repo->>Repo: Call AWS Cognito
    Repo-->>Service: AuthSession
    deactivate Repo

    Service-->>Queue: AuthSession
    deactivate Service

    Queue-->>Scheduler: New session
    deactivate Queue

    Scheduler->>Storage: saveSession(newSession)
    deactivate Scheduler

    Scheduler->>Scheduler: Reschedule next refresh
```

## Reactive Token Refresh

Reactive refresh occurs when an API call fails with a 401 error.

### Mermaid Diagram

```mermaid
graph TD
    A[API Request] --> B[AuthInterceptor onRequest]
    B --> C[Add Access Token]
    C --> D[Send Request]
    D --> E{Response Status}
    E -->|200 OK| F[Return Response]
    E -->|401 Unauthorized| G[AuthInterceptor onError]
    G --> H{Token Expired?}
    H -->|Yes| I[RefreshQueueManager.enqueueRequest]
    H -->|No| J[Throw Error]
    I --> K[Wait for Refresh to Complete]
    K --> L{Refresh Success?}
    L -->|Yes| M[Retry Original Request]
    L -->|No| N[Throw AuthException]
    M --> O{Retry Success?}
    O -->|Yes| F
    O -->|No| N

    style F fill:#c8e6c9
    style N fill:#ffcdd2
    style I fill:#fff9c4
```

### Sequence Diagram

```mermaid
sequenceDiagram
    participant Client as API Client
    participant Interceptor as AuthInterceptor
    participant Queue as RefreshQueueManager
    participant Service as TokenRefreshService
    participant API as Backend API

    Client->>Interceptor: GET /api/user
    activate Interceptor
    Interceptor->>Interceptor: Add auth token
    Interceptor->>API: GET /api/user (with token)
    activate API
    API-->>Interceptor: 401 Unauthorized
    deactivate API

    Interceptor->>Interceptor: onError(401)

    Interceptor->>Queue: enqueueRequest()
    activate Queue
    Note over Queue: If refresh in progress,<br/>queue this request

    Queue->>Service: refreshToken()
    activate Service
    Service->>Service: Perform refresh with retry
    Service-->>Queue: New AuthSession
    deactivate Service

    Queue-->>Interceptor: New session
    deactivate Queue

    Interceptor->>Interceptor: Update request with new token
    Interceptor->>API: GET /api/user (retry)
    activate API
    API-->>Interceptor: 200 OK
    deactivate API

    Interceptor-->>Client: Response data
    deactivate Interceptor
```

## Token Refresh with Retry Logic

Detailed flow showing the exponential backoff retry mechanism.

### Mermaid Diagram

```mermaid
graph TD
    A[TokenRefreshService.refreshToken] --> B{Refresh In Progress?}
    B -->|Yes| C[Wait for Completer]
    B -->|No| D[Acquire Mutex Lock]
    C --> E[Return Result]
    D --> F[Attempt 1: Refresh Token]
    F --> G{Success?}
    G -->|Yes| H[Emit Success Event]
    G -->|No| I{Recoverable Error?}
    I -->|Yes| J[Wait 1s (Exponential Backoff)]
    I -->|No| K[Emit Failure Event]
    J --> L[Attempt 2: Refresh Token]
    L --> M{Success?}
    M -->|Yes| H
    M -->|No| N{Recoverable Error?}
    N -->|Yes| O[Wait 2s]
    N -->|No| K
    O --> P[Attempt 3: Refresh Token]
    P --> Q{Success?}
    Q -->|Yes| H
    Q -->|No| R[Emit Max Retries Exceeded]
    H --> S[Return AuthSession]
    K --> T[Throw AuthException]
    R --> T

    style H fill:#c8e6c9
    style K fill:#ffcdd2
    style R fill:#ffcdd2
    style S fill:#c8e6c9
    style T fill:#ffcdd2
```

### Retry Logic Table

| Attempt | Backoff Delay | Total Delay | Status |
|---------|---------------|-------------|--------|
| 1       | 0s            | 0s          | First attempt |
| 2       | 1s            | 1s          | After first failure |
| 3       | 2s            | 3s          | After second failure |
| 4       | 4s            | 7s          | After third failure (rare) |
| Max     | 32s           | 63s         | Maximum backoff cap |

**Note**: In practice, we limit to 3 attempts, so max total delay is 1s + 2s = 3s.

### Retry Conditions

**Will Retry** ✅:
- Network errors (NETWORK_ERROR, network_connectivity)
- Network timeouts (network_timeout)
- Temporary server errors (5xx)
- Unknown errors

**Won't Retry** ❌:
- Invalid credentials (INVALID_CREDENTIALS)
- User not found (USER_NOT_FOUND)
- Email not verified (EMAIL_NOT_VERIFIED)
- Token refresh exceeded limit

## Queue Management

How multiple concurrent requests are handled during token refresh.

### Mermaid Diagram

```mermaid
graph TD
    A[Request 1: 401 Error] --> B[RefreshQueueManager]
    C[Request 2: 401 Error] --> B
    D[Request 3: 401 Error] --> B
    E[Request 4: Background Refresh] --> B

    B --> F{Refresh In Progress?}
    F -->|No| G[Start TokenRefreshService]
    F -->|Yes| H[Add to Queue]

    G --> I[Create Completer]
    I --> J[Store Request 1 Completer]
    H --> K[Store Request 2,3,4 Completers]

    J --> L[Perform Token Refresh]
    K --> L

    L --> M{Refresh Result}
    M -->|Success| N[Complete All Completers with New Session]
    M -->|Failure| O[Complete All Completers with Error]

    N --> P[Request 1: Retry with New Token]
    N --> Q[Request 2: Retry with New Token]
    N --> R[Request 3: Retry with New Token]
    N --> S[Request 4: Success]

    O --> T[Request 1: Throw Error]
    O --> U[Request 2: Throw Error]
    O --> V[Request 3: Throw Error]
    O --> W[Request 4: Throw Error]

    style N fill:#c8e6c9
    style O fill:#ffcdd2
```

### Queue Behavior

**Scenario 1: Single Refresh Request**
```
Request → RefreshQueueManager → TokenRefreshService → Response
```

**Scenario 2: Multiple Concurrent Requests**
```
Request1 ──┐
Request2 ──┼──→ RefreshQueueManager → TokenRefreshService → Response
Request3 ──┘                                           (shared)
                                                     ↓
                                    ┌─────────────────┴─────────────────┐
                                    ↓                                   ↓
                              Request1 completes                 Request2 completes
                              Request3 completes                 Request3 completes
```

**Benefits**:
- Prevents duplicate refresh calls
- Reduces network traffic
- Improves performance
- Maintains consistency

## Error Handling Flow

How errors are categorized and handled during token refresh.

### Mermaid Diagram

```mermaid
graph TD
    A[Token Refresh Attempt] --> B{Error Type}
    B -->|Network Error| C[AuthErrorHandler.categorize]
    B -->|Credential Error| C
    B -->|Rate Limit Error| C
    B -->|Server Error| C
    B -->|Unknown Error| C

    C --> D{Error Category}
    D -->|Network| E[Return recoverable=true]
    D -->|Credentials| F[Return recoverable=false]
    D -->|Expired Token| G[Return recoverable=true]
    D -->|Rate Limit| H[Return recoverable=false]
    D -->|Server| I[Return recoverable=true]

    E --> J{Attempt < 3?}
    F --> K[Throw AuthException Immediately]
    G --> J
    H --> L[Wait and Retry After Delay]
    I --> J

    J -->|Yes| M[Exponential Backoff Retry]
    J -->|No| N[Throw MaxRetriesExceeded]
    L --> O[Return RetryAfter Time]

    M --> P[Next Attempt]
    N --> Q[Show User Error Screen]
    O --> R[Schedule Retry]

    style K fill:#ffcdd2
    style N fill:#ffcdd2
    style Q fill:#ffcdd2
    style P fill:#fff9c4
    style R fill:#fff9c4
```

### Error Categorization

| Error Code | Category | Recoverable | User Action |
|------------|----------|-------------|-------------|
| NETWORK_ERROR | Network | ✅ Yes | Check internet connection |
| network_timeout | Network | ✅ Yes | Wait and retry |
| INVALID_CREDENTIALS | Credentials | ❌ No | Re-enter credentials |
| USER_NOT_FOUND | Credentials | ❌ No | Sign up for account |
| EMAIL_NOT_VERIFIED | Credentials | ❌ No | Verify email |
| TOKEN_EXPIRED | Expired | ✅ Yes | Auto-retry |
| REFRESH_TOKEN_EXPIRED | Expired | ❌ No | Re-authenticate |
| RATE_LIMIT_EXCEEDED | Rate Limit | ❌ No | Wait before retrying |
| SERVER_ERROR_500 | Server | ✅ Yes | Auto-retry |
| SERVER_ERROR_503 | Server | ✅ Yes | Auto-retry |

### User Experience

**Silent Refresh (Success)** ✅
- No user notification
- Tokens refreshed in background
- API calls proceed normally

**Silent Retry (Recoverable Error)** ⏳
- No user notification
- Automatic retry with backoff
- API calls wait and retry

**Visible Error (Non-Recoverable)** ⚠️
- Show user-friendly error message
- Provide actionable recovery steps
- Offer retry or re-authenticate options

## App Lifecycle Integration

How token refresh behaves during app lifecycle changes.

### Mermaid Diagram

```mermaid
stateDiagram-v2
    [*] --> Foreground: App Launch
    Foreground --> Refreshing: Token at 75% lifetime
    Refreshing --> Foreground: Refresh Complete
    Foreground --> Background: User presses home
    Background --> Foreground: User returns to app
    Foreground --> Paused: System dialog/phone call
    Paused --> Foreground: Dialog dismissed
    Foreground --> Detached: App swiped away
    Background --> Detached: System kills app
    Detached --> [*]

    note right of Refreshing
        Background refresh
        continues while
        app is foregrounded
    end note

    note right of Background
        Refresh timer
        paused to save
        battery
    end note

    note right of Detached
        All timers
        cancelled
        gracefully
    end note
```

### Lifecycle States

| State | Description | Refresh Behavior |
|-------|-------------|------------------|
| **resumed** | App is visible and running | ✅ Active refresh |
| **inactive** | App is in foreground but not focused | ⏸️ Paused |
| **paused** | App is in background | ⏸️ Paused |
| **detached** | App is being destroyed | ❌ Stopped |

## Summary

### Key Features

1. **Dual Strategy**: Both proactive and reactive token refresh
2. **Smart Retry**: Exponential backoff with intelligent error categorization
3. **Queue Management**: Deduplicates concurrent refresh requests
4. **Lifecycle Aware**: Pauses refresh when app is backgrounded
5. **User-Friendly**: Silent on success, helpful on failure

### Performance Characteristics

- **Proactive Refresh**: Happens at 75% of token lifetime (~45 min)
- **Reactive Refresh**: Triggered on 401 errors
- **Max Retry Time**: 3 seconds (1s + 2s backoff)
- **Queue Timeout**: 30 seconds for pending requests
- **Success Rate**: >95% with retry logic

---

**Document Version**: 1.0
**Last Updated**: 2026-01-04
**Maintainer**: SoloAdventurer Team
