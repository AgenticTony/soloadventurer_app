/// Interface for making HTTP requests
abstract class ApiService {
  /// Performs a GET request to the specified path
  Future<Map<String, dynamic>> get(String path);

  /// Performs a POST request to the specified path with optional data
  Future<Map<String, dynamic>> post(String path, {Map<String, dynamic>? data});

  /// Performs a PUT request to the specified path with optional data
  Future<Map<String, dynamic>> put(String path, {Map<String, dynamic>? data});

  /// Performs a DELETE request to the specified path
  Future<void> delete(String path);

  /// Performs a PATCH request to the specified path with optional data
  Future<Map<String, dynamic>> patch(String path, {Map<String, dynamic>? data});

  /// Performs a multipart request to the specified path with file data
  Future<Map<String, dynamic>> multipart(
    String path, {
    required String method,
    required Map<String, dynamic> files,
  });

  /// Sets the authorization token for subsequent requests
  void setAuthToken(String token);

  /// Clears the authorization token
  void clearAuthToken();

  /// Gets the current authorization token
  String? getAuthToken();

  /// Sets additional headers for subsequent requests
  void setHeaders(Map<String, String> headers);

  /// Gets the current headers
  Map<String, String> getHeaders();

  /// Sets the base URL for subsequent requests
  void setBaseUrl(String baseUrl);

  /// Gets the current base URL
  String getBaseUrl();
}
