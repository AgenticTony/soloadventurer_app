import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/verification_providers.dart';
import '../../../../features/social/domain/enums/verification_tier.dart';

/// Welcome screen explaining verification and its benefits
class VerificationWelcomeScreen extends ConsumerWidget {
  /// Route name for navigation
  static const routeName = '/verification';

  /// Creates a new [VerificationWelcomeScreen]
  const VerificationWelcomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(verificationFlowProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Get Verified'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero illustration
            Center(
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      theme.colorScheme.primary,
                      theme.colorScheme.tertiary,
                    ],
                  ),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.verified_user,
                  size: 60,
                  color: theme.colorScheme.onPrimary,
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Title
            Text(
              'Build Trust,\nTravel Safe',
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                height: 1.2,
              ),
            ),
            const SizedBox(height: 16),

            // Subtitle
            Text(
              'Verified travelers get more connections and better matches. '
              'Stand out as someone the community can trust.',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),

            // Benefits list
            _buildBenefitTile(
              context,
              icon: Icons.people,
              title: '3x more connections',
              subtitle: 'Verified users get significantly more match requests',
            ),
            const SizedBox(height: 12),
            _buildBenefitTile(
              context,
              icon: Icons.workspace_premium,
              title: 'Stand out in results',
              subtitle: 'A verification badge shows you\'re genuine',
            ),
            const SizedBox(height: 12),
            _buildBenefitTile(
              context,
              icon: Icons.lock,
              title: 'Access premium features',
              subtitle: 'Some features require verification for safety',
            ),
            const SizedBox(height: 32),

            // Verification steps
            Text(
              'Two simple steps:',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // Step 1 - Photo
            _buildStepCard(
              context,
              stepNumber: 1,
              title: 'Photo Verification',
              subtitle: 'Take a selfie to prove you\'re real',
              isComplete: state.currentTier == VerificationTier.emailVerified ||
                  state.currentTier == VerificationTier.idVerified,
              onTap: () => context.push('/verification/photo'),
            ),
            const SizedBox(height: 12),

            // Step 2 - ID
            _buildStepCard(
              context,
              stepNumber: 2,
              title: 'ID Verification',
              subtitle: 'Upload a government ID for maximum trust',
              isComplete: state.currentTier == VerificationTier.idVerified,
              isLocked: state.currentTier == VerificationTier.unverified,
              onTap: state.currentTier != VerificationTier.unverified
                  ? () => context.push('/verification/id')
                  : null,
            ),
            const SizedBox(height: 32),

            // Current status
            if (state.currentTier != VerificationTier.unverified)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.green.shade700),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        state.currentTier == VerificationTier.idVerified
                            ? 'You\'re fully verified! You have the highest trust level.'
                            : 'Photo verified! Complete ID verification for the maximum trust level.',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.green.shade700,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildBenefitTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 20, color: theme.colorScheme.primary),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStepCard(
    BuildContext context, {
    required int stepNumber,
    required String title,
    required String subtitle,
    required bool isComplete,
    bool isLocked = false,
    VoidCallback? onTap,
  }) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(
            color: isComplete
                ? Colors.green.withValues(alpha: 0.5)
                : isLocked
                    ? theme.colorScheme.outline.withValues(alpha: 0.3)
                    : theme.colorScheme.primary.withValues(alpha: 0.5),
          ),
          borderRadius: BorderRadius.circular(12),
          color: isComplete
              ? Colors.green.withValues(alpha: 0.05)
              : isLocked
                  ? theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3)
                  : null,
        ),
        child: Row(
          children: [
            // Step number or completion indicator
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isComplete
                    ? Colors.green
                    : isLocked
                        ? theme.colorScheme.surfaceContainerHighest
                        : theme.colorScheme.primary,
              ),
              child: Center(
                child: isComplete
                    ? const Icon(Icons.check, color: Colors.white, size: 20)
                    : Text(
                        '$stepNumber',
                        style: TextStyle(
                          color: isLocked
                              ? theme.colorScheme.onSurfaceVariant
                              : theme.colorScheme.onPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isLocked
                          ? theme.colorScheme.onSurfaceVariant
                          : null,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            if (isLocked)
              Icon(Icons.lock_outline, size: 20, color: theme.colorScheme.onSurfaceVariant)
            else if (!isComplete)
              Icon(Icons.chevron_right, color: theme.colorScheme.primary),
          ],
        ),
      ),
    );
  }
}
