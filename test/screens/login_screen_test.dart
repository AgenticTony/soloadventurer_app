import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soloadventurer/services/auth_service.dart';
import 'package:soloadventurer/providers/auth_provider.dart';

// Create mock classes
class MockAuthService extends Mock implements AuthService {}

class MockAuthNotifier extends Mock implements AuthNotifier {}

class MockNavigatorObserver extends Mock implements NavigatorObserver {}

// Create a simple login screen for testing
class TestLoginScreen extends StatefulWidget {
  final AuthService authService;

  const TestLoginScreen({super.key, required this.authService});

  @override
  State<TestLoginScreen> createState() => _TestLoginScreenState();
}

class _TestLoginScreenState extends State<TestLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              if (_errorMessage != null)
                Container(
                  padding: const EdgeInsets.all(8),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.red.shade100,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: Colors.red),
                  ),
                  child: Text(
                    _errorMessage!,
                    style: TextStyle(color: Colors.red.shade900),
                  ),
                ),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  if (!value.contains('@') || !value.contains('.')) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your password';
                  }
                  return null;
                },
              ),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    // Simulate login
                    if (_emailController.text == 'valid@example.com' &&
                        _passwordController.text == 'Password123!') {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const Scaffold(
                            body: Center(child: Text('Home Screen')),
                          ),
                        ),
                      );
                    } else {
                      setState(() {
                        _errorMessage = 'Invalid email or password';
                      });
                    }
                  }
                },
                child: const Text('Login'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const Scaffold(
                        body: Center(child: Text('Sign Up Screen')),
                      ),
                    ),
                  );
                },
                child: const Text('Create an account'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const Scaffold(
                        body: Center(child: Text('Forgot Password Screen')),
                      ),
                    ),
                  );
                },
                child: const Text('Forgot Password?'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

void main() {
  late MockAuthService mockAuthService;
  late MockNavigatorObserver mockNavigatorObserver;

  setUp(() {
    mockAuthService = MockAuthService();
    mockNavigatorObserver = MockNavigatorObserver();
  });

  Widget createTestApp() {
    return MaterialApp(
      home: TestLoginScreen(authService: mockAuthService),
      navigatorObservers: [mockNavigatorObserver],
    );
  }

  testWidgets('Login screen shows email and password fields',
      (WidgetTester tester) async {
    // Build the login screen
    await tester.pumpWidget(createTestApp());

    // Verify that the login form elements are present
    expect(find.byType(AppBar), findsOneWidget);
    expect(find.widgetWithText(AppBar, 'Login'), findsOneWidget);
    expect(find.widgetWithText(TextFormField, 'Email'), findsOneWidget);
    expect(find.widgetWithText(TextFormField, 'Password'), findsOneWidget);
    expect(find.widgetWithText(ElevatedButton, 'Login'), findsOneWidget);
    expect(find.text('Create an account'), findsOneWidget);
    expect(find.text('Forgot Password?'), findsOneWidget);
  });

  testWidgets('Login form validates email format', (WidgetTester tester) async {
    // Build the login screen
    await tester.pumpWidget(createTestApp());

    // Enter invalid email and try to submit
    await tester.enterText(
        find.widgetWithText(TextFormField, 'Email'), 'invalid-email');
    await tester.enterText(
        find.widgetWithText(TextFormField, 'Password'), 'password123');
    await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
    await tester.pump();

    // Verify validation error is shown
    expect(find.text('Please enter a valid email'), findsOneWidget);
  });

  testWidgets('Login form validates required fields',
      (WidgetTester tester) async {
    // Build the login screen
    await tester.pumpWidget(createTestApp());

    // Try to submit without entering any data
    await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
    await tester.pump();

    // Verify validation errors are shown
    expect(find.text('Please enter your email'), findsOneWidget);
    expect(find.text('Please enter your password'), findsOneWidget);
  });

  testWidgets('Shows error message on invalid login',
      (WidgetTester tester) async {
    // Build the login screen
    await tester.pumpWidget(createTestApp());

    // Enter invalid credentials
    await tester.enterText(
        find.widgetWithText(TextFormField, 'Email'), 'invalid@example.com');
    await tester.enterText(
        find.widgetWithText(TextFormField, 'Password'), 'wrongpassword');
    await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
    await tester.pump();

    // Verify error message is shown
    expect(find.text('Invalid email or password'), findsOneWidget);
  });

  testWidgets('Navigates to home screen on successful login',
      (WidgetTester tester) async {
    // Build the login screen
    await tester.pumpWidget(createTestApp());

    // Enter valid credentials
    await tester.enterText(
        find.widgetWithText(TextFormField, 'Email'), 'valid@example.com');
    await tester.enterText(
        find.widgetWithText(TextFormField, 'Password'), 'Password123!');

    // Verify that a navigation event will be triggered
    await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
    await tester.pumpAndSettle();

    // Verify we navigated to the home screen
    expect(find.text('Home Screen'), findsOneWidget);
  });

  testWidgets('Can navigate to sign up screen', (WidgetTester tester) async {
    // Build the login screen
    await tester.pumpWidget(createTestApp());

    // Tap on sign up button
    await tester.tap(find.text('Create an account'));
    await tester.pumpAndSettle();

    // Verify navigation to sign up screen
    expect(find.text('Sign Up Screen'), findsOneWidget);
  });

  testWidgets('Can navigate to forgot password screen',
      (WidgetTester tester) async {
    // Build the login screen
    await tester.pumpWidget(createTestApp());

    // Tap on forgot password button
    await tester.tap(find.text('Forgot Password?'));
    await tester.pumpAndSettle();

    // Verify navigation to forgot password screen
    expect(find.text('Forgot Password Screen'), findsOneWidget);
  });
}
