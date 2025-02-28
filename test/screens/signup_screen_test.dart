import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:soloadventurer/services/auth_service.dart';

// Create mock classes
class MockAuthService extends Mock implements AuthService {}

class MockNavigatorObserver extends Mock implements NavigatorObserver {}

// Create a fake Route class for testing
class MockRoute extends Fake implements Route<dynamic> {}

// Create a simple signup screen for testing
class TestSignUpScreen extends StatefulWidget {
  final AuthService authService;

  const TestSignUpScreen({super.key, required this.authService});

  @override
  State<TestSignUpScreen> createState() => _TestSignUpScreenState();
}

class _TestSignUpScreenState extends State<TestSignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _displayNameController = TextEditingController();
  final _confirmationCodeController = TextEditingController();
  bool _showConfirmation = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _displayNameController.dispose();
    _confirmationCodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sign Up')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child:
              _showConfirmation ? _buildConfirmationForm() : _buildSignUpForm(),
        ),
      ),
    );
  }

  Widget _buildSignUpForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
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
            decoration: const InputDecoration(
              labelText: 'Email',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.emailAddress,
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
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _firstNameController,
                  decoration: const InputDecoration(
                    labelText: 'First Name',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Required';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextFormField(
                  controller: _lastNameController,
                  decoration: const InputDecoration(
                    labelText: 'Last Name',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Required';
                    }
                    return null;
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _displayNameController,
            decoration: const InputDecoration(
              labelText: 'Display Name',
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a display name';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _passwordController,
            decoration: const InputDecoration(
              labelText: 'Password',
              border: OutlineInputBorder(),
            ),
            obscureText: true,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a password';
              }
              if (value.length < 8) {
                return 'Password must be at least 8 characters';
              }
              // Check for uppercase, lowercase, number, and symbol
              if (!RegExp(r'[A-Z]').hasMatch(value)) {
                return 'Password must contain at least one uppercase letter';
              }
              if (!RegExp(r'[a-z]').hasMatch(value)) {
                return 'Password must contain at least one lowercase letter';
              }
              if (!RegExp(r'[0-9]').hasMatch(value)) {
                return 'Password must contain at least one number';
              }
              if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(value)) {
                return 'Password must contain at least one symbol';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _confirmPasswordController,
            decoration: const InputDecoration(
              labelText: 'Confirm Password',
              border: OutlineInputBorder(),
            ),
            obscureText: true,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please confirm your password';
              }
              if (value != _passwordController.text) {
                return 'Passwords do not match';
              }
              return null;
            },
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                // Simulate signup
                if (_emailController.text == 'existing@example.com') {
                  setState(() {
                    _errorMessage = 'Email already exists';
                  });
                } else {
                  setState(() {
                    _errorMessage = null;
                    _showConfirmation = true;
                  });
                }
              }
            },
            child: const Text('Sign Up'),
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Already have an account? Sign In'),
          ),
        ],
      ),
    );
  }

  Widget _buildConfirmationForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Confirmation Code',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        const Text(
          'Please enter the confirmation code sent to your email.',
          style: TextStyle(fontSize: 16),
        ),
        if (_errorMessage != null)
          Container(
            padding: const EdgeInsets.all(8),
            margin: const EdgeInsets.symmetric(vertical: 16),
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
        const SizedBox(height: 24),
        TextField(
          controller: _confirmationCodeController,
          decoration: const InputDecoration(
            labelText: 'Confirmation Code',
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: () {
            if (_confirmationCodeController.text.isNotEmpty) {
              if (_confirmationCodeController.text == '123456') {
                Navigator.pop(context);
              } else {
                setState(() {
                  _errorMessage = 'Invalid confirmation code';
                });
              }
            }
          },
          child: const Text('Confirm Sign Up'),
        ),
        const SizedBox(height: 16),
        OutlinedButton(
          onPressed: () {
            // Simulate resending code
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content:
                    Text('Confirmation code resent. Please check your email.'),
              ),
            );
          },
          child: const Text('Resend Confirmation Code'),
        ),
        const SizedBox(height: 16),
        TextButton(
          onPressed: () {
            setState(() {
              _showConfirmation = false;
              _errorMessage = null;
            });
          },
          child: const Text('Back to Sign Up'),
        ),
      ],
    );
  }
}

