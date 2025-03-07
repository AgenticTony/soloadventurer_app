import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soloadventurer/features/auth/presentation/providers/auth_provider.dart';
import 'package:soloadventurer/features/auth/presentation/providers/auth_navigation_provider.dart';
import 'package:soloadventurer/features/auth/presentation/state/auth_state.dart';
import 'package:soloadventurer/features/profile/presentation/routes/profile_routes.dart';
import 'package:soloadventurer/features/auth/presentation/routes/auth_routes.dart';

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
          'VerifyEmailScreen: Needs verification: ${authState.value?.needsVerification}');

      // Try to get email from navigation arguments first
      final emailFromArgs =
          ModalRoute.of(context)?.settings.arguments as String?;

      if (mounted) {
        setState(() {
          _email = emailFromArgs ??
              authState.value?.user?.email ??
              (authState.value?.needsVerification == true
                  ? authState.value?.user?.email
                  : null);
        });
      }

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

            if (newState.value?.isAuthenticated ?? false) {
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

    // Redirect if user is authenticated
    if (authState.value?.isAuthenticated ?? false) {
      ref.read(authNavigationProvider.notifier).navigateToHome();
      return const SizedBox.shrink();
    }

    // Show loading state
    if (authState.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    // Show error state
    if (authState.hasError) {
      return Center(
        child: Text(
          authState.error.toString(),
          style: const TextStyle(color: Colors.red),
        ),
      );
    }

    final user = authState.value?.user;
    if (user == null) {
      ref.read(authNavigationProvider.notifier).navigateToLogin();
      return const SizedBox.shrink();
    }

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
              'We sent a verification code to ${user.email}',
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
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter the verification code';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState?.validate() ?? false) {
                        ref.read(authProvider.notifier).verifyEmail(
                              _codeController.text,
                              user.email,
                            );
                      }
                    },
                    child: const Text('Verify Email'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () {
                ref.read(authProvider.notifier).resendVerificationEmail();
              },
              child: const Text('Resend Code'),
            ),
          ],
        ),
      ),
    );
  }
}
