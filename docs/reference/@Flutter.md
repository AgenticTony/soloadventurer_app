# Flutter Documentation (Updated for 2026)

Official Documentation: [Flutter Documentation](https://docs.flutter.dev/)

**Current Version:** Flutter 3.27+ (November 2024+)

Flutter is Google's UI toolkit for building natively compiled applications. For complete and up-to-date documentation, please refer to the official Flutter documentation at https://docs.flutter.dev/

> **🚀 2026 Update:** This document now covers Flutter 3.27+ features including go_router patterns, modern async widgets, Dart 3 pattern matching, and latest best practices.

## Key Documentation Links

### 1. **Getting Started**
   - [Install Flutter](https://docs.flutter.dev/get-started/install)
   - [Set up an editor](https://docs.flutter.dev/get-started/editor)
   - [Test drive](https://docs.flutter.dev/get-started/test-drive)

### 2. **Development (Modern Patterns)**
   - [Widget catalog](https://docs.flutter.dev/ui/widgets)
   - [Navigation & Routing with go_router](https://docs.flutter.dev/ui/navigation)
   - [State management](https://docs.flutter.dev/data-and-backend/state-mgmt/intro)
   - [Async widgets patterns](https://docs.flutter.dev/data-and-backend/async)

### 3. **Platform Integration**
   - [Platform channels](https://docs.flutter.dev/platform-integration/platform-channels)
   - [Platform-specific code](https://docs.flutter.dev/platform-integration/ios/platform-views)
   - [Web support](https://docs.flutter.dev/platform-integration/web)

### 4. **Tools & Performance**
   - [DevTools](https://docs.flutter.dev/tools/devtools/overview)
   - [Performance best practices](https://docs.flutter.dev/perf/best-practices)
   - [Flutter 3.27 Release Notes](https://docs.flutter.dev/release/release-notes/release-notes-3.27.0)

## API Reference
- [Flutter API documentation](https://api.flutter.dev/)
- [Dart API documentation](https://api.dart.dev/)

## What's New in Flutter 3.27+ (2024-2026)

### Key Features Added:
- **Wide-gamut color support** for enhanced display capabilities
- **Streamlined asset management** - improved handling of app resources
- **37 new Cupertino widgets** for iOS 17+ compatibility
- **Improved focus handling** across platforms
- **Impeller rendering engine** for better graphics performance
- **Web enhancements** with improved platform support
- **Enhanced DevTools** with new debugging features

---

## Core Concepts (2026 Edition)

### 1. Modern Navigation with go_router

**⚠️ DEPRECATED:** Navigator 1.0 (MaterialApp routes)
**✅ RECOMMENDED:** go_router for declarative navigation

```dart
// Modern go_router setup
import 'package:go_router/go_router.dart';

final router = GoRouter(
  routes: [
    // StatefulShellRoute for bottom navigation with state preservation
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return ScaffoldWithNavBar(navigationShell: navigationShell);
      },
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/home',
              pageBuilder: (context, state) => MaterialPage(child: HomeScreen()),
            ),
          ],
        ),
        // More branches...
      ],
    ),

    // Protected route with redirect
    GoRoute(
      path: '/profile',
      redirect: (context, state) {
        final isAuthenticated = state.uri.queryParameters['auth'] == 'true';
        return isAuthenticated ? null : '/login';
      },
      pageBuilder: (context, state) => MaterialPage(child: ProfileScreen()),
    ),
  ],
);

// In your app
MaterialApp.router(
  routerConfig: router,
);
```

### 2. Modern State Management Patterns

**✅ RECOMMENDED:** Riverpod with @riverpod code generation

```dart
// Modern @riverpod pattern
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'my_provider.g.dart';

@riverpod
class Counter extends _$Counter {
  @override
  int build() => 0;

  void increment() => state++;
  void decrement() => state--;
}

// Usage in widget
class MyWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final count = ref.watch(counterProvider);
    return Text('Count: $count');
  }
}
```

### 3. Async State with AsyncNotifier

```dart
@riverpod
class UserRepository extends _$UserRepository {
  @override
  Future<User> build() async {
    // Initialization happens once
    return fetchUser();
  }

  Future<void> updateUser(User user) async {
    // Modern AsyncLoading syntax
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      return await updateUserApi(user);
    });
  }
}
```

### 4. Dart 3 Pattern Matching in Widgets

```dart
// Modern pattern matching for state
class UserWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(userProvider);

    return switch (userAsync) {
      AsyncData(:final value?) => UserProfileView(user: value),
      AsyncError(:final error?) => ErrorView(error: error),
      _ => const LoadingSpinner(),
    };
  }
}
```

---

## Widget Types (2026 Patterns)

### 1. StatelessWidget (Preferred for simple widgets)

```dart
class Greeting extends StatelessWidget {
  final String name;

  const Greeting({super.key, required this.name});

  @override
  Widget build(BuildContext context) {
    return Text('Hello, $name!');
  }
}
```

### 2. ConsumerWidget (For Riverpod integration)

```dart
class UserProfile extends ConsumerWidget {
  const UserProfile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(userProvider);

    return userAsync.when(
      data: (user) => UserProfileView(user: user),
      loading: () => const LoadingSpinner(),
      error: (error, stack) => ErrorView(error: error),
    );
  }
}
```

### 3. ConsumerStatefulWidget (Only when absolutely necessary)

```dart
class MyStatefulWidget extends ConsumerStatefulWidget {
  const MyStatefulWidget({super.key});

  @override
  ConsumerState<MyStatefulWidget> createState() => _MyStatefulWidgetState();
}

class _MyStatefulWidgetState extends ConsumerState<MyStatefulWidget> {
  @override
  void initState() {
    super.initState();
    // Initialize after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(initializationProvider.notifier).initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(stateProvider);
    return Text('State: $state');
  }
}
```

---

## Modern Async Patterns

### 1. Proper Async Loading States

```dart
// ✅ CORRECT: Use AsyncLoading for Riverpod
state = const AsyncLoading();

// ❌ AVOID: Old AsyncValue.loading() (still works but not preferred)
state = const AsyncValue.loading();
```

### 2. AsyncValue.guard for Error Handling

```dart
Future<void> loadData() async {
  state = await AsyncValue.guard(() async {
    final data = await apiService.fetch();
    return data;
  });
  // Automatically handles loading, data, and error states
}
```

### 3. Cancellation Tokens Pattern

```dart
class _MyWidgetState extends State<MyWidget> {
  Future<void>? _loadFuture;

  @override
  void initState() {
    super.initState();
    _loadFuture = _loadData();
  }

  @override
  void dispose() {
    // Cancel async operation
    _loadFuture?.ignore();
    super.dispose();
  }

  Future<void> _loadData() async {
    // Your async logic here
  }
}
```

---

## Performance Optimization (2026 Best Practices)

### 1. Const Constructors

```dart
// ✅ Use const wherever possible
const Padding(
  padding: EdgeInsets.all(16.0),
  child: Text('Hello'),
)

// ✅ Const constructors for widgets
class MyWidget extends StatelessWidget {
  const MyWidget({super.key}); // Add const constructor
  // ...
}
```

### 2. Efficient List Rendering

```dart
// ✅ Use ListView.builder for long lists
ListView.builder(
  itemCount: items.length,
  itemBuilder: (context, index) {
    return ListTile(
      key: ValueKey(items[index].id), // Add keys for better diffing
      title: Text(items[index].title),
    );
  },
);
```

### 3. Repaint Boundaries

```dart
RepaintBoundary(
  child: ExpensiveWidget(), // Isolates repaints to this subtree
)
```

### 4. Avoiding Async Anti-Patterns

```dart
// ❌ AVOID: Calling async code in build
@override
Widget build(BuildContext context) {
  someAsyncFunction(); // Don't do this!
  return Container();
}

// ✅ CORRECT: Use initState, ref.listen, or FutureBuilder
@override
void initState() {
  super.initState();
  someAsyncFunction();
}

// OR

ref.listen(provider, (previous, next) {
  if (next is SomeCondition) {
    someAsyncFunction();
  }
});
```

---

## Testing (2026 Patterns)

### 1. Widget Testing

```dart
testWidgets('Counter increments smoke test', (WidgetTester tester) async {
  // Build our app and trigger a frame
  await tester.pumpWidget(MyApp());

  // Verify that our counter starts at 0
  expect(find.text('0'), findsOneWidget);
  expect(find.text('1'), findsNothing);

  // Tap the '+' icon and trigger a frame
  await tester.tap(find.byIcon(Icons.add));
  await tester.pump();

  // Verify that our counter has incremented
  expect(find.text('0'), findsNothing);
  expect(find.text('1'), findsOneWidget);
});
```

### 2. Integration Testing with go_router

```dart
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Navigation flow test', (tester) async {
    await tester.pumpWidget(MyApp());

    // Navigate using go_router
    context.go('/details');
    await tester.pumpAndSettle();

    expect(find.text('Details'), findsOneWidget);
  });
}
```

---

## Platform Integration

### 1. Platform Channels (2026)

```dart
import 'package:flutter/services.dart';

static const platform = MethodChannel('com.example.app/native');

Future<void> getNativeData() async {
  try {
    final result = await platform.invokeMethod('getData');
    debugPrint('Result: $result');
  } on PlatformException catch (e) {
    debugPrint('Error: ${e.message}');
  }
}
```

### 2. Platform-Specific Code

```dart
Widget buildPlatformSpecific() {
  return switch (Theme.of(context).platform) {
    TargetPlatform.iOS => CupertinoApp(
        home: CupertinoPageScaffold(
          navigationBar: CupertinoNavigationBar(middle: Text('Home')),
          child: HomeScreen(),
        ),
      ),
    TargetPlatform.android => MaterialApp(
        home: Scaffold(
          appBar: AppBar(title: Text('Home')),
          body: HomeScreen(),
        ),
      ),
    _ => MaterialApp(home: HomeScreen()), // Fallback
  };
}
```

---

## Asset Management (New in 3.27+)

```dart
# pubspec.yaml
flutter:
  # Streamlined asset management
  assets:
    - assets/images/
    - assets/icons/
    - assets/

# Access assets with modern API
import 'package:flutter/services.dart' show rootBundle;

final data = await rootBundle.load('assets/my_data.json');
```

---

## Best Practices Summary (2026)

### ✅ DO:
- Use **go_router** for navigation (not Navigator.push)
- Use **@riverpod** code generation for state management
- Use **AsyncLoading()** instead of AsyncValue.loading()
- Use **Dart 3 pattern matching** (switch statements)
- Use **const constructors** wherever possible
- Cancel async operations in dispose()
- Use **RepaintBoundary** for expensive widgets
- Implement **proper error boundaries**

### ❌ AVOID:
- Using Navigator 1.0 (use go_router)
- Calling async code directly in build()
- Forgetting to cancel streams/Futures
- Using setState when Riverpod would work better
- Ignoring the const keyword
- Creating widgets in build methods

---

## Resources

### Official
- [Flutter Documentation](https://docs.flutter.dev/)
- [Dart Documentation](https://dart.dev/guides)
- [Flutter Gallery (Demo App)](https://gallery.flutter.dev/)

### Community
- [Flutter YouTube Channel](https://www.youtube.com/flutterdev)
- [Flutter Awesome](https://flutterawesome.com/)
- [Very Good Ventures (Best Practices)](https://verygood.ventures/)

### Tools
- [DevTools](https://docs.flutter.dev/tools/devtools/overview)
- [Flutter Extension for VS Code](https://marketplace.visualstudio.com/items?itemName=Dart-Code.flutter)
- [Flutter Inspector](https://api.flutter.dev/flutter/widgets/WidgetsBinding-class.html)

---

**Last Updated:** January 2026
**Flutter Version:** 3.27+
**Dart Version:** 3.6+
