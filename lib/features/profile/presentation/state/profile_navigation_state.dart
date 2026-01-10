/// State for profile navigation history
class ProfileNavigationState {
  /// List of routes in the navigation history
  final List<String> history;

  /// Creates a new [ProfileNavigationState]
  const ProfileNavigationState({
    this.history = const [],
  });

  /// Creates a copy of this state with the given values
  ProfileNavigationState copyWith({
    List<String>? history,
  }) {
    return ProfileNavigationState(
      history: history ?? this.history,
    );
  }
}
