import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../entities/profile.dart';
import '../entities/profile_state.dart';
import '../repositories/profile_repository.dart';
import '../../presentation/providers/profile_providers.dart'
    show profileRepositoryProvider;

part 'profile_provider.g.dart';

/// Riverpod 3.0 Migration Notes:
/// - Converted from StateNotifier<ProfileDomainState> to Notifier<ProfileDomainState>
/// - Dependencies injected via ref.watch() in build() method
/// - build() returns ProfileDomainState not AsyncValue
/// - Constructor auto-load moved to build() method

@riverpod
class ProfileDomain extends _$ProfileDomain {
  @override
  ProfileDomainState build() {
    final repository = ref.watch(profileRepositoryProvider);
    _loadProfile(repository);
    return const ProfileDomainState();
  }

  Future<void> _loadProfile(ProfileRepository repository) async {
    try {
      final profile = await repository.getCurrentProfile();
      state = state.copyWith(profile: profile);
    } catch (e) {
      state = const ProfileDomainState();
    }
  }

  Future<void> loadProfile() async {
    final repository = ref.read(profileRepositoryProvider);
    try {
      final profile = await repository.getCurrentProfile();
      state = state.copyWith(profile: profile);
    } catch (e) {
      state = const ProfileDomainState();
    }
  }

  Future<void> updateProfile(Profile profile) async {
    final repository = ref.read(profileRepositoryProvider);
    try {
      await repository.updateProfile(profile);
      state = state.copyWith(profile: profile);
    } catch (e) {
      state = state;
    }
  }

  Future<void> toggleVisibility() async {
    final currentProfile = state.profile;
    if (currentProfile == null) return;

    final updatedProfile = currentProfile.copyWith(
      isPublic: !currentProfile.isPublic,
    );

    await updateProfile(updatedProfile);
  }

  Future<void> deleteProfile() async {
    final repository = ref.read(profileRepositoryProvider);
    try {
      await repository.deleteProfile(state.profile?.id ?? '');
      state = const ProfileDomainState();
    } catch (e) {
      state = state;
    }
  }
}
