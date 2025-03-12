import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:soloadventurer/core/api/client/api_client.dart';
import 'package:soloadventurer/core/errors/app_exception.dart';
import 'package:soloadventurer/features/auth/data/sources/auth_remote_data_source.dart';
import 'package:soloadventurer/features/auth/domain/entities/user.dart';

class MockApiClient extends Mock implements ApiClient {}

void main() {
  late MockApiClient mockApiClient;
  late AuthRemoteDataSource authRemoteDataSource;

  final testDate = DateTime(2024, 3, 14);
  final testUserData = {
    'id': 'test-id',
    'email': 'test@example.com',
    'username': 'testuser',
    'createdAt': testDate.toIso8601String(),
    'lastLoginAt': null,
  };

  setUp(() {
    mockApiClient = MockApiClient();
    authRemoteDataSource = AuthRemoteDataSourceImpl(apiClient: mockApiClient);
    registerFallbackValue({});
  });

  group('AuthRemoteDataSource', () {
    group('signIn', () {
      test('should return auth data when login is successful', () async {
        // Arrange
        final responseData = {
          'user': testUserData,
          'access_token': 'test-access-token',
          'refresh_token': 'test-refresh-token',
        };

        when(() => mockApiClient.post(
              AuthEndpoints.login,
              data: any(named: 'data'),
            )).thenAnswer((_) async => responseData);

        // Act
        final result = await authRemoteDataSource.signIn(
          email: 'test@example.com',
          password: 'password',
        );

        // Assert
        expect(result, equals(responseData));
        verify(() => mockApiClient.post(
              AuthEndpoints.login,
              data: {
                'email': 'test@example.com',
                'password': 'password',
              },
            )).called(1);
      });

      test('should throw ServerException when login fails', () async {
        // Arrange
        when(() => mockApiClient.post(
              AuthEndpoints.login,
              data: any(named: 'data'),
            )).thenThrow(const ServerException(message: 'Invalid credentials'));

        // Act & Assert
        expect(
          () => authRemoteDataSource.signIn(
            email: 'test@example.com',
            password: 'password',
          ),
          throwsA(isA<ServerException>()),
        );
      });
    });

    group('signUp', () {
      test('should return auth data when registration is successful', () async {
        // Arrange
        final responseData = {
          'user': testUserData,
          'access_token': 'test-access-token',
          'refresh_token': 'test-refresh-token',
        };

        when(() => mockApiClient.post(
              AuthEndpoints.register,
              data: any(named: 'data'),
            )).thenAnswer((_) async => responseData);

        // Act
        final result = await authRemoteDataSource.signUp(
          email: 'test@example.com',
          password: 'password',
          username: 'testuser',
        );

        // Assert
        expect(result, equals(responseData));
        verify(() => mockApiClient.post(
              AuthEndpoints.register,
              data: {
                'email': 'test@example.com',
                'password': 'password',
                'username': 'testuser',
              },
            )).called(1);
      });

      test('should throw ServerException when registration fails', () async {
        // Arrange
        when(() => mockApiClient.post(
                  AuthEndpoints.register,
                  data: any(named: 'data'),
                ))
            .thenThrow(const ServerException(message: 'Email already exists'));

        // Act & Assert
        expect(
          () => authRemoteDataSource.signUp(
            email: 'test@example.com',
            password: 'password',
            username: 'testuser',
          ),
          throwsA(isA<ServerException>()),
        );
      });
    });

    group('confirmSignUp', () {
      test('should complete successfully when confirmation succeeds', () async {
        // Arrange
        when(() => mockApiClient.post(
              AuthEndpoints.confirm,
              data: any(named: 'data'),
            )).thenAnswer((_) async => {});

        // Act & Assert
        expect(
          authRemoteDataSource.confirmSignUp(
            email: 'test@example.com',
            confirmationCode: '123456',
          ),
          completes,
        );

        verify(() => mockApiClient.post(
              AuthEndpoints.confirm,
              data: {
                'email': 'test@example.com',
                'code': '123456',
              },
            )).called(1);
      });

      test('should throw ServerException when confirmation fails', () async {
        // Arrange
        when(() => mockApiClient.post(
              AuthEndpoints.confirm,
              data: any(named: 'data'),
            )).thenThrow(const ServerException(message: 'Invalid code'));

        // Act & Assert
        expect(
          () => authRemoteDataSource.confirmSignUp(
            email: 'test@example.com',
            confirmationCode: '123456',
          ),
          throwsA(isA<ServerException>()),
        );
      });
    });

    group('resendConfirmationCode', () {
      test('should complete successfully when resend succeeds', () async {
        // Arrange
        when(() => mockApiClient.post(
              AuthEndpoints.resendCode,
              data: any(named: 'data'),
            )).thenAnswer((_) async => {});

        // Act & Assert
        expect(
          authRemoteDataSource.resendConfirmationCode(
            email: 'test@example.com',
          ),
          completes,
        );

        verify(() => mockApiClient.post(
              AuthEndpoints.resendCode,
              data: {
                'email': 'test@example.com',
              },
            )).called(1);
      });
    });

    group('refreshToken', () {
      test('should return new tokens when refresh succeeds', () async {
        // Arrange
        final responseData = {
          'access_token': 'new-access-token',
          'refresh_token': 'new-refresh-token',
        };

        when(() => mockApiClient.post(
              AuthEndpoints.refreshToken,
              data: any(named: 'data'),
            )).thenAnswer((_) async => responseData);

        // Act
        final result = await authRemoteDataSource.refreshToken(
          refreshToken: 'old-refresh-token',
        );

        // Assert
        expect(result, equals(responseData));
        verify(() => mockApiClient.post(
              AuthEndpoints.refreshToken,
              data: {
                'refreshToken': 'old-refresh-token',
              },
            )).called(1);
      });

      test('should throw ServerException when refresh fails', () async {
        // Arrange
        when(() => mockApiClient.post(
                  AuthEndpoints.refreshToken,
                  data: any(named: 'data'),
                ))
            .thenThrow(const ServerException(message: 'Invalid refresh token'));

        // Act & Assert
        expect(
          () => authRemoteDataSource.refreshToken(
            refreshToken: 'old-refresh-token',
          ),
          throwsA(isA<ServerException>()),
        );
      });
    });

    group('forgotPassword', () {
      test('should complete successfully when request succeeds', () async {
        // Arrange
        when(() => mockApiClient.post(
              AuthEndpoints.forgotPassword,
              data: any(named: 'data'),
            )).thenAnswer((_) async => {});

        // Act & Assert
        expect(
          authRemoteDataSource.forgotPassword(
            email: 'test@example.com',
          ),
          completes,
        );

        verify(() => mockApiClient.post(
              AuthEndpoints.forgotPassword,
              data: {
                'email': 'test@example.com',
              },
            )).called(1);
      });
    });

    group('confirmPasswordReset', () {
      test('should complete successfully when reset succeeds', () async {
        // Arrange
        when(() => mockApiClient.post(
              AuthEndpoints.resetPassword,
              data: any(named: 'data'),
            )).thenAnswer((_) async => {});

        // Act & Assert
        expect(
          authRemoteDataSource.confirmPasswordReset(
            email: 'test@example.com',
            code: '123456',
            newPassword: 'newpassword',
          ),
          completes,
        );

        verify(() => mockApiClient.post(
              AuthEndpoints.resetPassword,
              data: {
                'email': 'test@example.com',
                'code': '123456',
                'newPassword': 'newpassword',
              },
            )).called(1);
      });

      test('should throw ServerException when reset fails', () async {
        // Arrange
        when(() => mockApiClient.post(
              AuthEndpoints.resetPassword,
              data: any(named: 'data'),
            )).thenThrow(const ServerException(message: 'Invalid code'));

        // Act & Assert
        expect(
          () => authRemoteDataSource.confirmPasswordReset(
            email: 'test@example.com',
            code: '123456',
            newPassword: 'newpassword',
          ),
          throwsA(isA<ServerException>()),
        );
      });
    });

    group('getUserProfile', () {
      test('should return User when profile fetch is successful', () async {
        // Arrange
        when(() => mockApiClient.get(
              AuthEndpoints.userProfile,
            )).thenAnswer((_) async => testUserData);

        // Act
        final result = await authRemoteDataSource.getUserProfile();

        // Assert
        expect(result, isA<User>());
        expect(result.id, equals(testUserData['id']));
        expect(result.email, equals(testUserData['email']));
        expect(result.username, equals(testUserData['username']));
        verify(() => mockApiClient.get(
              AuthEndpoints.userProfile,
            )).called(1);
      });

      test('should throw ServerException when profile fetch fails', () async {
        // Arrange
        when(() => mockApiClient.get(
                  AuthEndpoints.userProfile,
                ))
            .thenThrow(const ServerException(message: 'Failed to get profile'));

        // Act & Assert
        expect(
          () => authRemoteDataSource.getUserProfile(),
          throwsA(isA<ServerException>()),
        );
      });
    });

    group('updateUserProfile', () {
      test('should return updated User when update is successful', () async {
        // Arrange
        final updatedUserData = Map<String, dynamic>.from(testUserData)
          ..update('username', (value) => 'newusername')
          ..update('email', (value) => 'newemail@example.com');

        when(() => mockApiClient.put(
              AuthEndpoints.userProfile,
              data: any(named: 'data'),
            )).thenAnswer((_) async => updatedUserData);

        // Act
        final result = await authRemoteDataSource.updateUserProfile(
          username: 'newusername',
          email: 'newemail@example.com',
        );

        // Assert
        expect(result, isA<User>());
        expect(result.username, equals('newusername'));
        expect(result.email, equals('newemail@example.com'));
        verify(() => mockApiClient.put(
              AuthEndpoints.userProfile,
              data: {
                'username': 'newusername',
                'email': 'newemail@example.com',
              },
            )).called(1);
      });

      test('should throw ServerException when update fails', () async {
        // Arrange
        when(() => mockApiClient.put(
                  AuthEndpoints.userProfile,
                  data: any(named: 'data'),
                ))
            .thenThrow(
                const ServerException(message: 'Failed to update profile'));

        // Act & Assert
        expect(
          () => authRemoteDataSource.updateUserProfile(
            username: 'newusername',
            email: 'newemail@example.com',
          ),
          throwsA(isA<ServerException>()),
        );
      });
    });

    group('changePassword', () {
      test('should complete successfully when password change succeeds',
          () async {
        // Arrange
        when(() => mockApiClient.post(
              AuthEndpoints.changePassword,
              data: any(named: 'data'),
            )).thenAnswer((_) async => {});

        // Act & Assert
        expect(
          authRemoteDataSource.changePassword(
            currentPassword: 'oldpass',
            newPassword: 'newpass',
          ),
          completes,
        );

        verify(() => mockApiClient.post(
              AuthEndpoints.changePassword,
              data: {
                'currentPassword': 'oldpass',
                'newPassword': 'newpass',
              },
            )).called(1);
      });

      test('should throw ServerException when password change fails', () async {
        // Arrange
        when(() => mockApiClient.post(
              AuthEndpoints.changePassword,
              data: any(named: 'data'),
            )).thenThrow(const ServerException(message: 'Invalid password'));

        // Act & Assert
        expect(
          () => authRemoteDataSource.changePassword(
            currentPassword: 'oldpass',
            newPassword: 'newpass',
          ),
          throwsA(isA<ServerException>()),
        );
      });
    });
  });
}
