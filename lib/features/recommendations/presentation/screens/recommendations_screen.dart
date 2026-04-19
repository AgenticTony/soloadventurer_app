import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:soloadventurer/features/auth/presentation/providers/auth_notifier_provider.dart';
import 'package:soloadventurer/features/onboarding/domain/entities/date_range.dart';
import 'package:soloadventurer/features/recommendations/domain/entities/recommendation.dart';
import 'package:soloadventurer/features/recommendations/domain/entities/recommendation_request.dart';
import 'package:soloadventurer/features/recommendations/presentation/providers/recommendation_providers.dart';
import 'package:soloadventurer/features/recommendations/presentation/widgets/recommendation_card.dart';
import 'package:soloadventurer/features/recommendations/presentation/widgets/recommendation_detail_sheet.dart';
import 'package:soloadventurer/features/recommendations/presentation/widgets/recommendation_filter_panel.dart';
import 'package:soloadventurer/features/recommendations/presentation/widgets/schedule_recommendation_sheet.dart';
import 'package:soloadventurer/features/travel/domain/models/itinerary.dart';

/// Screen for browsing personalized recommendations
///
/// Displays AI-powered recommendations based on user interests,
/// trip context, and real-time conditions like weather.
class RecommendationsScreen extends ConsumerStatefulWidget {
  final String itineraryId;

  const RecommendationsScreen({
    required this.itineraryId,
    super.key,
  });

  @override
  ConsumerState<RecommendationsScreen> createState() =>
      _RecommendationsScreenState();
}

class _RecommendationsScreenState extends ConsumerState<RecommendationsScreen> {
  RecommendationFilter _filter = RecommendationFilter.defaultFilter();
  bool _showFilters = false;

  @override
  void initState() {
    super.initState();
    // Load recommendations immediately
    Future.microtask(() => ref
        .invalidate(recommendationsForItineraryProvider(widget.itineraryId)));
  }

