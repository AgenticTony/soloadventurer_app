import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Screen for obtaining informed consent before biometric data processing.
///
/// This screen explains that facial geometry data is biometric special category
/// data under GDPR Article 9, what it's used for, how long it's retained,
/// and the user's right to delete it. It appears before any camera/photo
/// capture in the verification flow.
///
/// ZClaw sign-off required on all copy before shipping.
class VerificationConsentScreen extends ConsumerStatefulWidget {
  /// Route name for navigation
  static const routeName = '/verification/consent';

  /// The type of verification being consented to
  final String verificationType;

  /// Creates a new [VerificationConsentScreen]
  const VerificationConsentScreen({
    super.key,
    this.verificationType = 'photo',
  });

  @override
  ConsumerState<VerificationConsentScreen> createState() =>
      _VerificationConsentScreenState();
}

class _VerificationConsentScreenState
    extends ConsumerState<VerificationConsentScreen> {
  bool _hasScrolledToBottom = false;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_checkScrollPosition);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_checkScrollPosition);
    _scrollController.dispose();
    super.dispose();
  }

  void _checkScrollPosition() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 50) {
      if (!_hasScrolledToBottom) {
        setState(() => _hasScrolledToBottom = true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isPhoto = widget.verificationType == 'photo';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Privacy Matters'),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              controller: _scrollController,
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.policy, color: theme.colorScheme.primary, size: 28),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Before we begin, please read this carefully',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Section 1: What we collect
                  _buildSection(
                    context,
                    icon: Icons.fingerprint,
                    title: 'What data we collect',
                    content: isPhoto
                        ? 'We process your facial geometry from a selfie photo. '
                            'Facial geometry is classified as biometric special '
                            'category data under GDPR Article 9.'
                        : 'We process images of your government-issued photo ID '
                            'document (passport, driver\'s license, or national ID). '
                            'This may include your full name, date of birth, '
                            'photograph, and document number.',
                  ),
                  const SizedBox(height: 20),

                  // Section 2: Purpose
                  _buildSection(
                    context,
                    icon: Icons.verified_user,
                    title: 'Why we need it',
                    content: isPhoto
                        ? 'To verify that you are a real person and that your '
                            'profile photos accurately represent you. This helps '
                            'build trust in the SoloAdventurer community and '
                            'protects other travelers from fake accounts.'
                        : 'To confirm your identity by matching your government ID '
                            'to your selfie photo. This provides the highest level '
                            'of trust verification for the SoloAdventurer community.',
                  ),
                  const SizedBox(height: 20),

                  // Section 3: Retention
                  _buildSection(
                    context,
                    icon: Icons.timer,
                    title: 'How long we keep it',
                    content: isPhoto
                        ? 'Your selfie photo is encrypted and stored for up to '
                            '90 days while verification is processed. After '
                            'verification is complete, the raw image is deleted. '
                            'Only a verification status (verified/not verified) '
                            'is retained on your account.'
                        : 'Your ID document images are encrypted and stored for up '
                            'to 30 days while verification is processed. After '
                            'verification is complete, the raw images are deleted. '
                            'Only a verification status (ID verified/not verified) '
                            'is retained on your account.',
                  ),
                  const SizedBox(height: 20),

                  // Section 4: Your rights
                  _buildSection(
                    context,
                    icon: Icons.gavel,
                    title: 'Your rights',
                    content: 'You have the right to:\n'
                        '• Request deletion of your verification data at any time\n'
                        '• Withdraw your consent, which will remove your verified status\n'
                        '• Request a copy of all data we hold about you\n'
                        '• Lodge a complaint with your local data protection authority\n\n'
                        'To exercise any of these rights, go to Profile > Settings > '
                        'Account > Delete Account, or contact us at privacy@soloadventurer.com.',
                  ),
                  const SizedBox(height: 20),

                  // Section 5: Third parties
                  _buildSection(
                    context,
                    icon: Icons.share,
                    title: 'Who else sees it',
                    content: 'Your biometric data is processed securely and is never '
                        'shared with other users. We use encrypted, GDPR-compliant '
                        'cloud storage (Supabase, hosted in the EU). Your verification '
                        'status (a simple yes/no badge) is visible to other users, '
                        'but your actual photos and ID documents are never shared.',
                  ),
                  const SizedBox(height: 20),

                  // Legal basis
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.balance, size: 20, color: theme.colorScheme.primary),
                            const SizedBox(width: 8),
                            Text(
                              'Legal basis',
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Processing is based on your explicit consent under '
                          'GDPR Article 6(1)(a) and Article 9(2)(a) for special '
                          'category data. You may withdraw consent at any time.',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),

          // Bottom action area
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              border: Border(
                top: BorderSide(
                  color: theme.colorScheme.outline.withValues(alpha: 0.2),
                ),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (!_hasScrolledToBottom)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Text(
                      'Please scroll down to read all information',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => context.pop(),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text('Decline'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                        onPressed: _hasScrolledToBottom ? _accept : null,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: theme.colorScheme.primary,
                          foregroundColor: theme.colorScheme.onPrimary,
                        ),
                        child: const Text('I Understand & Consent'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String content,
  }) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 20, color: theme.colorScheme.primary),
            const SizedBox(width: 8),
            Text(
              title,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          content,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Future<void> _accept() async {
    // Store consent acknowledgment
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(
      'verification_consent_${widget.verificationType}',
      true,
    );
    await prefs.setString(
      'verification_consent_date_${widget.verificationType}',
      DateTime.now().toIso8601String(),
    );

    if (mounted) {
      // Navigate to the appropriate verification screen
      if (widget.verificationType == 'photo') {
        context.go('/verification/photo');
      } else {
        context.go('/verification/id');
      }
    }
  }
}
