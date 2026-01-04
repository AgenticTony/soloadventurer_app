import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../auth/presentation/providers/auth_providers.dart';
import '../../domain/models/personalized_recommendation.dart';
import '../../application/providers/recommendation_provider.dart';
import '../../application/providers/saved_destinations_provider.dart';
import '../../domain/models/saved_destination.dart';
import '../widgets/destination_card.dart';
import '../widgets/safety_score_badge.dart';
import '../widgets/solo_suitability_badge.dart';

/// Screen displaying personalized destination recommendations for the user.
///
/// This screen shows AI-powered destination recommendations tailored to the user's
/// preferences, travel history, and behavior. Features include:
/// - Personalized greeting and recommendation summary
/// - Recommended destinations sorted by match score
/// - Match score percentage and reason for each recommendation
/// - Matching factors and insights
/// - Pull-to-refresh functionality
/// - Save/bookmark functionality
/// - Filter options (high match, hidden gems)
/// - Loading, error, and empty states
///
/// The screen integrates with:
/// - [RecommendationProvider] for recommendation data
/// - [SavedDestinationsProvider] for bookmark functionality
/// - [authNotifierProvider] for current user authentication
class RecommendationsScreen extends ConsumerStatefulWidget {
  /// Creates a new [RecommendationsScreen]
  const RecommendationsScreen({super.key});

  /// Route name for navigation
  static const String routeName = '/recommendations';

  @override
  ConsumerState<RecommendationsScreen> createState() =>
      _RecommendationsScreenState();
}

class _RecommendationsScreenState extends ConsumerState<RecommendationsScreen> {
  /// Selected filter for recommendations
  RecommendationFilter _selectedFilter = RecommendationFilter.all;

  @override
  void initState() {
    super.initState();
    // Initial load is handled automatically by the provider
  }

  /// Refresh recommendations
  Future<void> _refreshRecommendations() async {
    final authState = ref.read(authNotifierProvider);

    if (!authState.hasValue || authState.value!.user == null) {
      return;
    }

    final userId = authState.value!.user!.id;
    final recommendationNotifier = ref.read(recommendationProvider(userId).notifier);

    try {
      await recommendationNotifier.refresh();
    } catch (error) {
      // Error is handled in the provider's state
    }
  }

