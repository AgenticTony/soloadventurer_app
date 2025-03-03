import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:soloadventurer/features/auth/data/sources/auth_local_data_source.dart';
import 'package:soloadventurer/features/auth/domain/entities/user.dart';

class MockFlutterSecureStorage extends Mock implements FlutterSecureStorage {}

void main() {
  late MockFlutterSecureStorage mockSecureStorage;
  late AuthLocalDataSource authLocalDataSource;

  final testDate = DateTime(2024, 3, 14);
  final testLastLoginDate = DateTime(2024, 3, 15);
  final testUser = User(
    id: 'test-id',
    email: 'test@example.com',
    username: 'testuser',
    createdAt: testDate,
    lastLoginAt: testLastLoginDate,
  );

  final testUserJson = {
    'id': 'test-id',
    'email': 'test@example.com',
    'username': 'testuser',
    'createdAt': testDate.toIso8601String(),
    'lastLoginAt': testLastLoginDate.toIso8601String(),
  };

  setUp(() {
    mockSecureStorage = MockFlutterSecureStorage();
    authLocalDataSource =
        AuthLocalDataSourceImpl(secureStorage: mockSecureStorage);
  });

  group('AuthLocalDataSource', () {
    group('getUser', () {
      test('should return User when storage has user data', () async {
        // Arrange
        when(() => mockSecureStorage.read(key: 'user'))
            .thenAnswer((_) async => jsonEncode(testUserJson));

        // Act
        final result = await authLocalDataSource.getUser();

        // Assert
        expect(result, isA<User>());
        expect(result?.id, equals(testUser.id));
        expect(result?.email, equals(testUser.email));
        expect(result?.username, equals(testUser.username));
        expect(result?.createdAt, equals(testUser.createdAt));
        expect(result?.lastLoginAt, equals(testUser.lastLoginAt));
      });

      test('should return null when storage has no user data', () async {
        // Arrange
        when(() => mockSecureStorage.read(key: 'user'))
            .thenAnswer((_) async => null);

        // Act
        final result = await authLocalDataSource.getUser();

        // Assert
        expect(result, isNull);
      });

      test('should return null and clear data when stored JSON is invalid',
          () async {
        // Arrange
        when(() => mockSecureStorage.read(key: 'user'))
            .thenAnswer((_) async => 'invalid-json');
        when(() => mockSecureStorage.delete(key: 'user'))
            .thenAnswer((_) async {});

        // Act
        final result = await authLocalDataSource.getUser();

        // Assert
        expect(result, isNull);
        verify(() => mockSecureStorage.delete(key: 'user')).called(1);
      });
    });

    group('saveUser', () {
      test('should store user data in secure storage', () async {
        // Arrange
        when(() => mockSecureStorage.write(
              key: 'user',
              value: any(named: 'value'),
            )).thenAnswer((_) async {});

        // Act
        await authLocalDataSource.saveUser(testUser);

        // Assert
        verify(() => mockSecureStorage.write(
              key: 'user',
              value: jsonEncode(testUserJson),
            )).called(1);
      });
    });

    group('clearUser', () {
      test('should remove user data from secure storage', () async {
        // Arrange
        when(() => mockSecureStorage.delete(key: 'user'))
            .thenAnswer((_) async {});

        // Act
        await authLocalDataSource.clearUser();

        // Assert
        verify(() => mockSecureStorage.delete(key: 'user')).called(1);
      });
    });

    group('getAccessToken', () {
      test('should return token when storage has access token', () async {
        // Arrange
        const testToken = 'test-access-token';
        when(() => mockSecureStorage.read(key: 'access_token'))
            .thenAnswer((_) async => testToken);

        // Act
        final result = await authLocalDataSource.getAccessToken();

        // Assert
        expect(result, equals(testToken));
      });

      test('should return null when storage has no access token', () async {
        // Arrange
        when(() => mockSecureStorage.read(key: 'access_token'))
            .thenAnswer((_) async => null);

        // Act
        final result = await authLocalDataSource.getAccessToken();

        // Assert
        expect(result, isNull);
      });
    });

    group('saveAccessToken', () {
      test('should store access token in secure storage', () async {
        // Arrange
        const testToken = 'test-access-token';
        when(() => mockSecureStorage.write(
              key: 'access_token',
              value: any(named: 'value'),
            )).thenAnswer((_) async {});

        // Act
        await authLocalDataSource.saveAccessToken(testToken);

        // Assert
        verify(() => mockSecureStorage.write(
              key: 'access_token',
              value: testToken,
            )).called(1);
      });
    });

    group('getRefreshToken', () {
      test('should return token when storage has refresh token', () async {
        // Arrange
        const testToken = 'test-refresh-token';
        when(() => mockSecureStorage.read(key: 'refresh_token'))
            .thenAnswer((_) async => testToken);

        // Act
        final result = await authLocalDataSource.getRefreshToken();

        // Assert
        expect(result, equals(testToken));
      });

      test('should return null when storage has no refresh token', () async {
        // Arrange
        when(() => mockSecureStorage.read(key: 'refresh_token'))
            .thenAnswer((_) async => null);

        // Act
        final result = await authLocalDataSource.getRefreshToken();

        // Assert
        expect(result, isNull);
      });
    });

    group('saveRefreshToken', () {
      test('should store refresh token in secure storage', () async {
        // Arrange
        const testToken = 'test-refresh-token';
        when(() => mockSecureStorage.write(
              key: 'refresh_token',
              value: any(named: 'value'),
            )).thenAnswer((_) async {});

        // Act
        await authLocalDataSource.saveRefreshToken(testToken);

        // Assert
        verify(() => mockSecureStorage.write(
              key: 'refresh_token',
              value: testToken,
            )).called(1);
      });
    });

    group('clearAuthData', () {
      test('should remove all auth data from secure storage', () async {
        // Arrange
        when(() => mockSecureStorage.delete(key: any(named: 'key')))
            .thenAnswer((_) async {});

        // Act
        await authLocalDataSource.clearAuthData();

        // Assert
        verify(() => mockSecureStorage.delete(key: 'user')).called(1);
        verify(() => mockSecureStorage.delete(key: 'access_token')).called(1);
        verify(() => mockSecureStorage.delete(key: 'refresh_token')).called(1);
      });
    });
  });
}
