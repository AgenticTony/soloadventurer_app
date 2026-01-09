# Offline Indicator Widget

A comprehensive Flutter widget for displaying visual indicators when your app is offline. The widget monitors network connectivity and automatically shows/hides the indicator based on connection status.

## Features

- ✅ **Automatic connectivity monitoring** using `connectivity_plus`
- ✅ **Multiple display modes** (banner, badge, status bar, snackbar)
- ✅ **Fully customizable** appearance and behavior
- ✅ **Smooth animations** with configurable duration
- ✅ **Dismiss support** for temporary notifications
- ✅ **Position control** for badge mode
- ✅ **Callback support** for show/hide events
- ✅ **Material Design 3** theming
- ✅ **Zero configuration** required for basic usage
- ✅ **Riverpod integration** for state management

## Installation

Ensure you have the required dependencies in your `pubspec.yaml`:

```yaml
dependencies:
  flutter_riverpod: ^2.5.1
  connectivity_plus: ^6.1.3
```

The widget is already part of your project. Import it:

```dart
import 'package:soloadventurer/features/core/presentation/widgets/offline_indicator.dart';
```

## Quick Start

### Basic Banner (Most Common)

Add a global offline indicator to your app:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soloadventurer/features/core/presentation/widgets/offline_indicator.dart';

