import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../data/datasources/follow_remote_data_source.dart';
import '../data/repositories/follow_repository_impl.dart';
import '../domain/entities/follow.dart';
import '../domain/repositories/follow_repository.dart';
import '../domain/usecases/accept_follow_usecase.dart';
import '../domain/usecases/decline_follow_usecase.dart';
import '../domain/usecases/follow_user_usecase.dart';
import '../domain/usecases/get_followers_usecase.dart';
import '../domain/usecases/get_following_usecase.dart';
import '../domain/usecases/get_pending_requests_usecase.dart';
import '../domain/usecases/is_following_usecase.dart';
import '../domain/usecases/unfollow_user_usecase.dart';

part 'follow_providers.g.dart';

// ============================================================
// Data Source
// ============================================================

/// Provides the follow remote data source backed by Supabase
@Riverpod(keepAlive: true)
FollowRemoteDataSource followRemoteDataSource(Ref ref) {
  return FollowRemoteDataSourceImpl(client: Supabase.instance.client);
}

// ============================================================
// Repository
// ============================================================

/// Provides the follow repository implementation
@Riverpod(keepAlive: true)
FollowRepository followRepository(Ref ref) {
  return FollowRepositoryImpl(
    remoteDataSource: ref.read(followRemoteDataSourceProvider),
  );
}

// ============================================================
// Use Cases
// ============================================================

/// Provides the follow user use case
@riverpod
FollowUserUseCase followUserUseCase(Ref ref) =>
    FollowUserUseCase(ref.read(followRepositoryProvider));

/// Provides the unfollow user use case
@riverpod
UnfollowUserUseCase unfollowUserUseCase(Ref ref) =>
    UnfollowUserUseCase(ref.read(followRepositoryProvider));

/// Provides the accept follow use case
@riverpod
AcceptFollowUseCase acceptFollowUseCase(Ref ref) =>
    AcceptFollowUseCase(ref.read(followRepositoryProvider));

/// Provides the decline follow use case
@riverpod
DeclineFollowUseCase declineFollowUseCase(Ref ref) =>
    DeclineFollowUseCase(ref.read(followRepositoryProvider));

/// Provides the get followers use case
@riverpod
GetFollowersUseCase getFollowersUseCase(Ref ref) =>
    GetFollowersUseCase(ref.read(followRepositoryProvider));

/// Provides the get following use case
@riverpod
GetFollowingUseCase getFollowingUseCase(Ref ref) =>
    GetFollowingUseCase(ref.read(followRepositoryProvider));

/// Provides the get pending requests use case
@riverpod
GetPendingRequestsUseCase getPendingRequestsUseCase(Ref ref) =>
    GetPendingRequestsUseCase(ref.read(followRepositoryProvider));

/// Provides the is-following use case
@riverpod
IsFollowingUseCase isFollowingUseCase(Ref ref) =>
    IsFollowingUseCase(ref.read(followRepositoryProvider));

// ============================================================
// Async Notifiers
// ============================================================

/// AsyncNotifier that tracks the follow status for a specific target user.
///
/// Usage: `ref.watch(followStatusProvider(targetId))`
@riverpod
class FollowStatusNotifier extends _$FollowStatusNotifier {
  @override
  Future<bool> build(String targetUserId) async {
    final useCase = ref.read(isFollowingUseCaseProvider);
    return useCase(targetUserId);
  }

  /// Follow the target user
  Future<void> follow() async {
    final useCase = ref.read(followUserUseCaseProvider);
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await useCase(targetUserId);
      return true;
    });
  }

  /// Unfollow the target user
  Future<void> unfollow() async {
    final useCase = ref.read(unfollowUserUseCaseProvider);
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await useCase(targetUserId);
      return false;
    });
  }
}

// ============================================================
// Query Providers
// ============================================================

/// Provides the list of pending follow requests for the current user
@riverpod
Future<List<Follow>> pendingFollowRequests(Ref ref) async {
  final useCase = ref.read(getPendingRequestsUseCaseProvider);
  return useCase();
}

/// Provides the follower count for a specific user
@riverpod
Future<int> followerCount(Ref ref, String userId) async {
  final repository = ref.read(followRepositoryProvider);
  final followers = await repository.getFollowers(userId);
  return followers.length;
}

/// Provides the following count for a specific user
@riverpod
Future<int> followingCount(Ref ref, String userId) async {
  final repository = ref.read(followRepositoryProvider);
  final following = await repository.getFollowing(userId);
  return following.length;
}
