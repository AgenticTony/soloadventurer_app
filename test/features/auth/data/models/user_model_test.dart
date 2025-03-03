import 'package:flutter_test/flutter_test.dart';
import 'package:soloadventurer/features/auth/data/models/user_model.dart';
import 'package:soloadventurer/features/auth/domain/entities/user.dart';

void main() {
  final testDate = DateTime(2024, 3, 14);
  final testLastLoginDate = DateTime(2024, 3, 15);

  final testUser = UserModel(
    id: 'test-id',
    email: 'test@example.com',
    username: 'testuser',
    createdAt: testDate,
    lastLoginAt: testLastLoginDate,
  );

  final testJson = {
    'id': 'test-id',
    'email': 'test@example.com',
    'username': 'testuser',
    'created_at': '2024-03-14T00:00:00.000',
    'last_login_at': '2024-03-15T00:00:00.000',
  };

  group('UserModel', () {
    test('should be a subclass of User entity', () {
      // Assert
      expect(testUser, isA<User>());
    });

    group('fromJson', () {
      test('should return a valid model when JSON contains all fields', () {
        // Act
        final result = UserModel.fromJson(testJson);

        // Assert
        expect(result, isA<UserModel>());
        expect(result.id, equals(testJson['id']));
        expect(result.email, equals(testJson['email']));
        expect(result.username, equals(testJson['username']));
        expect(result.createdAt, equals(testDate));
        expect(result.lastLoginAt, equals(testLastLoginDate));
      });

      test('should return a valid model when lastLoginAt is null', () {
        // Arrange
        final jsonWithoutLastLogin = Map<String, dynamic>.from(testJson)
          ..remove('last_login_at');

        // Act
        final result = UserModel.fromJson(jsonWithoutLastLogin);

        // Assert
        expect(result.lastLoginAt, isNull);
      });

      test('should throw FormatException when dates are invalid', () {
        // Arrange
        final jsonWithInvalidDate = Map<String, dynamic>.from(testJson)
          ..['created_at'] = 'invalid-date';

        // Act & Assert
        expect(
          () => UserModel.fromJson(jsonWithInvalidDate),
          throwsFormatException,
        );
      });
    });

    group('toJson', () {
      test('should return JSON map containing proper data', () {
        // Act
        final result = testUser.toJson();

        // Assert
        expect(result, equals(testJson));
      });

      test('should return JSON map with null lastLoginAt when not set', () {
        // Arrange
        final userWithoutLastLogin = UserModel(
          id: 'test-id',
          email: 'test@example.com',
          username: 'testuser',
          createdAt: testDate,
        );

        // Act
        final result = userWithoutLastLogin.toJson();

        // Assert
        expect(result['last_login_at'], isNull);
      });
    });

    group('fromEntity', () {
      test('should return a valid model from User entity', () {
        // Arrange
        final user = User(
          id: 'test-id',
          email: 'test@example.com',
          username: 'testuser',
          createdAt: testDate,
          lastLoginAt: testLastLoginDate,
        );

        // Act
        final result = UserModel.fromEntity(user);

        // Assert
        expect(result, isA<UserModel>());
        expect(result.id, equals(user.id));
        expect(result.email, equals(user.email));
        expect(result.username, equals(user.username));
        expect(result.createdAt, equals(user.createdAt));
        expect(result.lastLoginAt, equals(user.lastLoginAt));
      });

      test('should handle null lastLoginAt from entity', () {
        // Arrange
        final user = User(
          id: 'test-id',
          email: 'test@example.com',
          username: 'testuser',
          createdAt: testDate,
        );

        // Act
        final result = UserModel.fromEntity(user);

        // Assert
        expect(result.lastLoginAt, isNull);
      });
    });
  });
}