class MyApp extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      home: Stack(
        children: [
          // Your app content
          const HomeScreen(),

          // Offline indicator overlay
          const OfflineIndicator.banner(),
        ],
      ),
    );
  }
}
```

### Badge Mode

For a subtle corner indicator:

```dart
Scaffold(
  body: Stack(
    children: [
      YourContent(),
      OfflineIndicator.badge(
        position: OfflineIndicatorPosition.topRight,
      ),
    ],
  ),
)
```

## Display Modes

### 1. Banner Mode (Recommended)

A full-width banner at the top of the screen. Best for persistent offline indication.

```dart
const OfflineIndicator.banner(
  message: 'You\'re offline. Some features may be limited.',
)
```

**Use cases:**
- Global app-wide offline indicator
- Critical features require internet
- Travel journal app with sync functionality

### 2. Status Bar Mode

A thin, less intrusive bar at the top. Best when you want to show status without blocking content.

```dart
const OfflineIndicator.statusBar(
  message: 'No connection',
)
```

**Use cases:**
- Less prominent offline indication
- Content-heavy screens
- When offline mode is expected

### 3. Badge Mode

A small badge in a corner of the screen. Best for subtle indication.

```dart
OfflineIndicator.badge(
  position: OfflineIndicatorPosition.topRight,
  offset: const Offset(16, 16),
)
```

**Use cases:**
- Minimal UI approach
- Overlay on maps or images
- Secondary visual indication

### 4. Snackbar Mode

A floating notification with dismiss button. Best for temporary alerts.

```dart
const OfflineIndicator.snackbar(
  message: 'You\'re offline. Some features may be limited.',
  autoDismissDuration: Duration(seconds: 5),
)
```

**Use cases:**
- Temporary offline notifications
- When user can dismiss the indicator
- Non-critical offline indication

## Configuration Options

### OfflineIndicatorConfig

```dart
OfflineIndicator(
  config: OfflineIndicatorConfig(
    // Content
    showIcon: true,
    showMessage: true,
    message: 'You\'re offline',

    // Display
    mode: OfflineIndicatorMode.banner,

    // Styling
    backgroundColor: Colors.red,
    textColor: Colors.white,
    borderRadius: 8,

    // Icon
    icon: Icons.cloud_off,

    // Animation
    animate: true,
    animationDuration: Duration(milliseconds: 300),

    // Dismiss
    showDismissButton: true,
    autoDismissDuration: Duration(seconds: 5),
  ),
)
```

### Predefined Configurations

#### Badge Configuration

```dart
const OfflineIndicatorConfig.badge()
```

Creates a small, round badge with icon only.

#### Status Bar Configuration

```dart
const OfflineIndicatorConfig.statusBar(
  message: 'No connection',
)
```

Creates a thin status bar.

#### Snackbar Configuration

```dart
const OfflineIndicatorConfig.snackbar(
  message: 'You\'re offline.',
  autoDismissDuration: Duration(seconds: 5),
)
```

Creates a floating snackbar with dismiss button.

## Badge Positioning

Control where the badge appears:

```dart
OfflineIndicator.badge(
  position: OfflineIndicatorPosition.topRight,    // Top right corner
  // position: OfflineIndicatorPosition.topLeft,     // Top left corner
  // position: OfflineIndicatorPosition.bottomRight,  // Bottom right corner
  // position: OfflineIndicatorPosition.bottomLeft,   // Bottom left corner
  offset: const Offset(16, 16),  // Distance from edges
)
```

## Callbacks

Track when the indicator is shown and hidden:

```dart
OfflineIndicator(
  onShow: () {
    // Triggered when offline indicator appears
    print('User went offline');

    // You can:
    // - Pause data sync
    // - Show additional warnings
    // - Log analytics event
    // - Disable certain features
  },
  onHide: () {
    // Triggered when offline indicator disappears
    print('User came back online');

    // You can:
    // - Resume data sync
    // - Clear offline cache
    // - Show "back online" message
    // - Re-enable features
  },
)
```

## Integration Examples

### 1. Global App Indicator

Add to your root widget for app-wide coverage:

```dart
class App extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Stack(
      children: [
        // Your main app navigation
        Navigator(...),

        // Global offline indicator
        const OfflineIndicator.banner(
          message: 'You\'re offline. Changes will sync when connected.',
        ),
      ],
    );
  }
}
```

### 2. Screen-Specific Indicator

Add to specific screens that require internet:

```dart
class JournalEntryDetailScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Screen content
          const JournalEntryContent(),

          // Offline indicator for this screen
          const OfflineIndicator.statusBar(
            message: 'Offline - edits will sync later',
          ),
        ],
      ),
    );
  }
}
```

### 3. Conditional Display

Show different indicators based on context:

```dart
class MediaUploadScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isUploading = ref.watch(uploadProvider);

    return Stack(
      children: [
        const Content(),

        // Show different indicators based on state
        if (isUploading)
          const OfflineIndicator.snackbar(
            message: 'Offline - uploads will resume when connected',
            autoDismissDuration: Duration(seconds: 10),
          )
        else
          const OfflineIndicator.badge(
            position: OfflineIndicatorPosition.topRight,
          ),
      ],
    );
  }
}
```

### 4. With Custom Styling

Match your app's theme:

```dart
OfflineIndicator(
  config: OfflineIndicatorConfig(
    mode: OfflineIndicatorMode.banner,
    backgroundColor: Theme.of(context).colorScheme.surface,
    textColor: Theme.of(context).colorScheme.onSurface,
    icon: Icons.signal_wifi_off,
    borderRadius: 12,
    message: 'No Internet Connection',
  ),
)
```

## Theming

The widget automatically uses Material Design 3 theme colors:

```dart
// Default colors (override with config)
backgroundColor: theme.colorScheme.error,  // Red banner
textColor: theme.colorScheme.onError,     // White text
```

Customize for snackbar mode:

```dart
// Snackbar mode uses different defaults
backgroundColor: theme.colorScheme.errorContainer,
textColor: theme.colorScheme.onErrorContainer,
```

## State Management

The widget uses Riverpod's `ConnectivityNotifier` for state:

```dart
// Access connectivity state in your widgets
class MyWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isConnected = ref.watch(connectivityNotifierProvider);

    return Text(
      isConnected ? 'Online' : 'Offline',
    );
  }
}
```

## Best Practices

### 1. Use Banner Mode for Critical Features

When your app requires internet for core functionality:

```dart
// ✅ Good - Clear indication
const OfflineIndicator.banner(
  message: 'You\'re offline. Core features unavailable.',
)
```

### 2. Use Badge for Non-Critical Features

When offline mode is acceptable:

```dart
// ✅ Good - Subtle indication
const OfflineIndicator.badge()
```

### 3. Provide Clear Guidance

Tell users what to expect when offline:

```dart
// ✅ Good - Informative
const OfflineIndicator.banner(
  message: 'Offline - Changes will sync automatically when connected',
)

// ❌ Bad - Vague
const OfflineIndicator.banner(
  message: 'Offline',
)
```

### 4. Handle Dismiss Gracefully

Allow users to dismiss temporary notifications:

```dart
// ✅ Good - Dismissible
const OfflineIndicator.snackbar(
  showDismissButton: true,
  autoDismissDuration: Duration(seconds: 5),
)
```

### 5. Consider UX Flow

Position indicators where they don't interfere:

```dart
// ✅ Good - Bottom badge for map screens
OfflineIndicator.badge(
  position: OfflineIndicatorPosition.bottomRight,
)

