# Riverpod 3.0 Pause/Resume Behavior

This document explains how Riverpod 3.0's pause/resume feature works in SoloAdventurer and how it affects provider behavior when widgets are not visible.

## Overview

Riverpod 3.0 introduced automatic pause/resume functionality for providers. When a widget is no longer visible on screen, its associated provider listeners automatically pause, reducing resource consumption.

**Official Documentation:**
- [Riverpod 3.0 What's New](https://riverpod.dev/docs/whats_new)
- [Migration from 2.0 to 3.0](https://riverpod.dev/docs/3.0_migration)

## How Pause/Resume Works

### Automatic Pause for Invisible Widgets

When using `ref.watch()` or `ref.listen()` in widgets, Riverpod 3.0 automatically pauses providers when:
1. The widget is no longer visible (e.g., navigating to a different screen)
2. `TickerMode.of(context)` is `false` (app is in background)

This is integrated with Flutter's `TickerMode` system, which automatically disables animations and timers when the app is not visible.

### Stream Provider Behavior

Stream providers automatically pause their subscriptions when the widget is not visible:

```dart
@riverpod
Stream<SyncStatus> syncStatusStream(Ref ref) {
  final syncManager = ref.watch(syncManagerProvider);
  return syncManager.syncStatusStream; // Pauses when widget is off-screen
}
```

### Provider Lifecycle

| Provider State | Widget Visible | Widget Hidden |
|----------------|---------------|--------------|
| `@riverpod` (no keepAlive) | Active | **Paused** |
| `@Riverpod(keepAlive: true)` | Active | **Active** |
| `@riverpod Stream` | Subscribing | **Paused** |

## Key Providers in SoloAdventurer

### Providers WITH `keepAlive: true` (Never Pause)

These providers must remain active even when widgets are not visible:

| Provider | File | Reason |
|----------|------|--------|
| `syncManagerProvider` | `offline_service_providers.dart` | Background sync coordination |
| `connectivityServiceProvider` | `offline_service_providers.dart` | Network status monitoring |
| `backgroundSyncServiceProvider` | `offline_service_providers.dart` | Background sync tasks |
| `backgroundCheckInServiceProvider` | `background_checkin_service_impl.dart` | Background check-ins |
| `backgroundTokenRefreshServiceProvider` | `background_token_refresh_service.dart` | Auth token refresh |
| `authProvider` | `auth_provider.dart` | User authentication state |
| `locationServiceProvider` | `core_service_providers.dart` | GPS tracking (when active) |
| `notificationServiceProvider` | `core_service_providers.dart` | Local notifications |

### Providers WITHOUT `keepAlive: true` (Can Pause)

These providers automatically pause when not visible:

| Provider | File | Behavior |
|----------|------|----------|
| `syncStatusStream` | `sync_status_provider.dart` | Pauses when sync screen not visible |
| `connectivityProvider` | `connectivity_provider.dart` | Pauses when no listeners |
| `safetyNotifier` | `safety_notifier.dart` | Pauses when safety screen not visible |
| `checkInNotifier` | `check_in_notifier.dart` | Pauses when check-in screen not visible |
| `trustedContactsNotifier` | `trusted_contacts_notifier.dart` | Pauses when contacts screen not visible |
| `locationSharingNotifier` | `location_sharing_notifier.dart` | Pauses when location screen not visible |

## Stream Subscriptions and Pause Behavior

### Current Implementation

The codebase has several notifiers that manage stream subscriptions manually:

```dart
@Riverpod(keepAlive: true)
class ConnectivityNotifier extends _$ConnectivityNotifier {
  StreamSubscription<ConnectivityStatus>? _subscription;

  @override
  ConnectivityState build() {
    _startMonitoring();
    return ConnectivityState.disconnected();
  }

  void _startMonitoring() {
    _subscription = _connectivityService.connectivityStream.listen(
      (status) => state = ConnectivityState.fromStatus(status),
    );
  }
}
```

**Important:** Stream subscriptions created directly in `build()` are NOT automatically paused by Riverpod 3.0. Only providers using `ref.watch()` or `ref.stream()` benefit from automatic pause/resume.

### Best Practice for Streams

Use `ref.onDispose()` to clean up subscriptions:

```dart
@riverpod
class MyNotifier extends _$MyNotifier {
  StreamSubscription? _subscription;

  @override
  MyData build() {
    final stream = ref.watch(myServiceProvider);

    _subscription = stream.listen((data) {
      state = data;
    });

    ref.onDispose(() {
      _subscription?.cancel();
    });

    return MyData.initial();
  }
}
```

## TickerMode Integration

Riverpod 3.0 integrates with Flutter's `TickerMode`. When `TickerMode.of(context)` is `false`:

- Provider listeners are paused
- Animation controllers stop
- Timer-based providers pause

### Example: Using TickerMode

```dart
@override
Widget build(BuildContext context) {
  final isActive = TickerMode.of(context);

  return TickerMode(
    enabled: isActive,
    child: Consumer(
      builder: (context, ref, child) {
        final status = ref.watch(syncStatusProvider);
        return SyncStatusWidget(status: status);
      },
    ),
  );
}
```

## Critical Services That Must Not Pause

### 1. Connectivity Monitoring

```dart
@Riverpod(keepAlive: true)
ConnectivityService connectivityService(Ref ref) {
  // Must keep running to detect network changes
  return ConnectivityServiceImpl();
}
```

**Reason:** App needs to detect network changes even when no UI is visible.

### 2. Background Sync

```dart
@Riverpod(keepAlive: true)
BackgroundSyncService backgroundSyncService(Ref ref) {
  // Must keep running for scheduled sync tasks
  return BackgroundSyncService(...);
}
```

**Reason:** Background sync must continue regardless of UI visibility.

### 3. Authentication State

```dart
@Riverpod(keepAlive: true)
AuthRepository authRepository(Ref ref) {
  // Must keep running for token refresh
  return AuthRepositoryImpl(...);
}
```

**Reason:** Token refresh must happen in background, even when app is backgrounded.

### 4. Location Tracking

```dart
@Riverpod(keepAlive: true)
LocationService locationService(Ref ref) {
  // Must keep running when tracking is active
  return LocationServiceImpl();
}
```

**Reason:** GPS tracking must continue during activities (hiking, solo travel).

## Verification Checklist

To verify pause/resume behavior is working correctly:

- [ ] Navigate to a screen with a provider
- [ ] Observe the provider is active (check logs/debug output)
- [ ] Navigate away from the screen
- [ ] Verify the provider is paused (subscriptions stopped)
- [ ] Navigate back to the screen
- [ ] Verify the provider resumes (subscriptions restart)

### Testing with DevTools

1. Open Flutter DevTools
2. Go to the "Performance" tab
3. Navigate between screens
4. Observe which providers are active/paused
5. Check for unnecessary CPU usage when app is backgrounded

## Common Pitfalls

### 1. Forgetting `ref.onDispose()`

**Problem:** Stream subscriptions continue even after widget is disposed.

**Solution:** Always clean up in `ref.onDispose()`:

```dart
ref.onDispose(() {
  _subscription?.cancel();
});
```

### 2. Using `keepAlive: true` Unnecessarily

**Problem:** Providers that should pause remain active, wasting resources.

**Solution:** Only use `keepAlive: true` for services that MUST run in background.

### 3. Manual Stream Subscriptions in `build()`

**Problem:** Manual subscriptions don't benefit from Riverpod's pause/resume.

**Solution:** Consider using `ref.watch()` with Stream providers or ensure proper cleanup.

## Monitoring Pause/Resume Behavior

### Adding Debug Logging

```dart
@riverpod
class MyNotifier extends _$MyNotifier {
  @override
  MyData build() {
    debugPrint('MyNotifier: Building/Resuming');
    ref.onDispose(() {
      debugPrint('MyNotifier: Disposing/Pausing');
    });
    return MyData.initial();
  }
}
```

### Measuring Resource Impact

To measure the impact of pause/resume:

1. **Before:** Monitor CPU/memory with all providers active
2. **After:** Monitor CPU/memory with providers paused
3. Compare the difference in resource usage

## Recommendations

### 1. Review All `keepAlive: true` Providers

Audit the current `keepAlive: true` providers and ensure they truly need to remain active:

```bash
grep -r "keepAlive: true" lib/
```

### 2. Consider Pausing Non-Essential Streams

For streams that don't need to update when off-screen:

- Location updates (when not tracking)
- Sync status (when not on sync screen)
- Safety status (when not in safety flow)

### 3. Use Selector Providers

Use selector providers to avoid unnecessary rebuilds and enable more granular pause behavior:

```dart
@riverpod
bool isSyncing(Ref ref) {
  return ref.watch(syncStatusProvider).isSyncing;
}
```

### 4. Document Provider Intent

Add comments to providers explaining why `keepAlive: true` is needed:

```dart
/// MUST remain active for background token refresh
@Riverpod(keepAlive: true)
AuthRepository authRepository(Ref ref) {
  return AuthRepositoryImpl();
}
```

## Future Enhancements

### 1. Conditional Pause Behavior

Consider adding app-level settings to control pause behavior:

```dart
@Riverpod(
  keepAlive: ref.watch(pauseSettingsProvider).disablePauseForSync
)
SyncManager syncManager(Ref ref) {
  return SyncManagerImpl();
}
```

### 2. Manual Pause Control

Use Riverpod 3.0's `pause()` and `resume()` methods for manual control:

```dart
final subscription = ref.listen(provider, (previous, next) {
  // Handle updates
});

// Manually pause
subscription.pause();

// Resume later
subscription.resume();
```

### 3. Integration with AppLifecycle

Already implemented via `AppLifecycleSyncManager`. Consider expanding to control provider pause/resume based on app lifecycle state.

## Resources

- [Riverpod 3.0 Pause/Resume Issue](https://github.com/rrousselGit/riverpod/issues/4123)
- [flutter_riverpod Changelog](https://pub.dev/packages/flutter_riverpod/changelog)
- [Riverpod Changelog 3.0.2](https://pub.dev/packages/riverpod/versions/3.0.2/changelog)

## Summary

- Riverpod 3.0 **automatically pauses** providers when widgets are not visible
- Providers with `keepAlive: true` **do not pause**
- Stream subscriptions created manually **do not automatically pause**
- Critical services (auth, sync, connectivity) use `keepAlive: true`
- UI-specific providers (safety screens, check-ins) should pause when off-screen
- Always use `ref.onDispose()` for cleanup
- Verify pause/resume behavior using DevTools and debug logging

---

**Last Updated:** 2026-01-06
**Riverpod Version:** 3.1.0
**flutter_riverpod Version:** 3.1.0
