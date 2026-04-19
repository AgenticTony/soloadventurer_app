import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/verification_providers.dart';

/// Screen showing the result of a verification attempt
class VerificationResultScreen extends ConsumerWidget {
  /// Route name for navigation
  static const routeName = '/verification/result';

  /// Creates a new [VerificationResultScreen]
  const VerificationResultScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(verificationFlowProvider);
    final theme = Theme.of(context);

    // Get the extra data from route
    final extra = GoRouterState.of(context).extra as Map<String, dynamic>?;
    final isSuccess = extra?['success'] as bool? ?? true;
    final type = extra?['type'] as String? ?? 'photo';

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Result icon
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSuccess
                        ? Colors.green.withValues(alpha: 0.1)
                        : theme.colorScheme.errorContainer,
                  ),
                  child: Icon(
                    isSuccess ? Icons.verified_user : Icons.error_outline,
                    size: 64,
                    color: isSuccess ? Colors.green : theme.colorScheme.error,
                  ),
                ),
                const SizedBox(height: 32),

                // Title
                Text(
                  isSuccess
                      ? '${type == 'photo' ? 'Photo' : 'ID'} Verified!'
                      : 'Verification Failed',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isSuccess ? Colors.green : theme.colorScheme.error,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),

                // Description
                Text(
                  isSuccess
                      ? type == 'photo'
                          ? 'Your identity has been confirmed. '
                              'You now have a photo verification badge that '
                              'other travelers can see.'
                          : 'Your government ID has been verified. '
                              'You now have the highest trust level on SoloAdventurer.'
                      : state.error ??
                          'We couldn\'t verify your identity. '
                              'Please try again with a clearer photo.',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),

                if (isSuccess) ...[
                  // Badge preview
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: Colors.green.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          type == 'photo'
                              ? Icons.verified
                              : Icons.shield,
                          color: Colors.green,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          type == 'photo'
                              ? 'Photo Verified'
                              : 'ID Verified',
                          style: theme.textTheme.titleSmall?.copyWith(
                            color: Colors.green,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Next steps
                  if (type == 'photo')
                    OutlinedButton.icon(
                      onPressed: () => context.go('/verification/id'),
                      icon: const Icon(Icons.badge),
                      label: const Text('Complete ID Verification'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 16,
                        ),
                      ),
                    ),
                ] else ...[
                  // Retry button
                  ElevatedButton.icon(
                    onPressed: () => context.go(
                      type == 'photo'
                          ? '/verification/photo'
                          : '/verification/id',
                    ),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Try Again'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 16,
                      ),
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: theme.colorScheme.onPrimary,
                    ),
                  ),
                ],
                const SizedBox(height: 16),

                // Done button
                TextButton(
                  onPressed: () => context.go('/profile'),
                  child: const Text('Back to Profile'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
