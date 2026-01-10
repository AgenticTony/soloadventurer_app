/// An error from the API
class ApiError implements Exception {
  /// Creates a new [ApiError] instance
  const ApiError({
    required this.message,
    required this.code,
    this.statusCode,
  });

  /// The error message
  final String message;

  /// The error code
  final String code;

  /// The HTTP status code (if applicable)
  final int? statusCode;

  @override
  String toString() => 'AppException: $message (Code: $code)';
}
