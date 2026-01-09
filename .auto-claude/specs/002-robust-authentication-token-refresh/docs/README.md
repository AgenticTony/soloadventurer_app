# Authentication System Documentation

Welcome to the comprehensive documentation for the SoloAdventurer authentication system. This system provides robust, production-ready authentication with AWS Cognito integration, automatic token refresh, offline support, and comprehensive error handling.

## 📚 Documentation Index

### Getting Started

- **[Architecture Overview](./ARCHITECTURE.md)** - Start here! High-level system architecture, design principles, and technology stack.

### Core Concepts

- **[Token Refresh Flow](./TOKEN_REFRESH_FLOW.md)** - Detailed diagrams and explanations of proactive and reactive token refresh mechanisms.
- **[Session Management](./SESSION_MANAGEMENT.md)** - How sessions are created, stored, validated, and restored across app restarts.

### Integration & Usage

- **[Error Handling Reference](./ERROR_HANDLING.md)** - Complete guide to error types, categorization, user messages, and recovery actions.
- **[Integration Guide](./INTEGRATION_GUIDE.md)** - Step-by-step guide for integrating authentication into new features.

### Support

- **[Troubleshooting Guide](./TROUBLESHOOTING.md)** - Diagnostics and solutions for common authentication issues.

## 🚀 Quick Start

### 1. Check Authentication Status

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soloadventurer/features/auth/presentation/providers/auth_provider.dart';

class MyWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    if (!authState.isAuthenticated) {
      return LoginPromptWidget();
    }

    return ProtectedContentWidget(user: authState.user);
  }
}
```

### 2. Make Authenticated API Calls

```dart
// AuthInterceptor automatically adds tokens and handles refresh
final response = await dio.get('/api/user/profile');
```

### 3. Show Offline Indicator

```dart
final offlineState = ref.watch(offlineStateProvider);

return offlineState.when(
  data: (state) {
    if (state != OfflineAuthState.online) {
      return OfflineIndicator(
        isOffline: true,
        child: OfflineContent(),
      );
    }
    return OnlineContent();
  },
  loading: () => CircularProgressIndicator(),
  error: (_, __) => ErrorWidget(),
);
```

## 🎯 Key Features

### ✅ Robust Token Refresh
- **Proactive**: Automatic refresh at 75% of token lifetime
- **Reactive**: Refresh on 401 errors with retry
- **Smart Retry**: Exponential backoff (1s, 2s, 4s, 8s, 16s, 32s max)
- **Deduplication**: Queue manager prevents duplicate refresh calls

### ✅ Session Persistence
- **Secure Storage**: Tokens stored in flutter_secure_storage
- **Auto-Restoration**: Sessions restored on app startup
- **Validation**: Automatic validation with 24-hour refresh threshold
- **Caching**: Performance optimization with 5-minute session cache

### ✅ Offline Support
- **State Management**: 4-state tracking (online, offlineWithCache, offlineWithoutCache, needsSync)
- **Cached Data**: Access cached user data when offline
- **Sync on Reconnect**: Automatic sync when network restored
- **UI Indicators**: Offline indicators and banners

### ✅ Error Handling
- **Categorization**: 5 error categories (network, credentials, token, rate limit, server)
- **User Messages**: Friendly, actionable error messages
- **Recovery Steps**: Clear guidance for resolving errors
- **Smart Retry**: Automatic retry for recoverable errors

## 📊 Performance Characteristics

| Operation | Target | Acceptable |
|-----------|--------|------------|
| Login | < 3s | < 5s |
| Token Refresh | < 1s | < 2s |
| Session Restoration | < 500ms | < 1s |
| Background Refresh | Non-blocking | - |

## 🔧 Services Overview

| Service | Purpose | Key Features |
|---------|---------|--------------|
| **TokenRefreshService** | Token refresh with retry | Exponential backoff, mutex pattern, status stream |
| **PersistentSessionManager** | Session storage | Secure storage, caching, validation |
| **OfflineAuthManager** | Offline state management | Connectivity monitoring, cached data access, sync |
| **BackgroundRefreshScheduler** | Proactive refresh | App lifecycle aware, 75% threshold |
| **RefreshQueueManager** | Request deduplication | Queue pending requests, prevent race conditions |
| **AuthErrorHandler** | Error handling | Categorization, user messages, recovery steps |

## 🏗️ Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    Presentation Layer                        │
│  Auth Screens (Login, Signup) + Auth Widgets                │
└─────────────────────────────────────────────────────────────┘
                           ▲
                           │
┌──────────────────────────┴──────────────────────────────────┐
│                     Domain Layer                             │
│  AuthRepository (Interface) + User Entity                   │
└─────────────────────────────────────────────────────────────┘
                           ▲
                           │
┌──────────────────────────┴──────────────────────────────────┐
│                   Infrastructure Layer                       │
│  Services (TokenRefresh, SessionManager, OfflineAuth, etc.) │
│  + Data Sources (AuthRemote, AuthLocal)                     │
└─────────────────────────────────────────────────────────────┘
                           ▲
                           │
┌──────────────────────────┴──────────────────────────────────┐
│                      Core Layer                              │
│  HTTP Client (Dio) + AuthInterceptor + Connectivity         │
└─────────────────────────────────────────────────────────────┘
```

## 🔐 Security

- **Token Storage**: OS-level secure storage (Keychain/Keystore)
- **Token Masking**: Masked logging (first 8 ... last 4 chars)
- **Expiration Validation**: Tokens validated on every use
- **HTTPS Only**: All auth traffic over HTTPS
- **Session Versioning**: Support for future migrations

## 📱 App Lifecycle Integration

| State | Description | Refresh Behavior |
|-------|-------------|------------------|
| **resumed** | App visible and running | ✅ Active refresh |
| **inactive** | App in foreground but not focused | ⏸️ Paused |
| **paused** | App in background | ⏸️ Paused |
| **detached** | App being destroyed | ❌ Stopped |

## 🧪 Testing

All authentication components have comprehensive test coverage:

- **Unit Tests**: > 90% coverage for services
- **Integration Tests**: Complete auth flows, session persistence, offline scenarios
- **Widget Tests**: Error screens, retry buttons, offline indicators
- **E2E Tests**: Login, refresh, logout, offline-to-online transitions

## 🤝 Contributing

When modifying the authentication system:

1. Read the [Architecture Overview](./ARCHITECTURE.md) first
2. Follow existing code patterns
3. Add unit tests for new functionality
4. Update documentation as needed
5. Test offline and online scenarios
6. Verify token refresh behavior

## 📖 Additional Resources

- **AWS Cognito Documentation**: https://docs.aws.amazon.com/cognito/
- **Flutter Secure Storage**: https://pub.dev/packages/flutter_secure_storage
- **Riverpod Documentation**: https://riverpod.dev/
- **Dio Documentation**: https://pub.dev/packages/dio

## 🆘 Getting Help

If you encounter issues:

1. Check the [Troubleshooting Guide](./TROUBLESHOOTING.md)
2. Run the health check script
3. Enable debug logging
4. Collect system information
5. Create a detailed bug report

---

**Version**: 1.0
**Last Updated**: 2026-01-04
**Maintainer**: SoloAdventurer Team
