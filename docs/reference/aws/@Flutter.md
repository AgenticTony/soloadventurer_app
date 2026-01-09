# Flutter Documentation

Official Documentation: [Flutter Documentation](https://docs.flutter.dev/)

Flutter is Google's UI toolkit for building natively compiled applications. For complete and up-to-date documentation, please refer to the official Flutter documentation at https://docs.flutter.dev/

## Key Documentation Links

1. **Getting Started**

   - [Install Flutter](https://docs.flutter.dev/get-started/install)
   - [Set up an editor](https://docs.flutter.dev/get-started/editor)
   - [Test drive](https://docs.flutter.dev/get-started/test-drive)

2. **Development**

   - [Widget catalog](https://docs.flutter.dev/ui/widgets)
   - [Layouts](https://docs.flutter.dev/ui/layout)
   - [Navigation](https://docs.flutter.dev/ui/navigation)
   - [State management](https://docs.flutter.dev/data-and-backend/state-mgmt/intro)

3. **Platform Integration**

   - [Platform channels](https://docs.flutter.dev/platform-integration/platform-channels)
   - [Platform-specific code](https://docs.flutter.dev/platform-integration/ios/platform-views)
   - [Web support](https://docs.flutter.dev/platform-integration/web)

4. **Tools & Techniques**

   - [Hot reload](https://docs.flutter.dev/tools/hot-reload)
   - [DevTools](https://docs.flutter.dev/tools/devtools/overview)
   - [Testing](https://docs.flutter.dev/testing)

5. **Performance**
   - [Performance best practices](https://docs.flutter.dev/perf/rendering-performance)
   - [App size](https://docs.flutter.dev/perf/app-size)
   - [Memory](https://docs.flutter.dev/perf/memory)

## API Reference

- [Flutter API documentation](https://api.flutter.dev/)
- [Dart API documentation](https://api.dart.dev/)

## Cookbook

For common Flutter patterns and recipes:

- [Flutter Cookbook](https://docs.flutter.dev/cookbook)
- [Animations](https://docs.flutter.dev/ui/animations/tutorial)
- [Forms](https://docs.flutter.dev/cookbook/forms)
- [Navigation](https://docs.flutter.dev/cookbook/navigation)

## Best Practices and Guidelines

For best practices and implementation guidelines, refer to:

- [Style guide](https://docs.flutter.dev/release/breaking-changes/style-guide)
- [Design principles](https://docs.flutter.dev/resources/architectural-overview)
- [Performance best practices](https://docs.flutter.dev/perf/best-practices)

## Overview

Flutter is Google's UI toolkit for building natively compiled applications for mobile, web, and desktop from a single codebase. Key features include:

- Cross-platform development
- Hot reload for rapid development
- Rich widget library
- High-performance rendering

## Core Concepts

### 1. Widget Tree

Flutter uses a widget tree to build UIs:

```dart
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text('My App')),
        body: Center(
          child: MyCustomWidget(),
        ),
      ),
    );
  }
}
```

### 2. State Management

Flutter provides several ways to manage state:

1. **StatefulWidget**

```dart
class Counter extends StatefulWidget {
  @override
  _CounterState createState() => _CounterState();
}

class _CounterState extends State<Counter> {
  int _count = 0;

  void _increment() {
    setState(() {
      _count++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Text('Count: $_count');
  }
}
```

2. **InheritedWidget**

```dart
class DataProvider extends InheritedWidget {
  final String data;

  DataProvider({
    required this.data,
    required Widget child,
  }) : super(child: child);

  static DataProvider of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<DataProvider>()!;
  }

  @override
  bool updateShouldNotify(DataProvider old) => data != old.data;
}
```

### 3. Navigation

Flutter uses a stack-based navigation system:

```dart
// Push a new route
Navigator.of(context).push(
  MaterialPageRoute(
    builder: (context) => SecondScreen(),
  ),
);

// Pop the current route
Navigator.of(context).pop();

// Named routes
MaterialApp(
  initialRoute: '/',
  routes: {
    '/': (context) => HomeScreen(),
    '/details': (context) => DetailsScreen(),
  },
);
```

## Widget Types

### 1. Stateless Widgets

```dart
class Greeting extends StatelessWidget {
  final String name;

  const Greeting({required this.name});

  @override
  Widget build(BuildContext context) {
    return Text('Hello, $name!');
  }
}
```

### 2. Stateful Widgets

```dart
class ToggleButton extends StatefulWidget {
  @override
  _ToggleButtonState createState() => _ToggleButtonState();
}

class _ToggleButtonState extends State<ToggleButton> {
  bool _isOn = false;

  @override
  Widget build(BuildContext context) {
    return Switch(
      value: _isOn,
      onChanged: (value) {
        setState(() {
          _isOn = value;
        });
      },
    );
  }
}
```

### 3. Inherited Widgets

```dart
class ThemeProvider extends InheritedWidget {
  final ThemeData theme;

  const ThemeProvider({
    required this.theme,
    required Widget child,
  }) : super(child: child);

  static ThemeProvider of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<ThemeProvider>()!;
  }

  @override
  bool updateShouldNotify(ThemeProvider old) => theme != old.theme;
}
```

## Asynchronous Programming

### 1. Future Builder

```dart
FutureBuilder<User>(
  future: fetchUser(),
  builder: (context, snapshot) {
    if (snapshot.hasData) {
      return UserProfile(user: snapshot.data!);
    } else if (snapshot.hasError) {
      return ErrorWidget(snapshot.error!);
    } else {
      return LoadingSpinner();
    }
  },
);
```

### 2. Stream Builder

```dart
StreamBuilder<List<Message>>(
  stream: messageStream(),
  builder: (context, snapshot) {
    if (snapshot.hasData) {
      return MessageList(messages: snapshot.data!);
    } else if (snapshot.hasError) {
      return ErrorWidget(snapshot.error!);
    } else {
      return LoadingSpinner();
    }
  },
);
```

## Layout System

### 1. Basic Layout Widgets

```dart
Column(
  mainAxisAlignment: MainAxisAlignment.center,
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    Container(
      padding: EdgeInsets.all(8.0),
      child: Text('Item 1'),
    ),
    Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('Left'),
        Text('Right'),
      ],
    ),
  ],
);
```

### 2. Responsive Layout

```dart
LayoutBuilder(
  builder: (context, constraints) {
    if (constraints.maxWidth > 600) {
      return WideLayout();
    } else {
      return NarrowLayout();
    }
  },
);
```

## Platform Integration

### 1. Platform Channels

```dart
static const platform = MethodChannel('app/native_channel');

Future<void> getNativeData() async {
  try {
    final result = await platform.invokeMethod('getData');
    print(result);
  } on PlatformException catch (e) {
    print('Error: ${e.message}');
  }
}
```

### 2. Platform-Specific Code

```dart
if (Platform.isIOS) {
  return CupertinoApp(
    home: CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(),
      child: HomeScreen(),
    ),
  );
} else {
  return MaterialApp(
    home: Scaffold(
      appBar: AppBar(),
      body: HomeScreen(),
    ),
  );
}
```

## Testing

### 1. Widget Testing

```dart
testWidgets('Counter increments', (WidgetTester tester) async {
  await tester.pumpWidget(MyApp());
  expect(find.text('0'), findsOneWidget);
  await tester.tap(find.byIcon(Icons.add));
  await tester.pump();
  expect(find.text('1'), findsOneWidget);
});
```

### 2. Integration Testing

```dart
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Complete flow test', (tester) async {
    app.main();
    await tester.pumpAndSettle();

    await tester.tap(find.byType(LoginButton));
    await tester.pumpAndSettle();

    expect(find.text('Welcome'), findsOneWidget);
  });
}
```

## Performance Optimization

### 1. Widget Keys

```dart
ListView.builder(
  itemCount: items.length,
  itemBuilder: (context, index) {
    return ListTile(
      key: ValueKey(items[index].id),
      title: Text(items[index].title),
    );
  },
);
```

### 2. Const Constructors

```dart
class MyWidget extends StatelessWidget {
  const MyWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(8.0),
      child: const Text('Hello'),
    );
  }
}
```

### 3. Memory Management

```dart
class _MyWidgetState extends State<MyWidget> {
  StreamSubscription? _subscription;

  @override
  void initState() {
    super.initState();
    _subscription = stream.listen((_) {});
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
```