  /// Handle destination card tap
  void _onDestinationTap(String destinationId) {
    // TODO: Implement navigation in subtask 6.1
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Viewing destination: $destinationId'),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  /// Handle save/bookmark destination
  Future<void> _onBookmarkTap(
    String destinationId,
    String destinationName,
  ) async {
    final authState = ref.read(authNotifierProvider);

    if (!authState.hasValue || authState.value!.user == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please sign in to save destinations'),
            duration: Duration(seconds: 2),
          ),
        );
      }
      return;
    }

    final userId = authState.value!.user!.id;
    final savedState = ref.read(savedDestinationsProvider(userId));
    final isAlreadySaved = savedState.hasValue &&
        savedState.value!.isDestinationInWishlist(destinationId);

    final savedNotifier = ref.read(savedDestinationsProvider(userId).notifier);

    try {
      if (isAlreadySaved) {
        // Unsave the destination
        await savedNotifier.unsaveDestination(
          userId: userId,
          destinationId: destinationId,
          saveType: SaveType.wishlist,
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('$destinationName removed from wishlist'),
              duration: const Duration(seconds: 2),
            ),
          );
        }
      } else {
        // Get destination data from recommendation
        final recommendationState = ref.read(recommendationProvider(userId));
        if (recommendationState.hasValue &&
            recommendationState.value!.recommendation != null) {
          final recommendedDest = recommendationState.value!.recommendation!.recommendations
              .where((r) => r.destination.id == destinationId)
              .firstOrNull;

          if (recommendedDest != null) {
            await savedNotifier.saveDestination(
              userId: userId,
              destination: recommendedDest.destination,
              saveType: SaveType.wishlist,
            );

            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('$destinationName saved to wishlist'),
                  duration: const Duration(seconds: 2),
                ),
              );
            }
          }
        }
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${error.toString()}'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  /// Get filtered recommendations based on selected filter
  List<RecommendedDestination> _getFilteredRecommendations(
    List<RecommendedDestination> recommendations,
  ) {
    switch (_selectedFilter) {
      case RecommendationFilter.highMatch:
        return recommendations
            .where((r) => r.matchScore >= 0.7)
            .toList();
      case RecommendationFilter.hiddenGems:
        return recommendations
            .where((r) => r.isHiddenGemMatch)
            .toList();
      case RecommendationFilter.all:
      default:
        return recommendations;
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('For You'),
        actions: [
          // Filter button
          PopupMenuButton<RecommendationFilter>(
            icon: const Icon(Icons.filter_list),
            onSelected: (filter) {
              setState(() {
                _selectedFilter = filter;
              });
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: RecommendationFilter.all,
                child: _buildFilterMenuItem(
                  context,
                  RecommendationFilter.all,
                  'All Recommendations',
                  Icons.list,
                ),
              ),
              PopupMenuItem(
                value: RecommendationFilter.highMatch,
                child: _buildFilterMenuItem(
                  context,
                  RecommendationFilter.highMatch,
                  'High Match Only',
                  Icons.star,
                ),
              ),
              PopupMenuItem(
                value: RecommendationFilter.hiddenGems,
                child: _buildFilterMenuItem(
                  context,
                  RecommendationFilter.hiddenGems,
                  'Hidden Gems',
                  Icons.diamond,
                ),
              ),
            ],
          ),
        ],
      ),
      body: authState.when(
        data: (authData) {
          // Check if user is authenticated
          if (authData.user == null) {
            return _buildSignInPrompt(context);
          }

          final userId = authData.user!.id;
          final recommendationState = ref.watch(recommendationProvider(userId));
          final savedState = ref.watch(savedDestinationsProvider(userId));

          return _buildRecommendationsContent(
            context,
            recommendationState,
            savedState,
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, stackTrace) => _buildErrorState(
          context,
          error,
          isAuthError: true,
        ),
      ),
    );
  }

  /// Build the main recommendations content
  Widget _buildRecommendationsContent(
    BuildContext context,
    AsyncValue<RecommendationState> recommendationState,
    AsyncValue<SavedDestinationsState> savedState,
  ) {
    return recommendationState.when(
      data: (state) {
        final recommendations = state.recommendation;
        final filteredRecommendations = recommendations != null
            ? _getFilteredRecommendations(
                recommendations.sortedByMatchScore,
              )
            : <RecommendedDestination>[];

        // Empty state
        if (filteredRecommendations.isEmpty) {
          return _buildEmptyState(context);
        }

        // Recommendations list
        return RefreshIndicator(
          onRefresh: _refreshRecommendations,
          child: CustomScrollView(
            slivers: [
              // Summary header
              if (recommendations?.summary != null)
                SliverToBoxAdapter(
                  child: _buildSummaryHeader(context, recommendations!),
                ),

              // Recommendations list
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final recommendedDest = filteredRecommendations[index];
                    final isSaved = savedState.hasValue &&
                        savedState.value!.isDestinationInWishlist(
                          recommendedDest.destination.id,
                        );

                    return RepaintBoundary(
                      child: _RecommendationCard(
                        key: ValueKey(recommendedDest.destination.id),
                        recommendedDestination: recommendedDest,
                        isSaved: isSaved,
                        onTap: () => _onDestinationTap(
                          recommendedDest.destination.id,
                        ),
                        onBookmarkTap: () => _onBookmarkTap(
                          recommendedDest.destination.id,
                          recommendedDest.destination.name,
                        ),
                      ),
                    );
                  },
                  childCount: filteredRecommendations.length,
                ),
              ),
            ],
          ),
        );
      },
      loading: () => const Center(
        child: CircularProgressIndicator(),
      ),
      error: (error, stackTrace) => _buildErrorState(context, error),
    );
  }

  /// Build the summary header with greeting and explanation
  Widget _buildSummaryHeader(
    BuildContext context,
    PersonalizedRecommendation recommendation,
  ) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer,
        border: Border(
          bottom: BorderSide(
            color: theme.dividerColor,
            width: 1,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.recommend,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                'Recommended for You',
                style: theme.textTheme.titleLarge?.copyWith(
                  color: theme.colorScheme.onPrimaryContainer,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            recommendation.summary ?? 'Based on your preferences',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onPrimaryContainer.withOpacity(0.8),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${recommendation.recommendations.length} destinations • '
            'Updated ${_formatTimestamp(recommendation.generatedAt)}',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onPrimaryContainer.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }

  /// Build empty state widget
  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.explore_off,
              size: 64,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              'No recommendations yet',
              style: theme.textTheme.titleLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _getEmptyStateMessage(),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _refreshRecommendations,
              icon: const Icon(Icons.refresh),
              label: const Text('Refresh'),
            ),
          ],
        ),
      ),
    );
  }

  /// Build error state widget
  Widget _buildErrorState(
    BuildContext context,
    Object error, {
    bool isAuthError = false,
  }) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isAuthError ? Icons.lock_outline : Icons.error_outline,
              size: 64,
              color: isAuthError
                  ? theme.colorScheme.onSurfaceVariant
                  : theme.colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              isAuthError ? 'Authentication Required' : 'Something went wrong',
              style: theme.textTheme.titleLarge?.copyWith(
                color: isAuthError
                    ? theme.colorScheme.onSurfaceVariant
                    : theme.colorScheme.error,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error.toString(),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            if (!isAuthError) ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _refreshRecommendations,
                icon: const Icon(Icons.refresh),
                label: const Text('Try Again'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Build sign in prompt widget
  Widget _buildSignInPrompt(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.person_outline,
              size: 64,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              'Sign In for Recommendations',
              style: theme.textTheme.titleLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Sign in to see personalized destination recommendations '
              'based on your preferences and travel history.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                // TODO: Navigate to sign in screen in subtask 6.2
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Sign in flow - to be implemented'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
              icon: const Icon(Icons.login),
              label: const Text('Sign In'),
            ),
          ],
        ),
      ),
    );
  }

  /// Build filter menu item
  Widget _buildFilterMenuItem(
    BuildContext context,
    RecommendationFilter filter,
    String label,
    IconData icon,
  ) {
    final theme = Theme.of(context);
    final isSelected = _selectedFilter == filter;

    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: isSelected ? theme.colorScheme.primary : null,
        ),
        const SizedBox(width: 12),
        Text(
          label,
          style: TextStyle(
            color: isSelected ? theme.colorScheme.primary : null,
            fontWeight: isSelected ? FontWeight.bold : null,
          ),
        ),
        if (isSelected) ...[
          const Spacer(),
          Icon(
            Icons.check,
            size: 20,
            color: theme.colorScheme.primary,
          ),
        ],
      ],
    );
  }

  /// Get empty state message based on selected filter
  String _getEmptyStateMessage() {
    switch (_selectedFilter) {
      case RecommendationFilter.highMatch:
        return 'No high-match recommendations found. '
            'Try selecting "All Recommendations" to see more options.';
      case RecommendationFilter.hiddenGems:
        return 'No hidden gem recommendations found. '
            'Try selecting "All Recommendations" to see all options.';
      case RecommendationFilter.all:
      default:
        return 'We\'re still learning about your preferences. '
            'Explore more destinations to get better recommendations!';
    }
  }

  /// Format timestamp to relative time
  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 60) {
      final minutes = difference.inMinutes;
      return minutes == 0 ? 'just now' : '$minutes ${minutes == 1 ? 'minute' : 'minutes'} ago';
    } else if (difference.inHours < 24) {
      final hours = difference.inHours;
      return '$hours ${hours == 1 ? 'hour' : 'hours'} ago';
    } else if (difference.inDays < 7) {
      final days = difference.inDays;
      return '$days ${days == 1 ? 'day' : 'days'} ago';
    } else {
      return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
    }
  }
}

