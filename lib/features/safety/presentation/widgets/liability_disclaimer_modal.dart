import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Reusable liability disclaimer modal.
///
/// Must appear on first use of SOS screen and Share My Meetup screen.
/// Stores acknowledgment in SharedPreferences so it only shows once per feature.
///
/// **IMPORTANT:** The wording below requires ZClaw legal sign-off before ship.
/// The current text is a placeholder pending legal review.
class LiabilityDisclaimerModal extends StatefulWidget {
  /// Which feature is triggering the disclaimer
  final LiabilityFeature feature;

  /// Callback when user acknowledges
  final VoidCallback onAcknowledged;

  /// Creates a new [LiabilityDisclaimerModal]
  const LiabilityDisclaimerModal({
    super.key,
    required this.feature,
    required this.onAcknowledged,
  });

  @override
  State<LiabilityDisclaimerModal> createState() =>
      _LiabilityDisclaimerModalState();

  /// Check if the disclaimer has already been acknowledged for a feature.
  static Future<bool> isAcknowledged(LiabilityFeature feature) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('liability_acknowledged_${feature.name}') ?? false;
  }

  /// Show the disclaimer modal if it hasn't been acknowledged yet.
  ///
  /// Returns true if the disclaimer was already acknowledged or was
  /// acknowledged in this interaction. Returns false if the user cancelled.
  static Future<bool> showIfNeeded(
    BuildContext context, {
    required LiabilityFeature feature,
    required VoidCallback onAcknowledged,
  }) async {
    final alreadyAcknowledged = await isAcknowledged(feature);
    if (alreadyAcknowledged) {
      onAcknowledged();
      return true;
    }

    if (!context.mounted) return false;

    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => LiabilityDisclaimerModal(
        feature: feature,
        onAcknowledged: () {
          Navigator.pop(ctx, true);
        },
      ),
    );

    if (result == true) {
      onAcknowledged();
      return true;
    }
    return false;
  }
}

class _LiabilityDisclaimerModalState extends State<LiabilityDisclaimerModal> {
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
    if (!_hasScrolledToBottom && _scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 50) {
      setState(() => _hasScrolledToBottom = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: theme.colorScheme.errorContainer.withValues(alpha: 0.3),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.gavel,
                    color: theme.colorScheme.error, size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Important Disclaimer',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Scrollable content
          SizedBox(
            height: 320,
            child: SingleChildScrollView(
              controller: _scrollController,
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _featureTitle(),
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _section(
                    theme,
                    title: 'Communication Aid, Not Emergency Services',
                    body: 'This feature is a communication aid designed to help '
                        'you share information with your trusted contacts. It is '
                        'NOT a substitute for calling emergency services directly. '
                        'In a life-threatening emergency, always call your local '
                        'emergency number (e.g., 911, 112, 999) first.',
                  ),
                  const SizedBox(height: 14),
                  _section(
                    theme,
                    title: 'No Guarantee of Delivery',
                    body: 'SoloAdventurer cannot guarantee that messages, alerts, '
                        'or location shares will be delivered to your contacts. '
                        'Network connectivity, device settings, and other factors '
                        'beyond our control may prevent delivery.',
                  ),
                  const SizedBox(height: 14),
                  _section(
                    theme,
                    title: 'Not Professional Safety Advice',
                    body: 'SoloAdventurer does not provide professional safety '
                        'or security advice. Always exercise personal judgment '
                        'and follow local safety guidelines when traveling.',
                  ),
                  const SizedBox(height: 14),
                  _section(
                    theme,
                    title: 'Limitation of Liability',
                    body: 'To the fullest extent permitted by law, SoloAdventurer '
                        'and its affiliates shall not be liable for any damages '
                        'arising from the use or inability to use safety features, '
                        'including but not limited to delayed alerts, undelivered '
                        'messages, or inaccurate location data.',
                  ),
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest
                          .withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.info_outline,
                            size: 16, color: theme.colorScheme.onSurfaceVariant),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'By proceeding, you acknowledge that you have read '
                            'and understood this disclaimer.',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Action buttons
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ElevatedButton(
                  onPressed: _hasScrolledToBottom ? _acknowledge : null,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    _hasScrolledToBottom
                        ? 'I Understand & Acknowledge'
                        : 'Scroll to read full disclaimer',
                  ),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _section(ThemeData theme,
      {required String title, required String body}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          body,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  String _featureTitle() {
    return switch (widget.feature) {
      LiabilityFeature.sos =>
          'Emergency SOS Disclaimer',
      LiabilityFeature.shareMeetup =>
          'Share My Meetup Disclaimer',
    };
  }

  Future<void> _acknowledge() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(
      'liability_acknowledged_${widget.feature.name}',
      true,
    );
    await prefs.setString(
      'liability_acknowledged_${widget.feature.name}_at',
      DateTime.now().toIso8601String(),
    );

    if (mounted) {
      Navigator.pop(context);
      widget.onAcknowledged();
    }
  }
}

/// Features that require liability disclaimer acknowledgment
enum LiabilityFeature {
  /// Emergency SOS feature
  sos,

  /// Share My Meetup feature
  shareMeetup,
}
