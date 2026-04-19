import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../auth/presentation/providers/auth_navigation_provider.dart';
import '../../../social/providers/privacy_providers.dart';
import '../../../social/domain/enums/profile_visibility.dart';
import '../../../social/domain/enums/verification_tier.dart';
import '../../../verification/presentation/widgets/verification_badge.dart';
import '../notifiers/profile_notifier.dart';

/// Badge widget showing profile visibility tier
class _VisibilityBadge extends StatelessWidget {
  final ProfileVisibility visibility;
  final VerificationTier tier;

  const _VisibilityBadge({
    required this.visibility,
    required this.tier,
  });

  @override
  Widget build(BuildContext context) {
    final Color color;
    final IconData icon;
    final String label;

    switch (visibility) {
      case ProfileVisibility.hidden:
        color = Colors.grey;
        icon = Icons.lock;
        label = 'Hidden';
      case ProfileVisibility.community:
        color = Colors.blue;
        icon = Icons.groups;
        label = 'Community';
      case ProfileVisibility.public:
        color = Colors.green;
        icon = Icons.public;
        label = 'Public';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(color: color, fontWeight: FontWeight.w600),
          ),
          if (tier != VerificationTier.unverified) ...[
            const SizedBox(width: 6),
            Icon(
              Icons.verified,
              size: 16,
              color: tier == VerificationTier.idVerified
                  ? Colors.green
                  : Colors.blue,
            ),
          ],
        ],
      ),
    );
  }
}

/// Profile screen that displays user profile information
class ProfileScreen extends ConsumerWidget {
  /// Creates a new [ProfileScreen]
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(profileProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => ref
                .read(authNavigationProvider.notifier)
                .navigateToProfileEdit(),
          ),
        ],
      ),
      body: profileAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, stackTrace) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 48,
                  color: Colors.red,
                ),
                const SizedBox(height: 16),
                Text(
                  'Failed to load profile',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  error.toString(),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                FilledButton.tonal(
                  onPressed: () =>
                      ref.read(profileProvider.notifier).loadProfile(),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
        data: (profileState) {
          final profile = profileState.profile;

          if (profile == null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.person_off_outlined,
                      size: 48,
                      color: Colors.grey,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No profile found',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Create a profile to get started.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey,
                          ),
                    ),
                  ],
                ),
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: CircleAvatar(
                    radius: 50,
                    backgroundImage: profile.avatarUrl != null
                        ? NetworkImage(profile.avatarUrl!)
                        : null,
                    child: profile.avatarUrl == null
                        ? Text(
                            profile.displayName[0].toUpperCase(),
                            style: Theme.of(context).textTheme.headlineMedium,
                          )
                        : null,
                  ),
                ),
                const SizedBox(height: 16),
                Center(
                  child: Text(
                    profile.displayName,
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                ),
                const SizedBox(height: 8),
                Center(
                  child: Text(
                    '@${profile.username}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.grey,
                        ),
                  ),
                ),
                // Visibility tier badge
                Center(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Consumer(
                      builder: (context, ref, _) {
                        final privacy = ref.watch(profilePrivacyProvider);
                        final tier = ref.watch(verificationTierProvider);
                        return privacy.when(
                          data: (data) => _VisibilityBadge(
                            visibility: data.visibility,
                            tier: tier.value ??
                                VerificationTier.unverified,
                          ),
                          loading: () => const SizedBox(
                            height: 28,
                            child: Center(
                              child: SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              ),
                            ),
                          ),
                          error: (_, __) => _VisibilityBadge(
                            visibility: ProfileVisibility.community,
                            tier: VerificationTier.unverified,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                // Verification status card
                Center(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Consumer(
                      builder: (context, ref, _) {
                        final tier = ref.watch(verificationTierProvider).value ??
                            VerificationTier.unverified;
                        return VerificationStatusCard(
                          tier: tier,
                          onTapVerify: tier == VerificationTier.unverified
                              ? () => context.push('/verification')
                              : null,
                        );
                      },
                    ),
                  ),
                ),
                if (profile.bio != null) ...[
                  const SizedBox(height: 16),
                  Text(
                    profile.bio!,
                    style: Theme.of(context).textTheme.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                ],
                const SizedBox(height: 24),
                ListTile(
                  leading: const Icon(Icons.email),
                  title: const Text('Email'),
                  subtitle: Text(profile.email),
                ),
                Consumer(
                  builder: (context, ref, _) {
                    final privacy = ref.watch(profilePrivacyProvider);
                    return ListTile(
                      leading: const Icon(Icons.visibility),
                      title: const Text('Profile Visibility'),
                      subtitle: privacy.when(
                        data: (data) =>
                            Text(data.visibility.name.toUpperCase()),
                        loading: () => const Text('...'),
                        error: (_, __) => const Text('Unknown'),
                      ),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.calendar_today),
                  title: const Text('Member Since'),
                  subtitle: Text(
                    profile.createdAt.toLocal().toString().split(' ')[0],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
