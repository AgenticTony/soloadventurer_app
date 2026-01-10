import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soloadventurer/features/auth/presentation/providers/auth_notifier_provider.dart';
import 'package:soloadventurer/features/auth/presentation/providers/auth_navigation_provider.dart';
import 'package:soloadventurer/features/auth/presentation/routes/auth_routes.dart';

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

  @override
  Widget build(BuildContext context) {
    final authAsync = ref.watch(authNotifierProvider);

    // Listen for password reset success and navigate
    ref.listen(authNotifierProvider, (previous, next) {
      next.when(
        data: (authState) {
          // Only navigate if we just completed password reset
          if (authState.requiresPasswordReset &&
              _emailController.text.trim().isNotEmpty) {
            // Show success message
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content:
                    Text('Password reset email sent. Please check your inbox.'),
              ),
            );

            // Navigate to confirm password reset screen
            ref.read(authNavigationProvider.notifier).navigateTo(
              AuthRoutes.confirmPasswordReset,
              arguments: {'email': _emailController.text.trim()},
            );
          }
        },
        loading: () {},
        error: (error, stack) {
          // Show error snackbar
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(error.toString())),
          );
        },
      );
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reset Password'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: authAsync.when(
            loading: () => _buildForm(context, isLoading: true),
            error: (error, stack) => _buildForm(context, isLoading: false),
            data: (authState) => _buildForm(context, isLoading: false),
          ),
        ),
      ),
    );
  }

  Widget _buildForm(BuildContext context, {required bool isLoading}) {
    return Form(
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
            enabled: !isLoading,
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
            onPressed: isLoading ? null : _requestPasswordReset,
            child: isLoading
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
    );
  }

  Future<void> _requestPasswordReset() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final email = _emailController.text.trim();
    await ref.read(authNotifierProvider.notifier).forgotPassword(email);
  }
}
