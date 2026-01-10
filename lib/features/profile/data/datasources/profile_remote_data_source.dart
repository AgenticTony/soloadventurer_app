import 'dart:io';
import 'package:dio/dio.dart';
import 'package:soloadventurer/core/errors/exceptions.dart';
import '../models/profile_model.dart';

/// Interface for remote profile data operations
abstract class ProfileRemoteDataSource {
  /// Create a new profile
  Future<ProfileModel> createProfile(ProfileModel profile);

  /// Get profile by user ID from the remote API
  Future<ProfileModel> getProfile(String userId);

  /// Get current user's profile from the remote API
  Future<ProfileModel> getCurrentProfile();

  /// Update profile on the remote API
  Future<ProfileModel> updateProfile(ProfileModel profile);

  /// Update specific profile fields on the remote API
  Future<ProfileModel> updateProfileFields(
      String userId, Map<String, dynamic> fields);

  /// Delete profile on the remote API
  Future<void> deleteProfile(String userId);

  /// Upload avatar to remote storage
  Future<String> uploadAvatar(String userId, String filePath);

  /// Remove avatar from remote storage
  Future<void> removeAvatar(String userId);

  /// Update profile preferences on the remote API
  Future<void> updatePreferences(
      String userId, Map<String, dynamic> preferences);

  /// Update profile interests on the remote API
  Future<void> updateInterests(String userId, List<String> interests);

  /// Toggle profile visibility on the remote API
  Future<void> toggleProfileVisibility(String userId, bool isPublic);

  /// Check if profile exists on the remote API
  Future<bool> profileExists(String userId);
}

/// Implementation of [ProfileRemoteDataSource] using REST API
class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  final Dio _dio;
  static const String _baseUrl = '/api/profiles';

  ProfileRemoteDataSourceImpl({required Dio dio}) : _dio = dio;

  @override
  Future<ProfileModel> createProfile(ProfileModel profile) async {
    try {
      final response = await _dio.post(
        _baseUrl,
        data: profile.toJson(),
      );
      return ProfileModel.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<ProfileModel> getProfile(String userId) async {
    try {
      final response = await _dio.get('$_baseUrl/$userId');
      return ProfileModel.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<ProfileModel> getCurrentProfile() async {
    try {
      final response = await _dio.get('$_baseUrl/me');
      return ProfileModel.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<ProfileModel> updateProfile(ProfileModel profile) async {
    try {
      final response = await _dio.put(
        '$_baseUrl/${profile.userId}',
        data: profile.toJson(),
      );
      return ProfileModel.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<ProfileModel> updateProfileFields(
      String userId, Map<String, dynamic> fields) async {
    try {
      final response = await _dio.patch(
        '$_baseUrl/$userId',
        data: fields,
      );
      return ProfileModel.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<void> deleteProfile(String userId) async {
    try {
      await _dio.delete('$_baseUrl/$userId');
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<String> uploadAvatar(String userId, String filePath) async {
    try {
      final file = File(filePath);
      final formData = FormData.fromMap({
        'avatar': await MultipartFile.fromFile(file.path),
      });

      final response = await _dio.post(
        '$_baseUrl/$userId/avatar',
        data: formData,
      );

      return response.data['avatarUrl'];
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<void> removeAvatar(String userId) async {
    try {
      await _dio.delete('$_baseUrl/$userId/avatar');
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<void> updatePreferences(
      String userId, Map<String, dynamic> preferences) async {
    try {
      await _dio.put(
        '$_baseUrl/$userId/preferences',
        data: {'preferences': preferences},
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<void> updateInterests(String userId, List<String> interests) async {
    try {
      await _dio.put(
        '$_baseUrl/$userId/interests',
        data: {'interests': interests},
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<void> toggleProfileVisibility(String userId, bool isPublic) async {
    try {
      await _dio.put(
        '$_baseUrl/$userId/visibility',
        data: {'isPublic': isPublic},
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<bool> profileExists(String userId) async {
    try {
      final response = await _dio.head('$_baseUrl/$userId');
      return response.statusCode == 200;
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return false;
      }
      throw _handleDioError(e);
    }
  }

  Exception _handleDioError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const NetworkTimeoutException(message: 'Connection timeout');
      case DioExceptionType.connectionError:
        return const NetworkConnectivityException(
            message: 'No internet connection');
      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        final message = e.response?.data['message'] ?? 'Unknown error occurred';
        final errors = e.response?.data['errors'] as Map<String, List<String>>?;

        switch (statusCode) {
          case 400:
            return BadRequestException(message: message);
          case 401:
            return UnauthorizedException(message: message);
          case 403:
            return ForbiddenException(message: message);
          case 404:
            return NotFoundException(message: message);
          case 409:
            return ConflictException(message: message);
          case 422:
            return ValidationException(
              message: message,
              errors: errors ??
                  {
                    'general': [message]
                  },
            );
          default:
            return ServerException(message: message);
        }
      case DioExceptionType.cancel:
        return const RequestCancelledException(
            message: 'Request was cancelled');
      default:
        return const UnknownException(message: 'An unexpected error occurred');
    }
  }
}
