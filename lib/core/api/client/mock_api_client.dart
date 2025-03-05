import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:soloadventurer/core/api/client/api_client.dart';
import 'package:soloadventurer/core/api/models/api_response.dart';
import 'package:soloadventurer/core/api/models/api_error.dart';
import 'package:soloadventurer/core/api/interceptors/mock_auth_interceptor.dart';
import 'package:soloadventurer/core/api/interceptors/mock_error_interceptor.dart';
import 'package:soloadventurer/core/monitoring/performance/mock_network_monitor.dart';
import '../api_service.dart';
import '../interceptors/auth_interceptor.dart';
import '../interceptors/error_interceptor.dart';
import '../../monitoring/performance/network_monitor.dart';

/// A mock implementation of [ApiService] for testing
class MockApiClient implements ApiService {
  final NetworkMonitor _networkMonitor;
  bool _isOffline = false;

  /// Creates a new [MockApiClient] instance
  MockApiClient({
    String baseUrl = 'http://mock.test',
    required AuthInterceptor authInterceptor,
    required ErrorInterceptor errorInterceptor,
    required NetworkMonitor networkMonitor,
  }) : _networkMonitor = networkMonitor;

  @override
  void setOfflineMode(bool offline) {
    _isOffline = offline;
  }

  @override
  void setAuthToken(String token) {
    // No-op in mock
  }

  @override
  void clearAuthToken() {
    // No-op in mock
  }

  @override
  Future<Map<String, dynamic>> post(String endpoint,
      {Map<String, dynamic>? data}) async {
    if (_isOffline) {
      throw Exception('No internet connection');
    }

    _networkMonitor.trackRequest(endpoint);

    // Simulate successful responses based on the endpoint
    switch (endpoint) {
      case '/auth/register':
        final response = {
          'user': {
            'id': '1',
            'email': data?['email'],
            'username': data?['username'],
            'created_at': DateTime.now().toIso8601String(),
            'updated_at': DateTime.now().toIso8601String(),
          },
          'token': 'mock_token',
          'refresh_token': 'mock_refresh_token',
          'expires_at':
              DateTime.now().add(const Duration(hours: 1)).toIso8601String(),
        };

        _networkMonitor.trackRequestAndResponse(
          path: endpoint,
          duration: const Duration(milliseconds: 100),
          statusCode: 201,
          responseSize: 0,
        );

        return response;

      case '/auth/login':
        final response = {
          'token': 'mock_auth_token',
          'refresh_token': 'mock_refresh_token',
          'expires_at':
              DateTime.now().add(const Duration(hours: 1)).toIso8601String(),
          'user': {
            'id': '1',
            'email': data?['email'],
            'username': 'Test User',
            'created_at': DateTime.now().toIso8601String(),
            'last_login_at': DateTime.now().toIso8601String(),
          },
        };

        _networkMonitor.trackRequestAndResponse(
          path: endpoint,
          duration: const Duration(milliseconds: 100),
          statusCode: 200,
          responseSize: 0,
        );

        return response;

      default:
        throw Exception('Endpoint not mocked: $endpoint');
    }
  }

  @override
  Future<Map<String, dynamic>> get(String endpoint) async {
    if (_isOffline) {
      throw Exception('No internet connection');
    }

    _networkMonitor.trackRequest(endpoint);

    // Simulate successful responses based on the endpoint
    switch (endpoint) {
      case '/auth/user':
        final response = {
          'id': '1',
          'email': 'test@example.com',
          'username': 'Test User',
          'created_at': DateTime.now().toIso8601String(),
          'last_login_at': DateTime.now().toIso8601String(),
        };

        _networkMonitor.trackRequestAndResponse(
          path: endpoint,
          duration: const Duration(milliseconds: 100),
          statusCode: 200,
          responseSize: 0,
        );

        return response;

      default:
        throw Exception('Endpoint not mocked: $endpoint');
    }
  }

  @override
  Future<Map<String, dynamic>> put(String endpoint,
      {Map<String, dynamic>? data}) async {
    throw UnimplementedError('PUT method not mocked');
  }

  @override
  Future<Map<String, dynamic>> delete(String endpoint) async {
    throw UnimplementedError('DELETE method not mocked');
  }
}
