import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/profile_providers.dart';
import '../widgets/profile_avatar.dart';
import '../widgets/profile_info_section.dart';
import '../widgets/profile_actions.dart';
import '../widgets/error_view.dart';
import '../widgets/loading_view.dart';
import '../routes/profile_routes.dart';

/// Profile screen for the application
class ProfileScreen extends ConsumerStatefulWidget {
  /// Route name for navigation
  static const routeName = '/profile';

  /// The ID of the profile to display. If null, displays the current user's profile.
  final String? profileId;

  /// Creates a new [ProfileScreen]
  const ProfileScreen({
    super.key,
    this.profileId,
  });

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => ref.read(profileProvider.notifier).loadProfile(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(profileProvider);
    final theme = Theme.of(context);

    if (state.isLoading) {
      return const LoadingView();
    }

    if (state.hasError) {
      return ErrorView(
        error: state.error!,
        onRetry: () => ref.read(profileProvider.notifier).loadProfile(),
      );
    }

    if (!state.isInitialized) {
      return const Center(
        child: Text('No profile data available'),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => ProfileRoutes.navigateToEditProfile(
              context,
              profile: state.profile,
            ),
            tooltip: 'Edit Profile',
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => ProfileRoutes.navigateToSettings(context),
            tooltip: 'Profile Settings',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(profileProvider.notifier).loadProfile(),
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            ProfileAvatar(
              avatarUrl: state.profile!.avatarUrl,
              size: 120,
            ),
            const SizedBox(height: 24),
            Text(
              state.profile!.displayName,
              style: theme.textTheme.headlineMedium,
              textAlign: TextAlign.center,
            ),
            if (state.profile!.bio != null) ...[
              const SizedBox(height: 8),
              Text(
                state.profile!.bio!,
                style: theme.textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
            ],
            const SizedBox(height: 32),
            ProfileInfoSection(profile: state.profile!),
            const SizedBox(height: 24),
            ProfileActions(
              isPublic: state.profile!.isPublic,
              onToggleVisibility: (isPublic) {
                ref.read(profileProvider.notifier).updateProfile({
                  'isPublic': isPublic,
                });
              },
              onDeleteProfile: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Delete Profile'),
                    content: const Text(
                      'Are you sure you want to delete your profile? This action cannot be undone.',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('CANCEL'),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                          ref.read(profileProvider.notifier).deleteProfile();
                          ProfileRoutes.popToProfile(context);
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: theme.colorScheme.error,
                        ),
                        child: const Text('DELETE'),
                      ),
                    ],
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
