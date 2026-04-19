import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:soloadventurer/l10n/app_localizations.dart';
import '../providers/subscription_providers.dart';
import '../../domain/enums/subscription_tier.dart';

/// Paywall screen with safety-led redesign.
///
/// Hero section leads with ID Verification (the trust product),
/// not feature bullets. Free tier feels complete. Pro is an upgrade.
/// Uses travel-appropriate language throughout.
class PaywallScreen extends ConsumerStatefulWidget {
  /// Route name for navigation
  static const routeName = '/paywall';

  /// Creates a new [PaywallScreen]
  const PaywallScreen({super.key});

  @override
  ConsumerState<PaywallScreen> createState() => _PaywallScreenState();
}

class _PaywallScreenState extends ConsumerState<PaywallScreen>
    with TickerProviderStateMixin {
  late final AnimationController _fadeController;
  late final AnimationController _slideController;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final state = ref.watch(subscriptionProvider);
    final isDark = theme.brightness == Brightness.dark;

    final gold = const Color(0xFFD4A74A);
    final teal = const Color(0xFF2D8B7A);
    final parchment = isDark ? const Color(0xFF1A1612) : const Color(0xFFFAF5EE);
    final ink = isDark ? const Color(0xFFE8DDD0) : const Color(0xFF2C1810);

    ref.listen<SubscriptionState>(subscriptionProvider, (prev, next) {
      if (next.error != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.error!),
            backgroundColor: theme.colorScheme.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
        ref.read(subscriptionProvider.notifier).clearError();
      }
    });

    return Scaffold(
      backgroundColor: parchment,
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
                // Close button
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton(
                        onPressed: () => context.pop(),
                        icon: Icon(Icons.close, color: ink.withValues(alpha: 0.6)),
                        style: IconButton.styleFrom(
                          backgroundColor: ink.withValues(alpha: 0.06),
                        ),
                        tooltip: AppLocalizations.of(context)!.subClose,
                      ),
                    ],
                  ),
                ),

                // Scrollable content
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 120),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // ── HERO SECTION ──
                        _HeroSection(
                          fadeAnimation: _fadeController,
                          gold: gold,
                          teal: teal,
                          ink: ink,
                          isDark: isDark,
                        ),
                        const SizedBox(height: 32),

                        // ── FEATURE COMPARISON ──
                        _FeatureComparison(
                          slideAnimation: _slideController,
                          gold: gold,
                          teal: teal,
                          ink: ink,
                          isDark: isDark,
                        ),
                        const SizedBox(height: 32),

                        // ── PRICING TOGGLE ──
                        _PricingToggle(
                          slideAnimation: _slideController,
                          gold: gold,
                          ink: ink,
                          isDark: isDark,
                        ),
                        const SizedBox(height: 24),

                        // ── COMING SOON TIERS ──
                        _ComingSoonTiers(
                          slideAnimation: _slideController,
                          ink: ink,
                          gold: gold,
                          isDark: isDark,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Bottom CTA
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _BottomCTA(
              state: state,
              ink: ink,
              gold: gold,
              isDark: isDark,
              onStartTrial: _handleStartTrial,
              onPurchase: _handlePurchase,
              onContinueFree: () => context.pop(),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleStartTrial() async {
    await ref.read(subscriptionProvider.notifier).startFreeTrial();
    if (mounted) {
      context.pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.subWelcomeTrial),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _handlePurchase() async {
    await ref
        .read(subscriptionProvider.notifier)
        .purchaseTier(SubscriptionTier.explorer);
    if (mounted) {
      context.pop();
    }
  }
}

// ── HERO SECTION ────────────────────────────────────────────────────────

class _HeroSection extends StatelessWidget {
  final Animation<double> fadeAnimation;
  final Color gold;
  final Color teal;
  final Color ink;
  final bool isDark;

  const _HeroSection({
    required this.fadeAnimation,
    required this.gold,
    required this.teal,
    required this.ink,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return FadeTransition(
      opacity: fadeAnimation,
      child: Semantics(
        header: true,
        child: Column(
          children: [
            // ID Verified badge mockup
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [gold, teal],
                ),
                boxShadow: [
                  BoxShadow(
                    color: gold.withValues(alpha: 0.3),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: const Icon(
                Icons.shield_outlined,
                color: Colors.white,
                size: 36,
              ),
            ),
            const SizedBox(height: 20),

            // Headline
            Text(
              AppLocalizations.of(context)!.subHeroHeadline,
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w800,
                color: ink,
                letterSpacing: -0.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),

            // Subheadline
            Text(
              AppLocalizations.of(context)!.subHeroSubheadline,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: ink.withValues(alpha: 0.65),
                height: 1.6,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),

            // Testimonial placeholder
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: ink.withValues(alpha: isDark ? 0.06 : 0.04),
                border: Border.all(
                  color: ink.withValues(alpha: 0.08),
                ),
              ),
              child: Column(
                children: [
                  Text(
                    AppLocalizations.of(context)!.subTestimonial,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: ink.withValues(alpha: 0.7),
                      fontStyle: FontStyle.italic,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    AppLocalizations.of(context)!.subTestimonialAttribution,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: ink.withValues(alpha: 0.4),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Guardian preview
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: teal.withValues(alpha: 0.1),
                border: Border.all(color: teal.withValues(alpha: 0.2)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.security_outlined, size: 16, color: teal),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      AppLocalizations.of(context)!.subGuardianPreview,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: teal,
                        fontWeight: FontWeight.w600,
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
}

// ── FEATURE COMPARISON ───────────────────────────────────────────────────

class _FeatureComparison extends StatelessWidget {
  final Animation<double> slideAnimation;
  final Color gold;
  final Color teal;
  final Color ink;
  final bool isDark;

  const _FeatureComparison({
    required this.slideAnimation,
    required this.gold,
    required this.teal,
    required this.ink,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0, 0.1),
        end: Offset.zero,
      ).animate(slideAnimation),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context)!.subWhatYouGet,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
              color: ink,
            ),
          ),
          const SizedBox(height: 16),

          // ID Verification — hero row
          _ComparisonRow(
            icon: Icons.verified_user_outlined,
            iconColor: gold,
            title: AppLocalizations.of(context)!.subFeatureIdVerification,
            description: AppLocalizations.of(context)!.subFeatureIdVerificationDesc,
            isIncluded: true,
            isHero: true,
            ink: ink,
            isDark: isDark,
          ),
          const SizedBox(height: 10),

          // Guardian Check-Ins — second hero row
          _ComparisonRow(
            icon: Icons.security_outlined,
            iconColor: teal,
            title: AppLocalizations.of(context)!.subFeatureGuardian,
            description: AppLocalizations.of(context)!.subFeatureGuardianDesc,
            isIncluded: true,
            isHero: true,
            ink: ink,
            isDark: isDark,
          ),
          const SizedBox(height: 10),

          // Regular features
          _ComparisonRow(
            icon: Icons.chat_bubble_outline,
            iconColor: ink.withValues(alpha: 0.5),
            title: AppLocalizations.of(context)!.subFeatureUnlimitedMessages,
            subtitle: AppLocalizations.of(context)!.subFeatureMessagesFree,
            isIncluded: true,
            ink: ink,
            isDark: isDark,
          ),
          const SizedBox(height: 10),

          _ComparisonRow(
            icon: Icons.people_outline,
            iconColor: ink.withValues(alpha: 0.5),
            title: AppLocalizations.of(context)!.subFeatureSeeInterested,
            isIncluded: true,
            ink: ink,
            isDark: isDark,
          ),
          const SizedBox(height: 10),

          _ComparisonRow(
            icon: Icons.filter_alt_outlined,
            iconColor: ink.withValues(alpha: 0.5),
            title: AppLocalizations.of(context)!.subFeatureVerifiedFilter,
            isIncluded: true,
            ink: ink,
            isDark: isDark,
          ),
          const SizedBox(height: 10),

          _ComparisonRow(
            icon: Icons.tune,
            iconColor: ink.withValues(alpha: 0.5),
            title: AppLocalizations.of(context)!.subFeatureAdvancedFilters,
            subtitle: AppLocalizations.of(context)!.subFeatureAdvancedFiltersSub,
            isIncluded: true,
            ink: ink,
            isDark: isDark,
          ),
          const SizedBox(height: 10),

          _ComparisonRow(
            icon: Icons.trending_up_outlined,
            iconColor: ink.withValues(alpha: 0.5),
            title: AppLocalizations.of(context)!.subFeaturePriority,
            isIncluded: true,
            ink: ink,
            isDark: isDark,
          ),
          const SizedBox(height: 10),

          _ComparisonRow(
            icon: Icons.done_all,
            iconColor: ink.withValues(alpha: 0.5),
            title: AppLocalizations.of(context)!.subFeatureReadReceipts,
            isIncluded: true,
            ink: ink,
            isDark: isDark,
          ),
        ],
      ),
    );
  }
}

class _ComparisonRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String? description;
  final String? subtitle;
  final bool isIncluded;
  final bool isHero;
  final Color ink;
  final bool isDark;

  const _ComparisonRow({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.ink,
    required this.isDark,
    this.description,
    this.subtitle,
    this.isIncluded = true,
    this.isHero = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: isHero
            ? iconColor.withValues(alpha: isDark ? 0.08 : 0.05)
            : ink.withValues(alpha: isDark ? 0.04 : 0.02),
        border: isHero
            ? Border.all(color: iconColor.withValues(alpha: 0.2))
            : Border.all(color: ink.withValues(alpha: 0.06)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: isHero ? 36 : 32,
            height: isHero ? 36 : 32,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: iconColor.withValues(alpha: 0.12),
            ),
            child: Icon(icon, size: isHero ? 18 : 16, color: iconColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: isHero ? FontWeight.w700 : FontWeight.w600,
                    color: ink,
                  ),
                ),
                if (description != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    description!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: ink.withValues(alpha: 0.55),
                      height: 1.4,
                    ),
                  ),
                ],
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle!,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: ink.withValues(alpha: 0.4),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── PRICING TOGGLE ──────────────────────────────────────────────────────

class _PricingToggle extends ConsumerWidget {
  final Animation<double> slideAnimation;
  final Color gold;
  final Color ink;
  final bool isDark;

  const _PricingToggle({
    required this.slideAnimation,
    required this.gold,
    required this.ink,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(subscriptionProvider);
    final isAnnual = state.selectedBillingCycle == BillingCycle.annual;
    final tier = SubscriptionTier.explorer;

    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0, 0.1),
        end: Offset.zero,
      ).animate(slideAnimation),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: gold.withValues(alpha: 0.3), width: 2),
          color: gold.withValues(alpha: isDark ? 0.06 : 0.04),
        ),
        child: Column(
          children: [
            // Monthly / Annual toggle
            Row(
              children: [
                Expanded(
                  child: _BillingOption(
                    label: AppLocalizations.of(context)!.subMonthly,
                    price: tier.priceLabel,
                    isSelected: !isAnnual,
                    gold: gold,
                    ink: ink,
                    isDark: isDark,
                    onTap: () => ref
                        .read(subscriptionProvider.notifier)
                        .setBillingCycle(BillingCycle.monthly),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _BillingOption(
                    label: AppLocalizations.of(context)!.subAnnual,
                    price: tier.annualPriceLabel,
                    subtitle: tier.annualEffectiveMonthly,
                    badge: tier.annualSavingsLabel,
                    isSelected: isAnnual,
                    gold: gold,
                    ink: ink,
                    isDark: isDark,
                    onTap: () => ref
                        .read(subscriptionProvider.notifier)
                        .setBillingCycle(BillingCycle.annual),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _BillingOption extends StatelessWidget {
  final String label;
  final String price;
  final String? subtitle;
  final String? badge;
  final bool isSelected;
  final Color gold;
  final Color ink;
  final bool isDark;
  final VoidCallback onTap;

  const _BillingOption({
    required this.label,
    required this.price,
    required this.isSelected,
    required this.gold,
    required this.ink,
    required this.isDark,
    required this.onTap,
    this.subtitle,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: isSelected
              ? gold.withValues(alpha: isDark ? 0.15 : 0.1)
              : Colors.transparent,
          border: Border.all(
            color: isSelected ? gold : ink.withValues(alpha: 0.12),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            if (badge != null)
              Container(
                margin: const EdgeInsets.only(bottom: 6),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: gold.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  badge!,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: gold,
                    fontWeight: FontWeight.w700,
                    fontSize: 9,
                  ),
                ),
              ),
            Text(
              label,
              style: theme.textTheme.labelMedium?.copyWith(
                color: ink.withValues(alpha: 0.6),
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              price,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
                color: isSelected ? gold : ink,
              ),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 2),
              Text(
                subtitle!,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: ink.withValues(alpha: 0.45),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ── COMING SOON TIERS ───────────────────────────────────────────────────

class _ComingSoonTiers extends StatelessWidget {
  final Animation<double> slideAnimation;
  final Color ink;
  final Color gold;
  final bool isDark;

  const _ComingSoonTiers({
    required this.slideAnimation,
    required this.ink,
    required this.gold,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0, 0.1),
        end: Offset.zero,
      ).animate(slideAnimation),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Container(height: 1, color: ink.withValues(alpha: 0.12)),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  AppLocalizations.of(context)!.subComingSoon,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: ink.withValues(alpha: 0.35),
                    fontWeight: FontWeight.w700,
                    letterSpacing: 2,
                  ),
                ),
              ),
              Expanded(
                child: Container(height: 1, color: ink.withValues(alpha: 0.12)),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Adventurer
          _ComingSoonCard(
            tier: SubscriptionTier.adventurer,
            ink: ink,
            gold: gold,
            isDark: isDark,
          ),
          const SizedBox(height: 10),

          // VIP
          _ComingSoonCard(
            tier: SubscriptionTier.vip,
            ink: ink,
            gold: gold,
            isDark: isDark,
          ),
        ],
      ),
    );
  }
}

class _ComingSoonCard extends StatefulWidget {
  final SubscriptionTier tier;
  final Color ink;
  final Color gold;
  final bool isDark;

  const _ComingSoonCard({
    required this.tier,
    required this.ink,
    required this.gold,
    required this.isDark,
  });

  @override
  State<_ComingSoonCard> createState() => _ComingSoonCardState();
}

class _ComingSoonCardState extends State<_ComingSoonCard> {
  bool _notifyRequested = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Opacity(
      opacity: 0.5,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: widget.ink.withValues(alpha: widget.isDark ? 0.04 : 0.02),
          border: Border.all(color: widget.ink.withValues(alpha: 0.08)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.tier.label,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: widget.ink,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${widget.tier.priceLabel} — ${widget.tier.description}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: widget.ink.withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            _NotifyMeButton(
              isRequested: _notifyRequested,
              gold: widget.gold,
              ink: widget.ink,
              onTap: () {
                setState(() => _notifyRequested = true);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      AppLocalizations.of(context)!.subNotifyMeConfirm(widget.tier.label),
                    ),
                    behavior: SnackBarBehavior.floating,
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _NotifyMeButton extends StatelessWidget {
  final bool isRequested;
  final Color gold;
  final Color ink;
  final VoidCallback onTap;

  const _NotifyMeButton({
    required this.isRequested,
    required this.gold,
    required this.ink,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (isRequested) {
      return Icon(Icons.check_circle, size: 20, color: gold);
    }
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        side: BorderSide(color: ink.withValues(alpha: 0.2)),
      ),
      child: Text(
        AppLocalizations.of(context)!.subNotifyMe,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: ink.withValues(alpha: 0.6),
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }
}

// ── BOTTOM CTA BAR ──────────────────────────────────────────────────────

class _BottomCTA extends ConsumerWidget {
  final SubscriptionState state;
  final Color ink;
  final Color gold;
  final bool isDark;
  final VoidCallback onStartTrial;
  final VoidCallback onPurchase;
  final VoidCallback onContinueFree;

  const _BottomCTA({
    required this.state,
    required this.ink,
    required this.gold,
    required this.isDark,
    required this.onStartTrial,
    required this.onPurchase,
    required this.onContinueFree,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isLoading = state.isInProgress;
    final canTrial = state.isEligibleForTrial;
    final isAnnual = state.selectedBillingCycle == BillingCycle.annual;
    final priceText = isAnnual ? '\$59.99/yr' : '\$9.99/mo';

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1612) : const Color(0xFFFAF5EE),
        border: Border(
          top: BorderSide(color: ink.withValues(alpha: 0.08), width: 1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: double.infinity,
            height: 54,
            child: Semantics(
              button: true,
              label: canTrial
                  ? AppLocalizations.of(context)!.subCtaStartTrial
                  : AppLocalizations.of(context)!.subCtaPurchase(priceText),
              child: ElevatedButton(
                onPressed: isLoading
                    ? null
                    : canTrial
                        ? onStartTrial
                        : onPurchase,
                style: ElevatedButton.styleFrom(
                  backgroundColor: gold,
                  foregroundColor: const Color(0xFF1A1200),
                  disabledBackgroundColor: gold.withValues(alpha: 0.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Color(0xFF1A1200),
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.verified_user_outlined, size: 18),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              canTrial
                                  ? AppLocalizations.of(context)!.subCtaStartTrial
                                  : AppLocalizations.of(context)!.subCtaPurchase(priceText),
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w800,
                                color: const Color(0xFF1A1200),
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ),
          if (canTrial)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                AppLocalizations.of(context)!.subTrialNote(priceText),
                style: theme.textTheme.labelSmall?.copyWith(
                  color: ink.withValues(alpha: 0.45),
                ),
                textAlign: TextAlign.center,
              ),
            ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: isLoading ? null : onContinueFree,
            child: Text(
              AppLocalizations.of(context)!.subContinueFree,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: ink.withValues(alpha: 0.4),
                decoration: TextDecoration.underline,
                decorationColor: ink.withValues(alpha: 0.2),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
