/// A response from the API
class ApiResponse {
  /// Creates a new [ApiResponse] instance
  const ApiResponse({
    required this.statusCode,
    required this.data,
  });

  /// The HTTP status code of the response
  final int statusCode;

  /// The response data
  final Map<String, dynamic> data;
}
