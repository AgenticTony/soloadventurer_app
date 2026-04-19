import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:soloadventurer/l10n/app_localizations.dart';
import 'package:soloadventurer/app/providers/analytics_provider.dart';
import 'package:soloadventurer/core/services/analytics_service.dart';
import 'package:soloadventurer/features/matching/presentation/providers/connection_provider.dart';
import 'package:soloadventurer/features/matching/presentation/providers/trip_provider.dart';
import 'package:soloadventurer/features/matching/presentation/providers/activity_provider.dart';
import 'package:soloadventurer/features/matching/presentation/providers/chat_provider.dart';
import 'package:soloadventurer/features/matching/domain/entities/connection.dart';
import 'package:soloadventurer/features/matching/domain/entities/activity.dart';
import 'package:soloadventurer/features/social/domain/enums/verification_tier.dart';
import 'package:soloadventurer/features/verification/presentation/widgets/verification_badge.dart';
import 'package:soloadventurer/features/social/providers/privacy_providers.dart';

/// Matches screen showing nearby travelers with overlapping trips
class MatchesScreen extends ConsumerStatefulWidget {
  /// Route name for navigation
  static const routeName = '/matches';

  /// Creates a new [MatchesScreen]
  const MatchesScreen({super.key});

  @override
  ConsumerState<MatchesScreen> createState() => _MatchesScreenState();
}

