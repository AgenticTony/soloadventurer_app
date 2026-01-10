import 'package:flutter_test/flutter_test.dart';
import 'package:soloadventurer/features/auth/data/models/auth_response_model.dart';
import 'package:soloadventurer/features/auth/data/models/user_model.dart';

void main() {
  final testDate = DateTime(2024, 3, 14);
  final testExpiryDate = DateTime(2024, 3, 15);

  final testUser = UserModel(
    id: 'test-id',
    email: 'test@example.com',
    username: 'testuser',
    createdAt: testDate,
  );

  final testAuthResponse = AuthResponseModel(
    user: testUser,
    accessToken: 'test-access-token',
    refreshToken: 'test-refresh-token',
    expiresAt: testExpiryDate,
  );

  final testJson = {
    'user': {
      'id': 'test-id',
      'email': 'test@example.com',
      'username': 'testuser',
      'created_at': '2024-03-14T00:00:00.000',
      'last_login_at': null,
    },
    'access_token': 'test-access-token',
    'refresh_token': 'test-refresh-token',
    'expires_at': '2024-03-15T00:00:00.000',
  };

  group('AuthResponseModel', () {
    group('fromJson', () {
      test('should return a valid model when JSON contains all fields', () {
        // Act
        final result = AuthResponseModel.fromJson(testJson);

        // Assert
        expect(result, isA<AuthResponseModel>());
        expect(result.user.id, equals(testUser.id));
        expect(result.user.email, equals(testUser.email));
        expect(result.user.username, equals(testUser.username));
        expect(result.user.createdAt, equals(testUser.createdAt));
        expect(result.accessToken, equals(testJson['access_token']));
        expect(result.refreshToken, equals(testJson['refresh_token']));
        expect(result.expiresAt, equals(testExpiryDate));
      });

      test('should throw FormatException when dates are invalid', () {
        // Arrange
        final jsonWithInvalidDate = Map<String, dynamic>.from(testJson)
          ..['expires_at'] = 'invalid-date';

        // Act & Assert
        expect(
          () => AuthResponseModel.fromJson(jsonWithInvalidDate),
          throwsFormatException,
        );
      });

      test('should throw TypeError when required fields are missing', () {
        // Arrange
        final jsonWithMissingFields = Map<String, dynamic>.from(testJson)
          ..remove('access_token');

        // Act & Assert
        expect(
          () => AuthResponseModel.fromJson(jsonWithMissingFields),
          throwsA(isA<TypeError>()),
        );
      });
    });

    group('toJson', () {
      test('should return JSON map containing proper data', () {
        // Act
        final result = testAuthResponse.toJson();

        // Assert
        expect(result, equals(testJson));
      });
    });
  });
}