/// Filter options for recommendations
enum RecommendationFilter {
  /// Show all recommendations
  all,

  /// Show only high-match recommendations (>= 70%)
  highMatch,

  /// Show only hidden gem recommendations
  hiddenGems,
}

/// Card widget for displaying a single recommended destination
class _RecommendationCard extends StatelessWidget {
  final RecommendedDestination recommendedDestination;
  final bool isSaved;
  final VoidCallback onTap;
  final VoidCallback onBookmarkTap;

  const _RecommendationCard({
    required this.recommendedDestination,
    required this.isSaved,
    required this.onTap,
    required this.onBookmarkTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final destination = recommendedDestination.destination;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row with destination name and match score
              Row(
                children: [
                  Expanded(
                    child: Text(
                      destination.name,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  // Match score badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: _getMatchScoreColor().withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: _getMatchScoreColor(),
                        width: 1.5,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _getMatchScoreIcon(),
                          size: 16,
                          color: _getMatchScoreColor(),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${(recommendedDestination.matchScore * 100).toInt()}%',
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: _getMatchScoreColor(),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Hidden gem badge if applicable
              if (recommendedDestination.isHiddenGemMatch)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Icon(
                        Icons.diamond,
                        size: 16,
                        color: Colors.amber.shade700,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Hidden Gem',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: Colors.amber.shade700,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),

              // Reason for recommendation
              Text(
                recommendedDestination.reason,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontStyle: FontStyle.italic,
                ),
              ),
              const SizedBox(height: 12),

              // Matching factors
              if (recommendedDestination.matchingFactors.isNotEmpty) ...[
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: recommendedDestination.matchingFactors
                      .take(4)
                      .map((factor) => Chip(
                            label: Text(
                              factor,
                              style: theme.textTheme.labelSmall,
                            ),
                            backgroundColor:
                                theme.colorScheme.secondaryContainer,
                            padding: EdgeInsets.zero,
                            materialTapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
                          ))
                      .toList(),
                ),
                const SizedBox(height: 12),
              ],

              // Scores row
              Row(
                children: [
                  SafetyScoreBadge(
                    score: destination.safetyScore,
                    showLabel: true,
                  ),
                  const SizedBox(width: 12),
                  SoloSuitabilityBadge(
                    score: destination.soloSuitabilityScore,
                    showLabel: true,
                  ),
                  const Spacer(),
                  // Bookmark button
                  IconButton(
                    icon: Icon(
                      isSaved ? Icons.bookmark : Icons.bookmark_border,
                      color: isSaved
                          ? theme.colorScheme.primary
                          : theme.colorScheme.onSurfaceVariant,
                    ),
                    onPressed: onBookmarkTap,
                    tooltip: isSaved ? 'Remove from wishlist' : 'Save to wishlist',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Get color for match score
  Color _getMatchScoreColor() {
    final score = recommendedDestination.matchScore;
    if (score >= 0.8) return Colors.green;
    if (score >= 0.6) return Colors.orange;
    return Colors.red;
  }

  /// Get icon for match score
  IconData _getMatchScoreIcon() {
    final score = recommendedDestination.matchScore;
    if (score >= 0.8) return Icons.star;
    if (score >= 0.6) return Icons.thumb_up;
    return Icons.info_outline;
  }
}
