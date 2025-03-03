import 'package:dio/dio.dart';
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
        final response = Response<Map<String, dynamic>>(
          requestOptions: RequestOptions(path: AuthEndpoints.login),
          data: {
            'user': testUserData,
            'access_token': 'test-access-token',
            'refresh_token': 'test-refresh-token',
          },
        );

        when(() => mockApiClient.post<Map<String, dynamic>>(
              AuthEndpoints.login,
              data: any(named: 'data'),
            )).thenAnswer((_) async => response);

        // Act
        final result = await authRemoteDataSource.signIn(
          email: 'test@example.com',
          password: 'password',
        );

        // Assert
        expect(result, equals(response.data));
        verify(() => mockApiClient.post<Map<String, dynamic>>(
              AuthEndpoints.login,
              data: {
                'email': 'test@example.com',
                'password': 'password',
              },
            )).called(1);
      });

      test('should throw ServerException when login fails', () async {
        // Arrange
        when(() => mockApiClient.post<Map<String, dynamic>>(
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
        final response = Response<Map<String, dynamic>>(
          requestOptions: RequestOptions(path: AuthEndpoints.register),
          data: {
            'user': testUserData,
            'access_token': 'test-access-token',
            'refresh_token': 'test-refresh-token',
          },
        );

        when(() => mockApiClient.post<Map<String, dynamic>>(
              AuthEndpoints.register,
              data: any(named: 'data'),
            )).thenAnswer((_) async => response);

        // Act
        final result = await authRemoteDataSource.signUp(
          email: 'test@example.com',
          password: 'password',
          username: 'testuser',
        );

        // Assert
        expect(result, equals(response.data));
        verify(() => mockApiClient.post<Map<String, dynamic>>(
              AuthEndpoints.register,
              data: {
                'email': 'test@example.com',
                'password': 'password',
                'username': 'testuser',
              },
            )).called(1);
      });
    });

    group('getUserProfile', () {
      test('should return User when profile fetch is successful', () async {
        // Arrange
        final response = Response<Map<String, dynamic>>(
          requestOptions: RequestOptions(path: AuthEndpoints.userProfile),
          data: testUserData,
        );

        when(() => mockApiClient.get<Map<String, dynamic>>(
              AuthEndpoints.userProfile,
            )).thenAnswer((_) async => response);

        // Act
        final result = await authRemoteDataSource.getUserProfile();

        // Assert
        expect(result, isA<User>());
        expect(result.id, equals(testUserData['id']));
        expect(result.email, equals(testUserData['email']));
        expect(result.username, equals(testUserData['username']));
        verify(() => mockApiClient.get<Map<String, dynamic>>(
              AuthEndpoints.userProfile,
            )).called(1);
      });

      test('should throw ServerException when profile fetch fails', () async {
        // Arrange
        when(() => mockApiClient.get<Map<String, dynamic>>(
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
        final response = Response<Map<String, dynamic>>(
          requestOptions: RequestOptions(path: AuthEndpoints.userProfile),
          data: testUserData,
        );

        when(() => mockApiClient.put<Map<String, dynamic>>(
              AuthEndpoints.userProfile,
              data: any(named: 'data'),
            )).thenAnswer((_) async => response);

        // Act
        final result = await authRemoteDataSource.updateUserProfile(
          username: 'newusername',
          email: 'newemail@example.com',
        );

        // Assert
        expect(result, isA<User>());
        verify(() => mockApiClient.put<Map<String, dynamic>>(
              AuthEndpoints.userProfile,
              data: {
                'username': 'newusername',
                'email': 'newemail@example.com',
              },
            )).called(1);
      });
    });

    group('changePassword', () {
      test('should complete successfully when password change succeeds',
          () async {
        // Arrange
        final response = Response<Map<String, dynamic>>(
          requestOptions: RequestOptions(path: AuthEndpoints.changePassword),
          data: {},
        );

        when(() => mockApiClient.post<Map<String, dynamic>>(
              AuthEndpoints.changePassword,
              data: any(named: 'data'),
            )).thenAnswer((_) async => response);

        // Act & Assert
        expect(
          authRemoteDataSource.changePassword(
            currentPassword: 'oldpass',
            newPassword: 'newpass',
          ),
          completes,
        );
      });

      test('should throw ServerException when password change fails', () async {
        // Arrange
        when(() => mockApiClient.post<Map<String, dynamic>>(
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