// ❌ Bad - Top banner blocks content
// When using app bar with scrollable content
```

## Testing

### Manual Testing

1. Run your app
2. Toggle airplane mode or disable WiFi
3. Verify the indicator appears
4. Re-enable connection
5. Verify the indicator disappears

### Automated Testing

```dart
testWidgets('Offline indicator appears when disconnected', (tester) async {
  // Build widget
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        connectivityNotifierProvider.overrideWith((ref) => false),
      ],
      child: const MaterialApp(
        home: OfflineIndicator.banner(),
      ),
    ),
  );

  // Verify indicator is shown
  expect(find.text('You\'re offline'), findsOneWidget);
});
```

## Troubleshooting

### Indicator Not Showing

**Problem:** Indicator doesn't appear when offline

**Solutions:**
1. Ensure `connectivity_plus` permissions in platform configs
2. Check that provider is accessible in widget tree
3. Verify parent `Stack` allows positioning

### Indicator Not Disappearing

**Problem:** Indicator stays visible after reconnection

**Solutions:**
1. Check connectivity state with `ref.watch(connectivityNotifierProvider)`
2. Ensure no other instances are stacked
3. Verify `connectivity_plus` is emitting updates

### Animation Issues

**Problem:** Indicator animation is jerky or doesn't play

**Solutions:**
1. Check `animate` config property is `true`
2. Ensure `animationDuration` is appropriate
3. Verify parent widget allows animations

### Z-Index Problems

**Problem:** Indicator appears behind other widgets

**Solutions:**
1. Place `OfflineIndicator` last in `Stack` children
2. Use `Positioned` widget for explicit layering
3. Check material app `builder` property

## Platform-Specific Setup

### Android

Add to `android/app/src/main/AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
```

### iOS

Add to `ios/Runner/Info.plist`:

```xml
<key>NSAppTransportSecurity</key>
<dict>
    <key>NSAllowsLocalNetworking</key>
    <true/>
</dict>
```

### macOS

Add to `macos/Runner/DebugProfile.entitlements` and `Release.entitlements`:

```xml
<key>com.apple.security.network.client</key>
<true/>
```

## Performance Considerations

- ✅ Lightweight - Only rebuilds when connectivity changes
- ✅ Efficient animations using `SingleTickerProviderStateMixin`
- ✅ Automatic disposal of animation controllers
- ✅ Minimal memory footprint

## API Reference

### OfflineIndicator

Main widget for displaying offline status.

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `config` | `OfflineIndicatorConfig` | `const OfflineIndicatorConfig()` | Configuration for appearance and behavior |
| `position` | `OfflineIndicatorPosition` | `topRight` | Position for badge mode |
| `offset` | `Offset` | `Offset(16, 16)` | Offset from edges for badge |
| `onShow` | `VoidCallback?` | `null` | Callback when indicator is shown |
| `onHide` | `VoidCallback?` | `null` | Callback when indicator is hidden |

### OfflineIndicatorConfig

Configuration class for offline indicator.

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `showIcon` | `bool` | `true` | Whether to show icon |
| `showMessage` | `bool` | `true` | Whether to show text |
| `message` | `String` | `'You\'re offline'` | Message to display |
| `mode` | `OfflineIndicatorMode` | `banner` | Display mode |
| `backgroundColor` | `Color?` | `null` | Custom background color |
| `textColor` | `Color?` | `null` | Custom text color |
| `borderRadius` | `double` | `0` | Border radius |
| `icon` | `IconData` | `Icons.cloud_off` | Icon to display |
| `animate` | `bool` | `true` | Whether to animate |
| `animationDuration` | `Duration` | `300ms` | Animation duration |
| `showDismissButton` | `bool` | `false` | Show dismiss button |
| `autoDismissDuration` | `Duration?` | `null` | Auto-dismiss timeout |

### OfflineIndicatorMode

Display modes for the indicator.

| Value | Description |
|-------|-------------|
| `banner` | Full-width banner at top |
| `badge` | Small badge in corner |
| `statusBar` | Thin status bar at top |
| `snackbar` | Floating notification |

### OfflineIndicatorPosition

Position options for badge mode.

| Value | Description |
|-------|-------------|
| `topLeft` | Top left corner |
| `topRight` | Top right corner |
| `bottomLeft` | Bottom left corner |
| `bottomRight` | Bottom right corner |

## Examples

See `offline_indicator_example.dart` for complete working examples:
- Banner mode demonstration
- Status bar integration
- Badge positioning options
- Snackbar with auto-dismiss
- App integration patterns
- Custom styling
- Callback usage
- Multiple examples menu

## Future Enhancements

Potential improvements for future versions:
- [ ] Add "reconnecting" state indicator
- [ ] Connection strength indicator
- [ ] Configurable shake/slide animations
- [ ] Multiple simultaneous indicators
- [ ] Built-in "back online" toast
- [ ] Material 2/3 auto theming
- [ ] Platform-specific styling
- [ ] Animated connection icon
- [ ] Tap-to-retry functionality
- [ ] Custom widget builders

## Related Components

- **ConnectivityNotifier**: Riverpod provider for connectivity state
- **ConnectivityService**: Domain service for connectivity operations
- **ConnectivityServiceImpl**: Implementation using connectivity_plus

## License

This widget is part of the SoloAdventurer project.

## Support

For issues or questions:
1. Check the troubleshooting section above
2. Review the example implementations
3. Consult connectivity_plus documentation
4. Check platform permissions and setup
