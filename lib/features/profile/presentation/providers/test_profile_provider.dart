import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/entities/profile.dart';
import '../state/profile_state.dart';

part 'test_profile_provider.g.dart';

/// Test profile data
final testProfileData = Profile(
  id: 'test-123',
  userId: 'user-123',
  username: 'TestUser',
  email: 'test@example.com',
  displayName: 'Test User',
  bio: 'This is a test profile for development',
  avatarUrl: 'https://via.placeholder.com/150',
  isPublic: true,
  createdAt: DateTime.now(),
  updatedAt: DateTime.now(),
);

/// Test profile provider that returns mock data
@riverpod
ProfileState testProfile(Ref ref) {
  return ProfileState(
    profile: testProfileData,
    isLoading: false,
    error: null,
    hasChanges: false,
  );
}
