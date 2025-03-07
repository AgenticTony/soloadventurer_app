import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soloadventurer/features/auth/presentation/providers/auth_provider.dart';
import 'package:soloadventurer/features/auth/presentation/state/auth_state.dart';

class AuthTestScreen extends ConsumerStatefulWidget {
  const AuthTestScreen({super.key});

  @override
  ConsumerState<AuthTestScreen> createState() => _AuthTestScreenState();
}

class _AuthTestScreenState extends ConsumerState<AuthTestScreen> {
  String _status = 'Not authenticated';

  Future<void> _signIn() async {
    try {
      setState(() => _status = 'Signing in...');
      await ref.read(authProvider.notifier).signIn(
            'test@example.com', // Replace with your test email
            'Test123!', // Replace with your test password
          );
      setState(() => _status = 'Signed in successfully');
    } catch (e) {
      setState(() => _status = 'Sign in failed: ${e.toString()}');
    }
  }

  Future<void> _getCurrentUser() async {
    try {
      setState(() => _status = 'Getting current user...');
      final state = ref.read(authProvider);
      if (state.user != null) {
        setState(() => _status = 'Current user: ${state.user!.email}');
      } else {
        setState(() => _status = 'No authenticated user');
      }
    } catch (e) {
      setState(() => _status = 'Get user failed: ${e.toString()}');
    }
  }

  Future<void> _signOut() async {
    try {
      setState(() => _status = 'Signing out...');
      await ref.read(authProvider.notifier).signOut();
      setState(() => _status = 'Signed out');
    } catch (e) {
      setState(() => _status = 'Sign out failed: ${e.toString()}');
    }
  }

  Future<void> _register() async {
    try {
      setState(() => _status = 'Registering...');
      await ref.read(authProvider.notifier).signUp(
            email: 'test@example.com', // Replace with your test email
            password: 'Test123!', // Replace with your test password
            name: 'Test User', // Replace with your test name
          );
      setState(() => _status = 'Registered successfully');
    } catch (e) {
      setState(() => _status = 'Registration failed: ${e.toString()}');
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Auth Test'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Status: $_status',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Auth State: ${authState.toString()}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _register,
              child: const Text('Register New User'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _signIn,
              child: const Text('Sign In'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _getCurrentUser,
              child: const Text('Get Current User'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _signOut,
              child: const Text('Sign Out'),
            ),
            const SizedBox(height: 20),
            Text(
              'Current user: ${authState.value?.user?.email ?? 'No user'}',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            Text(
              'Is authenticated: ${authState.value?.user != null}',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
        ),
      ),
    );
  }
}
