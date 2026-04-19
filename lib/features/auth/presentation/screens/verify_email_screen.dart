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
      final authAsync = ref.read(authProvider);
      final authState = authAsync.value;

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

      if (_email == null) {
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
      }

      await ref.read(authProvider.notifier).verifyEmail(code, _email!);
    }
  }

  Future<void> _resendCode() async {
    await ref.read(authProvider.notifier).resendVerificationEmail();
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
    final authAsync = ref.watch(authProvider);

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
                onPressed: () => ref.invalidate(authProvider),
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
