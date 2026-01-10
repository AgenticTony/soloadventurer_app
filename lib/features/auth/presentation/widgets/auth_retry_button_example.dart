import 'package:flutter/material.dart';

/// Example usage of AuthRetryButton widget
///
/// This file demonstrates how to use the AuthRetryButton in different scenarios
class AuthRetryButtonExample extends StatelessWidget {
  const AuthRetryButtonExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Auth Retry Button Examples')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          // Example 1: Basic usage
          Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text('Example 1: Basic Retry Button',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  SizedBox(height: 8),
                  Text('Simple retry button with all features enabled'),
                  SizedBox(height: 16),
                  // In real usage, you would have:
                  // AuthRetryButton(
                  //   onRetry: () {
                  //     // Perform retry logic
                  //   },
                  //   onCancel: () {
                  //     // Handle cancellation
                  //   },
                  // ),
                ],
              ),
            ),
          ),

          SizedBox(height: 16),

          // Example 2: Minimal configuration
          Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text('Example 2: Minimal Configuration',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  SizedBox(height: 8),
                  Text(
                      'Only shows the button, no countdown or attempt counter'),
                  SizedBox(height: 16),
                  // In real usage:
                  // AuthRetryButton(
                  //   config: AuthRetryButtonConfig.minimal(),
                  //   onRetry: () {},
                  // ),
                ],
              ),
            ),
          ),

          SizedBox(height: 16),

          // Example 3: Custom max attempts and delay
          Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text('Example 3: Custom Configuration',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  SizedBox(height: 8),
                  Text('5 max attempts with 5-second base delay'),
                  SizedBox(height: 16),
                  // In real usage:
                  // AuthRetryButton(
                  //   config: AuthRetryButtonConfig(
                  //     maxAttempts: 5,
                  //     baseDelaySeconds: 5,
                  //     maxDelaySeconds: 60,
                  //   ),
                  //   onRetry: () {},
                  // ),
                ],
              ),
            ),
          ),

          SizedBox(height: 16),

          // Example 4: Integration with TokenRefreshService
          Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text('Example 4: Automatic Mode',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  SizedBox(height: 8),
                  Text('Connects directly to TokenRefreshService'),
                  SizedBox(height: 16),
                  // In real usage:
                  // AuthRetryButtonAutomatic(
                  //   refreshService: tokenRefreshService,
                  //   onManualRetry: () {
                  //     // Optional manual retry trigger
                  //   },
                  //   onCancel: () {
                  //     // Handle cancellation
                  //   },
                  // ),
                ],
              ),
            ),
          ),

          SizedBox(height: 16),

          // Example 5: With custom labels
          Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text('Example 5: Custom Labels',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  SizedBox(height: 8),
                  Text('Custom button text and labels'),
                  SizedBox(height: 16),
                  // In real usage:
                  // AuthRetryButton(
                  //   buttonText: 'Try Again',
                  //   cancelButtonText: 'Give Up',
                  //   onRetry: () {},
                  //   onCancel: () {},
                  // ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Example integration in a real screen
class LoginScreenExample extends StatelessWidget {
  const LoginScreenExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const TextField(
              decoration: InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            const TextField(
              decoration: InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                // Handle login
              },
              child: const Text('Login'),
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),
            const Text('Or retry login if it failed:'),
            const SizedBox(height: 16),
            // Retry button shown after login failure
            // AuthRetryButton(
            //   config: AuthRetryButtonConfig(
            //     maxAttempts: 3,
            //     showCountdown: true,
            //     showAttemptCounter: true,
            //     showCancelButton: true,
            //   ),
            //   onRetry: () async {
            //     // Retry login logic
            //     try {
            //       await authRepository.signInWithEmailAndPassword(
            //         email,
            //         password,
            //       );
            //     } catch (e) {
            //       // Error will be handled, button will update
            //     }
            //   },
            //   onCancel: () {
            //     // Navigate back or show other options
            //     Navigator.of(context).pop();
            //   },
            // ),
          ],
        ),
      ),
    );
  }
}

/// Features of AuthRetryButton:
///
/// 1. **Countdown Timer**: Shows remaining time before next retry is allowed
///    - Displays "Next retry in X seconds"
///    - Updates every second
///    - Based on exponential backoff calculation
///
/// 2. **Attempt Counter**: Shows current retry attempt
///    - Displays "Attempt X of Y"
///    - Helps user understand progress
///    - Stops after max attempts reached
///
/// 3. **Automatic Disabling**: Button is disabled during:
///    - Active retry operation
///    - Countdown period
///    - After max attempts reached
///
/// 4. **Cancel Option**: Allows user to:
///    - Cancel in-progress retries
///    - Reset the retry state
///    - Navigate away or choose alternative action
///
/// 5. **Exponential Backoff**: Automatically calculates delays:
///    - Attempt 1-2: 1 second
///    - Attempt 2-3: 2 seconds
///    - Attempt 3-4: 4 seconds
///    - Attempt 4-5: 8 seconds
///    - Up to maxDelaySeconds (default 32)
///
/// 6. **Configurable**:
///    - Control which UI elements are shown
///    - Adjust max attempts
///    - Customize delay times
///    - Custom button labels
///
/// 7. **Two Modes**:
///    - Manual: You control when retries happen
///    - Automatic: Integrates with TokenRefreshService
