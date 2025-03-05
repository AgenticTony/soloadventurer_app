import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soloadventurer/core/config/cognito_config.dart';
import 'package:soloadventurer/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:amazon_cognito_identity_dart_2/cognito.dart';

class AuthTestScreen extends ConsumerStatefulWidget {
  const AuthTestScreen({super.key});

  @override
  ConsumerState<AuthTestScreen> createState() => _AuthTestScreenState();
}

class _AuthTestScreenState extends ConsumerState<AuthTestScreen> {
  String _status = 'Not authenticated';
  final AuthRemoteDataSourceImpl _authDataSource = AuthRemoteDataSourceImpl();

  Future<void> _signIn() async {
    try {
      setState(() => _status = 'Signing in...');

      final (user, token) = await _authDataSource.signIn(
        'test@example.com', // Replace with your test email
        'Test123!', // Replace with your test password
      );

      setState(() => _status = 'Signed in as ${user.email}');
    } catch (e) {
      setState(() => _status = 'Sign in failed: ${e.toString()}');
    }
  }

  Future<void> _getCurrentUser() async {
    try {
      setState(() => _status = 'Getting current user...');

      final user = await _authDataSource.getCurrentUser();
      if (user != null) {
        setState(() => _status = 'Current user: ${user.email}');
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

      await _authDataSource.signOut();

      setState(() => _status = 'Signed out');
    } catch (e) {
      setState(() => _status = 'Sign out failed: ${e.toString()}');
    }
  }

  Future<void> _register() async {
    try {
      setState(() => _status = 'Registering...');

      final (user, token) = await _authDataSource.register(
        'test@example.com', // Replace with your test email
        'Test123!', // Replace with your test password
        'Test User', // Replace with your test name
      );

      setState(() => _status = 'Registered as ${user.email}');
    } catch (e) {
      setState(() => _status = 'Registration failed: ${e.toString()}');
    }
  }

  @override
  Widget build(BuildContext context) {
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
          ],
        ),
      ),
    );
  }
}
