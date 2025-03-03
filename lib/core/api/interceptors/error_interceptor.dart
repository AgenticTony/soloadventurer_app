import 'dart:io';

import 'package:dio/dio.dart';
import 'package:soloadventurer/core/errors/app_exception.dart';

/// Interceptor for handling API errors
class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // Transform Dio errors into app-specific exceptions
    final exception = _handleError(err);

    // Pass the transformed exception to the next handler
    handler.next(
      DioException(
        requestOptions: err.requestOptions,
        error: exception,
        response: err.response,
        type: err.type,
        message: exception.message,
      ),
    );
  }

  /// Handle different types of Dio errors and convert them to AppException
  AppException _handleError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const NetworkTimeoutException(
          message:
              'Connection timed out. Please check your internet connection.',
        );

      case DioExceptionType.badResponse:
        return _handleResponseError(error);

      case DioExceptionType.cancel:
        return const RequestCancelledException(
          message: 'Request was cancelled',
        );

      case DioExceptionType.connectionError:
        return const NetworkConnectivityException(
          message: 'No internet connection',
        );

      case DioExceptionType.unknown:
      default:
        if (error.error is SocketException) {
          return const NetworkConnectivityException(
            message: 'No internet connection',
          );
        }
        return UnknownException(
          message: error.message ?? 'An unexpected error occurred',
        );
    }
  }

  /// Handle HTTP response errors based on status code
  AppException _handleResponseError(DioException error) {
    final statusCode = error.response?.statusCode;
    final responseData = error.response?.data;

    String errorMessage = 'An error occurred';
    if (responseData is Map<String, dynamic> &&
        responseData.containsKey('message')) {
      errorMessage = responseData['message'] as String;
    }

    switch (statusCode) {
      case 400:
        return BadRequestException(message: errorMessage);
      case 401:
        return UnauthorizedException(message: errorMessage);
      case 403:
        return ForbiddenException(message: errorMessage);
      case 404:
        return NotFoundException(message: errorMessage);
      case 409:
        return ConflictException(message: errorMessage);
      case 422:
        return ValidationException(
          message: errorMessage,
          errors: _extractValidationErrors(responseData),
        );
      case 500:
      case 501:
      case 502:
      case 503:
        return ServerException(message: errorMessage);
      default:
        return UnknownException(message: errorMessage);
    }
  }

  /// Extract validation errors from response data
  Map<String, List<String>> _extractValidationErrors(dynamic responseData) {
    final result = <String, List<String>>{};

    if (responseData is Map<String, dynamic> &&
        responseData.containsKey('errors') &&
        responseData['errors'] is Map) {
      final errors = responseData['errors'] as Map<String, dynamic>;

      errors.forEach((key, value) {
        if (value is List) {
          result[key] = List<String>.from(value.map((e) => e.toString()));
        } else if (value is String) {
          result[key] = [value];
        }
      });
    }

    return result;
  }
}
