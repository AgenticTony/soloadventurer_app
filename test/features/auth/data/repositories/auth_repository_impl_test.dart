import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:soloadventurer/core/errors/exceptions.dart';
import 'package:soloadventurer/features/auth/data/models/auth_response_model.dart';
import 'package:soloadventurer/features/auth/data/models/user_model.dart';
import 'package:soloadventurer/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:soloadventurer/features/auth/data/datasources/auth_local_data_source.dart';
import 'package:soloadventurer/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:soloadventurer/features/auth/domain/entities/user.dart';

class MockAuthRemoteDataSource extends Mock implements AuthRemoteDataSource {}

class MockAuthLocalDataSource extends Mock implements AuthLocalDataSource {}

void main() {
  late MockAuthRemoteDataSource mockRemoteDataSource;
  late MockAuthLocalDataSource mockLocalDataSource;
  late AuthRepositoryImpl authRepository;

  final testDate = DateTime(2024, 3, 14);
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
    expiresAt: testDate.add(const Duration(hours: 1)),
  );

  setUp(() {
    mockRemoteDataSource = MockAuthRemoteDataSource();
    mockLocalDataSource = MockAuthLocalDataSource();
    authRepository =
        AuthRepositoryImpl(mockRemoteDataSource, mockLocalDataSource);
    registerFallbackValue(testUser);
    registerFallbackValue(testAuthResponse);
  });

  group('AuthRepositoryImpl', () {
    group('signInWithEmailAndPassword', () {
      test('should return User when login is successful', () async {
        // Arrange
        when(() => mockRemoteDataSource.signInWithEmailAndPassword(
              any(),
              any(),
            )).thenAnswer((_) async => testAuthResponse);
        when(() => mockLocalDataSource.saveAuthData(any()))
            .thenAnswer((_) async {});
        when(() => mockLocalDataSource.saveUser(any()))
            .thenAnswer((_) async {
              return null;
            });

        // Act
        final result = await authRepository.signInWithEmailAndPassword(
          'test@example.com',
          'password',
        );

        // Assert
        expect(result, isA<User>());
        expect(result.id, equals(testUser.id));
        verify(() => mockLocalDataSource.saveAuthData(testAuthResponse))
            .called(1);
        verify(() => mockLocalDataSource.saveUser(testUser)).called(1);
      });

      test('should throw when login fails', () async {
        // Arrange
        when(() => mockRemoteDataSource.signInWithEmailAndPassword(
              any(),
              any(),
            )).thenThrow(const ServerException(message: 'Invalid credentials'));

        // Act & Assert
        expect(
          () => authRepository.signInWithEmailAndPassword(
            'test@example.com',
            'password',
          ),
          throwsA(isA<ServerException>()),
        );
      });
    });

    group('getCurrentUser', () {
      test('should return cached user when available', () async {
        // Arrange
        when(() => mockLocalDataSource.getUser())
            .thenAnswer((_) async => testUser);

        // Act
        final result = await authRepository.getCurrentUser();

        // Assert
        expect(result, equals(testUser));
        verifyNever(() => mockRemoteDataSource.getCurrentUser());
      });

      test('should fetch from remote when cache is empty', () async {
        // Arrange
        when(() => mockLocalDataSource.getUser()).thenAnswer((_) async => null);
        when(() => mockRemoteDataSource.getCurrentUser())
            .thenAnswer((_) async => testUser);
        when(() => mockLocalDataSource.saveUser(any()))
            .thenAnswer((_) async {
              return null;
            });

        // Act
        final result = await authRepository.getCurrentUser();

        // Assert
        expect(result, equals(testUser));
        verify(() => mockRemoteDataSource.getCurrentUser()).called(1);
        verify(() => mockLocalDataSource.saveUser(testUser)).called(1);
      });
    });

    group('signOut', () {
      test('should clear local data when signout is successful', () async {
        // Arrange
        when(() => mockRemoteDataSource.signOut()).thenAnswer((_) async {});
        when(() => mockLocalDataSource.clearAuthData())
            .thenAnswer((_) async {});
        when(() => mockLocalDataSource.clearUser()).thenAnswer((_) async {
          return null;
        });

        // Act
        await authRepository.signOut();

        // Assert
        verify(() => mockRemoteDataSource.signOut()).called(1);
        verify(() => mockLocalDataSource.clearAuthData()).called(1);
        verify(() => mockLocalDataSource.clearUser()).called(1);
      });

      test('should throw when signout fails', () async {
        // Arrange
        when(() => mockRemoteDataSource.signOut())
            .thenThrow(const ServerException(message: 'Failed to sign out'));

        // Act & Assert
        expect(
          () => authRepository.signOut(),
          throwsA(isA<ServerException>()),
        );
      });
    });

    group('isAuthenticated', () {
      test('should return true when auth data is valid', () async {
        // Arrange
        when(() => mockLocalDataSource.getAuthData())
            .thenAnswer((_) async => testAuthResponse);

        // Act
        final result = await authRepository.isAuthenticated();

        // Assert
        expect(result, isTrue);
      });

      test('should return false when auth data is missing', () async {
        // Arrange
        when(() => mockLocalDataSource.getAuthData())
            .thenAnswer((_) async => null);

        // Act
        final result = await authRepository.isAuthenticated();

        // Assert
        expect(result, isFalse);
      });

      test('should refresh token when expired', () async {
        // Arrange
        final expiredAuthResponse = AuthResponseModel(
          user: testUser,
          accessToken: 'test-access-token',
          refreshToken: 'test-refresh-token',
          expiresAt: testDate.subtract(const Duration(hours: 1)),
        );

        when(() => mockLocalDataSource.getAuthData())
            .thenAnswer((_) async => expiredAuthResponse);
        when(() => mockRemoteDataSource.refreshToken(any()))
            .thenAnswer((_) async => testAuthResponse);
        when(() => mockLocalDataSource.saveAuthData(any()))
            .thenAnswer((_) async {});

        // Act
        final result = await authRepository.isAuthenticated();

        // Assert
        expect(result, isTrue);
        verify(() => mockRemoteDataSource.refreshToken('test-refresh-token'))
            .called(1);
        verify(() => mockLocalDataSource.saveAuthData(testAuthResponse))
            .called(1);
      });
    });

    group('refreshToken', () {
      test('should return true when token refresh is successful', () async {
        // Arrange
        when(() => mockLocalDataSource.getAuthData())
            .thenAnswer((_) async => testAuthResponse);
        when(() => mockRemoteDataSource.refreshToken(any()))
            .thenAnswer((_) async => testAuthResponse);
        when(() => mockLocalDataSource.saveAuthData(any()))
            .thenAnswer((_) async {});

        // Act
        final result = await authRepository.refreshToken();

        // Assert
        expect(result, isTrue);
        verify(() => mockRemoteDataSource.refreshToken('test-refresh-token'))
            .called(1);
        verify(() => mockLocalDataSource.saveAuthData(testAuthResponse))
            .called(1);
      });

      test('should return false when token refresh fails', () async {
        // Arrange
        when(() => mockLocalDataSource.getAuthData())
            .thenAnswer((_) async => testAuthResponse);
        when(() => mockRemoteDataSource.refreshToken(any())).thenThrow(
            const ServerException(message: 'Failed to refresh token'));
        when(() => mockLocalDataSource.clearAuthData())
            .thenAnswer((_) async {});

        // Act
        final result = await authRepository.refreshToken();

        // Assert
        expect(result, isFalse);
        verify(() => mockLocalDataSource.clearAuthData()).called(1);
      });
    });

    group('getAccessToken', () {
      test('should return token when auth data exists', () async {
        // Arrange
        when(() => mockLocalDataSource.getAuthData())
            .thenAnswer((_) async => testAuthResponse);

        // Act
        final result = await authRepository.getAccessToken();

        // Assert
        expect(result, equals('test-access-token'));
      });

      test('should return null when auth data is missing', () async {
        // Arrange
        when(() => mockLocalDataSource.getAuthData())
            .thenAnswer((_) async => null);

        // Act
        final result = await authRepository.getAccessToken();

        // Assert
        expect(result, isNull);
      });
    });
  });
}
