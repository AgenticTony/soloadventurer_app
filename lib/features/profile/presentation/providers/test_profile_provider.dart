import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/profile.dart';
import '../state/profile_state.dart';

part 'test_profile_provider.g.dart';

/// Provider that returns profile data from the current Supabase auth session.
///
/// On first build, it reads user metadata from the auth session.
/// Falls back to placeholder values if no session exists.
@riverpod
ProfileState testProfile(Ref ref) {
  final user = Supabase.instance.client.auth.currentUser;

  if (user == null) {
    return const ProfileState();
  }

  final metadata = user.userMetadata;
  final displayName = metadata?['full_name'] as String? ??
      metadata?['name'] as String? ??
      user.email?.split('@').first ??
      'User';
  final email = user.email ?? '';
  final avatarUrl = metadata?['avatar_url'] as String?;

  final profile = Profile(
    id: user.id,
    userId: user.id,
    username: email.split('@').first,
    email: email,
    displayName: displayName,
    avatarUrl: avatarUrl,
    isPublic: false,
    createdAt: DateTime.tryParse(user.createdAt) ?? DateTime.now(),
    updatedAt: DateTime.tryParse(user.updatedAt ?? '') ?? DateTime.now(),
  );

  return ProfileState(profile: profile);
}
