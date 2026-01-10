/// Interface for API service
abstract class ApiService {
  /// Make a GET request to the specified endpoint
  Future<Map<String, dynamic>> get(String endpoint);

  /// Make a POST request to the specified endpoint
  Future<Map<String, dynamic>> post(String endpoint,
      {Map<String, dynamic>? data});

  /// Make a PUT request to the specified endpoint
  Future<Map<String, dynamic>> put(String endpoint,
      {Map<String, dynamic>? data});

  /// Make a DELETE request to the specified endpoint
  Future<Map<String, dynamic>> delete(String endpoint);

  /// Set the authorization token for requests
  void setAuthToken(String token);

  /// Clear the authorization token
  void clearAuthToken();

  /// Set offline mode
  void setOfflineMode(bool offline);
}
