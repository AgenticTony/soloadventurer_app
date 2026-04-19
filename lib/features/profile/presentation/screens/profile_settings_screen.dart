import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soloadventurer/core/widgets/widgets.dart';
import 'package:soloadventurer/features/matching/presentation/providers/chat_provider.dart';
import 'package:soloadventurer/features/social/providers/privacy_providers.dart';
import 'package:soloadventurer/features/social/domain/enums/content_audience.dart';
import 'package:soloadventurer/features/social/domain/enums/comment_permission.dart';
import '../providers/profile_providers.dart';
import '../widgets/loading_view.dart';

class ProfileSettingsScreen extends ConsumerStatefulWidget {
  /// Route name for navigation
  static const routeName = '/profile/settings';

  /// Creates a new [ProfileSettingsScreen]
  const ProfileSettingsScreen({super.key});

  @override
  ConsumerState<ProfileSettingsScreen> createState() => _ProfileSettingsScreenState();
}

class _ProfileSettingsScreenState extends ConsumerState<ProfileSettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final state = ref.watch(profileDomainProvider('current'));
    final theme = Theme.of(context);

    if (state.isLoading) {
      return const LoadingView();
    }

    if (state.error != null) {
      return Scaffold(
        body: Center(
          child: Text('Error: ${state.error}'),
        ),
      );
    }

    final profile = state.profile;
    if (profile == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile Settings'),
      ),
      body: VirtualListView<Widget>(
        itemCount: 1,
        itemBuilder: (context, index) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSection(
                context,
                'Privacy',
                [
                  SwitchListTile(
                    title: const Text('Public Profile'),
                    subtitle: Text(
                      profile.isPublic
                          ? 'Your profile is visible to everyone'
                          : 'Your profile is private',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    value: profile.isPublic,
                    onChanged: (value) {
                      final updatedProfile = profile.copyWith(isPublic: value);
                      ref
                          .read(profileDomainProvider('current').notifier)
                          .updateProfile(updatedProfile);
                    },
                  ),
                ],
              ),
              _buildContentPrivacySection(context, ref),
              _buildWomenOnlySection(context, ref),
              _buildSection(
                context,
                'Account',
                [
                  ListTile(
                    title: const Text('Delete Account'),
                    subtitle: const Text(
                      'Permanently delete your account and all data',
                    ),
                    leading: Icon(
                      Icons.delete_forever,
                      color: theme.colorScheme.error,
                    ),
                    textColor: theme.colorScheme.error,
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Delete Account'),
                          content: const Text(
                            'Are you sure you want to delete your account? This action cannot be undone and will permanently delete all your data.',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('CANCEL'),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                                ref
                                    .read(profileDomainProvider('current').notifier)
                                    .deleteProfile();
                                Navigator.pop(context); // Pop settings screen
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
              if (state.error != null)
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    state.error ?? 'An error occurred',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.error,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSection(
    BuildContext context,
    String title,
    List<Widget> children,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        ),
        ...children,
      ],
    );
  }

  Widget _buildContentPrivacySection(BuildContext context, WidgetRef ref) {
    final contentPrivacyAsync = ref.watch(contentPrivacyProvider);
    final theme = Theme.of(context);

    return contentPrivacyAsync.when(
      data: (settings) {
        return _buildSection(
          context,
          'Content Privacy',
          [
            ListTile(
              dense: true,
              title: const Text('Default Audience'),
              subtitle: Text(
                'Who sees your journal entries by default',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              trailing: DropdownButton<ContentAudience>(
                value: settings.defaultPostAudience,
                underline: const SizedBox.shrink(),
                onChanged: (value) {
                  if (value != null) {
                    ref.read(contentPrivacyProvider.notifier).updateSettings(
                      settings.copyWith(defaultPostAudience: value),
                    );
                  }
                },
                items: ContentAudience.values.map((audience) {
                  return DropdownMenuItem(
                    value: audience,
                    child: Text(
                      _contentAudienceLabel(audience),
                      style: theme.textTheme.bodyMedium,
                    ),
                  );
                }).toList(),
              ),
            ),
            ListTile(
              dense: true,
              title: const Text('Comment Permissions'),
              subtitle: Text(
                'Who can comment on your posts',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              trailing: DropdownButton<CommentPermission>(
                value: settings.allowCommentsFrom,
                underline: const SizedBox.shrink(),
                onChanged: (value) {
                  if (value != null) {
                    ref.read(contentPrivacyProvider.notifier).updateSettings(
                      settings.copyWith(allowCommentsFrom: value),
                    );
                  }
                },
                items: CommentPermission.values.map((perm) {
                  return DropdownMenuItem(
                    value: perm,
                    child: Text(
                      _commentPermissionLabel(perm),
                      style: theme.textTheme.bodyMedium,
                    ),
                  );
                }).toList(),
              ),
            ),
            SwitchListTile(
              dense: true,
              title: const Text('Allow Reshares'),
              subtitle: Text(
                'Let others share your content with their followers',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              value: settings.allowReshares,
              onChanged: (value) {
                ref.read(contentPrivacyProvider.notifier).updateSettings(
                  settings.copyWith(allowReshares: value),
                );
              },
            ),
            SwitchListTile(
              dense: true,
              title: const Text('Destination Feed'),
              subtitle: Text(
                'Show your posts in destination feeds for other travelers',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              value: settings.includeInDestinationFeed,
              onChanged: (value) {
                ref.read(contentPrivacyProvider.notifier).updateSettings(
                  settings.copyWith(includeInDestinationFeed: value),
                );
              },
            ),
          ],
        );
      },
      loading: () => _buildSection(
        context,
        'Content Privacy',
        const [
          ListTile(
            title: Text('Loading privacy settings...'),
            trailing: SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
        ],
      ),
      error: (error, _) => _buildSection(
        context,
        'Content Privacy',
        [
          ListTile(
            title: const Text('Could not load privacy settings'),
            subtitle: Text(
              error.toString(),
              style: TextStyle(color: theme.colorScheme.error),
            ),
            trailing: IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () => ref.invalidate(contentPrivacyProvider),
            ),
          ),
        ],
      ),
    );
  }

  String _contentAudienceLabel(ContentAudience audience) {
    switch (audience) {
      case ContentAudience.followers:
        return 'Followers Only';
      case ContentAudience.community:
        return 'Community';
      case ContentAudience.public:
        return 'Everyone';
    }
  }

  String _commentPermissionLabel(CommentPermission perm) {
    switch (perm) {
      case CommentPermission.nobody:
        return 'Nobody';
      case CommentPermission.followers:
        return 'Followers';
      case CommentPermission.everyone:
        return 'Everyone';
    }
  }

  Widget _buildWomenOnlySection(BuildContext context, WidgetRef ref) {
    final womenOnlyEnabled = ref.watch(womenOnlyModeEnabledProvider);
    final canEnable = ref.watch(canEnableWomenOnlyModeProvider);
    final theme = Theme.of(context);

    return womenOnlyEnabled.when(
      data: (enabled) {
        return canEnable.when(
          data: (canEnableValue) {
            return _buildSection(
              context,
              'Women-Only Mode',
              [
                Card(
                  margin: const EdgeInsets.symmetric(horizontal: 0),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.female,
                              color: theme.colorScheme.primary,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Connect only with verified women',
                                style: theme.textTheme.titleMedium,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'This mode requires identity verification and a premium subscription. '
                          'You will only see and be visible to other verified women travelers.',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 16),
                        if (!canEnableValue) ...[
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.errorContainer,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.verified_user_outlined,
                                  color: theme.colorScheme.onErrorContainer,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Verification required',
                                    style: TextStyle(
                                      color: theme.colorScheme.onErrorContainer,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),
                          OutlinedButton.icon(
                            onPressed: () {
                              // TODO: Navigate to verification flow
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Verification flow coming soon'),
                                ),
                              );
                            },
                            icon: const Icon(Icons.verified),
                            label: const Text('Start Verification'),
                          ),
                        ],
                        SwitchListTile(
                          title: const Text('Enable Women-Only Mode'),
                          subtitle: Text(
                            enabled
                                ? 'Active - only verified women will see you'
                                : 'Disabled',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                          value: enabled,
                          onChanged: canEnableValue
                              ? (value) async {
                                  try {
                                    if (value) {
                                      await ref
                                          .read(womenOnlyModeProvider.notifier)
                                          .enable();
                                    } else {
                                      await ref
                                          .read(womenOnlyModeProvider.notifier)
                                          .disable();
                                    }
                                    if (mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text(value 
                                              ? 'Women-only mode enabled'
                                              : 'Women-only mode disabled'),
                                        ),
                                      );
                                    }
                                  } catch (e) {
                                    if (mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text('Error: $e'),
                                          backgroundColor: theme.colorScheme.error,
                                        ),
                                      );
                                    }
                                  }
                                }
                              : null,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
          loading: () => const ListTile(
            title: Text('Women-Only Mode'),
            subtitle: Text('Checking eligibility...'),
          ),
          error: (error, _) => ListTile(
            title: const Text('Women-Only Mode'),
            subtitle: Text('Error: $error'),
          ),
        );
      },
      loading: () => const ListTile(
        title: Text('Women-Only Mode'),
        subtitle: Text('Loading...'),
      ),
      error: (error, _) => ListTile(
        title: const Text('Women-Only Mode'),
        subtitle: Text('Error: $error'),
      ),
    );
  }

}
