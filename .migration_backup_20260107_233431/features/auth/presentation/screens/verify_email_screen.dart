import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soloadventurer/features/auth/presentation/providers/auth_provider.dart';
import 'package:soloadventurer/features/auth/domain/providers/auth_providers.dart';
import 'package:soloadventurer/features/auth/presentation/providers/auth_navigation_provider.dart';

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
          'VerifyEmailScreen: User email from state: ${authState.value?.user?.email}');
      debugPrint(
          'VerifyEmailScreen: Needs verification: ${authState.value?.requiresEmailVerification ?? false}');

      // Try to get email from navigation arguments first
      final args =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      final emailFromArgs = args?['email'] as String?;

      if (mounted) {
        setState(() {
          _email = emailFromArgs ??
              authState.value?.user?.email ??
              ((authState.value?.requiresEmailVerification ?? false)
                  ? authState.value?.user?.email
                  : null);
        });
      }

      debugPrint('VerifyEmailScreen: Final email state: $_email');

      // Check if we need to redirect to login
      if (!(authState.value?.requiresEmailVerification ?? false) && authState.value?.user == null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            ref.read(authNavigationProvider.notifier).navigateToLogin();
          }
        });
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
        final preservedUser = authState.value?.user;

        debugPrint('VerifyEmailScreen: Starting verification');
        debugPrint('VerifyEmailScreen: Current auth state: $authState');
        debugPrint('VerifyEmailScreen: Preserved user: $preservedUser');
        debugPrint('VerifyEmailScreen: Local email state: $_email');
        debugPrint('VerifyEmailScreen: Verification code: $code');

        if (_email == null) {
          debugPrint('VerifyEmailScreen: No email available in local state');
          // Try to get email from preserved user first
          _email = preservedUser?.email ?? authState.value?.user?.email;
          if (_email == null) {
            throw Exception('No email found for verification');
          }
          debugPrint('VerifyEmailScreen: Retrieved email: $_email');
        }

        debugPrint(
            'VerifyEmailScreen: Proceeding with verification - Email: $_email, Code: $code');
        await ref.read(authProvider.notifier).verifyEmail(code, _email!);
        debugPrint('VerifyEmailScreen: Verification completed successfully');

        // Check the verification result
        final newState = ref.read(authProvider);
        debugPrint(
            'VerifyEmailScreen: Auth state after verification: $newState');

        if (mounted) {
          // Wait for the next frame to ensure state is properly updated
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;

            // Only show message if verification failed but user is still logged in
            if ((newState.value?.requiresEmailVerification ?? false) && newState.value?.user != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Please try verifying your email again'),
                  backgroundColor: Colors.orange,
                ),
              );
            }
            // No need to handle navigation here as AuthNavigationNotifier will handle it
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
    final isLoading = ref.watch(authProvider).isLoading;

    debugPrint('VerifyEmailScreen build - Full authState: $authState');
    debugPrint('VerifyEmailScreen - isLoading: $isLoading');
    debugPrint(
        'VerifyEmailScreen - requiresEmailVerification: ${authState.value?.requiresEmailVerification}');
    debugPrint('VerifyEmailScreen - user: ${authState.value?.user}');
    debugPrint('VerifyEmailScreen - isLoggedIn: ${authState.value?.isAuthenticated}');

    // Show loading state
    if (isLoading || authState.isLoading) {
      debugPrint('VerifyEmailScreen: Showing loading state');
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    // Show error state
    if (authState.error != null) {
      debugPrint('VerifyEmailScreen: Showing error state: ${authState.error}');
      return Scaffold(
        body: Center(
          child: Text(
            authState.error.toString(),
            style: const TextStyle(color: Colors.red),
          ),
        ),
      );
    }

    debugPrint('VerifyEmailScreen: Showing verification screen');
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verify Email'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              ref.read(authProvider.notifier).signOut();
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Please verify your email',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            Text(
              'We sent a verification code to ${_email ?? authState.value?.user?.email}',
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _codeController,
                    decoration: const InputDecoration(
                      labelText: 'Verification Code',
                      hintText: 'Enter the code from your email',
                    ),
                    validator: _validateCode,
                    enabled: !_isLoading,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _verifyEmail,
                    child: _isLoading
                        ? const CircularProgressIndicator()
                        : const Text('Verify Email'),
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: _isLoading ? null : _resendCode,
                    child: const Text('Resend Code'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
