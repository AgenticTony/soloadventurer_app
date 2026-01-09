import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:soloadventurer/core/api/client/api_client.dart';
import 'package:soloadventurer/core/api/interceptors/auth_interceptor.dart';
import 'package:soloadventurer/core/api/interceptors/error_interceptor.dart';
import 'package:soloadventurer/core/monitoring/performance/network_monitor.dart';

/// Provider for Dio instance
final dioProvider = Provider<Dio>((ref) {
  return Dio(BaseOptions(
    baseUrl: 'https://api.soloadventurer.com',
    connectTimeout: const Duration(seconds: 5),
    receiveTimeout: const Duration(seconds: 3),
  ));
});

/// Provider for AuthInterceptor
final authInterceptorProvider = Provider<AuthInterceptor>((ref) {
  return AuthInterceptor();
});

/// Provider for ErrorInterceptor
final errorInterceptorProvider = Provider<ErrorInterceptor>((ref) {
  return ErrorInterceptor();
});

/// Provider for NetworkMonitor
final networkMonitorProvider = Provider<NetworkMonitor>((ref) {
  return NetworkMonitor();
});

/// Provider for ApiClient (using core/api/client/api_client.dart)
final apiClientProviderFull = Provider<ApiClient>((ref) {
  final dio = ref.watch(dioProvider);
  final authInterceptor = ref.watch(authInterceptorProvider);
  final errorInterceptor = ref.watch(errorInterceptorProvider);
  final networkMonitor = ref.watch(networkMonitorProvider);

  return ApiClient(
    baseUrl: 'https://api.soloadventurer.com',
    authInterceptor: authInterceptor,
    errorInterceptor: errorInterceptor,
    networkMonitor: networkMonitor,
  );
});
