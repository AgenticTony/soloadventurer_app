import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soloadventurer/features/auth/presentation/providers/auth_notifier_provider.dart';
import 'package:soloadventurer/features/auth/presentation/providers/auth_navigation_provider.dart';
import 'package:soloadventurer/features/auth/presentation/widgets/navigation_error_handler.dart';

/// Screen for confirming password reset with code
class ConfirmPasswordResetScreen extends ConsumerStatefulWidget {
  /// Route name for navigation
  static const routeName = '/confirm-password-reset';

  /// Creates a new [ConfirmPasswordResetScreen]
  const ConfirmPasswordResetScreen({super.key});

  @override
  ConsumerState<ConfirmPasswordResetScreen> createState() =>
      _ConfirmPasswordResetScreenState();
}

class _ConfirmPasswordResetScreenState
    extends ConsumerState<ConfirmPasswordResetScreen> {
  final _formKey = GlobalKey<FormState>();
  final _codeController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isPasswordVisible = false;
  String? _email;

  @override
  void initState() {
    super.initState();
    // Get email from navigation arguments
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      if (args != null && args.containsKey('email')) {
        setState(() {
          _email = args['email'] as String;
        });
      }
    });
  }

  @override
  void dispose() {
    _codeController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _togglePasswordVisibility() {
    setState(() {
      _isPasswordVisible = !_isPasswordVisible;
    });
  }

  String? _validateCode(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter the verification code';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your new password';
    }

    // Password policy validation
    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }

    final hasUppercase = value.contains(RegExp(r'[A-Z]'));
    final hasLowercase = value.contains(RegExp(r'[a-z]'));
    final hasNumbers = value.contains(RegExp(r'[0-9]'));
    final hasSpecialCharacters =
        value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));

    if (!hasUppercase ||
        !hasLowercase ||
        !hasNumbers ||
        !hasSpecialCharacters) {
      return 'Password must contain uppercase, lowercase, numbers, and special characters';
    }

    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your new password';
    }

    if (value != _passwordController.text) {
      return 'Passwords do not match';
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    final authAsync = ref.watch(authProvider);

    // Listen for password reset success
    ref.listen(authProvider, (previous, next) {
      next.when(
        data: (authState) {
          // If password reset is no longer required (success), show message and navigate
          if (!authState.requiresPasswordReset && _email != null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Password reset successful. Please sign in.'),
                  backgroundColor: Colors.green,
                ),
              );
              ref.read(authNavigationProvider.notifier).navigateToLogin(null);
            });
          }
        },
        loading: () {},
        error: (error, stack) {
          // Error handling is done in .when() error state below
        },
      );
    });

    return NavigationErrorHandler(
      child: authAsync.when(
        loading: () => Scaffold(
          appBar: AppBar(
            title: const Text('Reset Password'),
          ),
          body: const Center(
            child: CircularProgressIndicator(),
          ),
        ),
        error: (error, stack) => Scaffold(
          appBar: AppBar(
            title: const Text('Reset Password'),
          ),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 48,
                  color: Colors.red,
                ),
                const SizedBox(height: 16),
                Text('Error: $error'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    ref.invalidate(authProvider);
                  },
                  child: const Text('Try Again'),
                ),
              ],
            ),
          ),
        ),
        data: (authState) => _buildResetForm(context, authAsync, authState),
      ),
    );
  }

  Widget _buildResetForm(
      BuildContext context, AsyncValue authAsync, authState) {
    final isLoading = authAsync.isLoading;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reset Password'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            ref.read(authNavigationProvider.notifier).navigateBack();
          },
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Enter Reset Code',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Enter the verification code sent to your email and choose a new password.',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                TextFormField(
                  controller: _codeController,
                  decoration: const InputDecoration(
                    labelText: 'Verification Code',
                    hintText: 'Enter the code from your email',
                    prefixIcon: Icon(Icons.security),
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  validator: _validateCode,
                  enabled: !isLoading,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    labelText: 'New Password',
                    hintText: 'Enter your new password',
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
                  validator: _validatePassword,
                  enabled: !isLoading,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _confirmPasswordController,
                  decoration: const InputDecoration(
                    labelText: 'Confirm New Password',
                    hintText: 'Confirm your new password',
                    prefixIcon: Icon(Icons.lock_outline),
                    border: OutlineInputBorder(),
                  ),
                  obscureText: true,
                  validator: _validateConfirmPassword,
                  enabled: !isLoading,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: isLoading ? null : _confirmPasswordReset,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: isLoading
                      ? const CircularProgressIndicator()
                      : const Text(
                          'Reset Password',
                          style: TextStyle(fontSize: 16),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _confirmPasswordReset() async {
    if (_email == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Email address is missing'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_formKey.currentState?.validate() ?? false) {
      await ref.read(authProvider.notifier).confirmPasswordReset(
            code: _codeController.text.trim(),
            newPassword: _passwordController.text,
            email: _email!,
          );
    }
  }
}
