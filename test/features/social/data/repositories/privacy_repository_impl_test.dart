import 'package:flutter_test/flutter_test.dart';
import 'package:soloadventurer/features/social/data/datasources/privacy_remote_data_source.dart';
import 'package:soloadventurer/features/social/data/models/content_privacy_settings_model.dart';
import 'package:soloadventurer/features/social/data/models/privacy_settings_model.dart';
import 'package:soloadventurer/features/social/data/repositories/privacy_repository_impl.dart';
import 'package:soloadventurer/features/social/domain/enums/comment_permission.dart';
import 'package:soloadventurer/features/social/domain/enums/content_audience.dart';
import 'package:soloadventurer/features/social/domain/enums/profile_visibility.dart';
import 'package:soloadventurer/features/social/domain/enums/verification_tier.dart';

/// Fake implementation of [PrivacyRemoteDataSource] for testing
class FakePrivacyRemoteDataSource implements PrivacyRemoteDataSource {
  /// The profile privacy model to return from getProfilePrivacy
  PrivacySettingsModel profileSettings;

  /// The content privacy model to return from getContentPrivacy
  ContentPrivacySettingsModel contentSettings;

  /// Tracks whether updateProfilePrivacy was called
  bool updateProfilePrivacyCalled = false;

  /// Tracks whether updateContentPrivacy was called
  bool updateContentPrivacyCalled = false;

  /// The last model passed to updateProfilePrivacy
  PrivacySettingsModel? lastProfileModel;

  /// The last model passed to updateContentPrivacy
  ContentPrivacySettingsModel? lastContentModel;

  FakePrivacyRemoteDataSource({
    required this.profileSettings,
    required this.contentSettings,
  });

  @override
  Future<PrivacySettingsModel> getProfilePrivacy() async => profileSettings;

  @override
  Future<void> updateProfilePrivacy(PrivacySettingsModel model) async {
    updateProfilePrivacyCalled = true;
    lastProfileModel = model;
    profileSettings = model;
  }

  @override
  Future<ContentPrivacySettingsModel> getContentPrivacy() async =>
      contentSettings;

  @override
  Future<void> updateContentPrivacy(ContentPrivacySettingsModel model) async {
    updateContentPrivacyCalled = true;
    lastContentModel = model;
    contentSettings = model;
  }

  @override
  Future<VerificationTier> getVerificationTier() async =>
      throw UnimplementedError();
}

