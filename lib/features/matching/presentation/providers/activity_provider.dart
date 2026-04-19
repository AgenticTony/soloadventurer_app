import 'dart:async';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:soloadventurer/features/matching/domain/entities/activity.dart';
import 'matching_provider.dart';

part 'activity_provider.g.dart';

/// Provider for available activities
@Riverpod(keepAlive: true)
Future<List<Activity>> activities(Ref ref) async {
  final repository = ref.watch(matchingRepositoryProvider);
  return repository.getActivities();
}

/// Provider for user's selected activities
@Riverpod(keepAlive: true)
Future<List<Activity>> userActivities(Ref ref) async {
  final repository = ref.watch(matchingRepositoryProvider);
  return repository.getUserActivities();
}

/// Notifier for managing user activities
@Riverpod(keepAlive: true)
class UserActivityNotifier extends _$UserActivityNotifier {
  @override
  FutureOr<void> build() {
    return null;
  }

  /// Toggle an activity (add if not present, remove if present)
  Future<void> toggleActivity(String activityId) async {
    final currentActivities = await ref.read(userActivitiesProvider.future);
    final hasActivity = currentActivities.any((a) => a.id == activityId);

    final repository = ref.read(matchingRepositoryProvider);

    final result = await AsyncValue.guard(() async {
      if (hasActivity) {
        await repository.removeUserActivity(activityId);
      } else {
        await repository.addUserActivity(activityId);
      }

      ref.invalidate(userActivitiesProvider);
    });

    state = result;

    if (result.hasError) {
      throw result.error!;
    }
  }

  /// Set user's activities (replaces all existing)
  Future<void> setActivities(List<String> activityIds) async {
    final repository = ref.read(matchingRepositoryProvider);

    final result = await AsyncValue.guard(() async {
      await repository.setUserActivities(activityIds);
      ref.invalidate(userActivitiesProvider);
    });

    state = result;

    if (result.hasError) {
      throw result.error!;
    }
  }

  /// Add a single activity to user's interests
  Future<void> addActivity(String activityId) async {
    final repository = ref.read(matchingRepositoryProvider);

    final result = await AsyncValue.guard(() async {
      await repository.addUserActivity(activityId);
      ref.invalidate(userActivitiesProvider);
    });

    state = result;

    if (result.hasError) {
      throw result.error!;
    }
  }

  /// Remove a single activity from user's interests
  Future<void> removeActivity(String activityId) async {
    final repository = ref.read(matchingRepositoryProvider);

    final result = await AsyncValue.guard(() async {
      await repository.removeUserActivity(activityId);
      ref.invalidate(userActivitiesProvider);
    });

    state = result;

    if (result.hasError) {
      throw result.error!;
    }
  }
}
