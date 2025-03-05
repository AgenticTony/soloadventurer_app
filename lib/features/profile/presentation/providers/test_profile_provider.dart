import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/profile.dart';
import '../state/profile_state.dart';

/// Test profile data
final testProfile = Profile(
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
final testProfileProvider = StateProvider<ProfileState>((ref) {
  return ProfileState(
    profile: testProfile,
    isLoading: false,
    error: null,
    hasChanges: false,
  );
});
