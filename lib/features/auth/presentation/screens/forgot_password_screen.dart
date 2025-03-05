import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soloadventurer/features/auth/presentation/providers/auth_provider.dart';
import 'package:soloadventurer/features/auth/presentation/providers/auth_navigation_provider.dart';
import 'package:soloadventurer/features/auth/presentation/widgets/navigation_error_handler.dart';
import 'package:soloadventurer/features/auth/domain/usecases/forgot_password.dart';

/// Screen for initiating password reset
class ForgotPasswordScreen extends ConsumerStatefulWidget {
  /// Route name for navigation
  static const routeName = '/forgot-password';

  /// Creates a new [ForgotPasswordScreen]
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  RecoveryMethod _selectedMethod = RecoveryMethod.email;
  bool _isLoading = false;

  Future<void> _requestPasswordReset() async {
    final identifier = _selectedMethod == RecoveryMethod.email
        ? _emailController.text
        : _phoneController.text;

    if (identifier.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _selectedMethod == RecoveryMethod.email
                ? 'Please enter your email'
                : 'Please enter your phone number',
          ),
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final params = ForgotPasswordParams(
        identifier: identifier,
        method: _selectedMethod,
      );

      await ref.read(authProvider.notifier).forgotPassword(params);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Reset instructions sent successfully'),
            backgroundColor: Colors.green,
          ),
        );
        // Navigate to confirm password reset screen with the email
        ref
            .read(authNavigationProvider.notifier)
            .navigateToConfirmPasswordReset(identifier);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return NavigationErrorHandler(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Forgot Password'),
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
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Reset Your Password',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Choose how you want to reset your password.',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                ListTile(
                  title: const Text('Email'),
                  leading: Radio<RecoveryMethod>(
                    value: RecoveryMethod.email,
                    groupValue: _selectedMethod,
                    onChanged: _isLoading
                        ? null
                        : (RecoveryMethod? value) {
                            setState(() {
                              _selectedMethod = value!;
                            });
                          },
                  ),
                ),
                ListTile(
                  title: const Text('SMS'),
                  leading: Radio<RecoveryMethod>(
                    value: RecoveryMethod.sms,
                    groupValue: _selectedMethod,
                    onChanged: _isLoading
                        ? null
                        : (RecoveryMethod? value) {
                            setState(() {
                              _selectedMethod = value!;
                            });
                          },
                  ),
                ),
                const SizedBox(height: 16),
                if (_selectedMethod == RecoveryMethod.email)
                  TextField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      hintText: 'Enter your email address',
                      prefixIcon: Icon(Icons.email),
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    enabled: !_isLoading,
                  )
                else
                  TextField(
                    controller: _phoneController,
                    decoration: const InputDecoration(
                      labelText: 'Phone Number',
                      hintText: 'Enter your phone number',
                      prefixIcon: Icon(Icons.phone),
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.phone,
                    enabled: !_isLoading,
                  ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _isLoading ? null : _requestPasswordReset,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
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
                const SizedBox(height: 16),
                TextButton(
                  onPressed: _isLoading
                      ? null
                      : () => ref
                          .read(authNavigationProvider.notifier)
                          .navigateToLogin(),
                  child: const Text('Back to Login'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }
}
