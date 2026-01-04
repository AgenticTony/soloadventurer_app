import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soloadventurer/core/errors/exceptions.dart';
import 'package:soloadventurer/features/auth/domain/providers/auth_providers.dart';
import 'package:soloadventurer/features/auth/presentation/providers/auth_navigation_provider.dart';
import 'package:soloadventurer/features/auth/presentation/routes/auth_routes.dart';
import 'package:soloadventurer/features/auth/presentation/widgets/auth_error_display.dart';

/// Screen for initiating password reset
class ForgotPasswordScreen extends ConsumerStatefulWidget {
  /// Creates a new [ForgotPasswordScreen]
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isLoading = false;
  Object? _currentError;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _clearError() {
    setState(() {
      _currentError = null;
    });
  }

  Future<void> _requestPasswordReset() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);
    _clearError();

    try {
      final email = _emailController.text.trim();
      await ref.read(authNotifierProvider.notifier).forgotPassword(email);

      if (!mounted) return;

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password reset email sent. Please check your inbox.'),
          backgroundColor: Colors.green,
        ),
      );

      // Navigate to confirm password reset screen
      ref.read(authNavigationProvider.notifier).navigateTo(
        AuthRoutes.confirmPasswordReset,
        arguments: {'email': email},
      );
    } catch (e) {
      if (!mounted) return;
      // Store the error for display
      setState(() {
        _currentError = e;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reset Password'),
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
            child: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                const Text(
                  'Enter your email address and we\'ll send you instructions to reset your password.',
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    hintText: 'Enter your email',
                    prefixIcon: Icon(Icons.email),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  enabled: !_isLoading,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    if (!value.contains('@')) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _isLoading ? null : _requestPasswordReset,
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        )
                      : const Text('Send Reset Instructions'),
                ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
