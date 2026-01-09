import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../features/auth/domain/models/user.dart';
import '../../../../features/core/infrastructure/api/api_service.dart';
import '../../../../features/core/infrastructure/api/dio_api_service.dart';

// Provider for the API service
final apiServiceProvider = Provider<ApiService>((ref) {
  return DioApiService();
});

// Provider for user repository
final userRepositoryProvider = Provider<UserRepository>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  return UserRepository(apiService);
});

// User repository class
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

// Provider for user profile
final userProfileProvider =
    FutureProvider.family<User, String>((ref, userId) async {
  final userRepository = ref.watch(userRepositoryProvider);
  return userRepository.getUserProfile(userId);
});

// Notifier for updating user profile
class UserProfileNotifier extends StateNotifier<AsyncValue<User?>> {
  final UserRepository _userRepository;
  final String userId;

  UserProfileNotifier(this._userRepository, this.userId)
      : super(const AsyncValue.loading()) {
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    state = const AsyncValue.loading();
    try {
      final user = await _userRepository.getUserProfile(userId);
      state = AsyncValue.data(user);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> updateProfile(Map<String, dynamic> data) async {
    try {
      state = const AsyncValue.loading();
      final updatedUser = await _userRepository.updateUserProfile(userId, data);
      state = AsyncValue.data(updatedUser);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}

// Provider for the user profile notifier
final userProfileNotifierProvider = StateNotifierProvider.family<
    UserProfileNotifier, AsyncValue<User?>, String>(
  (ref, userId) {
    final userRepository = ref.watch(userRepositoryProvider);
    return UserProfileNotifier(userRepository, userId);
  },
);
