import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import 'package:soloadventurer/features/recommendations/domain/entities/recommendation.dart';

/// Card widget for displaying a recommendation
class RecommendationCard extends StatelessWidget {
  final PersonalizedRecommendation recommendation;
  final VoidCallback onTap;
  final VoidCallback onAdd;
  final VoidCallback onSave;
  final VoidCallback onDismiss;

  const RecommendationCard({
    required this.recommendation,
    required this.onTap,
    required this.onAdd,
    required this.onSave,
    required this.onDismiss,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            if (recommendation.activity.images.isNotEmpty)
              CachedNetworkImage(
                imageUrl: recommendation.activity.images.first,
                height: 180,
                width: double.infinity,
                fit: BoxFit.cover,
                placeholder: (_, __) => Container(
                  height: 180,
                  color: Colors.grey[200],
                  child: const Center(child: CircularProgressIndicator()),
                ),
                errorWidget: (_, __, ___) => Container(
                  height: 180,
                  color: Colors.grey[200],
                  child: Icon(Icons.broken_image, size: 48, color: Colors.grey[400]),
                ),
              ),

            // Content
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title and rating
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          recommendation.activity.name,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: _getScoreColor(recommendation.relevanceScore),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${recommendation.relevanceScore.toInt()}% match',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Rating and reviews
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        recommendation.activity.rating.toStringAsFixed(1),
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '(${_formatCount(recommendation.activity.reviewCount)} reviews)',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey[600],
                            ),
                      ),
                      const Spacer(),
                      if (recommendation.metadata.requiresAdvanceBooking)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.orange[100],
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'Book ahead',
                            style: TextStyle(
                              color: Colors.orange[800],
                              fontSize: 11,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Reasoning
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.lightbulb_outline, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            recommendation.reasoning,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Metadata chips
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildMetadataChip(
                        context,
                        Icons.calendar_today,
                        DateFormat.MMMd().format(recommendation.metadata.suggestedDate),
                      ),
                      _buildMetadataChip(
                        context,
                        _getDistanceIcon(recommendation.metadata.distance),
                        _getDistanceText(recommendation.metadata.distance),
                      ),
                      _buildMetadataChip(
                        context,
                        _getWeatherIcon(recommendation.metadata.weather),
                        _getWeatherText(recommendation.metadata.weather),
                      ),
                      if (recommendation.metadata.estimatedDuration != Duration.zero)
                        _buildMetadataChip(
                          context,
                          Icons.schedule,
                          _formatDuration(recommendation.metadata.estimatedDuration),
                        ),
                    ],
                  ),

                  // Actions
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: onAdd,
                          icon: const Icon(Icons.add),
                          label: const Text('Add to Itinerary'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton.outlined(
                        onPressed: onSave,
                        icon: const Icon(Icons.bookmark_outline),
                      ),
                      IconButton.outlined(
                        onPressed: onDismiss,
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetadataChip(BuildContext context, IconData icon, String text) {
    return Chip(
      avatar: Icon(icon, size: 16),
      label: Text(text),
      visualDensity: VisualDensity.compact,
    );
  }

  Color _getScoreColor(double score) {
    if (score >= 80) return Colors.green;
    if (score >= 60) return Colors.blue;
    if (score >= 40) return Colors.orange;
    return Colors.grey;
  }

  IconData _getDistanceIcon(DistanceFromHotel distance) {
    switch (distance) {
      case DistanceFromHotel.walking:
        return Icons.directions_walk;
      case DistanceFromHotel.shortTrip:
        return Icons.directions_transit;
      case DistanceFromHotel.mediumTrip:
        return Icons.directions_car;
      case DistanceFromHotel.far:
        return Icons.flight;
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

  IconData _getWeatherIcon(WeatherContext weather) {
    switch (weather) {
      case WeatherContext.indoor:
        return Icons.home;
      case WeatherContext.outdoor:
        return Icons.wb_sunny;
      case WeatherContext.anyWeather:
        return Icons.cloud;
      case WeatherContext.weatherDependent:
        return Icons.cloud_queue;
    }
  }

  String _getWeatherText(WeatherContext weather) {
    switch (weather) {
      case WeatherContext.indoor:
        return 'Indoor';
      case WeatherContext.outdoor:
        return 'Outdoor';
      case WeatherContext.anyWeather:
        return 'Any weather';
      case WeatherContext.weatherDependent:
        return 'Weather dependent';
    }
  }

  String _formatCount(int count) {
    if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}k';
    }
    return count.toString();
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
}
