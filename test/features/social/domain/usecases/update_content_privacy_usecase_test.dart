import 'package:flutter_test/flutter_test.dart';
import 'package:soloadventurer/features/social/domain/entities/content_privacy_settings.dart';
import 'package:soloadventurer/features/social/domain/entities/privacy_settings.dart';
import 'package:soloadventurer/features/social/domain/enums/comment_permission.dart';
import 'package:soloadventurer/features/social/domain/enums/content_audience.dart';
import 'package:soloadventurer/features/social/domain/enums/profile_visibility.dart';
import 'package:soloadventurer/features/social/domain/enums/verification_tier.dart';
import 'package:soloadventurer/features/social/domain/repositories/privacy_repository.dart';
import 'package:soloadventurer/features/social/domain/usecases/update_content_privacy_usecase.dart';

/// Fake implementation of [PrivacyRepository] for testing
class FakePrivacyRepository implements PrivacyRepository {
  /// Tracks whether updateContentPrivacy was called
  bool updateContentPrivacyCalled = false;

  /// Captured settings from updateContentPrivacy
  ContentPrivacySettings? capturedSettings;

  @override
  Future<void> updateContentPrivacy(ContentPrivacySettings settings) async {
    updateContentPrivacyCalled = true;
    capturedSettings = settings;
  }

  @override
  Future<PrivacySettings> getProfilePrivacy() async {
    throw UnimplementedError();
  }

  @override
  Future<void> updateProfilePrivacy(PrivacySettings settings) async {
    throw UnimplementedError();
  }

  @override
  Future<ContentPrivacySettings> getContentPrivacy() async {
    throw UnimplementedError();
  }

  @override
  Future<VerificationTier> getVerificationTier() async {
    throw UnimplementedError();
  }
}

void main() {
  late FakePrivacyRepository fakeRepository;
  late UpdateContentPrivacyUseCase useCase;

  setUp(() {
    fakeRepository = FakePrivacyRepository();
    useCase = UpdateContentPrivacyUseCase(fakeRepository);
  });

  group('UpdateContentPrivacyUseCase', () {
    test('calls repository updateContentPrivacy with provided settings',
        () async {
      const settings = ContentPrivacySettings(
        defaultPostAudience: ContentAudience.public,
        allowCommentsFrom: CommentPermission.everyone,
        allowReshares: true,
        includeInDestinationFeed: true,
      );

      await useCase(settings);

      expect(fakeRepository.updateContentPrivacyCalled, isTrue);
      expect(fakeRepository.capturedSettings, isNotNull);
      expect(
        fakeRepository.capturedSettings!.defaultPostAudience,
        ContentAudience.public,
      );
      expect(
        fakeRepository.capturedSettings!.allowCommentsFrom,
        CommentPermission.everyone,
      );
      expect(fakeRepository.capturedSettings!.allowReshares, isTrue);
      expect(
        fakeRepository.capturedSettings!.includeInDestinationFeed,
        isTrue,
      );
    });

    test('passes default settings correctly', () async {
      const settings = ContentPrivacySettings();

      await useCase(settings);

      expect(fakeRepository.capturedSettings!.defaultPostAudience,
          ContentAudience.followers);
      expect(fakeRepository.capturedSettings!.allowCommentsFrom,
          CommentPermission.followers);
      expect(fakeRepository.capturedSettings!.allowReshares, isFalse);
      expect(fakeRepository.capturedSettings!.includeInDestinationFeed, isFalse);
    });

    test('passes mixed settings correctly', () async {
      const settings = ContentPrivacySettings(
        defaultPostAudience: ContentAudience.community,
        allowCommentsFrom: CommentPermission.nobody,
        allowReshares: false,
        includeInDestinationFeed: true,
      );

      await useCase(settings);

      expect(fakeRepository.capturedSettings!.defaultPostAudience,
          ContentAudience.community);
      expect(fakeRepository.capturedSettings!.allowCommentsFrom,
          CommentPermission.nobody);
      expect(fakeRepository.capturedSettings!.allowReshares, isFalse);
      expect(
          fakeRepository.capturedSettings!.includeInDestinationFeed, isTrue);
    });
  });
}
