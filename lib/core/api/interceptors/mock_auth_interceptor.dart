import 'package:soloadventurer/core/api/interceptors/auth_interceptor.dart';
import 'package:dio/dio.dart';

/// A mock implementation of [AuthInterceptor] for testing
class MockAuthInterceptor extends AuthInterceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    handler.next(err);
  }
}
