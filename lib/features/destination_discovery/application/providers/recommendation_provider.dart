import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/models/personalized_recommendation.dart';
import '../state/recommendation_state.dart';
import 'destination_repository_provider.dart';

part 'recommendation_provider.g.dart';

/// Riverpod 3.0 Migration Notes:
/// - Converted from `StateNotifier<AsyncValue<T>>` to `AsyncNotifier<T>`
/// - Dependencies injected via ref.watch() in build() method
/// - Family provider with userId parameter in build()
/// - AutoDispose enabled via @Riverpod annotation
/// - build() returns `Future<T>` not `AsyncValue<T>`
/// - State is automatically `AsyncValue<RecommendationState>` when consumed
/// - Constructor auto-load logic moved to build() method
///
/// Provider for personalized recommendations state management
///
/// This provider manages the state of personalized destination recommendations including:
/// - Recommendation data with match scores and reasons
/// - Loading and error states
/// - Expiration checking and auto-refresh
///
/// Riverpod 3.0: Uses @riverpod annotation with AsyncNotifier pattern.
/// Auto-dispose behavior for family provider.
///
/// Usage:
/// ```dart
/// final recommendationState = ref.watch(recommendationProvider(userId));
/// final recommendationNotifier = ref.read(recommendationProvider(userId).notifier);
///
/// // Load recommendations (automatically called on first watch)
/// // The userId is passed as a parameter to the provider
///
/// // Refresh recommendations
/// await recommendationNotifier.refresh();
///
/// // Clear recommendations
/// recommendationNotifier.clear();
/// ```
///
/// The [userId] parameter is the user ID to load recommendations for.
@riverpod
class Recommendation extends _$Recommendation {
  /// Initialize the notifier and auto-load recommendations
  ///
  /// Riverpod 3.0: build() returns `Future<RecommendationState>`
  /// Family provider parameter (userId) is passed here
  /// AutoDispose behavior: provider will be disposed when no longer watched
  @override
  Future<RecommendationState> build(String userId) async {
    // Get dependencies via ref.watch()
    final repository = ref.watch(destinationRepositoryProvider);

    // Auto-load recommendations on build
    final recommendation =
        await repository.getPersonalizedRecommendations(userId);

    return RecommendationState(
      recommendation: recommendation,
    );
  }

  /// Refresh the recommendations
  ///
  /// This method reloads recommendations from the repository.
  /// Useful for pull-to-refresh functionality or ensuring fresh data.
  ///
  /// Throws an exception if refreshing fails.
  Future<void> refresh() async {
    // Get userId and repository
    final currentState = state.value;
    if (currentState == null) {
      return;
    }

    final userId = currentState.recommendation?.userId ?? '';
    final repository = ref.read(destinationRepositoryProvider);

    // Set loading state
    state = const AsyncValue.loading();

    // Load recommendations
    state = await AsyncValue.guard(() async {
      final recommendation =
          await repository.getPersonalizedRecommendations(userId);

      return RecommendationState(
        recommendation: recommendation,
      );
    });
  }

  /// Refresh recommendations only if they have expired
  ///
  /// This method checks if the current recommendations have expired
  /// and only refreshes if needed. Useful for optimizing unnecessary API calls.
  ///
  /// Returns true if recommendations were refreshed, false if they're still valid.
  /// Throws an exception if refreshing fails.
  Future<bool> refreshIfExpired() async {
    // Guard against loading if not in success state
    if (!state.hasValue) {
      return false;
    }

    final currentState = state.value!;

    // Check if recommendations have expired
    if (currentState.isExpired) {
      await refresh();
      return true;
    }

    return false;
  }

  /// Clear the recommendation state
  ///
  /// This method resets the state to initial, clearing all data.
  /// This is useful for cleanup or when the user logs out.
  void clear() {
    state = const AsyncValue.data(RecommendationState.initial());
  }

  /// Get high-match recommendations (score >= 0.7)
  ///
  /// Returns a list of recommendations with match score of 0.7 or higher.
  /// Returns an empty list if no recommendations are loaded or if loading failed.
  List<RecommendedDestination> get highMatchRecommendations {
    if (!state.hasValue) {
      return const [];
    }

    return state.value!.highMatchRecommendations;
  }

  /// Get hidden gem recommendations
  ///
  /// Returns a list of recommendations marked as hidden gems.
  /// Returns an empty list if no recommendations are loaded or if loading failed.
  List<RecommendedDestination> get hiddenGemRecommendations {
    if (!state.hasValue) {
      return const [];
    }

    return state.value!.hiddenGemRecommendations;
  }

  /// Get recommendations sorted by match score
  ///
  /// Returns a list of recommendations sorted by match score in descending order.
  /// Returns an empty list if no recommendations are loaded or if loading failed.
  List<RecommendedDestination> get sortedRecommendations {
    if (!state.hasValue) {
      return const [];
    }

    return state.value!.sortedByMatchScore;
  }

  /// Check if recommendations are expired
  ///
  /// Returns true if the current recommendations have expired and should be refreshed.
  /// Returns false if recommendations are still valid or if no recommendations are loaded.
  bool get isExpired {
    if (!state.hasValue) {
      return false;
    }

    return state.value!.isExpired;
  }

  /// Check if recommendations are valid
  ///
  /// Returns true if the current recommendations are still valid (not expired).
  /// Returns false if recommendations have expired or if no recommendations are loaded.
  bool get isValid {
    if (!state.hasValue) {
      return false;
    }

    return state.value!.isValid;
  }

  /// Get the recommendation summary
  ///
  /// Returns the summary text explaining why these destinations were recommended.
  /// Returns null if no recommendations are loaded.
  String? get summary {
    if (!state.hasValue) {
      return null;
    }

    return state.value!.recommendation?.summary;
  }

  /// Get the recommendation source
  ///
  /// Returns the source/method used to generate these recommendations.
  /// Returns null if no recommendations are loaded.
  RecommendationSource? get source {
    if (!state.hasValue) {
      return null;
    }

    return state.value!.recommendation?.source;
  }

  /// Get the total count of available recommendations
  ///
  /// Returns the total count, which may be greater than the loaded recommendations
  /// for pagination purposes. Returns 0 if no recommendations are loaded.
  int get totalCount {
    if (!state.hasValue) {
      return 0;
    }

    return state.value!.recommendation?.totalCount ?? 0;
  }
}
