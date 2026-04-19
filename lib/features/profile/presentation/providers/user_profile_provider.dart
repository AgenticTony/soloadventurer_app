import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../features/auth/domain/entities/user.dart';
import '../../../../features/core/infrastructure/api/api_service.dart';
import '../../../../features/core/infrastructure/api/dio_api_service.dart';

part 'user_profile_provider.g.dart';

/// Riverpod 3.0 Migration Notes:
/// - Converted from `StateNotifier<AsyncValue<User?>>` to `AsyncNotifier<User?>`
/// - Dependencies injected via ref.watch() in build() method
/// - Family provider with userId parameter in build()
/// - AutoDispose enabled via @Riverpod annotation
/// - build() returns `Future<User?>` not AsyncValue
/// - State is automatically `AsyncValue<User?>` when consumed

/// Provider for the API service
@riverpod
ApiService apiService(Ref ref) {
  final apiService = DioApiService();
  ref.onDispose(() {
    // ApiService cleanup (if needed)
  });
  return apiService;
}

/// User repository class
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

/// Provider for user repository
@riverpod
UserRepository userRepository(Ref ref) {
  final apiService = ref.watch(apiServiceProvider);
  return UserRepository(apiService);
}

/// Notifier for updating user profile
///
/// Riverpod 3.0: Uses @riverpod annotation with AsyncNotifier pattern.
/// Family provider with userId parameter.
/// Auto-dispose behavior enabled.
@riverpod
class UserProfile extends _$UserProfile {
  @override
  Future<User?> build(String userId) async {
    final userRepository = ref.watch(userRepositoryProvider);
    return userRepository.getUserProfile(userId);
  }

  Future<void> loadProfile() async {
    final userRepository = ref.read(userRepositoryProvider);
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      return userRepository.getUserProfile(userId);
    });
  }

  Future<void> updateProfile(Map<String, dynamic> data) async {
    final userRepository = ref.read(userRepositoryProvider);
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      return userRepository.updateUserProfile(userId, data);
    });
  }
}

/// Selector provider for user profile loading state
@riverpod
bool userProfileLoading(Ref ref, String userId) {
  return ref.watch(userProfileProvider(userId)).isLoading;
}

/// Selector provider for user profile error state
@riverpod
String? userProfileError(Ref ref, String userId) {
  final state = ref.watch(userProfileProvider(userId));
  return state.hasError ? state.toString() : null;
}
