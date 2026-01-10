import 'package:flutter_test/flutter_test.dart';
import 'package:soloadventurer/core/errors/exceptions.dart';
import 'package:soloadventurer/features/profile/data/models/profile_model.dart';
import 'package:soloadventurer/features/profile/domain/entities/profile.dart';

void main() {
  final tProfileModel = ProfileModel(
    id: 'test_id',
    userId: 'test_user_id',
    displayName: 'Test User',
    bio: 'Test bio',
    createdAt: DateTime(2024),
    updatedAt: DateTime(2024),
    preferences: const {'theme': 'dark'},
    interests: const ['coding', 'testing'],
    isPublic: true,
  );

  final tProfileJson = {
    'id': 'test_id',
    'userId': 'test_user_id',
    'displayName': 'Test User',
    'bio': 'Test bio',
    'createdAt': '2024-01-01T00:00:00.000',
    'updatedAt': '2024-01-01T00:00:00.000',
    'preferences': {'theme': 'dark'},
    'interests': ['coding', 'testing'],
    'isPublic': true,
  };

  group('ProfileModel', () {
    test('should be a subclass of Profile entity', () {
      expect(tProfileModel, isA<Profile>());
    });

    group('fromJson', () {
      test('should return a valid model when JSON is valid', () {
        // act
        final result = ProfileModel.fromJson(tProfileJson);

        // assert
        expect(result, equals(tProfileModel));
      });

      test('should throw ValidationException when displayName is empty', () {
        // arrange
        final invalidJson = Map<String, dynamic>.from(tProfileJson)
          ..['displayName'] = '';

        // act & assert
        expect(
          () => ProfileModel.fromJson(invalidJson),
          throwsA(isA<ValidationException>()),
        );
      });

      test(
          'should throw ValidationException when displayName exceeds max length',
          () {
        // arrange
        final invalidJson = Map<String, dynamic>.from(tProfileJson)
          ..['displayName'] = 'a' * (ProfileModel.maxDisplayNameLength + 1);

        // act & assert
        expect(
          () => ProfileModel.fromJson(invalidJson),
          throwsA(isA<ValidationException>()),
        );
      });

      test('should throw ValidationException when bio exceeds max length', () {
        // arrange
        final invalidJson = Map<String, dynamic>.from(tProfileJson)
          ..['bio'] = 'a' * (ProfileModel.maxBioLength + 1);

        // act & assert
        expect(
          () => ProfileModel.fromJson(invalidJson),
          throwsA(isA<ValidationException>()),
        );
      });

      test('should throw ValidationException when interests exceed max count',
          () {
        // arrange
        final invalidJson = Map<String, dynamic>.from(tProfileJson)
          ..['interests'] = List.generate(
              ProfileModel.maxInterestsCount + 1, (i) => 'interest$i');

        // act & assert
        expect(
          () => ProfileModel.fromJson(invalidJson),
          throwsA(isA<ValidationException>()),
        );
      });

      test('should throw ValidationException when preferences exceed max count',
          () {
        // arrange
        final invalidJson = Map<String, dynamic>.from(tProfileJson)
          ..['preferences'] = Map.fromEntries(List.generate(
              ProfileModel.maxPreferencesCount + 1,
              (i) => MapEntry('pref$i', 'value$i')));

        // act & assert
        expect(
          () => ProfileModel.fromJson(invalidJson),
          throwsA(isA<ValidationException>()),
        );
      });
    });

    group('toJson', () {
      test('should return a JSON map containing the proper data', () {
        // act
        final result = tProfileModel.toJson();

        // assert
        expect(result, equals(tProfileJson));
      });
    });

    group('copyWith', () {
      test('should return a new ProfileModel with updated values', () {
        // act
        final result = tProfileModel.copyWith(
          displayName: 'New Name',
          bio: 'New bio',
          isPublic: false,
        );

        // assert
        expect(result.displayName, equals('New Name'));
        expect(result.bio, equals('New bio'));
        expect(result.isPublic, equals(false));
        expect(result.id, equals(tProfileModel.id));
        expect(result.userId, equals(tProfileModel.userId));
      });

      test('should return the same instance when no parameters are passed', () {
        // act
        final result = tProfileModel.copyWith();

        // assert
        expect(result, equals(tProfileModel));
      });
    });

    group('validate', () {
      test('should not throw when all fields are valid', () {
        // act & assert
        expect(() => tProfileModel.validate(), returnsNormally);
      });

      test('should throw ValidationException when displayName is invalid', () {
        // arrange
        final invalidModel = tProfileModel.copyWith(displayName: '');

        // act & assert
        expect(
          () => invalidModel.validate(),
          throwsA(isA<ValidationException>()),
        );
      });

      test('should throw ValidationException when bio is too long', () {
        // arrange
        final invalidModel =
            tProfileModel.copyWith(bio: 'a' * (ProfileModel.maxBioLength + 1));

        // act & assert
        expect(
          () => invalidModel.validate(),
          throwsA(isA<ValidationException>()),
        );
      });
    });
  });
}
