import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soloadventurer/features/auth/presentation/providers/auth_notifier_provider.dart';
import 'package:soloadventurer/features/auth/presentation/providers/auth_navigation_provider.dart';
import 'package:soloadventurer/features/auth/presentation/routes/auth_routes.dart';
import 'package:soloadventurer/features/auth/presentation/widgets/auth_error_display.dart';

/// Login screen for the application
class LoginScreen extends ConsumerStatefulWidget {
  /// Route name for navigation
  static const routeName = '/login';

  /// Creates a new [LoginScreen]
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  Object? _currentError;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _clearError() {
    setState(() {
      _currentError = null;
    });
  }

  void _togglePasswordVisibility() {
    setState(() {
      _isPasswordVisible = !_isPasswordVisible;
    });
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your email';
    }

    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email';
    }

    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your password';
    }

    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    final authAsync = ref.watch(authProvider);

    // Listen for auth state changes to show error messages
    ref.listen(authProvider, (previous, next) {
      next.when(
        data: (authState) {
          // Don't show snackbar - errors are handled by UI
        },
        loading: () {},
        error: (error, stack) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(error.toString()),
                backgroundColor: Theme.of(context).colorScheme.error,
                behavior: SnackBarBehavior.floating,
                action: SnackBarAction(
                  label: 'Dismiss',
                  textColor: Colors.white,
                  onPressed: () {
                    ScaffoldMessenger.of(context).hideCurrentSnackBar();
                  },
                ),
              ),
            );
          }
        },
      );
    });

    return authAsync.when(
      loading: () => const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      ),
      error: (error, stack) => Scaffold(
        appBar: AppBar(
          title: const Text('Login'),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 48,
                  color: Colors.red,
                ),
                const SizedBox(height: 16),
                Text(
                  'An error occurred',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Text(
                  error.toString(),
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => ref.invalidate(authProvider),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      ),
      data: (authState) => _buildLoginForm(context, authState),
    );
  }

  Widget _buildLoginForm(BuildContext context, authState) {
    // Note: With AsyncValue pattern, loading state is handled by .when() in build()
    // When _buildLoginForm is called, we're already in data state
    const isLoading = false;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
      ),
      body: Column(
        children: [
          // Show error banner if there's an error
          if (_currentError != null)
            AuthErrorBanner(
              error: _currentError!,
              onDismiss: _clearError,
            ),

          // Form content
          Expanded(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                // App logo or image
                const Icon(
                  Icons.hiking,
                  size: 80,
                  color: Colors.blue,
                ),

                const SizedBox(height: 24),

                // App name
                const Text(
                  'SoloAdventurer',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 48),

                // Email field
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email),
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  validator: _validateEmail,
                  enabled: !isLoading,
                ),

                const SizedBox(height: 16),

                // Password field
                TextFormField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    prefixIcon: const Icon(Icons.lock),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isPasswordVisible
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                      onPressed: _togglePasswordVisibility,
                    ),
                    border: const OutlineInputBorder(),
                  ),
                  obscureText: !_isPasswordVisible,
                  textInputAction: TextInputAction.done,
                  validator: _validatePassword,
                  enabled: !isLoading,
                ),

                const SizedBox(height: 8),

                // Forgot password link
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: isLoading ? null : _navigateToForgotPassword,
                    child: const Text('Forgot Password?'),
                  ),
                ),

                const SizedBox(height: 24),

                // Login button
                ElevatedButton(
                  onPressed: isLoading ? null : _login,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text(
                          'Login',
                          style: TextStyle(fontSize: 16),
                        ),
                ),

                const SizedBox(height: 16),

                // Sign up link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Don't have an account?"),
                    TextButton(
                      onPressed: isLoading ? null : _navigateToSignUp,
                      child: const Text('Sign Up'),
                    ),
                  ],
                ),
                ],
              ),
            ),
          ),
          ),
          ),
        ],
      ),
    );
  }

  void _navigateToSignUp() {
    ref.read(authNavigationProvider.notifier).navigateTo(AuthRoutes.signup);
  }

  void _navigateToForgotPassword() {
    ref
        .read(authNavigationProvider.notifier)
        .navigateTo(AuthRoutes.forgotPassword);
  }

  Future<void> _login() async {
    if (_formKey.currentState?.validate() ?? false) {
      final email = _emailController.text.trim();
      final password = _passwordController.text;

      // Clear any previous error before attempting login
      _clearError();

      try {
        await ref.read(authProvider.notifier).signIn(
              email,
              password,
            );

        // Only navigate to home if we're still mounted and the login was successful
        if (mounted) {
          final authAsync = ref.read(authProvider);
          authAsync.whenData((authState) {
            if (authState.isLoggedIn) {
              ref
                  .read(authNavigationProvider.notifier)
                  .navigateTo(AuthRoutes.home);
            }
          });
        }
      } catch (e) {
        // Store the error for display
        if (mounted) {
          setState(() {
            _currentError = e;
          });
        }
      }
    }
  }
}
