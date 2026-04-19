import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:soloadventurer/core/errors/exceptions.dart';
import 'package:soloadventurer/core/storage/secure_storage_adapter.dart';
import 'package:soloadventurer/features/auth/data/models/auth_response_model.dart';
import 'package:soloadventurer/features/auth/data/models/user_model.dart';
import 'package:soloadventurer/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:soloadventurer/features/auth/data/datasources/auth_local_data_source.dart';
import 'package:soloadventurer/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:soloadventurer/features/auth/domain/entities/user.dart';
import 'package:soloadventurer/features/auth/domain/models/auth_session.dart';

class MockAuthRemoteDataSource extends Mock implements AuthRemoteDataSource {}

class MockAuthLocalDataSource extends Mock implements AuthLocalDataSource {}

class MockSecurityManagerAdapter extends Mock implements SecurityManagerAdapter {}

void main() {
  late MockAuthRemoteDataSource mockRemoteDataSource;
  late MockAuthLocalDataSource mockLocalDataSource;
  late MockSecurityManagerAdapter mockSecurityManager;
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
    mockSecurityManager = MockSecurityManagerAdapter();
    authRepository = AuthRepositoryImpl(
      remoteDataSource: mockRemoteDataSource,
      localDataSource: mockLocalDataSource,
      securityManager: mockSecurityManager,
    );
    registerFallbackValue(testUser);
    registerFallbackValue(testAuthResponse);
    registerFallbackValue(AuthSession(
      accessToken: '',
      idToken: '',
      refreshToken: '',
      expiresAt: DateTime.now(),
    ));
  });

  group('AuthRepositoryImpl', () {
    group('signInWithEmailAndPassword', () {
      test('should return User when login is successful', () async {
        // Arrange
        when(() => mockSecurityManager.checkLoginAttempts())
            .thenAnswer((_) async {});
        when(() => mockRemoteDataSource.signIn(any(), any()))
            .thenAnswer((_) async => (
                  testUser,
                  AuthSession(
                    accessToken: 'test-access-token',
                    idToken: 'test-id-token',
                    refreshToken: 'test-refresh-token',
                    expiresAt: DateTime.now().add(const Duration(hours: 1)),
                  ),
                ));
        when(() => mockSecurityManager.isKnownDevice())
            .thenAnswer((_) async => true);
        when(() => mockSecurityManager.resetLoginAttempts())
            .thenAnswer((_) async {});
        when(() => mockLocalDataSource.saveAuthData(
              any(that: isA<String>()),
              any(that: isA<String>()),
              expiresAt: any(named: 'expiresAt', that: isA<DateTime>()),
              idToken: any(named: 'idToken', that: isA<String>()),
            )).thenAnswer((_) async {});
        when(() => mockLocalDataSource.cacheUser(any()))
            .thenAnswer((_) async {});

        // Act
        final result = await authRepository.signInWithEmailAndPassword(
          'test@example.com',
          'password',
        );

        // Assert
        expect(result, isA<User>());
        expect(result.email, equals('test@example.com'));
        verify(() => mockLocalDataSource.saveAuthData(
              any(that: isA<String>()),
              any(that: isA<String>()),
              expiresAt: any(named: 'expiresAt', that: isA<DateTime>()),
              idToken: any(named: 'idToken', that: isA<String>()),
            )).called(1);
        verify(() => mockLocalDataSource.cacheUser(any(that: isA<User>())))
            .called(1);
      });

      test('should throw when login fails', () async {
        // Arrange
        when(() => mockSecurityManager.checkLoginAttempts())
            .thenAnswer((_) async {});
        when(() => mockRemoteDataSource.signIn(any(), any()))
            .thenThrow(const AuthException('Invalid credentials'));
        when(() => mockSecurityManager.recordFailedLoginAttempt())
            .thenAnswer((_) async {});

        // Act & Assert
        expect(
          () => authRepository.signInWithEmailAndPassword(
            'test@example.com',
            'password',
          ),
          throwsA(isA<AuthException>()),
        );
      });
    });

    group('getCurrentUser', () {
      test('should return cached user when available', () async {
        // Arrange
        when(() => mockLocalDataSource.getCachedUser())
            .thenAnswer((_) async => testUser);
        when(() => mockLocalDataSource.hasValidSession())
            .thenAnswer((_) async => true);
        when(() => mockSecurityManager.isKnownDevice())
            .thenAnswer((_) async => true);

        // Act
        final result = await authRepository.getCurrentUser();

        // Assert
        expect(result, equals(testUser));
        verifyNever(() => mockRemoteDataSource.getCurrentUser());
      });

      test('should fetch from remote when cache is empty', () async {
        // Arrange
        when(() => mockLocalDataSource.getCachedUser())
            .thenAnswer((_) async => null);
        when(() => mockRemoteDataSource.getCurrentUser())
            .thenAnswer((_) async => testUser);
        when(() => mockLocalDataSource.cacheUser(any()))
            .thenAnswer((_) async {});

        // Act
        final result = await authRepository.getCurrentUser();

        // Assert
        expect(result, equals(testUser));
        verify(() => mockRemoteDataSource.getCurrentUser()).called(1);
        verify(() => mockLocalDataSource.cacheUser(testUser)).called(1);
      });
    });

    group('signOut', () {
      test('should clear local data when signout is successful', () async {
        // Arrange
        when(() => mockRemoteDataSource.signOut()).thenAnswer((_) async {});
        when(() => mockLocalDataSource.clearCache())
            .thenAnswer((_) async {});
        when(() => mockSecurityManager.resetLoginAttempts())
            .thenAnswer((_) async {});

        // Act
        await authRepository.signOut();

        // Assert
        verify(() => mockRemoteDataSource.signOut()).called(1);
        verify(() => mockLocalDataSource.clearCache()).called(1);
        verify(() => mockSecurityManager.resetLoginAttempts()).called(1);
      });

      test('should throw when signout fails', () async {
        // Arrange
        when(() => mockRemoteDataSource.signOut())
            .thenThrow(const ServerException(message: 'Failed to sign out'));
        when(() => mockLocalDataSource.clearCache())
            .thenAnswer((_) async {});
        when(() => mockSecurityManager.resetLoginAttempts())
            .thenAnswer((_) async {});

        // Act & Assert
        expect(
          () => authRepository.signOut(),
          throwsA(isA<ServerException>()),
        );
      });
    });

    group('isAuthenticated', () {
      test('should return true when session is valid', () async {
        // Arrange
        when(() => mockSecurityManager.isKnownDevice())
            .thenAnswer((_) async => true);
        when(() => mockLocalDataSource.hasValidSession())
            .thenAnswer((_) async => true);
        when(() => mockLocalDataSource.getCachedUser())
            .thenAnswer((_) async => testUser);

        // Act
        final result = await authRepository.isAuthenticated();

        // Assert
        expect(result, isTrue);
      });

      test('should return false when session is invalid', () async {
        // Arrange
        when(() => mockSecurityManager.isKnownDevice())
            .thenAnswer((_) async => true);
        when(() => mockLocalDataSource.hasValidSession())
            .thenAnswer((_) async => false);

        // Act
        final result = await authRepository.isAuthenticated();

        // Assert
        expect(result, isFalse);
      });

      test('should refresh token when expired', () async {
        // Arrange
        when(() => mockLocalDataSource.hasValidSession())
            .thenAnswer((_) async => false);
        when(() => mockSecurityManager.isKnownDevice())
            .thenAnswer((_) async => true);
        when(() => mockLocalDataSource.saveAuthData(
              any(that: isA<String>()),
              any(that: isA<String>()),
              expiresAt: any(named: 'expiresAt', that: isA<DateTime>()),
              idToken: any(named: 'idToken', that: isA<String>()),
            )).thenAnswer((_) async {});

        // Act
        final result = await authRepository.isAuthenticated();

        // Assert
        expect(result, isFalse);
        verify(() => mockLocalDataSource.hasValidSession()).called(1);
      });
    });

    group('refreshToken', () {
      test('should return true when token refresh is successful', () async {
        // Arrange
        final authSession = AuthSession(
          accessToken: 'test-access-token',
          idToken: 'test-id-token',
          refreshToken: 'test-refresh-token',
          expiresAt: DateTime.now().add(const Duration(hours: 1)),
        );

        when(() => mockRemoteDataSource.refreshToken())
            .thenAnswer((_) async => authSession);
        when(() => mockLocalDataSource.saveAuthData(
              any(that: isA<String>()),
              any(that: isA<String>()),
              expiresAt: any(named: 'expiresAt', that: isA<DateTime>()),
              idToken: any(named: 'idToken', that: isA<String>()),
            )).thenAnswer((_) async {});

        // Act
        final result = await authRepository.refreshToken();

        // Assert
        expect(result, equals(authSession));
        verify(() => mockRemoteDataSource.refreshToken()).called(1);
        verify(() => mockLocalDataSource.saveAuthData(
              any(that: isA<String>()),
              any(that: isA<String>()),
              expiresAt: any(named: 'expiresAt', that: isA<DateTime>()),
              idToken: any(named: 'idToken', that: isA<String>()),
            )).called(1);
      });

      test('should throw when token refresh fails', () async {
        // Arrange
        when(() => mockRemoteDataSource.refreshToken())
            .thenThrow(const AuthException('Failed to refresh token'));

        // Act & Assert
        expect(
          () => authRepository.refreshToken(),
          throwsA(isA<AuthException>()),
        );
      });
    });

    group('getAccessToken', () {
      test('should return token when session is valid', () async {
        // Arrange
        when(() => mockSecurityManager.isKnownDevice())
            .thenAnswer((_) async => true);
        when(() => mockLocalDataSource.hasValidSession())
            .thenAnswer((_) async => true);
        when(() => mockLocalDataSource.getAuthToken())
            .thenAnswer((_) async => 'test-access-token');

        // Act
        final result = await authRepository.getAccessToken();

        // Assert
        expect(result, equals('test-access-token'));
      });

      test('should return null when session is invalid', () async {
        // Arrange
        when(() => mockSecurityManager.isKnownDevice())
            .thenAnswer((_) async => true);
        when(() => mockLocalDataSource.hasValidSession())
            .thenAnswer((_) async => false);

        // Act
        final result = await authRepository.getAccessToken();

        // Assert
        expect(result, isNull);
      });
    });
  });
}
