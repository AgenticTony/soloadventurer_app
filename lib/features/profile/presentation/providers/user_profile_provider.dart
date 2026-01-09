import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../features/auth/domain/models/user.dart';
import '../../../../features/core/infrastructure/api/api_service.dart';
import '../../../../features/core/infrastructure/api/dio_api_service.dart';

/// Provider for the API service
///
/// Uses `autoDispose` to allow cleanup when no longer needed.
/// This prevents memory leaks from unused API service instances.
final apiServiceProvider = Provider.autoDispose<ApiService>((ref) {
  final apiService = DioApiService();

  // Ensure cleanup if ApiService has disposable resources
  ref.onDispose(() {
    // ApiService cleanup (if needed)
  });

  return apiService;
});

/// Provider for user repository
///
/// Uses `autoDispose` to prevent memory leaks when user profiles
/// are no longer being accessed.
final userRepositoryProvider = Provider.autoDispose<UserRepository>((ref) {
  final apiService = ref.read(apiServiceProvider);
  return UserRepository(apiService);
});

/// User repository class
///
/// Handles fetching and updating user profile data.
/// This is a simplified example - in production, you would use
/// a proper repository implementation with domain layer separation.
class UserRepository {
  final ApiService _apiService;

  UserRepository(this._apiService);

  Future<User> getUserProfile(String userId) async {
    try {
      final response = await _apiService.get('/users/$userId');
      return User.fromJson(response);
    } catch (e) {
      throw Exception('Failed to load user profile: $e');
    }
  }

  Future<User> updateUserProfile(
      String userId, Map<String, dynamic> data) async {
    try {
      final response = await _apiService.put('/users/$userId', data: data);
      return User.fromJson(response);
    } catch (e) {
      throw Exception('Failed to update user profile: $e');
    }
  }
}

/// Provider for user profile
///
/// OPTIMIZED: Uses `autoDispose` to clean up cached profiles
/// when they are no longer needed. This prevents memory leaks
/// when viewing many different user profiles.
///
/// For frequently accessed profiles, consider using `keepAlive()`:
/// ```dart
/// ref.keepAlive();
/// ```
final userProfileProvider =
    FutureProvider.autoDispose.family<User, String>((ref, userId) async {
  final userRepository = ref.read(userRepositoryProvider);
  return userRepository.getUserProfile(userId);
});

// Notifier for updating user profile
class UserProfileNotifier extends StateNotifier<AsyncValue<User?>> {
  final UserRepository _userRepository;
  final String userId;

  UserProfileNotifier(this._userRepository, this.userId)
      : super(const AsyncValue.data(null));

  /// Load user profile
  ///
  /// OPTIMIZED: Added mounted checks to prevent state updates
  /// after the notifier has been disposed.
  Future<void> loadProfile() async {
    if (!mounted) return;

    state = const AsyncValue.loading();

    try {
      final user = await _userRepository.getUserProfile(userId);

      if (!mounted) return;
      state = AsyncValue.data(user);
    } catch (e, stack) {
      if (!mounted) return;
      state = AsyncValue.error(e, stack);
    }
  }

  /// Update user profile
  ///
  /// OPTIMIZED: Added mounted checks to prevent state updates
  /// after the notifier has been disposed.
  Future<void> updateProfile(Map<String, dynamic> data) async {
    if (!mounted) return;

    state = const AsyncValue.loading();

    try {
      final updatedUser = await _userRepository.updateUserProfile(userId, data);

      if (!mounted) return;
      state = AsyncValue.data(updatedUser);
    } catch (e, stack) {
      if (!mounted) return;
      state = AsyncValue.error(e, stack);
    }
  }
}

/// Provider for the user profile notifier
///
/// OPTIMIZED:
/// 1. Uses `autoDispose` to clean up notifiers when no longer needed
/// 2. Uses `ref.read` instead of `ref.watch` to avoid unnecessary subscriptions
/// 3. Added `ref.onDispose()` for proper cleanup
final userProfileNotifierProvider = StateNotifierProvider.autoDispose
    .family<UserProfileNotifier, AsyncValue<User?>, String>(
  (ref, userId) {
    final userRepository = ref.read(userRepositoryProvider);
    final notifier = UserProfileNotifier(userRepository, userId);

    // Ensure cleanup when provider is disposed
    ref.onDispose(() {
      // Cleanup notifier resources if needed
    });

    return notifier;
  },
);

/// Selector provider for user profile loading state
///
/// OPTIMIZED: Using `select` prevents unnecessary rebuilds when
/// other profile state fields change.
final userProfileLoadingProvider =
    Provider.autoDispose.family<bool, String>((ref, userId) {
  return ref.watch(
    userProfileNotifierProvider(userId).select((state) => state.isLoading),
  );
});

/// Selector provider for user profile error state
///
/// OPTIMIZED: Using `select` prevents unnecessary rebuilds when
/// other profile state fields change.
final userProfileErrorProvider =
    Provider.autoDispose.family<String?, String>((ref, userId) {
  return ref.watch(
    userProfileNotifierProvider(userId).select(
      (state) => state.hasError ? state.toString() : null,
    ),
  );
});