void main() {
  group('PrivacyRemoteDataSource (fake delegation)', () {
    late FakePrivacyRemoteDataSource fakeDataSource;

    setUp(() {
      fakeDataSource = FakePrivacyRemoteDataSource(
        profileSettings: const PrivacySettingsModel(
          userId: 'user-1',
          visibility: ProfileVisibility.community,
          verifiedOnly: false,
          showLocation: true,
          discoverableByDestination: true,
        ),
        contentSettings: const ContentPrivacySettingsModel(
          userId: 'user-1',
          defaultPostAudience: ContentAudience.followers,
          allowCommentsFrom: CommentPermission.followers,
          allowReshares: false,
          includeInDestinationFeed: false,
        ),
      );
    });

    group('getProfilePrivacy', () {
      test('returns entity with correct default values', () async {
        final model = await fakeDataSource.getProfilePrivacy();
        final entity = model.toEntity();

        expect(entity.visibility, ProfileVisibility.community);
        expect(entity.verifiedOnly, isFalse);
        expect(entity.showLocation, isTrue);
        expect(entity.discoverableByDestination, isTrue);
        expect(entity.minViewerAge, isNull);
        expect(entity.genderFilter, isNull);
      });

      test('maps custom profile privacy values to entity', () async {
        fakeDataSource = FakePrivacyRemoteDataSource(
          profileSettings: const PrivacySettingsModel(
            userId: 'user-1',
            visibility: ProfileVisibility.public,
            verifiedOnly: true,
            showLocation: false,
            discoverableByDestination: false,
            minViewerAge: 21,
            genderFilter: ['female'],
          ),
          contentSettings: const ContentPrivacySettingsModel(
            userId: 'user-1',
            defaultPostAudience: ContentAudience.followers,
            allowCommentsFrom: CommentPermission.followers,
            allowReshares: false,
            includeInDestinationFeed: false,
          ),
        );

        final model = await fakeDataSource.getProfilePrivacy();
        final entity = model.toEntity();

        expect(entity.visibility, ProfileVisibility.public);
        expect(entity.verifiedOnly, isTrue);
        expect(entity.showLocation, isFalse);
        expect(entity.minViewerAge, 21);
        expect(entity.genderFilter, ['female']);
      });
    });

    group('getContentPrivacy', () {
      test('returns entity with correct default values', () async {
        final model = await fakeDataSource.getContentPrivacy();
        final entity = model.toEntity();

        expect(entity.defaultPostAudience, ContentAudience.followers);
        expect(entity.allowCommentsFrom, CommentPermission.followers);
        expect(entity.allowReshares, isFalse);
        expect(entity.includeInDestinationFeed, isFalse);
      });

      test('maps custom content privacy values to entity', () async {
        fakeDataSource = FakePrivacyRemoteDataSource(
          profileSettings: const PrivacySettingsModel(
            userId: 'user-1',
            visibility: ProfileVisibility.community,
            verifiedOnly: false,
            showLocation: true,
            discoverableByDestination: true,
          ),
          contentSettings: const ContentPrivacySettingsModel(
            userId: 'user-1',
            defaultPostAudience: ContentAudience.public,
            allowCommentsFrom: CommentPermission.everyone,
            allowReshares: true,
            includeInDestinationFeed: true,
          ),
        );

        final model = await fakeDataSource.getContentPrivacy();
        final entity = model.toEntity();

        expect(entity.defaultPostAudience, ContentAudience.public);
        expect(entity.allowCommentsFrom, CommentPermission.everyone);
        expect(entity.allowReshares, isTrue);
        expect(entity.includeInDestinationFeed, isTrue);
      });
    });

    group('updateProfilePrivacy', () {
      test('receives and stores the model', () async {
        const updatedModel = PrivacySettingsModel(
          userId: 'user-1',
          visibility: ProfileVisibility.hidden,
          verifiedOnly: true,
          showLocation: false,
          discoverableByDestination: false,
        );

        await fakeDataSource.updateProfilePrivacy(updatedModel);

        expect(fakeDataSource.updateProfilePrivacyCalled, isTrue);
        expect(fakeDataSource.lastProfileModel!.visibility,
            ProfileVisibility.hidden);
        expect(fakeDataSource.lastProfileModel!.verifiedOnly, isTrue);

        // Verify persistence in the fake
        final stored = await fakeDataSource.getProfilePrivacy();
        expect(stored.visibility, ProfileVisibility.hidden);
      });
    });

    group('updateContentPrivacy', () {
      test('receives and stores the model', () async {
        const updatedModel = ContentPrivacySettingsModel(
          userId: 'user-1',
          defaultPostAudience: ContentAudience.community,
          allowCommentsFrom: CommentPermission.nobody,
          allowReshares: true,
          includeInDestinationFeed: true,
        );

        await fakeDataSource.updateContentPrivacy(updatedModel);

        expect(fakeDataSource.updateContentPrivacyCalled, isTrue);
        expect(fakeDataSource.lastContentModel!.defaultPostAudience,
            ContentAudience.community);
        expect(fakeDataSource.lastContentModel!.allowCommentsFrom,
            CommentPermission.nobody);
        expect(fakeDataSource.lastContentModel!.allowReshares, isTrue);

        // Verify persistence in the fake
        final stored = await fakeDataSource.getContentPrivacy();
        expect(stored.defaultPostAudience, ContentAudience.community);
      });
    });
  });
}