void main() {
  late MockAuthService mockAuthService;
  late MockNavigatorObserver mockNavigatorObserver;

  setUpAll(() {
    // Register a fallback value for Route
    registerFallbackValue(MockRoute());
  });

  setUp(() {
    mockAuthService = MockAuthService();
    mockNavigatorObserver = MockNavigatorObserver();
  });

  Widget createTestApp() {
    return MaterialApp(
      home: TestSignUpScreen(authService: mockAuthService),
      navigatorObservers: [mockNavigatorObserver],
    );
  }

  testWidgets('SignUp screen shows all required form fields',
      (WidgetTester tester) async {
    // Build the signup screen
    await tester.pumpWidget(createTestApp());

    // Verify that the signup form elements are present
    expect(find.byType(AppBar), findsOneWidget);
    expect(find.widgetWithText(AppBar, 'Sign Up'), findsOneWidget);
    expect(find.widgetWithText(TextFormField, 'Email'), findsOneWidget);
    expect(find.widgetWithText(TextFormField, 'First Name'), findsOneWidget);
    expect(find.widgetWithText(TextFormField, 'Last Name'), findsOneWidget);
    expect(find.widgetWithText(TextFormField, 'Display Name'), findsOneWidget);
    expect(find.widgetWithText(TextFormField, 'Password'), findsOneWidget);
    expect(
        find.widgetWithText(TextFormField, 'Confirm Password'), findsOneWidget);
    expect(find.widgetWithText(ElevatedButton, 'Sign Up'), findsOneWidget);
    expect(find.text('Already have an account? Sign In'), findsOneWidget);
  });

  testWidgets('SignUp form validates email format',
      (WidgetTester tester) async {
    // Build the signup screen
    await tester.pumpWidget(createTestApp());

    // Enter invalid email and try to submit
    await tester.enterText(
        find.widgetWithText(TextFormField, 'Email'), 'invalid-email');

    // Fill other required fields with valid data
    await tester.enterText(
        find.widgetWithText(TextFormField, 'First Name'), 'John');
    await tester.enterText(
        find.widgetWithText(TextFormField, 'Last Name'), 'Doe');
    await tester.enterText(
        find.widgetWithText(TextFormField, 'Display Name'), 'johndoe');
    await tester.enterText(
        find.widgetWithText(TextFormField, 'Password'), 'Password123!');
    await tester.enterText(
        find.widgetWithText(TextFormField, 'Confirm Password'), 'Password123!');

    // Submit the form
    await tester.tap(find.widgetWithText(ElevatedButton, 'Sign Up'));
    await tester.pump();

    // Verify validation error is shown
    expect(find.text('Please enter a valid email'), findsOneWidget);
  });

  testWidgets('SignUp form validates password complexity',
      (WidgetTester tester) async {
    // Build the signup screen
    await tester.pumpWidget(createTestApp());

    // Fill all fields except password with valid data
    await tester.enterText(
        find.widgetWithText(TextFormField, 'Email'), 'valid@example.com');
    await tester.enterText(
        find.widgetWithText(TextFormField, 'First Name'), 'John');
    await tester.enterText(
        find.widgetWithText(TextFormField, 'Last Name'), 'Doe');
    await tester.enterText(
        find.widgetWithText(TextFormField, 'Display Name'), 'johndoe');

    // Test with too short password
    await tester.enterText(
        find.widgetWithText(TextFormField, 'Password'), 'short');
    await tester.enterText(
        find.widgetWithText(TextFormField, 'Confirm Password'), 'short');

    await tester.tap(find.widgetWithText(ElevatedButton, 'Sign Up'));
    await tester.pump();

    // Verify validation error for password length
    expect(find.text('Password must be at least 8 characters'), findsOneWidget);

    // Test with password missing uppercase
    await tester.enterText(
        find.widgetWithText(TextFormField, 'Password'), 'password123!');
    await tester.enterText(
        find.widgetWithText(TextFormField, 'Confirm Password'), 'password123!');

    await tester.tap(find.widgetWithText(ElevatedButton, 'Sign Up'));
    await tester.pump();

    // Verify validation error for missing uppercase
    expect(find.text('Password must contain at least one uppercase letter'),
        findsOneWidget);
  });

  testWidgets('SignUp form validates password confirmation match',
      (WidgetTester tester) async {
    // Build the signup screen
    await tester.pumpWidget(createTestApp());

    // Fill all fields with valid data
    await tester.enterText(
        find.widgetWithText(TextFormField, 'Email'), 'valid@example.com');
    await tester.enterText(
        find.widgetWithText(TextFormField, 'First Name'), 'John');
    await tester.enterText(
        find.widgetWithText(TextFormField, 'Last Name'), 'Doe');
    await tester.enterText(
        find.widgetWithText(TextFormField, 'Display Name'), 'johndoe');
    await tester.enterText(
        find.widgetWithText(TextFormField, 'Password'), 'Password123!');

    // Enter different password in confirmation field
    await tester.enterText(
        find.widgetWithText(TextFormField, 'Confirm Password'),
        'DifferentPassword123!');

    await tester.tap(find.widgetWithText(ElevatedButton, 'Sign Up'));
    await tester.pump();

    // Verify validation error for password mismatch
    expect(find.text('Passwords do not match'), findsOneWidget);
  });

  testWidgets('SignUp form validates required fields',
      (WidgetTester tester) async {
    // Build the signup screen
    await tester.pumpWidget(createTestApp());

    // Try to submit without entering any data
    await tester.tap(find.widgetWithText(ElevatedButton, 'Sign Up'));
    await tester.pump();

    // Verify validation errors are shown for required fields
    expect(find.text('Please enter your email'), findsOneWidget);
    expect(find.text('Required'), findsNWidgets(2)); // First Name and Last Name
    expect(find.text('Please enter a display name'), findsOneWidget);
    expect(find.text('Please enter a password'), findsOneWidget);
    expect(find.text('Please confirm your password'), findsOneWidget);
  });

  testWidgets('Shows confirmation form after successful signup',
      (WidgetTester tester) async {
    // Build the signup screen
    await tester.pumpWidget(createTestApp());

    // Fill all fields with valid data
    await tester.enterText(
        find.widgetWithText(TextFormField, 'Email'), 'valid@example.com');
    await tester.enterText(
        find.widgetWithText(TextFormField, 'First Name'), 'John');
    await tester.enterText(
        find.widgetWithText(TextFormField, 'Last Name'), 'Doe');
    await tester.enterText(
        find.widgetWithText(TextFormField, 'Display Name'), 'johndoe');
    await tester.enterText(
        find.widgetWithText(TextFormField, 'Password'), 'Password123!');
    await tester.enterText(
        find.widgetWithText(TextFormField, 'Confirm Password'), 'Password123!');

    // Submit the form
    await tester.tap(find.widgetWithText(ElevatedButton, 'Sign Up'));
    await tester.pump();

    // Verify that the confirmation form is shown
    expect(find.text('Please enter the confirmation code sent to your email.'),
        findsOneWidget);
    expect(
        find.widgetWithText(ElevatedButton, 'Confirm Sign Up'), findsOneWidget);
    expect(find.widgetWithText(OutlinedButton, 'Resend Confirmation Code'),
        findsOneWidget);
  });

  testWidgets('Shows error message on signup failure',
      (WidgetTester tester) async {
    // Build the signup screen
    await tester.pumpWidget(createTestApp());

    // Fill all fields with valid data but use an email that will trigger an error
    await tester.enterText(
        find.widgetWithText(TextFormField, 'Email'), 'existing@example.com');
    await tester.enterText(
        find.widgetWithText(TextFormField, 'First Name'), 'John');
    await tester.enterText(
        find.widgetWithText(TextFormField, 'Last Name'), 'Doe');
    await tester.enterText(
        find.widgetWithText(TextFormField, 'Display Name'), 'johndoe');
    await tester.enterText(
        find.widgetWithText(TextFormField, 'Password'), 'Password123!');
    await tester.enterText(
        find.widgetWithText(TextFormField, 'Confirm Password'), 'Password123!');

    // Submit the form
    await tester.tap(find.widgetWithText(ElevatedButton, 'Sign Up'));
    await tester.pump();

    // Verify that the error message is shown
    expect(find.text('Email already exists'), findsOneWidget);
  });

  testWidgets('Can navigate back to login screen', (WidgetTester tester) async {
    // Set up the mock navigator observer
    when(() => mockNavigatorObserver.didPop(any(), any())).thenReturn(null);

    // Build the signup screen
    await tester.pumpWidget(createTestApp());

    // Tap on the "Already have an account? Sign In" button
    await tester.tap(find.text('Already have an account? Sign In'));
    await tester.pumpAndSettle();

    // Verify that the navigator.pop was called
    verify(() => mockNavigatorObserver.didPop(any(), any())).called(1);
  });

  testWidgets('Confirmation form can navigate back to signup form',
      (WidgetTester tester) async {
    // Build the signup screen
    await tester.pumpWidget(createTestApp());

    // Fill all fields with valid data and submit to get to confirmation screen
    await tester.enterText(
        find.widgetWithText(TextFormField, 'Email'), 'valid@example.com');
    await tester.enterText(
        find.widgetWithText(TextFormField, 'First Name'), 'John');
    await tester.enterText(
        find.widgetWithText(TextFormField, 'Last Name'), 'Doe');
    await tester.enterText(
        find.widgetWithText(TextFormField, 'Display Name'), 'johndoe');
    await tester.enterText(
        find.widgetWithText(TextFormField, 'Password'), 'Password123!');
    await tester.enterText(
        find.widgetWithText(TextFormField, 'Confirm Password'), 'Password123!');

    await tester.tap(find.widgetWithText(ElevatedButton, 'Sign Up'));
    await tester.pump();

    // Verify we're on the confirmation screen
    expect(find.text('Please enter the confirmation code sent to your email.'),
        findsOneWidget);

    // Tap on the "Back to Sign Up" button
    await tester.tap(find.text('Back to Sign Up'));
    await tester.pump();

    // Verify that we're back on the signup form
    expect(find.widgetWithText(ElevatedButton, 'Sign Up'), findsOneWidget);
  });
}
