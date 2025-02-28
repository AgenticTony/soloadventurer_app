import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'services/auth_service.dart';
import 'providers/auth_provider.dart';
import 'screens/forgot_password_screen.dart';
import 'package:soloadventurer/services/api/dio_api_service.dart';
import 'package:soloadventurer/services/monitoring/aws_cloudwatch_monitoring.dart';
import 'package:soloadventurer/utils/error_handler.dart';
import 'package:soloadventurer/utils/performance_monitoring.dart';
import 'package:soloadventurer/screens/example_performance_screen.dart';
import 'dart:async';

void main() async {
  // Initialize Flutter bindings inside the same zone as runApp
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();

    final authService = AuthService();
    await authService.initialize();

    // Initialize API service with a temporary local URL
    // This will be replaced with the actual API URL in production
    final apiService = DioApiService(
      baseUrl:
          'https://hxs3jfwke3.execute-api.us-east-1.amazonaws.com/prod', // AWS API Gateway URL
    );

    // Initialize monitoring service
    final monitoringService = AwsCloudWatchMonitoring(apiService);

    // Initialize performance monitoring
    PerformanceMonitoring.initialize(monitoringService);

    // Initialize error handler
    final errorHandler = GlobalErrorHandler(monitoringService);

    // Run the app in the same zone
    runApp(
      const ProviderScope(
        child: MyApp(),
      ),
    );
  }, (error, stackTrace) {
    // This will catch any errors not caught by the Flutter framework
    print('Uncaught error: $error');
    // If monitoring service is initialized, report the error
    try {
      final monitoringService = AwsCloudWatchMonitoring(DioApiService(
        baseUrl: 'https://hxs3jfwke3.execute-api.us-east-1.amazonaws.com/prod',
      ));
      monitoringService.reportError(
        'UnhandledException',
        error,
        stackTrace,
      );
    } catch (e) {
      print('Failed to report error: $e');
    }
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Solo Adventurer',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const AuthWrapper(),
    );
  }
}

class AuthWrapper extends ConsumerWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    switch (authState.state) {
      case AuthState.initial:
      case AuthState.loading:
        return const Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        );
      case AuthState.authenticated:
        return const HomeScreen();
      case AuthState.unauthenticated:
        return const LoginScreen();
      case AuthState.error:
        return Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Authentication Error'),
                if (authState.errorMessage != null)
                  Text(authState.errorMessage!),
                ElevatedButton(
                  onPressed: () {
                    ref.read(authProvider.notifier).signOut();
                  },
                  child: const Text('Try Again'),
                ),
              ],
            ),
          ),
        );
    }
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Solo Adventurer'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Welcome to Solo Adventurer! 🎉',
              style: TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 20),
            Consumer(
              builder: (context, ref, _) {
                return ElevatedButton(
                  onPressed: () {
                    ref.read(authProvider.notifier).signOut();
                  },
                  child: const Text('Sign Out'),
                );
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const PerformanceExampleScreen(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
              ),
              child: const Text('Performance Monitor Demo'),
            ),
          ],
        ),
      ),
    );
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextFormField(
                controller: _usernameController,
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
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your password';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              Consumer(
                builder: (context, ref, _) {
                  final authState = ref.watch(authProvider);

                  return Column(
                    children: [
                      if (authState.state == AuthState.loading)
                        const CircularProgressIndicator()
                      else
                        ElevatedButton(
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              ref.read(authProvider.notifier).signIn(
                                    username: _usernameController.text,
                                    password: _passwordController.text,
                                  );
                            }
                          },
                          child: const Text('Sign In'),
                        ),
                      const SizedBox(height: 16),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const SignUpScreen(),
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
                              builder: (context) =>
                                  const ForgotPasswordScreen(),
                            ),
                          );
                        },
                        child: const Text('Forgot Password?'),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _displayNameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _showConfirmation = false;
  final _confirmationCodeController = TextEditingController();
  String? _errorMessage;

  @override
  void dispose() {
    _usernameController.dispose();
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
      appBar: AppBar(
        title: const Text('Sign Up'),
      ),
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
              helperText: 'This is how other users will see you',
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
              helperText:
                  'Password must be at least 8 characters with uppercase, lowercase, numbers, and symbols',
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
          Consumer(
            builder: (context, ref, _) {
              final authState = ref.watch(authProvider);

              return authState.state == AuthState.loading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          setState(() {
                            _errorMessage = null;
                          });

                          final notifier = ref.read(authProvider.notifier);
                          await notifier.signUp(
                            username: _emailController.text,
                            password: _passwordController.text,
                            email: _emailController.text,
                            firstName: _firstNameController.text,
                            lastName: _lastNameController.text,
                            displayName: _displayNameController.text,
                          );

                          final state = ref.read(authProvider);
                          if (state.state == AuthState.error) {
                            setState(() {
                              _errorMessage = state.errorMessage ??
                                  'An error occurred during sign up';
                            });
                          } else {
                            setState(() {
                              _showConfirmation = true;
                            });
                          }
                        }
                      },
                      child: const Text('Sign Up'),
                    );
            },
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
        const SizedBox(height: 8),
        Text(
          'If you don\'t receive a code, check your spam folder or verify your AWS Cognito settings.',
          style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
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
        Consumer(
          builder: (context, ref, _) {
            final authState = ref.watch(authProvider);

            return authState.state == AuthState.loading
                ? const Center(child: CircularProgressIndicator())
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      ElevatedButton(
                        onPressed: () async {
                          if (_confirmationCodeController.text.isNotEmpty) {
                            setState(() {
                              _errorMessage = null;
                            });

                            final notifier = ref.read(authProvider.notifier);
                            await notifier.confirmSignUp(
                              username: _emailController.text,
                              confirmationCode:
                                  _confirmationCodeController.text,
                            );

                            final state = ref.read(authProvider);
                            if (state.state == AuthState.error) {
                              setState(() {
                                _errorMessage = state.errorMessage ??
                                    'An error occurred during confirmation';
                              });
                            } else {
                              Navigator.pop(context);
                            }
                          }
                        },
                        child: const Text('Confirm Sign Up'),
                      ),
                      const SizedBox(height: 16),
                      OutlinedButton(
                        onPressed: () async {
                          setState(() {
                            _errorMessage = null;
                          });

                          final notifier = ref.read(authProvider.notifier);
                          await notifier.resendConfirmationCode(
                            username: _emailController.text,
                          );

                          final state = ref.read(authProvider);
                          if (state.state == AuthState.error) {
                            setState(() {
                              _errorMessage = state.errorMessage ??
                                  'An error occurred while resending code';
                            });
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                    'Confirmation code resent. Please check your email.'),
                              ),
                            );
                          }
                        },
                        child: const Text('Resend Confirmation Code'),
                      ),
                    ],
                  );
          },
        ),
        const SizedBox(height: 16),
        // Temporary button for development/testing only
        TextButton(
          onPressed: () {
            // This is just for testing - should be removed in production
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Bypassing email verification for testing'),
                backgroundColor: Colors.orange,
              ),
            );
            Navigator.pop(context);
          },
          child: const Text(
            'Skip Verification (Testing Only)',
            style: TextStyle(color: Colors.orange),
          ),
        ),
        const SizedBox(height: 16),
        TextButton(
          onPressed: () {
            setState(() {
              _showConfirmation = false;
            });
          },
          child: const Text('Back to Sign Up'),
        ),
      ],
    );
  }
}
