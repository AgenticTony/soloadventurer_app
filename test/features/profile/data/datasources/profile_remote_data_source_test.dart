import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:soloadventurer/core/errors/exceptions.dart';
import 'package:soloadventurer/features/profile/data/datasources/profile_remote_data_source.dart';
import 'package:soloadventurer/features/profile/data/models/profile_model.dart';
import 'mock_dio.dart';

void main() {
  late ProfileRemoteDataSourceImpl dataSource;
  late MockDio mockDio;

  final tProfile = ProfileModel(
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

  setUp(() {
    mockDio = MockDio();
    dataSource = ProfileRemoteDataSourceImpl(dio: mockDio);
  });

  group('getProfile', () {
    const tUserId = 'test_user_id';
    const tPath = '/api/profiles/$tUserId';

    test('should return ProfileModel when the response is 200', () async {
      // arrange
      when(mockDio.get(tPath)).thenAnswer(
        (_) async => Response(
          data: tProfile.toJson(),
          statusCode: 200,
          requestOptions: RequestOptions(path: tPath),
        ),
      );

      // act
      final result = await dataSource.getProfile(tUserId);

      // assert
      expect(result, equals(tProfile));
      verify(mockDio.get(tPath));
    });

    test('should throw ServerException when response is not 200', () async {
      // arrange
      when(mockDio.get(tPath)).thenThrow(
        DioException(
          response: Response(
            data: {'message': 'Server error'},
            statusCode: 500,
            requestOptions: RequestOptions(path: tPath),
          ),
          requestOptions: RequestOptions(path: tPath),
        ),
      );

      // act
      final call = dataSource.getProfile;

      // assert
      expect(() => call(tUserId), throwsA(isA<ServerException>()));
    });
  });

  group('getCurrentProfile', () {
    const tPath = '/api/profiles/me';

    test('should return ProfileModel when the response is 200', () async {
      // arrange
      when(mockDio.get(tPath)).thenAnswer(
        (_) async => Response(
          data: tProfile.toJson(),
          statusCode: 200,
          requestOptions: RequestOptions(path: tPath),
        ),
      );

      // act
      final result = await dataSource.getCurrentProfile();

      // assert
      expect(result, equals(tProfile));
      verify(mockDio.get(tPath));
    });
  });

  group('updateProfile', () {
    final tPath = '/api/profiles/${tProfile.userId}';

    test('should return updated ProfileModel when the response is 200',
        () async {
      // arrange
      when(mockDio.put(
        tPath,
        data: anyNamed('data'),
      )).thenAnswer(
        (_) async => Response(
          data: tProfile.toJson(),
          statusCode: 200,
          requestOptions: RequestOptions(path: tPath),
        ),
      );

      // act
      final result = await dataSource.updateProfile(tProfile);

      // assert
      expect(result, equals(tProfile));
      verify(mockDio.put(
        tPath,
        data: tProfile.toJson(),
      ));
    });
  });

  group('uploadAvatar', () {
    const tUserId = 'test_user_id';
    const tFilePath = 'test/assets/test_avatar.jpg';
    const tAvatarUrl = 'https://example.com/avatars/test.jpg';
    const tPath = '/api/profiles/$tUserId/avatar';

    test('should return avatar URL when upload is successful', () async {
      // arrange
      when(mockDio.post(
        tPath,
        data: anyNamed('data'),
      )).thenAnswer(
        (_) async => Response(
          data: {'avatarUrl': tAvatarUrl},
          statusCode: 200,
          requestOptions: RequestOptions(path: tPath),
        ),
      );

      // Create a temporary test file
      final file = File(tFilePath);
      await file.create(recursive: true);
      await file.writeAsBytes([0, 1, 2, 3]); // dummy image data

      // act
      final result = await dataSource.uploadAvatar(tUserId, tFilePath);

      // assert
      expect(result, equals(tAvatarUrl));
      verify(mockDio.post(
        tPath,
        data: any,
      ));

      // cleanup
      await file.delete();
    });

    test('should throw FileNotFoundException when file does not exist',
        () async {
      // act
      final call = dataSource.uploadAvatar;

      // assert
      expect(
        () => call(tUserId, 'nonexistent/path'),
        throwsA(isA<FileSystemException>()),
      );
    });
  });

  group('error handling', () {
    const tPath = '/api/profiles/any_id';

    test('should throw NetworkTimeoutException on connection timeout',
        () async {
      // arrange
      when(mockDio.get(tPath)).thenThrow(
        DioException(
          type: DioExceptionType.connectionTimeout,
          requestOptions: RequestOptions(path: tPath),
        ),
      );

      // act
      final call = dataSource.getProfile;

      // assert
      expect(
        () => call('any_id'),
        throwsA(isA<NetworkTimeoutException>()),
      );
    });

    test('should throw NetworkConnectivityException on connection error',
        () async {
      // arrange
      when(mockDio.get(tPath)).thenThrow(
        DioException(
          type: DioExceptionType.connectionError,
          requestOptions: RequestOptions(path: tPath),
        ),
      );

      // act
      final call = dataSource.getProfile;

      // assert
      expect(
        () => call('any_id'),
        throwsA(isA<NetworkConnectivityException>()),
      );
    });

    test('should throw ValidationException on 422 response', () async {
      // arrange
      when(mockDio.get(tPath)).thenThrow(
        DioException(
          response: Response(
            data: {
              'message': 'Validation failed',
              'errors': {
                'displayName': ['Display name is required']
              }
            },
            statusCode: 422,
            requestOptions: RequestOptions(path: tPath),
          ),
          requestOptions: RequestOptions(path: tPath),
        ),
      );

      // act
      final call = dataSource.getProfile;

      // assert
      expect(
        () => call('any_id'),
        throwsA(isA<ValidationException>()),
      );
    });
  });
}
