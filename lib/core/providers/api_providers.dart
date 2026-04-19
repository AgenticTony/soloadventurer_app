import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:soloadventurer/core/api/client/api_client.dart';
import 'package:soloadventurer/core/api/interceptors/auth_interceptor.dart';
import 'package:soloadventurer/core/api/interceptors/error_interceptor.dart';
import 'package:soloadventurer/core/monitoring/performance/network_monitor.dart';
import 'package:soloadventurer/app/providers/auth_service_providers.dart';

/// Provider for Dio instance
final dioProvider = Provider<Dio>((ref) {
  return Dio(BaseOptions(
    baseUrl: 'https://api.soloadventurer.com',
    connectTimeout: const Duration(seconds: 5),
    receiveTimeout: const Duration(seconds: 10),
  ));
});

/// Provider for AuthInterceptor
///
/// Wires [AuthInterceptor] with the [AuthRepository] from
/// [authRepositoryProvider] and the shared [Dio] instance.
final authInterceptorProvider = Provider<AuthInterceptor>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  final dio = ref.watch(dioProvider);
  return AuthInterceptor(authRepository: authRepository, dio: dio);
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
