import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:soloadventurer/features/matching/domain/repositories/matching_repository.dart';

import 'unified_discovery_provider.dart';

part 'activity_selection_provider.g.dart';

/// Manages saving user activity selections from destination discovery
/// to the matching system's user_activities table.
///
/// When a user picks interests from the discovery screen (Google Places or
/// Viator), this provider persists them so the matching algorithm can use
/// activity overlap for scoring.
@riverpod
class ActivitySelection extends _$ActivitySelection {
  @override
  Set<String> build() {
    return {};
  }

  /// Toggle selection of a place/activity.
  ///
  /// Saves to the matching repository immediately if available.
  void toggleSelection(UnifiedPlaceResult result) {
    final activityId = result.activity.id;

    if (state.contains(activityId)) {
      state = state.difference({activityId});
    } else {
      state = state.union({activityId});
      _saveToMatching(activityId);
    }
  }

  /// Check if an activity is selected.
  bool isSelected(String activityId) => state.contains(activityId);

  /// Clear all selections.
  void clearSelections() {
    state = {};
  }

  /// Get the count of selected activities.
  int get count => state.length;

  void _saveToMatching(String activityId) {
    // The matching repository is wired in the matching feature's DI.
    // This calls addUserActivity to store the selection for matching.
    try {
      // We access the matching repository through the ref if it's been
      // overridden in the DI container.
      ref.read(matchingRepositoryBridgeProvider)?.addUserActivity(activityId);
    } catch (_) {
      // Matching repository may not be wired yet — that's OK.
      // The selection is still tracked locally in this provider's state.
    }
  }
}

/// Bridge provider for the matching repository.
///
/// In production, the matching module overrides this with its actual
/// implementation. Returns null if not overridden (selections are tracked
/// locally only).
@Riverpod(keepAlive: true)
MatchingRepository? matchingRepositoryBridge(Ref ref) {
  return null;
}
