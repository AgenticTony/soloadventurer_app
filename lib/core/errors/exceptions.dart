/// Base exception class for application-specific exceptions
abstract class AppException implements Exception {
  /// Message describing the exception
  final String message;

  /// Error code for the exception
  final String? code;

  /// Creates a new [AppException] with the given [message] and optional [code]
  const AppException({
    required this.message,
    this.code,
  });

  @override
  String toString() =>
      'AppException: $message${code != null ? ' (Code: $code)' : ''}';
}

/// Exception thrown when a network request times out
class NetworkTimeoutException extends AppException {
  /// Creates a new [NetworkTimeoutException] with the given [message] and optional [code]
  const NetworkTimeoutException({
    required super.message,
    String? code,
  }) : super(code: code ?? 'network_timeout');
}

/// Exception thrown when there is no internet connection
class NetworkConnectivityException extends AppException {
  /// Creates a new [NetworkConnectivityException] with the given [message] and optional [code]
  const NetworkConnectivityException({
    required super.message,
    String? code,
  }) : super(code: code ?? 'network_connectivity');
}

/// Exception thrown when a request is cancelled
class RequestCancelledException extends AppException {
  /// Creates a new [RequestCancelledException] with the given [message] and optional [code]
  const RequestCancelledException({
    required super.message,
    String? code,
  }) : super(code: code ?? 'request_cancelled');
}

/// Exception thrown when a request is invalid (400)
class BadRequestException extends AppException {
  /// Creates a new [BadRequestException] with the given [message] and optional [code]
  const BadRequestException({
    required super.message,
    String? code,
  }) : super(code: code ?? 'bad_request');
}

/// Exception thrown when a user is not authenticated (401)
class UnauthorizedException extends AppException {
  /// Creates a new [UnauthorizedException] with the given [message] and optional [code]
  const UnauthorizedException({
    required super.message,
    String? code,
  }) : super(code: code ?? 'unauthorized');
}

/// Exception thrown when a user is forbidden from accessing a resource (403)
class ForbiddenException extends AppException {
  /// Creates a new [ForbiddenException] with the given [message] and optional [code]
  const ForbiddenException({
    required super.message,
    String? code,
  }) : super(code: code ?? 'forbidden');
}

/// Exception thrown when a resource is not found (404)
class NotFoundException extends AppException {
  /// Creates a new [NotFoundException] with the given [message] and optional [code]
  const NotFoundException({
    required super.message,
    String? code,
  }) : super(code: code ?? 'not_found');
}

/// Exception thrown when there is a conflict with the current state (409)
class ConflictException extends AppException {
  /// Creates a new [ConflictException] with the given [message] and optional [code]
  const ConflictException({
    required super.message,
    String? code,
  }) : super(code: code ?? 'conflict');
}

/// Exception thrown when validation fails (422)
class ValidationException extends AppException {
  /// Map of field names to error messages
  final Map<String, List<String>> errors;

  /// Creates a new [ValidationException] with the given [message], [errors], and optional [code]
  const ValidationException({
    required super.message,
    required this.errors,
    String? code,
  }) : super(code: code ?? 'validation_failed');

  @override
  String toString() {
    return 'ValidationException: $message (Code: ${code ?? 'validation_failed'}) - Errors: $errors';
  }
}

/// Exception thrown when there is a server error (500, 501, 502, 503)
class ServerException extends AppException {
  /// Creates a new [ServerException] with the given [message] and optional [code]
  const ServerException({
    required super.message,
    String? code,
  }) : super(code: code ?? 'server_error');
}

/// Exception thrown when the cause is unknown
class UnknownException extends AppException {
  /// Creates a new [UnknownException] with the given [message] and optional [code]
  const UnknownException({
    required super.message,
    String? code,
  }) : super(code: code ?? 'unknown_error');
}

/// Exception thrown when authentication operations fail
class AuthException extends AppException {
  /// The original error that caused this exception
  final Object? originalError;

  /// Creates a new [AuthException] with the given [message], optional [originalError], and optional [code]
  const AuthException(
    String message, {
    this.originalError,
    String? code,
  }) : super(message: message, code: code);
}

/// Exception thrown when there is a cache error
class CacheException extends AppException {
  /// Creates a new [CacheException] with the given [message] and optional [code]
  const CacheException({
    required super.message,
    String? code,
  }) : super(code: code ?? 'cache_error');
}

/// Exception thrown when media compression fails
class MediaCompressionException extends AppException {
  /// Creates a new [MediaCompressionException] with the given [message] and optional [code]
  const MediaCompressionException({
    required super.message,
    String? code,
  }) : super(code: code ?? 'media_compression_error');
}

/// Exception thrown when image format is not supported
class UnsupportedImageFormatException extends AppException {
  /// Creates a new [UnsupportedImageFormatException] with the given [message] and optional [code]
  const UnsupportedImageFormatException({
    required super.message,
    String? code,
  }) : super(code: code ?? 'unsupported_image_format');
}

/// Exception thrown when image file is too large or corrupted
class InvalidImageException extends AppException {
  /// Creates a new [InvalidImageException] with the given [message] and optional [code]
  const InvalidImageException({
    required super.message,
    String? code,
  }) : super(code: code ?? 'invalid_image');
}

/// Exception thrown when video format is not supported
class UnsupportedVideoFormatException extends AppException {
  /// Creates a new [UnsupportedVideoFormatException] with the given [message] and optional [code]
  const UnsupportedVideoFormatException({
    required super.message,
    String? code,
  }) : super(code: code ?? 'unsupported_video_format');
}

/// Exception thrown when video file is invalid, too large, or corrupted
class InvalidVideoException extends AppException {
  /// Creates a new [InvalidVideoException] with the given [message] and optional [code]
  const InvalidVideoException({
    required super.message,
    String? code,
  }) : super(code: code ?? 'invalid_video');
}

/// Exception thrown when location operations fail
class LocationException extends AppException {
  /// Creates a new [LocationException] with the given [message] and optional [code]
  const LocationException({
    required super.message,
    String? code,
  }) : super(code: code ?? 'location_error');
}

/// Exception thrown when geocoding operations fail
class GeocodingException extends AppException {
  /// Creates a new [GeocodingException] with the given [message] and optional [code]
  const GeocodingException({
    required super.message,
    String? code,
  }) : super(code: code ?? 'geocoding_error');
}

/// Exception thrown when EXIF data extraction fails
class ExifException extends AppException {
  /// Creates a new [ExifException] with the given [message] and optional [code]
  const ExifException({
    required super.message,
    String? code,
  }) : super(code: code ?? 'exif_error');
}
