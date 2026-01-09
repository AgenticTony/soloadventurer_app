import 'package:flutter/material.dart';
import 'package:soloadventurer/features/onboarding/domain/entities/travel_interest.dart';
import 'package:soloadventurer/features/recommendations/domain/entities/recommendation.dart';

/// Filter panel for recommendations
class RecommendationFilterPanel extends StatelessWidget {
  final RecommendationFilter filter;
  final ValueChanged<RecommendationFilter> onFilterChanged;

  const RecommendationFilterPanel({
    required this.filter,
    required this.onFilterChanged,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          bottom: BorderSide(color: Theme.of(context).dividerColor),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Filter & Sort',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              TextButton(
                onPressed: () =>
                    onFilterChanged(RecommendationFilter.defaultFilter()),
                child: const Text('Reset'),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Sort options
          SegmentedButton<RecommendationSort>(
            segments: const [
              ButtonSegment(
                value: RecommendationSort.bestMatch,
                label: Text('Best Match'),
              ),
              ButtonSegment(
                value: RecommendationSort.highestRated,
                label: Text('Top Rated'),
              ),
              ButtonSegment(
                value: RecommendationSort.closest,
                label: Text('Closest'),
              ),
            ],
            selected: {filter.sort},
            onSelectionChanged: (set) {
              onFilterChanged(filter.copyWith(sort: set.first));
            },
          ),
          const SizedBox(height: 16),

          // Interest filters
          const Text(
            'Categories',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: TravelInterest.values.map((interest) {
              final isSelected = filter.interests.contains(interest);
              return FilterChip(
                label: Text('${interest.emoji} ${interest.label}'),
                selected: isSelected,
                onSelected: (selected) {
                  final updated = Set<TravelInterest>.from(filter.interests);
                  if (selected) {
                    updated.add(interest);
                  } else {
                    updated.remove(interest);
                  }
                  onFilterChanged(filter.copyWith(interests: updated));
                },
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

/// Filter configuration for recommendations
class RecommendationFilter {
  final RecommendationSort sort;
  final Set<TravelInterest> interests;

  const RecommendationFilter({
    required this.sort,
    required this.interests,
  });

  factory RecommendationFilter.defaultFilter() {
    return RecommendationFilter(
      sort: RecommendationSort.bestMatch,
      interests: TravelInterest.values.toSet(),
    );
  }

  RecommendationFilter copyWith({
    RecommendationSort? sort,
    Set<TravelInterest>? interests,
  }) {
    return RecommendationFilter(
      sort: sort ?? this.sort,
      interests: interests ?? this.interests,
    );
  }

  /// Applies this filter to a list of recommendations
  List<PersonalizedRecommendation> apply(
      List<PersonalizedRecommendation> recommendations) {
    var filtered = recommendations;

    // Filter by interests
    if (interests.isNotEmpty) {
      filtered = filtered
          .where((r) => r.metadata.matchedInterests
              .any((interest) => interests.contains(interest)))
          .toList();
    }

    // Sort
    switch (sort) {
      case RecommendationSort.bestMatch:
        filtered.sort((a, b) => b.relevanceScore.compareTo(a.relevanceScore));
        break;
      case RecommendationSort.highestRated:
        filtered.sort((a, b) => b.activity.rating.compareTo(a.activity.rating));
        break;
      case RecommendationSort.closest:
        filtered.sort((a, b) => _distanceValue(a.metadata.distance)
            .compareTo(_distanceValue(b.metadata.distance)));
        break;
    }

    return filtered;
  }

  int _distanceValue(DistanceFromHotel distance) {
    switch (distance) {
      case DistanceFromHotel.walking:
        return 0;
      case DistanceFromHotel.shortTrip:
        return 1;
      case DistanceFromHotel.mediumTrip:
        return 2;
      case DistanceFromHotel.far:
        return 3;
    }
  }
}

/// Sort options for recommendations
enum RecommendationSort {
  bestMatch,
  highestRated,
  closest,
}
