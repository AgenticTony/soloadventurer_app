import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../data/datasources/privacy_remote_data_source.dart';
import '../data/repositories/privacy_repository_impl.dart';
import '../domain/entities/content_privacy_settings.dart';
import '../domain/entities/privacy_settings.dart';
import '../domain/enums/profile_visibility.dart';
import '../domain/enums/verification_tier.dart';
import '../domain/repositories/privacy_repository.dart';
import '../domain/usecases/get_content_privacy_usecase.dart';
import '../domain/usecases/get_profile_privacy_usecase.dart';
import '../domain/usecases/get_verification_tier_usecase.dart';
import '../domain/usecases/update_content_privacy_usecase.dart';
import '../domain/usecases/update_profile_privacy_usecase.dart';

part 'privacy_providers.g.dart';

// ============================================================
// Data Source
// ============================================================

/// Provides the privacy remote data source backed by Supabase
@Riverpod(keepAlive: true)
PrivacyRemoteDataSource privacyRemoteDataSource(Ref ref) {
  return PrivacyRemoteDataSourceImpl(client: Supabase.instance.client);
}

// ============================================================
// Repository
// ============================================================

/// Provides the privacy repository implementation
@Riverpod(keepAlive: true)
PrivacyRepository privacyRepository(Ref ref) {
  return PrivacyRepositoryImpl(
    remoteDataSource: ref.read(privacyRemoteDataSourceProvider),
  );
}

// ============================================================
// Use Cases
// ============================================================

/// Provides the get profile privacy use case
@riverpod
GetProfilePrivacyUseCase getProfilePrivacyUseCase(Ref ref) =>
    GetProfilePrivacyUseCase(ref.read(privacyRepositoryProvider));

/// Provides the update profile privacy use case
@riverpod
UpdateProfilePrivacyUseCase updateProfilePrivacyUseCase(Ref ref) =>
    UpdateProfilePrivacyUseCase(ref.read(privacyRepositoryProvider));

/// Provides the get content privacy use case
@riverpod
GetContentPrivacyUseCase getContentPrivacyUseCase(Ref ref) =>
    GetContentPrivacyUseCase(ref.read(privacyRepositoryProvider));

/// Provides the update content privacy use case
@riverpod
UpdateContentPrivacyUseCase updateContentPrivacyUseCase(Ref ref) =>
    UpdateContentPrivacyUseCase(ref.read(privacyRepositoryProvider));

/// Provides the get verification tier use case
@riverpod
GetVerificationTierUseCase getVerificationTierUseCase(Ref ref) =>
    GetVerificationTierUseCase(ref.read(privacyRepositoryProvider));

// ============================================================
// Async Notifiers
// ============================================================

/// AsyncNotifier that manages profile privacy settings
@riverpod
class ProfilePrivacy extends _$ProfilePrivacy {
  @override
  Future<PrivacySettings> build() async {
    final useCase = ref.read(getProfilePrivacyUseCaseProvider);
    return useCase();
  }

  /// Update profile visibility level
  Future<void> updateVisibility(ProfileVisibility visibility) async {
    final current = state.value;
    if (current == null) return;

    final updated = PrivacySettings(
      visibility: visibility,
      minViewerAge: current.minViewerAge,
      verifiedOnly: current.verifiedOnly,
      genderFilter: current.genderFilter,
      showLocation: current.showLocation,
      discoverableByDestination: current.discoverableByDestination,
    );

    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final useCase = ref.read(updateProfilePrivacyUseCaseProvider);
      await useCase(updated);
      return updated;
    });
  }

  /// Update profile privacy filters (age, verified, gender, etc.)
  Future<void> updateFilters({
    int? minViewerAge,
    bool? verifiedOnly,
    List<String>? genderFilter,
    bool? showLocation,
    bool? discoverableByDestination,
  }) async {
    final current = state.value;
    if (current == null) return;

    final updated = PrivacySettings(
      visibility: current.visibility,
      minViewerAge: minViewerAge ?? current.minViewerAge,
      verifiedOnly: verifiedOnly ?? current.verifiedOnly,
      genderFilter: genderFilter ?? current.genderFilter,
      showLocation: showLocation ?? current.showLocation,
      discoverableByDestination:
          discoverableByDestination ?? current.discoverableByDestination,
    );

    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final useCase = ref.read(updateProfilePrivacyUseCaseProvider);
      await useCase(updated);
      return updated;
    });
  }
}

/// AsyncNotifier that manages content privacy settings
@riverpod
class ContentPrivacy extends _$ContentPrivacy {
  @override
  Future<ContentPrivacySettings> build() async {
    final useCase = ref.read(getContentPrivacyUseCaseProvider);
    return useCase();
  }

  /// Update content privacy settings
  Future<void> updateSettings(ContentPrivacySettings settings) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final useCase = ref.read(updateContentPrivacyUseCaseProvider);
      await useCase(settings);
      return settings;
    });
  }
}

// ============================================================
// Simple Query Providers
// ============================================================

/// Provides the current user's verification tier
@riverpod
Future<VerificationTier> verificationTier(Ref ref) async {
  final useCase = ref.read(getVerificationTierUseCaseProvider);
  return useCase();
}
