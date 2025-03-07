import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../entities/profile.dart';
import '../entities/profile_state.dart';
import '../repositories/profile_repository.dart';
import '../../presentation/providers/profile_providers.dart';

/// Provider for profile domain state
final profileDomainProvider =
    StateNotifierProvider<ProfileDomainNotifier, ProfileDomainState>((ref) {
  final repository = ref.watch(profileRepositoryProvider);
  return ProfileDomainNotifier(repository);
});

/// Notifier for profile domain state
class ProfileDomainNotifier extends StateNotifier<ProfileDomainState> {
  final ProfileRepository _repository;

  ProfileDomainNotifier(this._repository) : super(const ProfileDomainState()) {
    loadProfile();
  }

  Future<void> loadProfile() async {
    try {
      final profile = await _repository.getCurrentProfile();
      state = state.copyWith(profile: profile);
    } catch (e) {
      state = const ProfileDomainState();
    }
  }

  Future<void> updateProfile(Profile profile) async {
    try {
      await _repository.updateProfile(profile);
      state = state.copyWith(profile: profile);
    } catch (e) {
      // Domain layer maintains current state on error
      state = state;
    }
  }

  Future<void> toggleVisibility() async {
    if (state.profile == null) return;

    final updatedProfile = state.profile!.copyWith(
      isPublic: !state.profile!.isPublic,
    );

    await updateProfile(updatedProfile);
  }

  Future<void> deleteProfile() async {
    try {
      await _repository.deleteProfile(state.profile?.id ?? '');
      state = const ProfileDomainState();
    } catch (e) {
      // Domain layer maintains current state on error
      state = state;
    }
  }
}
