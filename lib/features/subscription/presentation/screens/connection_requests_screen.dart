import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:soloadventurer/l10n/app_localizations.dart';
import '../providers/subscription_providers.dart';

/// Screen showing travelers who want to connect with the current user.
///
/// Free users see blurred profile cards with an upgrade CTA.
/// Explorer+ users see clear photos and can connect directly.
///
/// Uses travel-appropriate language: "travelers interested in connecting"
/// instead of dating-app language like "likes."
class ConnectionRequestsScreen extends ConsumerStatefulWidget {
  /// Route name for navigation
  static const routeName = '/connection-requests';

  /// Creates a new [ConnectionRequestsScreen]
  const ConnectionRequestsScreen({super.key});

  @override
  ConsumerState<ConnectionRequestsScreen> createState() =>
      _ConnectionRequestsScreenState();
}

class _ConnectionRequestsScreenState
    extends ConsumerState<ConnectionRequestsScreen> {
  // Mock connection requests — will be replaced with Supabase query
  final List<Map<String, String>> _mockRequests = List.generate(
    12,
    (i) => {
      'name': [
        'Sofia', 'Kenji', 'Elena', 'Marco', 'Aisha', 'Liam', 'Yuki',
        'Priya', 'Lucas', 'Mia', 'Anders', 'Zara'
      ][i],
      'location': [
        'Barcelona', 'Tokyo', 'Lisbon', 'Rome', 'Marrakech',
        'Vancouver', 'Osaka', 'Delhi', 'Sydney', 'Berlin',
        'Stockholm', 'Istanbul'
      ][i],
    },
  );

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final state = ref.watch(subscriptionProvider);
    final isPremium = state.isPremium;

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.subTravelersWantToConnectHeader),
        actions: [
          if (!isPremium)
            TextButton.icon(
              onPressed: () => context.push('/paywall'),
              icon: const Icon(Icons.lock_open, size: 16),
              label: Text(AppLocalizations.of(context)!.subUnlock),
            ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header with count
          Container(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
            child: Row(
              children: [
                Text(
                  AppLocalizations.of(context)!.subTravelersWantToConnect(_mockRequests.length),
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Spacer(),
                if (!isPremium) ...[
                  Icon(Icons.visibility_off,
                      size: 16, color: theme.colorScheme.onSurfaceVariant),
                  const SizedBox(width: 4),
                  Text(
                    AppLocalizations.of(context)!.subBlurredForFree,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Grid of connection request profiles
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 0.75,
              ),
              itemCount: _mockRequests.length,
              itemBuilder: (context, index) {
                final user = _mockRequests[index];
                return _ConnectionRequestCard(
                  name: user['name']!,
                  location: user['location']!,
                  isBlurred: !isPremium,
                  onTap: () => _handleCardTap(isPremium, user['name']!),
                );
              },
            ),
          ),

          // Upgrade banner for free users
          if (!isPremium)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest
                    .withValues(alpha: 0.3),
                border: Border(
                  top: BorderSide(
                    color: theme.colorScheme.outline.withValues(alpha: 0.1),
                  ),
                ),
              ),
              child: Column(
                children: [
                  Text(
                    AppLocalizations.of(context)!.subUpgradeBanner,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => context.push('/paywall'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(AppLocalizations.of(context)!.subStartFreeTrial),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  void _handleCardTap(bool isPremium, String name) {
    if (!isPremium) {
      _showUpgradeDialog(name);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.subConnectedWith(name)),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _showUpgradeDialog(String name) {
    final theme = Theme.of(context);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.visibility_off,
                color: theme.colorScheme.primary, size: 20),
            const SizedBox(width: 8),
            Text(AppLocalizations.of(context)!.subWantToSeeWho),
          ],
        ),
        content: Text(
          AppLocalizations.of(context)!.subUpgradeModalBody(name),
          style: theme.textTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(AppLocalizations.of(context)!.subMaybeLater),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.push('/paywall');
            },
            child: Text(AppLocalizations.of(context)!.subStartFreeTrial),
          ),
        ],
      ),
    );
  }
}

/// A single connection request profile card.
///
/// When [isBlurred] is true, the avatar is covered with a frosted
/// blur effect and the name is partially hidden.
class _ConnectionRequestCard extends StatelessWidget {
  final String name;
  final String location;
  final bool isBlurred;
  final VoidCallback onTap;

  const _ConnectionRequestCard({
    required this.name,
    required this.location,
    required this.isBlurred,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final hue = name.hashCode % 360;
    final avatarColor =
        HSVColor.fromAHSV(1, hue.toDouble(), 0.3, 0.9).toColor();

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: theme.colorScheme.surfaceContainerHighest
              .withValues(alpha: 0.3),
          border: Border.all(
            color: theme.colorScheme.outline.withValues(alpha: 0.1),
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      avatarColor,
                      avatarColor.withValues(alpha: 0.6),
                    ],
                  ),
                ),
                child: Center(
                  child: Text(
                    name[0].toUpperCase(),
                    style: theme.textTheme.displayLarge?.copyWith(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                ),
              ),

              // Blur overlay for free users
              if (isBlurred)
                Container(
                  color: Colors.white.withValues(alpha: 0.6),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.lock_outline,
                          size: 32,
                          color: theme.colorScheme.onSurface
                              .withValues(alpha: 0.5),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          AppLocalizations.of(context)!.subUpgradeToSee,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.onSurface
                                .withValues(alpha: 0.6),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              // Bottom info bar
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.6),
                      ],
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        isBlurred
                            ? '${name[0]}${'•' * (name.length - 1)}'
                            : name,
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        '📍 $location',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: Colors.white.withValues(alpha: 0.8),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