  @override
  Widget build(BuildContext context) {
    final recommendationsAsync = ref.watch(
      recommendationsForItineraryProvider(widget.itineraryId),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('✨ Recommendations'),
        actions: [
          IconButton(
            icon:
                Icon(_showFilters ? Icons.filter_list_off : Icons.filter_list),
            onPressed: () {
              setState(() => _showFilters = !_showFilters);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          if (_showFilters)
            RecommendationFilterPanel(
              filter: _filter,
              onFilterChanged: (newFilter) {
                setState(() => _filter = newFilter);
              },
            ),

          // Context header
          _buildContextHeader(),

          // Recommendations list
          Expanded(
            child: switch (recommendationsAsync) {
              AsyncData(:final value) => value.isEmpty
                  ? _buildEmptyState()
                  : _filter.apply(value).isEmpty
                      ? _buildNoResultsState()
                      : _buildRecommendationsList(_filter.apply(value)),
              AsyncLoading() => const Center(
                  child: CircularProgressIndicator(),
                ),
              AsyncError(:final error) => _buildErrorState(error),
            },
          ),
        ],
      ),
    );
  }

  Widget _buildContextHeader() {
    final itineraryAsync = ref.watch(
      itineraryProvider(widget.itineraryId),
    );

    return Container(
      padding: const EdgeInsets.all(16),
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: switch (itineraryAsync) {
        AsyncData(:final value) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'For your ${value.destination.name} trip',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 4),
              Text(
                _formatDateRange(value.dateRange),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[700],
                    ),
              ),
            ],
          ),
        _ => const SizedBox.shrink(),
      },
    );
  }

  Widget _buildRecommendationsList(
      List<PersonalizedRecommendation> recommendations) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: recommendations.length,
      itemBuilder: (context, index) {
        final recommendation = recommendations[index];
        return RecommendationCard(
          recommendation: recommendation,
          onTap: () => _showRecommendationDetail(context, recommendation),
          onAdd: () => _addToItinerary(context, recommendation),
          onSave: () => _saveRecommendation(context, recommendation),
          onDismiss: () => _dismissRecommendation(context, recommendation),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.lightbulb_outline, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No recommendations yet',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              'Complete your onboarding to get personalized suggestions',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoResultsState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No matches for your filters',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your filter criteria',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(Object error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.red[400]),
          const SizedBox(height: 16),
          Text(
            'Unable to load recommendations',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            error.toString(),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _showRecommendationDetail(
    BuildContext context,
    PersonalizedRecommendation recommendation,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => RecommendationDetailSheet(
        recommendation: recommendation,
        itineraryId: widget.itineraryId,
        onAdd: () => _addToItinerary(context, recommendation),
      ),
    );
  }

  Future<void> _addToItinerary(
    BuildContext context,
    PersonalizedRecommendation recommendation,
  ) async {
    // Show date/time picker
    final scheduledAt = await showModalBottomSheet<DateTime>(
      context: context,
      builder: (context) => ScheduleRecommendationSheet(
        recommendation: recommendation,
      ),
    );

    if (scheduledAt == null) return;

    final useCase = ref.read(addRecommendationToItineraryProvider);
    final result = await useCase(
      itineraryId: widget.itineraryId,
      recommendation: recommendation,
      scheduledAt: scheduledAt,
    );

    result.fold(
      (failure) => _showError(context, failure.toString()),
      (_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Added to your itinerary!')),
        );
        ref.invalidate(itineraryProvider(widget.itineraryId));
      },
    );
  }

  Future<void> _saveRecommendation(
    BuildContext context,
    PersonalizedRecommendation recommendation,
  ) async {
    // Get current user from auth state
    final authState = ref.read(authProvider).value;
    final user = authState?.user;

    if (user == null) {
      _showError(context, 'Please sign in to save recommendations');
      return;
    }

    // Get the use case and call it with parameters
    final useCase = ref.read(saveRecommendationProvider);
    final result = await useCase(user.id, recommendation);

    result.fold(
      (failure) => _showError(context, failure.toString()),
      (_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Saved for later')),
        );
      },
    );
  }

  Future<void> _dismissRecommendation(
    BuildContext context,
    PersonalizedRecommendation recommendation,
  ) async {
    // Get current user from auth state
    final authState = ref.read(authProvider).value;
    final user = authState?.user;

    if (user == null) {
      _showError(context, 'Please sign in to dismiss recommendations');
      return;
    }

    // Get the use case and call it with parameters
    final useCase = ref.read(dismissRecommendationProvider);
    final result = await useCase(user.id, recommendation.id);

    result.fold(
      (failure) => _showError(context, failure.toString()),
      (_) {
        ref.invalidate(recommendationsForItineraryProvider(widget.itineraryId));
      },
    );
  }

  void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  String _formatDateRange(DateRange range) {
    return '${DateFormat.MMMd().format(range.start)} - '
        '${DateFormat.MMMd().format(range.end)}';
  }
}

/// Provider for recommendations for a specific itinerary
final recommendationsForItineraryProvider =
    FutureProvider.family<List<PersonalizedRecommendation>, String>(
        (ref, itineraryId) async {
  final itinerary = await ref.watch(itineraryProvider(itineraryId).future);

  final request = RecommendationRequest(
    itineraryId: itineraryId,
    destination: itinerary.destination,
    tripDates: itinerary.dateRange,
    interests: {}, // Get from user profile
    limit: 20,
    excludeItineraryItems: true,
  );

  final useCase = ref.watch(getPersonalizedRecommendationsProvider);
  final result = await useCase(request);

  return result.fold(
    (failure) => throw Exception(failure.toString()),
    (recommendations) => recommendations,
  );
});

/// Provider for getting an itinerary
final itineraryProvider = FutureProvider.family<Itinerary, String>(
    (ref, itineraryId) async {
  // In production, would fetch from actual repository
  throw UnimplementedError('Implement itinerary provider');
});
