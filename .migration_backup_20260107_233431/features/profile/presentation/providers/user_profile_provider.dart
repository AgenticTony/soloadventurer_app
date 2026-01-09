import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../features/auth/domain/entities/user.dart';
import '../../../../features/core/infrastructure/api/api_service.dart';
import '../../../../features/core/infrastructure/api/dio_api_service.dart';

part 'user_profile_provider.g.dart';

/// Provider for the API service
@Riverpod(keepAlive: true)
ApiService apiService(Ref ref) {
  return DioApiService();
}

/// Provider for user repository
@Riverpod(keepAlive: true)
UserRepository userRepository(Ref ref) {
  final apiService = ref.watch(apiServiceProvider);
  return UserRepository(apiService);
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

/// Provider for fetching user profile (using @riverpod syntax)
@riverpod
Future<User> fetchUserProfile(Ref ref, String userId) async {
  final userRepository = ref.watch(userRepositoryProvider);
  return userRepository.getUserProfile(userId);
}

/// Provider for current user profile (using @riverpod syntax)
@riverpod
Future<User?> currentUserProfile(Ref ref) async {
  // This would normally come from your auth provider
  final authState = ref.watch(authStateProvider);

  if (authState.userId == null) {
    return null;
  }

  final userRepository = ref.watch(userRepositoryProvider);
  return userRepository.getUserProfile(authState.userId!);
}

/// Auth state provider (simplified for this example)
@Riverpod(keepAlive: true)
AuthState authState(Ref ref) {
  // This would normally come from your auth provider
  return AuthState(userId: 'current-user-id');
}

/// Simple auth state class for this example
class AuthState {
  final String? userId;

  AuthState({this.userId});
}

/// Notifier for updating user profile (migrated to @riverpod)
@riverpod
class UserProfileNotifier extends _$UserProfileNotifier {
  /// Load user profile
  Future<void> loadUserProfile() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final userRepository = ref.read(userRepositoryProvider);
      return await userRepository.getUserProfile(userId);
    });
  }

  /// Update user profile
  Future<void> updateProfile(Map<String, dynamic> data) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final userRepository = ref.read(userRepositoryProvider);
      return await userRepository.updateUserProfile(userId, data);
    });
  }

  @override
  AsyncValue<User?> build(String userId) {
    // Load initial data
    loadUserProfile();
    return const AsyncLoading();
  }
}