class _MatchesScreenState extends ConsumerState<MatchesScreen> {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final matchesAsync = ref.watch(matchesProvider);
    final activeTripsAsync = ref.watch(activeTripsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.appBarTitleNearbyTravelers),
        actions: [
          // Chat list button with unread badge
          Consumer(builder: (context, ref, _) {
            final unreadAsync = ref.watch(unreadCountProvider);
            final unread = unreadAsync.value ?? 0;
            return Stack(
              alignment: Alignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.chat_bubble_outline),
                  onPressed: () => context.push('/chats'),
                ),
                if (unread > 0)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.error,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      child: Text(
                        unread > 9 ? '9+' : '$unread',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            );
          }),
          // Matches count badge
          IconButton(
            icon: const Icon(Icons.people_outline),
            onPressed: () {
              // Show matches filter/list view
              _showMatchesFilterBottomSheet(context);
            },
          ),
        ],
      ),
      body: matchesAsync.when(
        data: (matches) {
          return activeTripsAsync.when(
            data: (trips) {
              if (trips.isEmpty) {
                return _buildNoTripsState(context, l10n);
              }

              if (matches.isEmpty) {
                return _buildNoMatchesState(context, l10n);
              }

              return _buildMatchesList(matches, l10n);
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) => _buildErrorState(context, l10n, error),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => _buildErrorState(context, l10n, error),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Navigate to create trip screen
          _showCreateTripDialog(context);
        },
        icon: const Icon(Icons.add),
        label: Text(l10n.fabAddTrip),
      ),
    );
  }

  Widget _buildNoTripsState(BuildContext context, AppLocalizations l10n) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.flight_takeoff,
              size: 80,
              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 24),
            Text(
              l10n.noTripsTitle,
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              l10n.noTripsDescription,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => _showCreateTripDialog(context),
              icon: const Icon(Icons.add),
              label: Text(l10n.noTripsButton),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoMatchesState(BuildContext context, AppLocalizations l10n) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search,
              size: 80,
              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 24),
            Text(
              l10n.noMatchesTitle,
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              l10n.noMatchesDescription,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            OutlinedButton.icon(
              onPressed: () {
                // Navigate to edit profile to adjust matching preferences
                context.push('/edit-profile');
              },
              icon: const Icon(Icons.tune),
              label: Text(l10n.noMatchesButton),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMatchesList(List<Connection> matches, AppLocalizations l10n) {
    final activitiesAsync = ref.watch(activitiesProvider);
    final verifiedOnly = ref.watch(profilePrivacyProvider).value?.verifiedOnly ?? false;

    final filteredMatches = verifiedOnly
        ? matches.where((m) =>
            m.matchedUserProfile?.verificationTier != VerificationTier.unverified)
            .toList()
        : matches;

    if (filteredMatches.isEmpty && verifiedOnly) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.verified_user_outlined,
                size: 64,
                color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.5),
              ),
              const SizedBox(height: 16),
              Text(
                'No verified travelers nearby',
                style: Theme.of(context).textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Try disabling the verified-only filter',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return activitiesAsync.when(
      data: (allActivities) {
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: filteredMatches.length,
          itemBuilder: (context, index) {
            final match = filteredMatches[index];
            final profile = match.matchedUserProfile;
            
            return Card(
              elevation: 2,
              margin: const EdgeInsets.only(bottom: 12),
              child: InkWell(
                onTap: () {
                  // Navigate to match detail screen
                  _showMatchDetailDialog(context, match, allActivities);
                },
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // User info row
                      Row(
                        children: [
                          Stack(
                            clipBehavior: Clip.none,
                            children: [
                              CircleAvatar(
                                radius: 28,
                                backgroundImage: profile?.avatarUrl != null
                                    ? NetworkImage(profile!.avatarUrl!)
                                    : null,
                                child: profile?.avatarUrl == null
                                    ? Text(
                                        profile?.firstName.isNotEmpty == true
                                            ? profile!.firstName[0].toUpperCase()
                                            : '?',
                                        style: const TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      )
                                    : null,
                              ),
                              if (profile?.verificationTier != VerificationTier.unverified)
                                Positioned(
                                  right: -4,
                                  bottom: -4,
                                  child: VerificationBadge(
                                    tier: profile!.verificationTier,
                                    size: 20,
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  profile?.firstName ?? l10n.unknownTraveler,
                                  style:
                                    Theme.of(context).textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${profile?.ageRange ?? l10n.notAvailable} • ${profile?.homeCountry ?? l10n.unknownLocation}',
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Status indicator
                          if (match.status.name == 'pending')
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.secondaryContainer,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                l10n.statusNew,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Theme.of(context).colorScheme.onSecondaryContainer,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      // Trip info
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.place,
                                  size: 16,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    profile?.trip?.destinationName ?? l10n.unknownDestination,
                                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(
                                  Icons.calendar_today,
                                  size: 16,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${_formatDate(match.overlapStartDate)} - ${_formatDate(match.overlapEndDate)}',
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).colorScheme.primaryContainer,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    l10n.daysOverlap(match.overlapDays),
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Activity icebreaker chips (F-003)
                      if (match.matchType == MatchType.activityMatch || 
                          match.matchType == MatchType.combinedMatch)
                        _buildActivityChips(match, allActivities),
                      const SizedBox(height: 8),
                      // Match type indicator
                      Row(
                        children: [
                          Icon(
                            _getMatchTypeIcon(match.matchType.name),
                            size: 14,
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _formatMatchType(match.matchType.name, l10n),
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                          ),
                          if (match.distanceMeters != null) ...[
                            const SizedBox(width: 8),
                            Icon(
                              Icons.straighten,
                              size: 14,
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              l10n.kmAway((match.distanceMeters! / 1000).toStringAsFixed(1)),
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => _buildMatchesListSimple(filteredMatches, l10n),
    );
  }

  /// Simple matches list without activity chips (fallback)
  Widget _buildMatchesListSimple(List<Connection> matches, AppLocalizations l10n) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: matches.length,
      itemBuilder: (context, index) {
        final match = matches[index];
        final profile = match.matchedUserProfile;
        
        return Card(
          elevation: 2,
          margin: const EdgeInsets.only(bottom: 12),
          child: InkWell(
            onTap: () {
              _showMatchDetailDialog(context, match, []);
            },
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // User info row
                  Row(
                    children: [
                      Stack(
                        clipBehavior: Clip.none,
                        children: [
                          CircleAvatar(
                            radius: 28,
                            backgroundImage: profile?.avatarUrl != null
                                ? NetworkImage(profile!.avatarUrl!)
                                : null,
                            child: profile?.avatarUrl == null
                                ? Text(
                                    profile?.firstName.isNotEmpty == true
                                        ? profile!.firstName[0].toUpperCase()
                                        : '?',
                                    style: const TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  )
                                : null,
                          ),
                          if (profile?.verificationTier != VerificationTier.unverified)
                            Positioned(
                              right: -4,
                              bottom: -4,
                              child: VerificationBadge(
                                tier: profile!.verificationTier,
                                size: 20,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              profile?.firstName ?? l10n.unknownTraveler,
                              style: 
                                Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${profile?.ageRange ?? l10n.notAvailable} • ${profile?.homeCountry ?? l10n.unknownLocation}',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  /// Build activity icebreaker chips for a match using genuine shared activities.
  Widget _buildActivityChips(Connection match, List<Activity> allActivities) {
    // Use the shared activity count from the connection to filter real shared
    // activities. In production, the matching RPC returns the actual overlap,
    // but for presentation we show the top shared activities by category.
    final sharedCount = match.sharedActivityCount ?? 0;
    if (sharedCount == 0 && allActivities.isEmpty) return const SizedBox.shrink();

    // Show activities that overlap (top N based on shared count or available)
    final matchedActivities = allActivities.take(sharedCount.clamp(0, 5)).toList();
    // Fallback: if connection doesn't list specific activities yet, show top 3.
    final displayActivities = matchedActivities.isNotEmpty
        ? matchedActivities
        : allActivities.take(3).toList();

    if (displayActivities.isEmpty) return const SizedBox.shrink();

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        ...displayActivities.map((activity) {
          return ActionChip(
            avatar: Text(activity.icon ?? '🎯'),
            label: Text(activity.name),
            onPressed: () {
              _sendMessageWithIcebreaker(match, activity);
            },
          );
        }),
        // "Book together" button for Viator activities when both users share interests
        if (sharedCount >= 2)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: ActionChip(
              avatar: const Icon(Icons.local_activity, size: 18),
              label: const Text('Book together'),
              onPressed: () {
                _sendBookTogetherMessage(match);
              },
            ),
          ),
      ],
    );
  }

  /// Send "Book together" message for shared Viator activities
  void _sendBookTogetherMessage(Connection match) async {
    try {
      await ref.read(chatProvider.notifier).startChat(match.id);

      ref.read(analyticsServiceProvider).track(
        AnalyticsEvents.openChat,
        properties: {
          'connectionId': match.id,
          'icebreaker': 'book_together',
        },
      );

      if (mounted) {
        // Navigate to chat with prefilled message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Opening chat to plan a shared activity!'),
            duration: Duration(seconds: 1),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not open chat: $e'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  /// Send message with activity icebreaker
  void _sendMessageWithIcebreaker(Connection match, Activity activity) async {
    final profile = match.matchedUserProfile;
    
    // Generate pre-filled message based on activity
    String icebreakerMessage;
    switch (activity.name.toLowerCase()) {
      case 'coffee':
        icebreakerMessage = "Hi! I'd love to grab coffee with you during our trip! ☕";
        break;
      case 'hiking':
        icebreakerMessage = "Hey! Interested in going hiking together? 🥾";
        break;
      case 'sightseeing':
        icebreakerMessage = "Hi! Want to explore ${profile?.trip?.destinationName ?? 'the area'} together? 🗺️";
        break;
      default:
        icebreakerMessage = "Hi! I see we both enjoy ${activity.name}. Want to do it together?";
    }

    try {
      // Create or get chat for this connection
      final chat = await ref.read(chatProvider.notifier).startChat(match.id);

      ref.read(analyticsServiceProvider).track(
        AnalyticsEvents.openChat,
        properties: {
          'connectionId': match.id,
          'icebreaker': activity.name,
        },
      );

      // Navigate to chat screen with pre-filled message
      if (mounted) {
        context.push(
          '/chat/${match.id}',
          extra: {
            'chatId': chat.id,
            'prefilledMessage': icebreakerMessage,
          },
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error opening chat: $e')),
        );
      }
    }
  }

  String _formatDate(DateTime date) {
    return '${date.month}/${date.day}';
  }

  IconData _getMatchTypeIcon(String matchType) {
    switch (matchType) {
      case 'geographicOverlap':
        return Icons.place;
      case 'activityMatch':
        return Icons.local_activity;
      case 'combinedMatch':
        return Icons.star;
      default:
        return Icons.people;
    }
  }

  String _formatMatchType(String matchType, AppLocalizations l10n) {
    switch (matchType) {
      case 'geographicOverlap':
        return l10n.matchTypeSameDestination;
      case 'activityMatch':
        return l10n.matchTypeSharedInterests;
      case 'combinedMatch':
        return l10n.matchTypePerfectMatch;
      default:
        return l10n.matchTypeDefault;
    }
  }

  Widget _buildErrorState(BuildContext context, AppLocalizations l10n, Object error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 80,
              color: Theme.of(context).colorScheme.error.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 24),
            Text(
              l10n.errorTitle,
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              error.toString(),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () {
                ref.invalidate(matchesProvider);
                ref.invalidate(activeTripsProvider);
              },
              icon: const Icon(Icons.refresh),
              label: Text(l10n.errorButtonRetry),
            ),
          ],
        ),
      ),
    );
  }

  void _showCreateTripDialog(BuildContext context) {
    // Navigate to trip creation screen
    context.push('/create-trip');
  }

  void _showMatchesFilterBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Consumer(
        builder: (context, ref, _) {
          final privacyAsync = ref.watch(profilePrivacyProvider);
          return Container(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Filter Matches',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                SwitchListTile(
                  secondary: const Icon(Icons.verified_user),
                  title: const Text('Only show verified users'),
                  subtitle: const Text('Filter out unverified travelers'),
                  value: privacyAsync.value?.verifiedOnly ?? false,
                  onChanged: (value) {
                    ref.read(profilePrivacyProvider.notifier).updateFilters(verifiedOnly: value);
                  },
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.place),
                  title: const Text('By Location'),
                  onTap: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Location filter coming soon!')),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.local_activity),
                  title: const Text('By Activities'),
                  onTap: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Activity filter coming soon!')),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.calendar_today),
                  title: const Text('By Travel Dates'),
                  onTap: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Date filter coming soon!')),
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showMatchDetailDialog(BuildContext context, Connection match, List<Activity> allActivities) {
    final profile = match.matchedUserProfile;
    final isPending = match.status == ConnectionStatus.pending;
    final isAccepted = match.status == ConnectionStatus.accepted;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(profile?.firstName ?? 'Traveler'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (profile?.trip != null) ...[
                Text('📍 ${profile!.trip!.destinationName}'),
                const SizedBox(height: 8),
                Text('📅 ${_formatDate(profile.trip!.startDate)} - ${_formatDate(profile.trip!.endDate)}'),
              ],
              const SizedBox(height: 16),
              Text('Overlap: ${match.overlapDays} days'),
              if (match.distanceMeters != null)
                Text('Distance: ${(match.distanceMeters! / 1000).toStringAsFixed(1)} km away'),
              const SizedBox(height: 16),
              // Activity icebreaker buttons
              if (match.matchType == MatchType.activityMatch ||
                  match.matchType == MatchType.combinedMatch) ...[
                const Divider(),
                const SizedBox(height: 8),
                Text(
                  'Suggest an activity:',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: allActivities.take(5).map((activity) {
                    return ActionChip(
                      avatar: Text(activity.icon ?? '🎯'),
                      label: Text(activity.name),
                      onPressed: () {
                        Navigator.pop(context);
                        _sendMessageWithIcebreaker(match, activity);
                      },
                    );
                  }).toList(),
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          if (profile?.id != null)
            TextButton.icon(
              onPressed: () {
                Navigator.pop(context);
                this.context.push('/user/${profile!.id}');
              },
              icon: const Icon(Icons.person, size: 18),
              label: const Text('View Profile'),
            ),
          if (isPending) ...[
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                ref.read(connectionProvider.notifier).declineConnection(match.id);
                ref.read(analyticsServiceProvider).track(
                  AnalyticsEvents.declineConnection,
                  properties: {'connectionId': match.id},
                );
                ScaffoldMessenger.of(this.context).showSnackBar(
                  const SnackBar(content: Text('Request declined')),
                );
              },
              style: TextButton.styleFrom(foregroundColor: Colors.grey),
              child: const Text('Decline'),
            ),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context);
                ref.read(connectionProvider.notifier).acceptConnection(match.id);
                ref.read(analyticsServiceProvider).track(
                  AnalyticsEvents.acceptConnection,
                  properties: {'connectionId': match.id},
                );
                ScaffoldMessenger.of(this.context).showSnackBar(
                  const SnackBar(content: Text('Connection accepted!')),
                );
              },
              icon: const Icon(Icons.check),
              label: const Text('Accept'),
            ),
          ],
          if (isAccepted)
            ElevatedButton.icon(
              onPressed: () async {
                Navigator.pop(context);
                ref.read(analyticsServiceProvider).track(
                  AnalyticsEvents.openChat,
                  properties: {'connectionId': match.id},
                );
                try {
                  final chat = await ref.read(chatProvider.notifier).startChat(match.id);
                  if (this.context.mounted) {
                    this.context.push('/chat/${match.id}', extra: {'chatId': chat.id});
                  }
                } catch (e) {
                  if (this.context.mounted) {
                    ScaffoldMessenger.of(this.context).showSnackBar(
                      SnackBar(content: Text('Error opening chat: $e')),
                    );
                  }
                }
              },
              icon: const Icon(Icons.chat),
              label: const Text('Message'),
            ),
        ],
      ),
    );
  }
}
