import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soloadventurer/features/auth/presentation/providers/auth_notifier_provider.dart';

class AuthTestScreen extends ConsumerWidget {
  const AuthTestScreen({super.key});

  Future<void> _signIn(WidgetRef ref) async {
    try {
      await ref.read(authNotifierProvider.notifier).signIn(
            'test@example.com', // Replace with your test email
            'Test123!', // Replace with your test password
          );
    } catch (e) {
      debugPrint('Sign in failed: ${e.toString()}');
    }
  }

  Future<void> _signOut(WidgetRef ref) async {
    try {
      await ref.read(authNotifierProvider.notifier).signOut();
    } catch (e) {
      debugPrint('Sign out failed: ${e.toString()}');
    }
  }

  Future<void> _register(WidgetRef ref) async {
    try {
      await ref.read(authNotifierProvider.notifier).signUp(
            email: 'test@example.com', // Replace with your test email
            password: 'Test123!', // Replace with your test password
            name: 'Test User', // Replace with your test name
          );
    } catch (e) {
      debugPrint('Registration failed: ${e.toString()}');
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authAsync = ref.watch(authNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Auth Test'),
      ),
      body: authAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, stack) => Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Error: $error',
                style: const TextStyle(color: Colors.red, fontSize: 16),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => ref.invalidate(authNotifierProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (authState) => Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Auth State: ${authState.toString()}',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => _register(ref),
                child: const Text('Register New User'),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () => _signIn(ref),
                child: const Text('Sign In'),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () => _signOut(ref),
                child: const Text('Sign Out'),
              ),
              const SizedBox(height: 20),
              Text(
                'Current user: ${authState.user?.email ?? 'No user'}',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              Text(
                'Is authenticated: ${authState.isAuthenticated}',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              Text(
                'Requires email verification: ${authState.requiresEmailVerification}',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              Text(
                'Requires password reset: ${authState.requiresPasswordReset}',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              Text(
                'Requires MFA: ${authState.requiresMFA}',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
