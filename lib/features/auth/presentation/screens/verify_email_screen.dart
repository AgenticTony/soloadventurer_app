import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soloadventurer/features/auth/presentation/providers/auth_providers.dart';
import 'package:soloadventurer/features/auth/presentation/providers/auth_navigation_provider.dart';
import 'package:soloadventurer/features/auth/presentation/state/auth_state.dart';
import 'package:soloadventurer/features/profile/presentation/routes/profile_routes.dart';

class VerifyEmailScreen extends ConsumerStatefulWidget {
  static const routeName = '/verify-email';

  const VerifyEmailScreen({super.key});

  @override
  ConsumerState<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends ConsumerState<VerifyEmailScreen> {
  final _formKey = GlobalKey<FormState>();
  final _codeController = TextEditingController();
  bool _isLoading = false;
  String? _email;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authState = ref.read(authProvider);
      debugPrint('VerifyEmailScreen: Auth state on init: $authState');
      debugPrint(
          'VerifyEmailScreen: User email from state: ${authState.user?.email}');
      debugPrint(
          'VerifyEmailScreen: Needs verification: ${authState.needsVerification}');

      // Try to get email from navigation arguments first
      final args =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      final emailFromArgs = args?['email'] as String?;
      debugPrint(
          'VerifyEmailScreen: Email from navigation args: $emailFromArgs');

      setState(() {
        _email = emailFromArgs ??
            authState.user?.email ??
            (authState.needsVerification ? authState.user?.email : null);
      });

      debugPrint('VerifyEmailScreen: Final email state: $_email');

      if (_email == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'No email found for verification. Please try registering again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  String? _validateCode(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter the verification code';
    }
    if (value.length != 6) {
      return 'Verification code must be 6 digits';
    }
    return null;
  }

  Future<void> _verifyEmail() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() => _isLoading = true);
      try {
        final code = _codeController.text.trim();
        // Store the current auth state before verification
        final authState = ref.read(authProvider);
        final preservedUser = authState.user;

        debugPrint('VerifyEmailScreen: Starting verification');
        debugPrint('VerifyEmailScreen: Current auth state: $authState');
        debugPrint('VerifyEmailScreen: Preserved user: $preservedUser');
        debugPrint('VerifyEmailScreen: Local email state: $_email');
        debugPrint('VerifyEmailScreen: Verification code: $code');

        if (_email == null) {
          debugPrint('VerifyEmailScreen: No email available in local state');
          // Try to get email from preserved user first
          _email = preservedUser?.email ?? authState.user?.email;
          if (_email == null) {
            throw Exception('No email found for verification');
          }
          debugPrint('VerifyEmailScreen: Retrieved email: $_email');
        }

        debugPrint('VerifyEmailScreen: Proceeding with verification - Email: $_email, Code: $code');
        await ref.read(authProvider.notifier).verifyEmail(code, _email!);
        debugPrint('VerifyEmailScreen: Verification completed successfully');

        // Check the verification result
        final newState = ref.read(authProvider);
        debugPrint('VerifyEmailScreen: Auth state after verification: $newState');

        if (mounted) {
          // Wait for the next frame to ensure state is properly updated
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;

            if (newState.isAuthenticated) {
              // Use typed navigation method
              ref.read(authNavigationProvider.notifier).navigateToProfileEdit(
                isInitialSetup: true,
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Please try verifying your email again'),
                  backgroundColor: Colors.orange,
                ),
              );
            }
          });
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(e.toString()),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  Future<void> _resendCode() async {
    setState(() => _isLoading = true);
    try {
      await ref.read(authProvider.notifier).resendVerificationEmail();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Verification code sent'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final email = _email ?? authState.user?.email ?? '';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Verify Email'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            // Use navigation provider to handle back navigation
            ref.read(authNavigationProvider.notifier).navigateBack();
            // Reset the verification state
            ref.read(authProvider.notifier).clearVerificationState();
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
                const Icon(
                  Icons.email_outlined,
                  size: 64,
                  color: Colors.blue,
                ),
                const SizedBox(height: 24),
                Text(
                  'Verify your email',
                  style: Theme.of(context).textTheme.headlineSmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  'We sent a verification code to:',
                  style: Theme.of(context).textTheme.bodyLarge,
                  textAlign: TextAlign.center,
                ),
                Text(
                  email,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _codeController,
                  decoration: const InputDecoration(
                    labelText: 'Verification Code',
                    hintText: 'Enter 6-digit code',
                    prefixIcon: Icon(Icons.lock_outline),
                  ),
                  keyboardType: TextInputType.number,
                  maxLength: 6,
                  validator: _validateCode,
                  enabled: !_isLoading,
                ),
                const SizedBox(height: 24),
                if (_isLoading)
                  const Center(child: CircularProgressIndicator())
                else ...[
                  ElevatedButton(
                    onPressed: _verifyEmail,
                    child: const Text('Verify Email'),
                  ),
                  TextButton(
                    onPressed: _resendCode,
                    child: const Text('Resend Code'),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
