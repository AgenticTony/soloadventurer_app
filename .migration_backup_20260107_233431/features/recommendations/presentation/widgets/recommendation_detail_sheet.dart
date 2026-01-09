import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import 'package:soloadventurer/features/recommendations/domain/entities/recommendation.dart';

/// Bottom sheet showing recommendation details
class RecommendationDetailSheet extends StatelessWidget {
  final PersonalizedRecommendation recommendation;
  final String itineraryId;
  final VoidCallback onAdd;

  const RecommendationDetailSheet({
    required this.recommendation,
    required this.itineraryId,
    required this.onAdd,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: CustomScrollView(
            controller: scrollController,
            slivers: [
              // Header
              SliverAppBar(
                expandedHeight: 250,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(recommendation.activity.name),
                  background: recommendation.activity.images.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: recommendation.activity.images.first,
                          fit: BoxFit.cover,
                        )
                      : Container(
                          color: Theme.of(context).colorScheme.primaryContainer,
                          child: Icon(Icons.attractions, size: 64, color: Theme.of(context).colorScheme.primary),
                        ),
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.bookmark_outline),
                    onPressed: () {
                      // Save for later
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.share),
                    onPressed: () {
                      // Share
                    },
                  ),
                ],
              ),

              // Content
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Quick stats
                      _buildQuickStats(context),
                      const SizedBox(height: 16),

                      // Why recommended section
                      _buildWhyRecommendedSection(context),
                      const SizedBox(height: 16),

                      // About section
                      _buildAboutSection(context),
                      const SizedBox(height: 16),

                      // Local tips
                      _buildLocalTipsSection(context),
                      const SizedBox(height: 16),

                      // Availability
                      _buildAvailabilitySection(context),
                      const SizedBox(height: 24),

                      // Action buttons
                      _buildActionButtons(context),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildQuickStats(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.star, color: Colors.amber),
        const SizedBox(width: 4),
        Text(
          recommendation.activity.rating.toStringAsFixed(1),
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(width: 16),
        const Icon(Icons.place_outlined),
        const SizedBox(width: 4),
        Text(
          _getDistanceText(recommendation.metadata.distance),
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(width: 16),
        const Icon(Icons.schedule),
        const SizedBox(width: 4),
        Text(
          _formatDuration(recommendation.metadata.estimatedDuration),
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }

  Widget _buildWhyRecommendedSection(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.lightbulb, color: Colors.amber[700]),
                const SizedBox(width: 8),
                Text(
                  'Why we recommended this',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(recommendation.reasoning),
            const SizedBox(height: 12),

            // Score breakdown
            RecommendationScoreBreakdown(
              score: recommendation.relevanceScore,
              metadata: recommendation.metadata,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAboutSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'About',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        Text(
          recommendation.activity.description ?? 'No description available.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }

  Widget _buildLocalTipsSection(BuildContext context) {
    final tips = recommendation.activity.localTips;

    if (tips.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.forum, color: Colors.blue),
            const SizedBox(width: 8),
            Text(
              'Tips from locals',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...tips.map((tip) => Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Text('"$tip"', style: const TextStyle(fontStyle: FontStyle.italic)),
            ),
          ),
        )),
      ],
    );
  }

  Widget _buildAvailabilitySection(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Availability',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            // Show next 3 days
            for (int i = 0; i < 3; i++)
              ListTile(
                leading: const Icon(Icons.event),
                title: Text(
                  DateFormat.EEEE().format(
                    recommendation.metadata.suggestedDate.add(Duration(days: i)),
                  ),
                ),
                subtitle: Text(_getOpeningHours(recommendation)),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FilledButton.icon(
          onPressed: onAdd,
          icon: const Icon(Icons.add),
          label: const Text('Add to Itinerary'),
          style: FilledButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: () {
            // View on map
          },
          icon: const Icon(Icons.map),
          label: const Text('View on Map'),
        ),
      ],
    );
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;

    if (hours > 0 && minutes > 0) {
      return '${hours}h ${minutes}m';
    } else if (hours > 0) {
      return '${hours}h';
    } else {
      return '${minutes}m';
    }
  }

  String _getDistanceText(DistanceFromHotel distance) {
    switch (distance) {
      case DistanceFromHotel.walking:
        return 'Walking distance';
      case DistanceFromHotel.shortTrip:
        return 'Short trip';
      case DistanceFromHotel.mediumTrip:
        return 'Medium trip';
      case DistanceFromHotel.far:
        return 'Far';
    }
  }

  String _getOpeningHours(PersonalizedRecommendation recommendation) {
    return recommendation.activity.openingHours ?? 'Hours not available';
  }
}

/// Widget displaying the relevance score breakdown
class RecommendationScoreBreakdown extends StatelessWidget {
  final double score;
  final RecommendationMetadata metadata;

  const RecommendationScoreBreakdown({
    required this.score,
    required this.metadata,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Score: ${score.toInt()}/100',
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: 8),
        _buildScoreBar(
          context,
          'Interest Match',
          40,
          metadata.matchedInterests.isNotEmpty ? 40 : 0,
          Colors.blue,
        ),
        _buildScoreBar(
          context,
          'Weather Fit',
          25,
          _calculateWeatherScore(),
          Colors.green,
        ),
        _buildScoreBar(
          context,
          'User Rating',
          15,
          12,
          Colors.amber,
        ),
        _buildScoreBar(
          context,
          'Proximity',
          10,
          _calculateProximityScore(),
          Colors.purple,
        ),
      ],
    );
  }

  Widget _buildScoreBar(
    BuildContext context,
    String label,
    double maxScore,
    double actualScore,
    Color color,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              Text(
                '+${actualScore.toInt()} pts',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: color,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          LinearProgressIndicator(
            value: actualScore / maxScore,
            backgroundColor: color.withOpacity(0.2),
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ],
      ),
    );
  }

  double _calculateWeatherScore() {
    return metadata.weather == WeatherContext.indoor ? 25 : 15;
  }

  double _calculateProximityScore() {
    switch (metadata.distance) {
      case DistanceFromHotel.walking:
        return 10;
      case DistanceFromHotel.shortTrip:
        return 7;
      case DistanceFromHotel.mediumTrip:
        return 4;
      case DistanceFromHotel.far:
        return 0;
    }
  }
}
