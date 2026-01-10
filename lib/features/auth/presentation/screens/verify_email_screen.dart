import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soloadventurer/features/auth/presentation/providers/auth_notifier_provider.dart';
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
  String? _email;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authAsync = ref.read(authNotifierProvider);
      final authState = authAsync.value;
      debugPrint('VerifyEmailScreen: Auth state on init: $authState');
      debugPrint(
          'VerifyEmailScreen: User email from state: ${authState?.user?.email}');
      debugPrint(
          'VerifyEmailScreen: Needs verification: ${authState?.requiresEmailVerification}');

      // Try to get email from navigation arguments first
      final args =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      final emailFromArgs = args?['email'] as String?;

      if (mounted) {
        setState(() {
          _email = emailFromArgs ??
              authState?.user?.email ??
              (authState?.requiresEmailVerification == true
                  ? authState?.user?.email
                  : null);
        });
      }

      debugPrint('VerifyEmailScreen: Final email state: $_email');

      // Check if we need to redirect to login
      if (authState?.requiresEmailVerification != true &&
          authState?.user == null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            ref.read(authNavigationProvider.notifier).navigateToLogin(null);
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

  Future<void> _verifyEmail(AsyncValue authAsync) async {
    if (_formKey.currentState?.validate() ?? false) {
      final code = _codeController.text.trim();
      // Store the current auth state before verification
      final preservedUser = authAsync.value?.user;

      debugPrint('VerifyEmailScreen: Starting verification');
      debugPrint('VerifyEmailScreen: Current auth async state: $authAsync');
      debugPrint('VerifyEmailScreen: Preserved user: $preservedUser');
      debugPrint('VerifyEmailScreen: Local email state: $_email');
      debugPrint('VerifyEmailScreen: Verification code: $code');

      if (_email == null) {
        debugPrint('VerifyEmailScreen: No email available in local state');
        // Try to get email from preserved user first
        _email = preservedUser?.email ?? authAsync.value?.user?.email;
        if (_email == null) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('No email found for verification'),
                backgroundColor: Colors.red,
              ),
            );
          }
          return;
        }
        debugPrint('VerifyEmailScreen: Retrieved email: $_email');
      }

      debugPrint(
          'VerifyEmailScreen: Proceeding with verification - Email: $_email, Code: $code');
      await ref.read(authNotifierProvider.notifier).verifyEmail(code, _email!);
      debugPrint('VerifyEmailScreen: Verification completed successfully');
    }
  }

  Future<void> _resendCode() async {
    await ref.read(authNotifierProvider.notifier).resendVerificationEmail();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Verification code sent'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authAsync = ref.watch(authNotifierProvider);

    return authAsync.when(
      loading: () => Scaffold(
        appBar: AppBar(
          title: const Text('Verify Email'),
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      ),
      error: (error, stack) => Scaffold(
        appBar: AppBar(
          title: const Text('Verify Email'),
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
              Text(
                'Verification Error',
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
                onPressed: () => ref.invalidate(authNotifierProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
      data: (authState) =>
          _buildVerificationForm(context, authAsync, authState),
    );
  }

  Widget _buildVerificationForm(
      BuildContext context, AsyncValue authAsync, authState) {
    final isLoading = authAsync.isLoading;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Verify Email'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              ref.read(authNotifierProvider.notifier).signOut();
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
              'We sent a verification code to ${_email ?? authState.user?.email}',
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
                    enabled: !isLoading,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: isLoading ? null : () => _verifyEmail(authAsync),
                    child: isLoading
                        ? const CircularProgressIndicator()
                        : const Text('Verify Email'),
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: isLoading ? null : _resendCode,
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
