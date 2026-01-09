import '../../domain/models/personalized_recommendation.dart';

/// State class for personalized recommendations
class RecommendationState {
  /// The personalized recommendations data
  final PersonalizedRecommendation? recommendation;

  /// Whether this is the initial state (no data loaded yet)
  final bool isInitial;

  /// Creates an initial recommendation state
  const RecommendationState.initial()
      : recommendation = null,
        isInitial = true;

  /// Creates a recommendation state with the given fields
  const RecommendationState({
    required this.recommendation,
    this.isInitial = false,
  });

  /// Creates a copy of this state with the given fields replaced
  RecommendationState copyWith({
    PersonalizedRecommendation? recommendation,
    bool? isInitial,
  }) {
    return RecommendationState(
      recommendation: recommendation ?? this.recommendation,
      isInitial: isInitial ?? this.isInitial,
    );
  }

  /// Returns true if no recommendation has been loaded
  bool get isEmpty => recommendation == null && !isInitial;

  /// Returns true if a recommendation has been loaded
  bool get hasRecommendation => recommendation != null;

  /// Returns true if the recommendation has expired
  bool get isExpired => recommendation?.isExpired ?? false;

  /// Returns true if the recommendation is still valid
  bool get isValid => recommendation?.isValid ?? false;

  /// Returns the list of recommended destinations
  List<RecommendedDestination> get recommendations =>
      recommendation?.recommendations ?? [];

  /// Returns the number of recommendations
  int get recommendationCount => recommendations.length;

  /// Returns high-match recommendations (score >= 0.7)
  List<RecommendedDestination> get highMatchRecommendations =>
      recommendation?.highMatchRecommendations ?? [];

  /// Returns hidden gem recommendations
  List<RecommendedDestination> get hiddenGemRecommendations =>
      recommendation?.hiddenGemRecommendations ?? [];

  /// Returns recommendations sorted by match score
  List<RecommendedDestination> get sortedByMatchScore =>
      recommendation?.sortedByMatchScore ?? [];
}
